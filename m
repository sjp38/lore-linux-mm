Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id EAF5A828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 00:45:55 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id 65so39451484pff.2
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 21:45:55 -0800 (PST)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id v24si2000282pfi.109.2016.01.10.21.45.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Jan 2016 21:45:55 -0800 (PST)
Received: by mail-pa0-x229.google.com with SMTP id yy13so223271163pab.3
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 21:45:55 -0800 (PST)
Date: Sun, 10 Jan 2016 21:45:45 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH next] powerpc/mm: fix _PAGE_PTE breaking swapoff
In-Reply-To: <87si24u32t.fsf@linux.vnet.ibm.com>
Message-ID: <alpine.LSU.2.11.1601102122280.1485@eggly.anvils>
References: <alpine.LSU.2.11.1601091643060.9808@eggly.anvils> <87si24u32t.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Mon, 11 Jan 2016, Aneesh Kumar K.V wrote:
> Hugh Dickins <hughd@google.com> writes:
> 
> > Swapoff after swapping hangs on the G5.  That's because the _PAGE_PTE
> > bit, added by set_pte_at(), is not expected by swapoff: so swap ptes
> > cannot be recognized.
> >
> > I'm not sure whether a swap pte should or should not have _PAGE_PTE set:
> > this patch assumes not, and fixes set_pte_at() to set _PAGE_PTE only on
> > present entries.
> 
> One of the reason we added _PAGE_PTE is to enable HUGETLB migration. So
> we want migratio ptes to have _PAGE_PTE set.

Okay, I won't pretend to understand the role of _PAGE_PTE in that;
but if it helps you to have _PAGE_PTE set in (swap and) migration entries,
that's very easily done with the alternative I suggested for pgtable.h:

-#define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val((pte)) })
-#define __swp_entry_to_pte(x)		__pte((x).val)
+#define __pte_to_swp_entry(pte)	((swp_entry_t) { pte_val(pte) & ~_PAGE_PTE })
+#define __swp_entry_to_pte(x)	__pte((x).val | _PAGE_PTE)

I did test that variant (with set_pte_at() restored to how you have it);
but not understanding _PAGE_PTE, I thought it odd to have in a swap entry.

> 
> >
> > But if that's wrong, a reasonable alternative would be to
> > #define __pte_to_swp_entry(pte)	((swp_entry_t) { pte_val(pte) & ~_PAGE_PTE })
> > #define __swp_entry_to_pte(x)	__pte((x).val | _PAGE_PTE)
> >
> 
> We do clear _PAGE_PTE bits, when converting swp_entry_t to type and
> offset. Can you share the stack trace for the hang, which will help me
> understand this more ? . 

The stack trace can be anywhere below try_to_unuse() in mm/swapfile.c,
since swapoff is circling around and around that function, reading from
each used swap block into a page, then trying to find where that page
belongs, looking at every non-file pte of every mm that ever swapped.

The code to look at is unuse_pte_range(), which at the top does
	pte_t swp_pte = swp_entry_to_pte(entry)
to get the form it hopes to find in the page table; then scans doing
		if (unlikely(maybe_same_pte(*pte, swp_pte))) {
on each pte slot.  Ignoring the MEM_SOFT_DIRTY complication (which
had its own independent bug) maybe_same_pte() just does pte_same().

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
