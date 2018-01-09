Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B053B6B027C
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 15:57:15 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id i1so9336366pgv.22
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 12:57:15 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o12sor1914917plg.38.2018.01.09.12.57.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Jan 2018 12:57:14 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 36/36] lkdtm: Update usercopy tests for whitelisting
Date: Tue,  9 Jan 2018 12:56:05 -0800
Message-Id: <1515531365-37423-37-git-send-email-keescook@chromium.org>
In-Reply-To: <1515531365-37423-1-git-send-email-keescook@chromium.org>
References: <1515531365-37423-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Windsor <dave@nullcore.net>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

This updates the USERCOPY_HEAP_FLAG_* tests to USERCOPY_HEAP_WHITELIST_*,
since the final form of usercopy whitelisting ended up using an offset/size
window instead of the earlier proposed allocation flags.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/misc/lkdtm.h          |  4 +-
 drivers/misc/lkdtm_core.c     |  4 +-
 drivers/misc/lkdtm_usercopy.c | 88 ++++++++++++++++++++++++-------------------
 3 files changed, 53 insertions(+), 43 deletions(-)

diff --git a/drivers/misc/lkdtm.h b/drivers/misc/lkdtm.h
index 687a0dbbe199..9e513dcfd809 100644
--- a/drivers/misc/lkdtm.h
+++ b/drivers/misc/lkdtm.h
@@ -76,8 +76,8 @@ void __init lkdtm_usercopy_init(void);
 void __exit lkdtm_usercopy_exit(void);
 void lkdtm_USERCOPY_HEAP_SIZE_TO(void);
 void lkdtm_USERCOPY_HEAP_SIZE_FROM(void);
-void lkdtm_USERCOPY_HEAP_FLAG_TO(void);
-void lkdtm_USERCOPY_HEAP_FLAG_FROM(void);
+void lkdtm_USERCOPY_HEAP_WHITELIST_TO(void);
+void lkdtm_USERCOPY_HEAP_WHITELIST_FROM(void);
 void lkdtm_USERCOPY_STACK_FRAME_TO(void);
 void lkdtm_USERCOPY_STACK_FRAME_FROM(void);
 void lkdtm_USERCOPY_STACK_BEYOND(void);
diff --git a/drivers/misc/lkdtm_core.c b/drivers/misc/lkdtm_core.c
index ba92291508dc..e3f2bac4b245 100644
--- a/drivers/misc/lkdtm_core.c
+++ b/drivers/misc/lkdtm_core.c
@@ -177,8 +177,8 @@ static const struct crashtype crashtypes[] = {
 	CRASHTYPE(ATOMIC_TIMING),
 	CRASHTYPE(USERCOPY_HEAP_SIZE_TO),
 	CRASHTYPE(USERCOPY_HEAP_SIZE_FROM),
-	CRASHTYPE(USERCOPY_HEAP_FLAG_TO),
-	CRASHTYPE(USERCOPY_HEAP_FLAG_FROM),
+	CRASHTYPE(USERCOPY_HEAP_WHITELIST_TO),
+	CRASHTYPE(USERCOPY_HEAP_WHITELIST_FROM),
 	CRASHTYPE(USERCOPY_STACK_FRAME_TO),
 	CRASHTYPE(USERCOPY_STACK_FRAME_FROM),
 	CRASHTYPE(USERCOPY_STACK_BEYOND),
diff --git a/drivers/misc/lkdtm_usercopy.c b/drivers/misc/lkdtm_usercopy.c
index 9ebbb031e5e3..9725aed305bb 100644
--- a/drivers/misc/lkdtm_usercopy.c
+++ b/drivers/misc/lkdtm_usercopy.c
@@ -20,7 +20,7 @@
  */
 static volatile size_t unconst = 0;
 static volatile size_t cache_size = 1024;
-static struct kmem_cache *bad_cache;
+static struct kmem_cache *whitelist_cache;
 
 static const unsigned char test_text[] = "This is a test.\n";
 
@@ -115,6 +115,10 @@ static noinline void do_usercopy_stack(bool to_user, bool bad_frame)
 	vm_munmap(user_addr, PAGE_SIZE);
 }
 
+/*
+ * This checks for whole-object size validation with hardened usercopy,
+ * with or without usercopy whitelisting.
+ */
 static void do_usercopy_heap_size(bool to_user)
 {
 	unsigned long user_addr;
@@ -177,77 +181,79 @@ static void do_usercopy_heap_size(bool to_user)
 	kfree(two);
 }
 
-static void do_usercopy_heap_flag(bool to_user)
+/*
+ * This checks for the specific whitelist window within an object. If this
+ * test passes, then do_usercopy_heap_size() tests will pass too.
+ */
+static void do_usercopy_heap_whitelist(bool to_user)
 {
-	unsigned long user_addr;
-	unsigned char *good_buf = NULL;
-	unsigned char *bad_buf = NULL;
+	unsigned long user_alloc;
+	unsigned char *buf = NULL;
+	unsigned char __user *user_addr;
+	size_t offset, size;
 
 	/* Make sure cache was prepared. */
-	if (!bad_cache) {
+	if (!whitelist_cache) {
 		pr_warn("Failed to allocate kernel cache\n");
 		return;
 	}
 
 	/*
-	 * Allocate one buffer from each cache (kmalloc will have the
-	 * SLAB_USERCOPY flag already, but "bad_cache" won't).
+	 * Allocate a buffer with a whitelisted window in the buffer.
 	 */
-	good_buf = kmalloc(cache_size, GFP_KERNEL);
-	bad_buf = kmem_cache_alloc(bad_cache, GFP_KERNEL);
-	if (!good_buf || !bad_buf) {
-		pr_warn("Failed to allocate buffers from caches\n");
+	buf = kmem_cache_alloc(whitelist_cache, GFP_KERNEL);
+	if (!buf) {
+		pr_warn("Failed to allocate buffer from whitelist cache\n");
 		goto free_alloc;
 	}
 
 	/* Allocate user memory we'll poke at. */
-	user_addr = vm_mmap(NULL, 0, PAGE_SIZE,
+	user_alloc = vm_mmap(NULL, 0, PAGE_SIZE,
 			    PROT_READ | PROT_WRITE | PROT_EXEC,
 			    MAP_ANONYMOUS | MAP_PRIVATE, 0);
-	if (user_addr >= TASK_SIZE) {
+	if (user_alloc >= TASK_SIZE) {
 		pr_warn("Failed to allocate user memory\n");
 		goto free_alloc;
 	}
+	user_addr = (void __user *)user_alloc;
 
-	memset(good_buf, 'A', cache_size);
-	memset(bad_buf, 'B', cache_size);
+	memset(buf, 'B', cache_size);
+
+	/* Whitelisted window in buffer, from kmem_cache_create_usercopy. */
+	offset = (cache_size / 4) + unconst;
+	size = (cache_size / 16) + unconst;
 
 	if (to_user) {
-		pr_info("attempting good copy_to_user with SLAB_USERCOPY\n");
-		if (copy_to_user((void __user *)user_addr, good_buf,
-				 cache_size)) {
+		pr_info("attempting good copy_to_user inside whitelist\n");
+		if (copy_to_user(user_addr, buf + offset, size)) {
 			pr_warn("copy_to_user failed unexpectedly?!\n");
 			goto free_user;
 		}
 
-		pr_info("attempting bad copy_to_user w/o SLAB_USERCOPY\n");
-		if (copy_to_user((void __user *)user_addr, bad_buf,
-				 cache_size)) {
+		pr_info("attempting bad copy_to_user outside whitelist\n");
+		if (copy_to_user(user_addr, buf + offset - 1, size)) {
 			pr_warn("copy_to_user failed, but lacked Oops\n");
 			goto free_user;
 		}
 	} else {
-		pr_info("attempting good copy_from_user with SLAB_USERCOPY\n");
-		if (copy_from_user(good_buf, (void __user *)user_addr,
-				   cache_size)) {
+		pr_info("attempting good copy_from_user inside whitelist\n");
+		if (copy_from_user(buf + offset, user_addr, size)) {
 			pr_warn("copy_from_user failed unexpectedly?!\n");
 			goto free_user;
 		}
 
-		pr_info("attempting bad copy_from_user w/o SLAB_USERCOPY\n");
-		if (copy_from_user(bad_buf, (void __user *)user_addr,
-				   cache_size)) {
+		pr_info("attempting bad copy_from_user outside whitelist\n");
+		if (copy_from_user(buf + offset - 1, user_addr, size)) {
 			pr_warn("copy_from_user failed, but lacked Oops\n");
 			goto free_user;
 		}
 	}
 
 free_user:
-	vm_munmap(user_addr, PAGE_SIZE);
+	vm_munmap(user_alloc, PAGE_SIZE);
 free_alloc:
-	if (bad_buf)
-		kmem_cache_free(bad_cache, bad_buf);
-	kfree(good_buf);
+	if (buf)
+		kmem_cache_free(whitelist_cache, buf);
 }
 
 /* Callable tests. */
@@ -261,14 +267,14 @@ void lkdtm_USERCOPY_HEAP_SIZE_FROM(void)
 	do_usercopy_heap_size(false);
 }
 
-void lkdtm_USERCOPY_HEAP_FLAG_TO(void)
+void lkdtm_USERCOPY_HEAP_WHITELIST_TO(void)
 {
-	do_usercopy_heap_flag(true);
+	do_usercopy_heap_whitelist(true);
 }
 
-void lkdtm_USERCOPY_HEAP_FLAG_FROM(void)
+void lkdtm_USERCOPY_HEAP_WHITELIST_FROM(void)
 {
-	do_usercopy_heap_flag(false);
+	do_usercopy_heap_whitelist(false);
 }
 
 void lkdtm_USERCOPY_STACK_FRAME_TO(void)
@@ -319,11 +325,15 @@ void lkdtm_USERCOPY_KERNEL(void)
 void __init lkdtm_usercopy_init(void)
 {
 	/* Prepare cache that lacks SLAB_USERCOPY flag. */
-	bad_cache = kmem_cache_create("lkdtm-no-usercopy", cache_size, 0,
-				      0, NULL);
+	whitelist_cache =
+		kmem_cache_create_usercopy("lkdtm-usercopy", cache_size,
+					   0, 0,
+					   cache_size / 4,
+					   cache_size / 16,
+					   NULL);
 }
 
 void __exit lkdtm_usercopy_exit(void)
 {
-	kmem_cache_destroy(bad_cache);
+	kmem_cache_destroy(whitelist_cache);
 }
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
