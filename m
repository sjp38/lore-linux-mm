Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id D297D6B0103
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 12:12:46 -0400 (EDT)
Message-ID: <517FED76.9030002@parallels.com>
Date: Tue, 30 Apr 2013 20:12:38 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [PATCH 5/5] pagemap: Prepare to reuse constant bits with page-shitf
References: <517FED13.8090806@parallels.com>
In-Reply-To: <517FED13.8090806@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Matt Mackall <mpm@selenic.com>, Marcelo Tosatti <mtosatti@redhat.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

In order to reuse bits from pagemap entries gracefully, we leave the entries as
is but on pagemap open emit a warning in dmesg, that bits 55-60 are about to change
in a couple of releases. Next, if a user issues soft-dirty clear command via the
clear_refs file (it was disabled before v3.9) we assume that he's aware of the new
pagemap format, note that fact and report the bits in pagemap in the new manner.

The "migration strategy" looks like this then:

1. existing users are not affected -- they don't touch soft-dirty feature, thus
   see old bits in pagemap, but are warned and have time to fix themselves
2. those who use soft-dirty know about new pagemap format
3. some time soon we get rid of any signs of page-shift in pagemap as well as
   this trick with clear-soft-dirty affecting pagemap format.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matt Mackall <mpm@selenic.com>
Cc: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Glauber Costa <glommer@parallels.com>
Cc: Marcelo Tosatti <mtosatti@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
---
 Documentation/vm/pagemap.txt |    3 ++-
 fs/proc/task_mmu.c           |   35 ++++++++++++++++++++++++++++++++++-
 2 files changed, 36 insertions(+), 2 deletions(-)

diff --git a/Documentation/vm/pagemap.txt b/Documentation/vm/pagemap.txt
index 7587493..fd7c3cf 100644
--- a/Documentation/vm/pagemap.txt
+++ b/Documentation/vm/pagemap.txt
@@ -15,7 +15,8 @@ There are three components to pagemap:
     * Bits 0-54  page frame number (PFN) if present
     * Bits 0-4   swap type if swapped
     * Bits 5-54  swap offset if swapped
-    * Bits 55-60 page shift (page size = 1<<page shift)
+    * Bit  55    pte is soft-dirty (see Documentation/vm/soft-dirty.txt)
+    * Bits 56-60 zero
     * Bit  61    page is file-page or shared-anon
     * Bit  62    page swapped
     * Bit  63    page present
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 9238acb..27453c0 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -688,6 +688,23 @@ const struct file_operations proc_tid_smaps_operations = {
 	.release	= seq_release_private,
 };
 
+/*
+ * We do not want to have constant page-shift bits sitting in
+ * pagemap entries and are about to reuse them some time soon.
+ *
+ * Here's the "migration strategy":
+ * 1. when the system boots these bits remain what they are,
+ *    but a warning about future change is printed in log;
+ * 2. once anyone clears soft-dirty bits via clear_refs file,
+ *    these flag is set to denote, that user is aware of the
+ *    new API and those page-shift bits change their meaning.
+ *    The respective warning is printed in dmesg;
+ * 3. In a couple of releases we will remove all the mentions
+ *    of page-shift in pagemap entries.
+ */
+
+static bool soft_dirty_cleared __read_mostly;
+
 enum clear_refs_types {
 	CLEAR_REFS_ALL = 1,
 	CLEAR_REFS_ANON,
@@ -777,6 +794,13 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 	type = (enum clear_refs_types)itype;
 	if (type < CLEAR_REFS_ALL || type >= CLEAR_REFS_LAST)
 		return -EINVAL;
+
+	if (type == CLEAR_REFS_SOFT_DIRTY) {
+		soft_dirty_cleared = true;
+		pr_warn_once("The pagemap bits 55-60 has changed their meaning! "
+				"See the linux/Documentation/vm/pagemap.txt for details.\n");
+	}
+
 	task = get_proc_task(file_inode(file));
 	if (!task)
 		return -ESRCH;
@@ -1086,7 +1110,7 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
 	if (!count)
 		goto out_task;
 
-	pm.v2 = false;
+	pm.v2 = soft_dirty_cleared;
 	pm.len = PM_ENTRY_BYTES * (PAGEMAP_WALK_SIZE >> PAGE_SHIFT);
 	pm.buffer = kmalloc(pm.len, GFP_TEMPORARY);
 	ret = -ENOMEM;
@@ -1159,9 +1183,18 @@ out:
 	return ret;
 }
 
+static int pagemap_open(struct inode *inode, struct file *file)
+{
+	pr_warn_once("Bits 55-60 of /proc/PID/pagemap entries are about "
+			"to stop being page-shift some time soon. See the "
+			"linux/Documentation/vm/pagemap.txt for details.\n");
+	return 0;
+}
+
 const struct file_operations proc_pagemap_operations = {
 	.llseek		= mem_lseek, /* borrow this */
 	.read		= pagemap_read,
+	.open		= pagemap_open,
 };
 #endif /* CONFIG_PROC_PAGE_MONITOR */
 
-- 
1.7.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
