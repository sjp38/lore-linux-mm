Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C750B6B01EE
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 22:53:49 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3S2rkhn025351
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 28 Apr 2010 11:53:46 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DF04445DE56
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 11:53:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B949C45DE52
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 11:53:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9BCCA1DB8056
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 11:53:45 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D32F1DB804C
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 11:53:45 +0900 (JST)
Date: Wed, 28 Apr 2010 11:49:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] mm,migration: Remove straggling migration PTEs when
 page tables are being moved after the VMA has already moved
Message-Id: <20100428114944.3570105f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100428024227.GN510@random.random>
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie>
	<1272403852-10479-4-git-send-email-mel@csn.ul.ie>
	<20100427223004.GF8860@random.random>
	<20100427225852.GH8860@random.random>
	<20100428102928.a3b25066.kamezawa.hiroyu@jp.fujitsu.com>
	<20100428014434.GM510@random.random>
	<20100428111248.2797801c.kamezawa.hiroyu@jp.fujitsu.com>
	<20100428024227.GN510@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 28 Apr 2010 04:42:27 +0200
Andrea Arcangeli <aarcange@redhat.com> wrote:

> On Wed, Apr 28, 2010 at 11:12:48AM +0900, KAMEZAWA Hiroyuki wrote:
> > The page can be replaced with migration_pte before the 1st vma_adjust.
> > 
> > The key is 
> > 	(vma, page) <-> address <-> pte <-> page
> > relationship.
> > 
> > 	vma_adjust() 
> > 	(*)
> > 	move_pagetables();
> > 	(**)
> > 	vma_adjust();
> > 
> > At (*), vma_address(vma, page) retruns a _new_ address. But pte is not
> > updated. This is ciritcal for rmap_walk. We're safe at (**).
> 
> Yes I agree we can move the unlock at (**) because the last vma_adjust
> is only there to truncate the vm_end. In fact it looks super
> heavyweight to call vma_adjust for that instead of just using
> vma->vm_end = new_end considering we're under mmap_sem, full anonymous
> etc... In fact I think even the first vma_adjust looks too
> heavyweight and it doesn't bring any simplicity or added safety
> considering this works in place and there's nothing to wonder about
> vm_next or vma_merge or vm_file or anything that vma_adjust is good at.
> 
> So the confusion I had about vm_pgoff is because all things that moves
> vm_start down, also move vm_pgoff down like stack growsdown but of
> course those don't move the pages down too, so we must not alter
> vm_pgoff here just vm_start along with the pagetables inside the
> anon_vma lock to be fully safe. Also I forgot to unlock in case of
> -ENOMEM ;)
> 
> this is a new try, next is for a later time... hope this helps!
> 
> Thanks!
> 
> ----
> Subject: fix race between shift_arg_pages and rmap_walk
> 
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> migrate.c requires rmap to be able to find all ptes mapping a page at
> all times, otherwise the migration entry can be instantiated, but it
> can't be removed if the second rmap_walk fails to find the page.
> 
> So shift_arg_pages must run atomically with respect of rmap_walk, and
> it's enough to run it under the anon_vma lock to make it atomic.
> 
> And split_huge_page() will have the same requirements as migrate.c
> already has.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Seems good.
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

I'll test this and report if I see trouble again.

Unfortunately, I'll have a week of holidays (in Japan) in 4/29-5/05,
my office is nearly closed. So, please consider no-mail-from-me is
good information.


Thanks,
-Kame


> ---
> 
> diff --git a/fs/exec.c b/fs/exec.c
> --- a/fs/exec.c
> +++ b/fs/exec.c
> @@ -55,6 +55,7 @@
>  #include <linux/fsnotify.h>
>  #include <linux/fs_struct.h>
>  #include <linux/pipe_fs_i.h>
> +#include <linux/rmap.h>
>  
>  #include <asm/uaccess.h>
>  #include <asm/mmu_context.h>
> @@ -502,6 +503,7 @@ static int shift_arg_pages(struct vm_are
>  	unsigned long length = old_end - old_start;
>  	unsigned long new_start = old_start - shift;
>  	unsigned long new_end = old_end - shift;
> +	unsigned long moved_length;
>  	struct mmu_gather *tlb;
>  
>  	BUG_ON(new_start > new_end);
> @@ -514,16 +516,26 @@ static int shift_arg_pages(struct vm_are
>  		return -EFAULT;
>  
>  	/*
> +	 * Stop the rmap walk or it won't find the stack pages, we've
> +	 * to keep the lock hold until all pages are moved to the new
> +	 * vm_start so their page->index will be always found
> +	 * consistent with the unchanged vm_pgoff.
> +	 */
> +	spin_lock(&vma->anon_vma->lock);
> +
> +	/*
>  	 * cover the whole range: [new_start, old_end)
>  	 */
> -	vma_adjust(vma, new_start, old_end, vma->vm_pgoff, NULL);
> +	vma->vm_start = new_start;
>  
>  	/*
>  	 * move the page tables downwards, on failure we rely on
>  	 * process cleanup to remove whatever mess we made.
>  	 */
> -	if (length != move_page_tables(vma, old_start,
> -				       vma, new_start, length))
> +	moved_length = move_page_tables(vma, old_start,
> +					vma, new_start, length);
> +	spin_unlock(&vma->anon_vma->lock);
> +	if (length != moved_length) 
>  		return -ENOMEM;
>  
>  	lru_add_drain();
> @@ -549,7 +561,7 @@ static int shift_arg_pages(struct vm_are
>  	/*
>  	 * shrink the vma to just the new range.
>  	 */
> -	vma_adjust(vma, new_start, new_end, vma->vm_pgoff, NULL);
> +	vma->vm_end = new_end;
>  
>  	return 0;
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
