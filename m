Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 67BE36B01EE
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 21:33:32 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3S1XTM4022541
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 28 Apr 2010 10:33:29 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EC32D45DE57
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 10:33:28 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 851701EF081
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 10:33:28 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FC5A1DB8038
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 10:33:28 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 776411DB803B
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 10:33:27 +0900 (JST)
Date: Wed, 28 Apr 2010 10:29:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] mm,migration: Remove straggling migration PTEs when
 page tables are being moved after the VMA has already moved
Message-Id: <20100428102928.a3b25066.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100427225852.GH8860@random.random>
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie>
	<1272403852-10479-4-git-send-email-mel@csn.ul.ie>
	<20100427223004.GF8860@random.random>
	<20100427225852.GH8860@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 28 Apr 2010 00:58:52 +0200
Andrea Arcangeli <aarcange@redhat.com> wrote:

> On Wed, Apr 28, 2010 at 12:30:04AM +0200, Andrea Arcangeli wrote:
> > I'll now evaluate the fix and see if I can find any other
> > way to handle this.
> 
> 
> I think a better fix for bug mentioned in patch 3, is like below. This
> seems to work fine on aa.git with the old (stable) 2.6.33 anon-vma
> code. Not sure if this also works with the new anon-vma code in
> mainline but at first glance I think it should. At that point we
> should be single threaded so it shouldn't matter if anon_vma is
> temporary null.
> 
> Then you've to re-evaluate the vma_adjust fixes for mainline-only in
> patch 2 at the light of the below (I didn't check patch 2 in detail).
> 
> Please try to reproduce with the below applied.
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

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hmm..Mel's patch 2/3 takes vma->anon_vma->lock in vma_adjust(),
so this patch clears vma->anon_vma...

some comment below.

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
> @@ -503,6 +504,7 @@ static int shift_arg_pages(struct vm_are
>  	unsigned long new_start = old_start - shift;
>  	unsigned long new_end = old_end - shift;
>  	struct mmu_gather *tlb;
> +	struct anon_vma *anon_vma;
>  
>  	BUG_ON(new_start > new_end);
>  
> @@ -513,6 +515,12 @@ static int shift_arg_pages(struct vm_are
>  	if (vma != find_vma(mm, new_start))
>  		return -EFAULT;
>  
> +	anon_vma = vma->anon_vma;
> +	/* stop rmap_walk or it won't find the stack pages */

	/*
	 * We adjust vma and move page tables in sequence. While update, 
	 * (vma, page) <-> address <-> pte relationship is unstable.
	 * We lock anon_vma->lock for keeping rmap_walk() safe. (see mm/rmap.c)
	 */


> +	spin_lock(&anon_vma->lock);
> +	/* avoid vma_adjust to take any further anon_vma lock */
> +	vma->anon_vma = NULL;
> +
>  	/*
>  	 * cover the whole range: [new_start, old_end)
>  	 */
> @@ -551,6 +559,9 @@ static int shift_arg_pages(struct vm_are
>  	 */
>  	vma_adjust(vma, new_start, new_end, vma->vm_pgoff, NULL);
>  
> +	vma->anon_vma = anon_vma;
> +	spin_unlock(&anon_vma->lock);
> +

I think we can unlock this just after move_page_tables().


Thanks,
-kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
