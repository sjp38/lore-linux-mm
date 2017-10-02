Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id D2E0C6B0033
	for <linux-mm@kvack.org>; Sun,  1 Oct 2017 23:59:21 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id i12so3748621qka.15
        for <linux-mm@kvack.org>; Sun, 01 Oct 2017 20:59:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a27si2878550qtd.410.2017.10.01.20.59.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Oct 2017 20:59:20 -0700 (PDT)
Date: Mon, 2 Oct 2017 06:59:12 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC] [PATCH] mm,oom: Offload OOM notify callback to a kernel
 thread.
Message-ID: <20171002065801-mutt-send-email-mst@kernel.org>
References: <201709111927.IDD00574.tFVJHLOSOOMQFF@I-love.SAKURA.ne.jp>
 <20170929065654-mutt-send-email-mst@kernel.org>
 <201709291344.FID60965.VHtMQFFJFSLOOO@I-love.SAKURA.ne.jp>
 <201710011444.IBD05725.VJSFHOOMOFtLQF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201710011444.IBD05725.VJSFHOOMOFtLQF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: jasowang@redhat.com, jani.nikula@linux.intel.com, joonas.lahtinen@linux.intel.com, rodrigo.vivi@intel.com, airlied@linux.ie, paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, virtualization@lists.linux-foundation.org, intel-gfx@lists.freedesktop.org, linux-mm@kvack.org

On Sun, Oct 01, 2017 at 02:44:34PM +0900, Tetsuo Handa wrote:
> Tetsuo Handa wrote:
> > Michael S. Tsirkin wrote:
> > > On Mon, Sep 11, 2017 at 07:27:19PM +0900, Tetsuo Handa wrote:
> > > > Hello.
> > > > 
> > > > I noticed that virtio_balloon is using register_oom_notifier() and
> > > > leak_balloon() from virtballoon_oom_notify() might depend on
> > > > __GFP_DIRECT_RECLAIM memory allocation.
> > > > 
> > > > In leak_balloon(), mutex_lock(&vb->balloon_lock) is called in order to
> > > > serialize against fill_balloon(). But in fill_balloon(),
> > > > alloc_page(GFP_HIGHUSER[_MOVABLE] | __GFP_NOMEMALLOC | __GFP_NORETRY) is
> > > > called with vb->balloon_lock mutex held. Since GFP_HIGHUSER[_MOVABLE] implies
> > > > __GFP_DIRECT_RECLAIM | __GFP_IO | __GFP_FS, this allocation attempt might
> > > > depend on somebody else's __GFP_DIRECT_RECLAIM | !__GFP_NORETRY memory
> > > > allocation. Such __GFP_DIRECT_RECLAIM | !__GFP_NORETRY allocation can reach
> > > > __alloc_pages_may_oom() and hold oom_lock mutex and call out_of_memory().
> > > > And leak_balloon() is called by virtballoon_oom_notify() via
> > > > blocking_notifier_call_chain() callback when vb->balloon_lock mutex is already
> > > > held by fill_balloon(). As a result, despite __GFP_NORETRY is specified,
> > > > fill_balloon() can indirectly get stuck waiting for vb->balloon_lock mutex
> > > > at leak_balloon().
> > > 
> > > That would be tricky to fix. I guess we'll need to drop the lock
> > > while allocating memory - not an easy fix.
> > > 
> > > > Also, in leak_balloon(), virtqueue_add_outbuf(GFP_KERNEL) is called via
> > > > tell_host(). Reaching __alloc_pages_may_oom() from this virtqueue_add_outbuf()
> > > > request from leak_balloon() from virtballoon_oom_notify() from
> > > > blocking_notifier_call_chain() from out_of_memory() leads to OOM lockup
> > > > because oom_lock mutex is already held before calling out_of_memory().
> > > 
> > > I guess we should just do
> > > 
> > > GFP_KERNEL & ~__GFP_DIRECT_RECLAIM there then?
> > 
> > Yes, but GFP_KERNEL & ~__GFP_DIRECT_RECLAIM will effectively be GFP_NOWAIT, for
> > __GFP_IO and __GFP_FS won't make sense without __GFP_DIRECT_RECLAIM. It might
> > significantly increases possibility of memory allocation failure.
> > 
> > > 
> > > 
> > > > 
> > > > OOM notifier callback should not (directly or indirectly) depend on
> > > > __GFP_DIRECT_RECLAIM memory allocation attempt. Can you fix this dependency?
> > > 
> > 
> > Another idea would be to use a kernel thread (or workqueue) so that
> > virtballoon_oom_notify() can wait with timeout.
> > 
> > We could offload entire blocking_notifier_call_chain(&oom_notify_list, 0, &freed)
> > call to a kernel thread (or workqueue) with timeout if MM folks agree.
> > 
> 
> Below is a patch which offloads blocking_notifier_call_chain() call. What do you think?
> ----------------------------------------
> [RFC] [PATCH] mm,oom: Offload OOM notify callback to a kernel thread.
> 
> Since oom_notify_list is traversed via blocking_notifier_call_chain(),
> it is legal to sleep inside OOM notifier callback function.
> 
> However, since oom_notify_list is traversed with oom_lock held,
> __GFP_DIRECT_RECLAIM && !__GFP_NORETRY memory allocation attempt cannot
> fail when traversing oom_notify_list entries. Therefore, OOM notifier
> callback function should not (directly or indirectly) depend on
> __GFP_DIRECT_RECLAIM && !__GFP_NORETRY memory allocation attempt.
> 
> Currently there are 5 register_oom_notifier() users in the mainline kernel.
> 
>   arch/powerpc/platforms/pseries/cmm.c
>   arch/s390/mm/cmm.c
>   drivers/gpu/drm/i915/i915_gem_shrinker.c
>   drivers/virtio/virtio_balloon.c
>   kernel/rcu/tree_plugin.h
> 
> Among these users, at least virtio_balloon.c has possibility of OOM lockup
> because it is using mutex which can depend on GFP_KERNEL memory allocations.
> (Both cmm.c seem to be safe as they use spinlocks. I'm not sure about
> tree_plugin.h and i915_gem_shrinker.c . Please check.)
> 
> But converting such allocations to use GFP_NOWAIT is not only prone to
> allocation failures under memory pressure but also difficult to audit
> whether all locations are converted to use GFP_NOWAIT.
> 
> Therefore, this patch offloads blocking_notifier_call_chain() call to a
> dedicated kernel thread and wait for completion with timeout of 5 seconds
> so that we can completely forget about possibility of OOM lockup due to
> OOM notifier callback function.
> 
> (5 seconds is chosen from my guess that blocking_notifier_call_chain()
> should not take long, for we are using mutex_trylock(&oom_lock) at
> __alloc_pages_may_oom() based on an assumption that out_of_memory() should
> reclaim memory shortly.)
> 
> The kernel thread is created upon first register_oom_notifier() call.
> Thus, those environments which do not use register_oom_notifier() will
> not waste resource for the dedicated kernel thread.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  mm/oom_kill.c | 40 ++++++++++++++++++++++++++++++++++++----
>  1 file changed, 36 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index dee0f75..d9744f7 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -981,9 +981,37 @@ static void check_panic_on_oom(struct oom_control *oc,
>  }
>  
>  static BLOCKING_NOTIFIER_HEAD(oom_notify_list);
> +static bool oom_notifier_requested;
> +static unsigned long oom_notifier_freed;
> +static struct task_struct *oom_notifier_th;
> +static DECLARE_WAIT_QUEUE_HEAD(oom_notifier_request_wait);
> +static DECLARE_WAIT_QUEUE_HEAD(oom_notifier_response_wait);
> +
> +static int oom_notifier(void *unused)
> +{
> +	while (true) {
> +		wait_event_freezable(oom_notifier_request_wait,
> +				     oom_notifier_requested);
> +		blocking_notifier_call_chain(&oom_notify_list, 0,
> +					     &oom_notifier_freed);
> +		oom_notifier_requested = false;
> +		wake_up(&oom_notifier_response_wait);
> +	}
> +	return 0;
> +}
>  
>  int register_oom_notifier(struct notifier_block *nb)
>  {
> +	if (!oom_notifier_th) {
> +		struct task_struct *th = kthread_run(oom_notifier, NULL,
> +						     "oom_notifier");
> +
> +		if (IS_ERR(th)) {
> +			pr_err("Unable to start OOM notifier thread.\n");
> +			return (int) PTR_ERR(th);
> +		}
> +		oom_notifier_th = th;
> +	}
>  	return blocking_notifier_chain_register(&oom_notify_list, nb);
>  }
>  EXPORT_SYMBOL_GPL(register_oom_notifier);
> @@ -1005,17 +1033,21 @@ int unregister_oom_notifier(struct notifier_block *nb)
>   */
>  bool out_of_memory(struct oom_control *oc)
>  {
> -	unsigned long freed = 0;
>  	enum oom_constraint constraint = CONSTRAINT_NONE;
>  
>  	if (oom_killer_disabled)
>  		return false;
>  
> -	if (!is_memcg_oom(oc)) {
> -		blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
> -		if (freed > 0)
> +	if (!is_memcg_oom(oc) && oom_notifier_th) {
> +		oom_notifier_requested = true;
> +		wake_up(&oom_notifier_request_wait);
> +		wait_event_timeout(oom_notifier_response_wait,
> +				   !oom_notifier_requested, 5 * HZ);

I guess this means what was earlier a deadlock will free up after 5
seconds, by a 5 sec downtime is still a lot, isn't it?


> +		if (oom_notifier_freed) {
> +			oom_notifier_freed = 0;
>  			/* Got some memory back in the last second. */
>  			return true;
> +		}
>  	}
>  
>  	/*
> -- 
> 1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
