Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
	by kanga.kvack.org (Postfix) with ESMTP id D10A16B025E
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 05:58:25 -0400 (EDT)
Received: by oibi136 with SMTP id i136so92312319oib.3
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 02:58:25 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id wv7si9004027obb.8.2015.09.15.02.58.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 15 Sep 2015 02:58:25 -0700 (PDT)
From: Junichi Nomura <j-nomura@ce.jp.nec.com>
Subject: [PATCH 1/1] fs: global sync to not clear error status of individual
 inodes
Date: Tue, 15 Sep 2015 09:54:13 +0000
Message-ID: <20150915095412.GD13399@xzibit.linux.bs1.fc.nec.co.jp>
References: <20150915094638.GA13399@xzibit.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20150915094638.GA13399@xzibit.linux.bs1.fc.nec.co.jp>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <5E51AEEBA3EF7B4FAFE62E1BB81530E2@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "andi@firstfloor.org" <andi@firstfloor.org>, "fengguang.wu@intel.com" <fengguang.wu@intel.com>, "tony.luck@intel.com" <tony.luck@intel.com>, "liwanp@linux.vnet.ibm.com" <liwanp@linux.vnet.ibm.com>, "david@fromorbit.com" <david@fromorbit.com>, Tejun Heo <tj@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

filemap_fdatawait() is a function to wait for on-going writeback
to complete but also consume and clear error status of the mapping
set during writeback.
The latter functionality is critical for applications to detect
writeback error with system calls like fsync(2)/fdatasync(2).

However filemap_fdatawait() is also used by sync(2) or FIFREEZE
ioctl, which don't check error status of individual mappings.

As a result, fsync() may not be able to detect writeback error
if events happen in the following order:

   Application                    System admin
   ----------------------------------------------------------
   write data on page cache
                                  Run sync command
                                  writeback completes with error
                                  filemap_fdatawait() clears error
   fsync returns success
   (but the data is not on disk)

This patch adds filemap_fdatawait_keep_errors() for call sites where
writeback error is not handled so that they don't clear error status.

Signed-off-by: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
---
 fs/fs-writeback.c  |  8 +++++++-
 fs/sync.c          |  2 +-
 include/linux/fs.h |  1 +
 mm/filemap.c       | 35 ++++++++++++++++++++++++++++++++---
 4 files changed, 41 insertions(+), 5 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 587ac08..df52aad 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -2121,7 +2121,13 @@ static void wait_sb_inodes(struct super_block *sb)
 		iput(old_inode);
 		old_inode =3D inode;
=20
-		filemap_fdatawait(mapping);
+		/*
+		 * Wait for on-going writeback to complete
+		 * but not consume error status on this mapping.
+		 * Otherwise application may fail to catch writeback error
+		 * using fsync(2).
+		 */
+		filemap_fdatawait_keep_errors(mapping);
=20
 		cond_resched();
=20
diff --git a/fs/sync.c b/fs/sync.c
index fbc98ee..e2b7a77 100644
--- a/fs/sync.c
+++ b/fs/sync.c
@@ -86,7 +86,7 @@ static void fdatawrite_one_bdev(struct block_device *bdev=
, void *arg)
=20
 static void fdatawait_one_bdev(struct block_device *bdev, void *arg)
 {
-	filemap_fdatawait(bdev->bd_inode->i_mapping);
+	filemap_fdatawait_keep_errors(bdev->bd_inode->i_mapping);
 }
=20
 /*
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 72d8a84..9355f37 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2422,6 +2422,7 @@ extern int write_inode_now(struct inode *, int);
 extern int filemap_fdatawrite(struct address_space *);
 extern int filemap_flush(struct address_space *);
 extern int filemap_fdatawait(struct address_space *);
+extern void filemap_fdatawait_keep_errors(struct address_space *);
 extern int filemap_fdatawait_range(struct address_space *, loff_t lstart,
 				   loff_t lend);
 extern int filemap_write_and_wait(struct address_space *mapping);
diff --git a/mm/filemap.c b/mm/filemap.c
index 72940fb..059050a 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -340,14 +340,14 @@ EXPORT_SYMBOL(filemap_flush);
  * Walk the list of under-writeback pages of the given address space
  * in the given range and wait for all of them.
  */
-int filemap_fdatawait_range(struct address_space *mapping, loff_t start_by=
te,
-			    loff_t end_byte)
+static int __filemap_fdatawait_range(struct address_space *mapping,
+				     loff_t start_byte, loff_t end_byte)
 {
 	pgoff_t index =3D start_byte >> PAGE_CACHE_SHIFT;
 	pgoff_t end =3D end_byte >> PAGE_CACHE_SHIFT;
 	struct pagevec pvec;
 	int nr_pages;
-	int ret2, ret =3D 0;
+	int ret =3D 0;
=20
 	if (end_byte < start_byte)
 		goto out;
@@ -374,6 +374,15 @@ int filemap_fdatawait_range(struct address_space *mapp=
ing, loff_t start_byte,
 		cond_resched();
 	}
 out:
+	return ret;
+}
+
+int filemap_fdatawait_range(struct address_space *mapping, loff_t start_by=
te,
+			    loff_t end_byte)
+{
+	int ret, ret2;
+
+	ret =3D __filemap_fdatawait_range(mapping, start_byte, end_byte);
 	ret2 =3D filemap_check_errors(mapping);
 	if (!ret)
 		ret =3D ret2;
@@ -382,6 +391,26 @@ out:
 }
 EXPORT_SYMBOL(filemap_fdatawait_range);
=20
+/*
+ * As filemap_check_errors() consumes and clears error status of mapping,
+ * filemap_fdatawait() should be used only when the caller is responsible
+ * for handling the error.
+ *
+ * Use filemap_fdatawait_keep_errors() if callers just want to wait for
+ * witeback and don't handle errors themselves.
+ * Expected call sites are system-wide / filesystem-wide data flushers:
+ * e.g. sync(2), fsfreeze(8)
+ */
+void filemap_fdatawait_keep_errors(struct address_space *mapping)
+{
+	loff_t i_size =3D i_size_read(mapping->host);
+
+	if (i_size =3D=3D 0)
+		return;
+
+	__filemap_fdatawait_range(mapping, 0, i_size - 1);
+}
+
 /**
  * filemap_fdatawait - wait for all under-writeback pages to complete
  * @mapping: address space structure to wait for
--=20
2.1.0=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
