Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 018726B0036
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 13:14:21 -0500 (EST)
Received: by mail-ig0-f177.google.com with SMTP id k19so2387366igc.4
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 10:14:21 -0800 (PST)
Received: from relay.sgi.com (relay3.sgi.com. [192.48.152.1])
        by mx.google.com with ESMTP id mg9si15109600icc.128.2014.01.22.10.14.20
        for <linux-mm@kvack.org>;
        Wed, 22 Jan 2014 10:14:20 -0800 (PST)
Date: Wed, 22 Jan 2014 12:14:42 -0600
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: [BUG] mm: thp: hugepage_vma_check has a blind spot
Message-ID: <20140122181442.GP18196@sgi.com>
References: <1390345671-136133-1-git-send-email-athorlton@sgi.com>
 <alpine.DEB.2.02.1401211519530.15306@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1401211519530.15306@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org

On Tue, Jan 21, 2014 at 03:24:08PM -0800, David Rientjes wrote:
> On Tue, 21 Jan 2014, Alex Thorlton wrote:
> 
> > hugepage_vma_check is called during khugepaged_scan_mm_slot to ensure
> > that khugepaged doesn't try to allocate THPs in vmas where they are
> > disallowed, either due to THPs being disabled system-wide, or through
> > MADV_NOHUGEPAGE.
> > 
> > The logic that hugepage_vma_check uses doesn't seem to cover all cases,
> > in my opinion.  Looking at the original code:
> > 
> >        if ((!(vma->vm_flags & VM_HUGEPAGE) && !khugepaged_always()) ||
> > 	   (vma->vm_flags & VM_NOHUGEPAGE))
> > 
> > We can see that it's possible to have THP disabled system-wide, but still
> > receive THPs in this vma.  It seems that it's assumed that just because
> > khugepaged_always == false, TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG must be
> > set, which is not the case.  We could have VM_HUGEPAGE set, but have THP
> > set to "never" system-wide, in which case, the condition presented in the
> > if will evaluate to false, and (provided the other checks pass) we can
> > end up giving out a THP even though the behavior is set to "never."
> > 
> 
> You should be able to add a
> 
> 	BUG_ON(current != khugepaged_thread);
> 
> here since khugepaged is supposed to be the only caller to the function.
> 
> > While we do properly check these flags in khugepaged_has_work, it looks
> > like it's possible to sleep after we check khugepaged_hask_work, but
> > before hugepage_vma_check, during which time, hugepages could have been
> > disabled system-wide, in which case, we could hand out THPs when we
> > shouldn't be.
> > 
> 
> You're talking about when thp is set to "never" and before khugepaged has 
> stopped, correct?

Yes, that's correct.

> That doesn't seem like a bug to me or anything that needs to be fixed, the 
> sysfs knob could be switched even after hugepage_vma_check() is called and 
> before a hugepage is actually collapsed so you have the same race.
> 
> The only thing that's guaranteed is that, upon writing "never" to 
> /sys/kernel/mm/transparent_hugepage/enabled, no more thp memory will be 
> collapsed after khugepaged has stopped.

That makes sense, I wasn't aware that that's the expected behavior here.
I suppose this isn't something that needs to be changed, in that case.
I needed the logic broken out a bit more explicitly (madvise/never case
need to be handled separately) for a patch that I'm working on - that's
when this caught my attention.  Good to know that a change to the
system-wide switch shouldn't affect khugepaged if it's already running.
I would've screwed up that behavior with my patch :)

Thanks, David!

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
