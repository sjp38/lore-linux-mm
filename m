Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 260786B0278
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 14:56:40 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id t93so260732306ioi.0
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 11:56:40 -0800 (PST)
Received: from p3plsmtps2ded03.prod.phx3.secureserver.net (p3plsmtps2ded03.prod.phx3.secureserver.net. [208.109.80.60])
        by mx.google.com with ESMTPS id 65si41607483iou.39.2016.11.28.11.56.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 11:56:39 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH v3 01/33] radix tree test suite: Fix compilation
Date: Mon, 28 Nov 2016 13:50:39 -0800
Message-Id: <1480369871-5271-36-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Patch "lib/radix-tree: Convert to hotplug state machine" breaks the
test suite as it adds a call to cpuhp_setup_state_nocalls() which is
not currently emulated in the test suite.  Add it, and delete the
emulation of the old CPU hotplug mechanism.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 lib/radix-tree.c                          |  1 -
 tools/testing/radix-tree/linux/cpu.h      | 22 +---------------------
 tools/testing/radix-tree/linux/notifier.h |  8 --------
 3 files changed, 1 insertion(+), 30 deletions(-)
 delete mode 100644 tools/testing/radix-tree/linux/notifier.h

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 2e8c6f7..e0290d1 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -30,7 +30,6 @@
 #include <linux/percpu.h>
 #include <linux/slab.h>
 #include <linux/kmemleak.h>
-#include <linux/notifier.h>
 #include <linux/cpu.h>
 #include <linux/string.h>
 #include <linux/bitops.h>
diff --git a/tools/testing/radix-tree/linux/cpu.h b/tools/testing/radix-tree/linux/cpu.h
index 7cf4121..a45530d 100644
--- a/tools/testing/radix-tree/linux/cpu.h
+++ b/tools/testing/radix-tree/linux/cpu.h
@@ -1,21 +1 @@
-
-#define hotcpu_notifier(a, b)
-
-#define CPU_ONLINE		0x0002 /* CPU (unsigned)v is up */
-#define CPU_UP_PREPARE		0x0003 /* CPU (unsigned)v coming up */
-#define CPU_UP_CANCELED		0x0004 /* CPU (unsigned)v NOT coming up */
-#define CPU_DOWN_PREPARE	0x0005 /* CPU (unsigned)v going down */
-#define CPU_DOWN_FAILED		0x0006 /* CPU (unsigned)v NOT going down */
-#define CPU_DEAD		0x0007 /* CPU (unsigned)v dead */
-#define CPU_POST_DEAD		0x0009 /* CPU (unsigned)v dead, cpu_hotplug
-					* lock is dropped */
-#define CPU_BROKEN		0x000C /* CPU (unsigned)v did not die properly,
-					* perhaps due to preemption. */
-#define CPU_TASKS_FROZEN	0x0010
-
-#define CPU_ONLINE_FROZEN	(CPU_ONLINE | CPU_TASKS_FROZEN)
-#define CPU_UP_PREPARE_FROZEN	(CPU_UP_PREPARE | CPU_TASKS_FROZEN)
-#define CPU_UP_CANCELED_FROZEN  (CPU_UP_CANCELED | CPU_TASKS_FROZEN)
-#define CPU_DOWN_PREPARE_FROZEN (CPU_DOWN_PREPARE | CPU_TASKS_FROZEN)
-#define CPU_DOWN_FAILED_FROZEN  (CPU_DOWN_FAILED | CPU_TASKS_FROZEN)
-#define CPU_DEAD_FROZEN		(CPU_DEAD | CPU_TASKS_FROZEN)
+#define cpuhp_setup_state_nocalls(a, b, c, d)	(0)
diff --git a/tools/testing/radix-tree/linux/notifier.h b/tools/testing/radix-tree/linux/notifier.h
deleted file mode 100644
index 70e4797..0000000
--- a/tools/testing/radix-tree/linux/notifier.h
+++ /dev/null
@@ -1,8 +0,0 @@
-#ifndef _NOTIFIER_H
-#define _NOTIFIER_H
-
-struct notifier_block;
-
-#define NOTIFY_OK              0x0001          /* Suits me */
-
-#endif
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
