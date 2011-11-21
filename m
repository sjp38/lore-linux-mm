Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 276B26B002D
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 17:27:23 -0500 (EST)
Date: Mon, 21 Nov 2011 14:27:20 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Fix virtual address handling in hugetlb fault
Message-Id: <20111121142720.a5b62c9c.akpm@linux-foundation.org>
In-Reply-To: <20111121194832.a0026d3e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20111121194832.a0026d3e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, n-horiguchi@ah.jp.nec.com

On Mon, 21 Nov 2011 19:48:32 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> >From 7c29389be2890c6b6934a80b4841d07a7014fe26 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Mon, 21 Nov 2011 19:45:27 +0900
> Subject: [PATCH] Fix virtual address handling in hugetlb fault
> 
> handle_mm_fault() passes 'faulted' address to hugetlb_fault().
> Then, the address is not aligned to hugepage boundary.
> 
> Most of functions for hugetlb pages are aware of that and
> calculate an alignment by itself. Some functions as copy_user_huge_page(),
> and clear_huge_page() doesn't handle alignment by themselves.
> 
> This patch make hugeltb_fault() to calculate the alignment and pass
> aligned addresss (top address of a faulted hugepage) to functions.
> 

Does this actually fix any known user-visible misbehaviour?

It sounds like the code is masking addresses in a lot of different
places.  It would be better to do it once, at the top level.  Perhaps
this patch makes some of the existing masking obsolete?

> index bb28a5f..af37337 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2629,6 +2629,8 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	static DEFINE_MUTEX(hugetlb_instantiation_mutex);
>  	struct hstate *h = hstate_vma(vma);
>  
> +	address = address & huge_page_mask(h);

--- a/mm/hugetlb.c~mm-hugetlbc-fix-virtual-address-handling-in-hugetlb-fault-fix
+++ a/mm/hugetlb.c
@@ -2639,7 +2639,7 @@ int hugetlb_fault(struct mm_struct *mm, 
 	static DEFINE_MUTEX(hugetlb_instantiation_mutex);
 	struct hstate *h = hstate_vma(vma);
 
-	address = address & huge_page_mask(h);
+	address &= huge_page_mask(h);
 
 	ptep = huge_pte_offset(mm, address);
 	if (ptep) {

is a bit more readable, IMO.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
