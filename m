Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D671BC48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:27:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 819EE20663
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:27:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="JI26dnXH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 819EE20663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F2A888E000F; Wed, 26 Jun 2019 08:27:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB6DF8E000E; Wed, 26 Jun 2019 08:27:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D06548E000F; Wed, 26 Jun 2019 08:27:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 915C38E000E
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:27:50 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id h15so1692224pfn.3
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:27:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=IuSVDPBHudchWUkWljO4sDvSgYSGPjFvkYKeyIq9LMc=;
        b=jOX0RrX0boc73KziVO9G1dFFC16nldW5CfdOo3K1FOWpXMtRM2WJgHf9cD2AKrvYJy
         adTduGLE0J9epW2HhP0k07qFsSb2x014w+3QrHbRcbeEU0Ac2/7BngNvhAJf2TXelHYv
         byPS1n6RIoikfcgt93W2PzKabxxWZrEpFBo6SUskh6R9sw7fqy+Czn41/P/Tx39am3+L
         6rszmHLsPYnMUVVMw5VbO5mXZ6zF3oFoPIgg/CULst5qH/iR5stRO50eFykS6pX7llqw
         NS3+jxNOXpZkLuCELJiHNxRl/MZcoCPlhlDWnj/gnZm8STdKrKVFoWexTcY1BFibz/4Y
         Tr5A==
X-Gm-Message-State: APjAAAU2Re/BBwPjHH6wkxNayfxQ+l+4jsm4UdCK6mQeLBbTdBKX/uUu
	SZL0hPbEBjVNBh2RggBET0c8EAVFeuqJ0nbN+wX4LBCQlj/8jjsIvok6uUFw/sLr5l+uWZ5pFyG
	Okb2shgl0OmPraTa8ufHfuxvNUOORXGGoNzxA/O67rg6r+A/HZVqhrc6zOK6IwKY=
X-Received: by 2002:a17:90a:270f:: with SMTP id o15mr4474727pje.56.1561552070196;
        Wed, 26 Jun 2019 05:27:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdDozrV8y2BRkh5dVAcnzBUPAHwULQgbPef+jabQb+/qenJ4KQVzxMAmtwKvg90hYuKjij
X-Received: by 2002:a17:90a:270f:: with SMTP id o15mr4474611pje.56.1561552068779;
        Wed, 26 Jun 2019 05:27:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561552068; cv=none;
        d=google.com; s=arc-20160816;
        b=H4ih9RHpdjgC3XNBl2azIPlpOfRvhhWuPMUiHOXACa/Bd8CmVHg4SOMy5j4rWxHWaj
         rLoSs9+KeYten8YQzcc3blEhzFuSgNcSGuLi1GlXCZRjmQBC/Xfj1d/AARzE5MBAIEfz
         OxhqIG2YLn9G8qFoy3C7ADoT7eIYTyjwnF7jDeoACH6KYhGqF2eFCClh+x1CN65FgpD3
         e+ZHSEsB6NfGTaD44xT8h7nO1bXDW+ElIZ4+w9krXfcrYlO3JNWhdz16pPNRuFqWzEsE
         0dFQ0GCqr39iPUR0S30Uad9rrG5WD5J4ZxgFn5thuNiK72Yu2NcoqvVmN3HTcMbRkYVc
         VT6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=IuSVDPBHudchWUkWljO4sDvSgYSGPjFvkYKeyIq9LMc=;
        b=vpkoduC+MDrruxXulsaULHiA5MgJme5vM2IvJglaZXhK/kQVxEYQfBJyxaJcNYN9fU
         K2PNM4uu0XRz2q2CcQ/98fE2XHD+Fr9hud0j3qoqT4HhGNJ+K/gtKhdKK+OAE9gkpaqE
         mIQxEe9a997dC98IiQ9TkjdAhGJ+3WtcbKojBifkC4sxHSHZnUKRIWZv547gwHKiYZZo
         LhhOqtJIfxU+9YjAZpH9VaIc2UN43LHCyHCdkEd3T3obUn1f+Ztm1bsHL8vObDCfB7pl
         T2X7CKg1smh10eCzoYdNeK5Py3EhNu6DmYNDi9Y/mM1DIcgdPwk7oIt+C/WYRNB34T/m
         LYtw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=JI26dnXH;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w17si18470506pfj.69.2019.06.26.05.27.48
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 26 Jun 2019 05:27:48 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=JI26dnXH;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=IuSVDPBHudchWUkWljO4sDvSgYSGPjFvkYKeyIq9LMc=; b=JI26dnXHpGPmFcF+rpii1hZv3Z
	Ek0KGlwl/lxGCVUxUSyC/eHM6sl/iVonfU7vti0UMb7JDmvwQIuAiVVyFOYeGUfHdgjpEdqF3+iCL
	a7xG6ajTzxtHTForLNaEe2xJqgLzs1sCEkGqnGaePrdZeWzJajntlWjBj+/M9uyhkP/BE+InVWKq2
	toX0aqRMU8tm+bgQa95bY3Y/xe2T0NBo1ymo91HHPou8tgm1RJMR+UIvcd3lYAoQIc0lSkjVNouQH
	JY+rBvuJYFPW8pUQdujdNPD9ZJap5kl7UgTHeJ0UMv690BqCG2MqrZ1mm6X5XDqeyZtJzLhMcUJEI
	KueE+atQ==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hg71W-0001LR-EH; Wed, 26 Jun 2019 12:27:38 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Michal Hocko <mhocko@suse.com>
Subject: [PATCH 04/25] mm: remove MEMORY_DEVICE_PUBLIC support
Date: Wed, 26 Jun 2019 14:27:03 +0200
Message-Id: <20190626122724.13313-5-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190626122724.13313-1-hch@lst.de>
References: <20190626122724.13313-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The code hasn't been used since it was added to the tree, and doesn't
appear to actually be usable.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/hmm.h      |  4 ++--
 include/linux/ioport.h   |  1 -
 include/linux/memremap.h |  8 --------
 include/linux/mm.h       | 12 ------------
 mm/Kconfig               | 11 -----------
 mm/gup.c                 |  7 -------
 mm/hmm.c                 |  4 ++--
 mm/memcontrol.c          | 11 +++++------
 mm/memory-failure.c      |  6 +-----
 mm/memory.c              | 34 ----------------------------------
 mm/migrate.c             | 26 +++-----------------------
 mm/swap.c                | 11 -----------
 12 files changed, 13 insertions(+), 122 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 5c46b0f603fd..44a5ac738bb5 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -584,7 +584,7 @@ static inline void hmm_mm_destroy(struct mm_struct *mm) {}
 static inline void hmm_mm_init(struct mm_struct *mm) {}
 #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
 
-#if IS_ENABLED(CONFIG_DEVICE_PRIVATE) ||  IS_ENABLED(CONFIG_DEVICE_PUBLIC)
+#if IS_ENABLED(CONFIG_DEVICE_PRIVATE)
 struct hmm_devmem;
 
 struct page *hmm_vma_alloc_locked_page(struct vm_area_struct *vma,
@@ -748,7 +748,7 @@ static inline unsigned long hmm_devmem_page_get_drvdata(const struct page *page)
 {
 	return page->hmm_data;
 }
-#endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
+#endif /* CONFIG_DEVICE_PRIVATE */
 #else /* IS_ENABLED(CONFIG_HMM) */
 static inline void hmm_mm_destroy(struct mm_struct *mm) {}
 static inline void hmm_mm_init(struct mm_struct *mm) {}
diff --git a/include/linux/ioport.h b/include/linux/ioport.h
index da0ebaec25f0..dd961882bc74 100644
--- a/include/linux/ioport.h
+++ b/include/linux/ioport.h
@@ -132,7 +132,6 @@ enum {
 	IORES_DESC_PERSISTENT_MEMORY		= 4,
 	IORES_DESC_PERSISTENT_MEMORY_LEGACY	= 5,
 	IORES_DESC_DEVICE_PRIVATE_MEMORY	= 6,
-	IORES_DESC_DEVICE_PUBLIC_MEMORY		= 7,
 };
 
 /* helpers to define resources */
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 1732dea030b2..995c62c5a48b 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -37,13 +37,6 @@ struct vmem_altmap {
  * A more complete discussion of unaddressable memory may be found in
  * include/linux/hmm.h and Documentation/vm/hmm.rst.
  *
- * MEMORY_DEVICE_PUBLIC:
- * Device memory that is cache coherent from device and CPU point of view. This
- * is use on platform that have an advance system bus (like CAPI or CCIX). A
- * driver can hotplug the device memory using ZONE_DEVICE and with that memory
- * type. Any page of a process can be migrated to such memory. However no one
- * should be allow to pin such memory so that it can always be evicted.
- *
  * MEMORY_DEVICE_FS_DAX:
  * Host memory that has similar access semantics as System RAM i.e. DMA
  * coherent and supports page pinning. In support of coordinating page
@@ -58,7 +51,6 @@ struct vmem_altmap {
  */
 enum memory_type {
 	MEMORY_DEVICE_PRIVATE = 1,
-	MEMORY_DEVICE_PUBLIC,
 	MEMORY_DEVICE_FS_DAX,
 	MEMORY_DEVICE_PCI_P2PDMA,
 };
diff --git a/include/linux/mm.h b/include/linux/mm.h
index dd0b5f4e1e45..6e4b9be08b13 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -944,7 +944,6 @@ static inline bool put_devmap_managed_page(struct page *page)
 		return false;
 	switch (page->pgmap->type) {
 	case MEMORY_DEVICE_PRIVATE:
-	case MEMORY_DEVICE_PUBLIC:
 	case MEMORY_DEVICE_FS_DAX:
 		__put_devmap_managed_page(page);
 		return true;
@@ -960,12 +959,6 @@ static inline bool is_device_private_page(const struct page *page)
 		page->pgmap->type == MEMORY_DEVICE_PRIVATE;
 }
 
-static inline bool is_device_public_page(const struct page *page)
-{
-	return is_zone_device_page(page) &&
-		page->pgmap->type == MEMORY_DEVICE_PUBLIC;
-}
-
 #ifdef CONFIG_PCI_P2PDMA
 static inline bool is_pci_p2pdma_page(const struct page *page)
 {
@@ -998,11 +991,6 @@ static inline bool is_device_private_page(const struct page *page)
 	return false;
 }
 
-static inline bool is_device_public_page(const struct page *page)
-{
-	return false;
-}
-
 static inline bool is_pci_p2pdma_page(const struct page *page)
 {
 	return false;
diff --git a/mm/Kconfig b/mm/Kconfig
index 0d2ba7e1f43e..6f35b85b3052 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -718,17 +718,6 @@ config DEVICE_PRIVATE
 	  memory; i.e., memory that is only accessible from the device (or
 	  group of devices). You likely also want to select HMM_MIRROR.
 
-config DEVICE_PUBLIC
-	bool "Addressable device memory (like GPU memory)"
-	depends on ARCH_HAS_HMM
-	select HMM
-	select DEV_PAGEMAP_OPS
-
-	help
-	  Allows creation of struct pages to represent addressable device
-	  memory; i.e., memory that is accessible from both the device and
-	  the CPU
-
 config FRAME_VECTOR
 	bool
 
diff --git a/mm/gup.c b/mm/gup.c
index ddde097cf9e4..fe131d879c70 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -605,13 +605,6 @@ static int get_gate_page(struct mm_struct *mm, unsigned long address,
 		if ((gup_flags & FOLL_DUMP) || !is_zero_pfn(pte_pfn(*pte)))
 			goto unmap;
 		*page = pte_page(*pte);
-
-		/*
-		 * This should never happen (a device public page in the gate
-		 * area).
-		 */
-		if (is_device_public_page(*page))
-			goto unmap;
 	}
 	if (unlikely(!try_get_page(*page))) {
 		ret = -ENOMEM;
diff --git a/mm/hmm.c b/mm/hmm.c
index bd260a3b6b09..376159a769fb 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1331,7 +1331,7 @@ EXPORT_SYMBOL(hmm_range_dma_unmap);
 #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
 
 
-#if IS_ENABLED(CONFIG_DEVICE_PRIVATE) ||  IS_ENABLED(CONFIG_DEVICE_PUBLIC)
+#if IS_ENABLED(CONFIG_DEVICE_PRIVATE)
 struct page *hmm_vma_alloc_locked_page(struct vm_area_struct *vma,
 				       unsigned long addr)
 {
@@ -1478,4 +1478,4 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 	return devmem;
 }
 EXPORT_SYMBOL_GPL(hmm_devmem_add);
-#endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
+#endif /* CONFIG_DEVICE_PRIVATE  */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ba9138a4a1de..fa844ae85bce 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4994,8 +4994,8 @@ static int mem_cgroup_move_account(struct page *page,
  *   2(MC_TARGET_SWAP): if the swap entry corresponding to this pte is a
  *     target for charge migration. if @target is not NULL, the entry is stored
  *     in target->ent.
- *   3(MC_TARGET_DEVICE): like MC_TARGET_PAGE  but page is MEMORY_DEVICE_PUBLIC
- *     or MEMORY_DEVICE_PRIVATE (so ZONE_DEVICE page and thus not on the lru).
+ *   3(MC_TARGET_DEVICE): like MC_TARGET_PAGE  but page is MEMORY_DEVICE_PRIVATE
+ *     (so ZONE_DEVICE page and thus not on the lru).
  *     For now we such page is charge like a regular page would be as for all
  *     intent and purposes it is just special memory taking the place of a
  *     regular page.
@@ -5029,8 +5029,7 @@ static enum mc_target_type get_mctgt_type(struct vm_area_struct *vma,
 		 */
 		if (page->mem_cgroup == mc.from) {
 			ret = MC_TARGET_PAGE;
-			if (is_device_private_page(page) ||
-			    is_device_public_page(page))
+			if (is_device_private_page(page))
 				ret = MC_TARGET_DEVICE;
 			if (target)
 				target->page = page;
@@ -5101,8 +5100,8 @@ static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
 	if (ptl) {
 		/*
 		 * Note their can not be MC_TARGET_DEVICE for now as we do not
-		 * support transparent huge page with MEMORY_DEVICE_PUBLIC or
-		 * MEMORY_DEVICE_PRIVATE but this might change.
+		 * support transparent huge page with MEMORY_DEVICE_PRIVATE but
+		 * this might change.
 		 */
 		if (get_mctgt_type_thp(vma, addr, *pmd, NULL) == MC_TARGET_PAGE)
 			mc.precharge += HPAGE_PMD_NR;
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 8da0334b9ca0..d9fc1a8bdf6a 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1177,16 +1177,12 @@ static int memory_failure_dev_pagemap(unsigned long pfn, int flags,
 		goto unlock;
 	}
 
-	switch (pgmap->type) {
-	case MEMORY_DEVICE_PRIVATE:
-	case MEMORY_DEVICE_PUBLIC:
+	if (pgmap->type == MEMORY_DEVICE_PRIVATE) {
 		/*
 		 * TODO: Handle HMM pages which may need coordination
 		 * with device-side memory.
 		 */
 		goto unlock;
-	default:
-		break;
 	}
 
 	/*
diff --git a/mm/memory.c b/mm/memory.c
index ddf20bd0c317..bd21e7063bf0 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -585,29 +585,6 @@ struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 			return NULL;
 		if (is_zero_pfn(pfn))
 			return NULL;
-
-		/*
-		 * Device public pages are special pages (they are ZONE_DEVICE
-		 * pages but different from persistent memory). They behave
-		 * allmost like normal pages. The difference is that they are
-		 * not on the lru and thus should never be involve with any-
-		 * thing that involve lru manipulation (mlock, numa balancing,
-		 * ...).
-		 *
-		 * This is why we still want to return NULL for such page from
-		 * vm_normal_page() so that we do not have to special case all
-		 * call site of vm_normal_page().
-		 */
-		if (likely(pfn <= highest_memmap_pfn)) {
-			struct page *page = pfn_to_page(pfn);
-
-			if (is_device_public_page(page)) {
-				if (with_public_device)
-					return page;
-				return NULL;
-			}
-		}
-
 		if (pte_devmap(pte))
 			return NULL;
 
@@ -797,17 +774,6 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		rss[mm_counter(page)]++;
 	} else if (pte_devmap(pte)) {
 		page = pte_page(pte);
-
-		/*
-		 * Cache coherent device memory behave like regular page and
-		 * not like persistent memory page. For more informations see
-		 * MEMORY_DEVICE_CACHE_COHERENT in memory_hotplug.h
-		 */
-		if (is_device_public_page(page)) {
-			get_page(page);
-			page_dup_rmap(page, false);
-			rss[mm_counter(page)]++;
-		}
 	}
 
 out_set_pte:
diff --git a/mm/migrate.c b/mm/migrate.c
index f2ecc2855a12..149c692d5f9b 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -246,8 +246,6 @@ static bool remove_migration_pte(struct page *page, struct vm_area_struct *vma,
 			if (is_device_private_page(new)) {
 				entry = make_device_private_entry(new, pte_write(pte));
 				pte = swp_entry_to_pte(entry);
-			} else if (is_device_public_page(new)) {
-				pte = pte_mkdevmap(pte);
 			}
 		}
 
@@ -381,7 +379,6 @@ static int expected_page_refs(struct address_space *mapping, struct page *page)
 	 * ZONE_DEVICE pages.
 	 */
 	expected_count += is_device_private_page(page);
-	expected_count += is_device_public_page(page);
 	if (mapping)
 		expected_count += hpage_nr_pages(page) + page_has_private(page);
 
@@ -994,10 +991,7 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 		if (!PageMappingFlags(page))
 			page->mapping = NULL;
 
-		if (unlikely(is_zone_device_page(newpage))) {
-			if (is_device_public_page(newpage))
-				flush_dcache_page(newpage);
-		} else
+		if (likely(!is_zone_device_page(newpage)))
 			flush_dcache_page(newpage);
 
 	}
@@ -2406,16 +2400,7 @@ static bool migrate_vma_check_page(struct page *page)
 		 * FIXME proper solution is to rework migration_entry_wait() so
 		 * it does not need to take a reference on page.
 		 */
-		if (is_device_private_page(page))
-			return true;
-
-		/*
-		 * Only allow device public page to be migrated and account for
-		 * the extra reference count imply by ZONE_DEVICE pages.
-		 */
-		if (!is_device_public_page(page))
-			return false;
-		extra++;
+		return is_device_private_page(page);
 	}
 
 	/* For file back page */
@@ -2665,11 +2650,6 @@ static void migrate_vma_insert_page(struct migrate_vma *migrate,
 
 			swp_entry = make_device_private_entry(page, vma->vm_flags & VM_WRITE);
 			entry = swp_entry_to_pte(swp_entry);
-		} else if (is_device_public_page(page)) {
-			entry = pte_mkold(mk_pte(page, READ_ONCE(vma->vm_page_prot)));
-			if (vma->vm_flags & VM_WRITE)
-				entry = pte_mkwrite(pte_mkdirty(entry));
-			entry = pte_mkdevmap(entry);
 		}
 	} else {
 		entry = mk_pte(page, vma->vm_page_prot);
@@ -2789,7 +2769,7 @@ static void migrate_vma_pages(struct migrate_vma *migrate)
 					migrate->src[i] &= ~MIGRATE_PFN_MIGRATE;
 					continue;
 				}
-			} else if (!is_device_public_page(newpage)) {
+			} else {
 				/*
 				 * Other types of ZONE_DEVICE page are not
 				 * supported.
diff --git a/mm/swap.c b/mm/swap.c
index 7ede3eddc12a..83107410d29f 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -740,17 +740,6 @@ void release_pages(struct page **pages, int nr)
 		if (is_huge_zero_page(page))
 			continue;
 
-		/* Device public page can not be huge page */
-		if (is_device_public_page(page)) {
-			if (locked_pgdat) {
-				spin_unlock_irqrestore(&locked_pgdat->lru_lock,
-						       flags);
-				locked_pgdat = NULL;
-			}
-			put_devmap_managed_page(page);
-			continue;
-		}
-
 		page = compound_head(page);
 		if (!put_page_testzero(page))
 			continue;
-- 
2.20.1

