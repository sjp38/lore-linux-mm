Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 48D526B004F
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 00:59:44 -0500 (EST)
Received: by mail-pz0-f42.google.com with SMTP id z17so198351dal.15
        for <linux-mm@kvack.org>; Wed, 25 Jan 2012 21:59:43 -0800 (PST)
From: Roland Dreier <roland@kernel.org>
Subject: [PATCH/RFC G-U-P experts] IB/umem: Modernize our get_user_pages() parameters
Date: Wed, 25 Jan 2012 21:59:34 -0800
Message-Id: <1327557574-6125-1-git-send-email-roland@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-rdma@vger.kernel.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Roland Dreier <roland@purestorage.com>

Right now, we always pass write==1 to get_user_pages(), even when we
only intend to read the memory.  We pass force==1 if we're going for
read-only and force==0 if we want writable.  The reasoning behind this
seems to be contained in this out-of-tree changelog from 2005:

    Always ask get_user_pages() for writable pages, but pass force=1
    if the consumer has only asked for read-only pages.  This fixes a
    problem registering memory that has just been allocated but not
    touched yet, while allowing registration of read-only memory to
    continue to work.

However, I don't think the mm works like this today, and indeed GUP
will fault in pages for an untouched read-only mapping just fine with
write and force set to 0.  In fact, always passing 1 for write causes
problems with modern kernels, because we end up hitting the "early
C-O-W break" case in __do_fault(), even for read-only mappings where
this makes no sense.

Signed-off-by: Roland Dreier <roland@purestorage.com>
---
This patch comes from me trying to do userspace RDMA on a memory
region exported from a character driver and mapped with

    mmap(... PROT_READ, MAP_PRIVATE ...)

The character driver has a trivial mmap method that just sets vm_ops
and and equally trivial fault method that essentially just does

    vmf->page = vmalloc_to_page(buf + (vmf->pgoff << PAGE_SHIFT));

ie the most elementary way to export a vmalloc'ed buffer to userspace.

However, when I tried doing

    ibv_reg_mr(... IBV_ACCESS_REMOTE_READ ...)

in userspace on that mmap region, I found that COW was happening and
so neither userspace nor the registered memory ended up pointing at
the kernel buffer anymore, exactly because of the COW in __do_fault()
I mention in the changelog above.

The patch below fixes my test case, and doesn't seem to break any of
the ibverbs examples and other simple tests of userspace verbs that I
tried.  But that's far from an exhaustive test suite.

I'd definitely appreciate comments from MM experts here, since I'm not
positive of my understand of G-U-P and friends, and I don't want to
apps because this is wrong in some special case I didn't try.

Also testing from anyone with an RDMA app that does anything at all
fancy with memory allocation or registration would be helpful.

Thanks!

PS Let me know if I didn't go on long enough about this one-line patch
and I can write some more.

 drivers/infiniband/core/umem.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
index 71f0c0f..fb5abd3 100644
--- a/drivers/infiniband/core/umem.c
+++ b/drivers/infiniband/core/umem.c
@@ -152,7 +152,7 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 		ret = get_user_pages(current, current->mm, cur_base,
 				     min_t(unsigned long, npages,
 					   PAGE_SIZE / sizeof (struct page *)),
-				     1, !umem->writable, page_list, vma_list);
+				     umem->writable, 0, page_list, vma_list);
 
 		if (ret < 0)
 			goto out;
-- 
1.7.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
