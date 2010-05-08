Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3DCC96B024C
	for <linux-mm@kvack.org>; Sat,  8 May 2010 11:39:57 -0400 (EDT)
Date: Sat, 8 May 2010 17:39:22 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
 the wrong VMA information
Message-ID: <20100508153922.GS5941@random.random>
References: <1273188053-26029-1-git-send-email-mel@csn.ul.ie>
 <1273188053-26029-2-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1273188053-26029-2-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Fri, May 07, 2010 at 12:20:52AM +0100, Mel Gorman wrote:
> @@ -1655,6 +1655,7 @@ int rmap_walk_ksm(struct page *page, int (*rmap_one)(struct page *,
>  {
>  	struct stable_node *stable_node;
>  	struct hlist_node *hlist;
> +	struct anon_vma *nested_anon_vma = NULL;
>  	struct rmap_item *rmap_item;
>  	int ret = SWAP_AGAIN;
>  	int search_new_forks = 0;
> @@ -1671,9 +1672,16 @@ again:
>  		struct anon_vma_chain *vmac;
>  		struct vm_area_struct *vma;
>  
> -		spin_lock(&anon_vma->lock);
> +		anon_vma = anon_vma_lock_root(anon_vma);
> +		if (nested_anon_vma) {
> +			spin_unlock(&nested_anon_vma->lock);
> +			nested_anon_vma = NULL;
> +		}
>  		list_for_each_entry(vmac, &anon_vma->head, same_anon_vma) {
>  			vma = vmac->vma;
> +			nested_anon_vma = anon_vma_lock_nested(nested_anon_vma,
> +						vma->anon_vma, anon_vma);
> +
>  			if (rmap_item->address < vma->vm_start ||
>  			    rmap_item->address >= vma->vm_end)
>  				continue;
> @@ -1368,19 +1444,26 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
>  	 * are holding mmap_sem. Users without mmap_sem are required to
>  	 * take a reference count to prevent the anon_vma disappearing
>  	 */
> -	anon_vma = page_anon_vma(page);
> +	anon_vma = page_anon_vma_lock_root(page);
>  	if (!anon_vma)
>  		return ret;
> -	spin_lock(&anon_vma->lock);
>  	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
>  		struct vm_area_struct *vma = avc->vma;
> -		unsigned long address = vma_address(page, vma);
> -		if (address == -EFAULT)
> -			continue;
> -		ret = rmap_one(page, vma, address, arg);
> +		unsigned long address;
> +
> +		nested_anon_vma = anon_vma_lock_nested(nested_anon_vma,
> +						vma->anon_vma, anon_vma);
> +		address = vma_address(page, vma);
> +		if (address != -EFAULT)
> +			ret = rmap_one(page, vma, address, arg);
> +
>  		if (ret != SWAP_AGAIN)
>  			break;
>  	}
> +
> +	if (nested_anon_vma)
> +		spin_unlock(&nested_anon_vma->lock);
> +
>  	spin_unlock(&anon_vma->lock);
>  	return ret;
>  }

I already told Mel by PM. This degrades the new-anon_vma code to an
even _slower_ mode than the old anon-vma code in 2.6.32 (the same in
math complexity terms but slower in practice) for migrate. Furthermore
page_referenced() may now return true even if there are young ptes
that simply get lost in the rmap walk.

The new anon-vma code is mostly relevant for migrate and memory
compaction and transparent hugepage support where it gets invoked even
if there's plenty of free memory and no I/O load at all. So whatever
you save during swap, you'll lose while transparent hugepage support
allocate the pages. So the above fix renders the whole effort
pointless as far as I'm concerned.

I think Rik's patch is the only sensible solution that won't
invalidate the whole effort for transparent hugepage.

About how to adapt split_huge_page to the root anon_vma I didn't even
think about it yet. All I can tell you right now is that
wait_split_huge_page can be changed to wait on the pmd_trans_splitting
(or alternatively the pmd_trans_huge bit) bit to go away in a
cpu_relax() barrier() loop. But the page->mapping/anon_vma->lock is
also used to serialize against parallel split_huge_page but I guess
taking the root anon_vma lock in split_huge_page() should work
fine. Just I'm not going to do that except maybe in a for-mainline
branch, but I'll keep master branch with the old-anon-vma 2.6.32 code
and the anon_vma_branch with Rik's fix that allows to take advantage
of the new anon-vma code (so it's not purely gratuitous complexity
added for nothing) also in migrate.c from memory compaction (that runs
24/7 on all my systems and it's much more frequent than the swap rmap
walks that in fact never ever happens here), and in the rmap walks in
split_huge_page too (which are not so frequent especially after
Johannes implemented native mprotect on hugepages but it's obviously
still more frequent than swap).

I'm simply not going to support the degradation to the root anon_vma
complexity in aa.git, except for strict merging requirements but I'll
keep backing it out in aa.git or I'd rather stick to old-anon-vma
code which at least is much simpler and saves memory too (as there are
many fewer anon-vma and no avc, and less useless locks).

What I instead already mentioned once was to add a _shared_ lock so
you share the spinlock across the whole forest but you keep walking
the right page->anon_vma->same_anon_vma! The moment you walk the
page->anon_vma->root_anon_vma->same_anon_vma you lost my support as it
makes the whole effort pointless compared to 2.6.32 as far as 99% of my
workloads are concerned.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
