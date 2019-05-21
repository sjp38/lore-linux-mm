Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F534C04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 04:53:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F077221783
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 04:53:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F077221783
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D556C6B0010; Tue, 21 May 2019 00:53:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D056B6B0266; Tue, 21 May 2019 00:53:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B7DC16B0269; Tue, 21 May 2019 00:53:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4686F6B0010
	for <linux-mm@kvack.org>; Tue, 21 May 2019 00:53:39 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n52so28826863edd.2
        for <linux-mm@kvack.org>; Mon, 20 May 2019 21:53:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=oQsC0aliXQsd7Ru4rFSVdN6bTIqeyTPYbrt7w+a23dc=;
        b=jrrD16YC9yngTbT9vbndo1AKhVKMUrvchBrmFdxBVIpw6+MsqvFdyazAufnoHM4bfl
         fCwBhxESCLkwgtEskod6pEPvoB2J8jX3m09LEWvZy55qWb56XvEShBNir0JlNesLY6MW
         +uEZQK0FgjZyP9hxf1m33b9y5Ei5W0cSbp3jkxCdQRVjLn07KGHMx1Gx+bpMH+ypzMH/
         Z6fqkGeRhmBhmvn5Qv1kfk5wwNxZYC5iCtFaEGQw/oqBGrhq53Tc4ymLzp/OLuEzzGCn
         UiUj6iomhxJIZRcsTyk/NPnoMptnDrbteKewTtDURwROfaP8ngyKLiF0QzwH8/j9N4vp
         P15w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: APjAAAXaXIn56BghNM25aGBBRlWaY3LW1BobPUQcLSbsb+wK3v3V/Ul6
	eI+gAEWHMft06GLKlcAVlMZ0HmreLOIBdvoQSDcctMpbbAIkX5cjj2DFtJ27FcaEbOhIFGQfTcY
	RyyxcbpxLp0iOTzI8u/5ZfUvyXBRIn7h+6ML9glzVeDNgkMaHnYo2WyXHURB0/yo=
X-Received: by 2002:a50:9705:: with SMTP id c5mr81192101edb.258.1558414418689;
        Mon, 20 May 2019 21:53:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxbW25e4PcNbK06rYiIzC6FJe22IHAdOf9pIyq5cAgno2UpatDT09RKSSUSHAVcpn4bmu5V
X-Received: by 2002:a50:9705:: with SMTP id c5mr81191939edb.258.1558414415606;
        Mon, 20 May 2019 21:53:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558414415; cv=none;
        d=google.com; s=arc-20160816;
        b=LjKvdOJABK0datwRSnZDA5JPJGGk5vL58uCPggS2RtZDFX35g3YG8ScoM1euto0juB
         iERQnwWyo859S+Kzs+QYThQmfo2uNcJQepHmmRO4lllZucKpo15WhDi/jrS/riroUA1X
         8bIcbTXvLurZzsOmzN9qDuv+pvc7MA6OP/vKEf6/7jP5WrDsu10Twr6GvtHlbPH2ywwZ
         aGXYo3nPtXgtoo47WMzKrfKbsbHVQrAdfqQHwANxasqCcwWn8HGZ5dyqbQdPHmx3P+4A
         amSjeiIcy0kpGTWVzqy4GHyasxSOAbLu0Xg0QQ4Xqdul7VnzU58k1dGOaz7cxg3/+tT9
         LGuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=oQsC0aliXQsd7Ru4rFSVdN6bTIqeyTPYbrt7w+a23dc=;
        b=TwQ3eacRLHrnheuTaGh1NEynH3l9uJK1yi/2kke9pFevy3f7uDtEzW3e0KGlGfpsHj
         VDMELByKRWLU8JPalknN8zO7f49ewnsdMYNDfFOfeLHlHqbYq0AAdy/p2eyjMoir/kXB
         haqP+ecMD1QGvkBRoMrVdDuc1Z+m/La9Mtt5nDRKo2LcK+9SgxwvDe7S3vvdFxMqmdeT
         EGCDc1J54h9rdYb8RYSWOke0JPbmkqfvq0XWvH0oStf8RijVn6hGS6ez/EnzI2+r5isU
         p7gkxAkcl848c+wOFlPuNdjHHlX6jfWfLdVsWZgUNwTLu3oyuviZ9uFyw+KtvjcWpb6E
         RC4w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id z54si863576edc.429.2019.05.20.21.53.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 21:53:35 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Tue, 21 May 2019 06:53:34 +0200
Received: from linux-r8p5.suse.de (nwb-a10-snat.microfocus.com [10.120.13.201])
	by emea4-mta.ukb.novell.com with ESMTP (TLS encrypted); Tue, 21 May 2019 05:53:04 +0100
From: Davidlohr Bueso <dave@stgolabs.net>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org,
	willy@infradead.org,
	mhocko@kernel.org,
	mgorman@techsingularity.net,
	jglisse@redhat.com,
	ldufour@linux.vnet.ibm.com,
	dave@stgolabs.net,
	Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 04/14] mm: teach pagefault paths about range locking
Date: Mon, 20 May 2019 21:52:32 -0700
Message-Id: <20190521045242.24378-5-dave@stgolabs.net>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190521045242.24378-1-dave@stgolabs.net>
References: <20190521045242.24378-1-dave@stgolabs.net>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When handling a page fault, it happens that the mmap_sem is released
during the processing. As moving to range lock requires remembering
the range parameter to do the lock/unlock, this patch adds a pointer
to struct vm_fault. As such, we work outwards from arming the vmf from:

  handle_mm_fault(), __collapse_huge_page_swapin() and hugetlb_no_page()

The idea is to use a local, stack allocated variable (no concurrency)
whenever the mmap_sem is originally taken and we end up in pf paths that
end up retaking the lock. Ie:

  DEFINE_RANGE_LOCK_FULL(mmrange);

  down_write(&mm->mmap_sem);
  some_fn(a, b, c, &mmrange);
  ....
   ....
    ...
     handle_mm_fault(vma, addr, flags, mmrange);
    ...
  up_write(&mm->mmap_sem);

Consequentially we also end up updating lock_page_or_retry(), which can
drop the mmap_sem.

For the the gup family, we pass nil for scenarios when the semaphore will
remain untouched.

Semantically nothing changes at all, and the 'mmrange' ends up
being unused for now. Later patches will use the variable when
the mmap_sem wrappers replace straightforward down/up.

*** For simplicity, this patch breaks when used in ksm and hmm. ***

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 arch/x86/mm/fault.c                     | 27 ++++++++------
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c |  2 +-
 drivers/gpu/drm/i915/i915_gem_userptr.c |  2 +-
 drivers/infiniband/core/umem_odp.c      |  2 +-
 drivers/iommu/amd_iommu_v2.c            |  3 +-
 drivers/iommu/intel-svm.c               |  3 +-
 drivers/vfio/vfio_iommu_type1.c         |  2 +-
 fs/exec.c                               |  2 +-
 include/linux/hugetlb.h                 |  9 +++--
 include/linux/mm.h                      | 24 ++++++++----
 include/linux/pagemap.h                 |  6 +--
 kernel/events/uprobes.c                 |  7 ++--
 kernel/futex.c                          |  2 +-
 mm/filemap.c                            |  2 +-
 mm/frame_vector.c                       |  6 ++-
 mm/gup.c                                | 65 ++++++++++++++++++++-------------
 mm/hmm.c                                |  4 +-
 mm/hugetlb.c                            | 14 ++++---
 mm/internal.h                           |  3 +-
 mm/khugepaged.c                         | 24 +++++++-----
 mm/ksm.c                                |  3 +-
 mm/memory.c                             | 14 ++++---
 mm/mempolicy.c                          |  9 +++--
 mm/mmap.c                               |  4 +-
 mm/mprotect.c                           |  2 +-
 mm/process_vm_access.c                  |  4 +-
 security/tomoyo/domain.c                |  2 +-
 virt/kvm/async_pf.c                     |  3 +-
 virt/kvm/kvm_main.c                     |  9 +++--
 29 files changed, 159 insertions(+), 100 deletions(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 46df4c6aae46..fb869c292b91 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -938,7 +938,8 @@ bad_area_nosemaphore(struct pt_regs *regs, unsigned long error_code,
 
 static void
 __bad_area(struct pt_regs *regs, unsigned long error_code,
-	   unsigned long address, u32 pkey, int si_code)
+	   unsigned long address, u32 pkey, int si_code,
+	   struct range_lock *mmrange)
 {
 	struct mm_struct *mm = current->mm;
 	/*
@@ -951,9 +952,10 @@ __bad_area(struct pt_regs *regs, unsigned long error_code,
 }
 
 static noinline void
-bad_area(struct pt_regs *regs, unsigned long error_code, unsigned long address)
+bad_area(struct pt_regs *regs, unsigned long error_code, unsigned long address,
+	 struct range_lock *mmrange)
 {
-	__bad_area(regs, error_code, address, 0, SEGV_MAPERR);
+	__bad_area(regs, error_code, address, 0, SEGV_MAPERR, mmrange);
 }
 
 static inline bool bad_area_access_from_pkeys(unsigned long error_code,
@@ -975,7 +977,8 @@ static inline bool bad_area_access_from_pkeys(unsigned long error_code,
 
 static noinline void
 bad_area_access_error(struct pt_regs *regs, unsigned long error_code,
-		      unsigned long address, struct vm_area_struct *vma)
+		      unsigned long address, struct vm_area_struct *vma,
+		      struct range_lock *mmrange)
 {
 	/*
 	 * This OSPKE check is not strictly necessary at runtime.
@@ -1005,9 +1008,9 @@ bad_area_access_error(struct pt_regs *regs, unsigned long error_code,
 		 */
 		u32 pkey = vma_pkey(vma);
 
-		__bad_area(regs, error_code, address, pkey, SEGV_PKUERR);
+		__bad_area(regs, error_code, address, pkey, SEGV_PKUERR, mmrange);
 	} else {
-		__bad_area(regs, error_code, address, 0, SEGV_ACCERR);
+		__bad_area(regs, error_code, address, 0, SEGV_ACCERR, mmrange);
 	}
 }
 
@@ -1306,6 +1309,7 @@ void do_user_addr_fault(struct pt_regs *regs,
 	struct mm_struct *mm;
 	vm_fault_t fault, major = 0;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	tsk = current;
 	mm = tsk->mm;
@@ -1417,17 +1421,17 @@ void do_user_addr_fault(struct pt_regs *regs,
 
 	vma = find_vma(mm, address);
 	if (unlikely(!vma)) {
-		bad_area(regs, hw_error_code, address);
+		bad_area(regs, hw_error_code, address, &mmrange);
 		return;
 	}
 	if (likely(vma->vm_start <= address))
 		goto good_area;
 	if (unlikely(!(vma->vm_flags & VM_GROWSDOWN))) {
-		bad_area(regs, hw_error_code, address);
+		bad_area(regs, hw_error_code, address, &mmrange);
 		return;
 	}
 	if (unlikely(expand_stack(vma, address))) {
-		bad_area(regs, hw_error_code, address);
+		bad_area(regs, hw_error_code, address, &mmrange);
 		return;
 	}
 
@@ -1437,7 +1441,8 @@ void do_user_addr_fault(struct pt_regs *regs,
 	 */
 good_area:
 	if (unlikely(access_error(hw_error_code, vma))) {
-		bad_area_access_error(regs, hw_error_code, address, vma);
+		bad_area_access_error(regs, hw_error_code, address, vma,
+				      &mmrange);
 		return;
 	}
 
@@ -1454,7 +1459,7 @@ void do_user_addr_fault(struct pt_regs *regs,
 	 * userland). The return to userland is identified whenever
 	 * FAULT_FLAG_USER|FAULT_FLAG_KILLABLE are both set in flags.
 	 */
-	fault = handle_mm_fault(vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags, &mmrange);
 	major |= fault & VM_FAULT_MAJOR;
 
 	/*
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
index af1e218c6a74..d81101ac57eb 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
@@ -776,7 +776,7 @@ int amdgpu_ttm_tt_get_user_pages(struct ttm_tt *ttm, struct page **pages)
 		else
 			r = get_user_pages_remote(gtt->usertask,
 					mm, userptr, num_pages,
-					flags, p, NULL, NULL);
+					flags, p, NULL, NULL, NULL);
 
 		spin_lock(&gtt->guptasklock);
 		list_del(&guptask.list);
diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
index 8079ea3af103..67f718015e42 100644
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
@@ -511,7 +511,7 @@ __i915_gem_userptr_get_pages_worker(struct work_struct *_work)
 					 obj->userptr.ptr + pinned * PAGE_SIZE,
 					 npages - pinned,
 					 flags,
-					 pvec + pinned, NULL, NULL);
+					 pvec + pinned, NULL, NULL, NULL);
 				if (ret < 0)
 					break;
 
diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
index f962b5bbfa40..62b5de027dd1 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -639,7 +639,7 @@ int ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem_odp, u64 user_virt,
 		 */
 		npages = get_user_pages_remote(owning_process, owning_mm,
 				user_virt, gup_num_pages,
-				flags, local_page_list, NULL, NULL);
+			        flags, local_page_list, NULL, NULL, NULL);
 		up_read(&owning_mm->mmap_sem);
 
 		if (npages < 0) {
diff --git a/drivers/iommu/amd_iommu_v2.c b/drivers/iommu/amd_iommu_v2.c
index 5d7ef750e4a0..67c609b26249 100644
--- a/drivers/iommu/amd_iommu_v2.c
+++ b/drivers/iommu/amd_iommu_v2.c
@@ -489,6 +489,7 @@ static void do_fault(struct work_struct *work)
 	unsigned int flags = 0;
 	struct mm_struct *mm;
 	u64 address;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	mm = fault->state->mm;
 	address = fault->address;
@@ -509,7 +510,7 @@ static void do_fault(struct work_struct *work)
 	if (access_error(vma, fault))
 		goto out;
 
-	ret = handle_mm_fault(vma, address, flags);
+	ret = handle_mm_fault(vma, address, flags, &mmrange);
 out:
 	up_read(&mm->mmap_sem);
 
diff --git a/drivers/iommu/intel-svm.c b/drivers/iommu/intel-svm.c
index 8f87304f915c..74d535ea6a03 100644
--- a/drivers/iommu/intel-svm.c
+++ b/drivers/iommu/intel-svm.c
@@ -551,6 +551,7 @@ static irqreturn_t prq_event_thread(int irq, void *d)
 		int result;
 		vm_fault_t ret;
 		u64 address;
+		DEFINE_RANGE_LOCK_FULL(mmrange);
 
 		handled = 1;
 
@@ -603,7 +604,7 @@ static irqreturn_t prq_event_thread(int irq, void *d)
 			goto invalid;
 
 		ret = handle_mm_fault(vma, address,
-				      req->wr_req ? FAULT_FLAG_WRITE : 0);
+				      req->wr_req ? FAULT_FLAG_WRITE : 0, &mmrange);
 		if (ret & VM_FAULT_ERROR)
 			goto invalid;
 
diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
index 0237ace12998..b5f911222ae6 100644
--- a/drivers/vfio/vfio_iommu_type1.c
+++ b/drivers/vfio/vfio_iommu_type1.c
@@ -354,7 +354,7 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
 				     vmas);
 	} else {
 		ret = get_user_pages_remote(NULL, mm, vaddr, 1, flags, page,
-					    vmas, NULL);
+					    vmas, NULL, NULL);
 		/*
 		 * The lifetime of a vaddr_get_pfn() page pin is
 		 * userspace-controlled. In the fs-dax case this could
diff --git a/fs/exec.c b/fs/exec.c
index d88584ebf07f..e96fd5328739 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -214,7 +214,7 @@ static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
 	 * doing the exec and bprm->mm is the new process's mm.
 	 */
 	ret = get_user_pages_remote(current, bprm->mm, pos, 1, gup_flags,
-			&page, NULL, NULL);
+				    &page, NULL, NULL, NULL);
 	if (ret <= 0)
 		return NULL;
 
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index edf476c8cfb9..67aba05ff78b 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -91,7 +91,7 @@ int copy_hugetlb_page_range(struct mm_struct *, struct mm_struct *, struct vm_ar
 long follow_hugetlb_page(struct mm_struct *, struct vm_area_struct *,
 			 struct page **, struct vm_area_struct **,
 			 unsigned long *, unsigned long *, long, unsigned int,
-			 int *);
+			 int *, struct range_lock *);
 void unmap_hugepage_range(struct vm_area_struct *,
 			  unsigned long, unsigned long, struct page *);
 void __unmap_hugepage_range_final(struct mmu_gather *tlb,
@@ -106,7 +106,8 @@ int hugetlb_report_node_meminfo(int, char *);
 void hugetlb_show_meminfo(void);
 unsigned long hugetlb_total_pages(void);
 vm_fault_t hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-			unsigned long address, unsigned int flags);
+			 unsigned long address, unsigned int flags,
+			 struct range_lock *mmrange);
 int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm, pte_t *dst_pte,
 				struct vm_area_struct *dst_vma,
 				unsigned long dst_addr,
@@ -182,7 +183,7 @@ static inline void adjust_range_if_pmd_sharing_possible(
 {
 }
 
-#define follow_hugetlb_page(m,v,p,vs,a,b,i,w,n)	({ BUG(); 0; })
+#define follow_hugetlb_page(m,v,p,vs,a,b,i,w,n,r)	({ BUG(); 0; })
 #define follow_huge_addr(mm, addr, write)	ERR_PTR(-EINVAL)
 #define copy_hugetlb_page_range(src, dst, vma)	({ BUG(); 0; })
 static inline void hugetlb_report_meminfo(struct seq_file *m)
@@ -233,7 +234,7 @@ static inline void __unmap_hugepage_range(struct mmu_gather *tlb,
 }
 static inline vm_fault_t hugetlb_fault(struct mm_struct *mm,
 				struct vm_area_struct *vma, unsigned long address,
-				unsigned int flags)
+				unsigned int flags, struct range_lock *mmrange)
 {
 	BUG();
 	return 0;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 780b6097ee47..044e428b1905 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -440,6 +440,10 @@ struct vm_fault {
 					 * page table to avoid allocation from
 					 * atomic context.
 					 */
+	struct range_lock *lockrange;    /* Range lock interval in use for when
+					  * the mm lock is manipulated throughout
+					  * its lifespan.
+					  */
 };
 
 /* page entry size for vm->huge_fault() */
@@ -1507,25 +1511,29 @@ int invalidate_inode_page(struct page *page);
 
 #ifdef CONFIG_MMU
 extern vm_fault_t handle_mm_fault(struct vm_area_struct *vma,
-			unsigned long address, unsigned int flags);
+				  unsigned long address, unsigned int flags,
+				  struct range_lock *mmrange);
 extern int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 			    unsigned long address, unsigned int fault_flags,
-			    bool *unlocked);
+			    bool *unlocked, struct range_lock *mmrange);
 void unmap_mapping_pages(struct address_space *mapping,
 		pgoff_t start, pgoff_t nr, bool even_cows);
 void unmap_mapping_range(struct address_space *mapping,
 		loff_t const holebegin, loff_t const holelen, int even_cows);
 #else
 static inline vm_fault_t handle_mm_fault(struct vm_area_struct *vma,
-		unsigned long address, unsigned int flags)
+					 unsigned long address,
+					 unsigned int flags,
+					 struct range_lock *mmrange)
 {
 	/* should never happen if there's no MMU */
 	BUG();
 	return VM_FAULT_SIGBUS;
 }
 static inline int fixup_user_fault(struct task_struct *tsk,
-		struct mm_struct *mm, unsigned long address,
-		unsigned int fault_flags, bool *unlocked)
+				   struct mm_struct *mm, unsigned long address,
+				   unsigned int fault_flags, bool *unlocked,
+				   struct range_lock *mmrange)
 {
 	/* should never happen if there's no MMU */
 	BUG();
@@ -1553,12 +1561,14 @@ extern int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 long get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
 			    unsigned long start, unsigned long nr_pages,
 			    unsigned int gup_flags, struct page **pages,
-			    struct vm_area_struct **vmas, int *locked);
+			    struct vm_area_struct **vmas, int *locked,
+			    struct range_lock *mmrange);
 long get_user_pages(unsigned long start, unsigned long nr_pages,
 			    unsigned int gup_flags, struct page **pages,
 			    struct vm_area_struct **vmas);
 long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
-		    unsigned int gup_flags, struct page **pages, int *locked);
+			   unsigned int gup_flags, struct page **pages, int *locked,
+			   struct range_lock *mmrange);
 long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
 		    struct page **pages, unsigned int gup_flags);
 
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 9ec3544baee2..15eb4765827f 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -462,7 +462,7 @@ static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
 extern void __lock_page(struct page *page);
 extern int __lock_page_killable(struct page *page);
 extern int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
-				unsigned int flags);
+				unsigned int flags, struct range_lock *mmrange);
 extern void unlock_page(struct page *page);
 
 static inline int trylock_page(struct page *page)
@@ -502,10 +502,10 @@ static inline int lock_page_killable(struct page *page)
  * __lock_page_or_retry().
  */
 static inline int lock_page_or_retry(struct page *page, struct mm_struct *mm,
-				     unsigned int flags)
+				     unsigned int flags, struct range_lock *mmrange)
 {
 	might_sleep();
-	return trylock_page(page) || __lock_page_or_retry(page, mm, flags);
+	return trylock_page(page) || __lock_page_or_retry(page, mm, flags, mmrange);
 }
 
 /*
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 78f61bfc6b79..3689eceb8d0c 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -374,7 +374,7 @@ __update_ref_ctr(struct mm_struct *mm, unsigned long vaddr, short d)
 		return -EINVAL;
 
 	ret = get_user_pages_remote(NULL, mm, vaddr, 1,
-			FOLL_WRITE, &page, &vma, NULL);
+				    FOLL_WRITE, &page, &vma, NULL, NULL);
 	if (unlikely(ret <= 0)) {
 		/*
 		 * We are asking for 1 page. If get_user_pages_remote() fails,
@@ -471,7 +471,8 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 retry:
 	/* Read the page with vaddr into memory */
 	ret = get_user_pages_remote(NULL, mm, vaddr, 1,
-			FOLL_FORCE | FOLL_SPLIT, &old_page, &vma, NULL);
+				    FOLL_FORCE | FOLL_SPLIT, &old_page,
+				    &vma, NULL, NULL);
 	if (ret <= 0)
 		return ret;
 
@@ -1976,7 +1977,7 @@ static int is_trap_at_addr(struct mm_struct *mm, unsigned long vaddr)
 	 * essentially a kernel access to the memory.
 	 */
 	result = get_user_pages_remote(NULL, mm, vaddr, 1, FOLL_FORCE, &page,
-			NULL, NULL);
+				       NULL, NULL, NULL);
 	if (result < 0)
 		return result;
 
diff --git a/kernel/futex.c b/kernel/futex.c
index 2268b97d5439..4615f9371a6f 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -733,7 +733,7 @@ static int fault_in_user_writeable(u32 __user *uaddr)
 
 	down_read(&mm->mmap_sem);
 	ret = fixup_user_fault(current, mm, (unsigned long)uaddr,
-			       FAULT_FLAG_WRITE, NULL);
+			       FAULT_FLAG_WRITE, NULL, NULL);
 	up_read(&mm->mmap_sem);
 
 	return ret < 0 ? ret : 0;
diff --git a/mm/filemap.c b/mm/filemap.c
index c5af80c43d36..959022841bab 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1378,7 +1378,7 @@ EXPORT_SYMBOL_GPL(__lock_page_killable);
  * with the page locked and the mmap_sem unperturbed.
  */
 int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
-			 unsigned int flags)
+			 unsigned int flags, struct range_lock *mmrange)
 {
 	if (flags & FAULT_FLAG_ALLOW_RETRY) {
 		/*
diff --git a/mm/frame_vector.c b/mm/frame_vector.c
index c64dca6e27c2..4e1a577cbb79 100644
--- a/mm/frame_vector.c
+++ b/mm/frame_vector.c
@@ -39,6 +39,7 @@ int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
 	int ret = 0;
 	int err;
 	int locked;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (nr_frames == 0)
 		return 0;
@@ -70,8 +71,9 @@ int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
 	if (!(vma->vm_flags & (VM_IO | VM_PFNMAP))) {
 		vec->got_ref = true;
 		vec->is_pfns = false;
-		ret = get_user_pages_locked(start, nr_frames,
-			gup_flags, (struct page **)(vec->ptrs), &locked);
+		ret = get_user_pages_locked(start, nr_frames, gup_flags,
+					    (struct page **)(vec->ptrs),
+					    &locked, &mmrange);
 		goto out;
 	}
 
diff --git a/mm/gup.c b/mm/gup.c
index 2c08248d4fa2..cf8fa037ce27 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -629,7 +629,8 @@ static int get_gate_page(struct mm_struct *mm, unsigned long address,
  * If it is, *@nonblocking will be set to 0 and -EBUSY returned.
  */
 static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
-		unsigned long address, unsigned int *flags, int *nonblocking)
+			unsigned long address, unsigned int *flags,
+			int *nonblocking, struct range_lock *mmrange)
 {
 	unsigned int fault_flags = 0;
 	vm_fault_t ret;
@@ -650,7 +651,7 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 		fault_flags |= FAULT_FLAG_TRIED;
 	}
 
-	ret = handle_mm_fault(vma, address, fault_flags);
+	ret = handle_mm_fault(vma, address, fault_flags, mmrange);
 	if (ret & VM_FAULT_ERROR) {
 		int err = vm_fault_to_errno(ret, *flags);
 
@@ -746,6 +747,7 @@ static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
  * @vmas:	array of pointers to vmas corresponding to each page.
  *		Or NULL if the caller does not require them.
  * @nonblocking: whether waiting for disk IO or mmap_sem contention
+ * @mmrange:	mm address space range locking
  *
  * Returns number of pages pinned. This may be fewer than the number
  * requested. If nr_pages is 0 or negative, returns 0. If no pages
@@ -792,7 +794,8 @@ static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
 static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned long start, unsigned long nr_pages,
 		unsigned int gup_flags, struct page **pages,
-		struct vm_area_struct **vmas, int *nonblocking)
+		struct vm_area_struct **vmas, int *nonblocking,
+		struct range_lock *mmrange)
 {
 	long ret = 0, i = 0;
 	struct vm_area_struct *vma = NULL;
@@ -835,8 +838,9 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 			}
 			if (is_vm_hugetlb_page(vma)) {
 				i = follow_hugetlb_page(mm, vma, pages, vmas,
-						&start, &nr_pages, i,
-						gup_flags, nonblocking);
+							&start, &nr_pages, i,
+							gup_flags,
+							nonblocking, mmrange);
 				continue;
 			}
 		}
@@ -854,7 +858,7 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		page = follow_page_mask(vma, start, foll_flags, &ctx);
 		if (!page) {
 			ret = faultin_page(tsk, vma, start, &foll_flags,
-					nonblocking);
+					   nonblocking, mmrange);
 			switch (ret) {
 			case 0:
 				goto retry;
@@ -935,6 +939,7 @@ static bool vma_permits_fault(struct vm_area_struct *vma,
  * @fault_flags:flags to pass down to handle_mm_fault()
  * @unlocked:	did we unlock the mmap_sem while retrying, maybe NULL if caller
  *		does not allow retry
+ * @mmrange:	mm address space range locking
  *
  * This is meant to be called in the specific scenario where for locking reasons
  * we try to access user memory in atomic context (within a pagefault_disable()
@@ -958,7 +963,7 @@ static bool vma_permits_fault(struct vm_area_struct *vma,
  */
 int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 		     unsigned long address, unsigned int fault_flags,
-		     bool *unlocked)
+		     bool *unlocked, struct range_lock *mmrange)
 {
 	struct vm_area_struct *vma;
 	vm_fault_t ret, major = 0;
@@ -974,7 +979,7 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 	if (!vma_permits_fault(vma, fault_flags))
 		return -EFAULT;
 
-	ret = handle_mm_fault(vma, address, fault_flags);
+	ret = handle_mm_fault(vma, address, fault_flags, mmrange);
 	major |= ret & VM_FAULT_MAJOR;
 	if (ret & VM_FAULT_ERROR) {
 		int err = vm_fault_to_errno(ret, 0);
@@ -1011,7 +1016,8 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 						struct page **pages,
 						struct vm_area_struct **vmas,
 						int *locked,
-						unsigned int flags)
+						unsigned int flags,
+						struct range_lock *mmrange)
 {
 	long ret, pages_done;
 	bool lock_dropped;
@@ -1030,7 +1036,7 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 	lock_dropped = false;
 	for (;;) {
 		ret = __get_user_pages(tsk, mm, start, nr_pages, flags, pages,
-				       vmas, locked);
+				       vmas, locked, mmrange);
 		if (!locked)
 			/* VM_FAULT_RETRY couldn't trigger, bypass */
 			return ret;
@@ -1073,7 +1079,7 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 		lock_dropped = true;
 		down_read(&mm->mmap_sem);
 		ret = __get_user_pages(tsk, mm, start, 1, flags | FOLL_TRIED,
-				       pages, NULL, NULL);
+				       pages, NULL, NULL, NULL);
 		if (ret != 1) {
 			BUG_ON(ret > 1);
 			if (!pages_done)
@@ -1121,7 +1127,7 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
  */
 long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
 			   unsigned int gup_flags, struct page **pages,
-			   int *locked)
+			   int *locked, struct range_lock *mmrange)
 {
 	/*
 	 * FIXME: Current FOLL_LONGTERM behavior is incompatible with
@@ -1134,7 +1140,7 @@ long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
 
 	return __get_user_pages_locked(current, current->mm, start, nr_pages,
 				       pages, NULL, locked,
-				       gup_flags | FOLL_TOUCH);
+				       gup_flags | FOLL_TOUCH, mmrange);
 }
 EXPORT_SYMBOL(get_user_pages_locked);
 
@@ -1159,6 +1165,7 @@ long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
 	struct mm_struct *mm = current->mm;
 	int locked = 1;
 	long ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/*
 	 * FIXME: Current FOLL_LONGTERM behavior is incompatible with
@@ -1171,7 +1178,7 @@ long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
 
 	down_read(&mm->mmap_sem);
 	ret = __get_user_pages_locked(current, mm, start, nr_pages, pages, NULL,
-				      &locked, gup_flags | FOLL_TOUCH);
+				      &locked, gup_flags | FOLL_TOUCH, &mmrange);
 	if (locked)
 		up_read(&mm->mmap_sem);
 	return ret;
@@ -1194,6 +1201,7 @@ EXPORT_SYMBOL(get_user_pages_unlocked);
  * @locked:	pointer to lock flag indicating whether lock is held and
  *		subsequently whether VM_FAULT_RETRY functionality can be
  *		utilised. Lock must initially be held.
+ * @mmrange:    mm address space range locking
  *
  * Returns number of pages pinned. This may be fewer than the number
  * requested. If nr_pages is 0 or negative, returns 0. If no pages
@@ -1237,7 +1245,8 @@ EXPORT_SYMBOL(get_user_pages_unlocked);
 long get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned long start, unsigned long nr_pages,
 		unsigned int gup_flags, struct page **pages,
-		struct vm_area_struct **vmas, int *locked)
+		struct vm_area_struct **vmas, int *locked,
+		struct range_lock *mmrange)
 {
 	/*
 	 * FIXME: Current FOLL_LONGTERM behavior is incompatible with
@@ -1250,7 +1259,8 @@ long get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
 
 	return __get_user_pages_locked(tsk, mm, start, nr_pages, pages, vmas,
 				       locked,
-				       gup_flags | FOLL_TOUCH | FOLL_REMOTE);
+				       gup_flags | FOLL_TOUCH | FOLL_REMOTE,
+				       mmrange);
 }
 EXPORT_SYMBOL(get_user_pages_remote);
 
@@ -1394,7 +1404,7 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
 		 */
 		nr_pages = __get_user_pages_locked(tsk, mm, start, nr_pages,
 						   pages, vmas, NULL,
-						   gup_flags);
+						   gup_flags, NULL);
 
 		if ((nr_pages > 0) && migrate_allow) {
 			drain_allow = true;
@@ -1448,7 +1458,7 @@ static long __gup_longterm_locked(struct task_struct *tsk,
 	}
 
 	rc = __get_user_pages_locked(tsk, mm, start, nr_pages, pages,
-				     vmas_tmp, NULL, gup_flags);
+				     vmas_tmp, NULL, gup_flags, NULL);
 
 	if (gup_flags & FOLL_LONGTERM) {
 		memalloc_nocma_restore(flags);
@@ -1481,7 +1491,7 @@ static __always_inline long __gup_longterm_locked(struct task_struct *tsk,
 						  unsigned int flags)
 {
 	return __get_user_pages_locked(tsk, mm, start, nr_pages, pages, vmas,
-				       NULL, flags);
+				       NULL, flags, NULL);
 }
 #endif /* CONFIG_FS_DAX || CONFIG_CMA */
 
@@ -1506,7 +1516,8 @@ EXPORT_SYMBOL(get_user_pages);
  * @vma:   target vma
  * @start: start address
  * @end:   end address
- * @nonblocking:
+ * @nonblocking: whether waiting for disk IO or mmap_sem contention
+ * @mmrange: mm address space range locking
  *
  * This takes care of mlocking the pages too if VM_LOCKED is set.
  *
@@ -1515,14 +1526,15 @@ EXPORT_SYMBOL(get_user_pages);
  * vma->vm_mm->mmap_sem must be held.
  *
  * If @nonblocking is NULL, it may be held for read or write and will
- * be unperturbed.
+ * be unperturbed, and hence @mmrange will be unnecessary.
  *
  * If @nonblocking is non-NULL, it must held for read only and may be
  * released.  If it's released, *@nonblocking will be set to 0.
  */
 long populate_vma_page_range(struct vm_area_struct *vma,
-		unsigned long start, unsigned long end, int *nonblocking)
-{
+		unsigned long start, unsigned long end, int *nonblocking,
+		struct range_lock *mmrange)
+			     {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long nr_pages = (end - start) / PAGE_SIZE;
 	int gup_flags;
@@ -1556,7 +1568,7 @@ long populate_vma_page_range(struct vm_area_struct *vma,
 	 * not result in a stack expansion that recurses back here.
 	 */
 	return __get_user_pages(current, mm, start, nr_pages, gup_flags,
-				NULL, NULL, nonblocking);
+				NULL, NULL, nonblocking, mmrange);
 }
 
 /*
@@ -1573,6 +1585,7 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
 	struct vm_area_struct *vma = NULL;
 	int locked = 0;
 	long ret = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	end = start + len;
 
@@ -1603,7 +1616,7 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
 		 * double checks the vma flags, so that it won't mlock pages
 		 * if the vma was already munlocked.
 		 */
-		ret = populate_vma_page_range(vma, nstart, nend, &locked);
+		ret = populate_vma_page_range(vma, nstart, nend, &locked, &mmrange);
 		if (ret < 0) {
 			if (ignore_errors) {
 				ret = 0;
@@ -1641,7 +1654,7 @@ struct page *get_dump_page(unsigned long addr)
 
 	if (__get_user_pages(current, current->mm, addr, 1,
 			     FOLL_FORCE | FOLL_DUMP | FOLL_GET, &page, &vma,
-			     NULL) < 1)
+			     NULL, NULL) < 1)
 		return NULL;
 	flush_cache_page(vma, addr, page_to_pfn(page));
 	return page;
diff --git a/mm/hmm.c b/mm/hmm.c
index 0db8491090b8..723109ac6bdc 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -347,7 +347,9 @@ static int hmm_vma_do_fault(struct mm_walk *walk, unsigned long addr,
 
 	flags |= hmm_vma_walk->block ? 0 : FAULT_FLAG_ALLOW_RETRY;
 	flags |= write_fault ? FAULT_FLAG_WRITE : 0;
-	ret = handle_mm_fault(vma, addr, flags);
+
+	/*** BROKEN mmrange, we don't care about hmm (for now) */
+	ret = handle_mm_fault(vma, addr, flags, NULL);
 	if (ret & VM_FAULT_RETRY)
 		return -EAGAIN;
 	if (ret & VM_FAULT_ERROR) {
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 81718c56b8f5..b56f69636ee2 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3778,7 +3778,8 @@ int huge_add_to_page_cache(struct page *page, struct address_space *mapping,
 static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
 			struct vm_area_struct *vma,
 			struct address_space *mapping, pgoff_t idx,
-			unsigned long address, pte_t *ptep, unsigned int flags)
+			unsigned long address, pte_t *ptep, unsigned int flags,
+			struct range_lock *mmrange)
 {
 	struct hstate *h = hstate_vma(vma);
 	vm_fault_t ret = VM_FAULT_SIGBUS;
@@ -3821,6 +3822,7 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
 				.vma = vma,
 				.address = haddr,
 				.flags = flags,
+				.lockrange = mmrange,
 				/*
 				 * Hard to debug if it ends up being
 				 * used by a callee that assumes
@@ -3969,7 +3971,8 @@ u32 hugetlb_fault_mutex_hash(struct hstate *h, struct address_space *mapping,
 #endif
 
 vm_fault_t hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-			unsigned long address, unsigned int flags)
+			 unsigned long address, unsigned int flags,
+			 struct range_lock *mmrange)
 {
 	pte_t *ptep, entry;
 	spinlock_t *ptl;
@@ -4011,7 +4014,7 @@ vm_fault_t hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	entry = huge_ptep_get(ptep);
 	if (huge_pte_none(entry)) {
-		ret = hugetlb_no_page(mm, vma, mapping, idx, address, ptep, flags);
+		ret = hugetlb_no_page(mm, vma, mapping, idx, address, ptep, flags, mmrange);
 		goto out_mutex;
 	}
 
@@ -4239,7 +4242,8 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
 long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			 struct page **pages, struct vm_area_struct **vmas,
 			 unsigned long *position, unsigned long *nr_pages,
-			 long i, unsigned int flags, int *nonblocking)
+			 long i, unsigned int flags, int *nonblocking,
+			 struct range_lock *mmrange)
 {
 	unsigned long pfn_offset;
 	unsigned long vaddr = *position;
@@ -4320,7 +4324,7 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 						FAULT_FLAG_ALLOW_RETRY);
 				fault_flags |= FAULT_FLAG_TRIED;
 			}
-			ret = hugetlb_fault(mm, vma, vaddr, fault_flags);
+			ret = hugetlb_fault(mm, vma, vaddr, fault_flags, mmrange);
 			if (ret & VM_FAULT_ERROR) {
 				err = vm_fault_to_errno(ret, flags);
 				remainder = 0;
diff --git a/mm/internal.h b/mm/internal.h
index 9eeaf2b95166..f38f7b9b01d8 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -298,7 +298,8 @@ void __vma_link_list(struct mm_struct *mm, struct vm_area_struct *vma,
 
 #ifdef CONFIG_MMU
 extern long populate_vma_page_range(struct vm_area_struct *vma,
-		unsigned long start, unsigned long end, int *nonblocking);
+		unsigned long start, unsigned long end, int *nonblocking,
+		struct range_lock *mmrange);
 extern void munlock_vma_pages_range(struct vm_area_struct *vma,
 			unsigned long start, unsigned long end);
 static inline void munlock_vma_pages_all(struct vm_area_struct *vma)
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index a335f7c1fac4..3eefcb8f797d 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -878,7 +878,8 @@ static int hugepage_vma_revalidate(struct mm_struct *mm, unsigned long address,
 static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 					struct vm_area_struct *vma,
 					unsigned long address, pmd_t *pmd,
-					int referenced)
+					int referenced,
+					struct range_lock *mmrange)
 {
 	int swapped_in = 0;
 	vm_fault_t ret = 0;
@@ -888,6 +889,7 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 		.flags = FAULT_FLAG_ALLOW_RETRY,
 		.pmd = pmd,
 		.pgoff = linear_page_index(vma, address),
+		.lockrange = mmrange,
 	};
 
 	/* we only decide to swapin, if there is enough young ptes */
@@ -932,9 +934,10 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 }
 
 static void collapse_huge_page(struct mm_struct *mm,
-				   unsigned long address,
-				   struct page **hpage,
-				   int node, int referenced)
+			       unsigned long address,
+			       struct page **hpage,
+			       int node, int referenced,
+			       struct range_lock *mmrange)
 {
 	pmd_t *pmd, _pmd;
 	pte_t *pte;
@@ -991,7 +994,8 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 * If it fails, we release mmap_sem and jump out_nolock.
 	 * Continuing to collapse causes inconsistency.
 	 */
-	if (!__collapse_huge_page_swapin(mm, vma, address, pmd, referenced)) {
+	if (!__collapse_huge_page_swapin(mm, vma, address, pmd,
+					 referenced, mmrange)) {
 		mem_cgroup_cancel_charge(new_page, memcg, true);
 		up_read(&mm->mmap_sem);
 		goto out_nolock;
@@ -1099,7 +1103,8 @@ static void collapse_huge_page(struct mm_struct *mm,
 static int khugepaged_scan_pmd(struct mm_struct *mm,
 			       struct vm_area_struct *vma,
 			       unsigned long address,
-			       struct page **hpage)
+			       struct page **hpage,
+			       struct range_lock *mmrange)
 {
 	pmd_t *pmd;
 	pte_t *pte, *_pte;
@@ -1213,7 +1218,7 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 	if (ret) {
 		node = khugepaged_find_target_node();
 		/* collapse_huge_page will return with the mmap_sem released */
-		collapse_huge_page(mm, address, hpage, node, referenced);
+		collapse_huge_page(mm, address, hpage, node, referenced, mmrange);
 	}
 out:
 	trace_mm_khugepaged_scan_pmd(mm, page, writable, referenced,
@@ -1652,6 +1657,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
 	int progress = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	VM_BUG_ON(!pages);
 	lockdep_assert_held(&khugepaged_mm_lock);
@@ -1724,8 +1730,8 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 				fput(file);
 			} else {
 				ret = khugepaged_scan_pmd(mm, vma,
-						khugepaged_scan.address,
-						hpage);
+							  khugepaged_scan.address,
+							  hpage, &mmrange);
 			}
 			/* move to next address */
 			khugepaged_scan.address += HPAGE_PMD_SIZE;
diff --git a/mm/ksm.c b/mm/ksm.c
index 81c20ed57bf6..ccc9737311eb 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -480,8 +480,9 @@ static int break_ksm(struct vm_area_struct *vma, unsigned long addr)
 		if (IS_ERR_OR_NULL(page))
 			break;
 		if (PageKsm(page))
+			/*** BROKEN mmrange, we don't care about ksm (for now) */
 			ret = handle_mm_fault(vma, addr,
-					FAULT_FLAG_WRITE | FAULT_FLAG_REMOTE);
+					      FAULT_FLAG_WRITE | FAULT_FLAG_REMOTE, NULL);
 		else
 			ret = VM_FAULT_WRITE;
 		put_page(page);
diff --git a/mm/memory.c b/mm/memory.c
index 0d0711a912de..9516c95108a1 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2850,7 +2850,7 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
 		goto out_release;
 	}
 
-	locked = lock_page_or_retry(page, vma->vm_mm, vmf->flags);
+	locked = lock_page_or_retry(page, vma->vm_mm, vmf->flags, vmf->lockrange);
 
 	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 	if (!locked) {
@@ -3938,7 +3938,8 @@ static vm_fault_t handle_pte_fault(struct vm_fault *vmf)
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
 static vm_fault_t __handle_mm_fault(struct vm_area_struct *vma,
-		unsigned long address, unsigned int flags)
+				    unsigned long address, unsigned int flags,
+				    struct range_lock *mmrange)
 {
 	struct vm_fault vmf = {
 		.vma = vma,
@@ -3946,6 +3947,7 @@ static vm_fault_t __handle_mm_fault(struct vm_area_struct *vma,
 		.flags = flags,
 		.pgoff = linear_page_index(vma, address),
 		.gfp_mask = __get_fault_gfp_mask(vma),
+		.lockrange = mmrange,
 	};
 	unsigned int dirty = flags & FAULT_FLAG_WRITE;
 	struct mm_struct *mm = vma->vm_mm;
@@ -4027,7 +4029,7 @@ static vm_fault_t __handle_mm_fault(struct vm_area_struct *vma,
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
 vm_fault_t handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
-		unsigned int flags)
+			   unsigned int flags, struct range_lock *mmrange)
 {
 	vm_fault_t ret;
 
@@ -4052,9 +4054,9 @@ vm_fault_t handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 		mem_cgroup_enter_user_fault();
 
 	if (unlikely(is_vm_hugetlb_page(vma)))
-		ret = hugetlb_fault(vma->vm_mm, vma, address, flags);
+		ret = hugetlb_fault(vma->vm_mm, vma, address, flags, mmrange);
 	else
-		ret = __handle_mm_fault(vma, address, flags);
+		ret = __handle_mm_fault(vma, address, flags, mmrange);
 
 	if (flags & FAULT_FLAG_USER) {
 		mem_cgroup_exit_user_fault();
@@ -4356,7 +4358,7 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 		struct page *page = NULL;
 
 		ret = get_user_pages_remote(tsk, mm, addr, 1,
-				gup_flags, &page, &vma, NULL);
+					    gup_flags, &page, &vma, NULL, NULL);
 		if (ret <= 0) {
 #ifndef CONFIG_HAVE_IOREMAP_PROT
 			break;
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 2219e747df49..975793cc1d71 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -823,13 +823,15 @@ static void get_policy_nodemask(struct mempolicy *p, nodemask_t *nodes)
 	}
 }
 
-static int lookup_node(struct mm_struct *mm, unsigned long addr)
+static int lookup_node(struct mm_struct *mm, unsigned long addr,
+		       struct range_lock *mmrange)
 {
 	struct page *p;
 	int err;
 
 	int locked = 1;
-	err = get_user_pages_locked(addr & PAGE_MASK, 1, 0, &p, &locked);
+	err = get_user_pages_locked(addr & PAGE_MASK, 1, 0, &p,
+				    &locked, mmrange);
 	if (err >= 0) {
 		err = page_to_nid(p);
 		put_page(p);
@@ -847,6 +849,7 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma = NULL;
 	struct mempolicy *pol = current->mempolicy, *pol_refcount = NULL;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (flags &
 		~(unsigned long)(MPOL_F_NODE|MPOL_F_ADDR|MPOL_F_MEMS_ALLOWED))
@@ -895,7 +898,7 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 			pol_refcount = pol;
 			vma = NULL;
 			mpol_get(pol);
-			err = lookup_node(mm, addr);
+			err = lookup_node(mm, addr, &mmrange);
 			if (err < 0)
 				goto out;
 			*policy = err;
diff --git a/mm/mmap.c b/mm/mmap.c
index 57803a0a3a5c..af228ae3508d 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2530,7 +2530,7 @@ find_extend_vma(struct mm_struct *mm, unsigned long addr)
 	if (!prev || !mmget_still_valid(mm) || expand_stack(prev, addr))
 		return NULL;
 	if (prev->vm_flags & VM_LOCKED)
-		populate_vma_page_range(prev, addr, prev->vm_end, NULL);
+		populate_vma_page_range(prev, addr, prev->vm_end, NULL, NULL);
 	return prev;
 }
 #else
@@ -2560,7 +2560,7 @@ find_extend_vma(struct mm_struct *mm, unsigned long addr)
 	if (expand_stack(vma, addr))
 		return NULL;
 	if (vma->vm_flags & VM_LOCKED)
-		populate_vma_page_range(vma, addr, start, NULL);
+		populate_vma_page_range(vma, addr, start, NULL, NULL);
 	return vma;
 }
 #endif
diff --git a/mm/mprotect.c b/mm/mprotect.c
index bf38dfbbb4b4..36c517c6a5b1 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -439,7 +439,7 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 	 */
 	if ((oldflags & (VM_WRITE | VM_SHARED | VM_LOCKED)) == VM_LOCKED &&
 			(newflags & VM_WRITE)) {
-		populate_vma_page_range(vma, start, end, NULL);
+		populate_vma_page_range(vma, start, end, NULL, NULL);
 	}
 
 	vm_stat_account(mm, oldflags, -nrpages);
diff --git a/mm/process_vm_access.c b/mm/process_vm_access.c
index a447092d4635..ff6772b86195 100644
--- a/mm/process_vm_access.c
+++ b/mm/process_vm_access.c
@@ -90,6 +90,7 @@ static int process_vm_rw_single_vec(unsigned long addr,
 	unsigned long max_pages_per_loop = PVM_MAX_KMALLOC_PAGES
 		/ sizeof(struct pages *);
 	unsigned int flags = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/* Work out address and page range required */
 	if (len == 0)
@@ -111,7 +112,8 @@ static int process_vm_rw_single_vec(unsigned long addr,
 		 */
 		down_read(&mm->mmap_sem);
 		pages = get_user_pages_remote(task, mm, pa, pages, flags,
-					      process_pages, NULL, &locked);
+					      process_pages, NULL, &locked,
+					      &mmrange);
 		if (locked)
 			up_read(&mm->mmap_sem);
 		if (pages <= 0)
diff --git a/security/tomoyo/domain.c b/security/tomoyo/domain.c
index 8526a0a74023..6f577b633413 100644
--- a/security/tomoyo/domain.c
+++ b/security/tomoyo/domain.c
@@ -910,7 +910,7 @@ bool tomoyo_dump_page(struct linux_binprm *bprm, unsigned long pos,
 	 * the execve().
 	 */
 	if (get_user_pages_remote(current, bprm->mm, pos, 1,
-				FOLL_FORCE, &page, NULL, NULL) <= 0)
+				  FOLL_FORCE, &page, NULL, NULL, NULL) <= 0)
 		return false;
 #else
 	page = bprm->page[pos / PAGE_SIZE];
diff --git a/virt/kvm/async_pf.c b/virt/kvm/async_pf.c
index 110cbe3f74f8..e93cd8515134 100644
--- a/virt/kvm/async_pf.c
+++ b/virt/kvm/async_pf.c
@@ -78,6 +78,7 @@ static void async_pf_execute(struct work_struct *work)
 	unsigned long addr = apf->addr;
 	gva_t gva = apf->gva;
 	int locked = 1;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	might_sleep();
 
@@ -88,7 +89,7 @@ static void async_pf_execute(struct work_struct *work)
 	 */
 	down_read(&mm->mmap_sem);
 	get_user_pages_remote(NULL, mm, addr, 1, FOLL_WRITE, NULL, NULL,
-			&locked);
+			      &locked, &mmrange);
 	if (locked)
 		up_read(&mm->mmap_sem);
 
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index f0d13d9d125d..e1484150a3dd 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -1522,7 +1522,8 @@ static bool vma_is_valid(struct vm_area_struct *vma, bool write_fault)
 static int hva_to_pfn_remapped(struct vm_area_struct *vma,
 			       unsigned long addr, bool *async,
 			       bool write_fault, bool *writable,
-			       kvm_pfn_t *p_pfn)
+			       kvm_pfn_t *p_pfn,
+			       struct range_lock *mmrange)
 {
 	unsigned long pfn;
 	int r;
@@ -1536,7 +1537,7 @@ static int hva_to_pfn_remapped(struct vm_area_struct *vma,
 		bool unlocked = false;
 		r = fixup_user_fault(current, current->mm, addr,
 				     (write_fault ? FAULT_FLAG_WRITE : 0),
-				     &unlocked);
+				     &unlocked, mmrange);
 		if (unlocked)
 			return -EAGAIN;
 		if (r)
@@ -1588,6 +1589,7 @@ static kvm_pfn_t hva_to_pfn(unsigned long addr, bool atomic, bool *async,
 	struct vm_area_struct *vma;
 	kvm_pfn_t pfn = 0;
 	int npages, r;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/* we can do it either atomically or asynchronously, not both */
 	BUG_ON(atomic && async);
@@ -1615,7 +1617,8 @@ static kvm_pfn_t hva_to_pfn(unsigned long addr, bool atomic, bool *async,
 	if (vma == NULL)
 		pfn = KVM_PFN_ERR_FAULT;
 	else if (vma->vm_flags & (VM_IO | VM_PFNMAP)) {
-		r = hva_to_pfn_remapped(vma, addr, async, write_fault, writable, &pfn);
+		r = hva_to_pfn_remapped(vma, addr, async, write_fault,
+					writable, &pfn, &mmrange);
 		if (r == -EAGAIN)
 			goto retry;
 		if (r < 0)
-- 
2.16.4

