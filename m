Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id A7C306B0292
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 19:01:30 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id m62so11690313qki.9
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 16:01:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k184si6339244qkf.266.2017.08.30.16.01.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 16:01:29 -0700 (PDT)
Date: Thu, 31 Aug 2017 01:01:25 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 02/13] mm/rmap: update to new mmu_notifier semantic
Message-ID: <20170830230125.GL13559@redhat.com>
References: <20170829235447.10050-1-jglisse@redhat.com>
 <20170829235447.10050-3-jglisse@redhat.com>
 <20170830165250.GD13559@redhat.com>
 <CA+55aFxiyrqasfojwS5rG4aKJfaZpw1H=QAPH+9PRq=HT0W8AQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CA+55aFxiyrqasfojwS5rG4aKJfaZpw1H=QAPH+9PRq=HT0W8AQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Wanpeng Li <kernellwp@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>, Takashi Iwai <tiwai@suse.de>, Nadav Amit <nadav.amit@gmail.com>, Mike Galbraith <efault@gmx.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, axie <axie@amd.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Aug 30, 2017 at 02:53:38PM -0700, Linus Torvalds wrote:
> On Wed, Aug 30, 2017 at 9:52 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> >
> > I pointed out in earlier email ->invalidate_range can only be
> > implemented (as mutually exclusive alternative to
> > ->invalidate_range_start/end) by secondary MMUs that shares the very
> > same pagetables with the core linux VM of the primary MMU, and those
> > invalidate_range are already called by
> > __mmu_notifier_invalidate_range_end.
> 
> I have to admit that I didn't notice that fact - that we are already
> in the situation that
> invalidate_range is called by by the rand_end() nofifier.
> 
> I agree that that should simplify all the code, and means that we
> don't have to worry about the few cases that already implemented only
> the "invalidate_page()" and "invalidate_range()" cases.
> 
> So I think that simplifies Jerome's patch further - once you have put
> the range_start/end() cases around the inner loop, you can just drop
> the invalidate_page() things entirely.
> 
> > So this conversion from invalidate_page to invalidate_range looks
> > superflous and the final mmu_notifier_invalidate_range_end should be
> > enough.
> 
> Yes. I missed the fact that we already called range() from range_end().
> 
> That said, the double call shouldn't hurt correctness, and it's
> "closer" to old behavior for those people who only did the range/page
> ones, so I wonder if we can keep Jerome's patch in its current state
> for 4.13.

Yes, the double call doesn't hurt correctness. Keeping it in current
state is safer if something, so I've no objection to it other than I'd
like to optimize it further if possible, but it can be done later.

We're already running the double call in various fast paths too in
fact, and rmap walk isn't the fastest path that would be doing such
double call, so it's not a major concern.

Also not a bug, but one further (but more obviously safe) enhancement
I would like is to restrict those rmap invalidation ranges to
PAGE_SIZE << compound_order(page) instead of PMD_SIZE/PMD_MASK.

+	/*
+	 * We have to assume the worse case ie pmd for invalidation. Note that
+	 * the page can not be free in this function as call of try_to_unmap()
+	 * must hold a reference on the page.
+	 */
+	end = min(vma->vm_end, (start & PMD_MASK) + PMD_SIZE);
+	mmu_notifier_invalidate_range_start(vma->vm_mm, start, end);

We don't need to invalidate 2MB of secondary MMU mappings surrounding
a 4KB page, just to swapout a 4k page. split_huge_page can't run while
holding the rmap locks, so compound_order(page) is safe to use there.

It can also be optimized incrementally later.

> Because I still want to release 4.13 this weekend, despite this
> upheaval. Otherwise I'll have timing problems during the next merge
> window.
> 
> Andrea, do you otherwise agree with the whole series as is?

I only wish we had more time to test Jerome's patchset, but I sure
agree in principle and I don't see regressions in it.

The callouts to ->invalidate_page seems to have diminished over time
(for the various reasons we know) so if we don't use it for the fast
paths, using it only in rmap walk slow paths probably wasn't providing
much performance benefit.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
