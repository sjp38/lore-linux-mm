Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 835B2C48BE0
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:23:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36F922084A
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:23:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36F922084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B44AB8E0006; Wed, 19 Jun 2019 22:23:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B1B7E8E0001; Wed, 19 Jun 2019 22:23:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A32268E0006; Wed, 19 Jun 2019 22:23:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 83EE18E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:23:30 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id l11so1635542qtp.22
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 19:23:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=nUliULzxns7pT1F4qCHDvBIX9vkZLQErhB7zoDHjDvo=;
        b=VZmAqLo/QPOcTxYTnoBx3koq7RjY6NHEX+PXpTqNeJ6ZqfkoBugasNiyn1l1xqHmWG
         ZbWRpYiaHCCnLjNDRPJsdkfBqIxxNDigWTZ8uCQIUnRkfS5T3opXDWzH6txB0MaSjdpi
         lGFRMAa9tOQvEOwoAYcBV3dqSa57BBzfQzn7TqkGWXnjQ1DtvdsO7+mqVJkI9RHfQCuW
         y35mvojSlPjsApJmWGKZS56b0vvJobWtg3WkgSwMIGOKLa2od7LqOmV/zfOgBswDt2ii
         UcETXiAeqFTvqjHDmwBiuqYv2xP9u4E8KQYl1GwWFt2All4j8t0xb5v4bE95zZARi6Ek
         /bng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUuEttHU3iED+psIrC7t7eU7UlI0U0eFwXXtYeH/mrNXnSd19Xz
	dQ7PcG1acY9hq1sAsVjJmvD/EjGg2s9XEXz29xSBxRtnb2wK9bBHED1sBHFo9e+fPUrgSbmfJfC
	I6Q33dbRmp1H7NrN7dKqf8niTEuha/C7qHwBK4dyLK+Fxk1DebwiOPBgviThoFEcPiw==
X-Received: by 2002:ac8:253d:: with SMTP id 58mr10852658qtm.40.1560997410300;
        Wed, 19 Jun 2019 19:23:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwdtL9XR/BHXnWV/PNKnIuCcvUUSpPmOXbqb3JOS6yiZCFeysuYo7q86by3rVj84lYozJKE
X-Received: by 2002:ac8:253d:: with SMTP id 58mr10852611qtm.40.1560997409408;
        Wed, 19 Jun 2019 19:23:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560997409; cv=none;
        d=google.com; s=arc-20160816;
        b=Zm170WEE8B/Ho6mEC5kY/rdqnet5OWb9HSkdOlsUxFe5EsoInCWpqve/iNJ0P06HBg
         XJvsP03Xu7tbXGEnDJqguYc9eVMVoRyNRSk8oau9uqtH8Zpi5+PbKjAkrhqQJxnSlgGY
         y/eqBCerxcL83OTW2y1rikq8qZ1YVF0E7bThx1uRgrfVtrNI7lLBJxwyHovYl9s4mU+C
         JYPej3xpY6AUpGF3p/n47IIFwJwJBQf0dlCUlYXVQrMWVRiSIDo+cRZ2hd76elr3o4Me
         wKi3Eom01DpMhH83LTem3T20tNa5ez413lV3iHxrw81Sl3rySPHR/NGbVw6RpnzmyrnK
         OxUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=nUliULzxns7pT1F4qCHDvBIX9vkZLQErhB7zoDHjDvo=;
        b=KOtKKzpmMVdKvl5+29t4rN9WZvauaQ5JVZaU/+hGisyeoloTXb6xROAAe5oyU7Fv3+
         Maompn1g1uNxbStwYtUq6+dwjMhhONP5bN2t3OyEmA137GrMNbX8kP5xiXZMSepLdwjE
         Dm/Xi1PkoP8Luxm1Liy9QaMSRHioBbKodUsCZLG4XzPO6w9DomZRT2rmzDgo31Y/46js
         HMJcoDaviZhXQsbwVUomuOexQ24ho431YDFFEVyEaRPb8PQvKoW1HnxzgabpDj6vsyqP
         yos+qEs7ObiqIfrzSJqtYk2EzPb2trKpWv7MsOfNpJZKTU3BnzKwIUVfK3yz2i3jcJca
         sYZw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a6si4073726qta.168.2019.06.19.19.23.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 19:23:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7284B30BB557;
	Thu, 20 Jun 2019 02:23:28 +0000 (UTC)
Received: from xz-x1.redhat.com (ovpn-12-78.pek2.redhat.com [10.72.12.78])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 287B51001E69;
	Thu, 20 Jun 2019 02:23:16 +0000 (UTC)
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
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Shaohua Li <shli@fb.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v5 15/25] userfaultfd: wp: support swap and page migration
Date: Thu, 20 Jun 2019 10:19:58 +0800
Message-Id: <20190620022008.19172-16-peterx@redhat.com>
In-Reply-To: <20190620022008.19172-1-peterx@redhat.com>
References: <20190620022008.19172-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Thu, 20 Jun 2019 02:23:28 +0000 (UTC)
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
index 757975920df8..eae25c58db9d 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2221,6 +2221,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 		write = is_write_migration_entry(entry);
 		young = false;
 		soft_dirty = pmd_swp_soft_dirty(old_pmd);
+		uffd_wp = pmd_swp_uffd_wp(old_pmd);
 	} else {
 		page = pmd_page(old_pmd);
 		if (pmd_dirty(old_pmd))
@@ -2253,6 +2254,8 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 			entry = swp_entry_to_pte(swp_entry);
 			if (soft_dirty)
 				entry = pte_swp_mksoft_dirty(entry);
+			if (uffd_wp)
+				entry = pte_swp_mkuffd_wp(entry);
 		} else {
 			entry = mk_pte(page + i, READ_ONCE(vma->vm_page_prot));
 			entry = maybe_mkwrite(entry, vma);
diff --git a/mm/memory.c b/mm/memory.c
index 8c69257d6ef1..28e9342d00cc 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -738,6 +738,8 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 				pte = swp_entry_to_pte(entry);
 				if (pte_swp_soft_dirty(*src_pte))
 					pte = pte_swp_mksoft_dirty(pte);
+				if (pte_swp_uffd_wp(*src_pte))
+					pte = pte_swp_mkuffd_wp(pte);
 				set_pte_at(src_mm, addr, src_pte, pte);
 			}
 		} else if (is_device_private_entry(entry)) {
@@ -767,6 +769,8 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 			    is_cow_mapping(vm_flags)) {
 				make_device_private_entry_read(&entry);
 				pte = swp_entry_to_pte(entry);
+				if (pte_swp_uffd_wp(*src_pte))
+					pte = pte_swp_mkuffd_wp(pte);
 				set_pte_at(src_mm, addr, src_pte, pte);
 			}
 		}
@@ -2930,6 +2934,10 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
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
index f2ecc2855a12..d8f1f6d13960 100644
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
index c7066d7384e3..a63737d9884e 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -139,11 +139,11 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
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
@@ -152,22 +152,28 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 				newpte = swp_entry_to_pte(entry);
 				if (pte_swp_soft_dirty(oldpte))
 					newpte = pte_swp_mksoft_dirty(newpte);
-				set_pte_at(vma->vm_mm, addr, pte, newpte);
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
-				set_pte_at(vma->vm_mm, addr, pte, newpte);
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
+				set_pte_at(vma->vm_mm, addr, pte, newpte);
 				pages++;
 			}
 		}
diff --git a/mm/rmap.c b/mm/rmap.c
index e5dfe2ae6b0d..dedde54dadb7 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1471,6 +1471,8 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			swp_pte = swp_entry_to_pte(entry);
 			if (pte_soft_dirty(pteval))
 				swp_pte = pte_swp_mksoft_dirty(swp_pte);
+			if (pte_uffd_wp(pteval))
+				swp_pte = pte_swp_mkuffd_wp(swp_pte);
 			set_pte_at(mm, pvmw.address, pvmw.pte, swp_pte);
 			/*
 			 * No need to invalidate here it will synchronize on
@@ -1563,6 +1565,8 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			swp_pte = swp_entry_to_pte(entry);
 			if (pte_soft_dirty(pteval))
 				swp_pte = pte_swp_mksoft_dirty(swp_pte);
+			if (pte_uffd_wp(pteval))
+				swp_pte = pte_swp_mkuffd_wp(swp_pte);
 			set_pte_at(mm, address, pvmw.pte, swp_pte);
 			/*
 			 * No need to invalidate here it will synchronize on
@@ -1629,6 +1633,8 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			swp_pte = swp_entry_to_pte(entry);
 			if (pte_soft_dirty(pteval))
 				swp_pte = pte_swp_mksoft_dirty(swp_pte);
+			if (pte_uffd_wp(pteval))
+				swp_pte = pte_swp_mkuffd_wp(swp_pte);
 			set_pte_at(mm, address, pvmw.pte, swp_pte);
 			/* Invalidate as we cleared the pte */
 			mmu_notifier_invalidate_range(mm, address,
-- 
2.21.0

