Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3EDBA6B004F
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 10:23:07 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20090618132020.GA21444@jukie.net>
References: <20090618132020.GA21444@jukie.net> <20090615123658.GC4721@jukie.net> <20090613182721.GA24072@jukie.net> <25357.1245068384@redhat.com> <25124.1245074627@redhat.com> <20090617120451.GF30951@jukie.net>
Subject: Re: [v2.6.30 nfs+fscache] lockdep: inconsistent lock state
Date: Thu, 18 Jun 2009 15:23:43 +0100
Message-ID: <16247.1245335023@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Bart Trojanowski <bart@jukie.net>
Cc: dhowells@redhat.com, linux-kernel@vger.kernel.org, linux-cachefs@redhat.com, linux-nfs@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Bart Trojanowski <bart@jukie.net> wrote:

> Pid: 29607, comm: kslowd Not tainted 2.6.30-kvm4-dirty #5
> Call Trace:
>  [<ffffffff80235b69>] ? __wake_up+0x27/0x55
>  [<ffffffffa02575cc>] cachefiles_read_waiter+0x5d/0x102 [cachefiles]
>  [<ffffffff80233a55>] __wake_up_common+0x4b/0x7a
>  [<ffffffff80235b7f>] __wake_up+0x3d/0x55
>  [<ffffffff8025a2cd>] __wake_up_bit+0x31/0x33
>  [<ffffffff802a51c6>] unlock_page+0x27/0x2b
>  [<ffffffffa0234fba>] ext3_truncate+0x4bb/0x8fd [ext3]
>  [<ffffffff802ba7d7>] ? unmap_mapping_range+0x232/0x241
>  [<ffffffff8026976d>] ? trace_hardirqs_on+0xd/0xf
>  [<ffffffff802ba987>] vmtruncate+0xc4/0xe4
>  [<ffffffff802ebfae>] inode_setattr+0x30/0x12a
>  [<ffffffffa023299f>] ext3_setattr+0x198/0x1ff [ext3]
>  [<ffffffff802ec241>] notify_change+0x199/0x2e4
>  [<ffffffffa02545b1>] cachefiles_attr_changed+0x10c/0x181 [cachefiles]
>  [<ffffffffa0256110>] ? cachefiles_walk_to_object+0x68b/0x798 [cachefiles]
>  [<ffffffffa0254c72>] cachefiles_lookup_object+0xac/0xd4 [cachefiles]
>  [<ffffffffa017450f>] fscache_lookup_object+0x136/0x14e [fscache]
>  [<ffffffffa0174aad>] fscache_object_slow_work_execute+0x243/0x814 [fscache]
>  [<ffffffff802a4092>] slow_work_thread+0x278/0x43a
>  [<ffffffff8025a2f7>] ? autoremove_wake_function+0x0/0x3d
>  [<ffffffff802a3e1a>] ? slow_work_thread+0x0/0x43a
>  [<ffffffff802a3e1a>] ? slow_work_thread+0x0/0x43a
>  [<ffffffff80259ee8>] kthread+0x5b/0x88
>  [<ffffffff8020ce8a>] child_rip+0xa/0x20
>  [<ffffffff805a1968>] ? _spin_unlock_irq+0x30/0x3b
>  [<ffffffff8020c850>] ? restore_args+0x0/0x30
>  [<ffffffff8023fcf8>] ? finish_task_switch+0x40/0x111
>  [<ffffffff80259e68>] ? kthreadd+0x10f/0x134
>  [<ffffffff80259e8d>] ? kthread+0x0/0x88
>  [<ffffffff8020ce80>] ? child_rip+0x0/0x20
> CacheFiles: I/O Error: Readpage failed on backing file c0000000000830
> FS-Cache: Cache cachefiles stopped due to I/O error

Yeah, I know what that is.  Patch attached.

David
---
From: David Howells <dhowells@redhat.com>
Subject: [PATCH] CacheFiles: Don't write a full page if there's only a partial page to cache

cachefiles_write_page() writes a full page to the backing file for the last
page of the netfs file, even if the netfs file's last page is only a partial
page.

This causes the EOF on the backing file to be extended beyond the EOF of the
netfs, and thus the backing file will be truncated by cachefiles_attr_changed()
called from cachefiles_lookup_object().

So we need to limit the write we make to the backing file on that last page
such that it doesn't push the EOF too far.


Also, if a backing file that has a partial page at the end is expanded, we
discard the partial page and refetch it on the basis that we then have a hole
in the file with invalid data, and should the power go out...  A better way to
deal with this could be to record a note that the partial page contains invalid
data until the correct data is written into it.

This isn't a problem for netfs's that discard the whole backing file if the
file size changes (such as NFS).

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/cachefiles/interface.c     |   20 +++++++++++++++++---
 fs/cachefiles/rdwr.c          |   23 +++++++++++++++++++----
 include/linux/fscache-cache.h |    3 +++
 3 files changed, 39 insertions(+), 7 deletions(-)


diff --git a/fs/cachefiles/interface.c b/fs/cachefiles/interface.c
index 431accd..919a7b6 100644
--- a/fs/cachefiles/interface.c
+++ b/fs/cachefiles/interface.c
@@ -403,12 +403,26 @@ static int cachefiles_attr_changed(struct fscache_object *_object)
 	if (oi_size == ni_size)
 		return 0;
 
-	newattrs.ia_size = ni_size;
-	newattrs.ia_valid = ATTR_SIZE;
-
 	cachefiles_begin_secure(cache, &saved_cred);
 	mutex_lock(&object->backer->d_inode->i_mutex);
+
+	/* if there's an extension to a partial page at the end of the backing
+	 * file, we need to discard the partial page so that we pick up new
+	 * data after it */
+	if (oi_size & ~PAGE_MASK && ni_size > oi_size) {
+		_debug("discard tail %llx", oi_size);
+		newattrs.ia_valid = ATTR_SIZE;
+		newattrs.ia_size = oi_size & PAGE_MASK;
+		ret = notify_change(object->backer, &newattrs);
+		if (ret < 0)
+			goto truncate_failed;
+	}
+
+	newattrs.ia_valid = ATTR_SIZE;
+	newattrs.ia_size = ni_size;
 	ret = notify_change(object->backer, &newattrs);
+
+truncate_failed:
 	mutex_unlock(&object->backer->d_inode->i_mutex);
 	cachefiles_end_secure(cache, saved_cred);
 
diff --git a/fs/cachefiles/rdwr.c b/fs/cachefiles/rdwr.c
index a69787e..86639c1 100644
--- a/fs/cachefiles/rdwr.c
+++ b/fs/cachefiles/rdwr.c
@@ -801,7 +801,8 @@ int cachefiles_write_page(struct fscache_storage *op, struct page *page)
 	struct cachefiles_cache *cache;
 	mm_segment_t old_fs;
 	struct file *file;
-	loff_t pos;
+	loff_t pos, eof;
+	size_t len;
 	void *data;
 	int ret;
 
@@ -835,15 +836,29 @@ int cachefiles_write_page(struct fscache_storage *op, struct page *page)
 		ret = -EIO;
 		if (file->f_op->write) {
 			pos = (loff_t) page->index << PAGE_SHIFT;
+
+			/* we mustn't write more data than we have, so we have
+			 * to beware of a partial page at EOF */
+			eof = object->fscache.store_limit_l;
+			len = PAGE_SIZE;
+			if (eof & ~PAGE_MASK) {
+				ASSERTCMP(pos, <, eof);
+				if (eof - pos < PAGE_SIZE) {
+					_debug("cut short %llx to %llx",
+					       pos, eof);
+					len = eof - pos;
+					ASSERTCMP(pos + len, ==, eof);
+				}
+			}
+
 			data = kmap(page);
 			old_fs = get_fs();
 			set_fs(KERNEL_DS);
 			ret = file->f_op->write(
-				file, (const void __user *) data, PAGE_SIZE,
-				&pos);
+				file, (const void __user *) data, len, &pos);
 			set_fs(old_fs);
 			kunmap(page);
-			if (ret != PAGE_SIZE)
+			if (ret != len)
 				ret = -EIO;
 		}
 		fput(file);
diff --git a/include/linux/fscache-cache.h b/include/linux/fscache-cache.h
index 84d3532..97229be 100644
--- a/include/linux/fscache-cache.h
+++ b/include/linux/fscache-cache.h
@@ -374,6 +374,7 @@ struct fscache_object {
 	struct list_head	dep_link;	/* link in parent's dependents list */
 	struct list_head	pending_ops;	/* unstarted operations on this object */
 	pgoff_t			store_limit;	/* current storage limit */
+	loff_t			store_limit_l;	/* current storage limit */
 };
 
 extern const char *fscache_object_states[];
@@ -414,6 +415,7 @@ void fscache_object_init(struct fscache_object *object,
 	object->events = object->event_mask = 0;
 	object->flags = 0;
 	object->store_limit = 0;
+	object->store_limit_l = 0;
 	object->cache = cache;
 	object->cookie = cookie;
 	object->parent = NULL;
@@ -460,6 +462,7 @@ static inline void fscache_object_lookup_error(struct fscache_object *object)
 static inline
 void fscache_set_store_limit(struct fscache_object *object, loff_t i_size)
 {
+	object->store_limit_l = i_size;
 	object->store_limit = i_size >> PAGE_SHIFT;
 	if (i_size & ~PAGE_MASK)
 		object->store_limit++;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
