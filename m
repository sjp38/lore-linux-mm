Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 161E46B0038
	for <linux-mm@kvack.org>; Fri, 29 Sep 2017 00:00:14 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id w63so133496qkd.0
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 21:00:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h8si2963315qtf.321.2017.09.28.21.00.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Sep 2017 21:00:13 -0700 (PDT)
Date: Fri, 29 Sep 2017 07:00:05 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: mm, virtio: possible OOM lockup at virtballoon_oom_notify()
Message-ID: <20170929065654-mutt-send-email-mst@kernel.org>
References: <201709111927.IDD00574.tFVJHLOSOOMQFF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201709111927.IDD00574.tFVJHLOSOOMQFF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: jasowang@redhat.com, virtualization@lists.linux-foundation.org, linux-mm@kvack.org

On Mon, Sep 11, 2017 at 07:27:19PM +0900, Tetsuo Handa wrote:
> Hello.
> 
> I noticed that virtio_balloon is using register_oom_notifier() and
> leak_balloon() from virtballoon_oom_notify() might depend on
> __GFP_DIRECT_RECLAIM memory allocation.
> 
> In leak_balloon(), mutex_lock(&vb->balloon_lock) is called in order to
> serialize against fill_balloon(). But in fill_balloon(),
> alloc_page(GFP_HIGHUSER[_MOVABLE] | __GFP_NOMEMALLOC | __GFP_NORETRY) is
> called with vb->balloon_lock mutex held. Since GFP_HIGHUSER[_MOVABLE] implies
> __GFP_DIRECT_RECLAIM | __GFP_IO | __GFP_FS, this allocation attempt might
> depend on somebody else's __GFP_DIRECT_RECLAIM | !__GFP_NORETRY memory
> allocation. Such __GFP_DIRECT_RECLAIM | !__GFP_NORETRY allocation can reach
> __alloc_pages_may_oom() and hold oom_lock mutex and call out_of_memory().
> And leak_balloon() is called by virtballoon_oom_notify() via
> blocking_notifier_call_chain() callback when vb->balloon_lock mutex is already
> held by fill_balloon(). As a result, despite __GFP_NORETRY is specified,
> fill_balloon() can indirectly get stuck waiting for vb->balloon_lock mutex
> at leak_balloon().

That would be tricky to fix. I guess we'll need to drop the lock
while allocating memory - not an easy fix.

> Also, in leak_balloon(), virtqueue_add_outbuf(GFP_KERNEL) is called via
> tell_host(). Reaching __alloc_pages_may_oom() from this virtqueue_add_outbuf()
> request from leak_balloon() from virtballoon_oom_notify() from
> blocking_notifier_call_chain() from out_of_memory() leads to OOM lockup
> because oom_lock mutex is already held before calling out_of_memory().

I guess we should just do

GFP_KERNEL & ~__GFP_DIRECT_RECLAIM there then?


> 
> OOM notifier callback should not (directly or indirectly) depend on
> __GFP_DIRECT_RECLAIM memory allocation attempt. Can you fix this dependency?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
