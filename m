Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id F0B9D6200BA
	for <linux-mm@kvack.org>; Fri,  7 May 2010 12:27:08 -0400 (EDT)
Date: Fri, 7 May 2010 17:26:44 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
	the wrong VMA information
Message-ID: <20100507162644.GD4859@csn.ul.ie>
References: <1273188053-26029-1-git-send-email-mel@csn.ul.ie> <1273188053-26029-2-git-send-email-mel@csn.ul.ie> <20100507095654.a8097967.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100507095654.a8097967.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Fri, May 07, 2010 at 09:56:54AM +0900, KAMEZAWA Hiroyuki wrote:
> On Fri,  7 May 2010 00:20:52 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > vma_adjust() is updating anon VMA information without locks being taken.
> > In contrast, file-backed mappings use the i_mmap_lock and this lack of
> > locking can result in races with users of rmap_walk such as page migration.
> > vma_address() can return -EFAULT for an address that will soon be valid.
> > For migration, this potentially leaves a dangling migration PTE behind
> > which can later cause a BUG_ON to trigger when the page is faulted in.
> > 
> > <SNIP>
> 
> I'm sorry but I don't think I understand this. Could you help me ?
> 

Hopefully.

> IIUC, anon_vma_chain is linked as 2D-mesh
> 
>             anon_vma1    anon_vma2    anon_vma3
>                 |            |            |
>     vma1 -----  1  --------  2  --------- 3 -----
>                 |            |            |
>     vma2 -----  4  --------  5 ---------- 6 -----
>                 |            |            |
>     vma3 -----  7  --------  8 ---------- 9 -----
> 
> 
> Here,
>   * vertical link is anon_vma->head, avc->same_anon_vma link.
>   * horizontal link is vma->anon_vma_chain, avc->same_vma link.
>   * 1-9 are avcs.
> 

I don't think this is quite right for how the "root" anon_vma is
discovered. The ordering of same_vma is such that the prev pointer
points to the root anon_vma as described in __page_set_anon_rmap() but
even so...

> When scanning pages, we may see a page whose anon_vma is anon_vma1
> or anon_vma2 or anon_vma3. 
>

When we are walking the list for the anon_vma, we also hold the page
lock and what we're really interested in are ptes mapping that page.

> When we see anon_vma3 in page->mapping, we lock anon_vma1 and chase
> avc1->avc4->avc7. Then, start from vma1. Next, we visit vma2, we lock anon_vma2.
> At the last, we visit vma3 and lock anon_vma3.....And all are done under
> anon_vma1->lock. Right ?
> 

assuming it's the root lock, sure.

> Hmm, one concern is 
> 	anon_vma3 -> avc3 -> vma1 -> avc1 -> anon_vma1 chasing.
> 
> What will prevent vma1 disappear right after releasling anon_vma3->lock ?
> 

What does it matter if it disappeared? If it did, it was because it was torn
down, the PTEs are also gone and a user of rmap_walk should have stopped
caring. Right?

> ex)
> a1) At we chase, anon_vma3 -> avc3 -> vma1 -> anon_vma1, link was following.
> 
>             anon_vma1    anon_vma2    anon_vma3
>                 |            |            |
>     vma1 -----  1  --------  2  --------- 3 -----
>                 |            |            |
>     vma2 -----  4  --------  5 ---------- 6 -----
>                 |            |            |
>     vma3 -----  7  --------  8 ---------- 9 -----
>  
>    We hold lock on anon_vma3.
> 
> a2) After releasing anon_vma3 lock. vma1 can be unlinked.
> 
>             anon_vma1    anon_vma2    anon_vma3
>                 |            |            |
>  vma1 removed.
>                 |            |            |
>     vma2 -----  4  --------  5 ---------- 6 -----
>                 |            |            |
>     vma3 -----  7  --------  8 ---------- 9 -----
> 
> But we know anon_vma1->head is not empty, and it's accessable.
> Then, no problem for our purpose. Right ?
> 

As the PTEs are also gone, I'm not seeing the problem.

> b1) Another thinking.
> 
> At we chase, anon_vma3 -> avc3 -> vma1 -> anon_vma1, link was following.
> 
>             anon_vma1    anon_vma2    anon_vma3
>                 |            |            |
>     vma1 -----  1  --------  2  --------- 3 -----
>                 |            |            |
>     vma2 -----  4  --------  5 ---------- 6 -----
>                 |            |            |
>     vma3 -----  7  --------  8 ---------- 9 -----
>  
>    We hold lock on anon_vma3. So, 
> 
>             anon_vma1    anon_vma2    anon_vma3
>                 |            |            |
>     vma1 ----removed -----removed  ------ 3 -----
>                 |            |            |
>     vma2 -----  4  --------  5 ---------- 6 -----
>                 |            |            |
>     vma3 -----  7  --------  8 ---------- 9 -----
> 
> we may see half-broken link while we take anon_vma3->lock. In this case,
> anon_vma1 can be caugt.
> 
> Don't we need this ?
> 
> 
>  void unlink_anon_vmas(struct vm_area_struct *vma)
>  {
>         struct anon_vma_chain *avc, *next;
> 
>         /* Unlink each anon_vma chained to the VMA. */
> -        list_for_each_entry_safe_reverse(avc, next, &vma->anon_vma_chain, same_vma) {

This was meant to be list_for_each_entry_safe(....)

> +        list_for_each_entry_safe_reverse(avc, next, &vma->anon_vma_chain, same_vma) {
>                 anon_vma_unlink(avc);
>                 list_del(&avc->same_vma);
>                 anon_vma_chain_free(avc);
>          }
>  }
> 
> head avc should be removed last...  Hmm ? I'm sorry if all are
> in correct order already.
> 

I think the ordering is ok. The rmap_walk may find a situation where the
anon_vmas are being cleaned up but again as the page tables are going
away at this point, the contents of the PTEs are no longer important.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
