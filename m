Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 058CE6B0272
	for <linux-mm@kvack.org>; Fri, 21 Mar 2014 01:17:24 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id md12so1947285pbc.9
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 22:17:24 -0700 (PDT)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id iu9si2907717pac.207.2014.03.20.22.17.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Mar 2014 22:17:23 -0700 (PDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so1869280pdi.5
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 22:17:22 -0700 (PDT)
Date: Thu, 20 Mar 2014 22:16:21 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] madvise: fix locking in force_swapin_readahead() (Re:
 [PATCH 08/11] madvise: redefine callback functions for page table walker)
In-Reply-To: <532ba74e.48c70e0a.7b9e.119cSMTPIN_ADDED_BROKEN@mx.google.com>
Message-ID: <alpine.LSU.2.11.1403202159190.1488@eggly.anvils>
References: <1392068676-30627-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1392068676-30627-9-git-send-email-n-horiguchi@ah.jp.nec.com> <532B9A18.8020606@oracle.com> <532ba74e.48c70e0a.7b9e.119cSMTPIN_ADDED_BROKEN@mx.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Shaohua Li <shli@kernel.org>, sasha.levin@oracle.com, linux-mm@kvack.org, akpm@linux-foundation.org, mpm@selenic.com, cpw@sgi.com, kosaki.motohiro@jp.fujitsu.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, aneesh.kumar@linux.vnet.ibm.com, xemul@parallels.com, riel@redhat.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

On Thu, 20 Mar 2014, Naoya Horiguchi wrote:
> On Thu, Mar 20, 2014 at 09:47:04PM -0400, Sasha Levin wrote:
> > On 02/10/2014 04:44 PM, Naoya Horiguchi wrote:
> > >swapin_walk_pmd_entry() is defined as pmd_entry(), but it has no code
> > >about pmd handling (except pmd_none_or_trans_huge_or_clear_bad, but the
> > >same check are now done in core page table walk code).
> > >So let's move this function on pte_entry() as swapin_walk_pte_entry().
> > >
> > >Signed-off-by: Naoya Horiguchi<n-horiguchi@ah.jp.nec.com>
> > 
> > This patch seems to generate:
> 
> Sasha, thank you for reporting.
> I forgot to unlock ptlock before entering read_swap_cache_async() which
> holds page lock in it, as a result lock ordering rule (written in mm/rmap.c)
> was violated (we should take in the order of mmap_sem -> page lock -> ptlock.)
> The following patch should fix this. Could you test with it?
> 
> ---
> From c0d56af5874dc40467c9b3a0f9e53b39b3c4f1c5 Mon Sep 17 00:00:00 2001
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Date: Thu, 20 Mar 2014 22:30:51 -0400
> Subject: [PATCH] madvise: fix locking in force_swapin_readahead()
> 
> We take mmap_sem and ptlock in walking over ptes with swapin_walk_pte_entry(),
> but inside it we call read_swap_cache_async() which holds page lock.
> So we should unlock ptlock to call read_swap_cache_async() to meet lock order
> rule (mmap_sem -> page lock -> ptlock).
> 
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

NAK.  You are now unlocking and relocking the spinlock, good; but on
arm frv or i386 CONFIG_HIGHPTE you are leaving the page table atomically
kmapped across read_swap_cache_async(), which (never mind lock ordering)
is quite likely to block waiting to allocate memory.

I do not see
madvise-redefine-callback-functions-for-page-table-walker.patch
as an improvement.  I can see what's going on in Shaohua's original
code, whereas this style makes bugs more likely.  Please drop it.

Hugh

> ---
>  mm/madvise.c | 11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 5e957b984c14..ed9c31e3b5ff 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -141,24 +141,35 @@ static int swapin_walk_pte_entry(pte_t *pte, unsigned long start,
>  	swp_entry_t entry;
>  	struct page *page;
>  	struct vm_area_struct *vma = walk->vma;
> +	spinlock_t *ptl = (spinlock_t *)walk->private;
>  
>  	if (pte_present(*pte) || pte_none(*pte) || pte_file(*pte))
>  		return 0;
>  	entry = pte_to_swp_entry(*pte);
>  	if (unlikely(non_swap_entry(entry)))
>  		return 0;
> +	spin_unlock(ptl);
>  	page = read_swap_cache_async(entry, GFP_HIGHUSER_MOVABLE,
>  				     vma, start);
> +	spin_lock(ptl);
>  	if (page)
>  		page_cache_release(page);
>  	return 0;
>  }
>  
> +static int swapin_walk_pmd_entry(pmd_t *pmd, unsigned long start,
> +	unsigned long end, struct mm_walk *walk)
> +{
> +	walk->private = pte_lockptr(walk->mm, pmd);
> +	return 0;
> +}
> +
>  static void force_swapin_readahead(struct vm_area_struct *vma,
>  		unsigned long start, unsigned long end)
>  {
>  	struct mm_walk walk = {
>  		.mm = vma->vm_mm,
> +		.pmd_entry = swapin_walk_pmd_entry,
>  		.pte_entry = swapin_walk_pte_entry,
>  	};
>  
> -- 
> 1.8.5.3
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
