Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id B0AA26B0037
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 16:22:05 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id z10so7625564pdj.17
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 13:22:05 -0700 (PDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rcjenn@linux.vnet.ibm.com>;
	Tue, 8 Oct 2013 06:22:01 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 0ECF02CE8040
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 07:21:59 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r97K54Zb7995826
	for <linux-mm@kvack.org>; Tue, 8 Oct 2013 07:05:04 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r97KLvNH014086
	for <linux-mm@kvack.org>; Tue, 8 Oct 2013 07:21:58 +1100
From: Robert C Jennings <rcj@linux.vnet.ibm.com>
Subject: [PATCH 2/2] vmsplice: Add limited zero copy to vmsplice
Date: Mon,  7 Oct 2013 15:21:33 -0500
Message-Id: <1381177293-27125-3-git-send-email-rcj@linux.vnet.ibm.com>
In-Reply-To: <1381177293-27125-1-git-send-email-rcj@linux.vnet.ibm.com>
References: <1381177293-27125-1-git-send-email-rcj@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave@sr71.net>, Robert C Jennings <rcj@linux.vnet.ibm.com>, Matt Helsley <matt.helsley@gmail.com>, Anthony Liguori <anthony@codemonkey.ws>, Michael Roth <mdroth@linux.vnet.ibm.com>, Lei Li <lilei@linux.vnet.ibm.com>, Leonardo Garcia <lagarcia@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>

From: Matt Helsley <matt.helsley@gmail.com>

It is sometimes useful to move anonymous pages over a pipe rather than
save/swap them. Check the SPLICE_F_GIFT and SPLICE_F_MOVE flags to see
if userspace would like to move such pages. This differs from plain
SPLICE_F_GIFT in that the memory written to the pipe will no longer
have the same contents as the original -- it effectively faults in new,
empty anonymous pages.

On the read side the page written to the pipe will be copied unless
SPLICE_F_MOVE is used. Otherwise copying will be performed and the page
will be reclaimed. Note that so long as there is a mapping to the page
copies will be done instead because rmap will have upped the map count for
each anonymous mapping; this can happen do to fork(), for example. This
is necessary because moving the page will usually change the anonymous
page's nonlinear index and that can only be done if it's unmapped.

Signed-off-by: Matt Helsley <matt.helsley@gmail.com>
Signed-off-by: Robert C Jennings <rcj@linux.vnet.ibm.com>
---
 fs/splice.c | 63 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 63 insertions(+)

diff --git a/fs/splice.c b/fs/splice.c
index a62d61e..9d2ed128 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -32,6 +32,10 @@
 #include <linux/gfp.h>
 #include <linux/socket.h>
 #include <linux/compat.h>
+#include <linux/page-flags.h>
+#include <linux/hugetlb.h>
+#include <linux/ksm.h>
+#include <linux/swapops.h>
 #include "internal.h"
 
 /*
@@ -1562,6 +1566,65 @@ static int pipe_to_user(struct pipe_inode_info *pipe, struct pipe_buffer *buf,
 	char *src;
 	int ret;
 
+	if (!buf->offset && (buf->len == PAGE_SIZE) &&
+	    (buf->flags & PIPE_BUF_FLAG_GIFT) && (sd->flags & SPLICE_F_MOVE)) {
+		struct page *page = buf->page;
+		struct mm_struct *mm;
+		struct vm_area_struct *vma;
+		spinlock_t *ptl;
+		pte_t *ptep, pte;
+		unsigned long useraddr;
+
+		if (!PageAnon(page))
+			goto copy;
+		if (PageCompound(page))
+			goto copy;
+		if (PageHuge(page) || PageTransHuge(page))
+			goto copy;
+		if (page_mapped(page))
+			goto copy;
+		useraddr = (unsigned long)sd->u.userptr;
+		mm = current->mm;
+
+		ret = -EAGAIN;
+		down_read(&mm->mmap_sem);
+		vma = find_vma_intersection(mm, useraddr, useraddr + PAGE_SIZE);
+		if (IS_ERR_OR_NULL(vma))
+			goto up_copy;
+		if (!vma->anon_vma) {
+			ret = anon_vma_prepare(vma);
+			if (ret)
+				goto up_copy;
+		}
+		zap_page_range(vma, useraddr, PAGE_SIZE, NULL);
+		ret = lock_page_killable(page);
+		if (ret)
+			goto up_copy;
+		ptep = get_locked_pte(mm, useraddr, &ptl);
+		if (!ptep)
+			goto unlock_up_copy;
+		pte = *ptep;
+		if (pte_present(pte))
+			goto unlock_up_copy;
+		get_page(page);
+		page_add_anon_rmap(page, vma, useraddr);
+		pte = mk_pte(page, vma->vm_page_prot);
+		set_pte_at(mm, useraddr, ptep, pte);
+		update_mmu_cache(vma, useraddr, ptep);
+		pte_unmap_unlock(ptep, ptl);
+		ret = 0;
+unlock_up_copy:
+		unlock_page(page);
+up_copy:
+		up_read(&mm->mmap_sem);
+		if (!ret) {
+			ret = sd->len;
+			goto out;
+		}
+		/* else ret < 0 and we should fallback to copying */
+		VM_BUG_ON(ret > 0);
+	}
+copy:
 	/*
 	 * See if we can use the atomic maps, by prefaulting in the
 	 * pages and doing an atomic copy
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
