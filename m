Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 8E5766B0006
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 19:14:24 -0400 (EDT)
Date: Wed, 13 Mar 2013 16:14:15 -0700
From: Josh Triplett <josh@joshtriplett.org>
Subject: [PATCH] fs: Don't compile in drop_caches.c when CONFIG_SYSCTL=n
Message-ID: <20130313231413.GA3265@jtriplet-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Ingo Molnar <mingo@kernel.org>, Kees Cook <keescook@chromium.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

drop_caches.c provides code only invokable via sysctl, so don't compile
it in when CONFIG_SYSCTL=n.

Signed-off-by: Josh Triplett <josh@joshtriplett.org>
---
 fs/Makefile        |    3 ++-
 include/linux/mm.h |    4 ++++
 kernel/sysctl.c    |    1 -
 3 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/Makefile b/fs/Makefile
index 9d53192..3b2c767 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -10,7 +10,7 @@ obj-y :=	open.o read_write.o file_table.o super.o \
 		ioctl.o readdir.o select.o fifo.o dcache.o inode.o \
 		attr.o bad_inode.o file.o filesystems.o namespace.o \
 		seq_file.o xattr.o libfs.o fs-writeback.o \
-		pnode.o drop_caches.o splice.o sync.o utimes.o \
+		pnode.o splice.o sync.o utimes.o \
 		stack.o fs_struct.o statfs.o
 
 ifeq ($(CONFIG_BLOCK),y)
@@ -49,6 +49,7 @@ obj-$(CONFIG_FS_POSIX_ACL)	+= posix_acl.o xattr_acl.o
 obj-$(CONFIG_NFS_COMMON)	+= nfs_common/
 obj-$(CONFIG_GENERIC_ACL)	+= generic_acl.o
 obj-$(CONFIG_COREDUMP)		+= coredump.o
+obj-$(CONFIG_SYSCTL)		+= drop_caches.o
 
 obj-$(CONFIG_FHANDLE)		+= fhandle.o
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7acc9dc..1bb400f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1674,8 +1674,12 @@ int in_gate_area_no_mm(unsigned long addr);
 #define in_gate_area(mm, addr) ({(void)mm; in_gate_area_no_mm(addr);})
 #endif	/* __HAVE_ARCH_GATE_AREA */
 
+#ifdef CONFIG_SYSCTL
+extern int sysctl_drop_caches;
 int drop_caches_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
+#endif
+
 unsigned long shrink_slab(struct shrink_control *shrink,
 			  unsigned long nr_pages_scanned,
 			  unsigned long lru_pages);
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index afc1dc6..3dadde5 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -106,7 +106,6 @@ extern unsigned int core_pipe_limit;
 #endif
 extern int pid_max;
 extern int pid_max_min, pid_max_max;
-extern int sysctl_drop_caches;
 extern int percpu_pagelist_fraction;
 extern int compat_log;
 extern int latencytop_enabled;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
