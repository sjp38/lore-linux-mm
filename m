Received: by ik-out-1112.google.com with SMTP id b32so4226848ika.6
        for <linux-mm@kvack.org>; Sun, 15 Jun 2008 21:24:32 -0700 (PDT)
Date: Mon, 16 Jun 2008 12:25:28 +0800
From: Dave Young <hidave.darkstar@gmail.com>
Subject: [PATCH] kernel parameter vmalloc size fix
Message-ID: <20080616042528.GA3003@darkstar.te-china.tietoenator.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, mingo@elte.hu, hpa@zytor.com
List-ID: <linux-mm.kvack.org>

booting kernel with vmalloc=[any size<=16m] will oops.

It's due to the vm area hole.

In include/asm-x86/pgtable_32.h:
#define VMALLOC_OFFSET	(8 * 1024 * 1024)
#define VMALLOC_START	(((unsigned long)high_memory + 2 * VMALLOC_OFFSET - 1) \
			 & ~(VMALLOC_OFFSET - 1))

BUG_ON in arch/x86/mm/init_32.c will be triggered:
BUG_ON((unsigned long)high_memory		> VMALLOC_START);

Fixed by return -EINVAL for invalid parameter

Signed-off-by: Dave Young <hidave.darkstar@gmail.com>

Documentation/kernel-parameters.txt |    3 ++-
arch/x86/kernel/setup_32.c          |   11 +++++++++--
2 files changed, 11 insertions(+), 3 deletions(-)

diff -upr linux/Documentation/kernel-parameters.txt linux.new/Documentation/kernel-parameters.txt
--- linux/Documentation/kernel-parameters.txt	2008-06-16 11:30:29.000000000 +0800
+++ linux.new/Documentation/kernel-parameters.txt	2008-06-16 11:43:01.000000000 +0800
@@ -2139,7 +2139,8 @@ and is between 256 and 4096 characters. 
 			size of <nn>. This can be used to increase the
 			minimum size (128MB on x86). It can also be used to
 			decrease the size and leave more room for directly
-			mapped kernel RAM.
+			mapped kernel RAM. Note that the size must be bigger
+			than 16M now on i386 due to the memory hole.
 
 	vmhalt=		[KNL,S390] Perform z/VM CP command after system halt.
 			Format: <command>
diff -upr linux/arch/x86/kernel/setup_32.c linux.new/arch/x86/kernel/setup_32.c
--- linux/arch/x86/kernel/setup_32.c	2008-06-16 11:28:51.000000000 +0800
+++ linux.new/arch/x86/kernel/setup_32.c	2008-06-16 11:43:35.000000000 +0800
@@ -305,15 +305,22 @@ early_param("highmem", parse_highmem);
 
 /*
  * vmalloc=size forces the vmalloc area to be exactly 'size'
- * bytes. This can be used to increase (or decrease) the
+ * bytes. Now size must be bigger than 16m due to the memory hole.
+ * This can be used to increase (or decrease) the
  * vmalloc area - the default is 128m.
  */
 static int __init parse_vmalloc(char *arg)
 {
+	unsigned int v;
+
 	if (!arg)
 		return -EINVAL;
 
-	__VMALLOC_RESERVE = memparse(arg, &arg);
+	v = memparse(arg, &arg);
+	if (v <= 2 * VMALLOC_OFFSET)
+		return -EINVAL;
+	__VMALLOC_RESERVE = v;
+
 	return 0;
 }
 early_param("vmalloc", parse_vmalloc);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
