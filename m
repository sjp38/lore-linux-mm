Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59F68C282DA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:47:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 094B9222BC
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:47:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 094B9222BC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 618DB6B026E; Tue, 16 Apr 2019 09:47:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57B666B0270; Tue, 16 Apr 2019 09:47:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F3506B0271; Tue, 16 Apr 2019 09:47:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 13E206B026E
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:03 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id g186so15672956ybg.16
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 06:47:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=PTSOch4L+fXVWlK6LWprFn0fIBj8utDcUEXogBml36Q=;
        b=swIeYwEue5FQleR3Zz+o6BjdXosRhmTl0GnbayrxO/7YVDR+OFJlAClJPg8jXoIiOk
         2BkkHzrqvQuQC/ahkX65aSqOnrVI9ZJVteeASPf+AZr20iVTYyYgHp9aYXLNmm7jV0qq
         8hTOgaTu3tFwacuBzLmEG000kToDDohfXhyFQp1lJB5WM+YQaf3IUhM3dHFI4N6Nc8i2
         zsFUPBGeexdej4RzkaEwN5s4QUiMC6gB20c+8bS5OnRTxtNOEx8GMpyIMU/qx1PzF5dn
         yhPNFI8HKf8Z25K3z7R4/1G9PYTeVAUwjuJxbKyzwsDAY7wXJi0E3cTfvmusdTC5Yj7c
         LSCQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAV5/RPUyNSSFWeD1bQILUYEjP0VkK5MTuCY7pqDKBRq85tFe2mv
	07Mrvck8f6j3OOyMwkbdWfpaU7wJFXIXHNQaWaLeYHMejjPDdadTANnJgfNL4Ur/TiBhv7zDXrF
	tpFIara4GqpQa/ulDy2MNwPyTfuYKYnapUfFAxmFuwHN9NethqCVKRWdYeVrqqOn9NQ==
X-Received: by 2002:a81:a350:: with SMTP id a77mr64692112ywh.66.1555422422748;
        Tue, 16 Apr 2019 06:47:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxon0nS2Wxsnju92mYca9QbMpnPzwgJMyKy5pNEXReCJws0/3zVIJvata003udAI0qRKmsn
X-Received: by 2002:a81:a350:: with SMTP id a77mr64691925ywh.66.1555422420794;
        Tue, 16 Apr 2019 06:47:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555422420; cv=none;
        d=google.com; s=arc-20160816;
        b=UoUtfMnNUYQOpI23h8NaZyo4mlObLT8IwKqQyFjiq/2yV7rlzkCSP4e3RxIjQafz4p
         +FT1imIJPl5lSkTvxc5V0ZTHSxrpzQcd205Bluui9gk/kUoXS6xun1ej606/dYv1jBCK
         ADK3+HoJUTVAFOpPaqcgm1sbBsscoAtXft9AQ6sK+hKUO+FOfxrkrfO63z7DhYCan6Ir
         9mNSszFEdw9/C/cTZIWxGiNZ56LFhvTkOkau6xxVR+KdHfjErTzzJGn30M4kH0sRqvyC
         vHLPnCU7R7oyA3qMKpNt0gygUCFcvwtmTyYfiA/2FROnuq0+2xYJG92571NyvZjhEiwY
         r8VQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=PTSOch4L+fXVWlK6LWprFn0fIBj8utDcUEXogBml36Q=;
        b=m7EZLEqUyvc8AfuGNilIMCjVETAENDYcvJAtqD6TAG3SUlLHnC/JP3EzTsVjQq2s4E
         JlJ/75jWWh0UcIL+ZUbSR6h0GzWgwVLY8DiJCH8gO95Ps/qBeCQ6i3dRsNxJIsNALp0w
         7Xw9jbgRoqHIHbUoSEDOj8tewstXBz+iQtshUrri8Lst1KoFgpgnYrzlps8pWo+mT7JN
         vsqATUlv+xMeLcNyyUrhfKiObhRFW6FfXy8J762E4ZZkE4UF5f7TyM3tvlKezXWYdsr6
         U5AuWDDG6dezN7kZPAQsHu72IbzWhuAOPDQ5hOU9PiWORif8zlljg+hAePJqb3l8lK1s
         59GA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 14si31170852yww.219.2019.04.16.06.47.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:47:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3GDkpMe059581
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:46:59 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rwe36ny53-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:46:56 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Tue, 16 Apr 2019 14:46:12 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 16 Apr 2019 14:46:02 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3GDk0sc55836732
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 16 Apr 2019 13:46:00 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 76C1C4C040;
	Tue, 16 Apr 2019 13:46:00 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 003A94C059;
	Tue, 16 Apr 2019 13:45:59 +0000 (GMT)
Received: from nimbus.lab.toulouse-stg.fr.ibm.com (unknown [9.101.4.33])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 16 Apr 2019 13:45:58 +0000 (GMT)
From: Laurent Dufour <ldufour@linux.ibm.com>
To: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org,
        kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net,
        jack@suse.cz, Matthew Wilcox <willy@infradead.org>,
        aneesh.kumar@linux.ibm.com, benh@kernel.crashing.org,
        mpe@ellerman.id.au, paulus@samba.org,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        hpa@zytor.com, Will Deacon <will.deacon@arm.com>,
        Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
        sergey.senozhatsky.work@gmail.com,
        Andrea Arcangeli <aarcange@redhat.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com,
        Daniel Jordan <daniel.m.jordan@oracle.com>,
        David Rientjes <rientjes@google.com>,
        Jerome Glisse <jglisse@redhat.com>,
        Ganesh Mahendran <opensource.ganesh@gmail.com>,
        Minchan Kim <minchan@kernel.org>,
        Punit Agrawal <punitagrawal@gmail.com>,
        vinayak menon <vinayakm.list@gmail.com>,
        Yang Shi <yang.shi@linux.alibaba.com>,
        zhong jiang <zhongjiang@huawei.com>,
        Haiyan Song <haiyanx.song@intel.com>,
        Balbir Singh <bsingharora@gmail.com>, sj38.park@gmail.com,
        Michel Lespinasse <walken@google.com>,
        Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com,
        npiggin@gmail.com, paulmck@linux.vnet.ibm.com,
        Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org,
        x86@kernel.org
Subject: [PATCH v12 13/31] mm: cache some VMA fields in the vm_fault structure
Date: Tue, 16 Apr 2019 15:45:04 +0200
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190416134522.17540-1-ldufour@linux.ibm.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19041613-0008-0000-0000-000002DA6FB2
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041613-0009-0000-0000-00002246A83C
Message-Id: <20190416134522.17540-14-ldufour@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-16_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904160093
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When handling speculative page fault, the vma->vm_flags and
vma->vm_page_prot fields are read once the page table lock is released. So
there is no more guarantee that these fields would not change in our back.
They will be saved in the vm_fault structure before the VMA is checked for
changes.

In the detail, when we deal with a speculative page fault, the mmap_sem is
not taken, so parallel VMA's changes can occurred. When a VMA change is
done which will impact the page fault processing, we assumed that the VMA
sequence counter will be changed.  In the page fault processing, at the
time the PTE is locked, we checked the VMA sequence counter to detect
changes done in our back. If no change is detected we can continue further.
But this doesn't prevent the VMA to not be changed in our back while the
PTE is locked. So VMA's fields which are used while the PTE is locked must
be saved to ensure that we are using *static* values.  This is important
since the PTE changes will be made on regards to these VMA fields and they
need to be consistent. This concerns the vma->vm_flags and
vma->vm_page_prot VMA fields.

This patch also set the fields in hugetlb_no_page() and
__collapse_huge_page_swapin even if it is not need for the callee.

Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
---
 include/linux/mm.h | 10 +++++++--
 mm/huge_memory.c   |  6 +++---
 mm/hugetlb.c       |  2 ++
 mm/khugepaged.c    |  2 ++
 mm/memory.c        | 53 ++++++++++++++++++++++++----------------------
 mm/migrate.c       |  2 +-
 6 files changed, 44 insertions(+), 31 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5d45b7d8718d..f465bb2b049e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -439,6 +439,12 @@ struct vm_fault {
 					 * page table to avoid allocation from
 					 * atomic context.
 					 */
+	/*
+	 * These entries are required when handling speculative page fault.
+	 * This way the page handling is done using consistent field values.
+	 */
+	unsigned long vma_flags;
+	pgprot_t vma_page_prot;
 };
 
 /* page entry size for vm->huge_fault() */
@@ -781,9 +787,9 @@ void free_compound_page(struct page *page);
  * pte_mkwrite.  But get_user_pages can cause write faults for mappings
  * that do not have writing enabled, when used by access_process_vm.
  */
-static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
+static inline pte_t maybe_mkwrite(pte_t pte, unsigned long vma_flags)
 {
-	if (likely(vma->vm_flags & VM_WRITE))
+	if (likely(vma_flags & VM_WRITE))
 		pte = pte_mkwrite(pte);
 	return pte;
 }
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 823688414d27..865886a689ee 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1244,8 +1244,8 @@ static vm_fault_t do_huge_pmd_wp_page_fallback(struct vm_fault *vmf,
 
 	for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
 		pte_t entry;
-		entry = mk_pte(pages[i], vma->vm_page_prot);
-		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		entry = mk_pte(pages[i], vmf->vma_page_prot);
+		entry = maybe_mkwrite(pte_mkdirty(entry), vmf->vma_flags);
 		memcg = (void *)page_private(pages[i]);
 		set_page_private(pages[i], 0);
 		page_add_new_anon_rmap(pages[i], vmf->vma, haddr, false);
@@ -2228,7 +2228,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 				entry = pte_swp_mksoft_dirty(entry);
 		} else {
 			entry = mk_pte(page + i, READ_ONCE(vma->vm_page_prot));
-			entry = maybe_mkwrite(entry, vma);
+			entry = maybe_mkwrite(entry, vma->vm_flags);
 			if (!write)
 				entry = pte_wrprotect(entry);
 			if (!young)
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 109f5de82910..13246da4bc50 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3812,6 +3812,8 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
 				.vma = vma,
 				.address = haddr,
 				.flags = flags,
+				.vma_flags = vma->vm_flags,
+				.vma_page_prot = vma->vm_page_prot,
 				/*
 				 * Hard to debug if it ends up being
 				 * used by a callee that assumes
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 6a0cbca3885e..42469037240a 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -888,6 +888,8 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 		.flags = FAULT_FLAG_ALLOW_RETRY,
 		.pmd = pmd,
 		.pgoff = linear_page_index(vma, address),
+		.vma_flags = vma->vm_flags,
+		.vma_page_prot = vma->vm_page_prot,
 	};
 
 	/* we only decide to swapin, if there is enough young ptes */
diff --git a/mm/memory.c b/mm/memory.c
index 2cf7b6185daa..d0de58464479 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1560,7 +1560,8 @@ static vm_fault_t insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 				goto out_unlock;
 			}
 			entry = pte_mkyoung(*pte);
-			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+			entry = maybe_mkwrite(pte_mkdirty(entry),
+					      vma->vm_flags);
 			if (ptep_set_access_flags(vma, addr, pte, entry, 1))
 				update_mmu_cache(vma, addr, pte);
 		}
@@ -1575,7 +1576,7 @@ static vm_fault_t insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 
 	if (mkwrite) {
 		entry = pte_mkyoung(entry);
-		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		entry = maybe_mkwrite(pte_mkdirty(entry), vma->vm_flags);
 	}
 
 	set_pte_at(mm, addr, pte, entry);
@@ -2257,7 +2258,7 @@ static inline void wp_page_reuse(struct vm_fault *vmf)
 
 	flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
 	entry = pte_mkyoung(vmf->orig_pte);
-	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+	entry = maybe_mkwrite(pte_mkdirty(entry), vmf->vma_flags);
 	if (ptep_set_access_flags(vma, vmf->address, vmf->pte, entry, 1))
 		update_mmu_cache(vma, vmf->address, vmf->pte);
 	pte_unmap_unlock(vmf->pte, vmf->ptl);
@@ -2335,8 +2336,8 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
 			inc_mm_counter_fast(mm, MM_ANONPAGES);
 		}
 		flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
-		entry = mk_pte(new_page, vma->vm_page_prot);
-		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		entry = mk_pte(new_page, vmf->vma_page_prot);
+		entry = maybe_mkwrite(pte_mkdirty(entry), vmf->vma_flags);
 		/*
 		 * Clear the pte entry and flush it first, before updating the
 		 * pte with the new entry. This will avoid a race condition
@@ -2401,7 +2402,7 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
 		 * Don't let another task, with possibly unlocked vma,
 		 * keep the mlocked page.
 		 */
-		if (page_copied && (vma->vm_flags & VM_LOCKED)) {
+		if (page_copied && (vmf->vma_flags & VM_LOCKED)) {
 			lock_page(old_page);	/* LRU manipulation */
 			if (PageMlocked(old_page))
 				munlock_vma_page(old_page);
@@ -2438,7 +2439,7 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
  */
 vm_fault_t finish_mkwrite_fault(struct vm_fault *vmf)
 {
-	WARN_ON_ONCE(!(vmf->vma->vm_flags & VM_SHARED));
+	WARN_ON_ONCE(!(vmf->vma_flags & VM_SHARED));
 	if (!pte_map_lock(vmf))
 		return VM_FAULT_RETRY;
 	/*
@@ -2540,7 +2541,7 @@ static vm_fault_t do_wp_page(struct vm_fault *vmf)
 		 * We should not cow pages in a shared writeable mapping.
 		 * Just mark the pages writable and/or call ops->pfn_mkwrite.
 		 */
-		if ((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
+		if ((vmf->vma_flags & (VM_WRITE|VM_SHARED)) ==
 				     (VM_WRITE|VM_SHARED))
 			return wp_pfn_shared(vmf);
 
@@ -2599,7 +2600,7 @@ static vm_fault_t do_wp_page(struct vm_fault *vmf)
 			return VM_FAULT_WRITE;
 		}
 		unlock_page(vmf->page);
-	} else if (unlikely((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
+	} else if (unlikely((vmf->vma_flags & (VM_WRITE|VM_SHARED)) ==
 					(VM_WRITE|VM_SHARED))) {
 		return wp_page_shared(vmf);
 	}
@@ -2878,9 +2879,9 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
 
 	inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
 	dec_mm_counter_fast(vma->vm_mm, MM_SWAPENTS);
-	pte = mk_pte(page, vma->vm_page_prot);
+	pte = mk_pte(page, vmf->vma_page_prot);
 	if ((vmf->flags & FAULT_FLAG_WRITE) && reuse_swap_page(page, NULL)) {
-		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
+		pte = maybe_mkwrite(pte_mkdirty(pte), vmf->vma_flags);
 		vmf->flags &= ~FAULT_FLAG_WRITE;
 		ret |= VM_FAULT_WRITE;
 		exclusive = RMAP_EXCLUSIVE;
@@ -2905,7 +2906,7 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
 
 	swap_free(entry);
 	if (mem_cgroup_swap_full(page) ||
-	    (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
+	    (vmf->vma_flags & VM_LOCKED) || PageMlocked(page))
 		try_to_free_swap(page);
 	unlock_page(page);
 	if (page != swapcache && swapcache) {
@@ -2963,7 +2964,7 @@ static vm_fault_t do_anonymous_page(struct vm_fault *vmf)
 	pte_t entry;
 
 	/* File mapping without ->vm_ops ? */
-	if (vma->vm_flags & VM_SHARED)
+	if (vmf->vma_flags & VM_SHARED)
 		return VM_FAULT_SIGBUS;
 
 	/*
@@ -2987,7 +2988,7 @@ static vm_fault_t do_anonymous_page(struct vm_fault *vmf)
 	if (!(vmf->flags & FAULT_FLAG_WRITE) &&
 			!mm_forbids_zeropage(vma->vm_mm)) {
 		entry = pte_mkspecial(pfn_pte(my_zero_pfn(vmf->address),
-						vma->vm_page_prot));
+						vmf->vma_page_prot));
 		if (!pte_map_lock(vmf))
 			return VM_FAULT_RETRY;
 		if (!pte_none(*vmf->pte))
@@ -3021,8 +3022,8 @@ static vm_fault_t do_anonymous_page(struct vm_fault *vmf)
 	 */
 	__SetPageUptodate(page);
 
-	entry = mk_pte(page, vma->vm_page_prot);
-	if (vma->vm_flags & VM_WRITE)
+	entry = mk_pte(page, vmf->vma_page_prot);
+	if (vmf->vma_flags & VM_WRITE)
 		entry = pte_mkwrite(pte_mkdirty(entry));
 
 	if (!pte_map_lock(vmf)) {
@@ -3242,7 +3243,7 @@ static vm_fault_t do_set_pmd(struct vm_fault *vmf, struct page *page)
 	for (i = 0; i < HPAGE_PMD_NR; i++)
 		flush_icache_page(vma, page + i);
 
-	entry = mk_huge_pmd(page, vma->vm_page_prot);
+	entry = mk_huge_pmd(page, vmf->vma_page_prot);
 	if (write)
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 
@@ -3318,11 +3319,11 @@ vm_fault_t alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
 		return VM_FAULT_NOPAGE;
 
 	flush_icache_page(vma, page);
-	entry = mk_pte(page, vma->vm_page_prot);
+	entry = mk_pte(page, vmf->vma_page_prot);
 	if (write)
-		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		entry = maybe_mkwrite(pte_mkdirty(entry), vmf->vma_flags);
 	/* copy-on-write page */
-	if (write && !(vma->vm_flags & VM_SHARED)) {
+	if (write && !(vmf->vma_flags & VM_SHARED)) {
 		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
 		page_add_new_anon_rmap(page, vma, vmf->address, false);
 		mem_cgroup_commit_charge(page, memcg, false, false);
@@ -3362,7 +3363,7 @@ vm_fault_t finish_fault(struct vm_fault *vmf)
 
 	/* Did we COW the page? */
 	if ((vmf->flags & FAULT_FLAG_WRITE) &&
-	    !(vmf->vma->vm_flags & VM_SHARED))
+	    !(vmf->vma_flags & VM_SHARED))
 		page = vmf->cow_page;
 	else
 		page = vmf->page;
@@ -3641,7 +3642,7 @@ static vm_fault_t do_fault(struct vm_fault *vmf)
 		}
 	} else if (!(vmf->flags & FAULT_FLAG_WRITE))
 		ret = do_read_fault(vmf);
-	else if (!(vma->vm_flags & VM_SHARED))
+	else if (!(vmf->vma_flags & VM_SHARED))
 		ret = do_cow_fault(vmf);
 	else
 		ret = do_shared_fault(vmf);
@@ -3698,7 +3699,7 @@ static vm_fault_t do_numa_page(struct vm_fault *vmf)
 	 * accessible ptes, some can allow access by kernel mode.
 	 */
 	old_pte = ptep_modify_prot_start(vma, vmf->address, vmf->pte);
-	pte = pte_modify(old_pte, vma->vm_page_prot);
+	pte = pte_modify(old_pte, vmf->vma_page_prot);
 	pte = pte_mkyoung(pte);
 	if (was_writable)
 		pte = pte_mkwrite(pte);
@@ -3732,7 +3733,7 @@ static vm_fault_t do_numa_page(struct vm_fault *vmf)
 	 * Flag if the page is shared between multiple address spaces. This
 	 * is later used when determining whether to group tasks together
 	 */
-	if (page_mapcount(page) > 1 && (vma->vm_flags & VM_SHARED))
+	if (page_mapcount(page) > 1 && (vmf->vma_flags & VM_SHARED))
 		flags |= TNF_SHARED;
 
 	last_cpupid = page_cpupid_last(page);
@@ -3777,7 +3778,7 @@ static inline vm_fault_t wp_huge_pmd(struct vm_fault *vmf, pmd_t orig_pmd)
 		return vmf->vma->vm_ops->huge_fault(vmf, PE_SIZE_PMD);
 
 	/* COW handled on pte level: split pmd */
-	VM_BUG_ON_VMA(vmf->vma->vm_flags & VM_SHARED, vmf->vma);
+	VM_BUG_ON_VMA(vmf->vma_flags & VM_SHARED, vmf->vma);
 	__split_huge_pmd(vmf->vma, vmf->pmd, vmf->address, false, NULL);
 
 	return VM_FAULT_FALLBACK;
@@ -3924,6 +3925,8 @@ static vm_fault_t __handle_mm_fault(struct vm_area_struct *vma,
 		.flags = flags,
 		.pgoff = linear_page_index(vma, address),
 		.gfp_mask = __get_fault_gfp_mask(vma),
+		.vma_flags = vma->vm_flags,
+		.vma_page_prot = vma->vm_page_prot,
 	};
 	unsigned int dirty = flags & FAULT_FLAG_WRITE;
 	struct mm_struct *mm = vma->vm_mm;
diff --git a/mm/migrate.c b/mm/migrate.c
index f2ecc2855a12..a9138093a8e2 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -240,7 +240,7 @@ static bool remove_migration_pte(struct page *page, struct vm_area_struct *vma,
 		 */
 		entry = pte_to_swp_entry(*pvmw.pte);
 		if (is_write_migration_entry(entry))
-			pte = maybe_mkwrite(pte, vma);
+			pte = maybe_mkwrite(pte, vma->vm_flags);
 
 		if (unlikely(is_zone_device_page(new))) {
 			if (is_device_private_page(new)) {
-- 
2.21.0

