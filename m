Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	UNWANTED_LANGUAGE_BODY autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1F90C10F00
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 20:05:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4692A21773
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 20:05:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4692A21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E0B1E8E000A; Tue, 19 Feb 2019 15:05:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE12D8E0002; Tue, 19 Feb 2019 15:05:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CCF378E000A; Tue, 19 Feb 2019 15:05:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9ABD78E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 15:05:33 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id b6so618815qkg.4
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 12:05:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=/MIZcvQ73oHvyizAkMy4bbNGmjZ0HL1PlOjIuvQh24c=;
        b=MOlMlKqPEOCsg3QUX+llkS59gfCa4hy0E6VVV8FxghP7nywISDZE0JnpUn/mrMsHyr
         8lv6VU1ApPci3Qk4S07DxMAT6H0PP6HG0ZfCPtRHtBGQU2dbuMCGdaIvcbRBvM8AoqPh
         xpzp1YF8DyoAcY9lxqb/DL5XrPTRSb6z/WgYeMJq7K9kWtd5u/tSJUQgVHv6O+mhSzh+
         p1g3pqGNJR0R1ijarJJzhBviZqdyBDqQPDIqNtCi7GgidrxOU3GB1Ot2PeU0KVMk8TUa
         fH1e/h/E6ici6t5OuDWOYR0j0MpN4aF0bymNv3vx1GXMHUbnXA5VA9j1YKGeAsuqhth/
         6yqw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuaiFvIsO8C9e+bEwqDSfdWyN+UYxlKU5aCT3BQ5tKQgxH3dOpaK
	Semg7oXzOlRnozXFppCI49JJTadosfp2GNeGjWVAJwqXd6vav83fZ6F9VOKzBaePWVCOJ4hw9eU
	Z3PeFS9UEATQYrxpPTiMUxkGgFD78iKS6HjPXPJTr4yJLrRiFHW4hTs+oPoyPq8CELw==
X-Received: by 2002:ac8:160d:: with SMTP id p13mr24306443qtj.20.1550606733363;
        Tue, 19 Feb 2019 12:05:33 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ1ASiD79OnhW7aS9Yzcj/YL19108UPNpxc9o4ps1Dp4YHBCqPguIOJ52y62CtEiXmCclQN
X-Received: by 2002:ac8:160d:: with SMTP id p13mr24306104qtj.20.1550606728695;
        Tue, 19 Feb 2019 12:05:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550606728; cv=none;
        d=google.com; s=arc-20160816;
        b=L0APHqSGga0xsOvsrkxEnpP9J2RjSeemtzUl38N77/NrXmMTGu4ZibkhUeHi3LzVz3
         oa019aT4kKpC41q2S7GCBsPGHOQHYMHAbfHn0zVC4sGZ6AqnWv9sSKZW3b/6mvnjwdHX
         VYp2Ecale9UH6IaTtISk0pbbyBvn73BWsRZMlmfWzgqrzJVJtjssT+7kFwTbSFW1j/vL
         7BErV1+H1WSJVQWJPnHmL/ubQsdvhms8ArvmsjkPdpRX4n61XaKqYNLn9ItIfF/Ic4vv
         2eFglMB7EoCwd+ypfxxpW+Cc+XPHrDGkgMPplrj3JqAlhKqz8wGajeWTMJIiO8YXJVKM
         ym9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=/MIZcvQ73oHvyizAkMy4bbNGmjZ0HL1PlOjIuvQh24c=;
        b=HGLCQTQoftr9RDqvm5bMOfiXYk6WYLnMpHfHv8TOWNT6pso0jrQvKdDhh65hkHXA35
         cPnLzSTelfyiyIo6ez+6qdcMfsrKL2tNA2SODzBzi4/fmmL5O5vqtRwfWg5uq1g3cXkr
         rRQBzNlknOmhfdVwbnCJw00imOwNFdzfNPjddn9zZTvI6HHUO1/auZfdxJ8ZpxbIKCmA
         3SOiQFvIEQBzKRin4q7xkD+2TWYBYn0xouvAVgYFkI0oBkjQMokEH3iy5tcVjRtH5C2O
         BA22fwi4TmdS2yTGVx9w7qjgqcLvi4w9VEiRXPTg7y2eiAciJ9k5wDi11ao8xxs012mI
         X9vg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 23si289299qtr.57.2019.02.19.12.05.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 12:05:28 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A1534C074132;
	Tue, 19 Feb 2019 20:05:27 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-122-134.rdu2.redhat.com [10.10.122.134])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 05695600C8;
	Tue, 19 Feb 2019 20:05:21 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	=?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Jan Kara <jack@suse.cz>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Peter Xu <peterx@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ross Zwisler <zwisler@kernel.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	=?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	kvm@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	linux-rdma@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v5 6/9] mm/mmu_notifier: use correct mmu_notifier events for each invalidation
Date: Tue, 19 Feb 2019 15:04:27 -0500
Message-Id: <20190219200430.11130-7-jglisse@redhat.com>
In-Reply-To: <20190219200430.11130-1-jglisse@redhat.com>
References: <20190219200430.11130-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Tue, 19 Feb 2019 20:05:27 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

This update each existing invalidation to use the correct mmu notifier
event that represent what is happening to the CPU page table. See the
patch which introduced the events to see the rational behind this.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Christian König <christian.koenig@amd.com>
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: Jani Nikula <jani.nikula@linux.intel.com>
Cc: Rodrigo Vivi <rodrigo.vivi@intel.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Peter Xu <peterx@redhat.com>
Cc: Felix Kuehling <Felix.Kuehling@amd.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: Ross Zwisler <zwisler@kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Radim Krčmář <rkrcmar@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Christian Koenig <christian.koenig@amd.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: kvm@vger.kernel.org
Cc: dri-devel@lists.freedesktop.org
Cc: linux-rdma@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>
---
 fs/proc/task_mmu.c      |  4 ++--
 kernel/events/uprobes.c |  2 +-
 mm/huge_memory.c        | 14 ++++++--------
 mm/hugetlb.c            |  8 ++++----
 mm/khugepaged.c         |  2 +-
 mm/ksm.c                |  4 ++--
 mm/madvise.c            |  2 +-
 mm/memory.c             | 14 +++++++-------
 mm/migrate.c            |  4 ++--
 mm/mprotect.c           |  5 +++--
 mm/rmap.c               |  6 +++---
 11 files changed, 32 insertions(+), 33 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index fcbd0e574917..3b93ce496dd4 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1151,8 +1151,8 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 				break;
 			}
 
-			mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, 0,
-						NULL, mm, 0, -1UL);
+			mmu_notifier_range_init(&range, MMU_NOTIFY_SOFT_DIRTY,
+						0, NULL, mm, 0, -1UL);
 			mmu_notifier_invalidate_range_start(&range);
 		}
 		walk_page_range(0, mm->highest_vm_end, &clear_refs_walk);
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 46f546bdba00..8e8342080013 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -161,7 +161,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	struct mmu_notifier_range range;
 	struct mem_cgroup *memcg;
 
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, 0, vma, mm, addr,
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, vma, mm, addr,
 				addr + PAGE_SIZE);
 
 	VM_BUG_ON_PAGE(PageTransHuge(old_page), old_page);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index c9d638f1b34e..1da6ca0f0f6d 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1184,9 +1184,8 @@ static vm_fault_t do_huge_pmd_wp_page_fallback(struct vm_fault *vmf,
 		cond_resched();
 	}
 
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, 0, vma, vma->vm_mm,
-				haddr,
-				haddr + HPAGE_PMD_SIZE);
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, vma, vma->vm_mm,
+				haddr, haddr + HPAGE_PMD_SIZE);
 	mmu_notifier_invalidate_range_start(&range);
 
 	vmf->ptl = pmd_lock(vma->vm_mm, vmf->pmd);
@@ -1349,9 +1348,8 @@ vm_fault_t do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 				    vma, HPAGE_PMD_NR);
 	__SetPageUptodate(new_page);
 
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, 0, vma, vma->vm_mm,
-				haddr,
-				haddr + HPAGE_PMD_SIZE);
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, vma, vma->vm_mm,
+				haddr, haddr + HPAGE_PMD_SIZE);
 	mmu_notifier_invalidate_range_start(&range);
 
 	spin_lock(vmf->ptl);
@@ -2028,7 +2026,7 @@ void __split_huge_pud(struct vm_area_struct *vma, pud_t *pud,
 	spinlock_t *ptl;
 	struct mmu_notifier_range range;
 
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, 0, vma, vma->vm_mm,
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, vma, vma->vm_mm,
 				address & HPAGE_PUD_MASK,
 				(address & HPAGE_PUD_MASK) + HPAGE_PUD_SIZE);
 	mmu_notifier_invalidate_range_start(&range);
@@ -2247,7 +2245,7 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	spinlock_t *ptl;
 	struct mmu_notifier_range range;
 
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, 0, vma, vma->vm_mm,
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, vma, vma->vm_mm,
 				address & HPAGE_PMD_MASK,
 				(address & HPAGE_PMD_MASK) + HPAGE_PMD_SIZE);
 	mmu_notifier_invalidate_range_start(&range);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index d9e5c5a4c004..a58115c6b0a3 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3250,7 +3250,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 	cow = (vma->vm_flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
 
 	if (cow) {
-		mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, 0, vma, src,
+		mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, vma, src,
 					vma->vm_start,
 					vma->vm_end);
 		mmu_notifier_invalidate_range_start(&range);
@@ -3631,7 +3631,7 @@ static vm_fault_t hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 			    pages_per_huge_page(h));
 	__SetPageUptodate(new_page);
 
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, 0, vma, mm, haddr,
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, vma, mm, haddr,
 				haddr + huge_page_size(h));
 	mmu_notifier_invalidate_range_start(&range);
 
@@ -4357,8 +4357,8 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	 * start/end.  Set range.start/range.end to cover the maximum possible
 	 * range if PMD sharing is possible.
 	 */
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, 0, vma, mm, start,
-				end);
+	mmu_notifier_range_init(&range, MMU_NOTIFY_PROTECTION_VMA,
+				0, vma, mm, start, end);
 	adjust_range_if_pmd_sharing_possible(vma, &range.start, &range.end);
 
 	BUG_ON(address >= end);
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index e7944f5e6258..579699d2b347 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1016,7 +1016,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	pte = pte_offset_map(pmd, address);
 	pte_ptl = pte_lockptr(mm, pmd);
 
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, 0, NULL, mm,
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, NULL, mm,
 				address, address + HPAGE_PMD_SIZE);
 	mmu_notifier_invalidate_range_start(&range);
 	pmd_ptl = pmd_lock(mm, pmd); /* probably unnecessary */
diff --git a/mm/ksm.c b/mm/ksm.c
index 2ea25fc0befb..b782fadade8f 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1066,7 +1066,7 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 
 	BUG_ON(PageTransCompound(page));
 
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, 0, vma, mm,
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, vma, mm,
 				pvmw.address,
 				pvmw.address + PAGE_SIZE);
 	mmu_notifier_invalidate_range_start(&range);
@@ -1155,7 +1155,7 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 	if (!pmd)
 		goto out;
 
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, 0, vma, mm, addr,
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, vma, mm, addr,
 				addr + PAGE_SIZE);
 	mmu_notifier_invalidate_range_start(&range);
 
diff --git a/mm/madvise.c b/mm/madvise.c
index c617f53a9c09..a692d2a893b5 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -472,7 +472,7 @@ static int madvise_free_single_vma(struct vm_area_struct *vma,
 	range.end = min(vma->vm_end, end_addr);
 	if (range.end <= vma->vm_start)
 		return -EINVAL;
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, 0, vma, mm,
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, vma, mm,
 				range.start, range.end);
 
 	lru_add_drain();
diff --git a/mm/memory.c b/mm/memory.c
index 4565f636cca3..45dbc174a88c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1010,8 +1010,8 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	is_cow = is_cow_mapping(vma->vm_flags);
 
 	if (is_cow) {
-		mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, 0, vma,
-					src_mm, addr, end);
+		mmu_notifier_range_init(&range, MMU_NOTIFY_PROTECTION_PAGE,
+					0, vma, src_mm, addr, end);
 		mmu_notifier_invalidate_range_start(&range);
 	}
 
@@ -1358,7 +1358,7 @@ void zap_page_range(struct vm_area_struct *vma, unsigned long start,
 	struct mmu_gather tlb;
 
 	lru_add_drain();
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, 0, vma, vma->vm_mm,
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, vma, vma->vm_mm,
 				start, start + size);
 	tlb_gather_mmu(&tlb, vma->vm_mm, start, range.end);
 	update_hiwater_rss(vma->vm_mm);
@@ -1385,7 +1385,7 @@ static void zap_page_range_single(struct vm_area_struct *vma, unsigned long addr
 	struct mmu_gather tlb;
 
 	lru_add_drain();
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, 0, vma, vma->vm_mm,
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, vma, vma->vm_mm,
 				address, address + size);
 	tlb_gather_mmu(&tlb, vma->vm_mm, address, range.end);
 	update_hiwater_rss(vma->vm_mm);
@@ -2282,7 +2282,7 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
 
 	__SetPageUptodate(new_page);
 
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, 0, vma, mm,
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, vma, mm,
 				vmf->address & PAGE_MASK,
 				(vmf->address & PAGE_MASK) + PAGE_SIZE);
 	mmu_notifier_invalidate_range_start(&range);
@@ -4105,7 +4105,7 @@ static int __follow_pte_pmd(struct mm_struct *mm, unsigned long address,
 			goto out;
 
 		if (range) {
-			mmu_notifier_range_init(range, MMU_NOTIFY_UNMAP, 0,
+			mmu_notifier_range_init(range, MMU_NOTIFY_CLEAR, 0,
 						NULL, mm, address & PMD_MASK,
 						(address & PMD_MASK) + PMD_SIZE);
 			mmu_notifier_invalidate_range_start(range);
@@ -4124,7 +4124,7 @@ static int __follow_pte_pmd(struct mm_struct *mm, unsigned long address,
 		goto out;
 
 	if (range) {
-		mmu_notifier_range_init(range, MMU_NOTIFY_UNMAP, 0, NULL, mm,
+		mmu_notifier_range_init(range, MMU_NOTIFY_CLEAR, 0, NULL, mm,
 					address & PAGE_MASK,
 					(address & PAGE_MASK) + PAGE_SIZE);
 		mmu_notifier_invalidate_range_start(range);
diff --git a/mm/migrate.c b/mm/migrate.c
index 81eb307b2b5b..8e6d00541b3c 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2340,7 +2340,7 @@ static void migrate_vma_collect(struct migrate_vma *migrate)
 	mm_walk.mm = migrate->vma->vm_mm;
 	mm_walk.private = migrate;
 
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, 0, NULL, mm_walk.mm,
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, NULL, mm_walk.mm,
 				migrate->start,
 				migrate->end);
 	mmu_notifier_invalidate_range_start(&range);
@@ -2749,7 +2749,7 @@ static void migrate_vma_pages(struct migrate_vma *migrate)
 				notified = true;
 
 				mmu_notifier_range_init(&range,
-							MMU_NOTIFY_UNMAP, 0,
+							MMU_NOTIFY_CLEAR, 0,
 							NULL,
 							migrate->vma->vm_mm,
 							addr, migrate->end);
diff --git a/mm/mprotect.c b/mm/mprotect.c
index b10984052ae9..65242f1e4457 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -185,8 +185,9 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 
 		/* invoke the mmu notifier if the pmd is populated */
 		if (!range.start) {
-			mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, 0,
-						vma, vma->vm_mm, addr, end);
+			mmu_notifier_range_init(&range,
+				MMU_NOTIFY_PROTECTION_VMA, 0,
+				vma, vma->vm_mm, addr, end);
 			mmu_notifier_invalidate_range_start(&range);
 		}
 
diff --git a/mm/rmap.c b/mm/rmap.c
index c6535a6ec850..627b38ad5052 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -896,8 +896,8 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 	 * We have to assume the worse case ie pmd for invalidation. Note that
 	 * the page can not be free from this function.
 	 */
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, 0, vma, vma->vm_mm,
-				address,
+	mmu_notifier_range_init(&range, MMU_NOTIFY_PROTECTION_PAGE,
+				0, vma, vma->vm_mm, address,
 				min(vma->vm_end, address +
 				    (PAGE_SIZE << compound_order(page))));
 	mmu_notifier_invalidate_range_start(&range);
@@ -1372,7 +1372,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	 * Note that the page can not be free in this function as call of
 	 * try_to_unmap() must hold a reference on the page.
 	 */
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, 0, vma, vma->vm_mm,
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, vma, vma->vm_mm,
 				address,
 				min(vma->vm_end, address +
 				    (PAGE_SIZE << compound_order(page))));
-- 
2.17.2

