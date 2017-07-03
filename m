Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9827D6B0279
	for <linux-mm@kvack.org>; Mon,  3 Jul 2017 18:57:28 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id d78so96580175qkb.0
        for <linux-mm@kvack.org>; Mon, 03 Jul 2017 15:57:28 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 36si16581678qku.154.2017.07.03.15.57.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jul 2017 15:57:26 -0700 (PDT)
Date: Mon, 3 Jul 2017 18:57:14 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] vmalloc: respect the GFP_NOIO and GFP_NOFS flags
In-Reply-To: <20170703062905.GB3217@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1707031703590.20792@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1706292221250.21823@file01.intranet.prod.int.rdu2.redhat.com> <20170630081245.GA22917@dhcp22.suse.cz> <alpine.LRH.2.02.1706301410160.8272@file01.intranet.prod.int.rdu2.redhat.com> <20170630204059.GA17255@dhcp22.suse.cz>
 <alpine.LRH.2.02.1706302033230.13879@file01.intranet.prod.int.rdu2.redhat.com> <20170703062905.GB3217@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Vlastimil Babka <vbabka@suse.cz>, Andreas Dilger <adilger@dilger.ca>, John Hubbard <jhubbard@nvidia.com>, David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org



On Mon, 3 Jul 2017, Michal Hocko wrote:

> We can add a warning (or move it from kvmalloc) and hope that the
> respective maintainers will fix those places properly. The reason I
> didn't add the warning to vmalloc and kept it in kvmalloc was to catch
> only new users rather than suddenly splat on existing ones. Note that
> there are users with panic_on_warn enabled.
> 
> Considering how many NOFS users we have in tree I would rather work with
> maintainers to fix them.

So - do you want this patch?

I still believe that the previous patch that pushes 
memalloc_noio/nofs_save into __vmalloc is better than this.

Currently there are 28 __vmalloc callers that use GFP_NOIO or GFP_NOFS, 
three of them already use memalloc_noio_save, 25 don't.

Mikulas

---
 drivers/block/drbd/drbd_bitmap.c        |    8 +++++---
 drivers/infiniband/hw/mlx4/qp.c         |   21 +++++++++++++++++----
 drivers/infiniband/sw/rdmavt/qp.c       |   19 +++++++++++++------
 drivers/infiniband/ulp/ipoib/ipoib_cm.c |    7 +++++--
 drivers/md/dm-bufio.c                   |    2 +-
 drivers/mtd/ubi/io.c                    |   11 +++++++++--
 fs/btrfs/free-space-tree.c              |    7 ++++++-
 fs/ext4/super.c                         |   21 +++++++++++++++++----
 fs/gfs2/dir.c                           |   29 +++++++++++++++++++++--------
 fs/gfs2/quota.c                         |    8 ++++++--
 fs/nfs/blocklayout/extent_tree.c        |    7 ++++++-
 fs/ntfs/malloc.h                        |   11 +++++++++--
 fs/ubifs/debug.c                        |    5 ++++-
 fs/ubifs/lprops.c                       |    5 ++++-
 fs/ubifs/lpt_commit.c                   |   10 ++++++++--
 fs/ubifs/orphan.c                       |    5 ++++-
 fs/ubifs/ubifs.h                        |    1 +
 fs/xfs/kmem.c                           |    2 +-
 mm/page_alloc.c                         |    2 +-
 mm/vmalloc.c                            |    6 ++++++
 net/ceph/ceph_common.c                  |   14 ++++++++++++--
 21 files changed, 156 insertions(+), 45 deletions(-)

Index: linux-2.6/drivers/block/drbd/drbd_bitmap.c
===================================================================
--- linux-2.6.orig/drivers/block/drbd/drbd_bitmap.c
+++ linux-2.6/drivers/block/drbd/drbd_bitmap.c
@@ -26,6 +26,7 @@
 
 #include <linux/bitmap.h>
 #include <linux/vmalloc.h>
+#include <linux/sched/mm.h>
 #include <linux/string.h>
 #include <linux/drbd.h>
 #include <linux/slab.h>
@@ -408,9 +409,10 @@ static struct page **bm_realloc_pages(st
 	bytes = sizeof(struct page *)*want;
 	new_pages = kzalloc(bytes, GFP_NOIO | __GFP_NOWARN);
 	if (!new_pages) {
-		new_pages = __vmalloc(bytes,
-				GFP_NOIO | __GFP_ZERO,
-				PAGE_KERNEL);
+		unsigned noio;
+		noio = memalloc_noio_save();
+		new_pages = vmalloc(bytes);
+		memalloc_noio_restore(noio);
 		if (!new_pages)
 			return NULL;
 	}
Index: linux-2.6/drivers/infiniband/hw/mlx4/qp.c
===================================================================
--- linux-2.6.orig/drivers/infiniband/hw/mlx4/qp.c
+++ linux-2.6/drivers/infiniband/hw/mlx4/qp.c
@@ -37,6 +37,7 @@
 #include <linux/slab.h>
 #include <linux/netdevice.h>
 #include <linux/vmalloc.h>
+#include <linux/sched/mm.h>
 
 #include <rdma/ib_cache.h>
 #include <rdma/ib_pack.h>
@@ -814,14 +815,26 @@ static int create_qp_common(struct mlx4_
 
 		qp->sq.wrid = kmalloc_array(qp->sq.wqe_cnt, sizeof(u64),
 					gfp | __GFP_NOWARN);
-		if (!qp->sq.wrid)
+		if (!qp->sq.wrid) {
+			unsigned noio;
+			if (!(gfp & __GFP_IO))
+				noio = memalloc_noio_save();
 			qp->sq.wrid = __vmalloc(qp->sq.wqe_cnt * sizeof(u64),
-						gfp, PAGE_KERNEL);
+						gfp | __GFP_FS | __GFP_IO, PAGE_KERNEL);
+			if (!(gfp & __GFP_IO))
+				memalloc_noio_restore(noio);
+		}
 		qp->rq.wrid = kmalloc_array(qp->rq.wqe_cnt, sizeof(u64),
 					gfp | __GFP_NOWARN);
-		if (!qp->rq.wrid)
+		if (!qp->rq.wrid) {
+			unsigned noio;
+			if (!(gfp & __GFP_IO))
+				noio = memalloc_noio_save();
 			qp->rq.wrid = __vmalloc(qp->rq.wqe_cnt * sizeof(u64),
-						gfp, PAGE_KERNEL);
+						gfp | __GFP_FS | __GFP_IO, PAGE_KERNEL);
+			if (!(gfp & __GFP_IO))
+				memalloc_noio_restore(noio);
+		}
 		if (!qp->sq.wrid || !qp->rq.wrid) {
 			err = -ENOMEM;
 			goto err_wrid;
Index: linux-2.6/drivers/infiniband/sw/rdmavt/qp.c
===================================================================
--- linux-2.6.orig/drivers/infiniband/sw/rdmavt/qp.c
+++ linux-2.6/drivers/infiniband/sw/rdmavt/qp.c
@@ -49,6 +49,7 @@
 #include <linux/bitops.h>
 #include <linux/lockdep.h>
 #include <linux/vmalloc.h>
+#include <linux/sched/mm.h>
 #include <linux/slab.h>
 #include <rdma/ib_verbs.h>
 #include <rdma/ib_hdrs.h>
@@ -719,11 +720,14 @@ struct ib_qp *rvt_create_qp(struct ib_pd
 		sz = sizeof(struct rvt_sge) *
 			init_attr->cap.max_send_sge +
 			sizeof(struct rvt_swqe);
-		if (gfp == GFP_NOIO)
+		if (gfp == GFP_NOIO) {
+			unsigned noio;
+			noio = memalloc_noio_save();
 			swq = __vmalloc(
 				sqsize * sz,
-				gfp | __GFP_ZERO, PAGE_KERNEL);
-		else
+				gfp | __GFP_FS | __GFP_IO | __GFP_ZERO, PAGE_KERNEL);
+			memalloc_noio_restore(noio);
+		} else
 			swq = vzalloc_node(
 				sqsize * sz,
 				rdi->dparms.node);
@@ -786,12 +790,15 @@ struct ib_qp *rvt_create_qp(struct ib_pd
 				qp->r_rq.wq = vmalloc_user(
 						sizeof(struct rvt_rwq) +
 						qp->r_rq.size * sz);
-			else if (gfp == GFP_NOIO)
+			else if (gfp == GFP_NOIO) {
+				unsigned noio;
+				noio = memalloc_noio_save();
 				qp->r_rq.wq = __vmalloc(
 						sizeof(struct rvt_rwq) +
 						qp->r_rq.size * sz,
-						gfp | __GFP_ZERO, PAGE_KERNEL);
-			else
+						GFP_KERNEL | __GFP_ZERO, PAGE_KERNEL);
+				memalloc_noio_restore(noio);
+			} else
 				qp->r_rq.wq = vzalloc_node(
 						sizeof(struct rvt_rwq) +
 						qp->r_rq.size * sz,
Index: linux-2.6/drivers/infiniband/ulp/ipoib/ipoib_cm.c
===================================================================
--- linux-2.6.orig/drivers/infiniband/ulp/ipoib/ipoib_cm.c
+++ linux-2.6/drivers/infiniband/ulp/ipoib/ipoib_cm.c
@@ -37,6 +37,7 @@
 #include <linux/delay.h>
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
+#include <linux/sched/mm.h>
 #include <linux/moduleparam.h>
 #include <linux/sched/signal.h>
 
@@ -1132,9 +1133,11 @@ static int ipoib_cm_tx_init(struct ipoib
 {
 	struct ipoib_dev_priv *priv = ipoib_priv(p->dev);
 	int ret;
+	unsigned noio;
 
-	p->tx_ring = __vmalloc(ipoib_sendq_size * sizeof *p->tx_ring,
-			       GFP_NOIO, PAGE_KERNEL);
+	noio = memalloc_noio_save();
+	p->tx_ring = vmalloc(ipoib_sendq_size * sizeof *p->tx_ring);
+	memalloc_noio_restore(noio);
 	if (!p->tx_ring) {
 		ret = -ENOMEM;
 		goto err_tx;
Index: linux-2.6/drivers/mtd/ubi/io.c
===================================================================
--- linux-2.6.orig/drivers/mtd/ubi/io.c
+++ linux-2.6/drivers/mtd/ubi/io.c
@@ -89,6 +89,7 @@
 #include <linux/crc32.h>
 #include <linux/err.h>
 #include <linux/slab.h>
+#include <linux/sched/mm.h>
 #include "ubi.h"
 
 static int self_check_not_bad(const struct ubi_device *ubi, int pnum);
@@ -1342,11 +1343,14 @@ static int self_check_write(struct ubi_d
 	size_t read;
 	void *buf1;
 	loff_t addr = (loff_t)pnum * ubi->peb_size + offset;
+	unsigned nofs;
 
 	if (!ubi_dbg_chk_io(ubi))
 		return 0;
 
-	buf1 = __vmalloc(len, GFP_NOFS, PAGE_KERNEL);
+	nofs = memalloc_nofs_save();
+	buf1 = vmalloc(len);
+	memalloc_nofs_restore(nofs);
 	if (!buf1) {
 		ubi_err(ubi, "cannot allocate memory to check writes");
 		return 0;
@@ -1406,11 +1410,14 @@ int ubi_self_check_all_ff(struct ubi_dev
 	int err;
 	void *buf;
 	loff_t addr = (loff_t)pnum * ubi->peb_size + offset;
+	unsigned nofs;
 
 	if (!ubi_dbg_chk_io(ubi))
 		return 0;
 
-	buf = __vmalloc(len, GFP_NOFS, PAGE_KERNEL);
+	nofs = memalloc_nofs_save();
+	buf = vmalloc(len);
+	memalloc_nofs_restore(nofs);
 	if (!buf) {
 		ubi_err(ubi, "cannot allocate memory to check for 0xFFs");
 		return 0;
Index: linux-2.6/fs/btrfs/free-space-tree.c
===================================================================
--- linux-2.6.orig/fs/btrfs/free-space-tree.c
+++ linux-2.6/fs/btrfs/free-space-tree.c
@@ -18,6 +18,7 @@
 
 #include <linux/kernel.h>
 #include <linux/vmalloc.h>
+#include <linux/sched/mm.h>
 #include "ctree.h"
 #include "disk-io.h"
 #include "locking.h"
@@ -154,6 +155,7 @@ static inline u32 free_space_bitmap_size
 static u8 *alloc_bitmap(u32 bitmap_size)
 {
 	void *mem;
+	unsigned nofs;
 
 	/*
 	 * The allocation size varies, observed numbers were < 4K up to 16K.
@@ -167,7 +169,10 @@ static u8 *alloc_bitmap(u32 bitmap_size)
 	if (mem)
 		return mem;
 
-	return __vmalloc(bitmap_size, GFP_NOFS | __GFP_ZERO, PAGE_KERNEL);
+	nofs = memalloc_nofs_save();
+	mem = __vmalloc(bitmap_size, GFP_KERNEL | __GFP_ZERO, PAGE_KERNEL);
+	memalloc_nofs_restore(nofs);
+	return mem;
 }
 
 int convert_free_space_to_bitmaps(struct btrfs_trans_handle *trans,
Index: linux-2.6/fs/ext4/super.c
===================================================================
--- linux-2.6.orig/fs/ext4/super.c
+++ linux-2.6/fs/ext4/super.c
@@ -40,6 +40,7 @@
 #include <linux/dax.h>
 #include <linux/cleancache.h>
 #include <linux/uaccess.h>
+#include <linux/sched/mm.h>
 
 #include <linux/kthread.h>
 #include <linux/freezer.h>
@@ -185,8 +186,14 @@ void *ext4_kvmalloc(size_t size, gfp_t f
 	void *ret;
 
 	ret = kmalloc(size, flags | __GFP_NOWARN);
-	if (!ret)
-		ret = __vmalloc(size, flags, PAGE_KERNEL);
+	if (!ret) {
+		unsigned nofs;
+		if (!(flags & __GFP_FS))
+			nofs = memalloc_nofs_save();
+		ret = __vmalloc(size, flags | __GFP_FS, PAGE_KERNEL);
+		if (!(flags & __GFP_FS))
+			memalloc_nofs_restore(nofs);
+	}
 	return ret;
 }
 
@@ -195,8 +202,14 @@ void *ext4_kvzalloc(size_t size, gfp_t f
 	void *ret;
 
 	ret = kzalloc(size, flags | __GFP_NOWARN);
-	if (!ret)
-		ret = __vmalloc(size, flags | __GFP_ZERO, PAGE_KERNEL);
+	if (!ret) {
+		unsigned nofs;
+		if (!(flags & __GFP_FS))
+			nofs = memalloc_nofs_save();
+		ret = __vmalloc(size, flags | __GFP_FS | __GFP_ZERO, PAGE_KERNEL);
+		if (!(flags & __GFP_FS))
+			memalloc_nofs_restore(nofs);
+	}
 	return ret;
 }
 
Index: linux-2.6/fs/gfs2/dir.c
===================================================================
--- linux-2.6.orig/fs/gfs2/dir.c
+++ linux-2.6/fs/gfs2/dir.c
@@ -62,6 +62,7 @@
 #include <linux/gfs2_ondisk.h>
 #include <linux/crc32.h>
 #include <linux/vmalloc.h>
+#include <linux/sched/mm.h>
 #include <linux/bio.h>
 
 #include "gfs2.h"
@@ -360,8 +361,11 @@ static __be64 *gfs2_dir_get_hash_table(s
 	}
 
 	hc = kmalloc(hsize, GFP_NOFS | __GFP_NOWARN);
-	if (hc == NULL)
-		hc = __vmalloc(hsize, GFP_NOFS, PAGE_KERNEL);
+	if (hc == NULL) {
+		unsigned nofs = memalloc_nofs_save();
+		hc = vmalloc(hsize);
+		memalloc_nofs_restore(nofs);
+	}
 
 	if (hc == NULL)
 		return ERR_PTR(-ENOMEM);
@@ -1172,8 +1176,11 @@ static int dir_double_exhash(struct gfs2
 		return PTR_ERR(hc);
 
 	hc2 = kmalloc(hsize_bytes * 2, GFP_NOFS | __GFP_NOWARN);
-	if (hc2 == NULL)
-		hc2 = __vmalloc(hsize_bytes * 2, GFP_NOFS, PAGE_KERNEL);
+	if (hc2 == NULL) {
+		unsigned nofs = memalloc_nofs_save();
+		hc2 = vmalloc(hsize_bytes * 2);
+		memalloc_nofs_restore(nofs);
+	}
 
 	if (!hc2)
 		return -ENOMEM;
@@ -1333,8 +1340,11 @@ static void *gfs2_alloc_sort_buffer(unsi
 
 	if (size < KMALLOC_MAX_SIZE)
 		ptr = kmalloc(size, GFP_NOFS | __GFP_NOWARN);
-	if (!ptr)
-		ptr = __vmalloc(size, GFP_NOFS, PAGE_KERNEL);
+	if (!ptr) {
+		unsigned nofs = memalloc_nofs_save();
+		ptr = vmalloc(size);
+		memalloc_nofs_restore(nofs);
+	}
 	return ptr;
 }
 
@@ -2000,9 +2010,12 @@ static int leaf_dealloc(struct gfs2_inod
 	memset(&rlist, 0, sizeof(struct gfs2_rgrp_list));
 
 	ht = kzalloc(size, GFP_NOFS | __GFP_NOWARN);
-	if (ht == NULL)
-		ht = __vmalloc(size, GFP_NOFS | __GFP_NOWARN | __GFP_ZERO,
+	if (ht == NULL) {
+		unsigned nofs = memalloc_nofs_save();
+		ht = __vmalloc(size, GFP_KERNEL | __GFP_NOWARN | __GFP_ZERO,
 			       PAGE_KERNEL);
+		memalloc_nofs_restore(nofs);
+	}
 	if (!ht)
 		return -ENOMEM;
 
Index: linux-2.6/fs/gfs2/quota.c
===================================================================
--- linux-2.6.orig/fs/gfs2/quota.c
+++ linux-2.6/fs/gfs2/quota.c
@@ -59,6 +59,7 @@
 #include <linux/bit_spinlock.h>
 #include <linux/jhash.h>
 #include <linux/vmalloc.h>
+#include <linux/sched/mm.h>
 
 #include "gfs2.h"
 #include "incore.h"
@@ -1353,9 +1354,12 @@ int gfs2_quota_init(struct gfs2_sbd *sdp
 	bm_size *= sizeof(unsigned long);
 	error = -ENOMEM;
 	sdp->sd_quota_bitmap = kzalloc(bm_size, GFP_NOFS | __GFP_NOWARN);
-	if (sdp->sd_quota_bitmap == NULL)
-		sdp->sd_quota_bitmap = __vmalloc(bm_size, GFP_NOFS |
+	if (sdp->sd_quota_bitmap == NULL) {
+		unsigned nofs = memalloc_nofs_save();
+		sdp->sd_quota_bitmap = __vmalloc(bm_size, GFP_KERNEL |
 						 __GFP_ZERO, PAGE_KERNEL);
+		memalloc_nofs_restore(nofs);
+	}
 	if (!sdp->sd_quota_bitmap)
 		return error;
 
Index: linux-2.6/fs/nfs/blocklayout/extent_tree.c
===================================================================
--- linux-2.6.orig/fs/nfs/blocklayout/extent_tree.c
+++ linux-2.6/fs/nfs/blocklayout/extent_tree.c
@@ -3,6 +3,7 @@
  */
 
 #include <linux/vmalloc.h>
+#include <linux/sched/mm.h>
 
 #include "blocklayout.h"
 
@@ -570,6 +571,8 @@ ext_tree_prepare_commit(struct nfs4_layo
 retry:
 	ret = ext_tree_encode_commit(bl, start_p + 1, buffer_size, &count, &arg->lastbytewritten);
 	if (unlikely(ret)) {
+		unsigned nofs;
+
 		ext_tree_free_commitdata(arg, buffer_size);
 
 		buffer_size = ext_tree_layoutupdate_size(bl, count);
@@ -581,7 +584,9 @@ retry:
 		if (!arg->layoutupdate_pages)
 			return -ENOMEM;
 
-		start_p = __vmalloc(buffer_size, GFP_NOFS, PAGE_KERNEL);
+		nofs = memalloc_nofs_save();
+		start_p = vmalloc(buffer_size);
+		memalloc_nofs_restore(nofs);
 		if (!start_p) {
 			kfree(arg->layoutupdate_pages);
 			return -ENOMEM;
Index: linux-2.6/fs/ntfs/malloc.h
===================================================================
--- linux-2.6.orig/fs/ntfs/malloc.h
+++ linux-2.6/fs/ntfs/malloc.h
@@ -23,6 +23,7 @@
 #define _LINUX_NTFS_MALLOC_H
 
 #include <linux/vmalloc.h>
+#include <linux/sched/mm.h>
 #include <linux/slab.h>
 #include <linux/highmem.h>
 
@@ -47,8 +48,14 @@ static inline void *__ntfs_malloc(unsign
 		return kmalloc(PAGE_SIZE, gfp_mask & ~__GFP_HIGHMEM);
 		/* return (void *)__get_free_page(gfp_mask); */
 	}
-	if (likely((size >> PAGE_SHIFT) < totalram_pages))
-		return __vmalloc(size, gfp_mask, PAGE_KERNEL);
+	if (likely((size >> PAGE_SHIFT) < totalram_pages)) {
+		unsigned nofs;
+		if (!(gfp_mask & __GFP_FS))
+			nofs = memalloc_nofs_save();
+		return __vmalloc(size, gfp_mask | __GFP_FS, PAGE_KERNEL);
+		if (!(gfp_mask & __GFP_FS))
+			memalloc_nofs_restore(nofs);
+	}
 	return NULL;
 }
 
Index: linux-2.6/fs/ubifs/debug.c
===================================================================
--- linux-2.6.orig/fs/ubifs/debug.c
+++ linux-2.6/fs/ubifs/debug.c
@@ -818,10 +818,13 @@ void ubifs_dump_leb(const struct ubifs_i
 	struct ubifs_scan_leb *sleb;
 	struct ubifs_scan_node *snod;
 	void *buf;
+	unsigned nofs;
 
 	pr_err("(pid %d) start dumping LEB %d\n", current->pid, lnum);
 
-	buf = __vmalloc(c->leb_size, GFP_NOFS, PAGE_KERNEL);
+	nofs = memalloc_nofs_save();
+	buf = vmalloc(c->leb_size);
+	memalloc_nofs_restore(nofs);
 	if (!buf) {
 		ubifs_err(c, "cannot allocate memory for dumping LEB %d", lnum);
 		return;
Index: linux-2.6/fs/ubifs/lprops.c
===================================================================
--- linux-2.6.orig/fs/ubifs/lprops.c
+++ linux-2.6/fs/ubifs/lprops.c
@@ -1034,6 +1034,7 @@ static int scan_check_cb(struct ubifs_in
 	struct ubifs_scan_node *snod;
 	int cat, lnum = lp->lnum, is_idx = 0, used = 0, free, dirty, ret;
 	void *buf = NULL;
+	unsigned nofs;
 
 	cat = lp->flags & LPROPS_CAT_MASK;
 	if (cat != LPROPS_UNCAT) {
@@ -1091,7 +1092,9 @@ static int scan_check_cb(struct ubifs_in
 		}
 	}
 
-	buf = __vmalloc(c->leb_size, GFP_NOFS, PAGE_KERNEL);
+	nofs = memalloc_nofs_save();
+	buf = vmalloc(c->leb_size);
+	memalloc_nofs_restore(nofs);
 	if (!buf)
 		return -ENOMEM;
 
Index: linux-2.6/fs/ubifs/lpt_commit.c
===================================================================
--- linux-2.6.orig/fs/ubifs/lpt_commit.c
+++ linux-2.6/fs/ubifs/lpt_commit.c
@@ -1630,11 +1630,14 @@ static int dbg_check_ltab_lnum(struct ub
 	int err, len = c->leb_size, dirty = 0, node_type, node_num, node_len;
 	int ret;
 	void *buf, *p;
+	unsigned nofs;
 
 	if (!dbg_is_chk_lprops(c))
 		return 0;
 
-	buf = p = __vmalloc(c->leb_size, GFP_NOFS, PAGE_KERNEL);
+	nofs = memalloc_nofs_save();
+	buf = p = vmalloc(c->leb_size);
+	memalloc_nofs_restore(nofs);
 	if (!buf) {
 		ubifs_err(c, "cannot allocate memory for ltab checking");
 		return 0;
@@ -1881,9 +1884,12 @@ static void dump_lpt_leb(const struct ub
 {
 	int err, len = c->leb_size, node_type, node_num, node_len, offs;
 	void *buf, *p;
+	unsigned nofs;
 
 	pr_err("(pid %d) start dumping LEB %d\n", current->pid, lnum);
-	buf = p = __vmalloc(c->leb_size, GFP_NOFS, PAGE_KERNEL);
+	nofs = memalloc_nofs_save();
+	buf = p = vmalloc(c->leb_size);
+	memalloc_nofs_restore(nofs);
 	if (!buf) {
 		ubifs_err(c, "cannot allocate memory to dump LPT");
 		return;
Index: linux-2.6/fs/ubifs/orphan.c
===================================================================
--- linux-2.6.orig/fs/ubifs/orphan.c
+++ linux-2.6/fs/ubifs/orphan.c
@@ -880,12 +880,15 @@ static int dbg_scan_orphans(struct ubifs
 {
 	int lnum, err = 0;
 	void *buf;
+	unsigned nofs;
 
 	/* Check no-orphans flag and skip this if no orphans */
 	if (c->no_orphs)
 		return 0;
 
-	buf = __vmalloc(c->leb_size, GFP_NOFS, PAGE_KERNEL);
+	nofs = memalloc_nofs_save();
+	buf = vmalloc(c->leb_size);
+	memalloc_nofs_restore(nofs);
 	if (!buf) {
 		ubifs_err(c, "cannot allocate memory to check orphans");
 		return 0;
Index: linux-2.6/mm/vmalloc.c
===================================================================
--- linux-2.6.orig/mm/vmalloc.c
+++ linux-2.6/mm/vmalloc.c
@@ -1671,6 +1671,12 @@ static void *__vmalloc_area_node(struct
 	const gfp_t nested_gfp = (gfp_mask & GFP_RECLAIM_MASK) | __GFP_ZERO;
 	const gfp_t alloc_mask = gfp_mask | __GFP_HIGHMEM | __GFP_NOWARN;
 
+	/*
+	 * vmalloc uses GFP_KERNEL for some internal allocations (e.g page tables)
+	 * so the given set of flags has to be compatible.
+	 */
+	WARN_ON_ONCE((gfp_mask & GFP_KERNEL) != GFP_KERNEL);
+
 	nr_pages = get_vm_area_size(area) >> PAGE_SHIFT;
 	array_size = (nr_pages * sizeof(struct page *));
 
Index: linux-2.6/net/ceph/ceph_common.c
===================================================================
--- linux-2.6.orig/net/ceph/ceph_common.c
+++ linux-2.6/net/ceph/ceph_common.c
@@ -17,6 +17,7 @@
 #include <linux/statfs.h>
 #include <linux/string.h>
 #include <linux/vmalloc.h>
+#include <linux/sched/mm.h>
 
 
 #include <linux/ceph/ceph_features.h>
@@ -179,13 +180,22 @@ EXPORT_SYMBOL(ceph_compare_options);
 
 void *ceph_kvmalloc(size_t size, gfp_t flags)
 {
+	void *ptr;
+	unsigned noio;
+
 	if (size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER)) {
-		void *ptr = kmalloc(size, flags | __GFP_NOWARN);
+		ptr = kmalloc(size, flags | __GFP_NOWARN);
 		if (ptr)
 			return ptr;
 	}
 
-	return __vmalloc(size, flags, PAGE_KERNEL);
+	if ((flags & (__GFP_FS | __GFP_IO)) != (__GFP_FS | __GFP_IO))
+		noio = memalloc_noio_save();
+	ptr = __vmalloc(size, flags | __GFP_FS | __GFP_IO, PAGE_KERNEL);
+	if ((flags & (__GFP_FS | __GFP_IO)) != (__GFP_FS | __GFP_IO))
+		memalloc_noio_restore(noio);
+
+	return ptr;
 }
 
 
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -7249,7 +7249,7 @@ void *__init alloc_large_system_hash(con
 		if (flags & HASH_EARLY)
 			table = memblock_virt_alloc_nopanic(size, 0);
 		else if (hashdist)
-			table = __vmalloc(size, GFP_ATOMIC, PAGE_KERNEL);
+			table = vmalloc(size);
 		else {
 			/*
 			 * If bucketsize is not a power-of-two, we may free
Index: linux-2.6/drivers/md/dm-bufio.c
===================================================================
--- linux-2.6.orig/drivers/md/dm-bufio.c
+++ linux-2.6/drivers/md/dm-bufio.c
@@ -406,7 +406,7 @@ static void *alloc_buffer_data(struct dm
 	if (gfp_mask & __GFP_NORETRY)
 		noio_flag = memalloc_noio_save();
 
-	ptr = __vmalloc(c->block_size, gfp_mask, PAGE_KERNEL);
+	ptr = __vmalloc(c->block_size, gfp_mask | __GFP_FS | __GFP_IO, PAGE_KERNEL);
 
 	if (gfp_mask & __GFP_NORETRY)
 		memalloc_noio_restore(noio_flag);
Index: linux-2.6/fs/xfs/kmem.c
===================================================================
--- linux-2.6.orig/fs/xfs/kmem.c
+++ linux-2.6/fs/xfs/kmem.c
@@ -67,7 +67,7 @@ kmem_zalloc_large(size_t size, xfs_km_fl
 		nofs_flag = memalloc_nofs_save();
 
 	lflags = kmem_flags_convert(flags);
-	ptr = __vmalloc(size, lflags | __GFP_ZERO, PAGE_KERNEL);
+	ptr = __vmalloc(size, lflags | __GFP_FS | __GFP_IO | __GFP_ZERO, PAGE_KERNEL);
 
 	if (flags & KM_NOFS)
 		memalloc_nofs_restore(nofs_flag);
Index: linux-2.6/fs/ubifs/ubifs.h
===================================================================
--- linux-2.6.orig/fs/ubifs/ubifs.h
+++ linux-2.6/fs/ubifs/ubifs.h
@@ -30,6 +30,7 @@
 #include <linux/sched.h>
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
+#include <linux/sched/mm.h>
 #include <linux/spinlock.h>
 #include <linux/mutex.h>
 #include <linux/rwsem.h>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
