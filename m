Date: Wed, 28 May 2003 17:28:09 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Question about locking in mmap.c
In-Reply-To: <33460000.1054135672@baldur.austin.ibm.com>
Message-ID: <Pine.LNX.4.44.0305281700450.1317-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 28 May 2003, Dave McCracken wrote:
> It's been my understanding that most vma manipulation is protected by
> mm->mmap_sem, and the page table is protected by mm->page_table_lock.  I've
> been rummaging through mmap.c and see a number of places that take
> page_table_lock when the code is about to make changes to the vma chains.
> These places are already holding mmap_sem for write.
> 
> My question is what is page_table_lock supposed to be protecting against?
> Am I wrong that mmap_sem is sufficient to protect against concurrent
> changes to the vmas?

mmap_sem does protect those who use it against concurrent changes to the
vmas, but neither swapout (vmscan.c and rmap.c) nor swapoff (swapfile.c)
use it, and they (in a few places) do need such protection.

swapout used to scan from vma to vma, and page_table_lock was important
to protect that linkage; rmap has changed that all around, so it might
(I've not thought) be possible to relax page_table_locking of vma
insertion/removal now.

swapoff still scans from vma to vma as it always did; but it's no longer
holding mmlist_lock across unuse_process, so it might (again, I've not
thought deeper) be possible to down_read mmap_sem there now, allowing
vma insertion/removal not to take page_table_lock.

But swapout still needs to find_vma, page_table_lock is all that's
protecting that linkage, isn't it?

I doubt that vma_merge actually needs page_table_lock where it's just
lowering the start or raising the end of a vma: split_vma doesn't take
it in the complementary case.  But I'm not entirely convinced.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
