Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 588AB6B01F5
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 11:35:54 -0400 (EDT)
Date: Wed, 28 Apr 2010 17:35:25 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/3] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
 the wrong VMA information
Message-ID: <20100428153525.GR510@random.random>
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie>
 <1272403852-10479-3-git-send-email-mel@csn.ul.ie>
 <20100427231007.GA510@random.random>
 <20100428091555.GB15815@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100428091555.GB15815@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 28, 2010 at 10:15:55AM +0100, Mel Gorman wrote:
> It became unconditional because I wasn't sure of the optimisation versus the
> new anon_vma changes (doesn't matter, should have been safe). At the time

Changeset 287d97ac032136724143cde8d5964b414d562ee3 is meant to explain
the removal of the lock but I don't get it from the comments. Or at
least I don't get from that comment why we can't resurrect the plain
old deleted code that looked fine to me. Like there is no reason to
take the lock if start == vma->vm_start.

> So, the VMA list does not appear to be messed up but there still needs
> to be protection against modification of VMA details that are already on
> the list. For that, the seq counter would have been enough and
> lighter-weight than acquiring the anon_vma->lock every time in
> vma_adjust().
> 
> I'll drop this patch again as the execve race looks the most important.

You mean you're dropping patch 2 too? I agree dropping patch 1 but
to me the having to take all the anon_vma locks for every
vma->anon_vma->lock that we walk seems a must, otherwise
expand_downwards and vma_adjust won't be ok, plus we need to re-add
the anon_vma lock to vma_adjust, it can't be safe to alter vm_pgoff
and vm_start outside of the anon_vma->lock. Or I am mistaken?

Patch 2 wouldn't help the swapops crash we reproduced because at that
point the anon_vma of the stack is the local one, it's just after
execve.

vma_adjust and expand_downards would alter vm_pgoff and vm_start while
taking only the vma->anon_vma->lock where the vma->anon_vma is the
_local_ one of the vma.  But a vma in mainline can be indexed in
infinite anon_vmas, so to prevent breaking migration
vma_adjust/expand_downards the rmap_walk would need to take _all_
anon_vma->locks for every anon_vma that the vma is indexed into. Or
alternatively like you implemented rmap_walk would need to check if
the vma we found in the rmap_walk is different from the original
anon_vma and to take the vma->anon_vma->lock (so taking the
anon_vma->lock of the local anon_vma of every vma) before it can
actually read the vma->vm_pgoff/vm_start inside vma_address.

If the above is right it also means the new anon-vma changes also break
the whole locking of transparent hugepage, see wait_split_huge_page,
it does a spin_unlock_wait(&anon_vma->lock) thinking that waiting the
"local" anon-vma is enough, when in fact the hugepage may be shared
and belonging to the parent parent_vma->anon_vma and not to the local
one of the last child that is waiting on the wrong lock. So I may have
to rewrite this part of the thp locking to solve this. And for me it's
not enough to just taking more locks inside the rmap walks inside
split_huge_page as I used the anon_vma lock outside too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
