Date: Thu, 12 Jul 2007 12:05:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] fix periodic superblock dirty inode flushing
Message-Id: <20070712120519.8a7241dd.akpm@linux-foundation.org>
In-Reply-To: <b040c32a0707112121y21d08438u8ca7f138931827b0@mail.gmail.com>
References: <b040c32a0707112121y21d08438u8ca7f138931827b0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 11 Jul 2007 21:21:19 -0700
"Ken Chen" <kenchen@google.com> wrote:

> Current -mm tree has bucketful of bug fixes in periodic writeback path.
> However, we still hit a glitch where dirty pages on a given inode aren't
> completely flushed to the disk, and system will accumulate large amount
> of dirty pages pass beyond what dirty_expire_interval is designed for.
> 
> The problem is __sync_single_inode() will move inode to sb->s_dirty list
> even when there are more pending dirty pages on that inode.  If there is
> another inode with small amount of dirty pages, we hit a case where loop
> iteration in wb_kupdate() terminates prematurely because wbc.nr_to_write > 0.
> Thus leaving the inode that has large amount of dirty pages behind and it has
> to wait for another dirty_writeback_interval before we flush it again.  It
> effectively only writeout MAX_WRITEBACK_PAGES every dirty_writeback_interval.
> If the rate of dirtying is sufficiently high, system will start accumulate
> large amount of dirty pages.
> 
> So fix it by having another sb->s_more_io list to park the inode while we
> iterate through sb->s_io and allow each dirty inode resides on that sb has
> an equal chance of flushing some amount of dirty pages.
> 

Thanks.  Was this tested in combination with check_dirty_inode_list.patch,
to make sure that the time-orderedness is being retained?


From: Andrew Morton <akpm@linux-foundation.org>

The per-superblock dirty-inode list super_block.s_dirty is supposed to be
sorted in reverse order of each inode's time-of-first-dirtying.  This is so
that the kupdate function can avoid having to walk all the dirty inodes on the
list: it terminates the search as soon as it finds an inode which was dirtied
less than 30 seconds ago (dirty_expire_centisecs).

We have a bunch of several-year-old bugs which cause that list to not be in
the correct reverse-time-order.  The result of this is that under certain
obscure circumstances, inodes get stuck and basically never get written back. 
It has been reported a couple of times, but nobody really cared much because
most people use ordered-mode journalling filesystems, which take care of the
writeback independently.  Plus we will _eventually_ get onto these inodes even
when the list is out of order, and a /bin/sync will still work OK.

However this is a pretty important data-integrity issue for filesystems such
as ext2.


As preparation for fixing these bugs, this patch adds a pile of fantastically
expensive debugging code which checks the sanity of the s_dirty list all over
the place, so we find out as soon as it goes bad.

The debugging code is controlled by /proc/sys/fs/inode_debug, which defaults
to off.  The debugging will disable itself whenever it detects a misordering,
to avoid log spew.

We can remove all this code later.

Cc: Mike Waychison <mikew@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/fs-writeback.c         |   62 +++++++++++++++++++++++++++++++++++-
 include/linux/writeback.h |    1 
 kernel/sysctl.c           |    8 ++++
 3 files changed, 70 insertions(+), 1 deletion(-)

diff -puN fs/fs-writeback.c~check_dirty_inode_list fs/fs-writeback.c
--- a/fs/fs-writeback.c~check_dirty_inode_list
+++ a/fs/fs-writeback.c
@@ -24,6 +24,57 @@
 #include <linux/buffer_head.h>
 #include "internal.h"
 
+int sysctl_inode_debug __read_mostly;
+
+static int __check(struct super_block *sb, int print_stuff)
+{
+	struct list_head *cursor = &sb->s_dirty;
+	unsigned long dirtied_when = 0;
+
+	while ((cursor = cursor->prev) != &sb->s_dirty) {
+		struct inode *inode = list_entry(cursor, struct inode, i_list);
+		if (print_stuff) {
+			printk("%p:%lu\n", inode, inode->dirtied_when);
+		} else {
+			if (dirtied_when &&
+			    time_before(inode->dirtied_when, dirtied_when))
+				return 1;
+			dirtied_when = inode->dirtied_when;
+		}
+	}
+	return 0;
+}
+
+static void __check_dirty_inode_list(struct super_block *sb,
+			struct inode *inode, const char *file, int line)
+{
+	if (!sysctl_inode_debug)
+		return;
+
+	if (__check(sb, 0)) {
+		sysctl_inode_debug = 0;
+		if (inode)
+			printk("%s:%d: s_dirty got screwed up.  inode=%p:%lu\n",
+					file, line, inode, inode->dirtied_when);
+		else
+			printk("%s:%d: s_dirty got screwed up\n", file, line);
+		__check(sb, 1);
+	}
+}
+
+#define check_dirty_inode_list(sb)					\
+	do {								\
+		if (unlikely(sysctl_inode_debug))			\
+		__check_dirty_inode_list(sb, NULL, __FILE__, __LINE__);	\
+	} while (0)
+
+#define check_dirty_inode(inode)					\
+	do {								\
+		if (unlikely(sysctl_inode_debug))			\
+			__check_dirty_inode_list(inode->i_sb, inode,	\
+						__FILE__, __LINE__);	\
+	} while (0)
+
 /**
  *	__mark_inode_dirty -	internal function
  *	@inode: inode to mark
@@ -122,8 +173,10 @@ void __mark_inode_dirty(struct inode *in
 		 * reposition it (that would break s_dirty time-ordering).
 		 */
 		if (!was_dirty) {
+			check_dirty_inode(inode);
 			inode->dirtied_when = jiffies;
 			list_move(&inode->i_list, &sb->s_dirty);
+			check_dirty_inode(inode);
 		}
 	}
 out:
@@ -152,6 +205,7 @@ static void redirty_tail(struct inode *i
 {
 	struct super_block *sb = inode->i_sb;
 
+	check_dirty_inode(inode);
 	if (!list_empty(&sb->s_dirty)) {
 		struct inode *tail_inode;
 
@@ -161,6 +215,7 @@ static void redirty_tail(struct inode *i
 			inode->dirtied_when = jiffies;
 	}
 	list_move(&inode->i_list, &sb->s_dirty);
+	check_dirty_inode(inode);
 }
 
 /*
@@ -374,8 +429,11 @@ int generic_sync_sb_inodes(struct super_
 
 	spin_lock(&inode_lock);
 
-	if (!wbc->for_kupdate || list_empty(&sb->s_io))
+	if (!wbc->for_kupdate || list_empty(&sb->s_io)) {
+		check_dirty_inode_list(sb);
 		list_splice_init(&sb->s_dirty, &sb->s_io);
+		check_dirty_inode_list(sb);
+	}
 
 	while (!list_empty(&sb->s_io)) {
 		int err;
@@ -440,8 +498,10 @@ int generic_sync_sb_inodes(struct super_
 		if (!ret)
 			ret = err;
 		if (wbc->sync_mode == WB_SYNC_HOLD) {
+			check_dirty_inode(inode);
 			inode->dirtied_when = jiffies;
 			list_move(&inode->i_list, &sb->s_dirty);
+			check_dirty_inode(inode);
 		}
 		if (current_is_pdflush())
 			writeback_release(bdi);
diff -puN include/linux/writeback.h~check_dirty_inode_list include/linux/writeback.h
--- a/include/linux/writeback.h~check_dirty_inode_list
+++ a/include/linux/writeback.h
@@ -140,5 +140,6 @@ void writeback_set_ratelimit(void);
 extern int nr_pdflush_threads;	/* Global so it can be exported to sysctl
 				   read-only. */
 
+extern int sysctl_inode_debug;
 
 #endif		/* WRITEBACK_H */
diff -puN kernel/sysctl.c~check_dirty_inode_list kernel/sysctl.c
--- a/kernel/sysctl.c~check_dirty_inode_list
+++ a/kernel/sysctl.c
@@ -1231,6 +1231,14 @@ static ctl_table fs_table[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "inode_debug",
+		.data		= &sysctl_inode_debug,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
 #if defined(CONFIG_BINFMT_MISC) || defined(CONFIG_BINFMT_MISC_MODULE)
 	{
 		.ctl_name	= CTL_UNNUMBERED,
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
