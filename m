Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 8E14E6B0006
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 07:29:45 -0400 (EDT)
Message-ID: <51669EA5.20209@parallels.com>
Date: Thu, 11 Apr 2013 15:29:41 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [PATCH 4/5] pagemap: Introduce the /proc/PID/pagemap2 file
References: <51669E5F.4000801@parallels.com>
In-Reply-To: <51669E5F.4000801@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

This file is the same as the pagemap one, but shows entries with bits
55-60 being zero (reserved for future use). Next patch will occupy one
of them.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
---
 Documentation/filesystems/proc.txt |    2 ++
 Documentation/vm/pagemap.txt       |    3 +++
 fs/proc/base.c                     |    2 ++
 fs/proc/internal.h                 |    1 +
 fs/proc/task_mmu.c                 |   11 +++++++++++
 5 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index fd8d0d5..22c47ec 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -487,6 +487,8 @@ Any other value written to /proc/PID/clear_refs will have no effect.
 The /proc/pid/pagemap gives the PFN, which can be used to find the pageflags
 using /proc/kpageflags and number of times a page is mapped using
 /proc/kpagecount. For detailed explanation, see Documentation/vm/pagemap.txt.
+(There's also a /proc/pid/pagemap2 file which is the 2nd version of the
+ pagemap one).
 
 1.2 Kernel data
 ---------------
diff --git a/Documentation/vm/pagemap.txt b/Documentation/vm/pagemap.txt
index 7587493..4350397 100644
--- a/Documentation/vm/pagemap.txt
+++ b/Documentation/vm/pagemap.txt
@@ -30,6 +30,9 @@ There are three components to pagemap:
    determine which areas of memory are actually mapped and llseek to
    skip over unmapped regions.
 
+ * /proc/pid/pagemap2.  This file provides the same info as the pagemap
+   does, but bits 55-60 are reserved for future use and thus zero
+
  * /proc/kpagecount.  This file contains a 64-bit count of the number of
    times each page is mapped, indexed by PFN.
 
diff --git a/fs/proc/base.c b/fs/proc/base.c
index 69078c7..34966ce 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2537,6 +2537,7 @@ static const struct pid_entry tgid_base_stuff[] = {
 	REG("clear_refs", S_IWUSR, proc_clear_refs_operations),
 	REG("smaps",      S_IRUGO, proc_pid_smaps_operations),
 	REG("pagemap",    S_IRUGO, proc_pagemap_operations),
+	REG("pagemap2",   S_IRUGO, proc_pagemap2_operations),
 #endif
 #ifdef CONFIG_SECURITY
 	DIR("attr",       S_IRUGO|S_IXUGO, proc_attr_dir_inode_operations, proc_attr_dir_operations),
@@ -2882,6 +2883,7 @@ static const struct pid_entry tid_base_stuff[] = {
 	REG("clear_refs", S_IWUSR, proc_clear_refs_operations),
 	REG("smaps",     S_IRUGO, proc_tid_smaps_operations),
 	REG("pagemap",    S_IRUGO, proc_pagemap_operations),
+	REG("pagemap2",   S_IRUGO, proc_pagemap2_operations),
 #endif
 #ifdef CONFIG_SECURITY
 	DIR("attr",      S_IRUGO|S_IXUGO, proc_attr_dir_inode_operations, proc_attr_dir_operations),
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 85ff3a4..cc12bb7 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -67,6 +67,7 @@ extern const struct file_operations proc_pid_smaps_operations;
 extern const struct file_operations proc_tid_smaps_operations;
 extern const struct file_operations proc_clear_refs_operations;
 extern const struct file_operations proc_pagemap_operations;
+extern const struct file_operations proc_pagemap2_operations;
 extern const struct file_operations proc_net_operations;
 extern const struct inode_operations proc_net_inode_operations;
 extern const struct inode_operations proc_pid_link_inode_operations;
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 7f9b66c..3138009 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1135,6 +1135,17 @@ const struct file_operations proc_pagemap_operations = {
 	.llseek		= mem_lseek, /* borrow this */
 	.read		= pagemap_read,
 };
+
+static ssize_t pagemap2_read(struct file *file, char __user *buf,
+			    size_t count, loff_t *ppos)
+{
+	return do_pagemap_read(file, buf, count, ppos, true);
+}
+
+const struct file_operations proc_pagemap2_operations = {
+	.llseek		= mem_lseek, /* borrow this */
+	.read		= pagemap2_read,
+};
 #endif /* CONFIG_PROC_PAGE_MONITOR */
 
 #ifdef CONFIG_NUMA
-- 
1.7.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
