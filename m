Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 682266B0031
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 11:55:07 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id md12so5656844pbc.15
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 08:55:07 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id da3si21816049pbc.123.2014.06.03.08.55.05
        for <linux-mm@kvack.org>;
        Tue, 03 Jun 2014 08:55:06 -0700 (PDT)
Message-ID: <538DEFD8.4050506@intel.com>
Date: Tue, 03 Jun 2014 08:55:04 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] mincore: apply page table walker on do_mincore()
 (Re: [PATCH 00/10] mm: pagewalk: huge page cleanups and VMA passing)
References: <20140602213644.925A26D0@viggo.jf.intel.com> <1401745925-l651h3s9@n-horiguchi@ah.jp.nec.com> <538CF25E.8070905@sr71.net> <1401776292-dn0fof8e@n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1401776292-dn0fof8e@n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 06/02/2014 11:18 PM, Naoya Horiguchi wrote:
> And for patch 8, 9, and 10, I don't think it's good idea to add a new callback
> which can handle both pmd and pte (because they are essentially differnt thing).
> But the underneath idea of doing pmd_trans_huge_lock() in the common code in
> walk_single_entry_locked() looks nice to me. So it would be great if we can do
> the same thing in walk_pmd_range() (of linux-mm) to reduce code in callbacks.

You think they are different, I think they're the same. :)

What the walkers *really* care about is getting a leaf node in the page
tables.  They generally don't *care* whether it is a pmd or pte, they
just want to know what its value is and how large it is.

I'd argue that they don't really ever need to actually know at which
level they are in the page tables, just if they are at the bottom or
not.  Note that *NOBODY* sets a pud or pgd entry.  That's because the
walkers are 100% concerned about leaf nodes (pte's) at this point.

Take a look at my version of gather_stats_locked():

>  static int gather_stats_locked(pte_t *pte, unsigned long addr,
>                 unsigned long size, struct mm_walk *walk)
>  {
>         struct numa_maps *md = walk->private;
>         struct page *page = can_gather_numa_stats(*pte, walk->vma, addr);
>  
>         if (page)
>                 gather_stats(page, md, pte_dirty(*pte), size/PAGE_SIZE);
>  
>         return 0;
>  }

The mmotm version looks _very_ similar to that, *BUT* the mmotm version
needs to have an entire *EXTRA* 22-line gather_pmd_stats() dealing with
THP locking, while mine doesn't.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
