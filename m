Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D8BA56B0279
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 06:33:56 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id g15so3032239wmc.8
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 03:33:56 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q3si4860707wrd.188.2017.06.08.03.33.55
        for <linux-mm@kvack.org>;
        Thu, 08 Jun 2017 03:33:55 -0700 (PDT)
Date: Thu, 8 Jun 2017 11:34:02 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 2/3] mm/page_ref: Ensure page_ref_unfreeze is ordered
 against prior accesses
Message-ID: <20170608103402.GF6071@arm.com>
References: <1496771916-28203-1-git-send-email-will.deacon@arm.com>
 <1496771916-28203-3-git-send-email-will.deacon@arm.com>
 <b6677057-54d6-4336-93a0-5d0770434aa7@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b6677057-54d6-4336-93a0-5d0770434aa7@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mark.rutland@arm.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, Punit.Agrawal@arm.com, mgorman@suse.de, steve.capper@arm.com

On Thu, Jun 08, 2017 at 11:38:21AM +0200, Vlastimil Babka wrote:
> On 06/06/2017 07:58 PM, Will Deacon wrote:
> > page_ref_freeze and page_ref_unfreeze are designed to be used as a pair,
> > wrapping a critical section where struct pages can be modified without
> > having to worry about consistency for a concurrent fast-GUP.
> > 
> > Whilst page_ref_freeze has full barrier semantics due to its use of
> > atomic_cmpxchg, page_ref_unfreeze is implemented using atomic_set, which
> > doesn't provide any barrier semantics and allows the operation to be
> > reordered with respect to page modifications in the critical section.
> > 
> > This patch ensures that page_ref_unfreeze is ordered after any critical
> > section updates, by invoking smp_mb__before_atomic() prior to the
> > atomic_set.
> > 
> > Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > Acked-by: Steve Capper <steve.capper@arm.com>
> > Signed-off-by: Will Deacon <will.deacon@arm.com>
> 
> Undecided if it's really needed. This is IMHO not the classical case
> from Documentation/core-api/atomic_ops.rst where we have to make
> modifications visible before we let others see them? Here the one who is
> freezing is doing it so others can't get their page pin and interfere
> with the freezer's work. But maybe there are some (documented or not)
> consistency guarantees to expect once you obtain the pin, that can be
> violated, or they might be added later, so it would be safer to add the
> barrier?

The problem comes if the unfreeze is reordered so that it happens before the
freezer has performed its work. For example, in
migrate_huge_page_move_mapping:


	if (!page_ref_freeze(page, expected_count)) {
		spin_unlock_irq(&mapping->tree_lock);
		return -EAGAIN;
	}

	newpage->index = page->index;
	newpage->mapping = page->mapping;

	get_page(newpage);

	radix_tree_replace_slot(&mapping->page_tree, pslot, newpage);

	page_ref_unfreeze(page, expected_count - 1);


then there's nothing stopping the CPU (and potentially the compiler) from
reordering the unfreeze call so that it effectively becomes:


	if (!page_ref_freeze(page, expected_count)) {
		spin_unlock_irq(&mapping->tree_lock);
		return -EAGAIN;
	}

	page_ref_unfreeze(page, expected_count - 1);

	newpage->index = page->index;
	newpage->mapping = page->mapping;

	get_page(newpage);

	radix_tree_replace_slot(&mapping->page_tree, pslot, newpage);


which then means that the freezer's work is carried out without the page
being frozen.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
