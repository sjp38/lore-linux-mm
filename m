Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id 8093B6B0259
	for <linux-mm@kvack.org>; Sat, 30 Jan 2016 04:33:24 -0500 (EST)
Received: by mail-yk0-f181.google.com with SMTP id r207so52829985ykd.2
        for <linux-mm@kvack.org>; Sat, 30 Jan 2016 01:33:24 -0800 (PST)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id o132si4596295ywo.47.2016.01.30.01.33.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Jan 2016 01:33:23 -0800 (PST)
Date: Sat, 30 Jan 2016 01:32:29 -0800
From: tip-bot for Toshi Kani <tipbot@zytor.com>
Message-ID: <tip-3f33647c41962401272bb60dce67e6094d14dbf2@git.kernel.org>
Reply-To: luto@amacapital.net, brgerst@gmail.com, jiang.liu@linux.intel.com,
        jsitnicki@gmail.com, rafael.j.wysocki@intel.com, mcgrof@suse.com,
        linux-kernel@vger.kernel.org, toshi.kani@hp.com,
        akpm@linux-foundation.org, linux-mm@kvack.org, dvlasenk@redhat.com,
        mingo@kernel.org, bp@suse.de, hanjun.guo@linaro.org,
        toshi.kani@hpe.com, dan.j.williams@intel.com, peterz@infradead.org,
        bp@alien8.de, hpa@zytor.com, torvalds@linux-foundation.org,
        tglx@linutronix.de
In-Reply-To: <1453841853-11383-14-git-send-email-bp@alien8.de>
References: <1453841853-11383-14-git-send-email-bp@alien8.de>
Subject: [tip:core/resources] resource: Add walk_iomem_res_desc()
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: dan.j.williams@intel.com, torvalds@linux-foundation.org, tglx@linutronix.de, bp@alien8.de, hpa@zytor.com, peterz@infradead.org, bp@suse.de, toshi.kani@hpe.com, hanjun.guo@linaro.org, linux-kernel@vger.kernel.org, dvlasenk@redhat.com, mingo@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, toshi.kani@hp.com, jsitnicki@gmail.com, jiang.liu@linux.intel.com, brgerst@gmail.com, luto@amacapital.net, mcgrof@suse.com, rafael.j.wysocki@intel.com

Commit-ID:  3f33647c41962401272bb60dce67e6094d14dbf2
Gitweb:     http://git.kernel.org/tip/3f33647c41962401272bb60dce67e6094d14dbf2
Author:     Toshi Kani <toshi.kani@hpe.com>
AuthorDate: Tue, 26 Jan 2016 21:57:29 +0100
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Sat, 30 Jan 2016 09:49:59 +0100

resource: Add walk_iomem_res_desc()

Add a new interface, walk_iomem_res_desc(), which walks through
the iomem table by identifying a target with @flags and @desc.
This interface provides the same functionality as
walk_iomem_res(), but does not use strcmp() to @name for better
efficiency.

walk_iomem_res() is deprecated and will be removed in a later
patch.

Requested-by: Borislav Petkov <bp@suse.de>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
[ Fixup comments. ]
Signed-off-by: Borislav Petkov <bp@suse.de>
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
Cc: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Toshi Kani <toshi.kani@hp.com>
Cc: linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>
Link: http://lkml.kernel.org/r/1453841853-11383-14-git-send-email-bp@alien8.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/ioport.h |  3 +++
 kernel/resource.c      | 66 ++++++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 59 insertions(+), 10 deletions(-)

diff --git a/include/linux/ioport.h b/include/linux/ioport.h
index 983bea0..2a4a5e8 100644
--- a/include/linux/ioport.h
+++ b/include/linux/ioport.h
@@ -268,6 +268,9 @@ extern int
 walk_system_ram_res(u64 start, u64 end, void *arg,
 		    int (*func)(u64, u64, void *));
 extern int
+walk_iomem_res_desc(unsigned long desc, unsigned long flags, u64 start, u64 end,
+		    void *arg, int (*func)(u64, u64, void *));
+extern int
 walk_iomem_res(char *name, unsigned long flags, u64 start, u64 end, void *arg,
 	       int (*func)(u64, u64, void *));
 
diff --git a/kernel/resource.c b/kernel/resource.c
index 0041ced..37ed2fc 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -333,14 +333,15 @@ int release_resource(struct resource *old)
 EXPORT_SYMBOL(release_resource);
 
 /*
- * Finds the lowest iomem reosurce exists with-in [res->start.res->end)
- * the caller must specify res->start, res->end, res->flags and "name".
- * If found, returns 0, res is overwritten, if not found, returns -1.
- * This walks through whole tree and not just first level children
- * until and unless first_level_children_only is true.
+ * Finds the lowest iomem resource existing within [res->start.res->end).
+ * The caller must specify res->start, res->end, res->flags, and optionally
+ * desc and "name".  If found, returns 0, res is overwritten, if not found,
+ * returns -1.
+ * This function walks the whole tree and not just first level children until
+ * and unless first_level_children_only is true.
  */
-static int find_next_iomem_res(struct resource *res, char *name,
-			       bool first_level_children_only)
+static int find_next_iomem_res(struct resource *res, unsigned long desc,
+			       char *name, bool first_level_children_only)
 {
 	resource_size_t start, end;
 	struct resource *p;
@@ -360,6 +361,8 @@ static int find_next_iomem_res(struct resource *res, char *name,
 	for (p = iomem_resource.child; p; p = next_resource(p, sibling_only)) {
 		if ((p->flags & res->flags) != res->flags)
 			continue;
+		if ((desc != IORES_DESC_NONE) && (desc != p->desc))
+			continue;
 		if (name && strcmp(p->name, name))
 			continue;
 		if (p->start > end) {
@@ -385,12 +388,55 @@ static int find_next_iomem_res(struct resource *res, char *name,
  * Walks through iomem resources and calls func() with matching resource
  * ranges. This walks through whole tree and not just first level children.
  * All the memory ranges which overlap start,end and also match flags and
+ * desc are valid candidates.
+ *
+ * @desc: I/O resource descriptor. Use IORES_DESC_NONE to skip @desc check.
+ * @flags: I/O resource flags
+ * @start: start addr
+ * @end: end addr
+ *
+ * NOTE: For a new descriptor search, define a new IORES_DESC in
+ * <linux/ioport.h> and set it in 'desc' of a target resource entry.
+ */
+int walk_iomem_res_desc(unsigned long desc, unsigned long flags, u64 start,
+		u64 end, void *arg, int (*func)(u64, u64, void *))
+{
+	struct resource res;
+	u64 orig_end;
+	int ret = -1;
+
+	res.start = start;
+	res.end = end;
+	res.flags = flags;
+	orig_end = res.end;
+
+	while ((res.start < res.end) &&
+		(!find_next_iomem_res(&res, desc, NULL, false))) {
+
+		ret = (*func)(res.start, res.end, arg);
+		if (ret)
+			break;
+
+		res.start = res.end + 1;
+		res.end = orig_end;
+	}
+
+	return ret;
+}
+
+/*
+ * Walks through iomem resources and calls @func with matching resource
+ * ranges. This walks the whole tree and not just first level children.
+ * All the memory ranges which overlap start,end and also match flags and
  * name are valid candidates.
  *
  * @name: name of resource
  * @flags: resource flags
  * @start: start addr
  * @end: end addr
+ *
+ * NOTE: This function is deprecated and should not be used in new code.
+ * Use walk_iomem_res_desc(), instead.
  */
 int walk_iomem_res(char *name, unsigned long flags, u64 start, u64 end,
 		void *arg, int (*func)(u64, u64, void *))
@@ -404,7 +450,7 @@ int walk_iomem_res(char *name, unsigned long flags, u64 start, u64 end,
 	res.flags = flags;
 	orig_end = res.end;
 	while ((res.start < res.end) &&
-		(!find_next_iomem_res(&res, name, false))) {
+		(!find_next_iomem_res(&res, IORES_DESC_NONE, name, false))) {
 		ret = (*func)(res.start, res.end, arg);
 		if (ret)
 			break;
@@ -433,7 +479,7 @@ int walk_system_ram_res(u64 start, u64 end, void *arg,
 	res.flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
 	orig_end = res.end;
 	while ((res.start < res.end) &&
-		(!find_next_iomem_res(&res, NULL, true))) {
+		(!find_next_iomem_res(&res, IORES_DESC_NONE, NULL, true))) {
 		ret = (*func)(res.start, res.end, arg);
 		if (ret)
 			break;
@@ -463,7 +509,7 @@ int walk_system_ram_range(unsigned long start_pfn, unsigned long nr_pages,
 	res.flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
 	orig_end = res.end;
 	while ((res.start < res.end) &&
-		(find_next_iomem_res(&res, NULL, true) >= 0)) {
+		(find_next_iomem_res(&res, IORES_DESC_NONE, NULL, true) >= 0)) {
 		pfn = (res.start + PAGE_SIZE - 1) >> PAGE_SHIFT;
 		end_pfn = (res.end + 1) >> PAGE_SHIFT;
 		if (end_pfn > pfn)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
