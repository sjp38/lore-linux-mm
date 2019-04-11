Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19FA4C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 15:39:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B455B2083E
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 15:39:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NET3Rf8Q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B455B2083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 468836B000D; Thu, 11 Apr 2019 11:39:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 41AD06B026A; Thu, 11 Apr 2019 11:39:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2BAC76B026B; Thu, 11 Apr 2019 11:39:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id CB04D6B000D
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 11:39:02 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id n6so4155006wrm.2
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 08:39:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:references
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=cSOQ7Gs++diSHQm1M9fFoOA1/dE9XvDkWRHKalGstic=;
        b=A6ouQBGsmV39a6UZQPlDXMRn6YoNdnx32Z9tjsT+TRqXiccaIFxyeoYPnpTTtMPLi9
         JAuZwHL4UMotFR9zHIabrzkLnDh1uc21sftvCxqWzgKOZkC3lehkT73KMkDuc6ZZ9tRF
         2THdGV5DkC/qB0i7rX87qZM9nrlmkEw0Z+uWz+MrtRHC8hOKJgskj4CsP3aWUivGRml4
         WobyQPaGLJSQ+19Ehr1iAC2J+rM0v4sfKNtAFmbueBPuwDELhPeCjzy0bj0OuC75iQ26
         eD1X7DYK8dQQ64IjVaCF0Xc7n4FCYo7YTTJTYZy4xDnFnXO2EMV9rhAu/7wrWbUgM+yd
         28IA==
X-Gm-Message-State: APjAAAVpdugKFZXm9HymToq5FY8Hm+KuBudYZ1+MVk4Lbxozg6MpQaWP
	VWezhiUUwb12i622CnBJwzVD7CE/NDi7QJiRKaiWiFbHN11Aiq3QkqyvaNk9zd5AgMuDjCUweH1
	3fAxHDpEqQYUH4z+wQDW4v5nRfIGbXGpGpx2E9LrLDYaZlh765UF3mZuMhXvqMOXBYg==
X-Received: by 2002:a5d:518f:: with SMTP id k15mr28993267wrv.122.1554997142298;
        Thu, 11 Apr 2019 08:39:02 -0700 (PDT)
X-Received: by 2002:a5d:518f:: with SMTP id k15mr28993190wrv.122.1554997140734;
        Thu, 11 Apr 2019 08:39:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554997140; cv=none;
        d=google.com; s=arc-20160816;
        b=TbRXgjhHrK3aKoNxcVYwAuZTau7iynJHVihVvWY4fi8grofmA4I07yujdl+ZI38j6B
         xCFr/yYcZSfqcItXHUZDoK9QHfDPHO0m/JOxXc5G7V4hKvKRnxbyAB5bPYwZTR48m7bH
         jK6eOEEZmxsWzbwmbwo8FpQDtxSMbh8WvR87+MoDMYaNTtG7WsFy12SjlJ23Ax2IbjJj
         34NZ7zh5yWTc2KLys/iMx4OF18PvC3d2IViyzQLCNEqw1D9HiRstqeYx/JaMSnSsHFyw
         4wctKEpVcYgkoo/7wJunjT6kR04q2dgKJYhAg+LniZf/Z3Jm20LoCO4kxTldTvuaXTMj
         YJYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject
         :dkim-signature;
        bh=cSOQ7Gs++diSHQm1M9fFoOA1/dE9XvDkWRHKalGstic=;
        b=sghybxQzOaoJuHBsC6Nfspz1ho0mJwzq7No80LYYwZdUmGGFbEDM3XT0hlFQetW2O+
         u0nd/b0z7l75t1TdRm/cESU6U4bje3+VOn6l4pvUGGxPVJZ06lhryIu1+LPH9eMg37d4
         N2pTDBwHkRFENxk+uLEh2JKuOJvaiJtOr6wvBMlmqpshy8hHPRxmmdc+UnjjPQoKMKmv
         KDhgrwRc4prTQ4LhRCUf4odRDfVP03zlFlcKg4/J/R8IMAx5pmFUEoyaBxgoa/12E8v4
         CZ2YNn5c4nTMFmlWjz5/E+w3+T3GrMbSH5+hE73Wd7FwKmk99NWeZgV8HpjMcfsWOS3U
         B8KQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NET3Rf8Q;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d14sor29254574wre.10.2019.04.11.08.39.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 08:39:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NET3Rf8Q;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:references:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=cSOQ7Gs++diSHQm1M9fFoOA1/dE9XvDkWRHKalGstic=;
        b=NET3Rf8QPYoMsqtb4EY8M/PQTQrDtNpZznGMI/5vGDVmw0WA/ccFoCAQPfE84npu/O
         F+Qr/8LcC2HFzQN84LeLM+kwCskAF2FuTBYaJzyv+8WUSkOoz7wl8gwHsbAkoS6TwHgk
         rUkjTcjh/RtrTfotGMCKZYOY7w1aY+Mz1RwI5NBuycu9VS/xvP6d6JQRXUp5/sI2e4+V
         TyfZdXNKoqapsm8LTJAnMIG+N+Clmnad61iIhLjBUtgaBBhrcPAIrvHKfL71fh1EAxvK
         g8/bjgLPOJXe1bSXEw16jHASw3hAhllMqH2v9xBFd7W/Ud5h9RPX48HwpMPDgsOHTcTx
         TUbg==
X-Google-Smtp-Source: APXvYqyccOvbSDGL7NU2r4JoReLSqRjhV3Jlh8SEaLAEufKdm9UBjZuj6ig+m9kZ/HWM6BAzzQoZew==
X-Received: by 2002:adf:dd82:: with SMTP id x2mr21471541wrl.214.1554997139970;
        Thu, 11 Apr 2019 08:38:59 -0700 (PDT)
Received: from ?IPv6:::1? (lan.nucleusys.com. [92.247.61.126])
        by smtp.gmail.com with ESMTPSA id g132sm5590006wme.3.2019.04.11.08.38.58
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 08:38:59 -0700 (PDT)
Subject: [PATCH 4/4] z3fold: support page migration
From: Vitaly Wool <vitalywool@gmail.com>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleksiy.Avramchenko@sony.com,
 Dan Streetman <ddstreet@ieee.org>
References: <b86e6a5e-44d6-2c1b-879e-54a1bc671ad3@gmail.com>
Message-ID: <d888ecb9-a8ab-aca9-4087-895b8b920886@gmail.com>
Date: Thu, 11 Apr 2019 17:38:56 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <b86e6a5e-44d6-2c1b-879e-54a1bc671ad3@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
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

