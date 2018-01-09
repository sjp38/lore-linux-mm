Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C81676B0033
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 15:56:51 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id i1so9335960pgv.22
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 12:56:51 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r8sor3940077pfk.109.2018.01.09.12.56.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Jan 2018 12:56:50 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 03/36] lkdtm/usercopy: Adjust test to include an offset to check reporting
Date: Tue,  9 Jan 2018 12:55:32 -0800
Message-Id: <1515531365-37423-4-git-send-email-keescook@chromium.org>
In-Reply-To: <1515531365-37423-1-git-send-email-keescook@chromium.org>
References: <1515531365-37423-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Windsor <dave@nullcore.net>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

Instead of doubling the size, push the start position up by 16 bytes to
still trigger an overflow. This allows to verify that offset reporting
is working correctly.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/misc/lkdtm_usercopy.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/misc/lkdtm_usercopy.c b/drivers/misc/lkdtm_usercopy.c
index a64372cc148d..9ebbb031e5e3 100644
--- a/drivers/misc/lkdtm_usercopy.c
+++ b/drivers/misc/lkdtm_usercopy.c
@@ -119,6 +119,8 @@ static void do_usercopy_heap_size(bool to_user)
 {
 	unsigned long user_addr;
 	unsigned char *one, *two;
+	void __user *test_user_addr;
+	void *test_kern_addr;
 	size_t size = unconst + 1024;
 
 	one = kmalloc(size, GFP_KERNEL);
@@ -139,27 +141,30 @@ static void do_usercopy_heap_size(bool to_user)
 	memset(one, 'A', size);
 	memset(two, 'B', size);
 
+	test_user_addr = (void __user *)(user_addr + 16);
+	test_kern_addr = one + 16;
+
 	if (to_user) {
 		pr_info("attempting good copy_to_user of correct size\n");
-		if (copy_to_user((void __user *)user_addr, one, size)) {
+		if (copy_to_user(test_user_addr, test_kern_addr, size / 2)) {
 			pr_warn("copy_to_user failed unexpectedly?!\n");
 			goto free_user;
 		}
 
 		pr_info("attempting bad copy_to_user of too large size\n");
-		if (copy_to_user((void __user *)user_addr, one, 2 * size)) {
+		if (copy_to_user(test_user_addr, test_kern_addr, size)) {
 			pr_warn("copy_to_user failed, but lacked Oops\n");
 			goto free_user;
 		}
 	} else {
 		pr_info("attempting good copy_from_user of correct size\n");
-		if (copy_from_user(one, (void __user *)user_addr, size)) {
+		if (copy_from_user(test_kern_addr, test_user_addr, size / 2)) {
 			pr_warn("copy_from_user failed unexpectedly?!\n");
 			goto free_user;
 		}
 
 		pr_info("attempting bad copy_from_user of too large size\n");
-		if (copy_from_user(one, (void __user *)user_addr, 2 * size)) {
+		if (copy_from_user(test_kern_addr, test_user_addr, size)) {
 			pr_warn("copy_from_user failed, but lacked Oops\n");
 			goto free_user;
 		}
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
