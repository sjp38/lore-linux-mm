Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id BDB606B02C3
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 14:33:55 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id y68so1319406qka.2
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 11:33:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j64si8237777qkc.431.2017.08.31.11.26.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Aug 2017 11:26:00 -0700 (PDT)
Date: Thu, 31 Aug 2017 14:25:55 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 02/13] mm/rmap: update to new mmu_notifier semantic
Message-ID: <20170831182555.GF9227@redhat.com>
References: <20170829235447.10050-1-jglisse@redhat.com>
 <20170829235447.10050-3-jglisse@redhat.com>
 <20170830165250.GD13559@redhat.com>
 <CA+55aFxiyrqasfojwS5rG4aKJfaZpw1H=QAPH+9PRq=HT0W8AQ@mail.gmail.com>
 <20170830230125.GL13559@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170830230125.GL13559@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Wanpeng Li <kernellwp@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>, Takashi Iwai <tiwai@suse.de>, Nadav Amit <nadav.amit@gmail.com>, Mike Galbraith <efault@gmx.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, axie <axie@amd.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Aug 31, 2017 at 01:01:25AM +0200, Andrea Arcangeli wrote:
> On Wed, Aug 30, 2017 at 02:53:38PM -0700, Linus Torvalds wrote:
> > On Wed, Aug 30, 2017 at 9:52 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> > >
> > > I pointed out in earlier email ->invalidate_range can only be
> > > implemented (as mutually exclusive alternative to
> > > ->invalidate_range_start/end) by secondary MMUs that shares the very
> > > same pagetables with the core linux VM of the primary MMU, and those
> > > invalidate_range are already called by
> > > __mmu_notifier_invalidate_range_end.
> > 
> > I have to admit that I didn't notice that fact - that we are already
> > in the situation that
> > invalidate_range is called by by the rand_end() nofifier.
> > 
> > I agree that that should simplify all the code, and means that we
> > don't have to worry about the few cases that already implemented only
> > the "invalidate_page()" and "invalidate_range()" cases.
> > 
> > So I think that simplifies Jerome's patch further - once you have put
> > the range_start/end() cases around the inner loop, you can just drop
> > the invalidate_page() things entirely.
> > 
> > > So this conversion from invalidate_page to invalidate_range looks
> > > superflous and the final mmu_notifier_invalidate_range_end should be
> > > enough.
> > 
> > Yes. I missed the fact that we already called range() from range_end().
> > 
> > That said, the double call shouldn't hurt correctness, and it's
> > "closer" to old behavior for those people who only did the range/page
> > ones, so I wonder if we can keep Jerome's patch in its current state
> > for 4.13.
> 
> Yes, the double call doesn't hurt correctness. Keeping it in current
> state is safer if something, so I've no objection to it other than I'd
> like to optimize it further if possible, but it can be done later.
> 
> We're already running the double call in various fast paths too in
> fact, and rmap walk isn't the fastest path that would be doing such
> double call, so it's not a major concern.
> 
> Also not a bug, but one further (but more obviously safe) enhancement
> I would like is to restrict those rmap invalidation ranges to
> PAGE_SIZE << compound_order(page) instead of PMD_SIZE/PMD_MASK.
> 
> +	/*
> +	 * We have to assume the worse case ie pmd for invalidation. Note that
> +	 * the page can not be free in this function as call of try_to_unmap()
> +	 * must hold a reference on the page.
> +	 */
> +	end = min(vma->vm_end, (start & PMD_MASK) + PMD_SIZE);
> +	mmu_notifier_invalidate_range_start(vma->vm_mm, start, end);
> 
> We don't need to invalidate 2MB of secondary MMU mappings surrounding
> a 4KB page, just to swapout a 4k page. split_huge_page can't run while
> holding the rmap locks, so compound_order(page) is safe to use there.
> 
> It can also be optimized incrementally later.

This optimization is safe i believe. Linus i can respin with that and
with further kvm dead code removal.

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
