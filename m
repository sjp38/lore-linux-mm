Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3869C10F12
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 08:39:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 75B8020835
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 08:39:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oTc9RzZo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75B8020835
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1DC946B0008; Wed, 17 Apr 2019 04:39:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 189906B000A; Wed, 17 Apr 2019 04:39:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 031646B000D; Wed, 17 Apr 2019 04:39:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 85AA36B0008
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 04:39:27 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id p13so3368701lfc.4
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 01:39:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=cSOQ7Gs++diSHQm1M9fFoOA1/dE9XvDkWRHKalGstic=;
        b=ZeAwlMQhOJ1qJFCB/4f2WjHk/sIE705jItL42oB0b1RLEOmEFohPQtRPkKt/7XKC20
         uZCgDUBVkybL+PltLtu14QVVctEx1Uc6G1nmJFtQxxNL93GmVOk50WIZtCd5aTSqfd4k
         ZYDnbY0xixQgPTbTuMs9SXTePz1XX7FIT9WFzUklnX5R+oR9oaMh7aLTwXZ4jd2FCvtO
         N+qRtI6dxanrYNw9XKNbRUqwqlLqxjklVSYFRUsEYRvnDZiEX0BNQAS2hOWVDDOwwdJk
         lFrBQ8frUvY9F2hli3C+909S1nL/ioAuNhFFh1zd8UMh3qdFnCB9F3k4joJKoGsJzVrk
         wN+g==
X-Gm-Message-State: APjAAAWQYOCyT2IHYrZQwAnQA3d/QaMxV3q/6LHQKTpjP9nn6D96eCNy
	p3eSVXt0njeb2HwJ97jhFCuuRAvWb/3bn+mgTQpde0smZWbn4ECIEg37gXuUisSyCLCHzx0oSTt
	RwOCfL3I2BBU5XmNsNMLN8vEy2+72sz7EMUxLzRW9QQDw3CbRR2hwhp14szo1EliayA==
X-Received: by 2002:a2e:8089:: with SMTP id i9mr46629944ljg.137.1555490366933;
        Wed, 17 Apr 2019 01:39:26 -0700 (PDT)
X-Received: by 2002:a2e:8089:: with SMTP id i9mr46629873ljg.137.1555490365153;
        Wed, 17 Apr 2019 01:39:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555490365; cv=none;
        d=google.com; s=arc-20160816;
        b=NQfmto7fIzIY91SzpX5sRYu+3MK6XpMo427T9e3gfgPV6MZcjJ4cssPIDYcSkZpMWz
         b4m2MKPtT5rbnoVTUl2wllCCR+8gGE2P5jOiVPaiikeYDNnnjJrr3FP0QrEnf9KkZLps
         cBf2obx1SJDNsSYjm59RxES5CnAucfP3gSKEr+04VJDbx9EEBPR3zi2gv6pJJ4KBLSuB
         P0GoFLWGJAuA/jemyDMWdy/S7IYsrCR/aKcc5TMIWYP+boxp8092VZ6rnjsvXOPUOgYl
         sbWM04lUOHvVy2XweXCYOXylx6YDI0BLBiMDffteyp4hbRdNgrm/bIa5t3QyoV4UeR4I
         DgsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=cSOQ7Gs++diSHQm1M9fFoOA1/dE9XvDkWRHKalGstic=;
        b=s+rsV2MHu0JVEccVj+S084kit0az8VpSin+l3f8Smr1SmoDRNdRnbeuIkmQ7JVCc7p
         XYmOGzuUjqm5XTiJaGeTWRB1c0DFsE3slBRSPmpR39Xc7Dhgz2FIKXuOD28WV2+vJA7p
         0Dak+TZMnLNgLjIc+Aa7XvPGI6ap8la2UAlkdpg0YVlH3kAKs8FhHEWAaEsfePe/vVJW
         ElHucCKN7znV61ixKUkAH/BW37Ofr5+AdfmggJMmzQUGCCci5ym9mDfDXou2vNrVZiG0
         xpLgPFq4jWGsMhJHLtp5dGQHywe+/CSShih+ljnCSEx5aVZIrEuSaOkzIzRCfCZINtFk
         e2oQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oTc9RzZo;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x26sor33039240ljb.16.2019.04.17.01.39.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 01:39:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oTc9RzZo;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=cSOQ7Gs++diSHQm1M9fFoOA1/dE9XvDkWRHKalGstic=;
        b=oTc9RzZo7AUyk5pj0tyHVttfdubvOnhHrx8eT0xZ8PbaQ+9PQTmqxjnWl3gpCFV7Xt
         Q9nvfRZF638cx7LG8/fw2Cu+kvndUtty56kC6eQreNhBp35P1pyZrgQipcLegyg+0lt+
         tfjjOVmJGuw5WSwVnpV3vbFVuJF8P5oPV3fJBpolwtd2ta08rxW1AXoACAHV6A8pWdrx
         WSrB1Kr5rBx4J8VDZKJs6CW+suqL/dbD0x5uOklokgLAkv+u4PPU7I/o2JALZ7JcJhZv
         N3vpwdgSu22zSApgonIrJpjJuaxd75k8xc3HVAMtZVodC/luQ1FmSazWENtVgAoMeLpZ
         RZFA==
X-Google-Smtp-Source: APXvYqwYJI2wYRIH1GvgDtpYP4W7t6wF+RkdlbsImDBBofg3hY0tgObM1O0O0TVDefCRoecArie5LA==
X-Received: by 2002:a2e:8e96:: with SMTP id z22mr46203924ljk.123.1555490363999;
        Wed, 17 Apr 2019 01:39:23 -0700 (PDT)
Received: from seldlx21914.corpusers.net ([37.139.156.40])
        by smtp.gmail.com with ESMTPSA id t23sm10820473ljc.13.2019.04.17.01.39.23
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 01:39:23 -0700 (PDT)
Date: Wed, 17 Apr 2019 10:39:22 +0200
From: Vitaly Wool <vitalywool@gmail.com>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton
 <akpm@linux-foundation.org>, Oleksiy.Avramchenko@sony.com, Bartlomiej
 Zolnierkiewicz <b.zolnierkie@samsung.com>, Krzysztof Kozlowski
 <k.kozlowski@samsung.com>
Subject: [PATCHv2 4/4] z3fold: support page migration
Message-Id: <20190417103922.31253da5c366c4ebe0419cfc@gmail.com>
In-Reply-To: <20190417103510.36b055f3314e0e32b916b30a@gmail.com>
References: <20190417103510.36b055f3314e0e32b916b30a@gmail.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.30; x86_64-unknown-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Now that we are not using page address in handles directly, we
can make z3fold pages movable to decrease the memory fragmentation
z3fold may create over time.

This patch starts advertising non-headless z3fold pages as movable
and uses the existing kernel infrastructure to implement moving of
such pages per memory management subsystem's request. It thus
implements 3 required callbacks for page migration:

* isolation callback: z3fold_page_isolate(): try to isolate the
page by removing it from all lists. Pages scheduled for some activity
and mapped pages will not be isolated. Return true if isolation was
successful or false otherwise
* migration callback: z3fold_page_migrate(): re-check critical
conditions and migrate page contents to the new page provided by the
memory subsystem. Returns 0 on success or negative error code
otherwise
* putback callback: z3fold_page_putback(): put back the page if
z3fold_page_migrate() for it failed permanently (i. e. not with
-EAGAIN code).

Signed-off-by: Vitaly Wool <vitaly.vul@sony.com>
---
 mm/z3fold.c | 241 +++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 231 insertions(+), 10 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index bebc10083f1c..d9eabfdad0fe 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -24,10 +24,18 @@
 
 #include <linux/atomic.h>
 #include <linux/sched.h>
+#include <linux/cpumask.h>
+#include <linux/dcache.h>
 #include <linux/list.h>
 #include <linux/mm.h>
 #include <linux/module.h>
+#include <linux/page-flags.h>
+#include <linux/migrate.h>
+#include <linux/node.h>
+#include <linux/compaction.h>
 #include <linux/percpu.h>
+#include <linux/mount.h>
+#include <linux/fs.h>
 #include <linux/preempt.h>
 #include <linux/workqueue.h>
 #include <linux/slab.h>
@@ -97,6 +105,7 @@ struct z3fold_buddy_slots {
  * @middle_chunks:	the size of the middle buddy in chunks, 0 if free
  * @last_chunks:	the size of the last buddy in chunks, 0 if free
  * @first_num:		the starting number (for the first handle)
+ * @mapped_count:	the number of objects currently mapped
  */
 struct z3fold_header {
 	struct list_head buddy;
@@ -110,6 +119,7 @@ struct z3fold_header {
 	unsigned short last_chunks;
 	unsigned short start_middle;
 	unsigned short first_num:2;
+	unsigned short mapped_count:2;
 };
 
 /**
@@ -130,6 +140,7 @@ struct z3fold_header {
  * @compact_wq:	workqueue for page layout background optimization
  * @release_wq:	workqueue for safe page release
  * @work:	work_struct for safe page release
+ * @inode:	inode for z3fold pseudo filesystem
  *
  * This structure is allocated at pool creation time and maintains metadata
  * pertaining to a particular z3fold pool.
@@ -149,6 +160,7 @@ struct z3fold_pool {
 	struct workqueue_struct *compact_wq;
 	struct workqueue_struct *release_wq;
 	struct work_struct work;
+	struct inode *inode;
 };
 
 /*
@@ -227,6 +239,59 @@ static inline void free_handle(unsigned long handle)
 	}
 }
 
+static struct dentry *z3fold_do_mount(struct file_system_type *fs_type,
+				int flags, const char *dev_name, void *data)
+{
+	static const struct dentry_operations ops = {
+		.d_dname = simple_dname,
+	};
+
+	return mount_pseudo(fs_type, "z3fold:", NULL, &ops, 0x33);
+}
+
+static struct file_system_type z3fold_fs = {
+	.name		= "z3fold",
+	.mount		= z3fold_do_mount,
+	.kill_sb	= kill_anon_super,
+};
+
+static struct vfsmount *z3fold_mnt;
+static int z3fold_mount(void)
+{
+	int ret = 0;
+
+	z3fold_mnt = kern_mount(&z3fold_fs);
+	if (IS_ERR(z3fold_mnt))
+		ret = PTR_ERR(z3fold_mnt);
+
+	return ret;
+}
+
+static void z3fold_unmount(void)
+{
+	kern_unmount(z3fold_mnt);
+}
+
+static const struct address_space_operations z3fold_aops;
+static int z3fold_register_migration(struct z3fold_pool *pool)
+{
+	pool->inode = alloc_anon_inode(z3fold_mnt->mnt_sb);
+	if (IS_ERR(pool->inode)) {
+		pool->inode = NULL;
+		return 1;
+	}
+
+	pool->inode->i_mapping->private_data = pool;
+	pool->inode->i_mapping->a_ops = &z3fold_aops;
+	return 0;
+}
+
+static void z3fold_unregister_migration(struct z3fold_pool *pool)
+{
+	if (pool->inode)
+		iput(pool->inode);
+ }
+
 /* Initializes the z3fold header of a newly allocated z3fold page */
 static struct z3fold_header *init_z3fold_page(struct page *page,
 					struct z3fold_pool *pool)
@@ -259,8 +324,14 @@ static struct z3fold_header *init_z3fold_page(struct page *page,
 }
 
 /* Resets the struct page fields and frees the page */
-static void free_z3fold_page(struct page *page)
+static void free_z3fold_page(struct page *page, bool headless)
 {
+	if (!headless) {
+		lock_page(page);
+		__ClearPageMovable(page);
+		unlock_page(page);
+	}
+	ClearPagePrivate(page);
 	__free_page(page);
 }
 
@@ -317,12 +388,12 @@ static unsigned long encode_handle(struct z3fold_header *zhdr, enum buddy bud)
 }
 
 /* Returns the z3fold page where a given handle is stored */
-static inline struct z3fold_header *handle_to_z3fold_header(unsigned long handle)
+static inline struct z3fold_header *handle_to_z3fold_header(unsigned long h)
 {
-	unsigned long addr = handle;
+	unsigned long addr = h;
 
 	if (!(addr & (1 << PAGE_HEADLESS)))
-		addr = *(unsigned long *)handle;
+		addr = *(unsigned long *)h;
 
 	return (struct z3fold_header *)(addr & PAGE_MASK);
 }
@@ -366,7 +437,7 @@ static void __release_z3fold_page(struct z3fold_header *zhdr, bool locked)
 	clear_bit(NEEDS_COMPACTING, &page->private);
 	spin_lock(&pool->lock);
 	if (!list_empty(&page->lru))
-		list_del(&page->lru);
+		list_del_init(&page->lru);
 	spin_unlock(&pool->lock);
 	if (locked)
 		z3fold_page_unlock(zhdr);
@@ -420,7 +491,7 @@ static void free_pages_work(struct work_struct *w)
 			continue;
 		spin_unlock(&pool->stale_lock);
 		cancel_work_sync(&zhdr->work);
-		free_z3fold_page(page);
+		free_z3fold_page(page, false);
 		cond_resched();
 		spin_lock(&pool->stale_lock);
 	}
@@ -486,6 +557,9 @@ static int z3fold_compact_page(struct z3fold_header *zhdr)
 	if (test_bit(MIDDLE_CHUNK_MAPPED, &page->private))
 		return 0; /* can't move middle chunk, it's used */
 
+	if (unlikely(PageIsolated(page)))
+		return 0;
+
 	if (zhdr->middle_chunks == 0)
 		return 0; /* nothing to compact */
 
@@ -546,6 +620,12 @@ static void do_compact_page(struct z3fold_header *zhdr, bool locked)
 		return;
 	}
 
+	if (unlikely(PageIsolated(page) ||
+		     test_bit(PAGE_STALE, &page->private))) {
+		z3fold_page_unlock(zhdr);
+		return;
+	}
+
 	z3fold_compact_page(zhdr);
 	add_to_unbuddied(pool, zhdr);
 	z3fold_page_unlock(zhdr);
@@ -705,10 +785,14 @@ static struct z3fold_pool *z3fold_create_pool(const char *name, gfp_t gfp,
 	pool->release_wq = create_singlethread_workqueue(pool->name);
 	if (!pool->release_wq)
 		goto out_wq;
+	if (z3fold_register_migration(pool))
+		goto out_rwq;
 	INIT_WORK(&pool->work, free_pages_work);
 	pool->ops = ops;
 	return pool;
 
+out_rwq:
+	destroy_workqueue(pool->release_wq);
 out_wq:
 	destroy_workqueue(pool->compact_wq);
 out_unbuddied:
@@ -730,6 +814,7 @@ static struct z3fold_pool *z3fold_create_pool(const char *name, gfp_t gfp,
 static void z3fold_destroy_pool(struct z3fold_pool *pool)
 {
 	kmem_cache_destroy(pool->c_handle);
+	z3fold_unregister_migration(pool);
 	destroy_workqueue(pool->release_wq);
 	destroy_workqueue(pool->compact_wq);
 	kfree(pool);
@@ -837,6 +922,7 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 		set_bit(PAGE_HEADLESS, &page->private);
 		goto headless;
 	}
+	__SetPageMovable(page, pool->inode->i_mapping);
 	z3fold_page_lock(zhdr);
 
 found:
@@ -895,7 +981,7 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 			spin_lock(&pool->lock);
 			list_del(&page->lru);
 			spin_unlock(&pool->lock);
-			free_z3fold_page(page);
+			free_z3fold_page(page, true);
 			atomic64_dec(&pool->pages_nr);
 		}
 		return;
@@ -931,7 +1017,8 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 		z3fold_page_unlock(zhdr);
 		return;
 	}
-	if (test_and_set_bit(NEEDS_COMPACTING, &page->private)) {
+	if (unlikely(PageIsolated(page)) ||
+	    test_and_set_bit(NEEDS_COMPACTING, &page->private)) {
 		z3fold_page_unlock(zhdr);
 		return;
 	}
@@ -1012,10 +1099,12 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 			if (test_and_set_bit(PAGE_CLAIMED, &page->private))
 				continue;
 
-			zhdr = page_address(page);
+			if (unlikely(PageIsolated(page)))
+				continue;
 			if (test_bit(PAGE_HEADLESS, &page->private))
 				break;
 
+			zhdr = page_address(page);
 			if (!z3fold_page_trylock(zhdr)) {
 				zhdr = NULL;
 				continue; /* can't evict at this point */
@@ -1076,7 +1165,7 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 next:
 		if (test_bit(PAGE_HEADLESS, &page->private)) {
 			if (ret == 0) {
-				free_z3fold_page(page);
+				free_z3fold_page(page, true);
 				atomic64_dec(&pool->pages_nr);
 				return 0;
 			}
@@ -1153,6 +1242,8 @@ static void *z3fold_map(struct z3fold_pool *pool, unsigned long handle)
 		break;
 	}
 
+	if (addr)
+		zhdr->mapped_count++;
 	z3fold_page_unlock(zhdr);
 out:
 	return addr;
@@ -1179,6 +1270,7 @@ static void z3fold_unmap(struct z3fold_pool *pool, unsigned long handle)
 	buddy = handle_to_buddy(handle);
 	if (buddy == MIDDLE)
 		clear_bit(MIDDLE_CHUNK_MAPPED, &page->private);
+	zhdr->mapped_count--;
 	z3fold_page_unlock(zhdr);
 }
 
@@ -1193,6 +1285,128 @@ static u64 z3fold_get_pool_size(struct z3fold_pool *pool)
 	return atomic64_read(&pool->pages_nr);
 }
 
+bool z3fold_page_isolate(struct page *page, isolate_mode_t mode)
+{
+	struct z3fold_header *zhdr;
+	struct z3fold_pool *pool;
+
+	VM_BUG_ON_PAGE(!PageMovable(page), page);
+	VM_BUG_ON_PAGE(PageIsolated(page), page);
+
+	if (test_bit(PAGE_HEADLESS, &page->private))
+		return false;
+
+	zhdr = page_address(page);
+	z3fold_page_lock(zhdr);
+	if (test_bit(NEEDS_COMPACTING, &page->private) ||
+	    test_bit(PAGE_STALE, &page->private))
+		goto out;
+
+	pool = zhdr_to_pool(zhdr);
+
+	if (zhdr->mapped_count == 0) {
+		kref_get(&zhdr->refcount);
+		if (!list_empty(&zhdr->buddy))
+			list_del_init(&zhdr->buddy);
+		spin_lock(&pool->lock);
+		if (!list_empty(&page->lru))
+			list_del(&page->lru);
+		spin_unlock(&pool->lock);
+		z3fold_page_unlock(zhdr);
+		return true;
+	}
+out:
+	z3fold_page_unlock(zhdr);
+	return false;
+}
+
+int z3fold_page_migrate(struct address_space *mapping, struct page *newpage,
+			struct page *page, enum migrate_mode mode)
+{
+	struct z3fold_header *zhdr, *new_zhdr;
+	struct z3fold_pool *pool;
+	struct address_space *new_mapping;
+
+	VM_BUG_ON_PAGE(!PageMovable(page), page);
+	VM_BUG_ON_PAGE(!PageIsolated(page), page);
+
+	zhdr = page_address(page);
+	pool = zhdr_to_pool(zhdr);
+
+	if (!trylock_page(page))
+		return -EAGAIN;
+
+	if (!z3fold_page_trylock(zhdr)) {
+		unlock_page(page);
+		return -EAGAIN;
+	}
+	if (zhdr->mapped_count != 0) {
+		z3fold_page_unlock(zhdr);
+		unlock_page(page);
+		return -EBUSY;
+	}
+	new_zhdr = page_address(newpage);
+	memcpy(new_zhdr, zhdr, PAGE_SIZE);
+	newpage->private = page->private;
+	page->private = 0;
+	z3fold_page_unlock(zhdr);
+	spin_lock_init(&new_zhdr->page_lock);
+	new_mapping = page_mapping(page);
+	__ClearPageMovable(page);
+	ClearPagePrivate(page);
+
+	get_page(newpage);
+	z3fold_page_lock(new_zhdr);
+	if (new_zhdr->first_chunks)
+		encode_handle(new_zhdr, FIRST);
+	if (new_zhdr->last_chunks)
+		encode_handle(new_zhdr, LAST);
+	if (new_zhdr->middle_chunks)
+		encode_handle(new_zhdr, MIDDLE);
+	set_bit(NEEDS_COMPACTING, &newpage->private);
+	new_zhdr->cpu = smp_processor_id();
+	spin_lock(&pool->lock);
+	list_add(&newpage->lru, &pool->lru);
+	spin_unlock(&pool->lock);
+	__SetPageMovable(newpage, new_mapping);
+	z3fold_page_unlock(new_zhdr);
+
+	queue_work_on(new_zhdr->cpu, pool->compact_wq, &new_zhdr->work);
+
+	page_mapcount_reset(page);
+	unlock_page(page);
+	put_page(page);
+	return 0;
+}
+
+void z3fold_page_putback(struct page *page)
+{
+	struct z3fold_header *zhdr;
+	struct z3fold_pool *pool;
+
+	zhdr = page_address(page);
+	pool = zhdr_to_pool(zhdr);
+
+	z3fold_page_lock(zhdr);
+	if (!list_empty(&zhdr->buddy))
+		list_del_init(&zhdr->buddy);
+	INIT_LIST_HEAD(&page->lru);
+	if (kref_put(&zhdr->refcount, release_z3fold_page_locked)) {
+		atomic64_dec(&pool->pages_nr);
+		return;
+	}
+	spin_lock(&pool->lock);
+	list_add(&page->lru, &pool->lru);
+	spin_unlock(&pool->lock);
+	z3fold_page_unlock(zhdr);
+}
+
+static const struct address_space_operations z3fold_aops = {
+	.isolate_page = z3fold_page_isolate,
+	.migratepage = z3fold_page_migrate,
+	.putback_page = z3fold_page_putback,
+};
+
 /*****************
  * zpool
  ****************/
@@ -1290,8 +1504,14 @@ MODULE_ALIAS("zpool-z3fold");
 
 static int __init init_z3fold(void)
 {
+	int ret;
+
 	/* Make sure the z3fold header is not larger than the page size */
 	BUILD_BUG_ON(ZHDR_SIZE_ALIGNED > PAGE_SIZE);
+	ret = z3fold_mount();
+	if (ret)
+		return ret;
+
 	zpool_register_driver(&z3fold_zpool_driver);
 
 	return 0;
@@ -1299,6 +1519,7 @@ static int __init init_z3fold(void)
 
 static void __exit exit_z3fold(void)
 {
+	z3fold_unmount();
 	zpool_unregister_driver(&z3fold_zpool_driver);
 }
 
-- 
2.17.1

