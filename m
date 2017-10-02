Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 704436B026B
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 10:23:44 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id d45so810297uag.21
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 07:23:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r125si2603240qkf.360.2017.10.02.07.23.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Oct 2017 07:23:43 -0700 (PDT)
Date: Mon, 2 Oct 2017 17:23:41 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC] [PATCH] mm,oom: Offload OOM notify callback to a kernel
 thread.
Message-ID: <20171002171641-mutt-send-email-mst@kernel.org>
References: <20171002090627.547gkmzvutrsamex@dhcp22.suse.cz>
 <201710022033.GFE82801.HLOVOFFJtSFQMO@I-love.SAKURA.ne.jp>
 <20171002115035.7sph6ul6hsszdwa4@dhcp22.suse.cz>
 <201710022205.IGD04659.HSOMJFFQtFOLOV@I-love.SAKURA.ne.jp>
 <20171002131330.5c5mpephrosfuxsa@dhcp22.suse.cz>
 <201710022252.DDJ51535.JFQSLFHFVOtOOM@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201710022252.DDJ51535.JFQSLFHFVOtOOM@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, linux-mm@kvack.org

On Mon, Oct 02, 2017 at 10:52:55PM +0900, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Mon 02-10-17 22:05:17, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > On Mon 02-10-17 20:33:52, Tetsuo Handa wrote:
> > > > > > I do not think that making oom notifier API more complex is the way to
> > > > > > go. Can we simply change the lock to try_lock?
> > > > > 
> > > > > Using mutex_trylock(&vb->balloon_lock) alone is not sufficient. Inside the
> > > > > mutex, __GFP_DIRECT_RECLAIM && !__GFP_NORETRY allocation attempt is used
> > > > > which will fail to make progress due to oom_lock already held. Therefore,
> > > > > virtballoon_oom_notify() needs to guarantee that all allocation attempts use
> > > > > GFP_NOWAIT when called from virtballoon_oom_notify().
> > > > 
> > > > Ohh, I missed your point and thought the dependency is indirect and some
> > > > other call path is allocating while holding the lock. But you seem to be
> > > > right and
> > > > leak_balloon
> > > >   tell_host
> > > >     virtqueue_add_outbuf
> > > >       virtqueue_add
> > > > 
> > > > can do GFP_KERNEL allocation and this is clearly wrong. Nobody should
> > > > try to allocate while we are in the OOM path. Michael, is there any way
> > > > to drop this?
> > > 
> > > Michael already said
> > > 
> > >   That would be tricky to fix. I guess we'll need to drop the lock
> > >   while allocating memory - not an easy fix.
> > 
> > We are OOM, we cannot allocate _any_ memory! This is just broken.
> > 
> > > and I think that it would be possible for virtio to locally offload
> > > virtballoon_oom_notify() using this patch's approach, if you don't like
> > > globally offloading at the OOM notifier API level.
> > 
> > Even if the allocation is offloaded to a different context we are sill
> > OOM and we would have to block waiting for it which is just error prone.
> 
> Like I comment below, I'm assuming that this deadlock should rarely
> happen from the beginning. Since GFP_KERNEL allocation is conditional,
> we might be able to avoid the allocation from virtballoon_oom_notify().
> 
> Michael S. Tsirkin wrote:
> > > @@ -1005,17 +1033,21 @@ int unregister_oom_notifier(struct notifier_block *nb)
> > >   */
> > >  bool out_of_memory(struct oom_control *oc)
> > >  {
> > > -	unsigned long freed = 0;
> > >  	enum oom_constraint constraint = CONSTRAINT_NONE;
> > >  
> > >  	if (oom_killer_disabled)
> > >  		return false;
> > >  
> > > -	if (!is_memcg_oom(oc)) {
> > > -		blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
> > > -		if (freed > 0)
> > > +	if (!is_memcg_oom(oc) && oom_notifier_th) {
> > > +		oom_notifier_requested = true;
> > > +		wake_up(&oom_notifier_request_wait);
> > > +		wait_event_timeout(oom_notifier_response_wait,
> > > +				   !oom_notifier_requested, 5 * HZ);
> > 
> > I guess this means what was earlier a deadlock will free up after 5
> > seconds,
> 
> Yes.
> 
> >          by a 5 sec downtime is still a lot, isn't it?
> 
> This timeout should unlikely expire. Please note that this offloading is
> intended for handling the worst scenario, that is, "out_of_memory() is called
> when somebody is already holding vb->balloon_lock lock" and
> "GFP_KERNEL allocation is attempted from virtballoon_oom_notify()".
> 
> As far as I know, this lock is held when fill_balloon() or leak_balloon() is
> called. Majority of OOM events call out_of_memory() without holding this lock.
> Thus, "out_of_memory() is called when somebody is already holding vb->balloon_lock
> lock" should rarely happen from the beginning.
> 
> If you can artificially trigger this deadlock (i.e. user triggerable OOM DoS),
> a patch for fixing this problem needs to be backported to older/distributor
> kernels...
> 
> Yes, conditional GFP_KERNEL allocation attempt from virtqueue_add() might
> still cause this deadlock. But that depends on whether you can trigger this
> deadlock. As far as I know, there is no report. Thus, I think that avoiding
> theoretical deadlock using timeout will be sufficient.


So first of all IMHO GFP_KERNEL allocations do not happen in
virtqueue_add_outbuf at all. They only trigger through add_sgs.

IMHO this is an API bug, we should just drop the gfp parameter
from this API.


so the issue is balloon_page_enqueue only.


> > 
> > 
> > > +		if (oom_notifier_freed) {
> > > +			oom_notifier_freed = 0;
> > >  			/* Got some memory back in the last second. */
> > >  			return true;
> > > +		}
> > >  	}
> > >  
> > >  	/*
> > > -- 
> > > 1.8.3.1
> > 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
