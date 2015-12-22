Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 6FD3D6B000D
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 22:41:11 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id uo6so5040909pac.1
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 19:41:11 -0800 (PST)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id q79si1462218pfi.238.2015.12.21.19.41.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Dec 2015 19:41:03 -0800 (PST)
Received: by mail-pa0-x22a.google.com with SMTP id uo6so5039425pac.1
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 19:41:03 -0800 (PST)
From: Laura Abbott <laura@labbott.name>
Subject: [RFC][PATCH 7/7] lkdtm: Add READ_AFTER_FREE test
Date: Mon, 21 Dec 2015 19:40:41 -0800
Message-Id: <1450755641-7856-8-git-send-email-laura@labbott.name>
In-Reply-To: <1450755641-7856-1-git-send-email-laura@labbott.name>
References: <1450755641-7856-1-git-send-email-laura@labbott.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Laura Abbott <laura@labbott.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>, kernel-hardening@lists.openwall.com, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>


In a similar manner to WRITE_AFTER_FREE, add a READ_AFTER_FREE
test to test free poisoning features. Sample output when
no poison is present:

[   20.222501] lkdtm: Performing direct entry READ_AFTER_FREE
[   20.226163] lkdtm: Freed val: 12345678

with poison:

[   24.203748] lkdtm: Performing direct entry READ_AFTER_FREE
[   24.207261] general protection fault: 0000 [#1] SMP
[   24.208193] Modules linked in:
[   24.208193] CPU: 0 PID: 866 Comm: sh Not tainted 4.4.0-rc5-work+ #108

Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Signed-off-by: Laura Abbott <laura@labbott.name>
---
 drivers/misc/lkdtm.c | 29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/drivers/misc/lkdtm.c b/drivers/misc/lkdtm.c
index 11fdadc..c641fb7 100644
--- a/drivers/misc/lkdtm.c
+++ b/drivers/misc/lkdtm.c
@@ -92,6 +92,7 @@ enum ctype {
 	CT_UNALIGNED_LOAD_STORE_WRITE,
 	CT_OVERWRITE_ALLOCATION,
 	CT_WRITE_AFTER_FREE,
+	CT_READ_AFTER_FREE,
 	CT_SOFTLOCKUP,
 	CT_HARDLOCKUP,
 	CT_SPINLOCKUP,
@@ -129,6 +130,7 @@ static char* cp_type[] = {
 	"UNALIGNED_LOAD_STORE_WRITE",
 	"OVERWRITE_ALLOCATION",
 	"WRITE_AFTER_FREE",
+	"READ_AFTER_FREE",
 	"SOFTLOCKUP",
 	"HARDLOCKUP",
 	"SPINLOCKUP",
@@ -417,6 +419,33 @@ static void lkdtm_do_action(enum ctype which)
 		memset(data, 0x78, len);
 		break;
 	}
+	case CT_READ_AFTER_FREE: {
+		int **base;
+		int *val, *tmp;
+
+		base = kmalloc(1024, GFP_KERNEL);
+		if (!base)
+			return;
+
+		val = kmalloc(1024, GFP_KERNEL);
+		if (!val)
+			return;
+
+		*val = 0x12345678;
+
+		/*
+		 * Don't just use the first entry since that's where the
+		 * freelist goes for the slab allocator
+		 */
+		base[1] = val;
+		kfree(base);
+
+		tmp = base[1];
+		pr_info("Freed val: %x\n", *tmp);
+
+		kfree(val);
+		break;
+	}
 	case CT_SOFTLOCKUP:
 		preempt_disable();
 		for (;;)
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
