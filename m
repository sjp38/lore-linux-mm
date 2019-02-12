Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2ED4BC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 03:00:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF98921773
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 03:00:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF98921773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 847BE8E01A9; Mon, 11 Feb 2019 22:00:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D1488E000E; Mon, 11 Feb 2019 22:00:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 672A68E01A9; Mon, 11 Feb 2019 22:00:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3851E8E000E
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 22:00:00 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id u32so1316819qte.1
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 19:00:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=kb1ebXpRqlyDe3Bcl80yjz2zx6M1w1j8ZoU2XgwL93g=;
        b=fxXvaGlbGLX+5DcrT7e8xSlAbCZE/7jZSzeIhiXuZUyPA1rhSlgz8hGSCTZI0AoVg1
         Y9Qbcov0G2mfOF4pAeAlg8hd+elPeqR34cqRMxmrmob1FlPm7AYpAfSRxi+GRhfs2eb0
         iH+/FIHuxtE2gPXLY2u5jJd2+X7QppfsmS/A8/FolLXGCqFLKnm927w4L/3UXMwMlwJj
         fr+LJMx8nrNyOqEc/PznPbFVh/MylQ8zxnC4+5dNOYozRoMEhnfjKuaOWFkV89TAD2G6
         pwmrcn+5eq7J2sKjv9hmniXeFmt/OGOwY3OZa1wJJ8dyzTqnsLx2lZCrQGjikzdADfVY
         WI6g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZEChdfbGB8uSE02EtKUUGVoVTmF56TnBqIn16tPsBPMT8FUEoV
	PAKQuqffwEENQZWPIw5hiafbWsr6vUPbHTihiHXe0j2gOfkDYVMah64kaSyp6F7bqVomoTNrZZP
	wgku6Mbw/Zk/hPFotG/4bFSyaw/ccozS8So3EbtYyyT0gpgT5+ZMeJlbmYZr2lQjVdA==
X-Received: by 2002:a37:2d02:: with SMTP id t2mr1031135qkh.82.1549940399966;
        Mon, 11 Feb 2019 18:59:59 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZabPf1sUXCNUJvXnY288sLd328B0kruNvmfxtX/rvPT106SQWoxBwFA1Q3C6kV1y/Qau54
X-Received: by 2002:a37:2d02:: with SMTP id t2mr1031107qkh.82.1549940399305;
        Mon, 11 Feb 2019 18:59:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549940399; cv=none;
        d=google.com; s=arc-20160816;
        b=VVv8hqUvjVdZCm/TUsfm/TJlv+cRecRUe9gl4Md76NFDLm9MpRofFzdkk+lnlMMlaM
         8s1LIVx11sFXkAKBJYdZPrFzAYisPTph2Rstbb8JT8/lo7UKfNU4dEXHOhjqVmY58Stk
         9JVtsrk6Kf6BK1tWW0a3Jzoy75MK6L+gpA67Vg4FzWuyMaJfR+nwIVIzgwLnwQQoown5
         6Nm6yVxQEspgrVPMaHbUSvzrPcC091x25xxiv4JcI2rl6xV4S9UsDww+dv3HlTCPVucC
         kGVzCYp1MFNz+UFh9SLJcwF9fv5xDd/oZ+ZzibBnqBfqfdXfzMEs1obPH8IpGA/M5gJC
         SN0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=kb1ebXpRqlyDe3Bcl80yjz2zx6M1w1j8ZoU2XgwL93g=;
        b=IxEAY084EX9fh1x9Sc5eLq2GMFXEn04kIfIPdkdVfEuxRCwJDDazqnGO3EpJm+xD2p
         LwZkBsigoatyxrbSNAh17HDlMnREvEiTRXkc+J0WiztI+oSiyrFMp6FvfjC4NyIk5Kdx
         yIbT3DPUokerP5fh8PCa1qpG1e2b94L6l0EvUAjohfBK8lNRbTSF0ydJZvEcjPq/irzI
         0eHnJB5RytaSECp1IRGaqIsr9pgQfrKxsbJQ8RwINiRbOU17BqSYSF7SHFWiUH+wre+R
         rThTu+JqIByGAvzEXDhDKq9KCb2uOT0SmY+sghovR9E8paRGfLouDaYNU7ChWVHENXlr
         R5MQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h12si8283878qto.184.2019.02.11.18.59.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 18:59:59 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5041080F90;
	Tue, 12 Feb 2019 02:59:58 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id BEA35600C6;
	Tue, 12 Feb 2019 02:59:47 +0000 (UTC)
From: Peter Xu <peterx@redhat.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	peterx@redhat.com,
	Martin Cracauer <cracauer@cons.org>,
	Shaohua Li <shli@fb.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v2 17/26] userfaultfd: wp: support swap and page migration
Date: Tue, 12 Feb 2019 10:56:23 +0800
Message-Id: <20190212025632.28946-18-peterx@redhat.com>
In-Reply-To: <20190212025632.28946-1-peterx@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Tue, 12 Feb 2019 02:59:58 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

For either swap and page migration, we all use the bit 2 of the entry to
identify whether this entry is uffd write-protected.  It plays a similar
role as the existing soft dirty bit in swap entries but only for keeping
the uffd-wp tracking for a specific PTE/PMD.

Something special here is that when we want to recover the uffd-wp bit
from a swap/migration entry to the PTE bit we'll also need to take care
of the _PAGE_RW bit and make sure it's cleared, otherwise even with the
_PAGE_UFFD_WP bit we can't trap it at all.

Note that this patch removed two lines from "userfaultfd: wp: hook
userfault handler to write protection fault" where we try to remove the
VM_FAULT_WRITE from vmf->flags when uffd-wp is set for the VMA.  This
patch will still keep the write flag there.

Signed-off-by: Peter Xu <peterx@redhat.com>
---
 include/linux/swapops.h | 2 ++
 mm/huge_memory.c        | 3 +++
 mm/memory.c             | 8 ++++++--
 mm/migrate.c            | 7 +++++++
 mm/mprotect.c           | 2 ++
 mm/rmap.c               | 6 ++++++
 6 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/include/linux/swapops.h b/include/linux/swapops.h
index 4d961668e5fc..0c2923b1cdb7 100644
--- a/include/linux/swapops.h
+++ b/include/linux/swapops.h
@@ -68,6 +68,8 @@ static inline swp_entry_t pte_to_swp_entry(pte_t pte)
 
 	if (pte_swp_soft_dirty(pte))
 		pte = pte_swp_clear_soft_dirty(pte);
+	if (pte_swp_uffd_wp(pte))
+		pte = pte_swp_clear_uffd_wp(pte);
 	arch_entry = __pte_to_swp_entry(pte);
 	return swp_entry(__swp_type(arch_entry), __swp_offset(arch_entry));
 }
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index fb2234cb595a..75de07141801 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2175,6 +2175,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 		write = is_write_migration_entry(entry);
 		young = false;
 		soft_dirty = pmd_swp_soft_dirty(old_pmd);
+		uffd_wp = pmd_swp_uffd_wp(old_pmd);
 	} else {
 		page = pmd_page(old_pmd);
 		if (pmd_dirty(old_pmd))
@@ -2207,6 +2208,8 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 			entry = swp_entry_to_pte(swp_entry);
 			if (soft_dirty)
 				entry = pte_swp_mksoft_dirty(entry);
+			if (uffd_wp)
+				entry = pte_swp_mkuffd_wp(entry);
 		} else {
 			entry = mk_pte(page + i, READ_ONCE(vma->vm_page_prot));
 			entry = maybe_mkwrite(entry, vma);
diff --git a/mm/memory.c b/mm/memory.c
index c2035539e9fd..7cee990d67cf 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -736,6 +736,8 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 				pte = swp_entry_to_pte(entry);
 				if (pte_swp_soft_dirty(*src_pte))
 					pte = pte_swp_mksoft_dirty(pte);
+				if (pte_swp_uffd_wp(*src_pte))
+					pte = pte_swp_mkuffd_wp(pte);
 				set_pte_at(src_mm, addr, src_pte, pte);
 			}
 		} else if (is_device_private_entry(entry)) {
@@ -2815,8 +2817,6 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
 	inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
 	dec_mm_counter_fast(vma->vm_mm, MM_SWAPENTS);
 	pte = mk_pte(page, vma->vm_page_prot);
-	if (userfaultfd_wp(vma))
-		vmf->flags &= ~FAULT_FLAG_WRITE;
 	if ((vmf->flags & FAULT_FLAG_WRITE) && reuse_swap_page(page, NULL)) {
 		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
 		vmf->flags &= ~FAULT_FLAG_WRITE;
@@ -2826,6 +2826,10 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
 	flush_icache_page(vma, page);
 	if (pte_swp_soft_dirty(vmf->orig_pte))
 		pte = pte_mksoft_dirty(pte);
+	if (pte_swp_uffd_wp(vmf->orig_pte)) {
+		pte = pte_mkuffd_wp(pte);
+		pte = pte_wrprotect(pte);
+	}
 	set_pte_at(vma->vm_mm, vmf->address, vmf->pte, pte);
 	arch_do_swap_page(vma->vm_mm, vma, vmf->address, pte, vmf->orig_pte);
 	vmf->orig_pte = pte;
diff --git a/mm/migrate.c b/mm/migrate.c
index d4fd680be3b0..605ccd1f5c64 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -242,6 +242,11 @@ static bool remove_migration_pte(struct page *page, struct vm_area_struct *vma,
 		if (is_write_migration_entry(entry))
 			pte = maybe_mkwrite(pte, vma);
 
+		if (pte_swp_uffd_wp(*pvmw.pte)) {
+			pte = pte_mkuffd_wp(pte);
+			pte = pte_wrprotect(pte);
+		}
+
 		if (unlikely(is_zone_device_page(new))) {
 			if (is_device_private_page(new)) {
 				entry = make_device_private_entry(new, pte_write(pte));
@@ -2290,6 +2295,8 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 			swp_pte = swp_entry_to_pte(entry);
 			if (pte_soft_dirty(pte))
 				swp_pte = pte_swp_mksoft_dirty(swp_pte);
+			if (pte_uffd_wp(pte))
+				swp_pte = pte_swp_mkuffd_wp(swp_pte);
 			set_pte_at(mm, addr, ptep, swp_pte);
 
 			/*
diff --git a/mm/mprotect.c b/mm/mprotect.c
index ae93721f3795..73a65f07fe41 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -187,6 +187,8 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 				newpte = swp_entry_to_pte(entry);
 				if (pte_swp_soft_dirty(oldpte))
 					newpte = pte_swp_mksoft_dirty(newpte);
+				if (pte_swp_uffd_wp(oldpte))
+					newpte = pte_swp_mkuffd_wp(newpte);
 				set_pte_at(mm, addr, pte, newpte);
 
 				pages++;
diff --git a/mm/rmap.c b/mm/rmap.c
index 0454ecc29537..3750d5a5283c 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1469,6 +1469,8 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			swp_pte = swp_entry_to_pte(entry);
 			if (pte_soft_dirty(pteval))
 				swp_pte = pte_swp_mksoft_dirty(swp_pte);
+			if (pte_uffd_wp(pteval))
+				swp_pte = pte_swp_mkuffd_wp(swp_pte);
 			set_pte_at(mm, pvmw.address, pvmw.pte, swp_pte);
 			/*
 			 * No need to invalidate here it will synchronize on
@@ -1561,6 +1563,8 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			swp_pte = swp_entry_to_pte(entry);
 			if (pte_soft_dirty(pteval))
 				swp_pte = pte_swp_mksoft_dirty(swp_pte);
+			if (pte_uffd_wp(pteval))
+				swp_pte = pte_swp_mkuffd_wp(swp_pte);
 			set_pte_at(mm, address, pvmw.pte, swp_pte);
 			/*
 			 * No need to invalidate here it will synchronize on
@@ -1627,6 +1631,8 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			swp_pte = swp_entry_to_pte(entry);
 			if (pte_soft_dirty(pteval))
 				swp_pte = pte_swp_mksoft_dirty(swp_pte);
+			if (pte_uffd_wp(pteval))
+				swp_pte = pte_swp_mkuffd_wp(swp_pte);
 			set_pte_at(mm, address, pvmw.pte, swp_pte);
 			/* Invalidate as we cleared the pte */
 			mmu_notifier_invalidate_range(mm, address,
-- 
2.17.1

