Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 90E4D6B01EE
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 20:11:16 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3R0BGBB013464
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 27 Apr 2010 09:11:16 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4563145DE50
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 09:11:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 24C7A45DE4E
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 09:11:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 07BF71DB803E
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 09:11:16 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A39C81DB8037
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 09:11:15 +0900 (JST)
Date: Tue, 27 Apr 2010 09:07:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
 the wrong VMA information
Message-Id: <20100427090706.7ca68e12.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1272321478-28481-3-git-send-email-mel@csn.ul.ie>
References: <1272321478-28481-1-git-send-email-mel@csn.ul.ie>
	<1272321478-28481-3-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 26 Apr 2010 23:37:58 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> vma_adjust() is updating anon VMA information without any locks taken.
> In contrast, file-backed mappings use the i_mmap_lock and this lack of
> locking can result in races with page migration. During rmap_walk(),
> vma_address() can return -EFAULT for an address that will soon be valid.
> This leaves a dangling migration PTE behind which can later cause a BUG_ON
> to trigger when the page is faulted in.
> 
> With the recent anon_vma changes, there can be more than one anon_vma->lock
> that can be taken in a anon_vma_chain but a second lock cannot be spinned
> upon in case of deadlock. Instead, the rmap walker tries to take locks of
> different anon_vma's. If the attempt fails, the operation is restarted.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Ok, acquiring vma->anon_vma->spin_lock always sounds very safe.
(but slow.)

I'll test this, too.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



> ---
>  mm/ksm.c  |   13 +++++++++++++
>  mm/mmap.c |    6 ++++++
>  mm/rmap.c |   22 +++++++++++++++++++---
>  3 files changed, 38 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 3666d43..baa5b4d 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -1674,9 +1674,22 @@ again:
>  		spin_lock(&anon_vma->lock);
>  		list_for_each_entry(vmac, &anon_vma->head, same_anon_vma) {
>  			vma = vmac->vma;
> +
> +			/* See comment in mm/rmap.c#rmap_walk_anon on locking */
> +			if (anon_vma != vma->anon_vma) {
> +				if (!spin_trylock(&vma->anon_vma->lock)) {
> +					spin_unlock(&anon_vma->lock);
> +					goto again;
> +				}
> +			}
> +
>  			if (rmap_item->address < vma->vm_start ||
>  			    rmap_item->address >= vma->vm_end)
>  				continue;
> +
> +			if (anon_vma != vma->anon_vma)
> +				spin_unlock(&vma->anon_vma->lock);
> +
>  			/*
>  			 * Initially we examine only the vma which covers this
>  			 * rmap_item; but later, if there is still work to do,
> diff --git a/mm/mmap.c b/mm/mmap.c
> index f90ea92..61d6f1d 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -578,6 +578,9 @@ again:			remove_next = 1 + (end > next->vm_end);
>  		}
>  	}
>  
> +	if (vma->anon_vma)
> +		spin_lock(&vma->anon_vma->lock);
> +
>  	if (root) {
>  		flush_dcache_mmap_lock(mapping);
>  		vma_prio_tree_remove(vma, root);
> @@ -620,6 +623,9 @@ again:			remove_next = 1 + (end > next->vm_end);
>  	if (mapping)
>  		spin_unlock(&mapping->i_mmap_lock);
>  
> +	if (vma->anon_vma)
> +		spin_unlock(&vma->anon_vma->lock);
> +
>  	if (remove_next) {
>  		if (file) {
>  			fput(file);
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 85f203e..bc313a6 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1368,15 +1368,31 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
>  	 * are holding mmap_sem. Users without mmap_sem are required to
>  	 * take a reference count to prevent the anon_vma disappearing
>  	 */
> +retry:
>  	anon_vma = page_anon_vma(page);
>  	if (!anon_vma)
>  		return ret;
>  	spin_lock(&anon_vma->lock);
>  	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
>  		struct vm_area_struct *vma = avc->vma;
> -		unsigned long address = vma_address(page, vma);
> -		if (address == -EFAULT)
> -			continue;
> +		unsigned long address;
> +
> +		/*
> +		 * Guard against deadlocks by not spinning against
> +		 * vma->anon_vma->lock. If contention is found, release our
> +		 * lock and try again until VMA list can be traversed without
> +		 * contention.
> +		 */
> +		if (anon_vma != vma->anon_vma) {
> +			if (!spin_trylock(&vma->anon_vma->lock)) {
> +				spin_unlock(&anon_vma->lock);
> +				goto retry;
> +			}
> +		}
> +		address = vma_address(page, vma);
> +		if (anon_vma != vma->anon_vma)
> +			spin_unlock(&vma->anon_vma->lock);
> +
>  		ret = rmap_one(page, vma, address, arg);
>  		if (ret != SWAP_AGAIN)
>  			break;
> -- 
> 1.6.5
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
