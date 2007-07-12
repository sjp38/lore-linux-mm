Received: from zps19.corp.google.com (zps19.corp.google.com [172.25.146.19])
	by smtp-out.google.com with ESMTP id l6C4LRro009213
	for <linux-mm@kvack.org>; Wed, 11 Jul 2007 21:21:27 -0700
Received: from an-out-0708.google.com (anac38.prod.google.com [10.100.54.38])
	by zps19.corp.google.com with ESMTP id l6C4LK9Q024180
	for <linux-mm@kvack.org>; Wed, 11 Jul 2007 21:21:20 -0700
Received: by an-out-0708.google.com with SMTP id c38so5565ana
        for <linux-mm@kvack.org>; Wed, 11 Jul 2007 21:21:20 -0700 (PDT)
Message-ID: <b040c32a0707112121y21d08438u8ca7f138931827b0@mail.gmail.com>
Date: Wed, 11 Jul 2007 21:21:19 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: [patch] fix periodic superblock dirty inode flushing
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_14789_16882867.1184214079908"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

------=_Part_14789_16882867.1184214079908
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Current -mm tree has bucketful of bug fixes in periodic writeback path.
However, we still hit a glitch where dirty pages on a given inode aren't
completely flushed to the disk, and system will accumulate large amount
of dirty pages pass beyond what dirty_expire_interval is designed for.

The problem is __sync_single_inode() will move inode to sb->s_dirty list
even when there are more pending dirty pages on that inode.  If there is
another inode with small amount of dirty pages, we hit a case where loop
iteration in wb_kupdate() terminates prematurely because wbc.nr_to_write > 0.
Thus leaving the inode that has large amount of dirty pages behind and it has
to wait for another dirty_writeback_interval before we flush it again.  It
effectively only writeout MAX_WRITEBACK_PAGES every dirty_writeback_interval.
If the rate of dirtying is sufficiently high, system will start accumulate
large amount of dirty pages.

So fix it by having another sb->s_more_io list to park the inode while we
iterate through sb->s_io and allow each dirty inode resides on that sb has
an equal chance of flushing some amount of dirty pages.

Signed-off-by: Ken Chen <kenchen@google.com>


diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 6d961d1..a0cf041 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -140,25 +140,11 @@ static int write_inode(struct inode *ino
 }

 /*
- * Redirty an inode, but mark it as the very next-to-be-written inode on its
- * superblock's dirty-inode list.
- * We need to preserve s_dirty's reverse-time-orderedness, so we cheat by
- * setting this inode's dirtied_when to the same value as that of the inode
- * which is presently head-of-list, if present head-of-list is newer than this
- * inode. (head-of-list is the least-recently-dirtied inode: the oldest one).
+ * requeue inode for re-scanning after sb->s_io list is exhausted.
  */
-static void redirty_head(struct inode *inode)
+static void requeue_io(struct inode *inode)
 {
-	struct super_block *sb = inode->i_sb;
-
-	if (!list_empty(&sb->s_dirty)) {
-		struct inode *head_inode;
-
-		head_inode = list_entry(sb->s_dirty.prev, struct inode, i_list);
-		if (time_after(inode->dirtied_when, head_inode->dirtied_when))
-			inode->dirtied_when = head_inode->dirtied_when;
-	}
-	list_move_tail(&inode->i_list, &sb->s_dirty);
+	list_move(&inode->i_list, &inode->i_sb->s_more_io);
 }

 /*
@@ -254,7 +240,7 @@ __sync_single_inode(struct inode *inode,
 				 * uncongested.
 				 */
 				inode->i_state |= I_DIRTY_PAGES;
-				redirty_head(inode);
+				requeue_io(inode);
 			} else {
 				/*
 				 * Otherwise fully redirty the inode so that
@@ -314,7 +300,7 @@ __writeback_single_inode(struct inode *i
 		 * on s_io.  We'll have another go at writing back this inode
 		 * when the s_dirty iodes get moved back onto s_io.
 		 */
-		redirty_head(inode);
+		requeue_io(inode);

 		/*
 		 * Even if we don't actually write the inode itself here,
@@ -409,14 +395,14 @@ sync_sb_inodes(struct super_block *sb, s
 			wbc->encountered_congestion = 1;
 			if (!sb_is_blkdev_sb(sb))
 				break;		/* Skip a congested fs */
-			redirty_head(inode);
+			requeue_io(inode);
 			continue;		/* Skip a congested blockdev */
 		}

 		if (wbc->bdi && bdi != wbc->bdi) {
 			if (!sb_is_blkdev_sb(sb))
 				break;		/* fs has the wrong queue */
-			redirty_head(inode);
+			requeue_io(inode);
 			continue;		/* blockdev has wrong queue */
 		}

@@ -426,8 +412,10 @@ sync_sb_inodes(struct super_block *sb, s

 		/* Was this inode dirtied too recently? */
 		if (wbc->older_than_this && time_after(inode->dirtied_when,
-						*wbc->older_than_this))
+						*wbc->older_than_this)) {
+			list_splice_init(&sb->s_io, sb->s_dirty.prev);
 			break;
+		}

 		/* Is another pdflush already flushing this queue? */
 		if (current_is_pdflush() && !writeback_acquire(bdi))
@@ -457,6 +445,10 @@ sync_sb_inodes(struct super_block *sb, s
 		if (wbc->nr_to_write <= 0)
 			break;
 	}
+
+	if (list_empty(&sb->s_io))
+		list_splice_init(&sb->s_more_io, &sb->s_io);
+
 	return;		/* Leave any unwritten inodes on s_io */
 }

diff --git a/fs/super.c b/fs/super.c
index 5260d62..8c6fa35 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -67,6 +67,7 @@ static struct super_block *alloc_super(s
 		}
 		INIT_LIST_HEAD(&s->s_dirty);
 		INIT_LIST_HEAD(&s->s_io);
+		INIT_LIST_HEAD(&s->s_more_io);
 		INIT_LIST_HEAD(&s->s_files);
 		INIT_LIST_HEAD(&s->s_instances);
 		INIT_HLIST_HEAD(&s->s_anon);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index b3ae77c..e135913 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -934,6 +934,7 @@ #endif
 	struct list_head	s_inodes;	/* all inodes */
 	struct list_head	s_dirty;	/* dirty inodes */
 	struct list_head	s_io;		/* parked for writeback */
+	struct list_head	s_more_io;	/* parked for more writeback */
 	struct hlist_head	s_anon;		/* anonymous dentries for (nfs) exporting */
 	struct list_head	s_files;

------=_Part_14789_16882867.1184214079908
Content-Type: text/x-patch; name=wb-s_more_io.patch; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_f40qguoz
Content-Disposition: attachment; filename="wb-s_more_io.patch"

ZGlmZiAtLWdpdCBhL2ZzL2ZzLXdyaXRlYmFjay5jIGIvZnMvZnMtd3JpdGViYWNrLmMKaW5kZXgg
NmQ5NjFkMS4uYTBjZjA0MSAxMDA2NDQKLS0tIGEvZnMvZnMtd3JpdGViYWNrLmMKKysrIGIvZnMv
ZnMtd3JpdGViYWNrLmMKQEAgLTE0MCwyNSArMTQwLDExIEBAIHN0YXRpYyBpbnQgd3JpdGVfaW5v
ZGUoc3RydWN0IGlub2RlICppbm8KIH0KIAogLyoKLSAqIFJlZGlydHkgYW4gaW5vZGUsIGJ1dCBt
YXJrIGl0IGFzIHRoZSB2ZXJ5IG5leHQtdG8tYmUtd3JpdHRlbiBpbm9kZSBvbiBpdHMKLSAqIHN1
cGVyYmxvY2sncyBkaXJ0eS1pbm9kZSBsaXN0LgotICogV2UgbmVlZCB0byBwcmVzZXJ2ZSBzX2Rp
cnR5J3MgcmV2ZXJzZS10aW1lLW9yZGVyZWRuZXNzLCBzbyB3ZSBjaGVhdCBieQotICogc2V0dGlu
ZyB0aGlzIGlub2RlJ3MgZGlydGllZF93aGVuIHRvIHRoZSBzYW1lIHZhbHVlIGFzIHRoYXQgb2Yg
dGhlIGlub2RlCi0gKiB3aGljaCBpcyBwcmVzZW50bHkgaGVhZC1vZi1saXN0LCBpZiBwcmVzZW50
IGhlYWQtb2YtbGlzdCBpcyBuZXdlciB0aGFuIHRoaXMKLSAqIGlub2RlLiAoaGVhZC1vZi1saXN0
IGlzIHRoZSBsZWFzdC1yZWNlbnRseS1kaXJ0aWVkIGlub2RlOiB0aGUgb2xkZXN0IG9uZSkuCisg
KiByZXF1ZXVlIGlub2RlIGZvciByZS1zY2FubmluZyBhZnRlciBzYi0+c19pbyBsaXN0IGlzIGV4
aGF1c3RlZC4KICAqLwotc3RhdGljIHZvaWQgcmVkaXJ0eV9oZWFkKHN0cnVjdCBpbm9kZSAqaW5v
ZGUpCitzdGF0aWMgdm9pZCByZXF1ZXVlX2lvKHN0cnVjdCBpbm9kZSAqaW5vZGUpCiB7Ci0Jc3Ry
dWN0IHN1cGVyX2Jsb2NrICpzYiA9IGlub2RlLT5pX3NiOwotCi0JaWYgKCFsaXN0X2VtcHR5KCZz
Yi0+c19kaXJ0eSkpIHsKLQkJc3RydWN0IGlub2RlICpoZWFkX2lub2RlOwotCi0JCWhlYWRfaW5v
ZGUgPSBsaXN0X2VudHJ5KHNiLT5zX2RpcnR5LnByZXYsIHN0cnVjdCBpbm9kZSwgaV9saXN0KTsK
LQkJaWYgKHRpbWVfYWZ0ZXIoaW5vZGUtPmRpcnRpZWRfd2hlbiwgaGVhZF9pbm9kZS0+ZGlydGll
ZF93aGVuKSkKLQkJCWlub2RlLT5kaXJ0aWVkX3doZW4gPSBoZWFkX2lub2RlLT5kaXJ0aWVkX3do
ZW47Ci0JfQotCWxpc3RfbW92ZV90YWlsKCZpbm9kZS0+aV9saXN0LCAmc2ItPnNfZGlydHkpOwor
CWxpc3RfbW92ZSgmaW5vZGUtPmlfbGlzdCwgJmlub2RlLT5pX3NiLT5zX21vcmVfaW8pOwogfQog
CiAvKgpAQCAtMjU0LDcgKzI0MCw3IEBAIF9fc3luY19zaW5nbGVfaW5vZGUoc3RydWN0IGlub2Rl
ICppbm9kZSwKIAkJCQkgKiB1bmNvbmdlc3RlZC4KIAkJCQkgKi8KIAkJCQlpbm9kZS0+aV9zdGF0
ZSB8PSBJX0RJUlRZX1BBR0VTOwotCQkJCXJlZGlydHlfaGVhZChpbm9kZSk7CisJCQkJcmVxdWV1
ZV9pbyhpbm9kZSk7CiAJCQl9IGVsc2UgewogCQkJCS8qCiAJCQkJICogT3RoZXJ3aXNlIGZ1bGx5
IHJlZGlydHkgdGhlIGlub2RlIHNvIHRoYXQKQEAgLTMxNCw3ICszMDAsNyBAQCBfX3dyaXRlYmFj
a19zaW5nbGVfaW5vZGUoc3RydWN0IGlub2RlICppCiAJCSAqIG9uIHNfaW8uICBXZSdsbCBoYXZl
IGFub3RoZXIgZ28gYXQgd3JpdGluZyBiYWNrIHRoaXMgaW5vZGUKIAkJICogd2hlbiB0aGUgc19k
aXJ0eSBpb2RlcyBnZXQgbW92ZWQgYmFjayBvbnRvIHNfaW8uCiAJCSAqLwotCQlyZWRpcnR5X2hl
YWQoaW5vZGUpOworCQlyZXF1ZXVlX2lvKGlub2RlKTsKIAogCQkvKgogCQkgKiBFdmVuIGlmIHdl
IGRvbid0IGFjdHVhbGx5IHdyaXRlIHRoZSBpbm9kZSBpdHNlbGYgaGVyZSwKQEAgLTQwOSwxNCAr
Mzk1LDE0IEBAIHN5bmNfc2JfaW5vZGVzKHN0cnVjdCBzdXBlcl9ibG9jayAqc2IsIHMKIAkJCXdi
Yy0+ZW5jb3VudGVyZWRfY29uZ2VzdGlvbiA9IDE7CiAJCQlpZiAoIXNiX2lzX2Jsa2Rldl9zYihz
YikpCiAJCQkJYnJlYWs7CQkvKiBTa2lwIGEgY29uZ2VzdGVkIGZzICovCi0JCQlyZWRpcnR5X2hl
YWQoaW5vZGUpOworCQkJcmVxdWV1ZV9pbyhpbm9kZSk7CiAJCQljb250aW51ZTsJCS8qIFNraXAg
YSBjb25nZXN0ZWQgYmxvY2tkZXYgKi8KIAkJfQogCiAJCWlmICh3YmMtPmJkaSAmJiBiZGkgIT0g
d2JjLT5iZGkpIHsKIAkJCWlmICghc2JfaXNfYmxrZGV2X3NiKHNiKSkKIAkJCQlicmVhazsJCS8q
IGZzIGhhcyB0aGUgd3JvbmcgcXVldWUgKi8KLQkJCXJlZGlydHlfaGVhZChpbm9kZSk7CisJCQly
ZXF1ZXVlX2lvKGlub2RlKTsKIAkJCWNvbnRpbnVlOwkJLyogYmxvY2tkZXYgaGFzIHdyb25nIHF1
ZXVlICovCiAJCX0KIApAQCAtNDI2LDggKzQxMiwxMCBAQCBzeW5jX3NiX2lub2RlcyhzdHJ1Y3Qg
c3VwZXJfYmxvY2sgKnNiLCBzCiAKIAkJLyogV2FzIHRoaXMgaW5vZGUgZGlydGllZCB0b28gcmVj
ZW50bHk/ICovCiAJCWlmICh3YmMtPm9sZGVyX3RoYW5fdGhpcyAmJiB0aW1lX2FmdGVyKGlub2Rl
LT5kaXJ0aWVkX3doZW4sCi0JCQkJCQkqd2JjLT5vbGRlcl90aGFuX3RoaXMpKQorCQkJCQkJKndi
Yy0+b2xkZXJfdGhhbl90aGlzKSkgeworCQkJbGlzdF9zcGxpY2VfaW5pdCgmc2ItPnNfaW8sIHNi
LT5zX2RpcnR5LnByZXYpOwogCQkJYnJlYWs7CisJCX0KIAogCQkvKiBJcyBhbm90aGVyIHBkZmx1
c2ggYWxyZWFkeSBmbHVzaGluZyB0aGlzIHF1ZXVlPyAqLwogCQlpZiAoY3VycmVudF9pc19wZGZs
dXNoKCkgJiYgIXdyaXRlYmFja19hY3F1aXJlKGJkaSkpCkBAIC00NTcsNiArNDQ1LDEwIEBAIHN5
bmNfc2JfaW5vZGVzKHN0cnVjdCBzdXBlcl9ibG9jayAqc2IsIHMKIAkJaWYgKHdiYy0+bnJfdG9f
d3JpdGUgPD0gMCkKIAkJCWJyZWFrOwogCX0KKworCWlmIChsaXN0X2VtcHR5KCZzYi0+c19pbykp
CisJCWxpc3Rfc3BsaWNlX2luaXQoJnNiLT5zX21vcmVfaW8sICZzYi0+c19pbyk7CisKIAlyZXR1
cm47CQkvKiBMZWF2ZSBhbnkgdW53cml0dGVuIGlub2RlcyBvbiBzX2lvICovCiB9CiAKZGlmZiAt
LWdpdCBhL2ZzL3N1cGVyLmMgYi9mcy9zdXBlci5jCmluZGV4IDUyNjBkNjIuLjhjNmZhMzUgMTAw
NjQ0Ci0tLSBhL2ZzL3N1cGVyLmMKKysrIGIvZnMvc3VwZXIuYwpAQCAtNjcsNiArNjcsNyBAQCBz
dGF0aWMgc3RydWN0IHN1cGVyX2Jsb2NrICphbGxvY19zdXBlcihzCiAJCX0KIAkJSU5JVF9MSVNU
X0hFQUQoJnMtPnNfZGlydHkpOwogCQlJTklUX0xJU1RfSEVBRCgmcy0+c19pbyk7CisJCUlOSVRf
TElTVF9IRUFEKCZzLT5zX21vcmVfaW8pOwogCQlJTklUX0xJU1RfSEVBRCgmcy0+c19maWxlcyk7
CiAJCUlOSVRfTElTVF9IRUFEKCZzLT5zX2luc3RhbmNlcyk7CiAJCUlOSVRfSExJU1RfSEVBRCgm
cy0+c19hbm9uKTsKZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvZnMuaCBiL2luY2x1ZGUvbGlu
dXgvZnMuaAppbmRleCBiM2FlNzdjLi5lMTM1OTEzIDEwMDY0NAotLS0gYS9pbmNsdWRlL2xpbnV4
L2ZzLmgKKysrIGIvaW5jbHVkZS9saW51eC9mcy5oCkBAIC05MzQsNiArOTM0LDcgQEAgI2VuZGlm
CiAJc3RydWN0IGxpc3RfaGVhZAlzX2lub2RlczsJLyogYWxsIGlub2RlcyAqLwogCXN0cnVjdCBs
aXN0X2hlYWQJc19kaXJ0eTsJLyogZGlydHkgaW5vZGVzICovCiAJc3RydWN0IGxpc3RfaGVhZAlz
X2lvOwkJLyogcGFya2VkIGZvciB3cml0ZWJhY2sgKi8KKwlzdHJ1Y3QgbGlzdF9oZWFkCXNfbW9y
ZV9pbzsJLyogcGFya2VkIGZvciBtb3JlIHdyaXRlYmFjayAqLwogCXN0cnVjdCBobGlzdF9oZWFk
CXNfYW5vbjsJCS8qIGFub255bW91cyBkZW50cmllcyBmb3IgKG5mcykgZXhwb3J0aW5nICovCiAJ
c3RydWN0IGxpc3RfaGVhZAlzX2ZpbGVzOwogCg==
------=_Part_14789_16882867.1184214079908--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
