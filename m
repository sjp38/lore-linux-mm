Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 433F96B0255
	for <linux-mm@kvack.org>; Sat, 30 Jan 2016 04:32:33 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id x125so55842758pfb.0
        for <linux-mm@kvack.org>; Sat, 30 Jan 2016 01:32:33 -0800 (PST)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id l81si30349640pfb.18.2016.01.30.01.32.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Jan 2016 01:32:32 -0800 (PST)
Date: Sat, 30 Jan 2016 01:31:24 -0800
From: tip-bot for Toshi Kani <tipbot@zytor.com>
Message-ID: <tip-bd7e6cb30ced147292d854a54d4a1f5c5a05d927@git.kernel.org>
Reply-To: mcgrof@suse.com, brgerst@gmail.com, dvlasenk@redhat.com,
        mingo@kernel.org, luto@amacapital.net, tglx@linutronix.de,
        bp@alien8.de, linux-mm@kvack.org, peterz@infradead.org,
        akpm@linux-foundation.org, bp@suse.de, linux-kernel@vger.kernel.org,
        hpa@zytor.com, jiang.liu@linux.intel.com, dan.j.williams@intel.com,
        jsitnicki@gmail.com, toshi.kani@hpe.com, toshi.kani@hp.com,
        torvalds@linux-foundation.org
In-Reply-To: <1453841853-11383-11-git-send-email-bp@alien8.de>
References: <1453841853-11383-11-git-send-email-bp@alien8.de>
Subject: [tip:core/resources] resource: Change walk_system_ram()
  to use System RAM type
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: tglx@linutronix.de, bp@alien8.de, peterz@infradead.org, linux-mm@kvack.org, mingo@kernel.org, luto@amacapital.net, dvlasenk@redhat.com, mcgrof@suse.com, brgerst@gmail.com, torvalds@linux-foundation.org, jsitnicki@gmail.com, dan.j.williams@intel.com, toshi.kani@hp.com, toshi.kani@hpe.com, hpa@zytor.com, jiang.liu@linux.intel.com, akpm@linux-foundation.org, bp@suse.de, linux-kernel@vger.kernel.org

Commit-ID:  bd7e6cb30ced147292d854a54d4a1f5c5a05d927
Gitweb:     http://git.kernel.org/tip/bd7e6cb30ced147292d854a54d4a1f5c5a05d927
Author:     Toshi Kani <toshi.kani@hpe.com>
AuthorDate: Tue, 26 Jan 2016 21:57:26 +0100
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Sat, 30 Jan 2016 09:49:58 +0100

resource: Change walk_system_ram() to use System RAM type

Now that all System RAM resource entries have been initialized
to IORESOURCE_SYSTEM_RAM type, change walk_system_ram_res() and
walk_system_ram_range() to call find_next_iomem_res() by setting
@res.flags to IORESOURCE_SYSTEM_RAM and @name to NULL. With this
change, they walk through the iomem table to find System RAM
ranges without the need to do strcmp() on the resource names.

No functional change is made to the interfaces.

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
[ Boris: fixup comments. ]
Signed-off-by: Borislav Petkov <bp@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Jakub Sitnicki <jsitnicki@gmail.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Toshi Kani <toshi.kani@hp.com>
Cc: linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>
Link: http://lkml.kernel.org/r/1453841853-11383-11-git-send-email-bp@alien8.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 kernel/resource.c | 26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/kernel/resource.c b/kernel/resource.c
index 61512e9..994f1e41 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -415,11 +415,11 @@ int walk_iomem_res(char *name, unsigned long flags, u64 start, u64 end,
 }
 
 /*
- * This function calls callback against all memory range of "System RAM"
- * which are marked as IORESOURCE_MEM and IORESOUCE_BUSY.
- * Now, this function is only for "System RAM". This function deals with
- * full ranges and not pfn. If resources are not pfn aligned, dealing
- * with pfn can truncate ranges.
+ * This function calls the @func callback against all memory ranges of type
+ * System RAM which are marked as IORESOURCE_SYSTEM_RAM and IORESOUCE_BUSY.
+ * Now, this function is only for System RAM, it deals with full ranges and
+ * not PFNs. If resources are not PFN-aligned, dealing with PFNs can truncate
+ * ranges.
  */
 int walk_system_ram_res(u64 start, u64 end, void *arg,
 				int (*func)(u64, u64, void *))
@@ -430,10 +430,10 @@ int walk_system_ram_res(u64 start, u64 end, void *arg,
 
 	res.start = start;
 	res.end = end;
-	res.flags = IORESOURCE_MEM | IORESOURCE_BUSY;
+	res.flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
 	orig_end = res.end;
 	while ((res.start < res.end) &&
-		(!find_next_iomem_res(&res, "System RAM", true))) {
+		(!find_next_iomem_res(&res, NULL, true))) {
 		ret = (*func)(res.start, res.end, arg);
 		if (ret)
 			break;
@@ -446,9 +446,9 @@ int walk_system_ram_res(u64 start, u64 end, void *arg,
 #if !defined(CONFIG_ARCH_HAS_WALK_MEMORY)
 
 /*
- * This function calls callback against all memory range of "System RAM"
- * which are marked as IORESOURCE_MEM and IORESOUCE_BUSY.
- * Now, this function is only for "System RAM".
+ * This function calls the @func callback against all memory ranges of type
+ * System RAM which are marked as IORESOURCE_SYSTEM_RAM and IORESOUCE_BUSY.
+ * It is to be used only for System RAM.
  */
 int walk_system_ram_range(unsigned long start_pfn, unsigned long nr_pages,
 		void *arg, int (*func)(unsigned long, unsigned long, void *))
@@ -460,10 +460,10 @@ int walk_system_ram_range(unsigned long start_pfn, unsigned long nr_pages,
 
 	res.start = (u64) start_pfn << PAGE_SHIFT;
 	res.end = ((u64)(start_pfn + nr_pages) << PAGE_SHIFT) - 1;
-	res.flags = IORESOURCE_MEM | IORESOURCE_BUSY;
+	res.flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
 	orig_end = res.end;
 	while ((res.start < res.end) &&
-		(find_next_iomem_res(&res, "System RAM", true) >= 0)) {
+		(find_next_iomem_res(&res, NULL, true) >= 0)) {
 		pfn = (res.start + PAGE_SIZE - 1) >> PAGE_SHIFT;
 		end_pfn = (res.end + 1) >> PAGE_SHIFT;
 		if (end_pfn > pfn)
@@ -484,7 +484,7 @@ static int __is_ram(unsigned long pfn, unsigned long nr_pages, void *arg)
 }
 /*
  * This generic page_is_ram() returns true if specified address is
- * registered as "System RAM" in iomem_resource list.
+ * registered as System RAM in iomem_resource list.
  */
 int __weak page_is_ram(unsigned long pfn)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
