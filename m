Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id D67AF6B0031
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 03:47:48 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id kp14so4850350pab.37
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 00:47:48 -0800 (PST)
Received: from psmtp.com ([74.125.245.168])
        by mx.google.com with SMTP id bn4si9058385pad.253.2013.11.18.00.47.46
        for <linux-mm@kvack.org>;
        Mon, 18 Nov 2013 00:47:47 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] kernel/bounds: avoid circular dependencies in generated headers
Date: Mon, 18 Nov 2013 10:47:27 +0200
Message-Id: <1384764447-17832-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

<linux/spinlock.h> has havy dependencies on other header files.
It triggers circular dependencies in generated headers on IA64, at
least:

  CC      kernel/bounds.s
In file included from /home/space/kas/git/public/linux/arch/ia64/include/asm/thread_info.h:9:0,
                 from include/linux/thread_info.h:54,
                 from include/asm-generic/preempt.h:4,
                 from arch/ia64/include/generated/asm/preempt.h:1,
                 from include/linux/preempt.h:18,
                 from include/linux/spinlock.h:50,
                 from kernel/bounds.c:14:
/home/space/kas/git/public/linux/arch/ia64/include/asm/asm-offsets.h:1:35: fatal error: generated/asm-offsets.h: No such file or directory
compilation terminated.

Let's replace <linux/spinlock.h> with <linux/spinlock_types.h>, it's
enough to find out size of spinlock_t.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-and-Tested-by: Tony Luck <tony.luck@intel.com>
---
 kernel/bounds.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/bounds.c b/kernel/bounds.c
index 578782ef6ae1..5253204afdca 100644
--- a/kernel/bounds.c
+++ b/kernel/bounds.c
@@ -11,7 +11,7 @@
 #include <linux/kbuild.h>
 #include <linux/page_cgroup.h>
 #include <linux/log2.h>
-#include <linux/spinlock.h>
+#include <linux/spinlock_types.h>
 
 void foo(void)
 {
-- 
1.8.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
