Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 245596B0033
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 01:48:00 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id ld10so1864580pab.8
        for <linux-mm@kvack.org>; Thu, 29 Aug 2013 22:47:59 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH] x86: e820: fix memmap kernel boot parameter
Date: Fri, 30 Aug 2013 13:47:53 +0800
Message-Id: <1377841673-17361-1-git-send-email-bob.liu@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, hpa@linux.intel.com, yinghai@kernel.org, jacob.shin@amd.com, konrad.wilk@oracle.com, linux-mm@kvack.org, Bob Liu <bob.liu@oracle.com>

Kernel boot parameter memmap=nn[KMG]$ss[KMG] is used to mark specific memory as
reserved. Region of memory to be used is from ss to ss+nn.

But I found the action of this parameter is not as expected.
I tried on two machines.
Machine1: bootcmdline in grub.cfg "memmap=800M$0x60bfdfff", but the result of
"cat /proc/cmdline" changed to "memmap=800M/bin/bashx60bfdfff" after system
booted.

Machine2: bootcmdline in grub.cfg "memmap=0x77ffffff$0x880000000", the result of
"cat /proc/cmdline" changed to "memmap=0x77ffffffx880000000".

I didn't find the root cause, I think maybe grub reserved "$0" as something
special.
Replace '$' with '%' in kernel boot parameter can fix this issue.

Signed-off-by: Bob Liu <bob.liu@oracle.com>
---
 Documentation/kernel-parameters.txt |    6 +++---
 arch/x86/kernel/e820.c              |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 7f9d4f5..a96c7b1 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1604,13 +1604,13 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			[KNL,ACPI] Mark specific memory as ACPI data.
 			Region of memory to be used, from ss to ss+nn.
 
-	memmap=nn[KMG]$ss[KMG]
+	memmap=nn[KMG]%ss[KMG]
 			[KNL,ACPI] Mark specific memory as reserved.
 			Region of memory to be used, from ss to ss+nn.
 			Example: Exclude memory from 0x18690000-0x1869ffff
-			         memmap=64K$0x18690000
+			         memmap=64K%0x18690000
 			         or
-			         memmap=0x10000$0x18690000
+			         memmap=0x10000%0x18690000
 
 	memory_corruption_check=0/1 [X86]
 			Some BIOSes seem to corrupt the first 64k of
diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index d32abea..8483d45 100644
--- a/arch/x86/kernel/e820.c
+++ b/arch/x86/kernel/e820.c
@@ -869,7 +869,7 @@ static int __init parse_memmap_one(char *p)
 	} else if (*p == '#') {
 		start_at = memparse(p+1, &p);
 		e820_add_region(start_at, mem_size, E820_ACPI);
-	} else if (*p == '$') {
+	} else if (*p == '%') {
 		start_at = memparse(p+1, &p);
 		e820_add_region(start_at, mem_size, E820_RESERVED);
 	} else
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
