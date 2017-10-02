Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 750846B025F
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 10:12:00 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id t134so1593276oih.6
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 07:12:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c8si4533837oih.496.2017.10.02.07.11.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Oct 2017 07:11:59 -0700 (PDT)
Date: Mon, 2 Oct 2017 17:11:55 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC] [PATCH] mm,oom: Offload OOM notify callback to a kernel
 thread.
Message-ID: <20171002170642-mutt-send-email-mst@kernel.org>
References: <20170929065654-mutt-send-email-mst@kernel.org>
 <201709291344.FID60965.VHtMQFFJFSLOOO@I-love.SAKURA.ne.jp>
 <201710011444.IBD05725.VJSFHOOMOFtLQF@I-love.SAKURA.ne.jp>
 <20171002065801-mutt-send-email-mst@kernel.org>
 <20171002090627.547gkmzvutrsamex@dhcp22.suse.cz>
 <201710022033.GFE82801.HLOVOFFJtSFQMO@I-love.SAKURA.ne.jp>
 <20171002115035.7sph6ul6hsszdwa4@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171002115035.7sph6ul6hsszdwa4@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, jasowang@redhat.com, jani.nikula@linux.intel.com, joonas.lahtinen@linux.intel.com, rodrigo.vivi@intel.com, airlied@linux.ie, paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, virtualization@lists.linux-foundation.org, intel-gfx@lists.freedesktop.org, linux-mm@kvack.org

On Mon, Oct 02, 2017 at 01:50:35PM +0200, Michal Hocko wrote:
> On Mon 02-10-17 20:33:52, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > [Hmm, I do not see the original patch which this has been a reply to]
> > 
> > urbl.hostedemail.com and b.barracudacentral.org blocked my IP address,
> > and the rest are "Recipient address rejected: Greylisted" or
> > "Deferred: 451-4.3.0 Multiple destination domains per transaction is unsupported.",
> > and after all dropped at the servers. Sad...
> > 
> > > 
> > > On Mon 02-10-17 06:59:12, Michael S. Tsirkin wrote:
> > > > On Sun, Oct 01, 2017 at 02:44:34PM +0900, Tetsuo Handa wrote:
> > > > > Tetsuo Handa wrote:
> > > > > > Michael S. Tsirkin wrote:
> > > > > > > On Mon, Sep 11, 2017 at 07:27:19PM +0900, Tetsuo Handa wrote:
> > > > > > > > Hello.
> > > > > > > > 
> > > > > > > > I noticed that virtio_balloon is using register_oom_notifier() and
> > > > > > > > leak_balloon() from virtballoon_oom_notify() might depend on
> > > > > > > > __GFP_DIRECT_RECLAIM memory allocation.
> > > > > > > > 
> > > > > > > > In leak_balloon(), mutex_lock(&vb->balloon_lock) is called in order to
> > > > > > > > serialize against fill_balloon(). But in fill_balloon(),
> > > > > > > > alloc_page(GFP_HIGHUSER[_MOVABLE] | __GFP_NOMEMALLOC | __GFP_NORETRY) is
> > > > > > > > called with vb->balloon_lock mutex held. Since GFP_HIGHUSER[_MOVABLE] implies
> > > > > > > > __GFP_DIRECT_RECLAIM | __GFP_IO | __GFP_FS, this allocation attempt might
> > > > > > > > depend on somebody else's __GFP_DIRECT_RECLAIM | !__GFP_NORETRY memory
> > > > > > > > allocation. Such __GFP_DIRECT_RECLAIM | !__GFP_NORETRY allocation can reach
> > > > > > > > __alloc_pages_may_oom() and hold oom_lock mutex and call out_of_memory().
> > > > > > > > And leak_balloon() is called by virtballoon_oom_notify() via
> > > > > > > > blocking_notifier_call_chain() callback when vb->balloon_lock mutex is already
> > > > > > > > held by fill_balloon(). As a result, despite __GFP_NORETRY is specified,
> > > > > > > > fill_balloon() can indirectly get stuck waiting for vb->balloon_lock mutex
> > > > > > > > at leak_balloon().
> > > 
> > > This is really nasty! And I would argue that this is an abuse of the oom
> > > notifier interface from the virtio code. OOM notifiers are an ugly hack
> > > on its own but all its users have to be really careful to not depend on
> > > any allocation request because that is a straight deadlock situation.
> > 
> > Please describe such warning at
> > "int register_oom_notifier(struct notifier_block *nb)" definition.
> 
> Yes, we can and should do that. Although I would prefer to simply
> document this API as deprecated. Care to send a patch? I am quite busy
> with other stuff.
> 
> > > I do not think that making oom notifier API more complex is the way to
> > > go. Can we simply change the lock to try_lock?
> > 
> > Using mutex_trylock(&vb->balloon_lock) alone is not sufficient. Inside the
> > mutex, __GFP_DIRECT_RECLAIM && !__GFP_NORETRY allocation attempt is used
> > which will fail to make progress due to oom_lock already held. Therefore,
> > virtballoon_oom_notify() needs to guarantee that all allocation attempts use
> > GFP_NOWAIT when called from virtballoon_oom_notify().
> 
> Ohh, I missed your point and thought the dependency is indirect

I do think this is the case. See below.


> and some
> other call path is allocating while holding the lock. But you seem to be
> right and
> leak_balloon
>   tell_host
>     virtqueue_add_outbuf
>       virtqueue_add
> 
> can do GFP_KERNEL allocation and this is clearly wrong. Nobody should
> try to allocate while we are in the OOM path. Michael, is there any way
> to drop this?

Yes - in practice it won't ever allocate - that path is never taken
with add_outbuf - it is for add_sgs only.

IMHO the issue is balloon inflation which needs to allocate
memory. It does it under a mutex, and oom handler tries to take the
same mutex.


> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
