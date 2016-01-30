Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id F2F126B0256
	for <linux-mm@kvack.org>; Sat, 30 Jan 2016 04:34:31 -0500 (EST)
Received: by mail-ig0-f182.google.com with SMTP id t15so5321771igr.0
        for <linux-mm@kvack.org>; Sat, 30 Jan 2016 01:34:31 -0800 (PST)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id k2si1860623igx.32.2016.01.30.01.34.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Jan 2016 01:34:31 -0800 (PST)
Date: Sat, 30 Jan 2016 01:33:33 -0800
From: tip-bot for Toshi Kani <tipbot@zytor.com>
Message-ID: <tip-a8fc42530ddd19d7580fe8c9f2ea86220a97e94c@git.kernel.org>
Reply-To: toshi.kani@hp.com, toshi.kani@hpe.com, akpm@linux-foundation.org,
        peterz@infradead.org, linux-kernel@vger.kernel.org, bp@suse.de,
        bp@alien8.de, dyoung@redhat.com, mingo@kernel.org,
        vinod.koul@intel.com, dvlasenk@redhat.com, brgerst@gmail.com,
        torvalds@linux-foundation.org, dan.j.williams@intel.com,
        linux-mm@kvack.org, tglx@linutronix.de, hpa@zytor.com,
        hanjun.guo@linaro.org, jsitnicki@gmail.com, luto@amacapital.net,
        jiang.liu@linux.intel.com, mcgrof@suse.com
In-Reply-To: <1453841853-11383-17-git-send-email-bp@alien8.de>
References: <1453841853-11383-17-git-send-email-bp@alien8.de>
Subject: [tip:core/resources] resource: Kill walk_iomem_res()
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: dyoung@redhat.com, mingo@kernel.org, bp@alien8.de, dvlasenk@redhat.com, vinod.koul@intel.com, akpm@linux-foundation.org, toshi.kani@hp.com, toshi.kani@hpe.com, bp@suse.de, linux-kernel@vger.kernel.org, peterz@infradead.org, hpa@zytor.com, tglx@linutronix.de, mcgrof@suse.com, jiang.liu@linux.intel.com, luto@amacapital.net, jsitnicki@gmail.com, hanjun.guo@linaro.org, dan.j.williams@intel.com, torvalds@linux-foundation.org, brgerst@gmail.com, linux-mm@kvack.org

Commit-ID:  a8fc42530ddd19d7580fe8c9f2ea86220a97e94c
Gitweb:     http://git.kernel.org/tip/a8fc42530ddd19d7580fe8c9f2ea86220a97e94c
Author:     Toshi Kani <toshi.kani@hpe.com>
AuthorDate: Tue, 26 Jan 2016 21:57:32 +0100
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Sat, 30 Jan 2016 09:49:59 +0100

resource: Kill walk_iomem_res()

walk_iomem_res_desc() replaced walk_iomem_res() and there is no
caller to walk_iomem_res() any more. Kill it. Also remove @name
from find_next_iomem_res() as it is no longer used.

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Signed-off-by: Borislav Petkov <bp@suse.de>
Acked-by: Dave Young <dyoung@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Hanjun Guo <hanjun.guo@linaro.org>
Cc: Jakub Sitnicki <jsitnicki@gmail.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Toshi Kani <toshi.kani@hp.com>
Cc: Vinod Koul <vinod.koul@intel.com>
Cc: linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>
Link: http://lkml.kernel.org/r/1453841853-11383-17-git-send-email-bp@alien8.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/ioport.h |  3 ---
 kernel/resource.c      | 49 +++++--------------------------------------------
 2 files changed, 5 insertions(+), 47 deletions(-)

diff --git a/include/linux/ioport.h b/include/linux/ioport.h
index 2a4a5e8..afb4559 100644
--- a/include/linux/ioport.h
+++ b/include/linux/ioport.h
@@ -270,9 +270,6 @@ walk_system_ram_res(u64 start, u64 end, void *arg,
 extern int
 walk_iomem_res_desc(unsigned long desc, unsigned long flags, u64 start, u64 end,
 		    void *arg, int (*func)(u64, u64, void *));
-extern int
-walk_iomem_res(char *name, unsigned long flags, u64 start, u64 end, void *arg,
-	       int (*func)(u64, u64, void *));
 
 /* True if any part of r1 overlaps r2 */
 static inline bool resource_overlaps(struct resource *r1, struct resource *r2)
diff --git a/kernel/resource.c b/kernel/resource.c
index 37ed2fc..4983430 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -335,13 +335,12 @@ EXPORT_SYMBOL(release_resource);
 /*
  * Finds the lowest iomem resource existing within [res->start.res->end).
  * The caller must specify res->start, res->end, res->flags, and optionally
- * desc and "name".  If found, returns 0, res is overwritten, if not found,
- * returns -1.
+ * desc.  If found, returns 0, res is overwritten, if not found, returns -1.
  * This function walks the whole tree and not just first level children until
  * and unless first_level_children_only is true.
  */
 static int find_next_iomem_res(struct resource *res, unsigned long desc,
-			       char *name, bool first_level_children_only)
+			       bool first_level_children_only)
 {
 	resource_size_t start, end;
 	struct resource *p;
@@ -363,8 +362,6 @@ static int find_next_iomem_res(struct resource *res, unsigned long desc,
 			continue;
 		if ((desc != IORES_DESC_NONE) && (desc != p->desc))
 			continue;
-		if (name && strcmp(p->name, name))
-			continue;
 		if (p->start > end) {
 			p = NULL;
 			break;
@@ -411,7 +408,7 @@ int walk_iomem_res_desc(unsigned long desc, unsigned long flags, u64 start,
 	orig_end = res.end;
 
 	while ((res.start < res.end) &&
-		(!find_next_iomem_res(&res, desc, NULL, false))) {
+		(!find_next_iomem_res(&res, desc, false))) {
 
 		ret = (*func)(res.start, res.end, arg);
 		if (ret)
@@ -425,42 +422,6 @@ int walk_iomem_res_desc(unsigned long desc, unsigned long flags, u64 start,
 }
 
 /*
- * Walks through iomem resources and calls @func with matching resource
- * ranges. This walks the whole tree and not just first level children.
- * All the memory ranges which overlap start,end and also match flags and
- * name are valid candidates.
- *
- * @name: name of resource
- * @flags: resource flags
- * @start: start addr
- * @end: end addr
- *
- * NOTE: This function is deprecated and should not be used in new code.
- * Use walk_iomem_res_desc(), instead.
- */
-int walk_iomem_res(char *name, unsigned long flags, u64 start, u64 end,
-		void *arg, int (*func)(u64, u64, void *))
-{
-	struct resource res;
-	u64 orig_end;
-	int ret = -1;
-
-	res.start = start;
-	res.end = end;
-	res.flags = flags;
-	orig_end = res.end;
-	while ((res.start < res.end) &&
-		(!find_next_iomem_res(&res, IORES_DESC_NONE, name, false))) {
-		ret = (*func)(res.start, res.end, arg);
-		if (ret)
-			break;
-		res.start = res.end + 1;
-		res.end = orig_end;
-	}
-	return ret;
-}
-
-/*
  * This function calls the @func callback against all memory ranges of type
  * System RAM which are marked as IORESOURCE_SYSTEM_RAM and IORESOUCE_BUSY.
  * Now, this function is only for System RAM, it deals with full ranges and
@@ -479,7 +440,7 @@ int walk_system_ram_res(u64 start, u64 end, void *arg,
 	res.flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
 	orig_end = res.end;
 	while ((res.start < res.end) &&
-		(!find_next_iomem_res(&res, IORES_DESC_NONE, NULL, true))) {
+		(!find_next_iomem_res(&res, IORES_DESC_NONE, true))) {
 		ret = (*func)(res.start, res.end, arg);
 		if (ret)
 			break;
@@ -509,7 +470,7 @@ int walk_system_ram_range(unsigned long start_pfn, unsigned long nr_pages,
 	res.flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
 	orig_end = res.end;
 	while ((res.start < res.end) &&
-		(find_next_iomem_res(&res, IORES_DESC_NONE, NULL, true) >= 0)) {
+		(find_next_iomem_res(&res, IORES_DESC_NONE, true) >= 0)) {
 		pfn = (res.start + PAGE_SIZE - 1) >> PAGE_SHIFT;
 		end_pfn = (res.end + 1) >> PAGE_SHIFT;
 		if (end_pfn > pfn)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
