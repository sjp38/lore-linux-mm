Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4DAD16B0023
	for <linux-mm@kvack.org>; Mon,  9 May 2011 03:38:54 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E013E3EE081
	for <linux-mm@kvack.org>; Mon,  9 May 2011 16:38:50 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C4EEF45DE55
	for <linux-mm@kvack.org>; Mon,  9 May 2011 16:38:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A6AA845DE61
	for <linux-mm@kvack.org>; Mon,  9 May 2011 16:38:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 91B131DB803C
	for <linux-mm@kvack.org>; Mon,  9 May 2011 16:38:50 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 55E501DB8038
	for <linux-mm@kvack.org>; Mon,  9 May 2011 16:38:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/8] mm: use walk_page_range() instead of custom page table walking code
In-Reply-To: <1303947349-3620-3-git-send-email-wilsons@start.ca>
References: <1303947349-3620-1-git-send-email-wilsons@start.ca> <1303947349-3620-3-git-send-email-wilsons@start.ca>
Message-Id: <20110509164034.164C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  9 May 2011 16:38:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Wilson <wilsons@start.ca>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

sorry for the long delay.

> In the specific case of show_numa_map(), the custom page table walking
> logic implemented in mempolicy.c does not provide any special service
> beyond that provided by walk_page_range().
> 
> Also, converting show_numa_map() to use the generic routine decouples
> the function from mempolicy.c, allowing it to be moved out of the mm
> subsystem and into fs/proc.
> 
> Signed-off-by: Stephen Wilson <wilsons@start.ca>
> ---
>  mm/mempolicy.c |   53 ++++++++++++++++++++++++++++++++++++++++++++++-------
>  1 files changed, 46 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 5bfb03e..dfe27e3 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -2568,6 +2568,22 @@ static void gather_stats(struct page *page, void *private, int pte_dirty)
>  	md->node[page_to_nid(page)]++;
>  }
>  
> +static int gather_pte_stats(pte_t *pte, unsigned long addr,
> +		unsigned long pte_size, struct mm_walk *walk)
> +{
> +	struct page *page;
> +
> +	if (pte_none(*pte))
> +		return 0;
> +
> +	page = pte_page(*pte);
> +	if (!page)
> +		return 0;

original check_pte_range() has following logic.

        orig_pte = pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
        do {
                struct page *page;
                int nid;

                if (!pte_present(*pte))
                        continue;
                page = vm_normal_page(vma, addr, *pte);
                if (!page)
                        continue;
                /*
                 * vm_normal_page() filters out zero pages, but there might
                 * still be PageReserved pages to skip, perhaps in a VDSO.
                 * And we cannot move PageKsm pages sensibly or safely yet.
                 */
                if (PageReserved(page) || PageKsm(page))
                        continue;
                gather_stats(page, private, pte_dirty(*pte));

Why did you drop a lot of check? Is it safe?

Other parts looks good to me.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
