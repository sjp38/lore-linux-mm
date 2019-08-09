Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECB87C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:02:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E42B20C01
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:02:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E42B20C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E9F936B0283; Fri,  9 Aug 2019 12:01:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E78986B0284; Fri,  9 Aug 2019 12:01:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8F466B0287; Fri,  9 Aug 2019 12:01:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 64F5D6B0283
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:13 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id r4so47050073wrt.13
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=nG0xZasIyNtk5APDc2FaQ2NIvWbDVnFwKYGzEWn8AiY=;
        b=HhZyJlFARr1k/+O9DaqCRSvOQw2UdbPAUlBx+JTBMSUwNEGwJdD2jejJU3u9OSl+6N
         q2O+DGA+IdjfHbtxzjoNYx4ZX4vzlhrjpSarsN0w9vAHshRCQB/GwpZH5cuEPWBBdYSn
         2RiENH3WFkTAVhsq3z62HHD47qWn7qQH8+Jiq6ey+qlcrE8WZYYgQrm09rELP+KfD8Qk
         t4/1+603saFRq2yBszCj+H1albi135LOCL6gl+1r4BJ8UUja+YnIR9PnPaLcHVPvPkO1
         Rz+TG9bCWIcDfYkDcmH5LP1d9SjyejguxOKRogUEFg/k2Z1h9cUjFEarNzIIjKRux9Y3
         RNrg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAW5FLAEohJ6kH50q9zE5QW/6pEP0NGkPFbw/kFocxiXHO1Yq0ao
	3JIzy4NkD06ddt0YaDelgF8I4ZLxy/cdwLjQNSjpOrAqIYqK0yBFs/QxRaP+SXSOJyWXDY0xXwm
	2EC+P+Cm8cMtA4jcSTEv/OcV0pFnLD9psmxCofs6/cWhpbv7w/U88a00xtyk1Th8QZQ==
X-Received: by 2002:a1c:4d05:: with SMTP id o5mr11323395wmh.129.1565366472902;
        Fri, 09 Aug 2019 09:01:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy9CTxZcCpgB7b+aJDeXCbHhwby6hp3ZexnH0bF+Qu0c8GK7Qtx2UEqDRm3wCN6INIUkYAX
X-Received: by 2002:a1c:4d05:: with SMTP id o5mr11322916wmh.129.1565366467282;
        Fri, 09 Aug 2019 09:01:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366467; cv=none;
        d=google.com; s=arc-20160816;
        b=k+54iie4EwmMapaN9/7QsJT36hmEBuskKOIsARiBWdOqY7Nd1M9RNFUn2cWCudY+HO
         dPZbUHvWH383W0I09CI22D11vpFvyFs7XL7kxoCXDxkXRI3de2jTUXwge2VGaoCcmgds
         DOj68EBK/W6RTgWsi4qv58hz76q9eVo6B8yr4Dl/haJOS1r9vynpHatg9E4vbvflkJCs
         QRmvePxX9bsRWc8hdkXG+Ab/dQ9Qfw+x27Ze8ABBw50Z7ZyfEBGUxKiR3IpPzOmMA5X8
         mOW9jw2hk5Te3AT9gRfuzq6d8KYjp0VmjPPQAgBxul9KZysLR7128YW5XgSrwtRoMNoc
         7D5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=nG0xZasIyNtk5APDc2FaQ2NIvWbDVnFwKYGzEWn8AiY=;
        b=ePj2fY4tu0Qe98CgPrCWff9bwlRuhxUO/pt3fbga5iRj+WI5SGSFx8VPeZ4wVOPlOt
         NmczPj3SQGe58XNYu8wD1+0+YS23ZNtQBy55VcX/3+Kx/StKfJKiA+bdXjcC2J0uU6YD
         IjKk7rswpK/nfvlSSWyUfo49AW5kt1zkmJVxZooV3Qokq+TP8RSLPuWiW5hnHR0aj0kY
         hGVdtrt1e8ZdOpuoVRxrk23QyCymnTMcs+Smg16YvwpljEO8h8BgGF4tRMi/iSoEHhc5
         5cN5SXyDl88WTzm4w/70KBLkQQUmhdObwStIHMHv1NkybMpPzQEGE6TemjEeyyBJDEcj
         558Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id m13si85060033wrn.20.2019.08.09.09.01.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 8DA5C305D344;
	Fri,  9 Aug 2019 19:01:06 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 6EC6C305B7A3;
	Fri,  9 Aug 2019 19:01:05 +0300 (EEST)
From: =?UTF-8?q?Adalbert=20Laz=C4=83r?= <alazar@bitdefender.com>
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, virtualization@lists.linux-foundation.org,
	Paolo Bonzini <pbonzini@redhat.com>,
	=?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Tamas K Lengyel <tamas@tklengyel.com>,
	Mathieu Tarral <mathieu.tarral@protonmail.com>,
	=?UTF-8?q?Samuel=20Laur=C3=A9n?= <samuel.lauren@iki.fi>,
	Patrick Colp <patrick.colp@oracle.com>,
	Jan Kiszka <jan.kiszka@siemens.com>,
	Stefan Hajnoczi <stefanha@redhat.com>,
	Weijiang Yang <weijiang.yang@intel.com>, Zhang@kvack.org,
	Yu C <yu.c.zhang@intel.com>,
	=?UTF-8?q?Mihai=20Don=C8=9Bu?= <mdontu@bitdefender.com>,
	=?UTF-8?q?Adalbert=20Laz=C4=83r?= <alazar@bitdefender.com>,
	He Chen <he.chen@linux.intel.com>,
	Zhang Yi <yi.z.zhang@linux.intel.com>
Subject: [RFC PATCH v6 36/92] KVM: VMX: Implement functions for SPPT paging setup
Date: Fri,  9 Aug 2019 18:59:51 +0300
Message-Id: <20190809160047.8319-37-alazar@bitdefender.com>
In-Reply-To: <20190809160047.8319-1-alazar@bitdefender.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Yang Weijiang <weijiang.yang@intel.com>

SPPT is a 4-level paging structure similar to EPT, when SPP is
kicked for target physical page, bit 61 of the corresponding
EPT enty will be flaged, then SPPT is traversed with the gfn to
build up entries, the leaf entry of SPPT contains the access
bitmap for subpages inside the target 4KB physical page, one bit
per 128-byte subpage.

SPPT entries are set up in below cases:
1. the EPT faulted page is SPP protected.
2. SPP mis-config induced vmexit is handled.
3. User configures SPP protected pages via SPP IOCTLs.

Co-developed-by: He Chen <he.chen@linux.intel.com>
Signed-off-by: He Chen <he.chen@linux.intel.com>
Co-developed-by: Zhang Yi <yi.z.zhang@linux.intel.com>
Signed-off-by: Zhang Yi <yi.z.zhang@linux.intel.com>
Co-developed-by: Yang Weijiang <weijiang.yang@intel.com>
Signed-off-by: Yang Weijiang <weijiang.yang@intel.com>
Message-Id: <20190717133751.12910-4-weijiang.yang@intel.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/include/asm/kvm_host.h |   7 +-
 arch/x86/kvm/mmu.c              | 207 ++++++++++++++++++++++++++++++++
 arch/x86/kvm/mmu.h              |   1 +
 include/linux/kvm_host.h        |   3 +
 4 files changed, 217 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index f1b3d89a0430..c05984f39923 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -271,7 +271,8 @@ union kvm_mmu_page_role {
 		unsigned smap_andnot_wp:1;
 		unsigned ad_disabled:1;
 		unsigned guest_mode:1;
-		unsigned :6;
+		unsigned spp:1;
+		unsigned reserved:5;
 
 		/*
 		 * This is left at the top of the word so that
@@ -1410,6 +1411,10 @@ int kvm_emulate_hypercall(struct kvm_vcpu *vcpu);
 
 int kvm_mmu_page_fault(struct kvm_vcpu *vcpu, gva_t gva, u64 error_code,
 		       void *insn, int insn_len);
+
+int kvm_mmu_setup_spp_structure(struct kvm_vcpu *vcpu,
+				u32 access_map, gfn_t gfn);
+
 void kvm_mmu_invlpg(struct kvm_vcpu *vcpu, gva_t gva);
 void kvm_mmu_invpcid_gva(struct kvm_vcpu *vcpu, gva_t gva, unsigned long pcid);
 void kvm_mmu_new_cr3(struct kvm_vcpu *vcpu, gpa_t new_cr3, bool skip_tlb_flush);
diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 810e3e5bd575..8a6287cd2be4 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -206,6 +206,11 @@ static const union kvm_mmu_page_role mmu_base_role_mask = {
 		({ spte = mmu_spte_get_lockless(_walker.sptep); 1; });	\
 	     __shadow_walk_next(&(_walker), spte))
 
+#define for_each_shadow_spp_entry(_vcpu, _addr, _walker)    \
+	for (shadow_spp_walk_init(&(_walker), _vcpu, _addr);	\
+	     shadow_walk_okay(&(_walker));			\
+	     shadow_walk_next(&(_walker)))
+
 static struct kmem_cache *pte_list_desc_cache;
 static struct kmem_cache *mmu_page_header_cache;
 static struct percpu_counter kvm_total_used_mmu_pages;
@@ -505,6 +510,11 @@ static int is_shadow_present_pte(u64 pte)
 	return (pte != 0) && !is_mmio_spte(pte);
 }
 
+static int is_spp_shadow_present(u64 pte)
+{
+	return pte & PT_PRESENT_MASK;
+}
+
 static int is_large_pte(u64 pte)
 {
 	return pte & PT_PAGE_SIZE_MASK;
@@ -524,6 +534,11 @@ static bool is_executable_pte(u64 spte)
 	return (spte & (shadow_x_mask | shadow_nx_mask)) == shadow_x_mask;
 }
 
+static bool is_spp_spte(struct kvm_mmu_page *sp)
+{
+	return sp->role.spp;
+}
+
 static kvm_pfn_t spte_to_pfn(u64 pte)
 {
 	return (pte & PT64_BASE_ADDR_MASK) >> PAGE_SHIFT;
@@ -1751,6 +1766,87 @@ int kvm_arch_write_log_dirty(struct kvm_vcpu *vcpu)
 	return 0;
 }
 
+static bool __rmap_open_subpage_bit(struct kvm *kvm,
+				    struct kvm_rmap_head *rmap_head)
+{
+	struct rmap_iterator iter;
+	bool flush = false;
+	u64 *sptep;
+	u64 spte;
+
+	for_each_rmap_spte(rmap_head, &iter, sptep) {
+		/*
+		 * SPP works only when the page is write-protected
+		 * and SPP bit is set in EPT leaf entry.
+		 */
+		flush |= spte_write_protect(sptep, false);
+		spte = *sptep | PT_SPP_MASK;
+		flush |= mmu_spte_update(sptep, spte);
+	}
+
+	return flush;
+}
+
+static int kvm_mmu_open_subpage_write_protect(struct kvm *kvm,
+					      struct kvm_memory_slot *slot,
+					      gfn_t gfn)
+{
+	struct kvm_rmap_head *rmap_head;
+	bool flush = false;
+
+	/*
+	 * SPP is only supported with 4KB level1 memory page, check
+	 * if the page is mapped in EPT leaf entry.
+	 */
+	rmap_head = __gfn_to_rmap(gfn, PT_PAGE_TABLE_LEVEL, slot);
+
+	if (!rmap_head->val)
+		return -EFAULT;
+
+	flush |= __rmap_open_subpage_bit(kvm, rmap_head);
+
+	if (flush)
+		kvm_flush_remote_tlbs(kvm);
+
+	return 0;
+}
+
+static bool __rmap_clear_subpage_bit(struct kvm *kvm,
+				     struct kvm_rmap_head *rmap_head)
+{
+	struct rmap_iterator iter;
+	bool flush = false;
+	u64 *sptep;
+	u64 spte;
+
+	for_each_rmap_spte(rmap_head, &iter, sptep) {
+		spte = (*sptep & ~PT_SPP_MASK) | PT_WRITABLE_MASK;
+		flush |= mmu_spte_update(sptep, spte);
+	}
+
+	return flush;
+}
+
+static int kvm_mmu_clear_subpage_write_protect(struct kvm *kvm,
+					       struct kvm_memory_slot *slot,
+					       gfn_t gfn)
+{
+	struct kvm_rmap_head *rmap_head;
+	bool flush = false;
+
+	rmap_head = __gfn_to_rmap(gfn, PT_PAGE_TABLE_LEVEL, slot);
+
+	if (!rmap_head->val)
+		return -EFAULT;
+
+	flush |= __rmap_clear_subpage_bit(kvm, rmap_head);
+
+	if (flush)
+		kvm_flush_remote_tlbs(kvm);
+
+	return 0;
+}
+
 bool kvm_mmu_slot_gfn_write_protect(struct kvm *kvm,
 				    struct kvm_memory_slot *slot, u64 gfn)
 {
@@ -2505,6 +2601,30 @@ static unsigned int kvm_mmu_page_track_acc(struct kvm_vcpu *vcpu, gfn_t gfn,
 	return acc;
 }
 
+struct kvm_mmu_page *kvm_mmu_get_spp_page(struct kvm_vcpu *vcpu,
+						 gfn_t gfn,
+						 unsigned int level)
+
+{
+	struct kvm_mmu_page *sp;
+	union kvm_mmu_page_role role;
+
+	role = vcpu->arch.mmu->mmu_role.base;
+	role.level = level;
+	role.direct = true;
+	role.spp = true;
+
+	sp = kvm_mmu_alloc_page(vcpu, true);
+	sp->gfn = gfn;
+	sp->role = role;
+	hlist_add_head(&sp->hash_link,
+		       &vcpu->kvm->arch.mmu_page_hash
+		       [kvm_page_table_hashfn(gfn)]);
+	clear_page(sp->spt);
+	return sp;
+}
+EXPORT_SYMBOL_GPL(kvm_mmu_get_spp_page);
+
 static struct kvm_mmu_page *kvm_mmu_get_page(struct kvm_vcpu *vcpu,
 					     gfn_t gfn,
 					     gva_t gaddr,
@@ -2632,6 +2752,16 @@ static void shadow_walk_init(struct kvm_shadow_walk_iterator *iterator,
 				    addr);
 }
 
+static void shadow_spp_walk_init(struct kvm_shadow_walk_iterator *iterator,
+				 struct kvm_vcpu *vcpu, u64 addr)
+{
+	iterator->addr = addr;
+	iterator->shadow_addr = vcpu->arch.mmu->sppt_root;
+
+	/* SPP Table is a 4-level paging structure */
+	iterator->level = 4;
+}
+
 static bool shadow_walk_okay(struct kvm_shadow_walk_iterator *iterator)
 {
 	if (iterator->level < PT_PAGE_TABLE_LEVEL)
@@ -2682,6 +2812,18 @@ static void link_shadow_page(struct kvm_vcpu *vcpu, u64 *sptep,
 		mark_unsync(sptep);
 }
 
+static void link_spp_shadow_page(struct kvm_vcpu *vcpu, u64 *sptep,
+				 struct kvm_mmu_page *sp)
+{
+	u64 spte;
+
+	spte = __pa(sp->spt) | PT_PRESENT_MASK;
+
+	mmu_spte_set(sptep, spte);
+
+	mmu_page_add_parent_pte(vcpu, sp, sptep);
+}
+
 static void validate_direct_spte(struct kvm_vcpu *vcpu, u64 *sptep,
 				   unsigned direct_access)
 {
@@ -4253,6 +4395,71 @@ static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa, u32 error_code,
 	return RET_PF_RETRY;
 }
 
+static u64 format_spp_spte(u32 spp_wp_bitmap)
+{
+	u64 new_spte = 0;
+	int i = 0;
+
+	/*
+	 * One 4K page contains 32 sub-pages, in SPP table L4E, old bits
+	 * are reserved, so we need to transfer u32 subpage write
+	 * protect bitmap to u64 SPP L4E format.
+	 */
+	while (i < 32) {
+		if (spp_wp_bitmap & (1ULL << i))
+			new_spte |= 1ULL << (i * 2);
+
+		i++;
+	}
+
+	return new_spte;
+}
+
+static void mmu_spp_spte_set(u64 *sptep, u64 new_spte)
+{
+	__set_spte(sptep, new_spte);
+}
+
+int kvm_mmu_setup_spp_structure(struct kvm_vcpu *vcpu,
+				u32 access_map, gfn_t gfn)
+{
+	struct kvm_shadow_walk_iterator iter;
+	struct kvm_mmu_page *sp;
+	gfn_t pseudo_gfn;
+	u64 old_spte, spp_spte;
+	int ret = -EFAULT;
+
+	/* direct_map spp start */
+	if (!VALID_PAGE(vcpu->arch.mmu->sppt_root))
+		return -EFAULT;
+
+	for_each_shadow_spp_entry(vcpu, (u64)gfn << PAGE_SHIFT, iter) {
+		if (iter.level == PT_PAGE_TABLE_LEVEL) {
+			spp_spte = format_spp_spte(access_map);
+			old_spte = mmu_spte_get_lockless(iter.sptep);
+			if (old_spte != spp_spte) {
+				mmu_spp_spte_set(iter.sptep, spp_spte);
+				kvm_make_request(KVM_REQ_TLB_FLUSH, vcpu);
+			}
+
+			ret = 0;
+			break;
+		}
+
+		if (!is_spp_shadow_present(*iter.sptep)) {
+			u64 base_addr = iter.addr;
+
+			base_addr &= PT64_LVL_ADDR_MASK(iter.level);
+			pseudo_gfn = base_addr >> PAGE_SHIFT;
+			sp = kvm_mmu_get_spp_page(vcpu, pseudo_gfn,
+						  iter.level - 1);
+			link_spp_shadow_page(vcpu, iter.sptep, sp);
+		}
+	}
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(kvm_mmu_setup_spp_structure);
 static void nonpaging_init_context(struct kvm_vcpu *vcpu,
 				   struct kvm_mmu *context)
 {
diff --git a/arch/x86/kvm/mmu.h b/arch/x86/kvm/mmu.h
index 45948dabe0b6..8c34decd6422 100644
--- a/arch/x86/kvm/mmu.h
+++ b/arch/x86/kvm/mmu.h
@@ -26,6 +26,7 @@
 #define PT_PAGE_SIZE_MASK (1ULL << PT_PAGE_SIZE_SHIFT)
 #define PT_PAT_MASK (1ULL << 7)
 #define PT_GLOBAL_MASK (1ULL << 8)
+#define PT_SPP_MASK (1ULL << 61)
 #define PT64_NX_SHIFT 63
 #define PT64_NX_MASK (1ULL << PT64_NX_SHIFT)
 
diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
index e876921938b6..ca7597e429df 100644
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -832,6 +832,9 @@ int kvm_arch_vcpu_runnable(struct kvm_vcpu *vcpu);
 bool kvm_arch_vcpu_in_kernel(struct kvm_vcpu *vcpu);
 int kvm_arch_vcpu_should_kick(struct kvm_vcpu *vcpu);
 
+struct kvm_mmu_page *kvm_mmu_get_spp_page(struct kvm_vcpu *vcpu,
+			gfn_t gfn, unsigned int level);
+
 #ifndef __KVM_HAVE_ARCH_VM_ALLOC
 /*
  * All architectures that want to use vzalloc currently also

