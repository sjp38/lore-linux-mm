Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20695C43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 22:58:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF0832084F
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 22:58:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="aSgS67XO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF0832084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36F1F6B0005; Thu, 25 Apr 2019 18:58:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2CE796B0006; Thu, 25 Apr 2019 18:58:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 198506B0007; Thu, 25 Apr 2019 18:58:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id E0CD26B0005
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 18:58:34 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id 81so639824vkn.19
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 15:58:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=Abdx1ueW6ffSY0bL+FYVJ9FzNWxLQwc/RZHTv7uW8qI=;
        b=BuRkR83U01ibrn8+Y3aW/nrX8QhULpoHy8mZJgkzTYMXFMYkhxp6nWiOmohYCUCOax
         /7FK02aFfaEV3DqlTWXHaG/MMD6iUiKneW7q83krHhu6wiNWyCJo+Pny5IqQ+9Qkp8nP
         9UnMrHrUh9kgOKyEpNaXUf7bEMZxq2fiSadG0zLO/OxOo+ONidgoECw+Opq97et5Vuk3
         LlvnhsGg0t5mcZX0UOTn8S/5zXtx0++HySTFlBFPsx8t8NoDeNKXX5+8gccJm0llh33q
         8rekZwrOdtSFMwYE6M8krbjy/rEhCJsALXcyGhsh/oIHxq7CI0pRWP56bhNGxeYeD01J
         3Lag==
X-Gm-Message-State: APjAAAX72RgjMVe6rpF4+kRFU2yHQry3ElCkVdra55Jao44Ap4YsxqvY
	uR3KkeEmWwjK4w21xVRFV5Zgj/EZf1f/Ty/9925xdkatUBf1qC2gx6nzGMERsCr2UwO5F3zsyn+
	UkW7MLX1yzsFskuXjjui7fupu9zT0YjfSdw30QQRUEq7Q+U+ZqFBebqkE4MZ9/RalenMWhQEK2v
	KcdRFoHLs5Nvplxrh4B4aTCYZOcpn5M+h2zyrImjzb2SrQkzPEvzEmXIvbFSYbJL6aR3LKGHdvn
	qy65xNuz2RcY3b8akxM/HRKGxTaTA==
X-Received: by 2002:ab0:6651:: with SMTP id b17mr8752625uaq.117.1556233114564;
        Thu, 25 Apr 2019 15:58:34 -0700 (PDT)
X-Received: by 2002:ab0:6651:: with SMTP id b17mr8752583uaq.117.1556233113270;
        Thu, 25 Apr 2019 15:58:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556233113; cv=none;
        d=google.com; s=arc-20160816;
        b=JaWHdGs2nYAL2nhLzwEokH97SauFjGPa5FCcVrEoFY8twJUNy3Bt8j0UKZ9g0Ombh/
         hA2q7ZO/XmDV6W6rPlo7n+VkD4wqEMcY2cXgvUtGJpIfAncEGn5uIVsiWCCrT3HnfO+C
         SKYZ0s17TERPDe3Ju5Ims1qL2e38deY2ZBmLpOkp7VkOwxwX7yoYjj9E7AEA8LmReRsi
         y4k7dK+drDJ49Pr54qLgOGTQYEwYEur6DZ2kAo19W8Wicq1Njy/yf17hJwvGmG8o/IPN
         PgRhpj8Uo14dIgbcWMJW+84WcyhGgV4guhRdbw3VtKRXSvlwE8ntgjJ5HvcwIrMhG9AH
         LCxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=Abdx1ueW6ffSY0bL+FYVJ9FzNWxLQwc/RZHTv7uW8qI=;
        b=ADXCEl9EDEc62LmXr9mjDCFQKGDqdVm1EuXtdnqvKEeM+E6M04TZnnYoEX7B6qew3z
         PnCbmO2MIRHmYdBrtA1BH4bGoyDDP9Az3KJQ/ZWIgYSj1UakBdAOFt8IRRus5ZA4aepb
         jVn518e8INUccxnrjO0XAKd5SxLuryA5hBHn4fEesyByA+lWgQ8A2NtrZxzG0N1jr4Ta
         89/JfA25xMH1LXMQIP5x0cZ2zH+KH2czFLeK/znuq0kc6G+3VtiuhaJB2CnWXXMC7rfr
         9VP6N1UFqZhyJCbTk/ElQmPmInTDrK3jT3q8Vy9FGQuqFJv9olJrjro02Q+7LcXXrzRv
         bj3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=aSgS67XO;
       spf=pass (google.com: domain of 3mdvcxa4kcaurfyymj1lfwwjyylttlqj.htrqnsz2-rrp0fhp.twl@flex--matthewgarrett.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3mDvCXA4KCAUrfyymj1lfwwjyylttlqj.htrqnsz2-rrp0fhp.twl@flex--matthewgarrett.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id j8sor3595381vsf.51.2019.04.25.15.58.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Apr 2019 15:58:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3mdvcxa4kcaurfyymj1lfwwjyylttlqj.htrqnsz2-rrp0fhp.twl@flex--matthewgarrett.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=aSgS67XO;
       spf=pass (google.com: domain of 3mdvcxa4kcaurfyymj1lfwwjyylttlqj.htrqnsz2-rrp0fhp.twl@flex--matthewgarrett.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3mDvCXA4KCAUrfyymj1lfwwjyylttlqj.htrqnsz2-rrp0fhp.twl@flex--matthewgarrett.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=Abdx1ueW6ffSY0bL+FYVJ9FzNWxLQwc/RZHTv7uW8qI=;
        b=aSgS67XOAM54g5xuWkWB37zmrTzUoPdGeyGkU+6kH09m0+aumfwEyH3Air+vnlmH5I
         DUm4278gRuPQ0lqHoDDEJjl8y/OyxQ5l11EsS0b5VdGp7l4gr1jziUmXSBlb7hTAZYVc
         WQkqpAj4N9zNYNrPEs4MOkz+HFkHOPdEX6xzNo8lv5ZIQjNMocwXIacMAac1yV80lzjj
         InAuRGuVW6zAEah2myD39jYNNK/KPpJw6imrXvSxhoGhkfnNNxdPk9vJpmVsg1lIfnCw
         PD0EFDR+m9hs3fxcr4o99oZPi//bJP2mrwj+XD7xIM7C2xf2RNFAx1mi1RyroVbKqCMe
         6z6Q==
X-Google-Smtp-Source: APXvYqwK8YzIE2mkuYhYmu8lk6jl2jh17uyHGveveocjH9AaidOoqScVYs6VQDqy2HdqKRdvY+hgHMxGWu/w+XCk+IDv+A==
X-Received: by 2002:a67:ba15:: with SMTP id l21mr23023847vsn.240.1556233112810;
 Thu, 25 Apr 2019 15:58:32 -0700 (PDT)
Date: Thu, 25 Apr 2019 15:58:28 -0700
In-Reply-To: <CACdnJuup-y1xAO93wr+nr6ARacxJ9YXgaceQK9TLktE7shab1w@mail.gmail.com>
Message-Id: <20190425225828.212472-1-matthewgarrett@google.com>
Mime-Version: 1.0
References: <CACdnJuup-y1xAO93wr+nr6ARacxJ9YXgaceQK9TLktE7shab1w@mail.gmail.com>
X-Mailer: git-send-email 2.21.0.593.g511ec345e18-goog
Subject: [PATCH V3] mm: Allow userland to request that the kernel clear memory
 on release
From: Matthew Garrett <matthewgarrett@google.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, 
	Matthew Garrett <mjg59@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Matthew Garrett <mjg59@google.com>

Applications that hold secrets and wish to avoid them leaking can use
mlock() to prevent the page from being pushed out to swap and
MADV_DONTDUMP to prevent it from being included in core dumps. Applications
can also use atexit() handlers to overwrite secrets on application exit.
However, if an attacker can reboot the system into another OS, they can
dump the contents of RAM and extract secrets. We can avoid this by setting
CONFIG_RESET_ATTACK_MITIGATION on UEFI systems in order to request that the
firmware wipe the contents of RAM before booting another OS, but this means
rebooting takes a *long* time - the expected behaviour is for a clean
shutdown to remove the request after scrubbing secrets from RAM in order to
avoid this.

Unfortunately, if an application exits uncleanly, its secrets may still be
present in RAM. This can't be easily fixed in userland (eg, if the OOM
killer decides to kill a process holding secrets, we're not going to be able
to avoid that), so this patch adds a new flag to madvise() to allow userland
to request that the kernel clear the covered pages whenever the page
map count hits zero. Since vm_flags is already full on 32-bit, it
will only work on 64-bit systems. This is currently only permitted on
private mappings that have not yet been populated in order to simplify
implementation, which should suffice for the envisaged use cases. We can
extend the behaviour later if we come up with a robust set of semantics.

Signed-off-by: Matthew Garrett <mjg59@google.com>
---

Updated based on feedback from Jann - for now let's just prevent setting
the flag on anything that has already mapped some pages, which avoids
child processes being able to interfere with the parent. In addition,
move the page clearing logic into page_remove_rmap() to ensure that we
cover the full set of cases (eg, handling page migration properly).

 include/linux/mm.h                     |  6 ++++++
 include/linux/rmap.h                   |  2 +-
 include/uapi/asm-generic/mman-common.h |  2 ++
 kernel/events/uprobes.c                |  2 +-
 mm/huge_memory.c                       | 12 ++++++------
 mm/hugetlb.c                           |  4 ++--
 mm/khugepaged.c                        |  2 +-
 mm/ksm.c                               |  2 +-
 mm/madvise.c                           | 25 +++++++++++++++++++++++++
 mm/memory.c                            |  6 +++---
 mm/migrate.c                           |  4 ++--
 mm/rmap.c                              |  9 +++++++--
 12 files changed, 57 insertions(+), 19 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6b10c21630f5..64bdab679275 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -257,6 +257,8 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_HIGH_ARCH_2	BIT(VM_HIGH_ARCH_BIT_2)
 #define VM_HIGH_ARCH_3	BIT(VM_HIGH_ARCH_BIT_3)
 #define VM_HIGH_ARCH_4	BIT(VM_HIGH_ARCH_BIT_4)
+
+#define VM_WIPEONRELEASE BIT(37)       /* Clear pages when releasing them */
 #endif /* CONFIG_ARCH_USES_HIGH_VMA_FLAGS */
 
 #ifdef CONFIG_ARCH_HAS_PKEYS
@@ -298,6 +300,10 @@ extern unsigned int kobjsize(const void *objp);
 # define VM_GROWSUP	VM_NONE
 #endif
 
+#ifndef VM_WIPEONRELEASE
+# define VM_WIPEONRELEASE VM_NONE
+#endif
+
 /* Bits set in the VMA until the stack is in its final location */
 #define VM_STACK_INCOMPLETE_SETUP	(VM_RAND_READ | VM_SEQ_READ)
 
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 988d176472df..abb47d623edd 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -177,7 +177,7 @@ void do_page_add_anon_rmap(struct page *, struct vm_area_struct *,
 void page_add_new_anon_rmap(struct page *, struct vm_area_struct *,
 		unsigned long, bool);
 void page_add_file_rmap(struct page *, bool);
-void page_remove_rmap(struct page *, bool);
+void page_remove_rmap(struct page *, struct vm_area_struct *, bool);
 
 void hugepage_add_anon_rmap(struct page *, struct vm_area_struct *,
 			    unsigned long);
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index abd238d0f7a4..82dfff4a8e3d 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -64,6 +64,8 @@
 #define MADV_WIPEONFORK 18		/* Zero memory on fork, child only */
 #define MADV_KEEPONFORK 19		/* Undo MADV_WIPEONFORK */
 
+#define MADV_WIPEONRELEASE 20
+#define MADV_DONTWIPEONRELEASE 21
 /* compatibility flags */
 #define MAP_FILE	0
 
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index c5cde87329c7..2230a1717fe3 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -196,7 +196,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	set_pte_at_notify(mm, addr, pvmw.pte,
 			mk_pte(new_page, vma->vm_page_prot));
 
-	page_remove_rmap(old_page, false);
+	page_remove_rmap(old_page, vma, false);
 	if (!page_mapped(old_page))
 		try_to_free_swap(old_page);
 	page_vma_mapped_walk_done(&pvmw);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 165ea46bf149..1ad6ee5857b7 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1260,7 +1260,7 @@ static vm_fault_t do_huge_pmd_wp_page_fallback(struct vm_fault *vmf,
 
 	smp_wmb(); /* make pte visible before pmd */
 	pmd_populate(vma->vm_mm, vmf->pmd, pgtable);
-	page_remove_rmap(page, true);
+	page_remove_rmap(page, vma, true);
 	spin_unlock(vmf->ptl);
 
 	/*
@@ -1410,7 +1410,7 @@ vm_fault_t do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 			add_mm_counter(vma->vm_mm, MM_ANONPAGES, HPAGE_PMD_NR);
 		} else {
 			VM_BUG_ON_PAGE(!PageHead(page), page);
-			page_remove_rmap(page, true);
+			page_remove_rmap(page, vma, true);
 			put_page(page);
 		}
 		ret |= VM_FAULT_WRITE;
@@ -1783,7 +1783,7 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 
 		if (pmd_present(orig_pmd)) {
 			page = pmd_page(orig_pmd);
-			page_remove_rmap(page, true);
+			page_remove_rmap(page, vma, true);
 			VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
 			VM_BUG_ON_PAGE(!PageHead(page), page);
 		} else if (thp_migration_supported()) {
@@ -2146,7 +2146,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 			set_page_dirty(page);
 		if (!PageReferenced(page) && pmd_young(_pmd))
 			SetPageReferenced(page);
-		page_remove_rmap(page, true);
+		page_remove_rmap(page, vma, true);
 		put_page(page);
 		add_mm_counter(mm, mm_counter_file(page), -HPAGE_PMD_NR);
 		return;
@@ -2266,7 +2266,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 
 	if (freeze) {
 		for (i = 0; i < HPAGE_PMD_NR; i++) {
-			page_remove_rmap(page + i, false);
+			page_remove_rmap(page + i, vma, false);
 			put_page(page + i);
 		}
 	}
@@ -2954,7 +2954,7 @@ void set_pmd_migration_entry(struct page_vma_mapped_walk *pvmw,
 	if (pmd_soft_dirty(pmdval))
 		pmdswp = pmd_swp_mksoft_dirty(pmdswp);
 	set_pmd_at(mm, address, pvmw->pmd, pmdswp);
-	page_remove_rmap(page, true);
+	page_remove_rmap(page, vma, true);
 	put_page(page);
 }
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 6cdc7b2d9100..1df046525861 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3419,7 +3419,7 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			set_page_dirty(page);
 
 		hugetlb_count_sub(pages_per_huge_page(h), mm);
-		page_remove_rmap(page, true);
+		page_remove_rmap(page, vma, true);
 
 		spin_unlock(ptl);
 		tlb_remove_page_size(tlb, page, huge_page_size(h));
@@ -3643,7 +3643,7 @@ static vm_fault_t hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 		mmu_notifier_invalidate_range(mm, range.start, range.end);
 		set_huge_pte_at(mm, haddr, ptep,
 				make_huge_pte(vma, new_page, 1));
-		page_remove_rmap(old_page, true);
+		page_remove_rmap(old_page, vma, true);
 		hugepage_add_new_anon_rmap(new_page, vma, haddr);
 		set_page_huge_active(new_page);
 		/* Make the old page be freed below */
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 449044378782..20df74dfd954 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -673,7 +673,7 @@ static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
 			 * superfluous.
 			 */
 			pte_clear(vma->vm_mm, address, _pte);
-			page_remove_rmap(src_page, false);
+			page_remove_rmap(src_page, vma, false);
 			spin_unlock(ptl);
 			free_page_and_swap_cache(src_page);
 		}
diff --git a/mm/ksm.c b/mm/ksm.c
index fc64874dc6f4..280705f65af7 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1193,7 +1193,7 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 	ptep_clear_flush(vma, addr, ptep);
 	set_pte_at_notify(mm, addr, ptep, newpte);
 
-	page_remove_rmap(page, false);
+	page_remove_rmap(page, vma, false);
 	if (!page_mapped(page))
 		try_to_free_swap(page);
 	put_page(page);
diff --git a/mm/madvise.c b/mm/madvise.c
index 21a7881a2db4..2a6e616e5c0d 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -92,6 +92,26 @@ static long madvise_behavior(struct vm_area_struct *vma,
 	case MADV_KEEPONFORK:
 		new_flags &= ~VM_WIPEONFORK;
 		break;
+	case MADV_WIPEONRELEASE:
+		/*
+		 * MADV_WIPEONRELEASE is only supported on as-yet unallocated
+		 * anonymous memory.
+		 */
+		if (VM_WIPEONRELEASE == 0 || vma->vm_file || vma->anon_vma ||
+		    vma->vm_flags & VM_SHARED) {
+			error = -EINVAL;
+			goto out;
+		}
+
+		new_flags |= VM_WIPEONRELEASE;
+		break;
+	case MADV_DONTWIPEONRELEASE:
+		if (VM_WIPEONRELEASE == 0) {
+			error = -EINVAL;
+			goto out;
+		}
+		new_flags &= ~VM_WIPEONRELEASE;
+		break;
 	case MADV_DONTDUMP:
 		new_flags |= VM_DONTDUMP;
 		break;
@@ -727,6 +747,8 @@ madvise_behavior_valid(int behavior)
 	case MADV_DODUMP:
 	case MADV_WIPEONFORK:
 	case MADV_KEEPONFORK:
+	case MADV_WIPEONRELEASE:
+	case MADV_DONTWIPEONRELEASE:
 #ifdef CONFIG_MEMORY_FAILURE
 	case MADV_SOFT_OFFLINE:
 	case MADV_HWPOISON:
@@ -785,6 +807,9 @@ madvise_behavior_valid(int behavior)
  *  MADV_DONTDUMP - the application wants to prevent pages in the given range
  *		from being included in its core dump.
  *  MADV_DODUMP - cancel MADV_DONTDUMP: no longer exclude from core dump.
+ *  MADV_WIPEONRELEASE - clear the contents of the memory after the last
+ *		reference to it has been released
+ *  MADV_DONTWIPEONRELEASE - cancel MADV_WIPEONRELEASE
  *
  * return values:
  *  zero    - success
diff --git a/mm/memory.c b/mm/memory.c
index ab650c21bccd..dd9555bb9aec 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1088,7 +1088,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 					mark_page_accessed(page);
 			}
 			rss[mm_counter(page)]--;
-			page_remove_rmap(page, false);
+			page_remove_rmap(page, vma, false);
 			if (unlikely(page_mapcount(page) < 0))
 				print_bad_pte(vma, addr, ptent, page);
 			if (unlikely(__tlb_remove_page(tlb, page))) {
@@ -1116,7 +1116,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 
 			pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
 			rss[mm_counter(page)]--;
-			page_remove_rmap(page, false);
+			page_remove_rmap(page, vma, false);
 			put_page(page);
 			continue;
 		}
@@ -2340,7 +2340,7 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
 			 * mapcount is visible. So transitively, TLBs to
 			 * old page will be flushed before it can be reused.
 			 */
-			page_remove_rmap(old_page, false);
+			page_remove_rmap(old_page, vma, false);
 		}
 
 		/* Free the old page.. */
diff --git a/mm/migrate.c b/mm/migrate.c
index 663a5449367a..5d3437a6541d 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2083,7 +2083,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 
 	page_ref_unfreeze(page, 2);
 	mlock_migrate_page(new_page, page);
-	page_remove_rmap(page, true);
+	page_remove_rmap(page, vma, true);
 	set_page_owner_migrate_reason(new_page, MR_NUMA_MISPLACED);
 
 	spin_unlock(ptl);
@@ -2313,7 +2313,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 			 * drop page refcount. Page won't be freed, as we took
 			 * a reference just above.
 			 */
-			page_remove_rmap(page, false);
+			page_remove_rmap(page, vma, false);
 			put_page(page);
 
 			if (pte_present(pte))
diff --git a/mm/rmap.c b/mm/rmap.c
index b30c7c71d1d9..46dc9946a516 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1292,11 +1292,13 @@ static void page_remove_anon_compound_rmap(struct page *page)
 /**
  * page_remove_rmap - take down pte mapping from a page
  * @page:	page to remove mapping from
+ * @vma:	VMA the page belongs to
  * @compound:	uncharge the page as compound or small page
  *
  * The caller needs to hold the pte lock.
  */
-void page_remove_rmap(struct page *page, bool compound)
+void page_remove_rmap(struct page *page, struct vm_area_struct *vma,
+		      bool compound)
 {
 	if (!PageAnon(page))
 		return page_remove_file_rmap(page, compound);
@@ -1321,6 +1323,9 @@ void page_remove_rmap(struct page *page, bool compound)
 	if (PageTransCompound(page))
 		deferred_split_huge_page(compound_head(page));
 
+	if (unlikely(vma->vm_flags & VM_WIPEONRELEASE))
+		clear_highpage(page);
+
 	/*
 	 * It would be tidy to reset the PageAnon mapping here,
 	 * but that might overwrite a racing page_add_anon_rmap
@@ -1652,7 +1657,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		 *
 		 * See Documentation/vm/mmu_notifier.rst
 		 */
-		page_remove_rmap(subpage, PageHuge(page));
+		page_remove_rmap(subpage, vma, PageHuge(page));
 		put_page(page);
 	}
 
-- 
2.21.0.593.g511ec345e18-goog

