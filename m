Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id B1B229C0003
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 10:29:04 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rr4so947539pbb.34
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 07:29:04 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 06/26] vmw_vmci: Convert driver to use get_user_pages_fast()
Date: Wed,  2 Oct 2013 16:27:47 +0200
Message-Id: <1380724087-13927-7-git-send-email-jack@suse.cz>
In-Reply-To: <1380724087-13927-1-git-send-email-jack@suse.cz>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Convert vmci_host_setup_notify() and qp_host_get_user_memory() to use
get_user_pages_fast() instead of get_user_pages(). Note that
qp_host_get_user_memory() was using mmap_sem for writing without an
apparent reason.

CC: Arnd Bergmann <arnd@arndb.de>
CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/misc/vmw_vmci/vmci_host.c       |  6 +-----
 drivers/misc/vmw_vmci/vmci_queue_pair.c | 21 ++++++---------------
 2 files changed, 7 insertions(+), 20 deletions(-)

diff --git a/drivers/misc/vmw_vmci/vmci_host.c b/drivers/misc/vmw_vmci/vmci_host.c
index d4722b3dc8ec..1723a6e4f2e8 100644
--- a/drivers/misc/vmw_vmci/vmci_host.c
+++ b/drivers/misc/vmw_vmci/vmci_host.c
@@ -243,11 +243,7 @@ static int vmci_host_setup_notify(struct vmci_ctx *context,
 	/*
 	 * Lock physical page backing a given user VA.
 	 */
-	down_read(&current->mm->mmap_sem);
-	retval = get_user_pages(current, current->mm,
-				PAGE_ALIGN(uva),
-				1, 1, 0, &page, NULL);
-	up_read(&current->mm->mmap_sem);
+	retval = get_user_pages_fast(PAGE_ALIGN(uva), 1, 1, &page);
 	if (retval != 1)
 		return VMCI_ERROR_GENERIC;
 
diff --git a/drivers/misc/vmw_vmci/vmci_queue_pair.c b/drivers/misc/vmw_vmci/vmci_queue_pair.c
index a0515a6d6ebd..1b7b303085d2 100644
--- a/drivers/misc/vmw_vmci/vmci_queue_pair.c
+++ b/drivers/misc/vmw_vmci/vmci_queue_pair.c
@@ -732,13 +732,9 @@ static int qp_host_get_user_memory(u64 produce_uva,
 	int retval;
 	int err = VMCI_SUCCESS;
 
-	down_write(&current->mm->mmap_sem);
-	retval = get_user_pages(current,
-				current->mm,
-				(uintptr_t) produce_uva,
-				produce_q->kernel_if->num_pages,
-				1, 0,
-				produce_q->kernel_if->u.h.header_page, NULL);
+	retval = get_user_pages_fast((uintptr_t) produce_uva,
+				     produce_q->kernel_if->num_pages, 1,
+				     produce_q->kernel_if->u.h.header_page);
 	if (retval < produce_q->kernel_if->num_pages) {
 		pr_warn("get_user_pages(produce) failed (retval=%d)", retval);
 		qp_release_pages(produce_q->kernel_if->u.h.header_page,
@@ -747,12 +743,9 @@ static int qp_host_get_user_memory(u64 produce_uva,
 		goto out;
 	}
 
-	retval = get_user_pages(current,
-				current->mm,
-				(uintptr_t) consume_uva,
-				consume_q->kernel_if->num_pages,
-				1, 0,
-				consume_q->kernel_if->u.h.header_page, NULL);
+	retval = get_user_pages_fast((uintptr_t) consume_uva,
+				     consume_q->kernel_if->num_pages, 1,
+				     consume_q->kernel_if->u.h.header_page);
 	if (retval < consume_q->kernel_if->num_pages) {
 		pr_warn("get_user_pages(consume) failed (retval=%d)", retval);
 		qp_release_pages(consume_q->kernel_if->u.h.header_page,
@@ -763,8 +756,6 @@ static int qp_host_get_user_memory(u64 produce_uva,
 	}
 
  out:
-	up_write(&current->mm->mmap_sem);
-
 	return err;
 }
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
