Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 78B406B02A4
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 17:08:37 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o6DL8YYq016312
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 14:08:34 -0700
Received: from pvh11 (pvh11.prod.google.com [10.241.210.203])
	by wpaz29.hot.corp.google.com with ESMTP id o6DL8WJH009455
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 14:08:32 -0700
Received: by pvh11 with SMTP id 11so2990481pvh.38
        for <linux-mm@kvack.org>; Tue, 13 Jul 2010 14:08:32 -0700 (PDT)
Date: Tue, 13 Jul 2010 14:08:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: FYI: mmap_sem OOM patch
In-Reply-To: <20100713091333.EA3E.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1007131349250.1821@chino.kir.corp.google.com>
References: <20100708200324.CD4B.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1007121446500.8468@chino.kir.corp.google.com> <20100713091333.EA3E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Divyesh Shah <dpshah@google.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, 13 Jul 2010, KOSAKI Motohiro wrote:

> > > I disagree. __GFP_NOFAIL mean this allocation failure can makes really
> > > dangerous result. Instead, OOM-Killer should try to kill next process.
> > > I think.
> > > 
> > 
> > That's not what happens, __alloc_pages_high_priority() will loop forever 
> > for __GFP_NOFAIL, the oom killer is never recalled.
> 
> Yup, please reread the discusstion.
> 

There's nothing in the discussion that addresses the fact that 
__alloc_pages_high_priority() loops infinitely for __GFP_NOFAIL without 
again calling the oom killer.  You may be proposing a change to that when 
you said "OOM-Killer should try to kill next process. I think," but I 
can't speculate on that.  If you are, please propose a patch.

The success of whether we can allocate without watermarks is dependent on 
where we set them and what types of exclusions we allow.  This isn't local 
only to the page allocator but rather to the entire kernel since 
GFP_ATOMIC allocations, for example, can deplete the min watermark by 
~60%.  The remaining memory is what we allow access to for 
ALLOC_NO_WATERMARKS: those allocations in the direct reclaim patch and 
those that have been oom killed.

Thus, it's important that oom killed tasks do not completely deplete 
memory reserves, otherwise __GFP_NOFAIL allocations will loop forever 
without killing additional tasks, as you say.  That's sane since oom 
killing additional tasks wouldn't allow them access to any additional 
memory, anyway, so the allocation would still fail (we only call the oom 
killer for those allocations that are retried) and the victim could not 
exit.

With that said, I'm not exactly sure what change you're proposing when you 
say the oom killer should try to kill another process because it won't 
lead to any future memory freeing unless the victim can exit without 
allocating memory.  If that's not possible, you've proliferated a ton of 
innocent kills that were triggered because of one __GFP_NOFAIL attempt.

I agree with Peter that it would be ideal to remove __GFP_NOFAIL, but I 
think we require changes in the retry logic first before that is possible.  
Right now, we insist on retrying all blockable !__GFP_NORETRY allocations 
under PAGE_ALLOC_COSTLY_ORDER indefinitely.  That, in a sense, is already 
__GFP_NOFAIL behavior that is implicit: that's why we typically see 
__GFP_NOFAIL with GFP_NOFS instead.  With GFP_NOFS, we never kill the oom 
killer in the first place, so memory allocation is only more successful on 
a subsequent attempt by either direct reclaim or memory compaction.

There's nothing preventing users from doing

	do {
		page = alloc_page(GFP_KERNEL);
	} while (!page);

if the retry logic were reworked to start failing allocations or we 
removed __GFP_NOFAIL.  Thus, I think __GFP_NOFAIL should be substituted 
with a different gfp flag that acts similar but failable: use compaction, 
reclaim, and the oom killer where possible and in that order if there is 
no success and then retry to a high watermark one final time.  If the 
allocation is still unsuccessful, return NULL.  This allows users to do 
what getblk() does, for instance, by implementing their own memory freeing 
functions.  It also allows them to use all of the page allocator's powers 
(compaction, reclaim, oom killer) without infinitely looping by either 
using an order under PAGE_ALLOC_COSTLY_ORDER or insisting on __GFP_NOFAIL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
