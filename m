Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 785D6C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 16:45:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0CEAE21773
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 16:45:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CEAE21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C0DDA6B0266; Thu, 28 Mar 2019 12:45:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B6C876B026B; Thu, 28 Mar 2019 12:45:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 99AEC6B026D; Thu, 28 Mar 2019 12:45:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4D6946B0266
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 12:45:41 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id q18so2701540pll.16
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 09:45:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8GS7kfPwWVz1qptFmBxi25Evvk1q5KxsOu4AatUFvR0=;
        b=h0iPsFe1sY2rLQft9L8nW8ohTqOyiwsooYKbtpboVr6sHPWIiI7B5AIuf2KBlBATEZ
         r8gqpt8DZP88wSb1T2rIKC7C3nvXfYHF79x9PqiVrJLpzpWwV7Ysi5f4nfsXjy8Y4wfH
         2SihMA09c3DUZ2pIZ4j3B3Y6HnDvt5PrbNR6fKVNVCL4IkOGFuvvI7G3kY7ko2oUaCzz
         UlzAdDIhBIqYHd1XPh3ngb38KRy9QOqfGuqrvtYr5AgvyHkoVldg/T7PVnhhPLuDG+WT
         rZ26PmsR5KylXTVTJNIjSx3eArOMLCsKKrfmUQ5QP7NDvM33aOhKodJKMvmmFSJOLD8X
         Xlig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUh2vXHpj9suIkBIIYeqHS8Rq+rzD42lJxVXfiQbzumZ5/TNoaS
	vyYq/jRSls1WTwKCml9YUffYJSrmpBbvtJTjeoAhAKoaqOLi5t+82G7czJ5DkwLhQhaY5OzOw0e
	3gqRuMGdkmr9/455D2p6AikbprKZJM3DVtQf+TTArIhjRoDqp6ZQ70MutGAZ4oMGcBg==
X-Received: by 2002:a65:620e:: with SMTP id d14mr41152897pgv.28.1553791540839;
        Thu, 28 Mar 2019 09:45:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwreh4mvFe3324WOp2fGgwXKfq1y+JGpNxFfFH9TSnPBnVNHFGDfoViIbehfCvnCQr0OCHu
X-Received: by 2002:a65:620e:: with SMTP id d14mr41152692pgv.28.1553791538168;
        Thu, 28 Mar 2019 09:45:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553791538; cv=none;
        d=google.com; s=arc-20160816;
        b=lP6Yl608jDNGvYTGTRFX0TdJu4z9/yznd1YOh0qMyZKxFfsdskDxNo20vYQ7PzhCST
         9Z6Fe2eEsN/GuEXt8NXwuNRxD2fA8dilllkUji4XUmQbPcSylI4soCB1PexmFTYAfJCZ
         +MSQu6LtMd2h4Wid4eEcRatqaursPPJbu+b3jxjWbcSB9ex/uhem5bz3IhC4GXGBCVRv
         Mb44MvNJvNtM4Hm/O60g4Xt1EhElsrWlhp5a2JOB2gA12WnaGcPybnq5xuMsHAkT69AI
         BtFPcpQV4h681X6gZ9kenLEDy/PFBPZAhdyCEOxRF4MbU4HrM1yTbjGO3lU+2YMFuUy8
         luOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=8GS7kfPwWVz1qptFmBxi25Evvk1q5KxsOu4AatUFvR0=;
        b=LtjOIGil5e4O3s60JIwGLIuYWkHRNy3g7lSZF22D4xp653FDVRrHCyH57+QwgUyMI/
         hsIbuIO9hXjAYX/fDNkWgQHvU7bNmTxRp7eMiQAJkSvbr/qvB5jmbgEtHWWZovhQYHOc
         Pp8egf8yqQVy73q8Q40Ir8GKf8PySDD4lBCRcoOsxywu9CK2KwvjvzG8nWrMJhxX6ED2
         jFGwzHX3FTzX0O1Trt8w2gUOs8rATnu9wjZLGIkfRgrn2v/FSPhYMCwHc8xpnnlVWpLF
         YDC9zf4AZ2cVmLAP+Wk//tKFl7N1SdGcH3sAiPcxpM6uO5KIc+cWBkmV+Cc6QfgyCmbu
         RwQg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 31si22686092plb.39.2019.03.28.09.45.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 09:45:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Mar 2019 09:45:35 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,281,1549958400"; 
   d="scan'208";a="218460203"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga001.jf.intel.com with ESMTP; 28 Mar 2019 09:45:36 -0700
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
	Mike Marshall <hubcap@omnibond.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-mips@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org
Subject: [PATCH V3 3/7] mm/gup: Change GUP fast to use flags rather than a write 'bool'
Date: Thu, 28 Mar 2019 01:44:18 -0700
Message-Id: <20190328084422.29911-4-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190328084422.29911-1-ira.weiny@intel.com>
References: <20190328084422.29911-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

To facilitate additional options to get_user_pages_fast() change the
singular write parameter to be gup_flags.

This patch does not change any functionality.  New functionality will
follow in subsequent patches.

Some of the get_user_pages_fast() call sites were unchanged because they
already passed FOLL_WRITE or 0 for the write parameter.

NOTE: It was suggested to change the ordering of the
get_user_pages_fast() arguments to ensure that callers were converted.
This breaks the current GUP call site convention of having the returned
pages be the final parameter.  So the suggestion was rejected.

Reviewed-by: Mike Marshall <hubcap@omnibond.com>
Signed-off-by: Ira Weiny <ira.weiny@intel.com>

---
Changes from V2:
	Added Review tag

Changes from V1:
	Rebase to current merge tree
	arch/powerpc/mm/mmu_context_iommu.c no longer calls gup_fast
		The gup_longterm it used was converted in a previous
		patch

 arch/mips/mm/gup.c                         | 11 ++++++-----
 arch/powerpc/kvm/book3s_64_mmu_hv.c        |  4 ++--
 arch/powerpc/kvm/e500_mmu.c                |  2 +-
 arch/s390/kvm/interrupt.c                  |  2 +-
 arch/s390/mm/gup.c                         | 12 ++++++------
 arch/sh/mm/gup.c                           | 11 ++++++-----
 arch/sparc/mm/gup.c                        |  9 +++++----
 arch/x86/kvm/paging_tmpl.h                 |  2 +-
 arch/x86/kvm/svm.c                         |  2 +-
 drivers/fpga/dfl-afu-dma-region.c          |  2 +-
 drivers/gpu/drm/via/via_dmablit.c          |  3 ++-
 drivers/infiniband/hw/hfi1/user_pages.c    |  3 ++-
 drivers/misc/genwqe/card_utils.c           |  2 +-
 drivers/misc/vmw_vmci/vmci_host.c          |  2 +-
 drivers/misc/vmw_vmci/vmci_queue_pair.c    |  6 ++++--
 drivers/platform/goldfish/goldfish_pipe.c  |  3 ++-
 drivers/rapidio/devices/rio_mport_cdev.c   |  4 +++-
 drivers/sbus/char/oradax.c                 |  2 +-
 drivers/scsi/st.c                          |  3 ++-
 drivers/staging/gasket/gasket_page_table.c |  4 ++--
 drivers/tee/tee_shm.c                      |  2 +-
 drivers/vfio/vfio_iommu_spapr_tce.c        |  3 ++-
 drivers/vhost/vhost.c                      |  2 +-
 drivers/video/fbdev/pvr2fb.c               |  2 +-
 drivers/virt/fsl_hypervisor.c              |  2 +-
 drivers/xen/gntdev.c                       |  2 +-
 fs/orangefs/orangefs-bufmap.c              |  2 +-
 include/linux/mm.h                         |  4 ++--
 kernel/futex.c                             |  2 +-
 lib/iov_iter.c                             |  7 +++++--
 mm/gup.c                                   | 10 +++++-----
 mm/util.c                                  |  8 ++++----
 net/ceph/pagevec.c                         |  2 +-
 net/rds/info.c                             |  2 +-
 net/rds/rdma.c                             |  3 ++-
 35 files changed, 79 insertions(+), 63 deletions(-)

diff --git a/arch/mips/mm/gup.c b/arch/mips/mm/gup.c
index 0d14e0d8eacf..4c2b4483683c 100644
--- a/arch/mips/mm/gup.c
+++ b/arch/mips/mm/gup.c
@@ -235,7 +235,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
  * get_user_pages_fast() - pin user pages in memory
  * @start:	starting user address
  * @nr_pages:	number of pages from start to pin
- * @write:	whether pages will be written to
+ * @gup_flags:	flags modifying pin behaviour
  * @pages:	array that receives pointers to the pages pinned.
  *		Should be at least nr_pages long.
  *
@@ -247,8 +247,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
  * requested. If nr_pages is 0 or negative, returns 0. If no pages
  * were pinned, returns -errno.
  */
-int get_user_pages_fast(unsigned long start, int nr_pages, int write,
-			struct page **pages)
+int get_user_pages_fast(unsigned long start, int nr_pages,
+			unsigned int gup_flags, struct page **pages)
 {
 	struct mm_struct *mm = current->mm;
 	unsigned long addr, len, end;
@@ -273,7 +273,8 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 		next = pgd_addr_end(addr, end);
 		if (pgd_none(pgd))
 			goto slow;
-		if (!gup_pud_range(pgd, addr, next, write, pages, &nr))
+		if (!gup_pud_range(pgd, addr, next, gup_flags & FOLL_WRITE,
+				   pages, &nr))
 			goto slow;
 	} while (pgdp++, addr = next, addr != end);
 	local_irq_enable();
@@ -289,7 +290,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	pages += nr;
 
 	ret = get_user_pages_unlocked(start, (end - start) >> PAGE_SHIFT,
-				      pages, write ? FOLL_WRITE : 0);
+				      pages, gup_flags);
 
 	/* Have to be a bit careful with return values */
 	if (nr > 0) {
diff --git a/arch/powerpc/kvm/book3s_64_mmu_hv.c b/arch/powerpc/kvm/book3s_64_mmu_hv.c
index be7bc070eae5..ab3d484c5e2e 100644
--- a/arch/powerpc/kvm/book3s_64_mmu_hv.c
+++ b/arch/powerpc/kvm/book3s_64_mmu_hv.c
@@ -600,7 +600,7 @@ int kvmppc_book3s_hv_page_fault(struct kvm_run *run, struct kvm_vcpu *vcpu,
 	/* If writing != 0, then the HPTE must allow writing, if we get here */
 	write_ok = writing;
 	hva = gfn_to_hva_memslot(memslot, gfn);
-	npages = get_user_pages_fast(hva, 1, writing, pages);
+	npages = get_user_pages_fast(hva, 1, writing ? FOLL_WRITE : 0, pages);
 	if (npages < 1) {
 		/* Check if it's an I/O mapping */
 		down_read(&current->mm->mmap_sem);
@@ -1193,7 +1193,7 @@ void *kvmppc_pin_guest_page(struct kvm *kvm, unsigned long gpa,
 	if (!memslot || (memslot->flags & KVM_MEMSLOT_INVALID))
 		goto err;
 	hva = gfn_to_hva_memslot(memslot, gfn);
-	npages = get_user_pages_fast(hva, 1, 1, pages);
+	npages = get_user_pages_fast(hva, 1, FOLL_WRITE, pages);
 	if (npages < 1)
 		goto err;
 	page = pages[0];
diff --git a/arch/powerpc/kvm/e500_mmu.c b/arch/powerpc/kvm/e500_mmu.c
index 24296f4cadc6..e0af53fd78c5 100644
--- a/arch/powerpc/kvm/e500_mmu.c
+++ b/arch/powerpc/kvm/e500_mmu.c
@@ -783,7 +783,7 @@ int kvm_vcpu_ioctl_config_tlb(struct kvm_vcpu *vcpu,
 	if (!pages)
 		return -ENOMEM;
 
-	ret = get_user_pages_fast(cfg->array, num_pages, 1, pages);
+	ret = get_user_pages_fast(cfg->array, num_pages, FOLL_WRITE, pages);
 	if (ret < 0)
 		goto free_pages;
 
diff --git a/arch/s390/kvm/interrupt.c b/arch/s390/kvm/interrupt.c
index 82162867f378..95ab979541be 100644
--- a/arch/s390/kvm/interrupt.c
+++ b/arch/s390/kvm/interrupt.c
@@ -2376,7 +2376,7 @@ static int kvm_s390_adapter_map(struct kvm *kvm, unsigned int id, __u64 addr)
 		ret = -EFAULT;
 		goto out;
 	}
-	ret = get_user_pages_fast(map->addr, 1, 1, &map->page);
+	ret = get_user_pages_fast(map->addr, 1, FOLL_WRITE, &map->page);
 	if (ret < 0)
 		goto out;
 	BUG_ON(ret != 1);
diff --git a/arch/s390/mm/gup.c b/arch/s390/mm/gup.c
index 2809d11c7a28..0a6faf3d9960 100644
--- a/arch/s390/mm/gup.c
+++ b/arch/s390/mm/gup.c
@@ -265,7 +265,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
  * get_user_pages_fast() - pin user pages in memory
  * @start:	starting user address
  * @nr_pages:	number of pages from start to pin
- * @write:	whether pages will be written to
+ * @gup_flags:	flags modifying pin behaviour
  * @pages:	array that receives pointers to the pages pinned.
  *		Should be at least nr_pages long.
  *
@@ -277,22 +277,22 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
  * requested. If nr_pages is 0 or negative, returns 0. If no pages
  * were pinned, returns -errno.
  */
-int get_user_pages_fast(unsigned long start, int nr_pages, int write,
-			struct page **pages)
+int get_user_pages_fast(unsigned long start, int nr_pages,
+			unsigned int gup_flags, struct page **pages)
 {
 	int nr, ret;
 
 	might_sleep();
 	start &= PAGE_MASK;
-	nr = __get_user_pages_fast(start, nr_pages, write, pages);
+	nr = __get_user_pages_fast(start, nr_pages, gup_flags & FOLL_WRITE,
+				   pages);
 	if (nr == nr_pages)
 		return nr;
 
 	/* Try to get the remaining pages with get_user_pages */
 	start += nr << PAGE_SHIFT;
 	pages += nr;
-	ret = get_user_pages_unlocked(start, nr_pages - nr, pages,
-				      write ? FOLL_WRITE : 0);
+	ret = get_user_pages_unlocked(start, nr_pages - nr, pages, gup_flags);
 	/* Have to be a bit careful with return values */
 	if (nr > 0)
 		ret = (ret < 0) ? nr : ret + nr;
diff --git a/arch/sh/mm/gup.c b/arch/sh/mm/gup.c
index 3e27f6d1f1ec..277c882f7489 100644
--- a/arch/sh/mm/gup.c
+++ b/arch/sh/mm/gup.c
@@ -204,7 +204,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
  * get_user_pages_fast() - pin user pages in memory
  * @start:	starting user address
  * @nr_pages:	number of pages from start to pin
- * @write:	whether pages will be written to
+ * @gup_flags:	flags modifying pin behaviour
  * @pages:	array that receives pointers to the pages pinned.
  *		Should be at least nr_pages long.
  *
@@ -216,8 +216,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
  * requested. If nr_pages is 0 or negative, returns 0. If no pages
  * were pinned, returns -errno.
  */
-int get_user_pages_fast(unsigned long start, int nr_pages, int write,
-			struct page **pages)
+int get_user_pages_fast(unsigned long start, int nr_pages,
+			unsigned int gup_flags, struct page **pages)
 {
 	struct mm_struct *mm = current->mm;
 	unsigned long addr, len, end;
@@ -241,7 +241,8 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 		next = pgd_addr_end(addr, end);
 		if (pgd_none(pgd))
 			goto slow;
-		if (!gup_pud_range(pgd, addr, next, write, pages, &nr))
+		if (!gup_pud_range(pgd, addr, next, gup_flags & FOLL_WRITE,
+				   pages, &nr))
 			goto slow;
 	} while (pgdp++, addr = next, addr != end);
 	local_irq_enable();
@@ -261,7 +262,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 
 		ret = get_user_pages_unlocked(start,
 			(end - start) >> PAGE_SHIFT, pages,
-			write ? FOLL_WRITE : 0);
+			gup_flags);
 
 		/* Have to be a bit careful with return values */
 		if (nr > 0) {
diff --git a/arch/sparc/mm/gup.c b/arch/sparc/mm/gup.c
index aee6dba83d0e..1e770a517d4a 100644
--- a/arch/sparc/mm/gup.c
+++ b/arch/sparc/mm/gup.c
@@ -245,8 +245,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	return nr;
 }
 
-int get_user_pages_fast(unsigned long start, int nr_pages, int write,
-			struct page **pages)
+int get_user_pages_fast(unsigned long start, int nr_pages,
+			unsigned int gup_flags, struct page **pages)
 {
 	struct mm_struct *mm = current->mm;
 	unsigned long addr, len, end;
@@ -303,7 +303,8 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 		next = pgd_addr_end(addr, end);
 		if (pgd_none(pgd))
 			goto slow;
-		if (!gup_pud_range(pgd, addr, next, write, pages, &nr))
+		if (!gup_pud_range(pgd, addr, next, gup_flags & FOLL_WRITE,
+				   pages, &nr))
 			goto slow;
 	} while (pgdp++, addr = next, addr != end);
 
@@ -324,7 +325,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 
 		ret = get_user_pages_unlocked(start,
 			(end - start) >> PAGE_SHIFT, pages,
-			write ? FOLL_WRITE : 0);
+			gup_flags);
 
 		/* Have to be a bit careful with return values */
 		if (nr > 0) {
diff --git a/arch/x86/kvm/paging_tmpl.h b/arch/x86/kvm/paging_tmpl.h
index 6bdca39829bc..08715034e315 100644
--- a/arch/x86/kvm/paging_tmpl.h
+++ b/arch/x86/kvm/paging_tmpl.h
@@ -140,7 +140,7 @@ static int FNAME(cmpxchg_gpte)(struct kvm_vcpu *vcpu, struct kvm_mmu *mmu,
 	pt_element_t *table;
 	struct page *page;
 
-	npages = get_user_pages_fast((unsigned long)ptep_user, 1, 1, &page);
+	npages = get_user_pages_fast((unsigned long)ptep_user, 1, FOLL_WRITE, &page);
 	/* Check if the user is doing something meaningless. */
 	if (unlikely(npages != 1))
 		return -EFAULT;
diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
index b5b128a0a051..9d8c8d108d55 100644
--- a/arch/x86/kvm/svm.c
+++ b/arch/x86/kvm/svm.c
@@ -1804,7 +1804,7 @@ static struct page **sev_pin_memory(struct kvm *kvm, unsigned long uaddr,
 		return NULL;
 
 	/* Pin the user virtual address. */
-	npinned = get_user_pages_fast(uaddr, npages, write ? FOLL_WRITE : 0, pages);
+	npinned = get_user_pages_fast(uaddr, npages, FOLL_WRITE, pages);
 	if (npinned != npages) {
 		pr_err("SEV: Failure locking %lu pages.\n", npages);
 		goto err;
diff --git a/drivers/fpga/dfl-afu-dma-region.c b/drivers/fpga/dfl-afu-dma-region.c
index e18a786fc943..c438722bf4e1 100644
--- a/drivers/fpga/dfl-afu-dma-region.c
+++ b/drivers/fpga/dfl-afu-dma-region.c
@@ -102,7 +102,7 @@ static int afu_dma_pin_pages(struct dfl_feature_platform_data *pdata,
 		goto unlock_vm;
 	}
 
-	pinned = get_user_pages_fast(region->user_addr, npages, 1,
+	pinned = get_user_pages_fast(region->user_addr, npages, FOLL_WRITE,
 				     region->pages);
 	if (pinned < 0) {
 		ret = pinned;
diff --git a/drivers/gpu/drm/via/via_dmablit.c b/drivers/gpu/drm/via/via_dmablit.c
index 8bf3a7c23ed3..062067438f1d 100644
--- a/drivers/gpu/drm/via/via_dmablit.c
+++ b/drivers/gpu/drm/via/via_dmablit.c
@@ -243,7 +243,8 @@ via_lock_all_dma_pages(drm_via_sg_info_t *vsg,  drm_via_dmablit_t *xfer)
 	if (NULL == vsg->pages)
 		return -ENOMEM;
 	ret = get_user_pages_fast((unsigned long)xfer->mem_addr,
-			vsg->num_pages, vsg->direction == DMA_FROM_DEVICE,
+			vsg->num_pages,
+			vsg->direction == DMA_FROM_DEVICE ? FOLL_WRITE : 0,
 			vsg->pages);
 	if (ret != vsg->num_pages) {
 		if (ret < 0)
diff --git a/drivers/infiniband/hw/hfi1/user_pages.c b/drivers/infiniband/hw/hfi1/user_pages.c
index 24b592c6522e..78ccacaf97d0 100644
--- a/drivers/infiniband/hw/hfi1/user_pages.c
+++ b/drivers/infiniband/hw/hfi1/user_pages.c
@@ -105,7 +105,8 @@ int hfi1_acquire_user_pages(struct mm_struct *mm, unsigned long vaddr, size_t np
 {
 	int ret;
 
-	ret = get_user_pages_fast(vaddr, npages, writable, pages);
+	ret = get_user_pages_fast(vaddr, npages, writable ? FOLL_WRITE : 0,
+				  pages);
 	if (ret < 0)
 		return ret;
 
diff --git a/drivers/misc/genwqe/card_utils.c b/drivers/misc/genwqe/card_utils.c
index 25265fd0fd6e..89cff9d1012b 100644
--- a/drivers/misc/genwqe/card_utils.c
+++ b/drivers/misc/genwqe/card_utils.c
@@ -603,7 +603,7 @@ int genwqe_user_vmap(struct genwqe_dev *cd, struct dma_mapping *m, void *uaddr,
 	/* pin user pages in memory */
 	rc = get_user_pages_fast(data & PAGE_MASK, /* page aligned addr */
 				 m->nr_pages,
-				 m->write,		/* readable/writable */
+				 m->write ? FOLL_WRITE : 0,	/* readable/writable */
 				 m->page_list);	/* ptrs to pages */
 	if (rc < 0)
 		goto fail_get_user_pages;
diff --git a/drivers/misc/vmw_vmci/vmci_host.c b/drivers/misc/vmw_vmci/vmci_host.c
index 997f92543dd4..422d08da3244 100644
--- a/drivers/misc/vmw_vmci/vmci_host.c
+++ b/drivers/misc/vmw_vmci/vmci_host.c
@@ -242,7 +242,7 @@ static int vmci_host_setup_notify(struct vmci_ctx *context,
 	/*
 	 * Lock physical page backing a given user VA.
 	 */
-	retval = get_user_pages_fast(uva, 1, 1, &context->notify_page);
+	retval = get_user_pages_fast(uva, 1, FOLL_WRITE, &context->notify_page);
 	if (retval != 1) {
 		context->notify_page = NULL;
 		return VMCI_ERROR_GENERIC;
diff --git a/drivers/misc/vmw_vmci/vmci_queue_pair.c b/drivers/misc/vmw_vmci/vmci_queue_pair.c
index f5f1aac9d163..1174735f003d 100644
--- a/drivers/misc/vmw_vmci/vmci_queue_pair.c
+++ b/drivers/misc/vmw_vmci/vmci_queue_pair.c
@@ -659,7 +659,8 @@ static int qp_host_get_user_memory(u64 produce_uva,
 	int err = VMCI_SUCCESS;
 
 	retval = get_user_pages_fast((uintptr_t) produce_uva,
-				     produce_q->kernel_if->num_pages, 1,
+				     produce_q->kernel_if->num_pages,
+				     FOLL_WRITE,
 				     produce_q->kernel_if->u.h.header_page);
 	if (retval < (int)produce_q->kernel_if->num_pages) {
 		pr_debug("get_user_pages_fast(produce) failed (retval=%d)",
@@ -671,7 +672,8 @@ static int qp_host_get_user_memory(u64 produce_uva,
 	}
 
 	retval = get_user_pages_fast((uintptr_t) consume_uva,
-				     consume_q->kernel_if->num_pages, 1,
+				     consume_q->kernel_if->num_pages,
+				     FOLL_WRITE,
 				     consume_q->kernel_if->u.h.header_page);
 	if (retval < (int)consume_q->kernel_if->num_pages) {
 		pr_debug("get_user_pages_fast(consume) failed (retval=%d)",
diff --git a/drivers/platform/goldfish/goldfish_pipe.c b/drivers/platform/goldfish/goldfish_pipe.c
index 321bc673c417..cef0133aa47a 100644
--- a/drivers/platform/goldfish/goldfish_pipe.c
+++ b/drivers/platform/goldfish/goldfish_pipe.c
@@ -274,7 +274,8 @@ static int pin_user_pages(unsigned long first_page,
 		*iter_last_page_size = last_page_size;
 	}
 
-	ret = get_user_pages_fast(first_page, requested_pages, !is_write,
+	ret = get_user_pages_fast(first_page, requested_pages,
+				  !is_write ? FOLL_WRITE : 0,
 				  pages);
 	if (ret <= 0)
 		return -EFAULT;
diff --git a/drivers/rapidio/devices/rio_mport_cdev.c b/drivers/rapidio/devices/rio_mport_cdev.c
index 1e1f42e210a0..4a4a75fa26d5 100644
--- a/drivers/rapidio/devices/rio_mport_cdev.c
+++ b/drivers/rapidio/devices/rio_mport_cdev.c
@@ -868,7 +868,9 @@ rio_dma_transfer(struct file *filp, u32 transfer_mode,
 
 		pinned = get_user_pages_fast(
 				(unsigned long)xfer->loc_addr & PAGE_MASK,
-				nr_pages, dir == DMA_FROM_DEVICE, page_list);
+				nr_pages,
+				dir == DMA_FROM_DEVICE ? FOLL_WRITE : 0,
+				page_list);
 
 		if (pinned != nr_pages) {
 			if (pinned < 0) {
diff --git a/drivers/sbus/char/oradax.c b/drivers/sbus/char/oradax.c
index 6516bc3cb58b..790aa148670d 100644
--- a/drivers/sbus/char/oradax.c
+++ b/drivers/sbus/char/oradax.c
@@ -437,7 +437,7 @@ static int dax_lock_page(void *va, struct page **p)
 
 	dax_dbg("uva %p", va);
 
-	ret = get_user_pages_fast((unsigned long)va, 1, 1, p);
+	ret = get_user_pages_fast((unsigned long)va, 1, FOLL_WRITE, p);
 	if (ret == 1) {
 		dax_dbg("locked page %p, for VA %p", *p, va);
 		return 0;
diff --git a/drivers/scsi/st.c b/drivers/scsi/st.c
index 19c022e66d63..3c6a18ad9a87 100644
--- a/drivers/scsi/st.c
+++ b/drivers/scsi/st.c
@@ -4922,7 +4922,8 @@ static int sgl_map_user_pages(struct st_buffer *STbp,
 
         /* Try to fault in all of the necessary pages */
         /* rw==READ means read from drive, write into memory area */
-	res = get_user_pages_fast(uaddr, nr_pages, rw == READ, pages);
+	res = get_user_pages_fast(uaddr, nr_pages, rw == READ ? FOLL_WRITE : 0,
+				  pages);
 
 	/* Errors and no page mapped should return here */
 	if (res < nr_pages)
diff --git a/drivers/staging/gasket/gasket_page_table.c b/drivers/staging/gasket/gasket_page_table.c
index 26755d9ca41d..f67fdf1d3817 100644
--- a/drivers/staging/gasket/gasket_page_table.c
+++ b/drivers/staging/gasket/gasket_page_table.c
@@ -486,8 +486,8 @@ static int gasket_perform_mapping(struct gasket_page_table *pg_tbl,
 			ptes[i].dma_addr = pg_tbl->coherent_pages[0].paddr +
 					   off + i * PAGE_SIZE;
 		} else {
-			ret = get_user_pages_fast(page_addr - offset, 1, 1,
-						  &page);
+			ret = get_user_pages_fast(page_addr - offset, 1,
+						  FOLL_WRITE, &page);
 
 			if (ret <= 0) {
 				dev_err(pg_tbl->device,
diff --git a/drivers/tee/tee_shm.c b/drivers/tee/tee_shm.c
index 0b9ab1d0dd45..49fd7312e2aa 100644
--- a/drivers/tee/tee_shm.c
+++ b/drivers/tee/tee_shm.c
@@ -273,7 +273,7 @@ struct tee_shm *tee_shm_register(struct tee_context *ctx, unsigned long addr,
 		goto err;
 	}
 
-	rc = get_user_pages_fast(start, num_pages, 1, shm->pages);
+	rc = get_user_pages_fast(start, num_pages, FOLL_WRITE, shm->pages);
 	if (rc > 0)
 		shm->num_pages = rc;
 	if (rc != num_pages) {
diff --git a/drivers/vfio/vfio_iommu_spapr_tce.c b/drivers/vfio/vfio_iommu_spapr_tce.c
index 8dbb270998f4..089c59c50d97 100644
--- a/drivers/vfio/vfio_iommu_spapr_tce.c
+++ b/drivers/vfio/vfio_iommu_spapr_tce.c
@@ -532,7 +532,8 @@ static int tce_iommu_use_page(unsigned long tce, unsigned long *hpa)
 	enum dma_data_direction direction = iommu_tce_direction(tce);
 
 	if (get_user_pages_fast(tce & PAGE_MASK, 1,
-			direction != DMA_TO_DEVICE, &page) != 1)
+			direction != DMA_TO_DEVICE ? FOLL_WRITE : 0,
+			&page) != 1)
 		return -EFAULT;
 
 	*hpa = __pa((unsigned long) page_address(page));
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index a2e5dc7716e2..2da5969bccb9 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1700,7 +1700,7 @@ static int set_bit_to_user(int nr, void __user *addr)
 	int bit = nr + (log % PAGE_SIZE) * 8;
 	int r;
 
-	r = get_user_pages_fast(log, 1, 1, &page);
+	r = get_user_pages_fast(log, 1, FOLL_WRITE, &page);
 	if (r < 0)
 		return r;
 	BUG_ON(r != 1);
diff --git a/drivers/video/fbdev/pvr2fb.c b/drivers/video/fbdev/pvr2fb.c
index 8a53d1de611d..41390c8e0f67 100644
--- a/drivers/video/fbdev/pvr2fb.c
+++ b/drivers/video/fbdev/pvr2fb.c
@@ -686,7 +686,7 @@ static ssize_t pvr2fb_write(struct fb_info *info, const char *buf,
 	if (!pages)
 		return -ENOMEM;
 
-	ret = get_user_pages_fast((unsigned long)buf, nr_pages, true, pages);
+	ret = get_user_pages_fast((unsigned long)buf, nr_pages, FOLL_WRITE, pages);
 	if (ret < nr_pages) {
 		nr_pages = ret;
 		ret = -EINVAL;
diff --git a/drivers/virt/fsl_hypervisor.c b/drivers/virt/fsl_hypervisor.c
index 8ba726e600e9..6446bcab4185 100644
--- a/drivers/virt/fsl_hypervisor.c
+++ b/drivers/virt/fsl_hypervisor.c
@@ -244,7 +244,7 @@ static long ioctl_memcpy(struct fsl_hv_ioctl_memcpy __user *p)
 
 	/* Get the physical addresses of the source buffer */
 	num_pinned = get_user_pages_fast(param.local_vaddr - lb_offset,
-		num_pages, param.source != -1, pages);
+		num_pages, param.source != -1 ? FOLL_WRITE : 0, pages);
 
 	if (num_pinned != num_pages) {
 		/* get_user_pages() failed */
diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index 7cf9c51318aa..02bc815982d4 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -852,7 +852,7 @@ static int gntdev_get_page(struct gntdev_copy_batch *batch, void __user *virt,
 	unsigned long xen_pfn;
 	int ret;
 
-	ret = get_user_pages_fast(addr, 1, writeable, &page);
+	ret = get_user_pages_fast(addr, 1, writeable ? FOLL_WRITE : 0, &page);
 	if (ret < 0)
 		return ret;
 
diff --git a/fs/orangefs/orangefs-bufmap.c b/fs/orangefs/orangefs-bufmap.c
index 443bcd8c3c19..5a7c4fda682f 100644
--- a/fs/orangefs/orangefs-bufmap.c
+++ b/fs/orangefs/orangefs-bufmap.c
@@ -269,7 +269,7 @@ orangefs_bufmap_map(struct orangefs_bufmap *bufmap,
 
 	/* map the pages */
 	ret = get_user_pages_fast((unsigned long)user_desc->ptr,
-			     bufmap->page_count, 1, bufmap->page_array);
+			     bufmap->page_count, FOLL_WRITE, bufmap->page_array);
 
 	if (ret < 0)
 		return ret;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 896d53587d0d..afdd0dcfc207 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1531,8 +1531,8 @@ long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
 long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
 		    struct page **pages, unsigned int gup_flags);
 
-int get_user_pages_fast(unsigned long start, int nr_pages, int write,
-			struct page **pages);
+int get_user_pages_fast(unsigned long start, int nr_pages,
+			unsigned int gup_flags, struct page **pages);
 
 /* Container for pinned pfns / pages */
 struct frame_vector {
diff --git a/kernel/futex.c b/kernel/futex.c
index c3b73b0311bc..1b9eca04fb0a 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -543,7 +543,7 @@ get_futex_key(u32 __user *uaddr, int fshared, union futex_key *key, enum futex_a
 	if (unlikely(should_fail_futex(fshared)))
 		return -EFAULT;
 
-	err = get_user_pages_fast(address, 1, 1, &page);
+	err = get_user_pages_fast(address, 1, FOLL_WRITE, &page);
 	/*
 	 * If write access is not required (eg. FUTEX_WAIT), try
 	 * and get read-only access.
diff --git a/lib/iov_iter.c b/lib/iov_iter.c
index ea36dc355da1..50e77ec427d0 100644
--- a/lib/iov_iter.c
+++ b/lib/iov_iter.c
@@ -1293,7 +1293,9 @@ ssize_t iov_iter_get_pages(struct iov_iter *i,
 			len = maxpages * PAGE_SIZE;
 		addr &= ~(PAGE_SIZE - 1);
 		n = DIV_ROUND_UP(len, PAGE_SIZE);
-		res = get_user_pages_fast(addr, n, iov_iter_rw(i) != WRITE, pages);
+		res = get_user_pages_fast(addr, n,
+				iov_iter_rw(i) != WRITE ?  FOLL_WRITE : 0,
+				pages);
 		if (unlikely(res < 0))
 			return res;
 		return (res == n ? len : res * PAGE_SIZE) - *start;
@@ -1374,7 +1376,8 @@ ssize_t iov_iter_get_pages_alloc(struct iov_iter *i,
 		p = get_pages_array(n);
 		if (!p)
 			return -ENOMEM;
-		res = get_user_pages_fast(addr, n, iov_iter_rw(i) != WRITE, p);
+		res = get_user_pages_fast(addr, n,
+				iov_iter_rw(i) != WRITE ?  FOLL_WRITE : 0, p);
 		if (unlikely(res < 0)) {
 			kvfree(p);
 			return res;
diff --git a/mm/gup.c b/mm/gup.c
index 6304317a308e..0fa7244d6f19 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -2038,7 +2038,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
  * get_user_pages_fast() - pin user pages in memory
  * @start:	starting user address
  * @nr_pages:	number of pages from start to pin
- * @write:	whether pages will be written to
+ * @gup_flags:	flags modifying pin behaviour
  * @pages:	array that receives pointers to the pages pinned.
  *		Should be at least nr_pages long.
  *
@@ -2050,8 +2050,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
  * requested. If nr_pages is 0 or negative, returns 0. If no pages
  * were pinned, returns -errno.
  */
-int get_user_pages_fast(unsigned long start, int nr_pages, int write,
-			struct page **pages)
+int get_user_pages_fast(unsigned long start, int nr_pages,
+			unsigned int gup_flags, struct page **pages)
 {
 	unsigned long addr, len, end;
 	int nr = 0, ret = 0;
@@ -2069,7 +2069,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 
 	if (gup_fast_permitted(start, nr_pages)) {
 		local_irq_disable();
-		gup_pgd_range(addr, end, write ? FOLL_WRITE : 0, pages, &nr);
+		gup_pgd_range(addr, end, gup_flags, pages, &nr);
 		local_irq_enable();
 		ret = nr;
 	}
@@ -2080,7 +2080,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 		pages += nr;
 
 		ret = get_user_pages_unlocked(start, nr_pages - nr, pages,
-				write ? FOLL_WRITE : 0);
+					      gup_flags);
 
 		/* Have to be a bit careful with return values */
 		if (nr > 0) {
diff --git a/mm/util.c b/mm/util.c
index d559bde497a9..f94a1ac09cd8 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -318,7 +318,7 @@ EXPORT_SYMBOL_GPL(__get_user_pages_fast);
  * get_user_pages_fast() - pin user pages in memory
  * @start:	starting user address
  * @nr_pages:	number of pages from start to pin
- * @write:	whether pages will be written to
+ * @gup_flags:	flags modifying pin behaviour
  * @pages:	array that receives pointers to the pages pinned.
  *		Should be at least nr_pages long.
  *
@@ -339,10 +339,10 @@ EXPORT_SYMBOL_GPL(__get_user_pages_fast);
  * were pinned, returns -errno.
  */
 int __weak get_user_pages_fast(unsigned long start,
-				int nr_pages, int write, struct page **pages)
+				int nr_pages, unsigned int gup_flags,
+				struct page **pages)
 {
-	return get_user_pages_unlocked(start, nr_pages, pages,
-				       write ? FOLL_WRITE : 0);
+	return get_user_pages_unlocked(start, nr_pages, pages, gup_flags);
 }
 EXPORT_SYMBOL_GPL(get_user_pages_fast);
 
diff --git a/net/ceph/pagevec.c b/net/ceph/pagevec.c
index d3736f5bffec..74cafc0142ea 100644
--- a/net/ceph/pagevec.c
+++ b/net/ceph/pagevec.c
@@ -27,7 +27,7 @@ struct page **ceph_get_direct_page_vector(const void __user *data,
 	while (got < num_pages) {
 		rc = get_user_pages_fast(
 		    (unsigned long)data + ((unsigned long)got * PAGE_SIZE),
-		    num_pages - got, write_page, pages + got);
+		    num_pages - got, write_page ? FOLL_WRITE : 0, pages + got);
 		if (rc < 0)
 			break;
 		BUG_ON(rc == 0);
diff --git a/net/rds/info.c b/net/rds/info.c
index e367a97a18c8..03f6fd56d237 100644
--- a/net/rds/info.c
+++ b/net/rds/info.c
@@ -193,7 +193,7 @@ int rds_info_getsockopt(struct socket *sock, int optname, char __user *optval,
 		ret = -ENOMEM;
 		goto out;
 	}
-	ret = get_user_pages_fast(start, nr_pages, 1, pages);
+	ret = get_user_pages_fast(start, nr_pages, FOLL_WRITE, pages);
 	if (ret != nr_pages) {
 		if (ret > 0)
 			nr_pages = ret;
diff --git a/net/rds/rdma.c b/net/rds/rdma.c
index 182ab8430594..b340ed4fc43a 100644
--- a/net/rds/rdma.c
+++ b/net/rds/rdma.c
@@ -158,7 +158,8 @@ static int rds_pin_pages(unsigned long user_addr, unsigned int nr_pages,
 {
 	int ret;
 
-	ret = get_user_pages_fast(user_addr, nr_pages, write, pages);
+	ret = get_user_pages_fast(user_addr, nr_pages, write ? FOLL_WRITE : 0,
+				  pages);
 
 	if (ret >= 0 && ret < nr_pages) {
 		while (ret--)
-- 
2.20.1

