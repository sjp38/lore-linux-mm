Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DATE_IN_FUTURE_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7BA8C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 17:09:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7737C206BA
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 17:09:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7737C206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 025036B000D; Wed, 27 Mar 2019 13:09:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E5B6F6B000E; Wed, 27 Mar 2019 13:09:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D23116B0010; Wed, 27 Mar 2019 13:09:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 869EC6B000D
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 13:09:33 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id q18so542956pll.16
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 10:09:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=yWAUhIXNJL73/EZGrKHESCQJPbjNfYR6LxwmblUx9PA=;
        b=cNU6xzKVIlpaRBypCLErbTDplykNnz8R/z26t/QscbAl1stpxcM950qj3delFPseii
         qI4eixIIFHXX+C0KWiYnBfDgXqAZlQ6IkyueUWtS+Y7/OR7GOfe17s8HKGQktGc5aKRT
         s/z/7x9N1iNa/dkZlvZnT30LtjiPR34vOwLxBAL3jYyRpDd1hlsnK6gsm+O+AxTUy3yH
         siReWGs4Pt4C0IpUGip499HEKzjRVKkg0iOSwqdLl19f4LS7Zdkz1U2pyGKmhT948fuK
         GHZRgsdHshY1vZSPHNGLmOgfirqCxy9Gy4eb9Q53GhFenar44qo/lxQ9d/UAqfOqjgQo
         AUWQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAXMtNUOci6tX8kZi1p78k7/cdrh8/O4hByC0PGVTHhhZwXIKFoE
	k+uZ8ASZIcHykbV+Sv3ve4wt+dRymDkus7sOjSg2sKyvjY8ZZAVeCU/j8z0zlumdAQBM3mo23fC
	q70ceZ7DL+WZjjTe8pnigqpTGD9FHkhyDUp8JN9FLHLGNtuy0o4uvvStThvvZAcLHJQ==
X-Received: by 2002:a63:7444:: with SMTP id e4mr16808407pgn.261.1553706573168;
        Wed, 27 Mar 2019 10:09:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyL5aieFTTKctDCRsNw9pDT2RjOESX8iFZ4/S96+Te94WElwGtAmuoUV30z86KZJ5O0KTbe
X-Received: by 2002:a63:7444:: with SMTP id e4mr16808227pgn.261.1553706571266;
        Wed, 27 Mar 2019 10:09:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553706571; cv=none;
        d=google.com; s=arc-20160816;
        b=0U5l+Sb2eFoIo1HRemaxyjwNjQWoXwTAd6mCXDsFjQbm0F9qfT5ny6wFTGksu7uWQI
         GFOzBD1Dh/jgiUXU/KMVyRJUenjykISmTD4VwSuNEZwf+4xFQs6ZH/Df6lu5wnzotMo1
         IUAolTjNgrZknNi/wtR1gVG9ADS6FtlAy2jVimIIYvaaf1kXT7HerKTsIvH/ahdMt9P6
         pZZGWSFxuW3MpoRU434dqTZx3+CSpSWLGTy82SIuOagRM+lhBc8TprtJCtFy5FjqjjgH
         jlC/Fy1rUH+YN/hOmRLGzgWOeJUWS8QNgGlbvvRUdee/PnoNAyBwg6zsWJptDWEba3He
         halQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=yWAUhIXNJL73/EZGrKHESCQJPbjNfYR6LxwmblUx9PA=;
        b=eYw2T4M9gKWVky4Vdos8PibVmDwxe2UPQuI54Yi7RntPnoqAmz6uhc3mcpZQlgXVji
         5FdeCnLEpFPKiWivU3leB8NTpuBnV6hR/Gdhc9Tpu1FK5/rNko6xQ28pt0GozOF6aBNR
         UFeTgqMy36O5SZLHMN0XV2Rxp22ZeDWezBuAMVSPlMSr5Us2roR1rBUt5ffy2+3abaEn
         2W1MJWYVJ+YM8P3bjNd9h8MPf0yJL+KdzWHe0nahVJ1SHeUNMxHuWt/H3nYYnVgVZ3Ub
         vIZWFV9gwRykTdEwqvG9VWdM9rrrJ5sh5/BrRNZ36UhBp7e1J918pzBXo8xaf0EaUKOT
         ogNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-001.vmware.com (ex13-edg-ou-001.vmware.com. [208.91.0.189])
        by mx.google.com with ESMTPS id n22si19678465plp.296.2019.03.27.10.09.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Mar 2019 10:09:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) client-ip=208.91.0.189;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost2.vmware.com (10.113.161.72) by
 EX13-EDG-OU-001.vmware.com (10.113.208.155) with Microsoft SMTP Server id
 15.0.1156.6; Wed, 27 Mar 2019 10:09:16 -0700
Received: from namit-esx4.eng.vmware.com (sc2-hs2-general-dhcp-219-51.eng.vmware.com [10.172.219.51])
	by sc9-mailhost2.vmware.com (Postfix) with ESMTP id BFEA7B2129;
	Wed, 27 Mar 2019 13:09:29 -0400 (EDT)
From: Nadav Amit <namit@vmware.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Arnd Bergmann
	<arnd@arndb.de>
CC: "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>,
	<virtualization@lists.linux-foundation.org>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>, "VMware, Inc." <pv-drivers@vmware.com>,
	Julien Freche <jfreche@vmware.com>, Nadav Amit <nadav.amit@gmail.com>, Nadav
 Amit <namit@vmware.com>
Subject: [PATCH v2 2/4] vmw_balloon: compaction support
Date: Thu, 28 Mar 2019 01:07:16 +0000
Message-ID: <20190328010718.2248-3-namit@vmware.com>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190328010718.2248-1-namit@vmware.com>
References: <20190328010718.2248-1-namit@vmware.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
Received-SPF: None (EX13-EDG-OU-001.vmware.com: namit@vmware.com does not
 designate permitted sender hosts)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add support for compaction for VMware balloon. Since unlike the virtio
balloon, we also support huge-pages, which are not going through
compaction, we keep these pages in vmballoon and handle this list
separately. We use the same lock to protect both lists, as this lock is
not supposed to be contended.

Doing so also eliminates the need for the page_size lists. We update the
accounting as needed to reflect inflation, deflation and migration to be
reflected in vmstat.

Since VMware balloon now provides statistics for inflation, deflation
and migration in vmstat, select MEMORY_BALLOON in Kconfig.

Reviewed-by: Xavier Deguillard <xdeguillard@vmware.com>
Signed-off-by: Nadav Amit <namit@vmware.com>
---
 drivers/misc/Kconfig       |   1 +
 drivers/misc/vmw_balloon.c | 301 ++++++++++++++++++++++++++++++++-----
 2 files changed, 264 insertions(+), 38 deletions(-)

diff --git a/drivers/misc/Kconfig b/drivers/misc/Kconfig
index 42ab8ec92a04..427cf10579b4 100644
--- a/drivers/misc/Kconfig
+++ b/drivers/misc/Kconfig
@@ -420,6 +420,7 @@ config SPEAR13XX_PCIE_GADGET
 config VMWARE_BALLOON
 	tristate "VMware Balloon Driver"
 	depends on VMWARE_VMCI && X86 && HYPERVISOR_GUEST
+	select MEMORY_BALLOON
 	help
 	  This is VMware physical memory management driver which acts
 	  like a "balloon" that can be inflated to reclaim physical pages
diff --git a/drivers/misc/vmw_balloon.c b/drivers/misc/vmw_balloon.c
index ad807d5a3141..2136f6ad97d3 100644
--- a/drivers/misc/vmw_balloon.c
+++ b/drivers/misc/vmw_balloon.c
@@ -28,6 +28,8 @@
 #include <linux/rwsem.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
+#include <linux/mount.h>
+#include <linux/balloon_compaction.h>
 #include <linux/vmw_vmci_defs.h>
 #include <linux/vmw_vmci_api.h>
 #include <asm/hypervisor.h>
@@ -38,25 +40,11 @@ MODULE_ALIAS("dmi:*:svnVMware*:*");
 MODULE_ALIAS("vmware_vmmemctl");
 MODULE_LICENSE("GPL");
 
-/*
- * Use __GFP_HIGHMEM to allow pages from HIGHMEM zone. We don't allow wait
- * (__GFP_RECLAIM) for huge page allocations. Use __GFP_NOWARN, to suppress page
- * allocation failure warnings. Disallow access to emergency low-memory pools.
- */
-#define VMW_HUGE_PAGE_ALLOC_FLAGS	(__GFP_HIGHMEM|__GFP_NOWARN|	\
-					 __GFP_NOMEMALLOC)
-
-/*
- * Use __GFP_HIGHMEM to allow pages from HIGHMEM zone. We allow lightweight
- * reclamation (__GFP_NORETRY). Use __GFP_NOWARN, to suppress page allocation
- * failure warnings. Disallow access to emergency low-memory pools.
- */
-#define VMW_PAGE_ALLOC_FLAGS		(__GFP_HIGHMEM|__GFP_NOWARN|	\
-					 __GFP_NOMEMALLOC|__GFP_NORETRY)
-
-/* Maximum number of refused pages we accumulate during inflation cycle */
 #define VMW_BALLOON_MAX_REFUSED		16
 
+/* Magic number for the balloon mount-point */
+#define BALLOON_VMW_MAGIC		0x0ba11007
+
 /*
  * Hypervisor communication port definitions.
  */
@@ -247,11 +235,6 @@ struct vmballoon_ctl {
 	enum vmballoon_op op;
 };
 
-struct vmballoon_page_size {
-	/* list of reserved physical pages */
-	struct list_head pages;
-};
-
 /**
  * struct vmballoon_batch_entry - a batch entry for lock or unlock.
  *
@@ -266,8 +249,6 @@ struct vmballoon_batch_entry {
 } __packed;
 
 struct vmballoon {
-	struct vmballoon_page_size page_sizes[VMW_BALLOON_NUM_PAGE_SIZES];
-
 	/**
 	 * @max_page_size: maximum supported page size for ballooning.
 	 *
@@ -348,8 +329,20 @@ struct vmballoon {
 	struct dentry *dbg_entry;
 #endif
 
+	/**
+	 * @b_dev_info: balloon device information descriptor.
+	 */
+	struct balloon_dev_info b_dev_info;
+
 	struct delayed_work dwork;
 
+	/**
+	 * @huge_pages - list of the inflated 2MB pages.
+	 *
+	 * Protected by @b_dev_info.pages_lock .
+	 */
+	struct list_head huge_pages;
+
 	/**
 	 * @vmci_doorbell.
 	 *
@@ -643,10 +636,10 @@ static int vmballoon_alloc_page_list(struct vmballoon *b,
 
 	for (i = 0; i < req_n_pages; i++) {
 		if (ctl->page_size == VMW_BALLOON_2M_PAGE)
-			page = alloc_pages(VMW_HUGE_PAGE_ALLOC_FLAGS,
-					   VMW_BALLOON_2M_ORDER);
+			page = alloc_pages(__GFP_HIGHMEM|__GFP_NOWARN|
+					__GFP_NOMEMALLOC, VMW_BALLOON_2M_ORDER);
 		else
-			page = alloc_page(VMW_PAGE_ALLOC_FLAGS);
+			page = balloon_page_alloc();
 
 		/* Update statistics */
 		vmballoon_stats_page_inc(b, VMW_BALLOON_PAGE_STAT_ALLOC,
@@ -961,9 +954,22 @@ static void vmballoon_enqueue_page_list(struct vmballoon *b,
 					unsigned int *n_pages,
 					enum vmballoon_page_size_type page_size)
 {
-	struct vmballoon_page_size *page_size_info = &b->page_sizes[page_size];
+	unsigned long flags;
+
+	if (page_size == VMW_BALLOON_4K_PAGE) {
+		balloon_page_list_enqueue(&b->b_dev_info, pages);
+	} else {
+		/*
+		 * Keep the huge pages in a local list which is not available
+		 * for the balloon compaction mechanism.
+		 */
+		spin_lock_irqsave(&b->b_dev_info.pages_lock, flags);
+		list_splice_init(pages, &b->huge_pages);
+		__count_vm_events(BALLOON_INFLATE, *n_pages *
+				  vmballoon_page_in_frames(VMW_BALLOON_2M_PAGE));
+		spin_unlock_irqrestore(&b->b_dev_info.pages_lock, flags);
+	}
 
-	list_splice_init(pages, &page_size_info->pages);
 	*n_pages = 0;
 }
 
@@ -986,15 +992,28 @@ static void vmballoon_dequeue_page_list(struct vmballoon *b,
 					enum vmballoon_page_size_type page_size,
 					unsigned int n_req_pages)
 {
-	struct vmballoon_page_size *page_size_info = &b->page_sizes[page_size];
 	struct page *page, *tmp;
 	unsigned int i = 0;
+	unsigned long flags;
 
-	list_for_each_entry_safe(page, tmp, &page_size_info->pages, lru) {
+	/* In the case of 4k pages, use the compaction infrastructure */
+	if (page_size == VMW_BALLOON_4K_PAGE) {
+		*n_pages = balloon_page_list_dequeue(&b->b_dev_info, pages,
+						     n_req_pages);
+		return;
+	}
+
+	/* 2MB pages */
+	spin_lock_irqsave(&b->b_dev_info.pages_lock, flags);
+	list_for_each_entry_safe(page, tmp, &b->huge_pages, lru) {
 		list_move(&page->lru, pages);
 		if (++i == n_req_pages)
 			break;
 	}
+
+	__count_vm_events(BALLOON_DEFLATE,
+			  i * vmballoon_page_in_frames(VMW_BALLOON_2M_PAGE));
+	spin_unlock_irqrestore(&b->b_dev_info.pages_lock, flags);
 	*n_pages = i;
 }
 
@@ -1552,9 +1571,204 @@ static inline void vmballoon_debugfs_exit(struct vmballoon *b)
 
 #endif	/* CONFIG_DEBUG_FS */
 
+
+#ifdef CONFIG_BALLOON_COMPACTION
+
+static struct dentry *vmballoon_mount(struct file_system_type *fs_type,
+				      int flags, const char *dev_name,
+				      void *data)
+{
+	static const struct dentry_operations ops = {
+		.d_dname = simple_dname,
+	};
+
+	return mount_pseudo(fs_type, "balloon-vmware:", NULL, &ops,
+			    BALLOON_VMW_MAGIC);
+}
+
+static struct file_system_type vmballoon_fs = {
+	.name           = "balloon-vmware",
+	.mount          = vmballoon_mount,
+	.kill_sb        = kill_anon_super,
+};
+
+static struct vfsmount *vmballoon_mnt;
+
+/**
+ * vmballoon_migratepage() - migrates a balloon page.
+ * @b_dev_info: balloon device information descriptor.
+ * @newpage: the page to which @page should be migrated.
+ * @page: a ballooned page that should be migrated.
+ * @mode: migration mode, ignored.
+ *
+ * This function is really open-coded, but that is according to the interface
+ * that balloon_compaction provides.
+ *
+ * Return: zero on success, -EAGAIN when migration cannot be performed
+ *	   momentarily, and -EBUSY if migration failed and should be retried
+ *	   with that specific page.
+ */
+static int vmballoon_migratepage(struct balloon_dev_info *b_dev_info,
+				 struct page *newpage, struct page *page,
+				 enum migrate_mode mode)
+{
+	unsigned long status, flags;
+	struct vmballoon *b;
+	int ret;
+
+	b = container_of(b_dev_info, struct vmballoon, b_dev_info);
+
+	/*
+	 * If the semaphore is taken, there is ongoing configuration change
+	 * (i.e., balloon reset), so try again.
+	 */
+	if (!down_read_trylock(&b->conf_sem))
+		return -EAGAIN;
+
+	spin_lock(&b->comm_lock);
+	/*
+	 * We must start by deflating and not inflating, as otherwise the
+	 * hypervisor may tell us that it has enough memory and the new page is
+	 * not needed. Since the old page is isolated, we cannot use the list
+	 * interface to unlock it, as the LRU field is used for isolation.
+	 * Instead, we use the native interface directly.
+	 */
+	vmballoon_add_page(b, 0, page);
+	status = vmballoon_lock_op(b, 1, VMW_BALLOON_4K_PAGE,
+				   VMW_BALLOON_DEFLATE);
+
+	if (status == VMW_BALLOON_SUCCESS)
+		status = vmballoon_status_page(b, 0, &page);
+
+	/*
+	 * If a failure happened, let the migration mechanism know that it
+	 * should not retry.
+	 */
+	if (status != VMW_BALLOON_SUCCESS) {
+		spin_unlock(&b->comm_lock);
+		ret = -EBUSY;
+		goto out_unlock;
+	}
+
+	/*
+	 * The page is isolated, so it is safe to delete it without holding
+	 * @pages_lock . We keep holding @comm_lock since we will need it in a
+	 * second.
+	 */
+	balloon_page_delete(page);
+
+	put_page(page);
+
+	/* Inflate */
+	vmballoon_add_page(b, 0, newpage);
+	status = vmballoon_lock_op(b, 1, VMW_BALLOON_4K_PAGE,
+				   VMW_BALLOON_INFLATE);
+
+	if (status == VMW_BALLOON_SUCCESS)
+		status = vmballoon_status_page(b, 0, &newpage);
+
+	spin_unlock(&b->comm_lock);
+
+	if (status != VMW_BALLOON_SUCCESS) {
+		/*
+		 * A failure happened. While we can deflate the page we just
+		 * inflated, this deflation can also encounter an error. Instead
+		 * we will decrease the size of the balloon to reflect the
+		 * change and report failure.
+		 */
+		atomic64_dec(&b->size);
+		ret = -EBUSY;
+	} else {
+		/*
+		 * Success. Take a reference for the page, and we will add it to
+		 * the list after acquiring the lock.
+		 */
+		get_page(newpage);
+		ret = MIGRATEPAGE_SUCCESS;
+	}
+
+	/* Update the balloon list under the @pages_lock */
+	spin_lock_irqsave(&b->b_dev_info.pages_lock, flags);
+
+	/*
+	 * On inflation success, we already took a reference for the @newpage.
+	 * If we succeed just insert it to the list and update the statistics
+	 * under the lock.
+	 */
+	if (ret == MIGRATEPAGE_SUCCESS) {
+		balloon_page_insert(&b->b_dev_info, newpage);
+		__count_vm_event(BALLOON_MIGRATE);
+	}
+
+	/*
+	 * We deflated successfully, so regardless to the inflation success, we
+	 * need to reduce the number of isolated_pages.
+	 */
+	b->b_dev_info.isolated_pages--;
+	spin_unlock_irqrestore(&b->b_dev_info.pages_lock, flags);
+
+out_unlock:
+	up_read(&b->conf_sem);
+	return ret;
+}
+
+/**
+ * vmballoon_compaction_deinit() - removes compaction related data.
+ *
+ * @b: pointer to the balloon.
+ */
+static void vmballoon_compaction_deinit(struct vmballoon *b)
+{
+	if (!IS_ERR(b->b_dev_info.inode))
+		iput(b->b_dev_info.inode);
+
+	b->b_dev_info.inode = NULL;
+	kern_unmount(vmballoon_mnt);
+	vmballoon_mnt = NULL;
+}
+
+/**
+ * vmballoon_compaction_init() - initialized compaction for the balloon.
+ *
+ * @b: pointer to the balloon.
+ *
+ * If during the initialization a failure occurred, this function does not
+ * perform cleanup. The caller must call vmballoon_compaction_deinit() in this
+ * case.
+ *
+ * Return: zero on success or error code on failure.
+ */
+static __init int vmballoon_compaction_init(struct vmballoon *b)
+{
+	vmballoon_mnt = kern_mount(&vmballoon_fs);
+	if (IS_ERR(vmballoon_mnt))
+		return PTR_ERR(vmballoon_mnt);
+
+	b->b_dev_info.migratepage = vmballoon_migratepage;
+	b->b_dev_info.inode = alloc_anon_inode(vmballoon_mnt->mnt_sb);
+
+	if (IS_ERR(b->b_dev_info.inode))
+		return PTR_ERR(b->b_dev_info.inode);
+
+	b->b_dev_info.inode->i_mapping->a_ops = &balloon_aops;
+	return 0;
+}
+
+#else /* CONFIG_BALLOON_COMPACTION */
+
+static void vmballoon_compaction_deinit(struct vmballoon *b)
+{
+}
+
+static int vmballoon_compaction_init(struct vmballoon *b)
+{
+	return 0;
+}
+
+#endif /* CONFIG_BALLOON_COMPACTION */
+
 static int __init vmballoon_init(void)
 {
-	enum vmballoon_page_size_type page_size;
 	int error;
 
 	/*
@@ -1564,17 +1778,22 @@ static int __init vmballoon_init(void)
 	if (x86_hyper_type != X86_HYPER_VMWARE)
 		return -ENODEV;
 
-	for (page_size = VMW_BALLOON_4K_PAGE;
-	     page_size <= VMW_BALLOON_LAST_SIZE; page_size++)
-		INIT_LIST_HEAD(&balloon.page_sizes[page_size].pages);
-
-
 	INIT_DELAYED_WORK(&balloon.dwork, vmballoon_work);
 
 	error = vmballoon_debugfs_init(&balloon);
 	if (error)
-		return error;
+		goto fail;
 
+	/*
+	 * Initialization of compaction must be done after the call to
+	 * balloon_devinfo_init() .
+	 */
+	balloon_devinfo_init(&balloon.b_dev_info);
+	error = vmballoon_compaction_init(&balloon);
+	if (error)
+		goto fail;
+
+	INIT_LIST_HEAD(&balloon.huge_pages);
 	spin_lock_init(&balloon.comm_lock);
 	init_rwsem(&balloon.conf_sem);
 	balloon.vmci_doorbell = VMCI_INVALID_HANDLE;
@@ -1585,6 +1804,9 @@ static int __init vmballoon_init(void)
 	queue_delayed_work(system_freezable_wq, &balloon.dwork, 0);
 
 	return 0;
+fail:
+	vmballoon_compaction_deinit(&balloon);
+	return error;
 }
 
 /*
@@ -1609,5 +1831,8 @@ static void __exit vmballoon_exit(void)
 	 */
 	vmballoon_send_start(&balloon, 0);
 	vmballoon_pop(&balloon);
+
+	/* Only once we popped the balloon, compaction can be deinit */
+	vmballoon_compaction_deinit(&balloon);
 }
 module_exit(vmballoon_exit);
-- 
2.19.1

