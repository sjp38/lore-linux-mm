Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 286E6C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:09:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC066217F4
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:09:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC066217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C1F86B0003; Tue, 19 Mar 2019 22:09:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 773296B000C; Tue, 19 Mar 2019 22:09:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 638076B0274; Tue, 19 Mar 2019 22:09:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3C9ED6B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 22:09:13 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id e25so19413692qkj.12
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:09:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=KfiR8hG7twEoGKvKf8wlozSQdGs9G3V4ZTs3Ue1pp5w=;
        b=mU7hkS0crM6xRjosQ+jMdIWtOZvhE0dmllUuWMfw7yl+8CTNflUHSG/LqUwkSmQnAs
         Ve941aBKTB1+N/Zu06aK2Sg+Yu+4dO+IqKQ6GBY0Gp5m8RLkgqI8LtR1eWBFA2EJ7TyP
         Q6qf94GwSMG5XHNV+PJGi2CWahDaBQbgmyjVV/Ihu/z+XLJ1OtsbAW+gWrYKIqgyPkmg
         LAXn+J3/Gk9KRIL5hOxDMNt1KR9HfaKgREtuWdPuccZfpFWWcNezk81p8tN0MbDVumGt
         D87Bj3YmkcLT+BZzd7v4TZBk0BWXHVCy8NG81g6hz+L8LJRW60qUH4ewr6e2I5rAuseV
         R/Jg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVWHVlkAuljiEZqBMNFEC3XiIMq1besNU0v3XepI2XKJLUmP9SD
	UdglyxrJtTa/NYIEpEzgaMkAB5PFbNn8lN3JF1WxkcONwLAC1JNYCVtFw34Wm5smZQJFso8w6Or
	cSRgHTiX5iO2sO2JaaNhAkpjCRFV7Cil/c6RXzo97SibfGWYGm60MM3WmZWyTvSv3YQ==
X-Received: by 2002:a37:c98e:: with SMTP id m14mr4274600qkl.274.1553047753029;
        Tue, 19 Mar 2019 19:09:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxfS33tXDr5XggEM40o3NhZXB8gRFWnPOVoBWSzKZ0KeKuoPzz884vqlywsb1J0GWJpUVM6
X-Received: by 2002:a37:c98e:: with SMTP id m14mr4274570qkl.274.1553047752194;
        Tue, 19 Mar 2019 19:09:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553047752; cv=none;
        d=google.com; s=arc-20160816;
        b=vhy9A+/yTON3R8uxF9/xKX78zWVkKfCUkgjF6vC2JhoWD/hryG4C0M28iE2Lz8USMR
         TKJHhkoSsJ/n7xBTuMM5umjgQ7w7hnZO+BS2pZqp8mCmD8VtV+mPmnb/niIky6qsL+Jy
         j3SNYC3iBEXEqhl3FQJmhfylC+YjPs3ssn7u5Kk6zPvtYme/2Sgw/erlEQbl2So/jT4s
         vnmOpISSu3nTMy7+dgoWtHE7/Tg+WHjDXISCpA1HUzCkUibgoKFCRBDWMHKiExZjIf1V
         gwV0pMwy8x+oCtwaV+wwhqsLgI1OSnMAyno2nsV7WwaCfJu/AWrD4TP9joy5LrkFZ7pA
         d93Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=KfiR8hG7twEoGKvKf8wlozSQdGs9G3V4ZTs3Ue1pp5w=;
        b=ABM07gCWpeU4ZwsUHaekgnb8+nsAfuk9RaClQlsTzw4T8cTqhVm2Hs7f2CK4Y3FwBY
         uYKR1BQFsyjR2QJlN/0yphGT1vBO/kYPPayQbAsMP1PJn1Q2MJ5ds+rpc4vVh7SZ8y9J
         bBWEpTJsBRpNI8QxrcXVVk5LzoGOsNKzQSkXARzcjdh2UBzON54bG7wGEw7MU48Jq4k9
         LNblqrG9kTM5knhDO2ui7M1rNLx18K8bnYwCVcU38Pp4L5KO0oF6Z19VIYb9+YNuTMZi
         K7ks+v+NK7skaXr2AvrmoGEmJlgGmcErlQ0OlkchdkVLSfK3ofsxSBmv/ekLiCtPwSZO
         H8tw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 25si406347qtq.283.2019.03.19.19.09.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 19:09:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4EA8F8553F;
	Wed, 20 Mar 2019 02:09:11 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 93CB46058F;
	Wed, 20 Mar 2019 02:09:05 +0000 (UTC)
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
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v3 17/28] userfaultfd: wp: support swap and page migration
Date: Wed, 20 Mar 2019 10:06:31 +0800
Message-Id: <20190320020642.4000-18-peterx@redhat.com>
In-Reply-To: <20190320020642.4000-1-peterx@redhat.com>
References: <20190320020642.4000-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Wed, 20 Mar 2019 02:09:11 +0000 (UTC)
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

Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 include/linux/swapops.h | 2 ++
 mm/huge_memory.c        | 3 +++
 mm/memory.c             | 6 ++++++
 mm/migrate.c            | 4 ++++
 mm/mprotect.c           | 2 ++
 mm/rmap.c               | 6 ++++++
 6 files changed, 23 insertions(+)

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
index 6405d56debee..c3d57fa890f2 100644
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
@@ -2825,6 +2827,10 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
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
index 181f5d2718a9..72cde187d4a1 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -241,6 +241,8 @@ static bool remove_migration_pte(struct page *page, struct vm_area_struct *vma,
 		entry = pte_to_swp_entry(*pvmw.pte);
 		if (is_write_migration_entry(entry))
 			pte = maybe_mkwrite(pte, vma);
+		else if (pte_swp_uffd_wp(*pvmw.pte))
+			pte = pte_mkuffd_wp(pte);
 
 		if (unlikely(is_zone_device_page(new))) {
 			if (is_device_private_page(new)) {
@@ -2301,6 +2303,8 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 			swp_pte = swp_entry_to_pte(entry);
 			if (pte_soft_dirty(pte))
 				swp_pte = pte_swp_mksoft_dirty(swp_pte);
+			if (pte_uffd_wp(pte))
+				swp_pte = pte_swp_mkuffd_wp(swp_pte);
 			set_pte_at(mm, addr, ptep, swp_pte);
 
 			/*
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 855dddb07ff2..96c0f521099d 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -196,6 +196,8 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
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

