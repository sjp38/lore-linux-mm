Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 742F5C04AA6
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 19:36:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D40AE2075E
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 19:36:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="p69iggOB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D40AE2075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D2026B0003; Mon, 29 Apr 2019 15:36:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 682986B0005; Mon, 29 Apr 2019 15:36:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 54A736B0007; Mon, 29 Apr 2019 15:36:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 11DA36B0003
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 15:36:38 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id a141so6123649pfa.13
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 12:36:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=X6f+4s58WTDJby6OmhMjz6wRTrpP4TIKCNCrLqFCf4w=;
        b=aQm2DIME0WZWHFsJCtOyADIIyiOEbAVdhjZiwyVEHwtzBbhtMxn8MJe9ng2k0JPQiI
         goyEUx30M8Zl7N1LPj68vfW6WJSY+/nQzg84hmXLYcpYja5tRnO1TqQHtSbOJCXCCnnI
         id9Q4KIO/88HL1+AybslvmM4jFTY400lP3yKUsQZd2wGR3qs1E/MW/P4sAB7VbgZHwg3
         EEADyu8I198Sm7kR2vxF/4XvFxyTPPOBeK6lVfLbFD/KsvgYv/QxnZtTS/BWLxgwgpVt
         lnSVPdz1cZ/WXlZSi8lGFdTRhtQSbJasgLQznwjLeFwmXceWZg3zqWm/5TGJPzHw2Ppl
         6i7A==
X-Gm-Message-State: APjAAAVuooxu2cb6isR/P5dVkuALuVFwwZPpILvIRXQIM8aMAs2ti9k+
	ImR9n9Mtv5SE2vAHIrw0rvDpiUijtDiYxOWaSSLJHJCinpLMl3X8nWGhpoaZc4EEPIY2T81ARz8
	zh9fWDzuJD1sQrdd4M85XGWrbWDzpwPyEncqUI57yNpvT8Yf0ejvTnzm8iR0o/fbvq45SQC6GHJ
	OfkOgj+/JCVg9JFLN5wurCVaw2XAKQx2/lXIUeOg2ifBDdk1tA7r82XljPzOij6zCk7/YXgeEiN
	Wwiq8xuAcc76cVcH38TlokCqDr98w==
X-Received: by 2002:a17:902:1602:: with SMTP id g2mr64104967plg.325.1556566597670;
        Mon, 29 Apr 2019 12:36:37 -0700 (PDT)
X-Received: by 2002:a17:902:1602:: with SMTP id g2mr64104806plg.325.1556566595877;
        Mon, 29 Apr 2019 12:36:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556566595; cv=none;
        d=google.com; s=arc-20160816;
        b=YHGUyAIVUZIGu3FggHV6qSuBsu3pNJbtrImCzQ6lJmbNc+V7bnCJjSSBWtP9gNSByo
         mkXsIl33swAmLrQIhDHdtE3W3FPuVwDIZ5WGXi9l4UjcMSIzrqAJr8A5HOIJqCxSErYM
         4a7q0POad6KEo2abekgtgp1d8IFwdHnHCxcY1n4dV/hNc/AP/8QrxSrW13vPDGHT5dHb
         LZcgqiyvk1R0ThjBCwYJykOpdm6eGBLIxjWnYXFgF0Wo0diI6r8GItPknmLrs7XWzwPX
         H/NvHa849ZAhTOvyUOWoYjP6XDb5H0RoLJ4KRhxn1Nit+yiB+6vZtEHrOVl5jBRSsnBR
         hT8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=X6f+4s58WTDJby6OmhMjz6wRTrpP4TIKCNCrLqFCf4w=;
        b=rzDguWalcTaydQ/dN7hUCpWIN9ClLPB4Wa31O4ZUAkLSNTZIX31oLbih7x2adsbTIz
         tNxsqTYmNjoDltaUKXzhY+irqSBFZdKk7NwIFCF/A8BtM0X1cs302jUT2gzIQ5EOTO6k
         9QUvqsn9nh6IUQ2Jr/v7eV0Vkh6nR3fByv6RU2U0/DOmmdUq/XN2TMTnZqMQlQ+oHbcZ
         WzMJGZ9BYzhmUccN3TxLAqQdP7pEFTiDwgc/Z45JsqYoHE7mN0S5B27myrPIEktqKUXC
         tcYFqyjphvIza/59NMMZby6m0Cw3p75KS0dkuglyrn3Dm26c4+Du2EyTc6aCOJs2Qm97
         sBWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=p69iggOB;
       spf=pass (google.com: domain of 3qllhxa4kco8drkkyvnxriivkkxffxcv.tfdczelo-ddbmrtb.fix@flex--matthewgarrett.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3QlLHXA4KCO8dRkkYVnXRiiVkkXffXcV.TfdcZelo-ddbmRTb.fiX@flex--matthewgarrett.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id l9sor9449631pgq.46.2019.04.29.12.36.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Apr 2019 12:36:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3qllhxa4kco8drkkyvnxriivkkxffxcv.tfdczelo-ddbmrtb.fix@flex--matthewgarrett.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=p69iggOB;
       spf=pass (google.com: domain of 3qllhxa4kco8drkkyvnxriivkkxffxcv.tfdczelo-ddbmrtb.fix@flex--matthewgarrett.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3QlLHXA4KCO8dRkkYVnXRiiVkkXffXcV.TfdcZelo-ddbmRTb.fiX@flex--matthewgarrett.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=X6f+4s58WTDJby6OmhMjz6wRTrpP4TIKCNCrLqFCf4w=;
        b=p69iggOBexUOxBUtqPOdEYxx/Q/Qb0KJ7EJl6G+KWHh4qvn+qEN+lh3bfVMERgPCFf
         0xdtEAksGjNrkRUvOUShzWjAV00kXk216Mk+pT20Mb6piBS3EtybCBDJBXXICSJaGNGs
         uNmT4YjOydxv3TUaCOCif4kIt2CP+lV6/DrmdWc4wEuSlGk4zDEhKaKKfG5BiPKoZYNc
         4DL0isJ0zS3QbCU5fzRKCyhNIlJNAUNdJrqbyUXkkPeY5aK2cwz81k0shlwoW6ODR7oN
         y6tJlTWY1vJ5blzRTNBLAQyhuKhju047ouOH25bYtemWbbaGoHnzEbjH0olaLqVWyu+Y
         pCaw==
X-Google-Smtp-Source: APXvYqyWIWLNEYgUdjbBJmFBtF2xpWUOfcQBNuEB4DojU0BorepaQmZ2vc9ieiP8iff2RVKZX4HGOqToIe6OAaoZjhfSXQ==
X-Received: by 2002:a63:fc43:: with SMTP id r3mr60203845pgk.44.1556566594898;
 Mon, 29 Apr 2019 12:36:34 -0700 (PDT)
Date: Mon, 29 Apr 2019 12:36:31 -0700
In-Reply-To: <CACdnJuup-y1xAO93wr+nr6ARacxJ9YXgaceQK9TLktE7shab1w@mail.gmail.com>
Message-Id: <20190429193631.119828-1-matthewgarrett@google.com>
Mime-Version: 1.0
References: <CACdnJuup-y1xAO93wr+nr6ARacxJ9YXgaceQK9TLktE7shab1w@mail.gmail.com>
X-Mailer: git-send-email 2.21.0.593.g511ec345e18-goog
Subject: [PATCH V4] mm: Allow userland to request that the kernel clear memory
 on release
From: Matthew Garrett <matthewgarrett@google.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Matthew Garrett <mjg59@google.com>
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
to avoid that), so this patch adds a new flag (MADV_WIPEONRELEASE) to
madvise() to allow userland to request that the kernel clear the covered
pages on process exit (clean or otherwise).

If a process clone()s, pages may end up being simultaneously owned by
multiple processes. In this case the parent process may exit before the
child, in which case the pages would not be cleared because the map count
would still be non-zero. This could result in surprising outcomes, so
instead all CoW pages are forcibly copied on fork() and madvise(). Child
processes will still receive copies of the secrets and must be trusted to
also ensure that they are wiped - this can be avoided if the parent also
sets MADV_WIPEONFORK on these regions to ensure that the child receives
clean pages.

Signed-off-by: Matthew Garrett <mjg59@google.com>
---

Further updates based on feedback - we now forcibly copy any CoW pages
in MADV_WIPEONRELEASE areas, and I've moved the wiping logic to
page_remove_rmap() and page_remove_anon_compound_rmap(). I know more
about mm than I did when I started, which means I'm probably more
dangerous than I was this time last week - please do feel free to point
out how I've screwed up.

 include/linux/mm.h                     |  7 +++++
 include/linux/rmap.h                   |  2 +-
 include/uapi/asm-generic/mman-common.h |  2 ++
 kernel/events/uprobes.c                |  2 +-
 kernel/fork.c                          | 10 +++++++
 mm/gup.c                               | 37 ++++++++++++++++++++++++++
 mm/huge_memory.c                       | 12 ++++-----
 mm/hugetlb.c                           |  4 +--
 mm/khugepaged.c                        |  2 +-
 mm/ksm.c                               |  2 +-
 mm/madvise.c                           | 28 +++++++++++++++++++
 mm/memory.c                            |  6 ++---
 mm/migrate.c                           |  4 +--
 mm/rmap.c                              | 28 +++++++++++++++----
 14 files changed, 124 insertions(+), 22 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6b10c21630f5..7841dd282961 100644
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
 
@@ -1449,6 +1455,7 @@ int generic_error_remove_page(struct address_space *mapping, struct page *page);
 int invalidate_inode_page(struct page *page);
 
 #ifdef CONFIG_MMU
+extern int trigger_cow(unsigned long start, unsigned long end);
 extern vm_fault_t handle_mm_fault(struct vm_area_struct *vma,
 			unsigned long address, unsigned int flags);
 extern int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
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
diff --git a/kernel/fork.c b/kernel/fork.c
index 9dcd18aa210b..04fe45966042 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -584,6 +584,16 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 		if (!(tmp->vm_flags & VM_WIPEONFORK))
 			retval = copy_page_range(mm, oldmm, mpnt);
 
+		/*
+		 * If VM_WIPEONRELEASE is set and VM_WIPEONFORK isn't, ensure
+		 * that the any mapped pages are copied rather than being
+		 * left as CoW - this avoids situations where a parent
+		 * has pages marked as WIPEONRELEASE and a child doesn't
+		 */
+		if (unlikely((tmp->vm_flags & (VM_WIPEONRELEASE|VM_WIPEONFORK))
+			     == VM_WIPEONRELEASE))
+			trigger_cow(tmp->vm_start, tmp->vm_end);
+
 		if (tmp->vm_ops && tmp->vm_ops->open)
 			tmp->vm_ops->open(tmp);
 
diff --git a/mm/gup.c b/mm/gup.c
index 91819b8ad9cc..bd89795ceaf5 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1499,6 +1499,43 @@ struct page *get_dump_page(unsigned long addr)
 }
 #endif /* CONFIG_ELF_CORE */
 
+static int trigger_cow_pte_entry(pte_t *pte, unsigned long addr,
+				 unsigned long next, struct mm_walk *walk)
+{
+	int ret = __get_user_pages(current, current->mm, addr, 1,
+				   FOLL_WRITE | FOLL_TOUCH, NULL, NULL, NULL);
+	if (ret != 1)
+		return ret;
+	return 0;
+}
+
+static int trigger_cow_hugetlb_range(pte_t *pte, unsigned long hmask,
+				     unsigned long addr, unsigned long end,
+				     struct mm_walk *walk)
+{
+#ifdef CONFIG_HUGETLB_PAGE
+	int ret = __get_user_pages(current, current->mm, addr, 1,
+				   FOLL_WRITE | FOLL_TOUCH, NULL, NULL, NULL);
+
+	if (ret != 1)
+		return ret;
+#else
+	BUG();
+#endif
+	return 0;
+}
+
+int trigger_cow(unsigned long start, unsigned long end)
+{
+	struct mm_walk cow_walk = {
+		.pte_entry = trigger_cow_pte_entry,
+		.hugetlb_entry = trigger_cow_hugetlb_range,
+		.mm = current->mm,
+	};
+
+	return walk_page_range(start, end, &cow_walk);
+}
+
 /*
  * Generic Fast GUP
  *
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
index 21a7881a2db4..3e133496c801 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -92,6 +92,29 @@ static long madvise_behavior(struct vm_area_struct *vma,
 	case MADV_KEEPONFORK:
 		new_flags &= ~VM_WIPEONFORK;
 		break;
+	case MADV_WIPEONRELEASE:
+		/* MADV_WIPEONRELEASE is only supported on anonymous memory. */
+		if (VM_WIPEONRELEASE == 0 || vma->vm_file ||
+		    vma->vm_flags & VM_SHARED) {
+			error = -EINVAL;
+			goto out;
+		}
+
+		new_flags |= VM_WIPEONRELEASE;
+		/*
+		 * If the VMA already has backing pages that are mapped by
+		 * multiple processes, ensure that they're CoWed
+		 */
+		if (vma->anon_vma)
+			trigger_cow(start, end);
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
@@ -727,6 +750,8 @@ madvise_behavior_valid(int behavior)
 	case MADV_DODUMP:
 	case MADV_WIPEONFORK:
 	case MADV_KEEPONFORK:
+	case MADV_WIPEONRELEASE:
+	case MADV_DONTWIPEONRELEASE:
 #ifdef CONFIG_MEMORY_FAILURE
 	case MADV_SOFT_OFFLINE:
 	case MADV_HWPOISON:
@@ -785,6 +810,9 @@ madvise_behavior_valid(int behavior)
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
index b30c7c71d1d9..f6f4e52299ed 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1251,13 +1251,19 @@ static void page_remove_file_rmap(struct page *page, bool compound)
 	unlock_page_memcg(page);
 }
 
-static void page_remove_anon_compound_rmap(struct page *page)
+static void page_remove_anon_compound_rmap(struct vm_area_struct *vma,
+					   struct page *page)
 {
 	int i, nr;
 
 	if (!atomic_add_negative(-1, compound_mapcount_ptr(page)))
 		return;
 
+	if (unlikely(vma->vm_flags & VM_WIPEONRELEASE))
+		for (i = 0; i < HPAGE_PMD_NR; i++)
+			if (page_mapcount(page) == 0)
+				clear_highpage(&page[i]);
+
 	/* Hugepages are not counted in NR_ANON_PAGES for now. */
 	if (unlikely(PageHuge(page)))
 		return;
@@ -1273,8 +1279,15 @@ static void page_remove_anon_compound_rmap(struct page *page)
 		 * themi are still mapped.
 		 */
 		for (i = 0, nr = 0; i < HPAGE_PMD_NR; i++) {
-			if (atomic_add_negative(-1, &page[i]._mapcount))
+			if (atomic_add_negative(-1, &page[i]._mapcount)) {
 				nr++;
+				/*
+				 * These will have been missed in the first
+				 * pass, so clear them now
+				 */
+				if (unlikely(vma->vm_flags & VM_WIPEONRELEASE))
+					clear_highpage(&page[i]);
+			}
 		}
 	} else {
 		nr = HPAGE_PMD_NR;
@@ -1292,17 +1305,19 @@ static void page_remove_anon_compound_rmap(struct page *page)
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
 
 	if (compound)
-		return page_remove_anon_compound_rmap(page);
+		return page_remove_anon_compound_rmap(vma, page);
 
 	/* page still mapped by someone else? */
 	if (!atomic_add_negative(-1, &page->_mapcount))
@@ -1321,6 +1336,9 @@ void page_remove_rmap(struct page *page, bool compound)
 	if (PageTransCompound(page))
 		deferred_split_huge_page(compound_head(page));
 
+	if (unlikely(vma->vm_flags & VM_WIPEONRELEASE))
+		clear_highpage(page);
+
 	/*
 	 * It would be tidy to reset the PageAnon mapping here,
 	 * but that might overwrite a racing page_add_anon_rmap
@@ -1652,7 +1670,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		 *
 		 * See Documentation/vm/mmu_notifier.rst
 		 */
-		page_remove_rmap(subpage, PageHuge(page));
+		page_remove_rmap(subpage, vma, PageHuge(page));
 		put_page(page);
 	}
 
-- 
2.21.0.593.g511ec345e18-goog

