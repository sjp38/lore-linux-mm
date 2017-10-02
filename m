Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3AA9F6B0069
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 09:05:25 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id f84so12072936pfj.0
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 06:05:25 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id u8si4327370plr.725.2017.10.02.06.05.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 02 Oct 2017 06:05:23 -0700 (PDT)
Subject: Re: [RFC] [PATCH] mm,oom: Offload OOM notify callback to a kernel thread.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201710011444.IBD05725.VJSFHOOMOFtLQF@I-love.SAKURA.ne.jp>
	<20171002065801-mutt-send-email-mst@kernel.org>
	<20171002090627.547gkmzvutrsamex@dhcp22.suse.cz>
	<201710022033.GFE82801.HLOVOFFJtSFQMO@I-love.SAKURA.ne.jp>
	<20171002115035.7sph6ul6hsszdwa4@dhcp22.suse.cz>
In-Reply-To: <20171002115035.7sph6ul6hsszdwa4@dhcp22.suse.cz>
Message-Id: <201710022205.IGD04659.HSOMJFFQtFOLOV@I-love.SAKURA.ne.jp>
Date: Mon, 2 Oct 2017 22:05:17 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: mst@redhat.com, linux-mm@kvack.org

(Reducing recipients in a hope not to be filtered at the servers.)

Michal Hocko wrote:
> On Mon 02-10-17 20:33:52, Tetsuo Handa wrote:
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
> > > I do not think that making oom notifier API more complex is the way to
> > > go. Can we simply change the lock to try_lock?
> > 
> > Using mutex_trylock(&vb->balloon_lock) alone is not sufficient. Inside the
> > mutex, __GFP_DIRECT_RECLAIM && !__GFP_NORETRY allocation attempt is used
> > which will fail to make progress due to oom_lock already held. Therefore,
> > virtballoon_oom_notify() needs to guarantee that all allocation attempts use
> > GFP_NOWAIT when called from virtballoon_oom_notify().
> 
> Ohh, I missed your point and thought the dependency is indirect and some
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

Michael already said

  That would be tricky to fix. I guess we'll need to drop the lock
  while allocating memory - not an easy fix.

and I think that it would be possible for virtio to locally offload
virtballoon_oom_notify() using this patch's approach, if you don't like
globally offloading at the OOM notifier API level.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
