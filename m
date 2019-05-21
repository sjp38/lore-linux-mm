Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F02CC072AF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 04:53:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 342A9217D4
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 04:53:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 342A9217D4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 988666B026A; Tue, 21 May 2019 00:53:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E9176B026C; Tue, 21 May 2019 00:53:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 67B006B026B; Tue, 21 May 2019 00:53:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 079A56B0269
	for <linux-mm@kvack.org>; Tue, 21 May 2019 00:53:42 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id 18so28715724eds.5
        for <linux-mm@kvack.org>; Mon, 20 May 2019 21:53:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=XR4QyHJwMBb9LpIc+JtkzaDUUiGrVVVGbuem2XVnM2w=;
        b=QBran7IYRO566sLjq0jhqKthI5TPe5rKwODZ0m9BuwOXiosjOimPZV0nwmShAVIo0b
         biv+t0OkLCxFz+a/rGa6QJ6WGWXQABZkvotHhu9YN222uesO4MJ08/PRPKMpzYU7jJLf
         giUZ+0q2t2H/CqWuaOs3fpjNlzZtr5ieagY9mPIA+di9Rlz4ACcTQLRaLLtqAgm+r9Av
         5Fs42QyEp17cmdIk5ziIl+aNJx7LTcvyhNocFFl9K022jlCHTr1uTi55ed1mPEjauw1l
         J7eoLMph99w77xpMvJoHiSjoKkerRr6nT9dGpVrrxfEJuBUpzInFT+7GHNng6FZUYN2g
         wCDA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: APjAAAXziuaU5kdMWAbJllJKe0EDNDMf9mJ8aX0dcW+f4HWX+1vbrNyo
	jhjw6Vq4faBzd5LLPGRh0vOSikWDiEneKK0Nqa0jX6K84V+EGFf3rK6Ygj2qub0v+HMDTsrjE2e
	0B6xkys7z7TE7SpmndqzmfTpKlOA9yB8IaV55Fn9WZQahwnP1MMzp4RoBwYfNoYo=
X-Received: by 2002:a05:6402:70b:: with SMTP id w11mr57413191edx.139.1558414421506;
        Mon, 20 May 2019 21:53:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwQxFuOPitcIAsPzTjC6kPNNsQKBi9UVbSQnDIMpFka1YkwWvj/ffMzPZeVYQxJMM9peFbL
X-Received: by 2002:a05:6402:70b:: with SMTP id w11mr57413107edx.139.1558414419972;
        Mon, 20 May 2019 21:53:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558414419; cv=none;
        d=google.com; s=arc-20160816;
        b=ofZTcbQkJm3W2J7cvBq3ZjpAsaVgo5T/Qw0Gl/y+wWNaj+7ljwzxYRU8N1DQ1Nv7h3
         z190hPVigkPEpTohPF196pCEmMsmRA3XovwFJPKxfXrkQJ0JUrvJ+A1cJ3aTpyrse/tY
         E8HqrcHwHBFx9uQJ17ILZHauLOfJ4FGMwy5k9/i/664slqWOV1NyM2E7LN7FhfSMKqVB
         202Z2ekbs2EcbGCU26pvd+KwBzf1GQhuiREZH27p9wjP5KzDQ8R4Sq4n7oILj4UTqyOr
         GkPdYz3krylxDiUc1Bj69GOZSyto2GLXsTAZHCN4aJzNkGdwofTefwBmpQkieTCcFEs6
         wa3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=XR4QyHJwMBb9LpIc+JtkzaDUUiGrVVVGbuem2XVnM2w=;
        b=RbgclHFQD6+VhthSIBGkLryB8GR+qWH/lanSlWDJ1UwySHRR1iYn87Gz42hhNh7Oxn
         ccguUK3PfCGA3ALucpqI44wBpKxgNCmdqJEwgG+ElXUb5/ykSgvOXET4wq4AEtWLtKiD
         e9bSBaJXI1iPtC5hBjUJykiYyhQ1Om87p60H28F0u6fcfsvs/iuVFou2szjUstQ3N/5x
         5H/ShbAScrReTmpqzES2FShorJaqTtZ8DQP8ULsaGUxA3lp+7oGw31lEBqP4nFE8Czy+
         xpxV97S/ssXlawhFQtTyWtc6GWIQc1aw4VhNYJLyHN5C7hTxNg/Umetv49RrI7CrS0xa
         OPyA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id s27si87875ejb.385.2019.05.20.21.53.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 21:53:39 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Tue, 21 May 2019 06:53:39 +0200
Received: from linux-r8p5.suse.de (nwb-a10-snat.microfocus.com [10.120.13.201])
	by emea4-mta.ukb.novell.com with ESMTP (TLS encrypted); Tue, 21 May 2019 05:53:13 +0100
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
Subject: [PATCH 08/14] arch/x86: teach the mm about range locking
Date: Mon, 20 May 2019 21:52:36 -0700
Message-Id: <20190521045242.24378-9-dave@stgolabs.net>
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
 arch/x86/entry/vdso/vma.c      | 12 +++++++-----
 arch/x86/kernel/vm86_32.c      |  5 +++--
 arch/x86/kvm/paging_tmpl.h     |  9 +++++----
 arch/x86/mm/debug_pagetables.c |  8 ++++----
 arch/x86/mm/fault.c            |  8 ++++----
 arch/x86/mm/mpx.c              | 15 +++++++++------
 arch/x86/um/vdso/vma.c         |  5 +++--
 7 files changed, 35 insertions(+), 27 deletions(-)

diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
index babc4e7a519c..f6d8950f37b8 100644
--- a/arch/x86/entry/vdso/vma.c
+++ b/arch/x86/entry/vdso/vma.c
@@ -145,12 +145,13 @@ static const struct vm_special_mapping vvar_mapping = {
  */
 static int map_vdso(const struct vdso_image *image, unsigned long addr)
 {
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	unsigned long text_start;
 	int ret = 0;
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &mmrange))
 		return -EINTR;
 
 	addr = get_unmapped_area(NULL, addr,
@@ -193,7 +194,7 @@ static int map_vdso(const struct vdso_image *image, unsigned long addr)
 	}
 
 up_fail:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	return ret;
 }
 
@@ -254,8 +255,9 @@ int map_vdso_once(const struct vdso_image *image, unsigned long addr)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 	/*
 	 * Check if we have already mapped vdso blob - fail to prevent
 	 * abusing from userspace install_speciall_mapping, which may
@@ -266,11 +268,11 @@ int map_vdso_once(const struct vdso_image *image, unsigned long addr)
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		if (vma_is_special_mapping(vma, &vdso_mapping) ||
 				vma_is_special_mapping(vma, &vvar_mapping)) {
-			up_write(&mm->mmap_sem);
+			mm_write_unlock(mm, &mmrange);
 			return -EEXIST;
 		}
 	}
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 
 	return map_vdso(image, addr);
 }
diff --git a/arch/x86/kernel/vm86_32.c b/arch/x86/kernel/vm86_32.c
index 6a38717d179c..39eecee07dcd 100644
--- a/arch/x86/kernel/vm86_32.c
+++ b/arch/x86/kernel/vm86_32.c
@@ -171,8 +171,9 @@ static void mark_screen_rdonly(struct mm_struct *mm)
 	pmd_t *pmd;
 	pte_t *pte;
 	int i;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 	pgd = pgd_offset(mm, 0xA0000);
 	if (pgd_none_or_clear_bad(pgd))
 		goto out;
@@ -198,7 +199,7 @@ static void mark_screen_rdonly(struct mm_struct *mm)
 	}
 	pte_unmap_unlock(pte, ptl);
 out:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	flush_tlb_mm_range(mm, 0xA0000, 0xA0000 + 32*PAGE_SIZE, PAGE_SHIFT, false);
 }
 
diff --git a/arch/x86/kvm/paging_tmpl.h b/arch/x86/kvm/paging_tmpl.h
index 367a47df4ba0..347d3ba41974 100644
--- a/arch/x86/kvm/paging_tmpl.h
+++ b/arch/x86/kvm/paging_tmpl.h
@@ -152,23 +152,24 @@ static int FNAME(cmpxchg_gpte)(struct kvm_vcpu *vcpu, struct kvm_mmu *mmu,
 		unsigned long vaddr = (unsigned long)ptep_user & PAGE_MASK;
 		unsigned long pfn;
 		unsigned long paddr;
+		DEFINE_RANGE_LOCK_FULL(mmrange);
 
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, &mmrange);
 		vma = find_vma_intersection(current->mm, vaddr, vaddr + PAGE_SIZE);
 		if (!vma || !(vma->vm_flags & VM_PFNMAP)) {
-			up_read(&current->mm->mmap_sem);
+			mm_read_unlock(current->mm, &mmrange);
 			return -EFAULT;
 		}
 		pfn = ((vaddr - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
 		paddr = pfn << PAGE_SHIFT;
 		table = memremap(paddr, PAGE_SIZE, MEMREMAP_WB);
 		if (!table) {
-			up_read(&current->mm->mmap_sem);
+			mm_read_unlock(current->mm, &mmrange);
 			return -EFAULT;
 		}
 		ret = CMPXCHG(&table[index], orig_pte, new_pte);
 		memunmap(table);
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &mmrange);
 	}
 
 	return (ret != orig_pte);
diff --git a/arch/x86/mm/debug_pagetables.c b/arch/x86/mm/debug_pagetables.c
index cd84f067e41d..0d131edc6a75 100644
--- a/arch/x86/mm/debug_pagetables.c
+++ b/arch/x86/mm/debug_pagetables.c
@@ -15,9 +15,9 @@ DEFINE_SHOW_ATTRIBUTE(ptdump);
 static int ptdump_curknl_show(struct seq_file *m, void *v)
 {
 	if (current->mm->pgd) {
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, &mmrange);
 		ptdump_walk_pgd_level_debugfs(m, current->mm->pgd, false);
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &mmrange);
 	}
 	return 0;
 }
@@ -30,9 +30,9 @@ static struct dentry *pe_curusr;
 static int ptdump_curusr_show(struct seq_file *m, void *v)
 {
 	if (current->mm->pgd) {
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, &mmrange);
 		ptdump_walk_pgd_level_debugfs(m, current->mm->pgd, true);
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &mmrange);
 	}
 	return 0;
 }
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index fb869c292b91..fbb060c89e7d 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -946,7 +946,7 @@ __bad_area(struct pt_regs *regs, unsigned long error_code,
 	 * Something tried to access memory that isn't in our memory map..
 	 * Fix it, but check if it's kernel or user first..
 	 */
-	up_read(&mm->mmap_sem);
+        mm_read_unlock(mm, mmrange);
 
 	__bad_area_nosemaphore(regs, error_code, address, pkey, si_code);
 }
@@ -1399,7 +1399,7 @@ void do_user_addr_fault(struct pt_regs *regs,
 	 * 1. Failed to acquire mmap_sem, and
 	 * 2. The access did not originate in userspace.
 	 */
-	if (unlikely(!down_read_trylock(&mm->mmap_sem))) {
+	if (unlikely(!mm_read_trylock(mm, &mmrange))) {
 		if (!user_mode(regs) && !search_exception_tables(regs->ip)) {
 			/*
 			 * Fault from code in kernel from
@@ -1409,7 +1409,7 @@ void do_user_addr_fault(struct pt_regs *regs,
 			return;
 		}
 retry:
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &mmrange);
 	} else {
 		/*
 		 * The above down_read_trylock() might have succeeded in
@@ -1485,7 +1485,7 @@ void do_user_addr_fault(struct pt_regs *regs,
 		return;
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		mm_fault_error(regs, hw_error_code, address, fault);
 		return;
diff --git a/arch/x86/mm/mpx.c b/arch/x86/mm/mpx.c
index 0d1c47cbbdd6..5f0a4af29920 100644
--- a/arch/x86/mm/mpx.c
+++ b/arch/x86/mm/mpx.c
@@ -46,16 +46,17 @@ static inline unsigned long mpx_bt_size_bytes(struct mm_struct *mm)
 static unsigned long mpx_mmap(unsigned long len)
 {
 	struct mm_struct *mm = current->mm;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	unsigned long addr, populate;
 
 	/* Only bounds table can be allocated here */
 	if (len != mpx_bt_size_bytes(mm))
 		return -EINVAL;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 	addr = do_mmap(NULL, 0, len, PROT_READ | PROT_WRITE,
 		       MAP_ANONYMOUS | MAP_PRIVATE, VM_MPX, 0, &populate, NULL);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	if (populate)
 		mm_populate(addr, populate);
 
@@ -214,6 +215,7 @@ int mpx_enable_management(void)
 	void __user *bd_base = MPX_INVALID_BOUNDS_DIR;
 	struct mm_struct *mm = current->mm;
 	int ret = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/*
 	 * runtime in the userspace will be responsible for allocation of
@@ -227,7 +229,7 @@ int mpx_enable_management(void)
 	 * unmap path; we can just use mm->context.bd_addr instead.
 	 */
 	bd_base = mpx_get_bounds_dir();
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 
 	/* MPX doesn't support addresses above 47 bits yet. */
 	if (find_vma(mm, DEFAULT_MAP_WINDOW)) {
@@ -241,20 +243,21 @@ int mpx_enable_management(void)
 	if (mm->context.bd_addr == MPX_INVALID_BOUNDS_DIR)
 		ret = -ENXIO;
 out:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	return ret;
 }
 
 int mpx_disable_management(void)
 {
 	struct mm_struct *mm = current->mm;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (!cpu_feature_enabled(X86_FEATURE_MPX))
 		return -ENXIO;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 	mm->context.bd_addr = MPX_INVALID_BOUNDS_DIR;
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	return 0;
 }
 
diff --git a/arch/x86/um/vdso/vma.c b/arch/x86/um/vdso/vma.c
index 6be22f991b59..d65d82b967c7 100644
--- a/arch/x86/um/vdso/vma.c
+++ b/arch/x86/um/vdso/vma.c
@@ -55,13 +55,14 @@ subsys_initcall(init_vdso);
 
 int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 {
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	int err;
 	struct mm_struct *mm = current->mm;
 
 	if (!vdso_enabled)
 		return 0;
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &mmrange))
 		return -EINTR;
 
 	err = install_special_mapping(mm, um_vdso_addr, PAGE_SIZE,
@@ -69,7 +70,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 		VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
 		vdsop);
 
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 
 	return err;
 }
-- 
2.16.4

