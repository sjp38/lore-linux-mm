Message-ID: <390714287.11184@ustc.edu.cn>
Date: Tue, 25 Sep 2007 17:58:04 +0800
From: Fengguang Wu <wfg@mail.ustc.edu.cn>
Subject: filecache: expose what's in the page cache
Message-ID: <20070925095804.GA12549@mail.ustc.edu.cn>
References: <200709242044.l8OKi01e016834@imap1.linux-foundation.org> <20070924205901.GI19691@waste.org> <1190668988.26982.254.camel@localhost> <20070924213549.GJ19691@waste.org> <1190670636.26982.258.camel@localhost> <20070924220202.GK19691@waste.org> <390704784.02057@ustc.edu.cn> <46F8C426.3090300@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="jI8keyz6grp/JLjh"
Content-Disposition: inline
In-Reply-To: <46F8C426.3090300@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Matt Mackall <mpm@selenic.com>, Dave Hansen <haveblue@us.ibm.com>, akpm@linux-foundation.org, jjberthels@gmail.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Sep 25, 2007 at 01:47:42PM +0530, Balbir Singh wrote:
> Fengguang Wu wrote:
> > On Mon, Sep 24, 2007 at 05:02:02PM -0500, Matt Mackall wrote:
> >> I think Fengguang is just thinking forward to the next logical step
> >> here which is "expose what's in the page cache". Which means being
> > 
> > I have been doing it for a long time - that's the filecache patch I
> > sent you. However it's not quite ready for a public review.
> > 
> >> able to go from page back to device:inode:offset or (better, but
> >> trickier) path:offset.
> > 
> > It's doing the other way around - a top-down way.
> > 
> > First, you get a table of all cached inodes with the following fields:
> >   device-number  inode-number  file-path  cached-page-count  status
> > 
> > Then, one can query any file he's interested in, and list all its
> > cached pages in the following format:
> >   index  length  page-flags  reference-count
> 
> This design sounds good to me, I would expect people using madvise()
> to probably use this interface. Questions on the interface

Thank you, answers below. 

> 1. What permissions would a program need to use the interface

- inode list (whole system)
Only root is allowed. Or there may be leak of information.
Because we don't know the permission of the path.

- page list (for one file)
It's OK to view any file he can open.

> 2. Do we export both mapped and unmapped page cache. How does this
>    interface gel with mincore(2)? Is there duplicate information

Both are exported.
It's system wide info, and hence the superset of mincore(2).

> 3. If the user already knows the file of interest, is it possible
>    to list, it's cached pages without having to list all cached inodes

Sure, it's easy:

# echo 'cat /bin/bash' > /proc/filecache
# cat /proc/filecache

To get the inode list:

# echo 'ls' > /proc/filecache
# cat /proc/filecache

Yes, /proc/filecache accepts simple commands. Which could make it an
unfavorably complex interface... Anyway, I've been focusing on
exporting (more than enough) information. There will be a lot room of
discussion when it comes down to the details of *interface*.

> 4. What's the size of data (expected average) and the format, binary
>    or text?

Here are some numbers and output samples on my desktop:

- inode list: 185KB

#      ino       size   cached cached% refcnt state accessed   uid process         dev          file
[...]
   2888725         82       84     100      7    --      140     0 init            08:02(sda2)  /lib/libselinux.so.1
   2888724        216       84      38      7    --      140     0 init            08:02(sda2)  /lib/libsepol.so.1
   1258136         50       52     100      0    --     2349     0 init            08:02(sda2)  /etc/ld.so.cache
   2889047        115      116     100     52    --     1727     0 swapper         08:02(sda2)  /lib/ld-2.6.so
   1403527         32       32     100      1    --        1     0 swapper         08:02(sda2)  /sbin/init
[...]

- page list: bash 523B; firefox 6.5KB 

# file /bin/bash
# flags R:referenced A:active M:mmap U:uptodate D:dirty W:writeback B:buffer
# idx   len     state   refcnt
0       76      RAMU___ 2
76      4       ___U___ 1
80      5       RAMU___ 2
85      1       ___U___ 1
86      1       RAMU___ 2
87      1       RA_U___ 1
88      1       RAMU___ 2
89      4       RA_U___ 1
93      1       ___U___ 1
94      1       R__U___ 1
95      1       RA_U___ 1
96      3       RAMU___ 2
99      1       RA_U___ 1
100     1       RAMU___ 2
101     2       RA_U___ 1
103     6       RAMU___ 2
109     1       RA_U___ 1
110     10      ___U___ 1
123     10      ___U___ 1
133     4       RA_U___ 1
137     7       RAMU___ 2
144     10      ___U___ 1
154     7       RAMU___ 2
161     2       RA_U___ 1
163     1       ___U___ 1
164     2       RA_U___ 1


Attached is the patch on 2.6.23-rc6 for your convenience.
It's pretty stable and safe to use, in despite of it being a bit fat ;-)

Thank you,
Fengguang

--jI8keyz6grp/JLjh
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="filecache-2.6.23-rc6.patch"

--- linux-2.6.23-rc6.orig/include/linux/mm.h
+++ linux-2.6.23-rc6/include/linux/mm.h
@@ -28,6 +28,7 @@ extern unsigned long max_mapnr;
 extern unsigned long num_physpages;
 extern void * high_memory;
 extern int page_cluster;
+extern char * const zone_names[];
 
 #ifdef CONFIG_SYSCTL
 extern int sysctl_legacy_va_layout;
--- linux-2.6.23-rc6.orig/mm/page_alloc.c
+++ linux-2.6.23-rc6/mm/page_alloc.c
@@ -87,7 +87,7 @@ int sysctl_lowmem_reserve_ratio[MAX_NR_Z
 
 EXPORT_SYMBOL(totalram_pages);
 
-static char * const zone_names[MAX_NR_ZONES] = {
+char * const zone_names[MAX_NR_ZONES] = {
 #ifdef CONFIG_ZONE_DMA
 	 "DMA",
 #endif
--- linux-2.6.23-rc6.orig/fs/dcache.c
+++ linux-2.6.23-rc6/fs/dcache.c
@@ -1810,7 +1810,10 @@ static char * __d_path( struct dentry *d
 
 		if (dentry == root && vfsmnt == rootmnt)
 			break;
-		if (dentry == vfsmnt->mnt_root || IS_ROOT(dentry)) {
+		if (unlikely(!vfsmnt)) {
+			if (IS_ROOT(dentry))
+				break;
+		} else if (dentry == vfsmnt->mnt_root || IS_ROOT(dentry)) {
 			/* Global root? */
 			spin_lock(&vfsmount_lock);
 			if (vfsmnt->mnt_parent == vfsmnt) {
--- linux-2.6.23-rc6.orig/include/linux/seq_file.h
+++ linux-2.6.23-rc6/include/linux/seq_file.h
@@ -32,6 +32,7 @@ struct seq_operations {
 };
 
 int seq_open(struct file *, const struct seq_operations *);
+int seq_open_private(struct file *, struct seq_operations *, void *);
 ssize_t seq_read(struct file *, char __user *, size_t, loff_t *);
 loff_t seq_lseek(struct file *, loff_t, int);
 int seq_release(struct inode *, struct file *);
--- linux-2.6.23-rc6.orig/fs/seq_file.c
+++ linux-2.6.23-rc6/fs/seq_file.c
@@ -53,6 +53,16 @@ int seq_open(struct file *file, const st
 }
 EXPORT_SYMBOL(seq_open);
 
+int seq_open_private(struct file *file, struct seq_operations *op, void *data)
+{
+	int ret = seq_open(file, op);
+
+	if (!ret)
+		((struct seq_file *)file->private_data)->private = data;
+
+	return ret;
+}
+EXPORT_SYMBOL(seq_open_private);
 /**
  *	seq_read -	->read() method for sequential files.
  *	@file: the file to read from
--- linux-2.6.23-rc6.orig/fs/nfs/client.c
+++ linux-2.6.23-rc6/fs/nfs/client.c
@@ -1188,17 +1188,7 @@ static const struct file_operations nfs_
  */
 static int nfs_server_list_open(struct inode *inode, struct file *file)
 {
-	struct seq_file *m;
-	int ret;
-
-	ret = seq_open(file, &nfs_server_list_ops);
-	if (ret < 0)
-		return ret;
-
-	m = file->private_data;
-	m->private = PDE(inode)->data;
-
-	return 0;
+	return seq_open_private(file, &nfs_server_list_ops, PDE(inode)->data);
 }
 
 /*
@@ -1258,17 +1248,7 @@ static int nfs_server_list_show(struct s
  */
 static int nfs_volume_list_open(struct inode *inode, struct file *file)
 {
-	struct seq_file *m;
-	int ret;
-
-	ret = seq_open(file, &nfs_volume_list_ops);
-	if (ret < 0)
-		return ret;
-
-	m = file->private_data;
-	m->private = PDE(inode)->data;
-
-	return 0;
+	return seq_open_private(file, &nfs_volume_list_ops, PDE(inode)->data);
 }
 
 /*
--- linux-2.6.23-rc6.orig/fs/inode.c
+++ linux-2.6.23-rc6/fs/inode.c
@@ -82,6 +82,10 @@ static struct hlist_head *inode_hashtabl
  */
 DEFINE_SPINLOCK(inode_lock);
 
+EXPORT_SYMBOL(inode_in_use);
+EXPORT_SYMBOL(inode_unused);
+EXPORT_SYMBOL(inode_lock);
+
 /*
  * iprune_mutex provides exclusion between the kswapd or try_to_free_pages
  * icache shrinking path, and the umount path.  Without this exclusion,
@@ -99,6 +103,14 @@ struct inodes_stat_t inodes_stat;
 
 static struct kmem_cache * inode_cachep __read_mostly;
 
+static inline void inode_created_by(struct inode *inode, struct task_struct *task)
+{
+#ifdef CONFIG_PROC_FILECACHE_EXTRAS
+	inode->i_cuid = task->uid;
+	memcpy(inode->i_comm, task->comm, sizeof(task->comm));
+#endif
+}
+
 static struct inode *alloc_inode(struct super_block *sb)
 {
 	static const struct address_space_operations empty_aops;
@@ -164,6 +176,7 @@ static struct inode *alloc_inode(struct 
 		}
 		inode->i_private = NULL;
 		inode->i_mapping = mapping;
+		inode_created_by(inode, current);
 	}
 	return inode;
 }
@@ -231,6 +244,8 @@ void __iget(struct inode * inode)
 	inodes_stat.nr_unused--;
 }
 
+EXPORT_SYMBOL(__iget);
+
 /**
  * clear_inode - clear an inode
  * @inode: inode to clear
--- linux-2.6.23-rc6.orig/fs/super.c
+++ linux-2.6.23-rc6/fs/super.c
@@ -47,6 +47,9 @@ struct file_system_type *get_fs_type(con
 LIST_HEAD(super_blocks);
 DEFINE_SPINLOCK(sb_lock);
 
+EXPORT_SYMBOL(super_blocks);
+EXPORT_SYMBOL(sb_lock);
+
 /**
  *	alloc_super	-	create new superblock
  *	@type:	filesystem type superblock should belong to
--- linux-2.6.23-rc6.orig/mm/vmscan.c
+++ linux-2.6.23-rc6/mm/vmscan.c
@@ -212,6 +212,7 @@ unsigned long shrink_slab(unsigned long 
 	up_read(&shrinker_rwsem);
 	return ret;
 }
+EXPORT_SYMBOL(shrink_slab);
 
 /* Called without lock on whether page is mapped, so answer is unstable */
 static inline int page_mapping_inuse(struct page *page)
--- linux-2.6.23-rc6.orig/Documentation/filesystems/proc.txt
+++ linux-2.6.23-rc6/Documentation/filesystems/proc.txt
@@ -263,6 +263,7 @@ Table 1-4: Kernel info in /proc
  driver	     Various drivers grouped here, currently rtc (2.4)
  execdomains Execdomains, related to security			(2.4)
  fb	     Frame Buffer devices				(2.4)
+ filecache   Query/drop in-memory file cache
  fs	     File system parameters, currently nfs/exports	(2.4)
  ide         Directory containing info about the IDE subsystem 
  interrupts  Interrupt usage                                   
@@ -507,6 +508,88 @@ VmallocTotal: total size of vmalloc memo
  VmallocUsed: amount of vmalloc area which is used
 VmallocChunk: largest contigious block of vmalloc area which is free
 
+..............................................................................
+
+filecache:
+
+Provides access to the in-memory file cache.
+
+To list an index of all cached files:
+
+    echo ls > /proc/filecache
+    cat /proc/filecache
+
+The output looks like:
+
+    # filecache 1.0
+    #      ino       size   cached cached%  state   refcnt  dev             file
+       1026334         91       92    100   --      66      03:02(hda2)     /lib/ld-2.3.6.so
+        233608       1242      972     78   --      66      03:02(hda2)     /lib/tls/libc-2.3.6.so
+         65203        651      476     73   --      1       03:02(hda2)     /bin/bash
+       1026445        261      160     61   --      10      03:02(hda2)     /lib/libncurses.so.5.5
+        235427         10       12    100   --      44      03:02(hda2)     /lib/tls/libdl-2.3.6.so
+
+FIELD	INTRO
+---------------------------------------------------------------------------
+ino	inode number
+size	inode size in KB
+cached	cached size in KB
+cached%	percent of file data cached
+state1	'-' clean; 'd' metadata dirty; 'D' data dirty
+state2	'-' unlocked; 'L' locked, normally indicates file being written out
+refcnt	file reference count, it's an in-kernel one, not exactly open count
+dev	major:minor numbers in hex, followed by a descriptive device name
+file	file path _inside_ the filesystem. There are several special names:
+	'(noname)':	the file name is not available
+	'(03:02)':	the file is a block device file of major:minor
+	'...(deleted)': the named file has been deleted from the disk
+
+To list the cached pages of a perticular file:
+
+    echo /bin/bash > /proc/filecache
+    cat /proc/filecache
+
+    # file /bin/bash
+    # flags R:referenced A:active U:uptodate D:dirty W:writeback M:mmap
+    # idx   len     state   refcnt
+    0       36      RAU__M  3
+    36      1       RAU__M  2
+    37      8       RAU__M  3
+    45      2       RAU___  1
+    47      6       RAU__M  3
+    53      3       RAU__M  2
+    56      2       RAU__M  3
+
+FIELD	INTRO
+----------------------------------------------------------------------------
+idx	page index
+len	number of pages which are cached and share the same state
+state	page state of the flags listed in line two
+refcnt	page reference count
+
+Careful users may notice that the file name to be queried is remembered between
+commands. Internally, the module has a global variable to store the file name
+parameter, so that it can be inherited by newly opened /proc/filecache file.
+However it can lead to interference for multiple queriers. The solution here
+is to obey a rule: only root can interactively change the file name parameter;
+normal users must go for scripts to access the interface. Scripts should do it
+by following the code example below:
+
+    filecache = open("/proc/filecache", "rw");
+    # avoid polluting the global parameter filename
+    filecache.write("set private");
+
+To instruct the kernel to drop clean caches, dentries and inodes from memory,
+causing that memory to become free:
+
+    # drop clean file data cache (i.e. file backed pagecache)
+    echo drop pagecache > /proc/filecache
+
+    # drop clean file metadata cache (i.e. dentries and inodes)
+    echo drop slabcache > /proc/filecache
+
+Note that the drop commands are non-destructive operations and dirty objects
+are not freeable, the user should run `sync' first.
 
 1.3 IDE devices in /proc/ide
 ----------------------------
--- /dev/null
+++ linux-2.6.23-rc6/fs/proc/filecache.c
@@ -0,0 +1,934 @@
+/*
+ * fs/proc/filecache.c
+ *
+ * Copyright (C) 2006, 2007 Fengguang Wu <wfg@mail.ustc.edu.cn>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/fs.h>
+#include <linux/mm.h>
+#include <linux/radix-tree.h>
+#include <linux/page-flags.h>
+#include <linux/pagevec.h>
+#include <linux/pagemap.h>
+#include <linux/vmalloc.h>
+#include <linux/writeback.h>
+#include <linux/buffer_head.h>
+#include <linux/parser.h>
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
+#include <linux/file.h>
+#include <linux/module.h>
+#include <asm/uaccess.h>
+
+/*
+ * Increase minor version when new columns are added;
+ * Increase major version when existing columns are changed.
+ */
+#define FILECACHE_VERSION	"1.0"
+
+/* Internal buffer sizes. The larger the more effcient. */
+#define SBUF_SIZE	(128<<10)
+#define IWIN_PAGE_ORDER	3
+#define IWIN_SIZE	((PAGE_SIZE<<IWIN_PAGE_ORDER) / sizeof(struct inode *))
+
+/*
+ * Session management.
+ *
+ * Each opened /proc/filecache file is assiocated with a session object.
+ * Also there is a global_session that maintains status across open()/close()
+ * (i.e. the lifetime of an opened file), so that a casual user can query the
+ * filecache via _multiple_ simple shell commands like
+ * 'echo cat /bin/bash > /proc/filecache; cat /proc/filecache'.
+ *
+ * session.query_file is the file whose cache info is to be queried.
+ * Its value determines what we get on read():
+ * 	- NULL: ii_*() called to show the inode index
+ * 	- filp: pg_*() called to show the page groups of a filp
+ *
+ * session.query_file is
+ * 	- cloned from global_session.query_file on open();
+ * 	- updated on write("cat filename");
+ * 	  note that the new file will also be saved in global_session.query_file if
+ * 	  session.private_session is false.
+ */
+
+struct session {
+	/* options */
+	int		private_session;
+	unsigned long	ls_options;
+	dev_t		ls_dev;
+
+	/* parameters */
+	struct file	*query_file;
+
+	/* seqfile pos */
+	pgoff_t		start_offset;
+	pgoff_t		next_offset;
+
+	/* inode at last pos */
+	struct {
+		unsigned long pos;
+		unsigned long state;
+		struct inode *inode;
+		struct inode *pinned_inode;
+	} ipos;
+
+	/* inode window */
+	struct {
+		unsigned long cursor;
+		unsigned long origin;
+		unsigned long size;
+		struct inode **inodes;
+	} iwin;
+};
+
+static struct session global_session;
+
+/*
+ * Session address is stored in proc_file->f_ra.start:
+ * we assume that there will be no readahead for proc_file.
+ */
+static struct session *get_session(struct file *proc_file)
+{
+	return (struct session *)proc_file->f_ra.start;
+}
+
+static void set_session(struct file *proc_file, struct session *s)
+{
+	BUG_ON(proc_file->f_ra.start);
+	proc_file->f_ra.start = (unsigned long)s;
+}
+
+static void update_global_file(struct session *s)
+{
+	if (s->private_session)
+		return;
+
+	if (global_session.query_file)
+		fput(global_session.query_file);
+
+	global_session.query_file = s->query_file;
+
+	if (global_session.query_file)
+		get_file(global_session.query_file);
+}
+
+/*
+ * Cases of the name:
+ * 1) NULL                (new session)
+ * 	s->query_file = global_session.query_file = 0;
+ * 2) ""                  (ls/la)
+ * 	s->query_file = global_session.query_file;
+ * 3) a regular file name (cat newfile)
+ * 	s->query_file = global_session.query_file = newfile;
+ */
+static int session_update_file(struct session *s, char *name)
+{
+	static DEFINE_MUTEX(mutex); /* protects global_session.query_file */
+	int err = 0;
+
+	mutex_lock(&mutex);
+
+	/*
+	 * We are to quit, or to list the cached files.
+	 * Reset *.query_file.
+	 */
+	if (!name) {
+		if (s->query_file) {
+			fput(s->query_file);
+			s->query_file = NULL;
+		}
+		update_global_file(s);
+		goto out;
+	}
+
+	/*
+	 * This is a new session.
+	 * Inherit options/parameters from global ones.
+	 */
+	if (name[0] == '\0') {
+		*s = global_session;
+		if (s->query_file)
+			get_file(s->query_file);
+		goto out;
+	}
+
+	/*
+	 * Open the named file.
+	 */
+	if (s->query_file)
+		fput(s->query_file);
+	s->query_file = filp_open(name, O_RDONLY|O_LARGEFILE, 0);
+	if (IS_ERR(s->query_file)) {
+		err = PTR_ERR(s->query_file);
+		s->query_file = NULL;
+	} else
+		update_global_file(s);
+
+out:
+	mutex_unlock(&mutex);
+
+	return err;
+}
+
+static struct session *session_create(void)
+{
+	struct session *s;
+	int err = 0;
+
+	s = kmalloc(sizeof(*s), GFP_KERNEL);
+	if (s)
+		err = session_update_file(s, "");
+	else
+		err = -ENOMEM;
+
+	return err ? ERR_PTR(err) : s;
+}
+
+static void session_release(struct session *s)
+{
+	if (s->ipos.pinned_inode)
+		iput(s->ipos.pinned_inode);
+	if (s->query_file)
+		fput(s->query_file);
+	kfree(s);
+}
+
+
+/*
+ * Listing of cached files.
+ *
+ * Usage:
+ * 		echo > /proc/filecache  # enter listing mode
+ * 		cat /proc/filecache     # get the file listing
+ */
+
+/* code style borrowed from ib_srp.c */
+enum {
+	LS_OPT_ERR	=	0,
+	LS_OPT_NOCLEAN	=	1 << 0,
+	LS_OPT_NODIRTY	=	1 << 1,
+	LS_OPT_NOUNUSED	=	1 << 2,
+	LS_OPT_EMPTY	=	1 << 3,
+	LS_OPT_ALL	=	1 << 4,
+	LS_OPT_DEV	=	1 << 5,
+};
+
+static match_table_t ls_opt_tokens = {
+	{ LS_OPT_NOCLEAN,	"noclean" 	},
+	{ LS_OPT_NODIRTY,	"nodirty" 	},
+	{ LS_OPT_NOUNUSED,	"nounused" 	},
+	{ LS_OPT_EMPTY,		"empty"		},
+	{ LS_OPT_ALL,		"all" 		},
+	{ LS_OPT_DEV,		"dev=%s"	},
+	{ LS_OPT_ERR,		NULL 		}
+};
+
+static int ls_parse_options(const char *buf, struct session *s)
+{
+	substring_t args[MAX_OPT_ARGS];
+	char *options, *sep_opt;
+	char *p;
+	int token;
+	int ret = 0;
+
+	if (!buf)
+		return 0;
+	options = kstrdup(buf, GFP_KERNEL);
+	if (!options)
+		return -ENOMEM;
+
+	s->ls_options = 0;
+	sep_opt = options;
+	while ((p = strsep(&sep_opt, " ")) != NULL) {
+		if (!*p)
+			continue;
+
+		token = match_token(p, ls_opt_tokens, args);
+
+		switch (token) {
+		case LS_OPT_NOCLEAN:
+		case LS_OPT_NODIRTY:
+		case LS_OPT_NOUNUSED:
+		case LS_OPT_EMPTY:
+		case LS_OPT_ALL:
+			s->ls_options |= token;
+			break;
+		case LS_OPT_DEV:
+			p = match_strdup(args);
+			if (!p) {
+				ret = -ENOMEM;
+				goto out;
+			}
+			if (*p == '/') {
+				struct kstat stat;
+				struct nameidata nd;
+				ret = path_lookup(p, LOOKUP_FOLLOW, &nd);
+				if (!ret)
+					ret = vfs_getattr(nd.mnt,
+							  nd.dentry, &stat);
+				if (!ret)
+					s->ls_dev = stat.rdev;
+			} else
+				s->ls_dev = simple_strtoul(p, NULL, 0);
+			/* printk("%lx %s\n", (long)s->ls_dev, p); */
+			kfree(p);
+			break;
+
+		default:
+			printk(KERN_WARNING "unknown parameter or missing value "
+			       "'%s' in ls command\n", p);
+			ret = -EINVAL;
+			goto out;
+		}
+	}
+
+out:
+	kfree(options);
+	return ret;
+}
+
+/*
+ * Add possible filters here.
+ * No permission check: we cannot verify the path's permission anyway.
+ * We simply demand root previledge for accessing /proc/filecache.
+ */
+static int may_show_inode(struct session *s, struct inode *inode)
+{
+	if (!atomic_read(&inode->i_count))
+		return 0;
+	if (inode->i_state & (I_FREEING|I_CLEAR|I_WILL_FREE))
+		return 0;
+	if (!inode->i_mapping)
+		return 0;
+
+	if (s->ls_dev && s->ls_dev != inode->i_sb->s_dev)
+		return 0;
+
+	if (s->ls_options & LS_OPT_ALL)
+		return 1;
+
+	if (!(s->ls_options & LS_OPT_EMPTY) && !inode->i_mapping->nrpages)
+		return 0;
+
+	if ((s->ls_options & LS_OPT_NOCLEAN) && !(inode->i_state & I_DIRTY))
+		return 0;
+
+	if ((s->ls_options & LS_OPT_NODIRTY) && (inode->i_state & I_DIRTY))
+		return 0;
+
+	if (!(S_ISREG(inode->i_mode) || S_ISDIR(inode->i_mode) ||
+	      S_ISLNK(inode->i_mode) || S_ISBLK(inode->i_mode)))
+		return 0;
+
+	return 1;
+}
+
+/*
+ * Full: there are more data following.
+ */
+static int iwin_full(struct session *s)
+{
+	return !s->iwin.cursor ||
+		s->iwin.cursor > s->iwin.origin + s->iwin.size;
+}
+
+static int iwin_push(struct session *s, struct inode *inode)
+{
+	if (!may_show_inode(s, inode))
+		return 0;
+
+	s->iwin.cursor++;
+
+	if (s->iwin.size >= IWIN_SIZE)
+		return 1;
+
+	if (s->iwin.cursor > s->iwin.origin)
+		s->iwin.inodes[s->iwin.size++] = inode;
+	return 0;
+}
+
+/*
+ * Travease the inode lists in order - newest first.
+ * And fill @s->iwin.inodes with inodes positioned in [@pos, @pos+IWIN_SIZE).
+ */
+static int iwin_fill(struct session *s, unsigned long pos)
+{
+	struct inode *inode;
+	struct super_block *sb;
+
+	s->iwin.origin = pos;
+	s->iwin.cursor = 0;
+	s->iwin.size = 0;
+
+	/*
+	 * We have a cursor inode, clean and expected to be unchanged.
+	 */
+	if (s->ipos.inode && pos >= s->ipos.pos &&
+			!(s->ipos.state & I_DIRTY) &&
+			s->ipos.state == s->ipos.inode->i_state) {
+		inode = s->ipos.inode;
+		s->iwin.cursor = s->ipos.pos;
+		goto continue_from_saved;
+	}
+
+	if (s->ls_options & LS_OPT_NODIRTY)
+		goto clean_inodes;
+
+	spin_lock(&sb_lock);
+	list_for_each_entry(sb, &super_blocks, s_list) {
+		if (s->ls_dev && s->ls_dev != sb->s_dev)
+			continue;
+
+		list_for_each_entry(inode, &sb->s_dirty, i_list) {
+			if (iwin_push(s, inode))
+				goto out_full_unlock;
+		}
+		list_for_each_entry(inode, &sb->s_io, i_list) {
+			if (iwin_push(s, inode))
+				goto out_full_unlock;
+		}
+	}
+	spin_unlock(&sb_lock);
+
+clean_inodes:
+	list_for_each_entry(inode, &inode_in_use, i_list) {
+		if (iwin_push(s, inode))
+			goto out_full;
+continue_from_saved:
+		;
+	}
+
+	if (s->ls_options & LS_OPT_NOUNUSED)
+		return 0;
+
+	list_for_each_entry(inode, &inode_unused, i_list) {
+		if (iwin_push(s, inode))
+			goto out_full;
+	}
+
+	return 0;
+
+out_full_unlock:
+	spin_unlock(&sb_lock);
+out_full:
+	return 1;
+}
+
+static struct inode *iwin_inode(struct session *s, unsigned long pos)
+{
+	if ((iwin_full(s) && pos >= s->iwin.origin + s->iwin.size)
+			  || pos < s->iwin.origin)
+		iwin_fill(s, pos);
+
+	if (pos >= s->iwin.cursor)
+		return NULL;
+
+	s->ipos.pos = pos;
+	s->ipos.inode = s->iwin.inodes[pos - s->iwin.origin];
+	BUG_ON(!s->ipos.inode);
+	return s->ipos.inode;
+}
+
+static void show_inode(struct seq_file *m, struct inode *inode)
+{
+	char state[] = "--"; /* dirty, locked */
+	struct dentry *dentry;
+	loff_t size = i_size_read(inode);
+	unsigned long nrpages;
+	int percent;
+	int refcnt;
+	int shift;
+
+	if (!size)
+		size++;
+
+	if (inode->i_mapping)
+		nrpages = inode->i_mapping->nrpages;
+	else {
+		nrpages = 0;
+		WARN_ON(1);
+	}
+
+	for (shift = 0; (size >> shift) > ULONG_MAX / 128; shift += 12)
+		;
+	percent = min(100UL, (((100 * nrpages) >> shift) << PAGE_CACHE_SHIFT) /
+						(unsigned long)(size >> shift));
+
+	if (inode->i_state & (I_DIRTY_DATASYNC|I_DIRTY_PAGES))
+		state[0] = 'D';
+	else if (inode->i_state & I_DIRTY_SYNC)
+		state[0] = 'd';
+
+	if (inode->i_state & I_LOCK)
+		state[0] = 'L';
+
+	refcnt = 0;
+	list_for_each_entry(dentry, &inode->i_dentry, d_alias) {
+		refcnt += atomic_read(&dentry->d_count);
+	}
+
+	seq_printf(m, "%10lu %10llu %8lu %7d ",
+			inode->i_ino,
+			DIV_ROUND_UP(size, 1024),
+			nrpages << (PAGE_CACHE_SHIFT - 10),
+			percent);
+
+	seq_printf(m, "%6d %5s ",
+			refcnt,
+			state);
+
+#ifdef CONFIG_PROC_FILECACHE_EXTRAS
+	seq_printf(m, "%8u %5u %-16s",
+			inode->i_access_count,
+			inode->i_cuid,
+			inode->i_comm);
+#endif
+
+	seq_printf(m, "%02x:%02x(%s)\t",
+			MAJOR(inode->i_sb->s_dev),
+			MINOR(inode->i_sb->s_dev),
+			inode->i_sb->s_id);
+
+	if (list_empty(&inode->i_dentry)) {
+		if (!atomic_read(&inode->i_count))
+			seq_puts(m, "(noname)\n");
+		else
+			seq_printf(m, "(%02x:%02x)\n",
+					imajor(inode), iminor(inode));
+	} else {
+		dentry = list_entry(inode->i_dentry.next,
+							struct dentry, d_alias);
+		seq_path(m, NULL, dentry, " \t\n\\");
+		seq_putc(m, '\n');
+	}
+}
+
+static int ii_show(struct seq_file *m, void *v)
+{
+	unsigned long index = *(loff_t *) v;
+	struct session *s = m->private;
+        struct inode *inode;
+
+	if (index == 0) {
+		seq_puts(m, "# filecache " FILECACHE_VERSION "\n");
+		seq_puts(m, "#      ino       size   cached cached% "
+				"refcnt state "
+#ifdef CONFIG_PROC_FILECACHE_EXTRAS
+				"accessed   uid process         "
+#endif
+				"dev\t\tfile\n");
+	}
+
+        inode = iwin_inode(s,index);
+	show_inode(m, inode);
+
+	return 0;
+}
+
+static void *ii_start(struct seq_file *m, loff_t *pos)
+{
+	struct session *s = m->private;
+
+	s->iwin.size = 0;
+	s->iwin.inodes = (struct inode **)
+				__get_free_pages( GFP_KERNEL, IWIN_PAGE_ORDER);
+	if (!s->iwin.inodes)
+		return NULL;
+
+	spin_lock(&inode_lock);
+
+	return iwin_inode(s, *pos) ? pos : NULL;
+}
+
+static void *ii_next(struct seq_file *m, void *v, loff_t *pos)
+{
+	struct session *s = m->private;
+
+	(*pos)++;
+	return iwin_inode(s, *pos) ? pos : NULL;
+}
+
+static void ii_stop(struct seq_file *m, void *v)
+{
+	struct session *s = m->private;
+	struct inode *inode = s->ipos.inode;
+
+	if (!s->iwin.inodes)
+		return;
+
+	if (inode) {
+		__iget(inode);
+		s->ipos.state = inode->i_state;
+	}
+	spin_unlock(&inode_lock);
+
+	free_pages((unsigned long) s->iwin.inodes, IWIN_PAGE_ORDER);
+	if (s->ipos.pinned_inode)
+		iput(s->ipos.pinned_inode);
+	s->ipos.pinned_inode = inode;
+}
+
+/*
+ * Listing of cached page ranges of a file.
+ *
+ * Usage:
+ * 		echo 'file name' > /proc/filecache
+ * 		cat /proc/filecache
+ */
+
+unsigned long page_mask;
+#define PG_MMAP		PG_lru		/* reuse any non-relevant flag */
+#define PG_BUFFER	PG_readahead	/* ditto */
+
+/*
+ * Page state names, prefixed by their abbreviations.
+ */
+struct {
+	unsigned long	mask;
+	const char     *name;
+	int		faked;
+} page_flag [] = {
+	{1 << PG_referenced,	"R:referenced",	0},
+	{1 << PG_active,	"A:active",	0},
+	{1 << PG_MMAP,		"M:mmap",	1},
+
+	{1 << PG_uptodate,	"U:uptodate",	0},
+	{1 << PG_dirty,		"D:dirty",	0},
+	{1 << PG_writeback,	"W:writeback",	0},
+
+	{1 << PG_BUFFER,	"B:buffer",	1},
+
+};
+
+static unsigned long page_flags(struct page* page)
+{
+	unsigned long flags;
+
+	flags = page->flags & page_mask;
+
+	if (page_mapped(page))
+		flags |= (1 << PG_MMAP);
+
+	if (page_has_buffers(page))
+		flags |= (1 << PG_BUFFER);
+
+	return flags;
+}
+
+static int pages_similiar(struct page* page0, struct page* page)
+{
+	if (page_count(page0) != page_count(page))
+		return 0;
+
+	if (page_flags(page0) != page_flags(page))
+		return 0;
+
+	return 1;
+}
+
+static void show_range(struct seq_file *m, struct page* page, unsigned long len)
+{
+	int i;
+	unsigned long flags;
+
+	if (!m || !page)
+		return;
+
+	seq_printf(m, "%lu\t%lu\t", page->index, len);
+
+	flags = page_flags(page);
+	for (i = 0; i < ARRAY_SIZE(page_flag); i++)
+		seq_putc(m, (flags & page_flag[i].mask) ?
+					page_flag[i].name[0] : '_');
+
+	seq_printf(m, "\t%d\n", page_count(page));
+}
+
+#define BATCH_LINES	100
+static pgoff_t show_file_cache(struct seq_file *m,
+				struct address_space *mapping, pgoff_t start)
+{
+	int i;
+	int lines = 0;
+	pgoff_t len = 0;
+	struct pagevec pvec;
+	struct page *page;
+	struct page *page0 = NULL;
+
+	for (;;) {
+		pagevec_init(&pvec, 0);
+		pvec.nr = radix_tree_gang_lookup(&mapping->page_tree,
+				(void **)pvec.pages, start + len, PAGEVEC_SIZE);
+
+		if (pvec.nr == 0) {
+			show_range(m, page0, len);
+			start = ULONG_MAX;
+			goto out;
+		}
+
+		if (!page0)
+			page0 = pvec.pages[0];
+
+		for (i = 0; i < pvec.nr; i++) {
+			page = pvec.pages[i];
+
+			if (page->index == start + len &&
+					pages_similiar(page0, page))
+				len++;
+			else {
+				show_range(m, page0, len);
+				page0 = page;
+				start = page->index;
+				len = 1;
+				if (++lines > BATCH_LINES)
+					goto out;
+			}
+		}
+	}
+
+out:
+	return start;
+}
+
+static int pg_show(struct seq_file *m, void *v)
+{
+	struct session *s = m->private;
+	struct file *file = s->query_file;
+	pgoff_t offset;
+
+	if (!file)
+		return ii_show(m, v);
+
+	offset = *(loff_t *) v;
+
+	if (!offset) { /* print header */
+		int i;
+
+		seq_puts(m, "# file ");
+		seq_path(m, file->f_vfsmnt, file->f_dentry, " \t\n\\");
+
+		seq_puts(m, "\n# flags");
+		for (i = 0; i < ARRAY_SIZE(page_flag); i++)
+			seq_printf(m, " %s", page_flag[i].name);
+
+		seq_puts(m, "\n# idx\tlen\tstate\trefcnt\n");
+	}
+
+	s->start_offset = offset;
+	s->next_offset = show_file_cache(m, file->f_mapping, offset);
+
+	return 0;
+}
+
+static void *file_pos(struct file *file, loff_t *pos)
+{
+	loff_t size = i_size_read(file->f_mapping->host);
+	pgoff_t end = DIV_ROUND_UP(size, PAGE_CACHE_SIZE);
+	pgoff_t offset = *pos;
+
+	return offset < end ? pos : NULL;
+}
+
+static void *pg_start(struct seq_file *m, loff_t *pos)
+{
+	struct session *s = m->private;
+	struct file *file = s->query_file;
+	pgoff_t offset = *pos;
+
+	if (!file)
+		return ii_start(m, pos);
+
+	read_lock_irq(&file->f_mapping->tree_lock);
+
+	if (offset - s->start_offset == 1)
+		*pos = s->next_offset;
+	return file_pos(file, pos);
+}
+
+static void *pg_next(struct seq_file *m, void *v, loff_t *pos)
+{
+	struct session *s = m->private;
+	struct file *file = s->query_file;
+
+	if (!file)
+		return ii_next(m, v, pos);
+
+	*pos = s->next_offset;
+	return file_pos(file, pos);
+}
+
+static void pg_stop(struct seq_file *m, void *v)
+{
+	struct session *s = m->private;
+	struct file *file = s->query_file;
+
+	if (!file)
+		return ii_stop(m, v);
+
+	read_unlock_irq(&file->f_mapping->tree_lock);
+}
+
+struct seq_operations seq_filecache_op = {
+	.start	= pg_start,
+	.next	= pg_next,
+	.stop	= pg_stop,
+	.show	= pg_show,
+};
+
+
+/*
+ * Proc file operations.
+ */
+
+static int filecache_open(struct inode *inode, struct file *proc_file)
+{
+	struct seq_file *m;
+	struct session *s;
+	unsigned size;
+	char *buf = 0;
+	int ret;
+
+	if (!try_module_get(THIS_MODULE))
+		return -ENOENT;
+
+	s = session_create();
+	if (IS_ERR(s)) {
+		ret = PTR_ERR(s);
+		goto out;
+	}
+	set_session(proc_file, s);
+
+	size = SBUF_SIZE;
+	buf = kmalloc(size, GFP_KERNEL);
+	if (!buf) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	ret = seq_open(proc_file, &seq_filecache_op);
+	if (!ret) {
+		m = proc_file->private_data;
+		m->private = s;
+		m->buf = buf;
+		m->size = size;
+	}
+
+out:
+	if (ret) {
+		kfree(s);
+		kfree(buf);
+		module_put(THIS_MODULE);
+	}
+	return ret;
+}
+
+static int filecache_release(struct inode *inode, struct file *proc_file)
+{
+	struct session *s = get_session(proc_file);
+	int ret;
+
+	session_release(s);
+	ret = seq_release(inode, proc_file);
+	module_put(THIS_MODULE);
+	return ret;
+}
+
+ssize_t filecache_write(struct file *proc_file, const char __user * buffer,
+			size_t count, loff_t *ppos)
+{
+	struct session *s;
+	char *name;
+	int err = 0;
+
+	if (count >= PATH_MAX + 5)
+		return -ENAMETOOLONG;
+
+	name = kmalloc(count+1, GFP_KERNEL);
+	if (!name)
+		return -ENOMEM;
+
+	if (copy_from_user(name, buffer, count)) {
+		err = -EFAULT;
+		goto out;
+	}
+
+	/* strip the optional newline */
+	if (count && name[count-1] == '\n')
+		name[count-1] = '\0';
+	else
+		name[count] = '\0';
+
+	s = get_session(proc_file);
+	if (!strcmp(name, "set private")) {
+		s->private_session = 1;
+		goto out;
+	}
+
+	if (!strncmp(name, "cat ", 4)) {
+		err = session_update_file(s, name+4);
+		goto out;
+	}
+
+	if (!strncmp(name, "ls", 2)) {
+		err = session_update_file(s, NULL);
+		if (!err)
+			err = ls_parse_options(name+2, s);
+		if (!err && !s->private_session) {
+			global_session.ls_dev = s->ls_dev;
+			global_session.ls_options = s->ls_options;
+		}
+		goto out;
+	}
+
+	/* err = -EINVAL; */
+	err = session_update_file(s, name);
+
+out:
+	kfree(name);
+
+	return err ? err : count;
+}
+
+static struct file_operations proc_filecache_fops = {
+	.owner		= THIS_MODULE,
+	.open		= filecache_open,
+	.release	= filecache_release,
+	.write		= filecache_write,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+};
+
+
+static __init int filecache_init(void)
+{
+	int i;
+	struct proc_dir_entry *entry;
+
+	entry = create_proc_entry("filecache", 0600, NULL);
+	if (entry)
+		entry->proc_fops = &proc_filecache_fops;
+
+	for (page_mask = i = 0; i < ARRAY_SIZE(page_flag); i++)
+		if (!page_flag[i].faked)
+			page_mask |= page_flag[i].mask;
+
+	return 0;
+}
+
+static void filecache_exit(void)
+{
+	remove_proc_entry("filecache", NULL);
+	if (global_session.query_file)
+		fput(global_session.query_file);
+}
+
+MODULE_AUTHOR("Fengguang Wu <wfg@mail.ustc.edu.cn>");
+MODULE_LICENSE("GPL");
+
+module_init(filecache_init);
+module_exit(filecache_exit);
--- linux-2.6.23-rc6.orig/include/linux/fs.h
+++ linux-2.6.23-rc6/include/linux/fs.h
@@ -595,6 +595,12 @@ struct inode {
 	void			*i_security;
 #endif
 	void			*i_private; /* fs or device private pointer */
+
+#ifdef CONFIG_PROC_FILECACHE_EXTRAS
+	unsigned int		i_access_count;	/* opened how many times? */
+	uid_t			i_cuid;		/* opened first by which user? */
+	char			i_comm[16];	/* opened first by which app? */
+#endif
 };
 
 /*
@@ -683,6 +689,13 @@ static inline unsigned imajor(const stru
 	return MAJOR(inode->i_rdev);
 }
 
+static inline void inode_accessed(struct inode *inode)
+{
+#ifdef CONFIG_PROC_FILECACHE_EXTRAS
+	inode->i_access_count++;
+#endif
+}
+
 extern struct block_device *I_BDEV(struct inode *inode);
 
 struct fown_struct {
--- linux-2.6.23-rc6.orig/fs/open.c
+++ linux-2.6.23-rc6/fs/open.c
@@ -765,6 +765,7 @@ static struct file *__dentry_open(struct
 			goto cleanup_all;
 	}
 
+	inode_accessed(inode);
 	f->f_flags &= ~(O_CREAT | O_EXCL | O_NOCTTY | O_TRUNC);
 
 	file_ra_state_init(&f->f_ra, f->f_mapping->host->i_mapping);
--- linux-2.6.23-rc6.orig/fs/Kconfig
+++ linux-2.6.23-rc6/fs/Kconfig
@@ -1028,6 +1028,36 @@ config CONFIGFS_FS
 	  Both sysfs and configfs can and should exist together on the
 	  same system. One is not a replacement for the other.
 
+config PROC_FILECACHE
+	tristate "/proc/filecache support"
+	default m
+	depends on PROC_FS
+	help
+	  This option creates a file /proc/filecache which enables one to
+	  query/drop the cached files in memory.
+
+	  A quick start guide:
+
+	  # echo 'ls' > /proc/filecache
+	  # head /proc/filecache
+
+	  # echo 'cat /bin/bash' > /proc/filecache
+	  # head /proc/filecache
+
+	  # echo 'drop pagecache' > /proc/filecache
+	  # echo 'drop slabcache' > /proc/filecache
+
+	  For more details, please check Documentation/filesystems/proc.txt .
+
+	  It can be a handy tool for sysadms and desktop users.
+
+config PROC_FILECACHE_EXTRAS
+	bool "track extra states"
+	default y
+	depends on PROC_FILECACHE
+	help
+	  Track extra states that costs a little more time/space.
+
 endmenu
 
 menu "Miscellaneous filesystems"
--- linux-2.6.23-rc6.orig/fs/proc/Makefile
+++ linux-2.6.23-rc6/fs/proc/Makefile
@@ -2,7 +2,8 @@
 # Makefile for the Linux proc filesystem routines.
 #
 
-obj-$(CONFIG_PROC_FS) += proc.o
+obj-$(CONFIG_PROC_FS)		+= proc.o
+obj-$(CONFIG_PROC_FILECACHE)	+= filecache.o
 
 proc-y			:= nommu.o task_nommu.o
 proc-$(CONFIG_MMU)	:= mmu.o task_mmu.o

--jI8keyz6grp/JLjh--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
