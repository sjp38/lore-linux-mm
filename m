Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5310BC4360F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 02:36:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EBEBB214D8
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 02:36:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EBEBB214D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E26A96B0007; Sun, 17 Mar 2019 22:36:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DAB846B000D; Sun, 17 Mar 2019 22:36:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BFF8C6B000C; Sun, 17 Mar 2019 22:36:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6C1FA6B0007
	for <linux-mm@kvack.org>; Sun, 17 Mar 2019 22:36:06 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id a72so17507180pfj.19
        for <linux-mm@kvack.org>; Sun, 17 Mar 2019 19:36:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=muC8NI9W4OvoCYcn8f749oAf5UOc2H/5vwr/RGBGK3U=;
        b=H/Ou9hp2cUl2pHipohdn5uWhj+Nm2pNCZkKVzu8CPoL6eX2e4uE0Nbc352y++PTQXs
         /A3K5KH0Xdw8z6rmDZ10AmxtNlhvPWMhq8BlZBtMB6NznihZkhEwyO3W/THH3KTRush2
         XLjVWofgdxGpw3Oqu+SNUFIWUo9QsmcoxdIZRiAWtPZI1TJ1V/rTTsK6hWA92eQ6DpOT
         iJ+BPpQ2eq1pWhYR3Unk+NoR85e3YwtKuytGNOsDd5TFLyX3LoM3CxrUGpq7CPhcbHOW
         Kdr7WyH/Tmg3aWWRmVxg0Cj9vPiaHwfGJ0dP/q3cxFPYnjjLPE62Uz9r9hYFh+jpGtdX
         9nNA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXnjz51UWKpprjaHa7vDdAdSpyJkRLgij5HXYDaRmI6CqGp7mtV
	8aDaZ8VBmva0rTVS+UwBG0SVehuXVC8InJ5/zbVomnwz80Q70F/OIlKEoGCywxZPV812Gr9d0GX
	cEl6k+UkKjfTMpa5LQg2Meedk4KpzRdyn8zGLszqBib6JUE9s8G4sZVDHjjToH1D2kQ==
X-Received: by 2002:a63:c04e:: with SMTP id z14mr15276744pgi.20.1552876566054;
        Sun, 17 Mar 2019 19:36:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzjCny30qeKFKgEQmRxVF/Z6FTYN927crVMcYtjTHLimUe6AWRcdbsvfoWB6WxlT0Eunawv
X-Received: by 2002:a63:c04e:: with SMTP id z14mr15276694pgi.20.1552876564956;
        Sun, 17 Mar 2019 19:36:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552876564; cv=none;
        d=google.com; s=arc-20160816;
        b=Uctma1uDD/tIpyDQYCY/pFCvaHmGJijpoV4tTwrDONMIG3Tcd5PseTxkY7Rz5yMRFO
         OhuUfrmRqs/aaQZLqLI5N3avcr4K6Ec/6lBsycN/3NHFXUSSIwT9GZbIaZ4vQ82ejeie
         93SjGPlEk8kOVpJw76EA7yA/haSq3WOPZal/FK8RWf+FsY634M5VC5aUmkzUIdbUpp7h
         Fy0XOepXpNQZcLCvYgSC1TNEdy6YNGhIIzosSA9Fwf8KKq8UdiwdaoxtmQXAYx6EuscQ
         vzEgmOfFJuB7AkdWAB76ZBYutu6vycvCRzW8vTUaF7dKUEGbVB2G6agO89ghp/kUDAS8
         4xfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=muC8NI9W4OvoCYcn8f749oAf5UOc2H/5vwr/RGBGK3U=;
        b=QYmweuSXmSUkKhCezDj3jK+SRbTNMFvGEOQbDawnG5aQG0RYEcHEjH+TJPhqgotwNY
         crIiQZUAyEAdI+1MB+NB5LvCbcinlzxkgdJ1U1wmi0/iwh/eIvX905QQAkAq45gHXAPl
         kBM/ITGsVzsWbqNtgAEP/rRxdW56kzD+JRXFXIDGR8+yEqYvMUKb2v1zUP94E+ZiPoiK
         MmPe2adGKLXRacBSa0UqBkcprErNwN7/XEdRChNDvJrUoCjt4Tm/pH1DpJu6XnG5GMUq
         4jEZ4LJj2XG5tEQ+dod0mNsp7qxw804jD+zQ2ia+Z7s1y7AFvkI8eBEc4nZosWaaBom2
         q4Cg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id j71si8521384pfc.280.2019.03.17.19.36.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Mar 2019 19:36:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Mar 2019 19:36:04 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,491,1544515200"; 
   d="scan'208";a="155877411"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga001.fm.intel.com with ESMTP; 17 Mar 2019 19:36:03 -0700
From: ira.weiny@intel.com
To: Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@suse.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Rich Felker <dalias@libc.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	Ralf Baechle <ralf@linux-mips.org>,
	James Hogan <jhogan@kernel.org>
Cc: Ira Weiny <ira.weiny@intel.com>,
	"Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>,
	Michal Hocko <mhocko@kernel.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-mips@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org
Subject: [RESEND 1/7] mm/gup: Replace get_user_pages_longterm() with FOLL_LONGTERM
Date: Sun, 17 Mar 2019 11:34:32 -0700
Message-Id: <20190317183438.2057-2-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190317183438.2057-1-ira.weiny@intel.com>
References: <20190317183438.2057-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

Rather than have a separate get_user_pages_longterm() call,
introduce FOLL_LONGTERM and change the longterm callers to use
it.

This patch does not change any functionality.

FOLL_LONGTERM can only be supported with get_user_pages() as it
requires vmas to determine if DAX is in use.

CC: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Michal Hocko <mhocko@kernel.org>
Signed-off-by: Ira Weiny <ira.weiny@intel.com>

---
Changes from V1:
	Rebased on 5.1 merge
	Adjusted for changes introduced by CONFIG_CMA
	Convert new users of GUP longterm
		io_uring.c
		xdp_umem.c

 arch/powerpc/mm/mmu_context_iommu.c        |   3 +-
 drivers/infiniband/core/umem.c             |   5 +-
 drivers/infiniband/hw/qib/qib_user_pages.c |   8 +-
 drivers/infiniband/hw/usnic/usnic_uiom.c   |   9 +-
 drivers/media/v4l2-core/videobuf-dma-sg.c  |   6 +-
 drivers/vfio/vfio_iommu_type1.c            |   3 +-
 fs/io_uring.c                              |   5 +-
 include/linux/mm.h                         |  14 +-
 mm/gup.c                                   | 171 ++++++++++++---------
 mm/gup_benchmark.c                         |   5 +-
 net/xdp/xdp_umem.c                         |   4 +-
 11 files changed, 129 insertions(+), 104 deletions(-)

diff --git a/arch/powerpc/mm/mmu_context_iommu.c b/arch/powerpc/mm/mmu_context_iommu.c
index e7a9c4f6bfca..2bd48998765e 100644
--- a/arch/powerpc/mm/mmu_context_iommu.c
+++ b/arch/powerpc/mm/mmu_context_iommu.c
@@ -148,7 +148,8 @@ static long mm_iommu_do_alloc(struct mm_struct *mm, unsigned long ua,
 	}
 
 	down_read(&mm->mmap_sem);
-	ret = get_user_pages_longterm(ua, entries, FOLL_WRITE, mem->hpages, NULL);
+	ret = get_user_pages(ua, entries, FOLL_WRITE | FOLL_LONGTERM,
+			     mem->hpages, NULL);
 	up_read(&mm->mmap_sem);
 	if (ret != entries) {
 		/* free the reference taken */
diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
index fe5551562dbc..31191f098e73 100644
--- a/drivers/infiniband/core/umem.c
+++ b/drivers/infiniband/core/umem.c
@@ -189,10 +189,11 @@ struct ib_umem *ib_umem_get(struct ib_udata *udata, unsigned long addr,
 
 	while (npages) {
 		down_read(&mm->mmap_sem);
-		ret = get_user_pages_longterm(cur_base,
+		ret = get_user_pages(cur_base,
 				     min_t(unsigned long, npages,
 					   PAGE_SIZE / sizeof (struct page *)),
-				     gup_flags, page_list, vma_list);
+				     gup_flags | FOLL_LONGTERM,
+				     page_list, vma_list);
 		if (ret < 0) {
 			up_read(&mm->mmap_sem);
 			goto umem_release;
diff --git a/drivers/infiniband/hw/qib/qib_user_pages.c b/drivers/infiniband/hw/qib/qib_user_pages.c
index 123ca8f64f75..f712fb7fa82f 100644
--- a/drivers/infiniband/hw/qib/qib_user_pages.c
+++ b/drivers/infiniband/hw/qib/qib_user_pages.c
@@ -114,10 +114,10 @@ int qib_get_user_pages(unsigned long start_page, size_t num_pages,
 
 	down_read(&current->mm->mmap_sem);
 	for (got = 0; got < num_pages; got += ret) {
-		ret = get_user_pages_longterm(start_page + got * PAGE_SIZE,
-					      num_pages - got,
-					      FOLL_WRITE | FOLL_FORCE,
-					      p + got, NULL);
+		ret = get_user_pages(start_page + got * PAGE_SIZE,
+				     num_pages - got,
+				     FOLL_LONGTERM | FOLL_WRITE | FOLL_FORCE,
+				     p + got, NULL);
 		if (ret < 0) {
 			up_read(&current->mm->mmap_sem);
 			goto bail_release;
diff --git a/drivers/infiniband/hw/usnic/usnic_uiom.c b/drivers/infiniband/hw/usnic/usnic_uiom.c
index 06862a6af185..1d9a182ac163 100644
--- a/drivers/infiniband/hw/usnic/usnic_uiom.c
+++ b/drivers/infiniband/hw/usnic/usnic_uiom.c
@@ -143,10 +143,11 @@ static int usnic_uiom_get_pages(unsigned long addr, size_t size, int writable,
 	ret = 0;
 
 	while (npages) {
-		ret = get_user_pages_longterm(cur_base,
-					min_t(unsigned long, npages,
-					PAGE_SIZE / sizeof(struct page *)),
-					gup_flags, page_list, NULL);
+		ret = get_user_pages(cur_base,
+				     min_t(unsigned long, npages,
+				     PAGE_SIZE / sizeof(struct page *)),
+				     gup_flags | FOLL_LONGTERM,
+				     page_list, NULL);
 
 		if (ret < 0)
 			goto out;
diff --git a/drivers/media/v4l2-core/videobuf-dma-sg.c b/drivers/media/v4l2-core/videobuf-dma-sg.c
index 08929c087e27..870a2a526e0b 100644
--- a/drivers/media/v4l2-core/videobuf-dma-sg.c
+++ b/drivers/media/v4l2-core/videobuf-dma-sg.c
@@ -186,12 +186,12 @@ static int videobuf_dma_init_user_locked(struct videobuf_dmabuf *dma,
 	dprintk(1, "init user [0x%lx+0x%lx => %d pages]\n",
 		data, size, dma->nr_pages);
 
-	err = get_user_pages_longterm(data & PAGE_MASK, dma->nr_pages,
-			     flags, dma->pages, NULL);
+	err = get_user_pages(data & PAGE_MASK, dma->nr_pages,
+			     flags | FOLL_LONGTERM, dma->pages, NULL);
 
 	if (err != dma->nr_pages) {
 		dma->nr_pages = (err >= 0) ? err : 0;
-		dprintk(1, "get_user_pages_longterm: err=%d [%d]\n", err,
+		dprintk(1, "get_user_pages: err=%d [%d]\n", err,
 			dma->nr_pages);
 		return err < 0 ? err : -EINVAL;
 	}
diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
index 73652e21efec..1500bd0bb6da 100644
--- a/drivers/vfio/vfio_iommu_type1.c
+++ b/drivers/vfio/vfio_iommu_type1.c
@@ -351,7 +351,8 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
 
 	down_read(&mm->mmap_sem);
 	if (mm == current->mm) {
-		ret = get_user_pages_longterm(vaddr, 1, flags, page, vmas);
+		ret = get_user_pages(vaddr, 1, flags | FOLL_LONGTERM, page,
+				     vmas);
 	} else {
 		ret = get_user_pages_remote(NULL, mm, vaddr, 1, flags, page,
 					    vmas, NULL);
diff --git a/fs/io_uring.c b/fs/io_uring.c
index e2bd77da5e21..8d61b81373bd 100644
--- a/fs/io_uring.c
+++ b/fs/io_uring.c
@@ -2450,8 +2450,9 @@ static int io_sqe_buffer_register(struct io_ring_ctx *ctx, void __user *arg,
 
 		ret = 0;
 		down_read(&current->mm->mmap_sem);
-		pret = get_user_pages_longterm(ubuf, nr_pages, FOLL_WRITE,
-						pages, vmas);
+		pret = get_user_pages(ubuf, nr_pages,
+				      FOLL_WRITE | FOLL_LONGTERM,
+				      pages, vmas);
 		if (pret == nr_pages) {
 			/* don't support file backed memory */
 			for (j = 0; j < nr_pages; j++) {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 2d483dbdffc0..6831077d126c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1531,19 +1531,6 @@ long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
 long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
 		    struct page **pages, unsigned int gup_flags);
 
-#if defined(CONFIG_FS_DAX) || defined(CONFIG_CMA)
-long get_user_pages_longterm(unsigned long start, unsigned long nr_pages,
-			    unsigned int gup_flags, struct page **pages,
-			    struct vm_area_struct **vmas);
-#else
-static inline long get_user_pages_longterm(unsigned long start,
-		unsigned long nr_pages, unsigned int gup_flags,
-		struct page **pages, struct vm_area_struct **vmas)
-{
-	return get_user_pages(start, nr_pages, gup_flags, pages, vmas);
-}
-#endif /* CONFIG_FS_DAX */
-
 int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			struct page **pages);
 
@@ -2609,6 +2596,7 @@ struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
 #define FOLL_REMOTE	0x2000	/* we are working on non-current tsk/mm */
 #define FOLL_COW	0x4000	/* internal GUP flag */
 #define FOLL_ANON	0x8000	/* don't do file mappings */
+#define FOLL_LONGTERM	0x10000	/* mapping is intended for a long term pin */
 
 static inline int vm_fault_to_errno(vm_fault_t vm_fault, int foll_flags)
 {
diff --git a/mm/gup.c b/mm/gup.c
index f84e22685aaa..8cb4cff067bc 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1112,26 +1112,7 @@ long get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
 }
 EXPORT_SYMBOL(get_user_pages_remote);
 
-/*
- * This is the same as get_user_pages_remote(), just with a
- * less-flexible calling convention where we assume that the task
- * and mm being operated on are the current task's and don't allow
- * passing of a locked parameter.  We also obviously don't pass
- * FOLL_REMOTE in here.
- */
-long get_user_pages(unsigned long start, unsigned long nr_pages,
-		unsigned int gup_flags, struct page **pages,
-		struct vm_area_struct **vmas)
-{
-	return __get_user_pages_locked(current, current->mm, start, nr_pages,
-				       pages, vmas, NULL,
-				       gup_flags | FOLL_TOUCH);
-}
-EXPORT_SYMBOL(get_user_pages);
-
 #if defined(CONFIG_FS_DAX) || defined (CONFIG_CMA)
-
-#ifdef CONFIG_FS_DAX
 static bool check_dax_vmas(struct vm_area_struct **vmas, long nr_pages)
 {
 	long i;
@@ -1150,12 +1131,6 @@ static bool check_dax_vmas(struct vm_area_struct **vmas, long nr_pages)
 	}
 	return false;
 }
-#else
-static inline bool check_dax_vmas(struct vm_area_struct **vmas, long nr_pages)
-{
-	return false;
-}
-#endif
 
 #ifdef CONFIG_CMA
 static struct page *new_non_cma_page(struct page *page, unsigned long private)
@@ -1209,10 +1184,13 @@ static struct page *new_non_cma_page(struct page *page, unsigned long private)
 	return __alloc_pages_node(nid, gfp_mask, 0);
 }
 
-static long check_and_migrate_cma_pages(unsigned long start, long nr_pages,
-					unsigned int gup_flags,
+static long check_and_migrate_cma_pages(struct task_struct *tsk,
+					struct mm_struct *mm,
+					unsigned long start,
+					unsigned long nr_pages,
 					struct page **pages,
-					struct vm_area_struct **vmas)
+					struct vm_area_struct **vmas,
+					unsigned int gup_flags)
 {
 	long i;
 	bool drain_allow = true;
@@ -1268,10 +1246,14 @@ static long check_and_migrate_cma_pages(unsigned long start, long nr_pages,
 				putback_movable_pages(&cma_page_list);
 		}
 		/*
-		 * We did migrate all the pages, Try to get the page references again
-		 * migrating any new CMA pages which we failed to isolate earlier.
+		 * We did migrate all the pages, Try to get the page references
+		 * again migrating any new CMA pages which we failed to isolate
+		 * earlier.
 		 */
-		nr_pages = get_user_pages(start, nr_pages, gup_flags, pages, vmas);
+		nr_pages = __get_user_pages_locked(tsk, mm, start, nr_pages,
+						   pages, vmas, NULL,
+						   gup_flags);
+
 		if ((nr_pages > 0) && migrate_allow) {
 			drain_allow = true;
 			goto check_again;
@@ -1281,66 +1263,115 @@ static long check_and_migrate_cma_pages(unsigned long start, long nr_pages,
 	return nr_pages;
 }
 #else
-static inline long check_and_migrate_cma_pages(unsigned long start, long nr_pages,
-					       unsigned int gup_flags,
-					       struct page **pages,
-					       struct vm_area_struct **vmas)
+static long check_and_migrate_cma_pages(struct task_struct *tsk,
+					struct mm_struct *mm,
+					unsigned long start,
+					unsigned long nr_pages,
+					struct page **pages,
+					struct vm_area_struct **vmas,
+					unsigned int gup_flags)
 {
 	return nr_pages;
 }
 #endif
 
 /*
- * This is the same as get_user_pages() in that it assumes we are
- * operating on the current task's mm, but it goes further to validate
- * that the vmas associated with the address range are suitable for
- * longterm elevated page reference counts. For example, filesystem-dax
- * mappings are subject to the lifetime enforced by the filesystem and
- * we need guarantees that longterm users like RDMA and V4L2 only
- * establish mappings that have a kernel enforced revocation mechanism.
+ * __gup_longterm_locked() is a wrapper for __get_uer_pages_locked which
+ * allows us to process the FOLL_LONGTERM flag if present.
+ *
+ * FOLL_LONGTERM Checks for either DAX VMAs or PPC CMA regions and either fails
+ * the pin or attempts to migrate the page as appropriate.
+ *
+ * In the filesystem-dax case mappings are subject to the lifetime enforced by
+ * the filesystem and we need guarantees that longterm users like RDMA and V4L2
+ * only establish mappings that have a kernel enforced revocation mechanism.
+ *
+ * In the CMA case pages can't be pinned in a CMA region as this would
+ * unnecessarily fragment that region.  So CMA attempts to migrate the page
+ * before pinning.
  *
  * "longterm" == userspace controlled elevated page count lifetime.
  * Contrast this to iov_iter_get_pages() usages which are transient.
  */
-long get_user_pages_longterm(unsigned long start, unsigned long nr_pages,
-			     unsigned int gup_flags, struct page **pages,
-			     struct vm_area_struct **vmas_arg)
+static __always_inline long __gup_longterm_locked(struct task_struct *tsk,
+						  struct mm_struct *mm,
+						  unsigned long start,
+						  unsigned long nr_pages,
+						  struct page **pages,
+						  struct vm_area_struct **vmas,
+						  unsigned int gup_flags)
 {
-	struct vm_area_struct **vmas = vmas_arg;
-	unsigned long flags;
+	struct vm_area_struct **vmas_tmp = vmas;
+	unsigned long flags = 0;
 	long rc, i;
 
-	if (!pages)
-		return -EINVAL;
-
-	if (!vmas) {
-		vmas = kcalloc(nr_pages, sizeof(struct vm_area_struct *),
-			       GFP_KERNEL);
-		if (!vmas)
-			return -ENOMEM;
+	if (gup_flags & FOLL_LONGTERM) {
+		if (!pages)
+			return -EINVAL;
+
+		if (!vmas_tmp) {
+			vmas_tmp = kcalloc(nr_pages,
+					   sizeof(struct vm_area_struct *),
+					   GFP_KERNEL);
+			if (!vmas_tmp)
+				return -ENOMEM;
+		}
+		flags = memalloc_nocma_save();
 	}
 
-	flags = memalloc_nocma_save();
-	rc = get_user_pages(start, nr_pages, gup_flags, pages, vmas);
-	memalloc_nocma_restore(flags);
-	if (rc < 0)
-		goto out;
+	rc = __get_user_pages_locked(tsk, mm, start, nr_pages, pages,
+				     vmas_tmp, NULL, gup_flags);
 
-	if (check_dax_vmas(vmas, rc)) {
-		for (i = 0; i < rc; i++)
-			put_page(pages[i]);
-		rc = -EOPNOTSUPP;
-		goto out;
+	if (gup_flags & FOLL_LONGTERM) {
+		memalloc_nocma_restore(flags);
+		if (rc < 0)
+			goto out;
+
+		if (check_dax_vmas(vmas_tmp, rc)) {
+			for (i = 0; i < rc; i++)
+				put_page(pages[i]);
+			rc = -EOPNOTSUPP;
+			goto out;
+		}
+
+		rc = check_and_migrate_cma_pages(tsk, mm, start, rc, pages,
+						 vmas_tmp, gup_flags);
 	}
 
-	rc = check_and_migrate_cma_pages(start, rc, gup_flags, pages, vmas);
 out:
-	if (vmas != vmas_arg)
-		kfree(vmas);
+	if (vmas_tmp != vmas)
+		kfree(vmas_tmp);
 	return rc;
 }
-EXPORT_SYMBOL(get_user_pages_longterm);
-#endif /* CONFIG_FS_DAX */
+#else /* !CONFIG_FS_DAX && !CONFIG_CMA */
+static __always_inline long __gup_longterm_locked(struct task_struct *tsk,
+						  struct mm_struct *mm,
+						  unsigned long start,
+						  unsigned long nr_pages,
+						  struct page **pages,
+						  struct vm_area_struct **vmas,
+						  unsigned int flags)
+{
+	return __get_user_pages_locked(tsk, mm, start, nr_pages, pages, vmas,
+				       NULL, flags);
+}
+#endif /* CONFIG_FS_DAX || CONFIG_CMA */
+
+/*
+ * This is the same as get_user_pages_remote(), just with a
+ * less-flexible calling convention where we assume that the task
+ * and mm being operated on are the current task's and don't allow
+ * passing of a locked parameter.  We also obviously don't pass
+ * FOLL_REMOTE in here.
+ */
+long get_user_pages(unsigned long start, unsigned long nr_pages,
+		unsigned int gup_flags, struct page **pages,
+		struct vm_area_struct **vmas)
+{
+	return __gup_longterm_locked(current, current->mm, start, nr_pages,
+				     pages, vmas, gup_flags | FOLL_TOUCH);
+}
+EXPORT_SYMBOL(get_user_pages);
 
 /**
  * populate_vma_page_range() -  populate a range of pages in the vma.
diff --git a/mm/gup_benchmark.c b/mm/gup_benchmark.c
index 6c0279e70cc4..7dd602d7f8db 100644
--- a/mm/gup_benchmark.c
+++ b/mm/gup_benchmark.c
@@ -54,8 +54,9 @@ static int __gup_benchmark_ioctl(unsigned int cmd,
 						 pages + i);
 			break;
 		case GUP_LONGTERM_BENCHMARK:
-			nr = get_user_pages_longterm(addr, nr, gup->flags & 1,
-						     pages + i, NULL);
+			nr = get_user_pages(addr, nr,
+					    (gup->flags & 1) | FOLL_LONGTERM,
+					    pages + i, NULL);
 			break;
 		case GUP_BENCHMARK:
 			nr = get_user_pages(addr, nr, gup->flags & 1, pages + i,
diff --git a/net/xdp/xdp_umem.c b/net/xdp/xdp_umem.c
index 77520eacee8f..ab489454a63e 100644
--- a/net/xdp/xdp_umem.c
+++ b/net/xdp/xdp_umem.c
@@ -267,8 +267,8 @@ static int xdp_umem_pin_pages(struct xdp_umem *umem)
 		return -ENOMEM;
 
 	down_read(&current->mm->mmap_sem);
-	npgs = get_user_pages_longterm(umem->address, umem->npgs,
-				       gup_flags, &umem->pgs[0], NULL);
+	npgs = get_user_pages(umem->address, umem->npgs,
+			      gup_flags | FOLL_LONGTERM, &umem->pgs[0], NULL);
 	up_read(&current->mm->mmap_sem);
 
 	if (npgs != umem->npgs) {
-- 
2.20.1

