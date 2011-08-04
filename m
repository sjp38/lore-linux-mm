Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B795D6B0169
	for <linux-mm@kvack.org>; Thu,  4 Aug 2011 18:22:14 -0400 (EDT)
Date: Thu, 4 Aug 2011 15:22:11 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
Subject: [PATCH -next] drivers/base/inode.c: let vmstat_text be optional
Message-Id: <20110804152211.ea10e3e7.rdunlap@xenotime.net>
In-Reply-To: <20110804145834.3b1d92a9eeb8357deb84bf83@canb.auug.org.au>
References: <20110804145834.3b1d92a9eeb8357deb84bf83@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>, Amerigo Wang <amwang@redhat.com>, gregkh@suse.de
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, akpm <akpm@linux-foundation.org>

From: Randy Dunlap <rdunlap@xenotime.net>

vmstat_text is only available when PROC_FS or SYSFS is enabled.
This causes build errors in drivers/base/node.c when they are
both disabled:

drivers/built-in.o: In function `node_read_vmstat':
node.c:(.text+0x10e28f): undefined reference to `vmstat_text'

Rather than litter drivers/base/node.c with #ifdef/#endif around
the affected lines of code, add macros for optional sysdev
attributes so that those lines of code will be ignored, without
using #ifdef/#endif in the .c file(s).  I.e., the ifdeffery
is done only in a header file with sysdev_create_file_optional()
and sysdev_remove_file_optional().

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 drivers/base/node.c    |    6 ++++--
 include/linux/sysdev.h |   14 ++++++++++++++
 include/linux/vmstat.h |    2 ++
 3 files changed, 20 insertions(+), 2 deletions(-)

--- linux-next-20110804.orig/include/linux/vmstat.h
+++ linux-next-20110804/include/linux/vmstat.h
@@ -258,6 +258,8 @@ static inline void refresh_zone_stat_thr
 
 #endif		/* CONFIG_SMP */
 
+#if defined(CONFIG_PROC_FS) || defined(CONFIG_SYSFS)
 extern const char * const vmstat_text[];
+#endif
 
 #endif /* _LINUX_VMSTAT_H */
--- linux-next-20110804.orig/drivers/base/node.c
+++ linux-next-20110804/drivers/base/node.c
@@ -176,6 +176,7 @@ static ssize_t node_read_numastat(struct
 }
 static SYSDEV_ATTR(numastat, S_IRUGO, node_read_numastat, NULL);
 
+#if defined(CONFIG_PROC_FS) || defined(CONFIG_SYSFS)
 static ssize_t node_read_vmstat(struct sys_device *dev,
 				struct sysdev_attribute *attr, char *buf)
 {
@@ -190,6 +191,7 @@ static ssize_t node_read_vmstat(struct s
 	return n;
 }
 static SYSDEV_ATTR(vmstat, S_IRUGO, node_read_vmstat, NULL);
+#endif
 
 static ssize_t node_read_distance(struct sys_device * dev,
 			struct sysdev_attribute *attr, char * buf)
@@ -274,7 +276,7 @@ int register_node(struct node *node, int
 		sysdev_create_file(&node->sysdev, &attr_meminfo);
 		sysdev_create_file(&node->sysdev, &attr_numastat);
 		sysdev_create_file(&node->sysdev, &attr_distance);
-		sysdev_create_file(&node->sysdev, &attr_vmstat);
+		sysdev_create_file_optional(&node->sysdev, &attr_vmstat);
 
 		scan_unevictable_register_node(node);
 
@@ -299,7 +301,7 @@ void unregister_node(struct node *node)
 	sysdev_remove_file(&node->sysdev, &attr_meminfo);
 	sysdev_remove_file(&node->sysdev, &attr_numastat);
 	sysdev_remove_file(&node->sysdev, &attr_distance);
-	sysdev_remove_file(&node->sysdev, &attr_vmstat);
+	sysdev_remove_file_optional(&node->sysdev, &attr_vmstat);
 
 	scan_unevictable_unregister_node(node);
 	hugetlb_unregister_node(node);		/* no-op, if memoryless node */
--- linux-next-20110804.orig/include/linux/sysdev.h
+++ linux-next-20110804/include/linux/sysdev.h
@@ -114,6 +114,20 @@ struct sysdev_attribute { 
 extern int sysdev_create_file(struct sys_device *, struct sysdev_attribute *);
 extern void sysdev_remove_file(struct sys_device *, struct sysdev_attribute *);
 
+#if defined(CONFIG_PROC_FS) || defined(CONFIG_SYSFS)
+#define sysdev_create_file_optional(sysdev, sysdevattr)	\
+	return sysdev_create_file(sysdev, sysdevattr);
+
+#define sysdev_remove_file_optional(sysdev, sysdevattr)	\
+		sysdev_remove_file(sysdev, sysdevattr);
+#else
+#define sysdev_create_file_optional(sysdev, sysdevattr)	\
+		(0)
+
+#define sysdev_remove_file_optional(sysdev, sysdevattr)	\
+		do {} while (0)
+#endif
+
 /* Create/remove NULL terminated attribute list */
 static inline int
 sysdev_create_files(struct sys_device *d, struct sysdev_attribute **a)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
