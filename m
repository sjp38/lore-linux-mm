Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA8JmIZv027978
	for <linux-mm@kvack.org>; Thu, 8 Nov 2007 14:48:18 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA8JmBLh025656
	for <linux-mm@kvack.org>; Thu, 8 Nov 2007 12:48:13 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA8Jm8FA001062
	for <linux-mm@kvack.org>; Thu, 8 Nov 2007 12:48:08 -0700
Date: Thu, 8 Nov 2007 12:48:07 -0700
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20071108194805.17862.32971.sendpatchset@norville.austin.ibm.com>
In-Reply-To: <20071108194709.17862.16713.sendpatchset@norville.austin.ibm.com>
References: <20071108194709.17862.16713.sendpatchset@norville.austin.ibm.com>
Subject: [RFC:PATCH 09/09] VM tail statistics support
Sender: owner-linux-mm@kvack.org
From: "Luiz Fernando N. Capitulino" <lcapitulino@mandriva.com.br>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

[PATCH]: VM tail statistics support

This patch is a hack which introduces initial statistics support
for the VM tail functionality.

It uses debugfs and does accouting of:

1. Number of times vm_file_tail_pack() have been called
2. Number of times vm_file_tail_unpack() have been called
3. Total size of file tails allocations
4. Number of file tail allocations
5. Bytes saved

Signed-off-by: Luiz Fernando N. Capitulino <lcapitulino@mandriva.com.br>
Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>

---

 mm/file_tail.c |  127 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 126 insertions(+), 1 deletion(-)

diff -Nurp linux008/mm/file_tail.c linux009/mm/file_tail.c
--- linux008/mm/file_tail.c	2007-11-08 10:49:46.000000000 -0600
+++ linux009/mm/file_tail.c	2007-11-08 10:49:46.000000000 -0600
@@ -12,10 +12,51 @@
 
 #include <linux/buffer_head.h>
 #include <linux/fs.h>
+#include <linux/init.h>
+#include <linux/debugfs.h>
 #include <linux/hardirq.h>
 #include <linux/module.h>
+#include <linux/spinlock.h>
 #include <linux/vm_file_tail.h>
 
+struct {
+	struct dentry *root_dir;
+	struct dentry *nr_tails;
+	struct dentry *tail_size;
+	struct dentry *saved_bytes;
+	struct dentry *pack_called;
+	struct dentry *unpack_called;
+	struct dentry *read_called;
+} vm_tail_debugfs;
+
+struct {
+	u32 nr_tails;
+	u32 tail_size;
+	u32 saved_bytes;
+	u32 pack_called;
+	u32 unpack_called;
+	u32 read_called;
+	spinlock_t lock;
+} vm_tail_stats = { .lock = __SPIN_LOCK_UNLOCKED(lock) };
+
+static void vm_file_tail_stats_inc(int length)
+{
+	spin_lock(&vm_tail_stats.lock);
+	vm_tail_stats.nr_tails++;
+	vm_tail_stats.tail_size += length;
+	vm_tail_stats.saved_bytes += (PAGE_SIZE - length);
+	spin_unlock(&vm_tail_stats.lock);
+}
+
+static void vm_file_tail_stats_dec(int length)
+{
+	spin_lock(&vm_tail_stats.lock);
+	vm_tail_stats.nr_tails--;
+	vm_tail_stats.tail_size -= length;
+	vm_tail_stats.saved_bytes -= (PAGE_SIZE - length);
+	spin_unlock(&vm_tail_stats.lock);
+}
+
 /*
  * Free the file tail
  *
@@ -29,7 +70,10 @@ void __vm_file_tail_free(struct address_
 
 	spin_lock_irqsave(&mapping->tail_lock, flags);
 	tail = mapping->tail;
-	mapping->tail = NULL;
+	if (tail) {
+		vm_file_tail_stats_dec(vm_file_tail_length(mapping));
+		mapping->tail = NULL;
+	}
 	spin_unlock_irqrestore(&mapping->tail_lock, flags);
 	kfree(tail);
 }
@@ -49,6 +93,8 @@ void vm_file_tail_unpack(struct address_
 	struct page *page;
 	void *tail;
 
+	vm_tail_stats.unpack_called++;
+
 	if (!mapping->tail)
 		return;
 
@@ -85,6 +131,7 @@ void vm_file_tail_unpack(struct address_
 		add_to_page_cache_lru(page, mapping, index, gfp_mask);
 		unlock_page(page);
 		page_cache_release(page);
+		vm_file_tail_stats_dec(length);
 	} else
 		/* Free the tail */
 		__vm_file_tail_free(mapping);
@@ -120,6 +167,8 @@ int vm_file_tail_pack(struct page *page)
 	struct address_space *mapping;
 	void *tail;
 
+	vm_tail_stats.pack_called++;
+
 	if (TestSetPageLocked(page))
 		return 0;
 
@@ -163,12 +212,86 @@ int vm_file_tail_pack(struct page *page)
 	remove_from_page_cache(page);
 	page_cache_release(page);	/* pagecache ref */
 	ret = 1;
+	vm_file_tail_stats_inc(length);
 
 out:
 	unlock_page(page);
 	return ret;
 }
 
+static int __init create_debugfs_file(const char *name, struct dentry **dir,
+				      u32 *var)
+{
+	*dir = debugfs_create_u32(name, S_IFREG|S_IRUGO,
+				  vm_tail_debugfs.root_dir, var);
+	if (!*dir) {
+		printk(KERN_ERR "ERROR: vm_tail: could not create %s\n", name);
+		return -ENOMEM;
+	}
+	return 0;
+}
+
+static int __init vm_file_tail_init(void)
+{
+	int err;
+
+	vm_tail_debugfs.root_dir = debugfs_create_dir("vm_tail", NULL);
+	if (!vm_tail_debugfs.root_dir) {
+		printk(KERN_ERR "ERROR: %s Could not create root directory\n",
+		       __FUNCTION__);
+		return -ENOMEM;
+	}
+
+	err = create_debugfs_file("nr_tails", &vm_tail_debugfs.nr_tails,
+				  &vm_tail_stats.nr_tails);
+	if (err)
+		goto out_err;
+
+	err = create_debugfs_file("tail_size", &vm_tail_debugfs.tail_size,
+				  &vm_tail_stats.tail_size);
+	if (err)
+		goto out_err1;
+
+	err = create_debugfs_file("saved_bytes", &vm_tail_debugfs.saved_bytes,
+				  &vm_tail_stats.saved_bytes);
+	if (err)
+		goto out_err2;
+
+	err = create_debugfs_file("unpack_called",
+				  &vm_tail_debugfs.unpack_called,
+				  &vm_tail_stats.unpack_called);
+	if (err)
+		goto out_err3;
+
+	err = create_debugfs_file("pack_called", &vm_tail_debugfs.pack_called,
+				  &vm_tail_stats.pack_called);
+	if (err)
+		goto out_err4;
+
+	err = create_debugfs_file("read_called", &vm_tail_debugfs.read_called,
+				  &vm_tail_stats.read_called);
+	if (err)
+		goto out_err5;
+
+	return 0;
+
+out_err5:
+	debugfs_remove(vm_tail_debugfs.pack_called);
+out_err4:
+	debugfs_remove(vm_tail_debugfs.unpack_called);
+out_err3:
+	debugfs_remove(vm_tail_debugfs.saved_bytes);
+out_err2:
+	debugfs_remove(vm_tail_debugfs.tail_size);
+out_err1:
+	debugfs_remove(vm_tail_debugfs.nr_tails);
+out_err:
+	debugfs_remove(vm_tail_debugfs.root_dir);
+	return err;
+}
+
+postcore_initcall(vm_file_tail_init);
+
 void __vm_file_tail_unpack_on_resize(struct inode *inode, loff_t new_size)
 {
 	loff_t old_size = i_size_read(inode);
@@ -211,6 +334,8 @@ int __vm_file_tail_read(struct file *fil
 		return 0;
 	}
 
+	vm_tail_stats.read_called++;
+
 	size = vm_file_tail_length(mapping) - offset;
 	if (size > count)
 		size = count;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
