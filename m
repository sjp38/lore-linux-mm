Received: from mail.intermedia.net ([207.5.44.129])
	by kvack.org (8.8.7/8.8.7) with SMTP id PAA04061
	for <linux-mm@kvack.org>; Wed, 12 May 1999 15:45:31 -0400
Received: from [134.96.127.77] by mail.colorfullife.com (NTMail 3.03.0017/1.abcr) with ESMTP id ma370772 for <linux-mm@kvack.org>; Wed, 12 May 1999 12:45:55 -0700
Message-ID: <3739DA3E.20ACC175@colorfullife.com>
Date: Wed, 12 May 1999 21:45:02 +0200
From: Manfred Spraul <manfreds@colorfullife.com>
Reply-To: masp0008@stud.uni-sb.de
MIME-Version: 1.0
Subject: Re: Swap Questions (includes possible bug) - swapfile.c / swap.c
References: <003f01be9c62$75765550$c80c17ac@clmsdev.local> <14137.51764.951033.152486@dukat.scot.redhat.com>
Content-Type: multipart/mixed;
 boundary="------------B11A5DF7FFF27357F3C3C859"
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Manfred Spraul <masp0008@stud.uni-sb.de>, Rik van Riel <riel@nl.linux.org>, Joseph Pranevich <knight@baltimore.wwaves.com>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------B11A5DF7FFF27357F3C3C859
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

"Stephen C. Tweedie" wrote:
> 
> Hi,
> 
> On Wed, 12 May 1999 12:30:27 +0200, "Manfred Spraul"
> <masp0008@stud.uni-sb.de> said:
> 
> > There is another problem with this line:
> > set_blocksize() also means that the previous block size
> > doesn't work anymore:
> > if you accidentially enter 'swapon /dev/hda1' (my root drive)
> > instead of 'swapon /dev/hda3', then you have to fsck:
> 
> Yep, it would make perfect sense to move the set_blocksize to be after
> the EBUSY check.

Unfortunately that doesn't solve the problem:
The current EBUSY check checks that the partition is not used as a
swap partition, it doesn't check the VFS, and it doesn't check
whether the RAID driver uses the volume.

I've attached an old patch (vs.2.2.6):
I've send that patch to linux-kernel@vger, Alan (..wait until Linus
returns from vacation..), Linus (no reply).

The patch adds a bitmap to the block cache for EBUSY checks.
Actually, we can use this bitmap for other bits if we use devfs and
dynamic MAJOR/MINOR codes:
we must replace all 'MAJOR==LOOP', 'MAJOR==IDE' etc. if we want to
support dynamic block device MAJOR/MINOR's.

Additionally, we save 6-8 kB kernel memory. (ro_bits was an 8 kB
static array).

If you think that the patch is usefull, then I'll make a new patch
vs 2.3.0, otherwise I'll wait until devfs is added, and I'll
try to write a larger patch (dynamic MAJOR/MINOR for block cache)
that includes this one.

--
	Manfred
--------------B11A5DF7FFF27357F3C3C859
Content-Type: text/plain; charset=us-ascii;
 name="patch_busy-2.2.6"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch_busy-2.2.6"

diff -r -u -P -x CVS -x *,v 2.2.6/drivers/block/ll_rw_blk.c current/drivers/block/ll_rw_blk.c
--- 2.2.6/drivers/block/ll_rw_blk.c	Wed Mar 31 00:56:57 1999
+++ current/drivers/block/ll_rw_blk.c	Thu Apr 22 18:02:20 1999
@@ -16,6 +16,7 @@
 #include <linux/config.h>
 #include <linux/locks.h>
 #include <linux/mm.h>
+#include <linux/slab.h>
 #include <linux/init.h>
 
 #include <asm/system.h>
@@ -241,8 +242,24 @@
 }
 
 /* RO fail safe mechanism */
+/* device busy: (C) Manfred Spraul masp0008@stud.uni-sb.de */
 
-static long ro_bits[MAX_BLKDEV][8];
+struct kdev_bits {
+	unsigned char ro_bits[(1U << MINORBITS)/8];
+	unsigned char busy_bits[(1U << MINORBITS)/8];
+};
+
+static struct kdev_bits* kdev_info[MAX_BLKDEV] = { NULL, NULL };
+
+#define ALLOC_KDEV_BITS(major) \
+	if (kdev_info[major] == NULL) { \
+		kdev_info[major] = kmalloc(sizeof(struct kdev_bits),GFP_KERNEL); \
+		if(kdev_info[major] == NULL) { \
+			printk("ALLOC_KDEV_BITS() failed due to ENOMEM.\n"); \
+			return; \
+		} \
+		memset(kdev_info[major],0,sizeof(struct kdev_bits)); \
+	}
 
 int is_read_only(kdev_t dev)
 {
@@ -251,7 +268,8 @@
 	major = MAJOR(dev);
 	minor = MINOR(dev);
 	if (major < 0 || major >= MAX_BLKDEV) return 0;
-	return ro_bits[major][minor >> 5] & (1 << (minor & 31));
+	if (kdev_info[major] == NULL) return 0;
+     	return kdev_info[major]->ro_bits[minor >> 3] & (1 << (minor & 7));
 }
 
 void set_device_ro(kdev_t dev,int flag)
@@ -261,10 +279,39 @@
 	major = MAJOR(dev);
 	minor = MINOR(dev);
 	if (major < 0 || major >= MAX_BLKDEV) return;
-	if (flag) ro_bits[major][minor >> 5] |= 1 << (minor & 31);
-	else ro_bits[major][minor >> 5] &= ~(1 << (minor & 31));
+	ALLOC_KDEV_BITS(major)
+	if (flag)
+		kdev_info[major]->ro_bits[minor >> 3] |= 1 << (minor & 7);
+	 else
+		kdev_info[major]->ro_bits[minor >> 3] &= ~(1 << (minor & 7));
+}
+
+int is_device_busy(kdev_t dev)
+{
+	int minor,major;
+
+	major = MAJOR(dev);
+	minor = MINOR(dev);
+	if (major < 0 || major >= MAX_BLKDEV) return 0;
+	if (kdev_info[major] == NULL) return 0;
+	return kdev_info[major]->busy_bits[minor >> 3] & (1 << (minor & 7));
 }
 
+void set_device_busy(kdev_t dev,int flag)
+{
+	int minor,major;
+	
+	major = MAJOR(dev);
+	minor = MINOR(dev);
+	if (major < 0 || major >= MAX_BLKDEV) return;
+	ALLOC_KDEV_BITS(major)
+	if (flag)
+		kdev_info[major]->busy_bits[minor >> 3] |= 1 << (minor & 7);
+	 else
+		kdev_info[major]->busy_bits[minor >> 3] &= ~(1 << (minor & 7));
+}
+
+
 static inline void drive_stat_acct(int cmd, unsigned long nr_sectors,
                                    short disk_index)
 {
@@ -731,7 +778,6 @@
 		req->rq_status = RQ_INACTIVE;
 		req->next = NULL;
 	}
-	memset(ro_bits,0,sizeof(ro_bits));
 	memset(max_readahead, 0, sizeof(max_readahead));
 	memset(max_sectors, 0, sizeof(max_sectors));
 #ifdef CONFIG_AMIGA_Z2RAM
diff -r -u -P -x CVS -x *,v 2.2.6/fs/super.c current/fs/super.c
--- 2.2.6/fs/super.c	Tue Apr 20 13:41:57 1999
+++ current/fs/super.c	Thu Apr 22 18:02:20 1999
@@ -131,6 +131,7 @@
 		vfsmnttail->mnt_next = lptr;
 		vfsmnttail = lptr;
 	}
+	set_device_busy(sb->s_dev,1);
 out:
 	return lptr;
 }
@@ -165,6 +166,8 @@
 	kfree(tofree->mnt_devname);
 	kfree(tofree->mnt_dirname);
 	kfree_s(tofree, sizeof(struct vfsmount));
+
+	set_device_busy(dev,0);
 }
 
 int register_filesystem(struct file_system_type * fs)
@@ -873,6 +876,8 @@
 	if (dir_d->d_covers != dir_d)
 		goto dput_and_out;
 
+	if (is_device_busy(dev))
+		goto dput_and_out;
 	/*
 	 * Note: If the superblock already exists,
 	 * read_super just does a get_super().
diff -r -u -P -x CVS -x *,v 2.2.6/include/linux/fs.h current/include/linux/fs.h
--- 2.2.6/include/linux/fs.h	Tue Apr 20 13:41:58 1999
+++ current/include/linux/fs.h	Thu Apr 22 18:02:20 1999
@@ -839,6 +839,8 @@
 extern struct buffer_head * find_buffer(kdev_t dev, int block, int size);
 extern void ll_rw_block(int, int, struct buffer_head * bh[]);
 extern int is_read_only(kdev_t);
+extern int is_device_busy(kdev_t);
+extern void set_device_busy(kdev_t dev, int flag);
 extern void __brelse(struct buffer_head *);
 extern inline void brelse(struct buffer_head *buf)
 {
diff -r -u -P -x CVS -x *,v 2.2.6/kernel/ksyms.c current/kernel/ksyms.c
--- 2.2.6/kernel/ksyms.c	Wed Mar 31 00:56:57 1999
+++ current/kernel/ksyms.c	Thu Apr 22 18:02:20 1999
@@ -47,7 +47,7 @@
 #endif
 
 extern char *get_options(char *str, int *ints);
-extern void set_device_ro(kdev_t dev,int flag);
+extern void set_device_ro(kdev_t dev, int flag);
 extern struct file_operations * get_blkfops(unsigned int);
 extern int blkdev_release(struct inode * inode);
 #if !defined(CONFIG_NFSD) && defined(CONFIG_NFSD_MODULE)
@@ -209,6 +209,8 @@
 EXPORT_SYMBOL(blk_dev);
 EXPORT_SYMBOL(is_read_only);
 EXPORT_SYMBOL(set_device_ro);
+EXPORT_SYMBOL(is_device_busy);
+EXPORT_SYMBOL(set_device_busy);
 EXPORT_SYMBOL(bmap);
 EXPORT_SYMBOL(sync_dev);
 EXPORT_SYMBOL(get_blkfops);
diff -r -u -P -x CVS -x *,v 2.2.6/mm/swapfile.c current/mm/swapfile.c
--- 2.2.6/mm/swapfile.c	Wed Mar 31 00:56:57 1999
+++ current/mm/swapfile.c	Thu Apr 22 18:02:20 1999
@@ -414,6 +414,7 @@
 			filp.f_op->release(dentry->d_inode,&filp);
 			filp.f_op->release(dentry->d_inode,&filp);
 		}
+		set_device_busy(p->swap_device,0);
 	}
 	dput(dentry);
 
@@ -531,6 +532,10 @@
 
 	if (S_ISBLK(swap_dentry->d_inode->i_mode)) {
 		p->swap_device = swap_dentry->d_inode->i_rdev;
+		if(is_device_busy(p->swap_device)) {
+			error = -EBUSY;
+			goto bad_swap;
+		}
 		set_blocksize(p->swap_device, PAGE_SIZE);
 		
 		filp.f_dentry = swap_dentry;
@@ -686,6 +691,8 @@
 		swap_info[prev].next = p - swap_info;
 	}
 	error = 0;
+	if(p->swap_device != 0)
+		set_device_busy(p->swap_device,1);
 	goto out;
 bad_swap:
 	if(filp.f_op && filp.f_op->release)


--------------B11A5DF7FFF27357F3C3C859--

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
