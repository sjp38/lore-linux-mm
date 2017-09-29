Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7CE876B0038
	for <linux-mm@kvack.org>; Fri, 29 Sep 2017 00:44:59 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id u136so794324pgc.5
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 21:44:59 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id l7si2635011pgs.418.2017.09.28.21.44.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 28 Sep 2017 21:44:58 -0700 (PDT)
Subject: Re: mm, virtio: possible OOM lockup at virtballoon_oom_notify()
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201709111927.IDD00574.tFVJHLOSOOMQFF@I-love.SAKURA.ne.jp>
	<20170929065654-mutt-send-email-mst@kernel.org>
In-Reply-To: <20170929065654-mutt-send-email-mst@kernel.org>
Message-Id: <201709291344.FID60965.VHtMQFFJFSLOOO@I-love.SAKURA.ne.jp>
Date: Fri, 29 Sep 2017 13:44:52 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mst@redhat.com
Cc: jasowang@redhat.com, virtualization@lists.linux-foundation.org, linux-mm@kvack.org

Michael S. Tsirkin wrote:
> On Mon, Sep 11, 2017 at 07:27:19PM +0900, Tetsuo Handa wrote:
> > Hello.
> > 
> > I noticed that virtio_balloon is using register_oom_notifier() and
> > leak_balloon() from virtballoon_oom_notify() might depend on
> > __GFP_DIRECT_RECLAIM memory allocation.
> > 
> > In leak_balloon(), mutex_lock(&vb->balloon_lock) is called in order to
> > serialize against fill_balloon(). But in fill_balloon(),
> > alloc_page(GFP_HIGHUSER[_MOVABLE] | __GFP_NOMEMALLOC | __GFP_NORETRY) is
> > called with vb->balloon_lock mutex held. Since GFP_HIGHUSER[_MOVABLE] implies
> > __GFP_DIRECT_RECLAIM | __GFP_IO | __GFP_FS, this allocation attempt might
> > depend on somebody else's __GFP_DIRECT_RECLAIM | !__GFP_NORETRY memory
> > allocation. Such __GFP_DIRECT_RECLAIM | !__GFP_NORETRY allocation can reach
> > __alloc_pages_may_oom() and hold oom_lock mutex and call out_of_memory().
> > And leak_balloon() is called by virtballoon_oom_notify() via
> > blocking_notifier_call_chain() callback when vb->balloon_lock mutex is already
> > held by fill_balloon(). As a result, despite __GFP_NORETRY is specified,
> > fill_balloon() can indirectly get stuck waiting for vb->balloon_lock mutex
> > at leak_balloon().
> 
> That would be tricky to fix. I guess we'll need to drop the lock
> while allocating memory - not an easy fix.
> 
> > Also, in leak_balloon(), virtqueue_add_outbuf(GFP_KERNEL) is called via
> > tell_host(). Reaching __alloc_pages_may_oom() from this virtqueue_add_outbuf()
> > request from leak_balloon() from virtballoon_oom_notify() from
> > blocking_notifier_call_chain() from out_of_memory() leads to OOM lockup
> > because oom_lock mutex is already held before calling out_of_memory().
> 
> I guess we should just do
> 
> GFP_KERNEL & ~__GFP_DIRECT_RECLAIM there then?

Yes, but GFP_KERNEL & ~__GFP_DIRECT_RECLAIM will effectively be GFP_NOWAIT, for
__GFP_IO and __GFP_FS won't make sense without __GFP_DIRECT_RECLAIM. It might
significantly increases possibility of memory allocation failure.

> 
> 
> > 
> > OOM notifier callback should not (directly or indirectly) depend on
> > __GFP_DIRECT_RECLAIM memory allocation attempt. Can you fix this dependency?
> 

Another idea would be to use a kernel thread (or workqueue) so that
virtballoon_oom_notify() can wait with timeout.

We could offload entire blocking_notifier_call_chain(&oom_notify_list, 0, &freed)
call to a kernel thread (or workqueue) with timeout if MM folks agree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
