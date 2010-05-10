Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8F1B46B0276
	for <linux-mm@kvack.org>; Sun,  9 May 2010 20:46:46 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4A0kiw2012074
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 10 May 2010 09:46:44 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id DE50D45DE51
	for <linux-mm@kvack.org>; Mon, 10 May 2010 09:46:43 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id BD6E145DE4E
	for <linux-mm@kvack.org>; Mon, 10 May 2010 09:46:43 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F2361DB805B
	for <linux-mm@kvack.org>; Mon, 10 May 2010 09:46:43 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C7341DB8040
	for <linux-mm@kvack.org>; Mon, 10 May 2010 09:46:43 +0900 (JST)
Date: Mon, 10 May 2010 09:42:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] mm,migration: Fix race between shift_arg_pages and
 rmap_walk by guaranteeing rmap_walk finds PTEs created within the temporary
 stack
Message-Id: <20100510094238.5781d6fc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LFD.2.00.1005091245000.3711@i5.linux-foundation.org>
References: <1273188053-26029-1-git-send-email-mel@csn.ul.ie>
	<1273188053-26029-3-git-send-email-mel@csn.ul.ie>
	<alpine.LFD.2.00.1005061836110.901@i5.linux-foundation.org>
	<20100507105712.18fc90c4.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LFD.2.00.1005061905230.901@i5.linux-foundation.org>
	<20100509192145.GI4859@csn.ul.ie>
	<alpine.LFD.2.00.1005091245000.3711@i5.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Sun, 9 May 2010 12:56:49 -0700 (PDT)
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> 
> 
> On Sun, 9 May 2010, Mel Gorman wrote:
> > 
> > It turns out not to be easy to the preallocating of PUDs, PMDs and PTEs
> > move_page_tables() needs.  To avoid overallocating, it has to follow the same
> > logic as move_page_tables duplicating some code in the process. The ugliest
> > aspect of all is passing those pre-allocated pages back into move_page_tables
> > where they need to be passed down to such functions as __pte_alloc. It turns
> > extremely messy.
> 
> Umm. What?
> 
> That's crazy talk. I'm not talking about preallocating stuff in order to 
> pass it in to move_page_tables(). I'm talking about just _creating_ the 
> dang page tables early - preallocating them IN THE PROCESS VM SPACE.
> 
> IOW, a patch like this (this is a pseudo-patch, totally untested, won't 
> compile, yadda yadda - you need to actually make the people who call 
> "move_page_tables()" call that prepare function first etc etc)
> 
> Yeah, if we care about holes in the page tables, we can certainly copy 
> more of the move_page_tables() logic, but it certainly doesn't matter for 
> execve(). This just makes sure that the destination page tables exist 
> first.
> 
IMHO, I think move_page_tables() itself should be implemented as your patch.

But, move_page_tables()'s failure is not a big problem. At failure,
exec will abort and no page fault will occur later. What we have to do in
this migration-patch-series is avoding inconsistent update of sets of
[page, vma->vm_start, vma->pg_off, ptes] or "dont' migrate pages in exec's
statk".

Considering cost, as Mel shows, "don't migrate pages in exec's stack" seems
reasonable. But, I still doubt this check.

+static bool is_vma_temporary_stack(struct vm_area_struct *vma)
+{
+	int maybe_stack = vma->vm_flags & (VM_GROWSDOWN | VM_GROWSUP);
+
+	if (!maybe_stack)
+		return false;
+
+	/* If only the stack is mapped, assume exec is in progress */
+	if (vma->vm_mm->map_count == 1) -------------------(*)
+		return true; 
+
+	return false;
+}
+


Mel, can (*) be safe even on a.out format (format other than ELFs) ?

Thanks,
-Kame







> 		Linus
> 
> ---
>  mm/mremap.c |   22 +++++++++++++++++++++-
>  1 files changed, 21 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/mremap.c b/mm/mremap.c
> index cde56ee..c14505c 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -128,6 +128,26 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
>  
>  #define LATENCY_LIMIT	(64 * PAGE_SIZE)
>  
> +/*
> + * Preallocate the page tables, so that we can do the actual move
> + * without any allocations, and thus no error handling etc.
> + */
> +int prepare_move_page_tables(struct vm_area_struct *vma,
> +	unsigned long old_addr, struct vm_area_struct *new_vma,
> +	unsigned long new_addr, unsigned long len)
> +{
> +	unsigned long end_addr = new_addr + len;
> +
> +	while (new_addr < end_addr) {
> +		pmd_t *new_pmd;
> +		new_pmd = alloc_new_pmd(vma->vm_mm, new_addr);
> +		if (!new_pmd)
> +			return -ENOMEM;
> +		new_addr = (new_addr + PMD_SIZE) & PMD_MASK;
> +	}
> +	return 0;
> +}
> +
>  unsigned long move_page_tables(struct vm_area_struct *vma,
>  		unsigned long old_addr, struct vm_area_struct *new_vma,
>  		unsigned long new_addr, unsigned long len)
> @@ -147,7 +167,7 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
>  		old_pmd = get_old_pmd(vma->vm_mm, old_addr);
>  		if (!old_pmd)
>  			continue;
> -		new_pmd = alloc_new_pmd(vma->vm_mm, new_addr);
> +		new_pmd = get_old_pmd(vma->vm_mm, new_addr);
>  		if (!new_pmd)
>  			break;
>  		next = (new_addr + PMD_SIZE) & PMD_MASK;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
