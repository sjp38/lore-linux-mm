Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58054C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:54:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 138632077B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:54:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 138632077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A2C306B0279; Fri, 26 Apr 2019 00:54:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DA6B6B027A; Fri, 26 Apr 2019 00:54:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F0636B027B; Fri, 26 Apr 2019 00:54:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6FC306B0279
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:54:30 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id k6so1839801qkf.13
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 21:54:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=XOSlci1dq3CxVK30ZuotdjWSgcs2dSvqE9xrxT37Oio=;
        b=bP83kyCtzn9c+ZKZdS8isoMaCBx7I0MBTGRWl3zeN+85sLsNNgQo5GEmC8I41Nkz5C
         jfVWq3tuyILVa/CJGvrENV6rRRD1U0LYm05gmGNeBkiEuVn+r07S52BnsZi/TgzKe7ap
         VChKB8hG3G6hxhkceNKzo8b5fBx3oTqNATwqCPZqTy5gpjCz8t3zvJFi4OTxyfCRs/cd
         xMgH8Bgzn998reaHl+q6r676Kg8+N+Z5OCClLy7pQjJxsVDg8cd+ZlBwtdjhaChbNCmu
         YY1oEfhirlQ75+8EuxtQpT7sfcMCS9SgL2k1aseRX1ABwOZVe06WMLiLoya/QsQLwvBX
         6i0w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVHltf1wsu6ptSMON2OQxxTDMsbDDPvZH24x1awjn3St1YWif2T
	d0Y11UEVk3+qqDzq6sE2rbb1Zon52zIPLMO92EPntzNHg3Q6/bQ/RGpdPRoT+Vk3htA+rgHbE4l
	PzB7fYnFUjTRiTbv6DrNWO8eOAZ8JOpSmmmhRTw3HOsqx0SdvnQ6fSAxtV6W57DCAbg==
X-Received: by 2002:ac8:304f:: with SMTP id g15mr15204226qte.306.1556254470223;
        Thu, 25 Apr 2019 21:54:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyqVXq7PawpgyLeUD6xDouKSIxipG71+8WoqpxnletcF5os8W2bZNpiVpE4NabMEkI2u7qo
X-Received: by 2002:ac8:304f:: with SMTP id g15mr15204186qte.306.1556254469340;
        Thu, 25 Apr 2019 21:54:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556254469; cv=none;
        d=google.com; s=arc-20160816;
        b=z/ogjw692jP6QDwMMP0QGgl2EqTpZVpTXV0StMUr8mVSOMFOH1LSNc0xTky80ZWhda
         T55BB6LqZ1Ma98Uy6n1Svau46C/auErWd+K+ikPHe7ips3hZHDefH/NfXS1yRtn3nQxM
         8P79XgIEbLA0OJ006T3OL8GlQgeNHA0gvijL5wO9D26aAS3rJlBp6jS5XUhfcW5LmN7h
         pGrZ2YwCPOUUb/tIjqdwpeMcMFrHGCZ1822K6mtEu8+Hh6GXPWbtitmWpGIA/m2n0iG0
         zzkRQbh1ayc2p1s6/eli9WzRGvcN2Zbii566Ox4YHL3SQgDBTRv2lVVv934ONd26Bq2l
         JfpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=XOSlci1dq3CxVK30ZuotdjWSgcs2dSvqE9xrxT37Oio=;
        b=yiL/4Nt9LiQdHq/CyOGcfcSpnsbEatmZXKE6x0higWbcBU64K3d3yVK3KyoA44zB2w
         47HV5rvyfKHjc289FMWciDrossXvVIIvxaQL0uRHNyCTa9781pdTZ08kytpRUfx0HCOT
         T8bmvloyUAmOgYRXAd6YpJiKHVBxYM5QUeWcjJ1QocnSPRedbLyEzWiXRUFGYDjDsgK3
         R8zhIv7RPaYCKYhwcljDVk+smrGnt+WU6fLzzbsuPn4eG9J/UxV3YVI8JcG0B39dqQye
         rNPGpJR1apSyJWSmOk2Gu35mYzZAJnk1CU383bJbuCx3ceqwByTg4OWGSYpL58r1hOny
         s9Mw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c20si4186205qkb.236.2019.04.25.21.54.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 21:54:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 710FF308425B;
	Fri, 26 Apr 2019 04:54:28 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-15-205.nay.redhat.com [10.66.15.205])
	by smtp.corp.redhat.com (Postfix) with ESMTP id D580D17B21;
	Fri, 26 Apr 2019 04:54:22 +0000 (UTC)
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
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v4 17/27] userfaultfd: wp: support swap and page migration
Date: Fri, 26 Apr 2019 12:51:41 +0800
Message-Id: <20190426045151.19556-18-peterx@redhat.com>
In-Reply-To: <20190426045151.19556-1-peterx@redhat.com>
References: <20190426045151.19556-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Fri, 26 Apr 2019 04:54:28 +0000 (UTC)
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

In change_pte_range() we do nothing for uffd if the PTE is a swap
entry.  That can lead to data mismatch if the page that we are going
to write protect is swapped out when sending the UFFDIO_WRITEPROTECT.
This patch also applies/removes the uffd-wp bit even for the swap
entries.

Signed-off-by: Peter Xu <peterx@redhat.com>
---
 include/linux/swapops.h |  2 ++
 mm/huge_memory.c        |  3 +++
 mm/memory.c             |  8 ++++++++
 mm/migrate.c            |  6 ++++++
 mm/mprotect.c           | 28 +++++++++++++++++-----------
 mm/rmap.c               |  6 ++++++
 6 files changed, 42 insertions(+), 11 deletions(-)

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
index cf8f11d6e6cd..998a7e5d625e 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2212,6 +2212,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 		write = is_write_migration_entry(entry);
 		young = false;
 		soft_dirty = pmd_swp_soft_dirty(old_pmd);
+		uffd_wp = pmd_swp_uffd_wp(old_pmd);
 	} else {
 		page = pmd_page(old_pmd);
 		if (pmd_dirty(old_pmd))
@@ -2244,6 +2245,8 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 			entry = swp_entry_to_pte(swp_entry);
 			if (soft_dirty)
 				entry = pte_swp_mksoft_dirty(entry);
+			if (uffd_wp)
+				entry = pte_swp_mkuffd_wp(entry);
 		} else {
 			entry = mk_pte(page + i, READ_ONCE(vma->vm_page_prot));
 			entry = maybe_mkwrite(entry, vma);
diff --git a/mm/memory.c b/mm/memory.c
index 2abf0934ad7f..f53f54592ddc 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -737,6 +737,8 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 				pte = swp_entry_to_pte(entry);
 				if (pte_swp_soft_dirty(*src_pte))
 					pte = pte_swp_mksoft_dirty(pte);
+				if (pte_swp_uffd_wp(*src_pte))
+					pte = pte_swp_mkuffd_wp(pte);
 				set_pte_at(src_mm, addr, src_pte, pte);
 			}
 		} else if (is_device_private_entry(entry)) {
@@ -766,6 +768,8 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 			    is_cow_mapping(vm_flags)) {
 				make_device_private_entry_read(&entry);
 				pte = swp_entry_to_pte(entry);
+				if (pte_swp_uffd_wp(*src_pte))
+					pte = pte_swp_mkuffd_wp(pte);
 				set_pte_at(src_mm, addr, src_pte, pte);
 			}
 		}
@@ -2854,6 +2858,10 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
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
index 663a5449367a..deff1f8c20af 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -241,11 +241,15 @@ static bool remove_migration_pte(struct page *page, struct vm_area_struct *vma,
 		entry = pte_to_swp_entry(*pvmw.pte);
 		if (is_write_migration_entry(entry))
 			pte = maybe_mkwrite(pte, vma);
+		else if (pte_swp_uffd_wp(*pvmw.pte))
+			pte = pte_mkuffd_wp(pte);
 
 		if (unlikely(is_zone_device_page(new))) {
 			if (is_device_private_page(new)) {
 				entry = make_device_private_entry(new, pte_write(pte));
 				pte = swp_entry_to_pte(entry);
+				if (pte_swp_uffd_wp(*pvmw.pte))
+					pte = pte_mkuffd_wp(pte);
 			} else if (is_device_public_page(new)) {
 				pte = pte_mkdevmap(pte);
 			}
@@ -2306,6 +2310,8 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 			swp_pte = swp_entry_to_pte(entry);
 			if (pte_soft_dirty(pte))
 				swp_pte = pte_swp_mksoft_dirty(swp_pte);
+			if (pte_uffd_wp(pte))
+				swp_pte = pte_swp_mkuffd_wp(swp_pte);
 			set_pte_at(mm, addr, ptep, swp_pte);
 
 			/*
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 1f40662182f8..adc054d38f89 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -174,11 +174,11 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 			}
 			ptep_modify_prot_commit(vma, addr, pte, oldpte, ptent);
 			pages++;
-		} else if (IS_ENABLED(CONFIG_MIGRATION)) {
+		} else if (is_swap_pte(oldpte)) {
 			swp_entry_t entry = pte_to_swp_entry(oldpte);
+			pte_t newpte;
 
 			if (is_write_migration_entry(entry)) {
-				pte_t newpte;
 				/*
 				 * A protection check is difficult so
 				 * just be safe and disable write
@@ -187,22 +187,28 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 				newpte = swp_entry_to_pte(entry);
 				if (pte_swp_soft_dirty(oldpte))
 					newpte = pte_swp_mksoft_dirty(newpte);
-				set_pte_at(mm, addr, pte, newpte);
-
-				pages++;
-			}
-
-			if (is_write_device_private_entry(entry)) {
-				pte_t newpte;
-
+				if (pte_swp_uffd_wp(oldpte))
+					newpte = pte_swp_mkuffd_wp(newpte);
+			} else if (is_write_device_private_entry(entry)) {
 				/*
 				 * We do not preserve soft-dirtiness. See
 				 * copy_one_pte() for explanation.
 				 */
 				make_device_private_entry_read(&entry);
 				newpte = swp_entry_to_pte(entry);
-				set_pte_at(mm, addr, pte, newpte);
+				if (pte_swp_uffd_wp(oldpte))
+					newpte = pte_swp_mkuffd_wp(newpte);
+			} else {
+				newpte = oldpte;
+			}
 
+			if (uffd_wp)
+				newpte = pte_swp_mkuffd_wp(newpte);
+			else if (uffd_wp_resolve)
+				newpte = pte_swp_clear_uffd_wp(newpte);
+
+			if (!pte_same(oldpte, newpte)) {
+				set_pte_at(mm, addr, pte, newpte);
 				pages++;
 			}
 		}
diff --git a/mm/rmap.c b/mm/rmap.c
index b30c7c71d1d9..0b2e2f74b477 100644
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

