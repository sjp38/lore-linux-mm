Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3A5576B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 17:19:52 -0500 (EST)
Received: by mail-we0-f172.google.com with SMTP id q58so560712wes.31
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 14:19:51 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id j10si7736810wjw.161.2014.01.22.14.19.50
        for <linux-mm@kvack.org>;
        Wed, 22 Jan 2014 14:19:51 -0800 (PST)
Date: Wed, 22 Jan 2014 23:19:41 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm/mmu_notifier: restore set_pte_at_notify semantics
Message-ID: <20140122221941.GJ14193@redhat.com>
References: <1389778834-21200-1-git-send-email-mike.rapoport@ravellosystems.com>
 <20140122135459.120a50ecec95d0e3cf017586@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140122135459.120a50ecec95d0e3cf017586@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Rapoport <mike.rapoport@ravellosystems.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Izik Eidus <izik.eidus@ravellosystems.com>, Haggai Eran <haggaie@mellanox.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Wed, Jan 22, 2014 at 01:54:59PM -0800, Andrew Morton wrote:
> The changelog fails to describe the end-user visible effects of the
> bug, so I (and others) will be unable to decide which kernel versions
> need patching
> 
> Given that the bug has been around for 1.5 years I assume the priority
> is low.

The priority is low, it's about a performance optimization
only.

change_pte avoids a vmexit when the guest first access the page after
a KSM cow break, or after a KSM merge.

But the change_pte method become worthless, it was still called but it
did nothing with the current common code in memory.c and ksm.c.

In the old days KVM would call gup_fast(write=1). These days write=1
is not forced always on and a secondary MMU read fault calls gup_fast
with write=0. So in the old days without a fully functional change_pte
invocation, KSM merged pages could never be read from the guest
without first breaking them with a COW. So it would have been a
showstopper if change_pte wouldn't work.

These days the KVM secondary MMU page fault handler become more
advanced and it's just a vmexit optimization.

> Generally, the patch is really ugly :( We have a nice consistent and

It would get even uglier once we'd fix the problem Haggai pointed out
in another email on this thread, by keeping the pte wrprotected until
we call the mmu_notifier invalidate and in short doing 1 more TLB
flush to convert it to a writable pte, if the change_pte method wasn't
implemented for some registered mmu notifier for the mm.

That problem isn't the end of the world and is fixable but the
do_wp_page code gets even more hairy after fixing it with this
approach.

> symmetrical pattern of calling
> ->invalidate_range_start()/->invalidate_range_end() and this patch
> comes along and tears great holes in it by removing those calls from a
> subset of places and replacing them with open-coded calls to
> single-page ->invalidate_page().  Isn't there some (much) nicer way of
> doing all this?

The fundamental problem is that change_pte acts only on established on
secondary MMU mappings. So if we teardown the secondary mmu mappings
with invalidate_range_start, we can as well skip calling change_pte in
set_pte_at_notify, and just use set_pte_at instead.

Something must be done about it because current code just doesn't make
sense to keep as is.

Possible choices:

1) we drop change_pte completely (not fully evaluated the impact vs
   current production code where change_pte was in full effect and
   skipping some vmexit with KSM activity). It won't be slower than
   current upstream, it may be slower than current production code
   with KSM in usage. We need to benchmark it to see if it's
   measurable...

2) we fix it with this patch, plus adding a further step to keep the
   pte wrprotected until we flush the secondary mmu mapping.

3) we change the semantics of ->change_pte not to just change, but to
   establish not-existent secondary mmu mappings. So far the only way
   to establish secondary mmu mappings would have been outside of the
   mmu notifier, through regular secondary MMU page faults invoking
   gup_fast or one of the gup variants. That may be tricky as
   change_pte must be non blocking so it cannot reliably allocate
   memory.

Comments welcome,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
