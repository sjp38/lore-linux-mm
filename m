Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1179AC04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 04:53:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C560321019
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 04:53:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C560321019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0390A6B026D; Tue, 21 May 2019 00:53:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E8DCC6B026E; Tue, 21 May 2019 00:53:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D556E6B026F; Tue, 21 May 2019 00:53:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 816136B026D
	for <linux-mm@kvack.org>; Tue, 21 May 2019 00:53:45 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c26so28668891eda.15
        for <linux-mm@kvack.org>; Mon, 20 May 2019 21:53:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=xkRCB1iF6fVn4v/jj8cO3WC0XjDj1aKonhoR1jGRE2k=;
        b=MzfXXo4SZzqg47rcLqrnIEEMGp4ibfNqcnRTOscjGjh6HWZhjQVWvRUK/HfAcwXbH1
         h6elNQk20RjzOxk0qBGd+fRq5EijaB7VHGN16AMmRh6ZzAwp1nOG+jSu6UFIj/qULFsH
         PTZaOVXPVuJSGvb39jdT1P7p4UgS2TEBQlOkiPO1LdYt/bZnsHdHEFOv+WKDbVG9Y/on
         uxpq/Yon1qK29gUcj9YH+0omppTffj10nXzOwF3tHSUEfO0TWMWCyCHE8CS3hHU1nUnC
         MoQCn8y1eF3LdVxETIkUkTm243E65nfiGmcT6YOoVf/HTBpBw39JwdqsPIxVUe9fht/h
         mLoQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: APjAAAXvSoaqFyGMw7K5cWR9DrtK8CZI/WCkPSAidR3g4/ddFPaHoLH3
	b6EfVH9cSFThUiHF4CBoBQvX2kcMgMLmLa+5XR53cifI8wyQ1UoTnqIsQWVq/88llNvhWjzoWgI
	uIFmXq2YCkeV6FS//9Z301jxI0WRJPc1Po5OrCZJ72R3jYSQ9wDpJmrXcwOdomY4=
X-Received: by 2002:a17:907:2164:: with SMTP id rl4mr7212590ejb.103.1558414424962;
        Mon, 20 May 2019 21:53:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzGV71sm3N6VASxyxh4lUCQhmt7ggqGHH6wBI/dR1HRsPQSQhrXbj1cTXdQ4Wy+fmne+XLl
X-Received: by 2002:a17:907:2164:: with SMTP id rl4mr7212512ejb.103.1558414423272;
        Mon, 20 May 2019 21:53:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558414423; cv=none;
        d=google.com; s=arc-20160816;
        b=oZV8jvFYyhZn7apdrN5eNDRIoCM2wKE/D/wTBzmSa6Nv/pzADHksRyA6w5TW9cjBNe
         Yb5ySkRiQKA1aa7BoWM0PI5mwC3DZbj9dmYPfETrM2GvgNKx+zCkTtkMW8bbW+Hlqb4a
         XgzxZ1t4sgO1c8Z1eXBjKOhgehWZ6bKsPeZKkutOhHoUTaXfk4OIbWeyPvZ01uX9ITMO
         VBWU4B6BrgXLMM6MzfSzhB4MAAumNUwuu55sVmQMg5IxRyURnXYcfLj1Y3lHQC2x5E4z
         0/ZkCgv5DmasLCV3LQbK8TFfP5v13QRxMIrGANTNcoQcKtmsrzMRrl/glzcFq3YCz41Z
         x6Hg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=xkRCB1iF6fVn4v/jj8cO3WC0XjDj1aKonhoR1jGRE2k=;
        b=L+2Lec2gDAPxNP+oXndp8o2yNYzViYhfDa+J8BZ+bcW1EEtxZLKplefjnBSxZALimS
         JGv+oHhaFhaGGnyCMnYvwyMhIrOK8ZilVfGMNKYSYxcM5YF/ZAkQponWRIWy4LPOhEyp
         LkAuDl9Z4IJKDlhcScpmiOMqBphbmqpJPDBIUFo/HlGfsJXjVuK0+fWmjWvGhrTPQtMj
         0S5lDke/4Kd7uOPtqXJMlY3NW8nggG6Kpaycgll16rYdspd0M5UN4j+fZJyKxesVVStU
         a1kRCXReFcdd0moTp7PHG8oibLJ3RJxpxZOqNCsxiG8l2kq8je/X1liOpHTcTEDSxyMu
         aDNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id k35si4062594edd.39.2019.05.20.21.53.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 21:53:43 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Tue, 21 May 2019 06:53:42 +0200
Received: from linux-r8p5.suse.de (nwb-a10-snat.microfocus.com [10.120.13.201])
	by emea4-mta.ukb.novell.com with ESMTP (TLS encrypted); Tue, 21 May 2019 05:53:15 +0100
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
Subject: [PATCH 09/14] virt: teach the mm about range locking
Date: Mon, 20 May 2019 21:52:37 -0700
Message-Id: <20190521045242.24378-10-dave@stgolabs.net>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190521045242.24378-1-dave@stgolabs.net>
References: <20190521045242.24378-1-dave@stgolabs.net>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Conversion is straightforward, mmap_sem is used within the
the same function context most of the time. No change in
semantics.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 virt/kvm/arm/mmu.c  | 17 ++++++++++-------
 virt/kvm/async_pf.c |  4 ++--
 virt/kvm/kvm_main.c | 11 ++++++-----
 3 files changed, 18 insertions(+), 14 deletions(-)

diff --git a/virt/kvm/arm/mmu.c b/virt/kvm/arm/mmu.c
index 74b6582eaa3c..85f8b9ccfabe 100644
--- a/virt/kvm/arm/mmu.c
+++ b/virt/kvm/arm/mmu.c
@@ -980,9 +980,10 @@ void stage2_unmap_vm(struct kvm *kvm)
 	struct kvm_memslots *slots;
 	struct kvm_memory_slot *memslot;
 	int idx;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	idx = srcu_read_lock(&kvm->srcu);
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &mmrange);
 	spin_lock(&kvm->mmu_lock);
 
 	slots = kvm_memslots(kvm);
@@ -990,7 +991,7 @@ void stage2_unmap_vm(struct kvm *kvm)
 		stage2_unmap_memslot(kvm, memslot);
 
 	spin_unlock(&kvm->mmu_lock);
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 	srcu_read_unlock(&kvm->srcu, idx);
 }
 
@@ -1688,6 +1689,7 @@ static int user_mem_abort(struct kvm_vcpu *vcpu, phys_addr_t fault_ipa,
 	kvm_pfn_t pfn;
 	pgprot_t mem_type = PAGE_S2;
 	bool logging_active = memslot_is_logging(memslot);
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	unsigned long vma_pagesize, flags = 0;
 
 	write_fault = kvm_is_write_fault(vcpu);
@@ -1700,11 +1702,11 @@ static int user_mem_abort(struct kvm_vcpu *vcpu, phys_addr_t fault_ipa,
 	}
 
 	/* Let's check if we will get back a huge page backed by hugetlbfs */
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &mmrange);
 	vma = find_vma_intersection(current->mm, hva, hva + 1);
 	if (unlikely(!vma)) {
 		kvm_err("Failed to find VMA for hva 0x%lx\n", hva);
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &mmrange);
 		return -EFAULT;
 	}
 
@@ -1725,7 +1727,7 @@ static int user_mem_abort(struct kvm_vcpu *vcpu, phys_addr_t fault_ipa,
 	if (vma_pagesize == PMD_SIZE ||
 	    (vma_pagesize == PUD_SIZE && kvm_stage2_has_pmd(kvm)))
 		gfn = (fault_ipa & huge_page_mask(hstate_vma(vma))) >> PAGE_SHIFT;
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 
 	/* We need minimum second+third level pages */
 	ret = mmu_topup_memory_cache(memcache, kvm_mmu_cache_min_pages(kvm),
@@ -2280,6 +2282,7 @@ int kvm_arch_prepare_memory_region(struct kvm *kvm,
 	hva_t reg_end = hva + mem->memory_size;
 	bool writable = !(mem->flags & KVM_MEM_READONLY);
 	int ret = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (change != KVM_MR_CREATE && change != KVM_MR_MOVE &&
 			change != KVM_MR_FLAGS_ONLY)
@@ -2293,7 +2296,7 @@ int kvm_arch_prepare_memory_region(struct kvm *kvm,
 	    (kvm_phys_size(kvm) >> PAGE_SHIFT))
 		return -EFAULT;
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &mmrange);
 	/*
 	 * A memory region could potentially cover multiple VMAs, and any holes
 	 * between them, so iterate over all of them to find out if we can map
@@ -2361,7 +2364,7 @@ int kvm_arch_prepare_memory_region(struct kvm *kvm,
 		stage2_flush_memslot(kvm, memslot);
 	spin_unlock(&kvm->mmu_lock);
 out:
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 	return ret;
 }
 
diff --git a/virt/kvm/async_pf.c b/virt/kvm/async_pf.c
index e93cd8515134..03d9f9bc5270 100644
--- a/virt/kvm/async_pf.c
+++ b/virt/kvm/async_pf.c
@@ -87,11 +87,11 @@ static void async_pf_execute(struct work_struct *work)
 	 * mm and might be done in another context, so we must
 	 * access remotely.
 	 */
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	get_user_pages_remote(NULL, mm, addr, 1, FOLL_WRITE, NULL, NULL,
 			      &locked, &mmrange);
 	if (locked)
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 
 	kvm_async_page_present_sync(vcpu, apf);
 
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index e1484150a3dd..421652e66a03 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -1331,6 +1331,7 @@ EXPORT_SYMBOL_GPL(kvm_is_visible_gfn);
 unsigned long kvm_host_page_size(struct kvm *kvm, gfn_t gfn)
 {
 	struct vm_area_struct *vma;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	unsigned long addr, size;
 
 	size = PAGE_SIZE;
@@ -1339,7 +1340,7 @@ unsigned long kvm_host_page_size(struct kvm *kvm, gfn_t gfn)
 	if (kvm_is_error_hva(addr))
 		return PAGE_SIZE;
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &mmrange);
 	vma = find_vma(current->mm, addr);
 	if (!vma)
 		goto out;
@@ -1347,7 +1348,7 @@ unsigned long kvm_host_page_size(struct kvm *kvm, gfn_t gfn)
 	size = vma_kernel_pagesize(vma);
 
 out:
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 
 	return size;
 }
@@ -1588,8 +1589,8 @@ static kvm_pfn_t hva_to_pfn(unsigned long addr, bool atomic, bool *async,
 {
 	struct vm_area_struct *vma;
 	kvm_pfn_t pfn = 0;
-	int npages, r;
 	DEFINE_RANGE_LOCK_FULL(mmrange);
+	int npages, r;
 
 	/* we can do it either atomically or asynchronously, not both */
 	BUG_ON(atomic && async);
@@ -1604,7 +1605,7 @@ static kvm_pfn_t hva_to_pfn(unsigned long addr, bool atomic, bool *async,
 	if (npages == 1)
 		return pfn;
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &mmrange);
 	if (npages == -EHWPOISON ||
 	      (!async && check_user_page_hwpoison(addr))) {
 		pfn = KVM_PFN_ERR_HWPOISON;
@@ -1629,7 +1630,7 @@ static kvm_pfn_t hva_to_pfn(unsigned long addr, bool atomic, bool *async,
 		pfn = KVM_PFN_ERR_FAULT;
 	}
 exit:
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 	return pfn;
 }
 
-- 
2.16.4

