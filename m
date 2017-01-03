Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8FDEF6B0069
	for <linux-mm@kvack.org>; Mon,  2 Jan 2017 20:36:56 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id n184so958859726oig.1
        for <linux-mm@kvack.org>; Mon, 02 Jan 2017 17:36:56 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id h10si13996807oib.150.2017.01.02.17.36.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 02 Jan 2017 17:36:55 -0800 (PST)
Subject: Re: [PATCH 0/3 -v3] GFP_NOFAIL cleanups
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20161220134904.21023-1-mhocko@kernel.org>
	<20170102154858.GC18048@dhcp22.suse.cz>
In-Reply-To: <20170102154858.GC18048@dhcp22.suse.cz>
Message-Id: <201701031036.IBE51044.QFLFSOHtFOJVMO@I-love.SAKURA.ne.jp>
Date: Tue, 3 Jan 2017 10:36:31 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, rientjes@google.com, mgorman@suse.de, hillf.zj@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Tue 20-12-16 14:49:01, Michal Hocko wrote:
> > Hi,
> > This has been posted [1] initially to later be reduced to a single patch
> > [2].  Johannes then suggested [3] to split up the second patch and make
> > the access to memory reserves by __GF_NOFAIL requests which do not
> > invoke the oom killer a separate change. This is patch 3 now.
> > 
> > Tetsuo has noticed [4] that recent changes have changed GFP_NOFAIL
> > semantic for costly order requests. I believe that the primary reason
> > why this happened is that our GFP_NOFAIL checks are too scattered
> > and it is really easy to forget about adding one. That's why I am
> > proposing patch 1 which consolidates all the nofail handling at a single
> > place. This should help to make this code better maintainable.
> > 
> > Patch 2 on top is a further attempt to make GFP_NOFAIL semantic less
> > surprising. As things stand currently GFP_NOFAIL overrides the oom killer
> > prevention code which is both subtle and not really needed. The patch 2
> > has more details about issues this might cause. We have also seen
> > a report where __GFP_NOFAIL|GFP_NOFS requests cause the oom killer which
> > is premature.
> > 
> > Patch 3 is an attempt to reduce chances of GFP_NOFAIL requests being
> > preempted by other memory consumers by giving them access to memory
> > reserves.
> 
> a friendly ping on this
> 
> > [1] http://lkml.kernel.org/r/20161123064925.9716-1-mhocko@kernel.org
> > [2] http://lkml.kernel.org/r/20161214150706.27412-1-mhocko@kernel.org
> > [3] http://lkml.kernel.org/r/20161216173151.GA23182@cmpxchg.org
> > [4] http://lkml.kernel.org/r/1479387004-5998-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp

I'm OK with "[PATCH 1/3] mm: consolidate GFP_NOFAIL checks in the allocator
slowpath" given that we describe that we make __GFP_NOFAIL stronger than
__GFP_NORETRY with this patch in the changelog.

But I don't think "[PATCH 2/3] mm, oom: do not enfore OOM killer for __GFP_NOFAIL
automatically" is correct. Firstly, we need to confirm

  "The pre-mature OOM killer is a real issue as reported by Nils Holland"

in the changelog is still true because we haven't tested with "[PATCH] mm, memcg:
fix the active list aging for lowmem requests when memcg is enabled" applied and
without "[PATCH 2/3] mm, oom: do not enfore OOM killer for __GFP_NOFAIL
automatically" and "[PATCH 3/3] mm: help __GFP_NOFAIL allocations which do not
trigger OOM killer" applied.

Secondly, as you are using __GFP_NORETRY in "[PATCH] mm: introduce kv[mz]alloc
helpers" as a mean to enforce not to invoke the OOM killer

	/*
	 * Make sure that larger requests are not too disruptive - no OOM
	 * killer and no allocation failure warnings as we have a fallback
	 */
	if (size > PAGE_SIZE)
		kmalloc_flags |= __GFP_NORETRY | __GFP_NOWARN;

, we can use __GFP_NORETRY as a mean to enforce not to invoke the OOM killer
rather than applying "[PATCH 2/3] mm, oom: do not enfore OOM killer for
__GFP_NOFAIL automatically".

Additionally, although currently there seems to be no
kv[mz]alloc(GFP_KERNEL | __GFP_NOFAIL) users, kvmalloc_node() in
"[PATCH] mm: introduce kv[mz]alloc helpers" will be confused when a
kv[mz]alloc(GFP_KERNEL | __GFP_NOFAIL) user comes in in the future because
"[PATCH 1/3] mm: consolidate GFP_NOFAIL checks in the allocator slowpath" makes
__GFP_NOFAIL stronger than __GFP_NORETRY.

My concern with "[PATCH 3/3] mm: help __GFP_NOFAIL allocations which
do not trigger OOM killer" is

  "AFAIU, this is an allocation path which doesn't block a forward progress
   on a regular IO. It is merely a check whether there is a new medium in
   the CDROM (aka regular polling of the device). I really fail to see any
   reason why this one should get any access to memory reserves at all."

in http://lkml.kernel.org/r/20161218163727.GC8440@dhcp22.suse.cz .
Indeed that trace is a __GFP_DIRECT_RECLAIM and it might not be blocking
other workqueue items which a regular I/O depend on, I think there are
!__GFP_DIRECT_RECLAIM memory allocation requests for issuing SCSI commands
which could potentially start failing due to helping GFP_NOFS | __GFP_NOFAIL
allocations with memory reserves. If a SCSI disk I/O request fails due to
GFP_ATOMIC memory allocation failures because we allow a FS I/O request to
use memory reserves, it adds a new problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
