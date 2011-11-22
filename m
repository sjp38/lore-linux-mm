Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id B3D326B002D
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 19:33:53 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 88F203EE0B5
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 09:33:49 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A00C45DE56
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 09:33:49 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 49C7445DE59
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 09:33:49 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2434BE08003
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 09:33:49 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E474B1DB804C
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 09:33:48 +0900 (JST)
Date: Tue, 22 Nov 2011 09:32:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Fix virtual address handling in hugetlb fault
Message-Id: <20111122093238.9bdbee39.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111121142720.a5b62c9c.akpm@linux-foundation.org>
References: <20111121194832.a0026d3e.kamezawa.hiroyu@jp.fujitsu.com>
	<20111121142720.a5b62c9c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, n-horiguchi@ah.jp.nec.com

On Mon, 21 Nov 2011 14:27:20 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 21 Nov 2011 19:48:32 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > >From 7c29389be2890c6b6934a80b4841d07a7014fe26 Mon Sep 17 00:00:00 2001
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Date: Mon, 21 Nov 2011 19:45:27 +0900
> > Subject: [PATCH] Fix virtual address handling in hugetlb fault
> > 
> > handle_mm_fault() passes 'faulted' address to hugetlb_fault().
> > Then, the address is not aligned to hugepage boundary.
> > 
> > Most of functions for hugetlb pages are aware of that and
> > calculate an alignment by itself. Some functions as copy_user_huge_page(),
> > and clear_huge_page() doesn't handle alignment by themselves.
> > 
> > This patch make hugeltb_fault() to calculate the alignment and pass
> > aligned addresss (top address of a faulted hugepage) to functions.
> > 
> 
> Does this actually fix any known user-visible misbehaviour?
> 

I just found this at reading codes. And I know 'vaddr' is ignored
in most of per-arch implemantation of clear_user_highpage().
It seems, in some arch, vaddr is used for flushing cache. Now,
CONFIG_HUGETLBFS can be set on x86,powerpc,ia64,mips,sh,sparc,tile. (by grep)

it seems mips and sh uses vaddr in clear_user_(high)page.



> It sounds like the code is masking addresses in a lot of different
> places.  It would be better to do it once, at the top level.  Perhaps
> this patch makes some of the existing masking obsolete?
> 

I think so. 
I'd like to check it and post an additional fix if this patch goes.


> > index bb28a5f..af37337 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -2629,6 +2629,8 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> >  	static DEFINE_MUTEX(hugetlb_instantiation_mutex);
> >  	struct hstate *h = hstate_vma(vma);
> >  
> > +	address = address & huge_page_mask(h);
> 
> --- a/mm/hugetlb.c~mm-hugetlbc-fix-virtual-address-handling-in-hugetlb-fault-fix
> +++ a/mm/hugetlb.c
> @@ -2639,7 +2639,7 @@ int hugetlb_fault(struct mm_struct *mm, 
>  	static DEFINE_MUTEX(hugetlb_instantiation_mutex);
>  	struct hstate *h = hstate_vma(vma);
>  
> -	address = address & huge_page_mask(h);
> +	address &= huge_page_mask(h);
>  
>  	ptep = huge_pte_offset(mm, address);
>  	if (ptep) {
> 
> is a bit more readable, IMO.
> 
Sure.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
