Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 832E26B0009
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 06:13:36 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id p20so14300132pfh.17
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 03:13:36 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id k195si10729313pga.68.2018.01.31.03.13.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 Jan 2018 03:13:34 -0800 (PST)
Subject: Re: [PATCH] virtio_balloon: use non-blocking allocation
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1514904621-39186-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20180131015912-mutt-send-email-mst@kernel.org>
In-Reply-To: <20180131015912-mutt-send-email-mst@kernel.org>
Message-Id: <201801312013.FGI90108.OQFMtFLHFOOJSV@I-love.SAKURA.ne.jp>
Date: Wed, 31 Jan 2018 20:13:26 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mst@redhat.com
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, mhocko@suse.com, wei.w.wang@intel.com

Michael S. Tsirkin wrote:
> On Tue, Jan 02, 2018 at 11:50:21PM +0900, Tetsuo Handa wrote:
> > Commit c7cdff0e864713a0 ("virtio_balloon: fix deadlock on OOM") tried to
> > avoid OOM lockup by moving memory allocations to outside of balloon_lock.
> > 
> > Now, Wei is trying to allocate far more pages outside of balloon_lock and
> > some more memory inside of balloon_lock in order to perform efficient
> > communication between host and guest using scatter-gather API.
> > 
> > Since pages allocated outside of balloon_lock are not visible to the OOM
> > notifier path until fill_balloon() holds balloon_lock (and enqueues the
> > pending pages), allocating more pages than now may lead to unacceptably
> > premature OOM killer invocation.
> > 
> > It would be possible to make the pending pages visible to the OOM notifier
> > path. But there is no need to try to allocate memory so hard from the
> > beginning. As of commit 18468d93e53b037e ("mm: introduce a common
> > interface for balloon pages mobility"), it made sense to try allocation
> > as hard as possible. But after commit 5a10b7dbf904bfe0 ("virtio_balloon:
> > free some memory from balloon on OOM"),
> 
> However, please not that this behavious is optional.
> Can you keep the current behaviour when deflate on OOM is disabled?

I can, for passing a flag to balloon_page_alloc() will do it.

But do we really prefer behavior up to comment 27 of
https://bugzilla.redhat.com/show_bug.cgi?id=1525356 ?

> 
> 
> > it no longer makes sense to try
> > allocation as hard as possible, for fill_balloon() will after all have to
> > release just allocated memory if some allocation request hits the OOM
> > notifier path. Therefore, this patch disables __GFP_DIRECT_RECLAIM when
> > allocating memory for inflating the balloon. Then, memory for inflating
> > the balloon can be allocated inside balloon_lock, and we can release just
> > allocated memory as needed.
> > 
> > Also, this patch adds __GFP_NOWARN, for possibility of hitting memory
> > allocation failure is increased by removing __GFP_DIRECT_RECLAIM, which
> > might spam the kernel log buffer. At the same time, this patch moves
> > "puff" messages to outside of balloon_lock, for it is not a good thing to
> > block the OOM notifier path for 1/5 of a second. (Moreover, it is better
> > to release the workqueue and allow processing other pending items. But
> > that change is out of this patch's scope.)
> > 
> > __GFP_NOMEMALLOC is currently not required because workqueue context
> > which calls balloon_page_alloc() won't cause __gfp_pfmemalloc_flags()
> > to return ALLOC_OOM. But since some process context might start calling
> > balloon_page_alloc() in future, this patch does not remove
> > __GFP_NOMEMALLOC.
> > 
> > (Only compile tested. Please do runtime tests before committing.)
> 
> You will have to find someone to test it.

I don't have machines with much memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
