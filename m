Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C51D06B0078
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 08:58:15 -0500 (EST)
Date: Thu, 14 Jan 2010 21:56:05 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 1/8] vfs: fix too big f_pos handling
Message-ID: <20100114135604.GA13382@localhost>
References: <20100113140955.GA18593@localhost> <20100114051308.GA14616@ZenIV.linux.org.uk> <20100114144250.ebbe6601.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100114144250.ebbe6601.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 14, 2010 at 01:42:50PM +0800, KAMEZAWA Hiroyuki wrote:
> On Thu, 14 Jan 2010 05:13:08 +0000
> Al Viro <viro@ZenIV.linux.org.uk> wrote:
> 
> > On Wed, Jan 13, 2010 at 10:09:56PM +0800, Wu, Fengguang wrote:
> > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > 
> > > Now, rw_verify_area() checsk f_pos is negative or not. And if
> > > negative, returns -EINVAL.
> > > 
> > > But, some special files as /dev/(k)mem and /proc/<pid>/mem etc..
> > > has negative offsets. And we can't do any access via read/write
> > > to the file(device).
> > > 
> > > This patch introduce a flag S_VERYBIG and allow negative file
> > > offsets.
> > 
> > Ehh...  FMODE_NEG_OFFSET in file->f_mode, perhaps?
> > 
> Any method is okay for me.
> I was just not sure where I could modify without problem.
> If modifing f_mode is allowed, I'll write new version.
> 
> Thank you for advice. 
> 
> I'm sorry that I don't have enough time this week. So, I'll try next week.
> I think dropping this patch itself has no big influence to this patch set. 
> (but debug will be harder ;)

I just added FMODE_RANDOM, so hands down to add another ;)

Here is the updated patch, I'd like to submit it in another series
together with the FMODE_RANDOM patch.

Tested OK on /dev/kmem.

Thanks,
Fengguang
---
Subject: vfs: allow negative f_pos with FMODE_NEG_OFFSET

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, rw_verify_area() checsk f_pos is negative or not. And if
negative, returns -EINVAL.

But, some special files as /dev/(k)mem and /proc/<pid>/mem etc..
has negative offsets. And we can't do any access via read/write
to the file(device).

So introduce FMODE_NEG_OFFSET to allow negative file offsets.

Changelog: v5->v6
 - use FMODE_NEG_OFFSET (suggested by Al)
 - rebased onto 2.6.33-rc1

Changelog: v4->v5
 - clean up patches dor /dev/mem.
 - rebased onto 2.6.32-rc1

Changelog: v3->v4
 - make changes in mem.c aligned.
 - change __negative_fpos_check() to return int. 
 - fixed bug in "pos" check.
 - added comments.

Changelog: v2->v3
 - fixed bug in rw_verify_area (it cannot be compiled)

CC: Al Viro <viro@ZenIV.linux.org.uk>
CC: Heiko Carstens <heiko.carstens@de.ibm.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 drivers/char/mem.c |    4 ++++
 fs/proc/base.c     |    2 ++
 fs/read_write.c    |   21 +++++++++++++++++++--
 include/linux/fs.h |    3 +++
 4 files changed, 28 insertions(+), 2 deletions(-)

--- linux.orig/fs/read_write.c	2010-01-14 21:28:00.000000000 +0800
+++ linux/fs/read_write.c	2010-01-14 21:30:41.000000000 +0800
@@ -205,6 +205,20 @@ bad:
 }
 #endif
 
+static int
+__negative_fpos_check(struct file *file, loff_t pos, size_t count)
+{
+	/*
+	 * pos or pos+count is negative here, check overflow.
+	 * too big "count" will be caught in rw_verify_area().
+	 */
+	if ((pos < 0) && (pos + count < pos))
+		return -EOVERFLOW;
+	if (file->f_mode & FMODE_NEG_OFFSET)
+		return 0;
+	return -EINVAL;
+}
+
 /*
  * rw_verify_area doesn't like huge counts. We limit
  * them to something that fits in "int" so that others
@@ -222,8 +236,11 @@ int rw_verify_area(int read_write, struc
 	if (unlikely((ssize_t) count < 0))
 		return retval;
 	pos = *ppos;
-	if (unlikely((pos < 0) || (loff_t) (pos + count) < 0))
-		return retval;
+	if (unlikely((pos < 0) || (loff_t) (pos + count) < 0)) {
+		retval = __negative_fpos_check(file, pos, count);
+		if (retval)
+			return retval;
+	}
 
 	if (unlikely(inode->i_flock && mandatory_lock(inode))) {
 		retval = locks_mandatory_area(
--- linux.orig/include/linux/fs.h	2010-01-14 21:28:00.000000000 +0800
+++ linux/include/linux/fs.h	2010-01-14 21:32:24.000000000 +0800
@@ -93,6 +93,9 @@ struct inodes_stat_t {
 /* Expect random access pattern */
 #define FMODE_RANDOM		((__force fmode_t)0x1000)
 
+/* File is huge (eg. /dev/kmem): treat loff_t as unsigned */
+#define FMODE_NEG_OFFSET	((__force fmode_t)0x2000)
+
 /*
  * The below are the various read and write types that we support. Some of
  * them include behavioral modifiers that send information down to the
--- linux.orig/drivers/char/mem.c	2010-01-14 21:28:00.000000000 +0800
+++ linux/drivers/char/mem.c	2010-01-14 21:33:20.000000000 +0800
@@ -861,6 +861,10 @@ static int memory_open(struct inode *ino
 	if (dev->dev_info)
 		filp->f_mapping->backing_dev_info = dev->dev_info;
 
+	/* Is /dev/mem or /dev/kmem ? */
+	if (dev->dev_info == &directly_mappable_cdev_bdi)
+		filp->f_mode |= FMODE_NEG_OFFSET;
+
 	if (dev->fops->open)
 		return dev->fops->open(inode, filp);
 
--- linux.orig/fs/proc/base.c	2010-01-14 21:28:00.000000000 +0800
+++ linux/fs/proc/base.c	2010-01-14 21:37:08.000000000 +0800
@@ -861,6 +861,8 @@ static const struct file_operations proc
 static int mem_open(struct inode* inode, struct file* file)
 {
 	file->private_data = (void*)((long)current->self_exec_id);
+	/* OK to pass negative loff_t, we can catch out-of-range */
+	file->f_mode |= FMODE_NEG_OFFSET;
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
