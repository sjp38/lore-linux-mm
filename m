Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3EA5C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:02:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79B772089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:02:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79B772089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B1D1C6B0276; Fri,  9 Aug 2019 12:01:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A7DF36B0278; Fri,  9 Aug 2019 12:01:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F4E06B0279; Fri,  9 Aug 2019 12:01:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3C52D6B0276
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:03 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id x12so1339219wrw.0
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZOyS+PwN0o96D16GYIDjVQX2lYltkfelfuVse3R5jyE=;
        b=Shc3qGU35E9Cdi9ESQHICuj0rtT+ic3OgoBTML0ghxpdCSTVe2qqPr7cdS8JVhu8PZ
         UXcytebwsIAnCnPatH5BvH8+xoVA4Zavok6bdmzsrufmg65RSBVRG6peghIulz8zHIKo
         Gzc12bxRfGvUv5qdv2eiMfJ5kkG4KBeDkPR9covABdsyueVcMVI/BBrD0LrsNTz52iI6
         EKeluLtMz/4XhXEAylpK2eWdBsH/gcVlGUK7VDAzUt0yQnGhDgRtLTKf94HDX0bqi0ru
         83Cl1teQy8VY456cB+2ZDSXcyj29YX01U8hUXCr7RvQ8XPQ4x5yqO6R3DRc31TrNUG2E
         VT5w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAUh0EGwzuAtamavMl8sKsqQYbB3+cShcjMDMkRz8QVevEABuuOX
	0RLR4XY3SeBCNDupoWJnLuc2Cohh18ZhVwnThJ5UFmz+OyCFCtDgcUg2aAHSGQ6UEv23p0hbMSF
	ilqTh/prYRElC+2rPIuvgNf+XFQWwTcJqRnDVZ08Uwn3R4PZ6KX3vO/rvSSQ6f+mh3g==
X-Received: by 2002:a1c:5a56:: with SMTP id o83mr11537218wmb.103.1565366462744;
        Fri, 09 Aug 2019 09:01:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy4M4olwh7mLRM5R2+J5gfMaCLS7H9uKba/NAJRpR/QOwuhCYeH3FpD9Ez4ETkceSr3sqf5
X-Received: by 2002:a1c:5a56:: with SMTP id o83mr11537060wmb.103.1565366460889;
        Fri, 09 Aug 2019 09:01:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366460; cv=none;
        d=google.com; s=arc-20160816;
        b=hgq4FmfMtVtLCYzZj3PHjPcOz5uI1h1jog8NYm+RQhYrw4CjMdXBSTe16+8oY1a+kc
         nVEZ9fd46skCZ4eox7J2TrpNUY96zD+r+jwJ5LLUvLciZxI7CxtY4sd6RMKBY3kxz4L8
         CDIP1WQ0b1tekiCps3IishBA/8qj6GECXP9wjYCfCoW9aeOzdMWmgrJR4AeBtSQNnCL5
         IehSa7BEgqQ9VI8dzEcn8JdHrljIFoC+tcVS+RhLzqM2sk8d14ITYPFQhLAWVLRMWXSB
         yvv1l+To4zOQaJO1UAA06P8egU8PdgqMa7ZJgBarQySwHB+mO4oEK4ilwaHrV825UdKT
         Qv8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ZOyS+PwN0o96D16GYIDjVQX2lYltkfelfuVse3R5jyE=;
        b=LbeRu0B0D5jnm7jXgyOLoEXeFTRSBciJbNjz8afWtJ+mwluq+dSLvHNy19eifo7YGN
         NlQjdukARCTrIasMFVHy5OroVYo30MFQTDOKTte9ZieoXu/w7ZjkFCt12W1mLHnas7Gb
         d0lGovUSmjcJqITmNx1NxScvEuydLSLvoxzuFjkNoFGtAA/CwANID+cvSQEgnWhob1ej
         k6GKC/BN4UuNXvIjq7ZwYEMbEUtxJswMgMAs3+YaPLAc1k7xeRvJgXcysz7BR0PRhVZU
         n1nAy1mSO4X9LiXm71X6yWwq7YXvaLPDmShwHu33bAbX6WBFMMx6EIfhlsYef5mSzrt0
         q7bw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id v7si90031094wrd.283.2019.08.09.09.01.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 46210301ACC1;
	Fri,  9 Aug 2019 19:01:00 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id CA4D7305B7A3;
	Fri,  9 Aug 2019 19:00:59 +0300 (EEST)
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
	Xiao Guangrong <guangrong.xiao@gmail.com>,
	Sean Christopherson <sean.j.christopherson@intel.com>
Subject: [RFC PATCH v6 23/92] kvm: page track: add support for preread, prewrite and preexec
Date: Fri,  9 Aug 2019 18:59:38 +0300
Message-Id: <20190809160047.8319-24-alazar@bitdefender.com>
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

From: Mihai Donțu <mdontu@bitdefender.com>

These callbacks return a boolean value. If false, the emulation should
stop and the instruction should be reexecuted in guest. The preread
callback can return the bytes needed by the read operation.

CC: Xiao Guangrong <guangrong.xiao@gmail.com>
CC: Sean Christopherson <sean.j.christopherson@intel.com>
Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/include/asm/kvm_page_track.h |  19 +++-
 arch/x86/kvm/mmu.c                    |  81 +++++++++++++++++
 arch/x86/kvm/mmu.h                    |   4 +
 arch/x86/kvm/page_track.c             | 123 ++++++++++++++++++++++++--
 4 files changed, 217 insertions(+), 10 deletions(-)

diff --git a/arch/x86/include/asm/kvm_page_track.h b/arch/x86/include/asm/kvm_page_track.h
index 0492a85f3a44..a431e5e1e5cb 100644
--- a/arch/x86/include/asm/kvm_page_track.h
+++ b/arch/x86/include/asm/kvm_page_track.h
@@ -3,7 +3,10 @@
 #define _ASM_X86_KVM_PAGE_TRACK_H
 
 enum kvm_page_track_mode {
+	KVM_PAGE_TRACK_PREREAD,
+	KVM_PAGE_TRACK_PREWRITE,
 	KVM_PAGE_TRACK_WRITE,
+	KVM_PAGE_TRACK_PREEXEC,
 	KVM_PAGE_TRACK_MAX,
 };
 
@@ -22,6 +25,13 @@ struct kvm_page_track_notifier_head {
 struct kvm_page_track_notifier_node {
 	struct hlist_node node;
 
+	bool (*track_preread)(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
+			      u8 *new, int bytes,
+			      struct kvm_page_track_notifier_node *node,
+			      bool *data_ready);
+	bool (*track_prewrite)(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
+			       const u8 *new, int bytes,
+			       struct kvm_page_track_notifier_node *node);
 	/*
 	 * It is called when guest is writing the write-tracked page
 	 * and write emulation is finished at that time.
@@ -35,12 +45,14 @@ struct kvm_page_track_notifier_node {
 	void (*track_write)(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
 			    const u8 *new, int bytes,
 			    struct kvm_page_track_notifier_node *node);
+	bool (*track_preexec)(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
+			      struct kvm_page_track_notifier_node *node);
 	void (*track_create_slot)(struct kvm *kvm, struct kvm_memory_slot *slot,
 				  unsigned long npages,
 				  struct kvm_page_track_notifier_node *node);
 	/*
 	 * It is called when memory slot is being moved or removed
-	 * users can drop write-protection for the pages in that memory slot
+	 * users can drop active protection for the pages in that memory slot
 	 *
 	 * @kvm: the kvm where memory slot being moved or removed
 	 * @slot: the memory slot being moved or removed
@@ -73,7 +85,12 @@ kvm_page_track_register_notifier(struct kvm *kvm,
 void
 kvm_page_track_unregister_notifier(struct kvm *kvm,
 				   struct kvm_page_track_notifier_node *n);
+bool kvm_page_track_preread(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
+			    u8 *new, int bytes, bool *data_ready);
+bool kvm_page_track_prewrite(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
+			     const u8 *new, int bytes);
 void kvm_page_track_write(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
 			  const u8 *new, int bytes);
+bool kvm_page_track_preexec(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva);
 void kvm_page_track_flush_slot(struct kvm *kvm, struct kvm_memory_slot *slot);
 #endif
diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 9898d863b6b6..a86b165cf6dd 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -1523,6 +1523,31 @@ static bool spte_write_protect(u64 *sptep, bool pt_protect)
 	return mmu_spte_update(sptep, spte);
 }
 
+static bool spte_read_protect(u64 *sptep)
+{
+	u64 spte = *sptep;
+	bool exec_only_supported = (shadow_present_mask == 0ull);
+
+	rmap_printk("rmap_read_protect: spte %p %llx\n", sptep, *sptep);
+
+	WARN_ON_ONCE(!exec_only_supported);
+
+	spte = spte & ~(PT_WRITABLE_MASK | PT_PRESENT_MASK);
+
+	return mmu_spte_update(sptep, spte);
+}
+
+static bool spte_exec_protect(u64 *sptep)
+{
+	u64 spte = *sptep;
+
+	rmap_printk("rmap_exec_protect: spte %p %llx\n", sptep, *sptep);
+
+	spte = spte & ~PT_USER_MASK;
+
+	return mmu_spte_update(sptep, spte);
+}
+
 static bool __rmap_write_protect(struct kvm *kvm,
 				 struct kvm_rmap_head *rmap_head,
 				 bool pt_protect)
@@ -1537,6 +1562,32 @@ static bool __rmap_write_protect(struct kvm *kvm,
 	return flush;
 }
 
+static bool __rmap_read_protect(struct kvm *kvm,
+				struct kvm_rmap_head *rmap_head)
+{
+	u64 *sptep;
+	struct rmap_iterator iter;
+	bool flush = false;
+
+	for_each_rmap_spte(rmap_head, &iter, sptep)
+		flush |= spte_read_protect(sptep);
+
+	return flush;
+}
+
+static bool __rmap_exec_protect(struct kvm *kvm,
+				struct kvm_rmap_head *rmap_head)
+{
+	u64 *sptep;
+	struct rmap_iterator iter;
+	bool flush = false;
+
+	for_each_rmap_spte(rmap_head, &iter, sptep)
+		flush |= spte_exec_protect(sptep);
+
+	return flush;
+}
+
 static bool spte_clear_dirty(u64 *sptep)
 {
 	u64 spte = *sptep;
@@ -1707,6 +1758,36 @@ bool kvm_mmu_slot_gfn_write_protect(struct kvm *kvm,
 	return write_protected;
 }
 
+bool kvm_mmu_slot_gfn_read_protect(struct kvm *kvm,
+				   struct kvm_memory_slot *slot, u64 gfn)
+{
+	struct kvm_rmap_head *rmap_head;
+	int i;
+	bool read_protected = false;
+
+	for (i = PT_PAGE_TABLE_LEVEL; i <= PT_MAX_HUGEPAGE_LEVEL; ++i) {
+		rmap_head = __gfn_to_rmap(gfn, i, slot);
+		read_protected |= __rmap_read_protect(kvm, rmap_head);
+	}
+
+	return read_protected;
+}
+
+bool kvm_mmu_slot_gfn_exec_protect(struct kvm *kvm,
+				   struct kvm_memory_slot *slot, u64 gfn)
+{
+	struct kvm_rmap_head *rmap_head;
+	int i;
+	bool exec_protected = false;
+
+	for (i = PT_PAGE_TABLE_LEVEL; i <= PT_MAX_HUGEPAGE_LEVEL; ++i) {
+		rmap_head = __gfn_to_rmap(gfn, i, slot);
+		exec_protected |= __rmap_exec_protect(kvm, rmap_head);
+	}
+
+	return exec_protected;
+}
+
 static bool rmap_write_protect(struct kvm_vcpu *vcpu, u64 gfn)
 {
 	struct kvm_memory_slot *slot;
diff --git a/arch/x86/kvm/mmu.h b/arch/x86/kvm/mmu.h
index c7b333147c4a..45948dabe0b6 100644
--- a/arch/x86/kvm/mmu.h
+++ b/arch/x86/kvm/mmu.h
@@ -210,5 +210,9 @@ void kvm_mmu_gfn_disallow_lpage(struct kvm_memory_slot *slot, gfn_t gfn);
 void kvm_mmu_gfn_allow_lpage(struct kvm_memory_slot *slot, gfn_t gfn);
 bool kvm_mmu_slot_gfn_write_protect(struct kvm *kvm,
 				    struct kvm_memory_slot *slot, u64 gfn);
+bool kvm_mmu_slot_gfn_read_protect(struct kvm *kvm,
+				   struct kvm_memory_slot *slot, u64 gfn);
+bool kvm_mmu_slot_gfn_exec_protect(struct kvm *kvm,
+				   struct kvm_memory_slot *slot, u64 gfn);
 int kvm_arch_write_log_dirty(struct kvm_vcpu *vcpu);
 #endif
diff --git a/arch/x86/kvm/page_track.c b/arch/x86/kvm/page_track.c
index ff7defb4a1d2..fc792939a05c 100644
--- a/arch/x86/kvm/page_track.c
+++ b/arch/x86/kvm/page_track.c
@@ -1,5 +1,5 @@
 /*
- * Support KVM gust page tracking
+ * Support KVM guest page tracking
  *
  * This feature allows us to track page access in guest. Currently, only
  * write access is tracked.
@@ -101,7 +101,7 @@ static void update_gfn_track(struct kvm_memory_slot *slot, gfn_t gfn,
  * @kvm: the guest instance we are interested in.
  * @slot: the @gfn belongs to.
  * @gfn: the guest page.
- * @mode: tracking mode, currently only write track is supported.
+ * @mode: tracking mode.
  */
 void kvm_slot_page_track_add_page(struct kvm *kvm,
 				  struct kvm_memory_slot *slot, gfn_t gfn,
@@ -119,9 +119,16 @@ void kvm_slot_page_track_add_page(struct kvm *kvm,
 	 */
 	kvm_mmu_gfn_disallow_lpage(slot, gfn);
 
-	if (mode == KVM_PAGE_TRACK_WRITE)
+	if (mode == KVM_PAGE_TRACK_PREWRITE || mode == KVM_PAGE_TRACK_WRITE) {
 		if (kvm_mmu_slot_gfn_write_protect(kvm, slot, gfn))
 			kvm_flush_remote_tlbs(kvm);
+	} else if (mode == KVM_PAGE_TRACK_PREREAD) {
+		if (kvm_mmu_slot_gfn_read_protect(kvm, slot, gfn))
+			kvm_flush_remote_tlbs(kvm);
+	} else if (mode == KVM_PAGE_TRACK_PREEXEC) {
+		if (kvm_mmu_slot_gfn_exec_protect(kvm, slot, gfn))
+			kvm_flush_remote_tlbs(kvm);
+	}
 }
 EXPORT_SYMBOL_GPL(kvm_slot_page_track_add_page);
 
@@ -136,7 +143,7 @@ EXPORT_SYMBOL_GPL(kvm_slot_page_track_add_page);
  * @kvm: the guest instance we are interested in.
  * @slot: the @gfn belongs to.
  * @gfn: the guest page.
- * @mode: tracking mode, currently only write track is supported.
+ * @mode: tracking mode.
  */
 void kvm_slot_page_track_remove_page(struct kvm *kvm,
 				     struct kvm_memory_slot *slot, gfn_t gfn,
@@ -229,12 +236,81 @@ kvm_page_track_unregister_notifier(struct kvm *kvm,
 }
 EXPORT_SYMBOL_GPL(kvm_page_track_unregister_notifier);
 
+/*
+ * Notify the node that a read access is about to happen. Returning false
+ * doesn't stop the other nodes from being called, but it will stop
+ * the emulation.
+ *
+ * The node should figure out if the written page is the one that the node
+ * is interested in by itself.
+ *
+ * The nodes will always be in conflict if they track the same page:
+ * - accepting a read won't guarantee that the next node will not override
+ *   the data (filling new/bytes and setting data_ready)
+ * - filling new/bytes with custom data won't guarantee that the next node
+ *   will not override that
+ */
+bool kvm_page_track_preread(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
+			    u8 *new, int bytes, bool *data_ready)
+{
+	struct kvm_page_track_notifier_head *head;
+	struct kvm_page_track_notifier_node *n;
+	int idx;
+	bool ret = true;
+
+	*data_ready = false;
+
+	head = &vcpu->kvm->arch.track_notifier_head;
+
+	if (hlist_empty(&head->track_notifier_list))
+		return ret;
+
+	idx = srcu_read_lock(&head->track_srcu);
+	hlist_for_each_entry_rcu(n, &head->track_notifier_list, node)
+		if (n->track_preread)
+			if (!n->track_preread(vcpu, gpa, gva, new, bytes, n,
+					       data_ready))
+				ret = false;
+	srcu_read_unlock(&head->track_srcu, idx);
+	return ret;
+}
+
+/*
+ * Notify the node that a write access is about to happen. Returning false
+ * doesn't stop the other nodes from being called, but it will stop
+ * the emulation.
+ *
+ * The node should figure out if the written page is the one that the node
+ * is interested in by itself.
+ */
+bool kvm_page_track_prewrite(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
+			     const u8 *new, int bytes)
+{
+	struct kvm_page_track_notifier_head *head;
+	struct kvm_page_track_notifier_node *n;
+	int idx;
+	bool ret = true;
+
+	head = &vcpu->kvm->arch.track_notifier_head;
+
+	if (hlist_empty(&head->track_notifier_list))
+		return ret;
+
+	idx = srcu_read_lock(&head->track_srcu);
+	hlist_for_each_entry_rcu(n, &head->track_notifier_list, node)
+		if (n->track_prewrite)
+			if (!n->track_prewrite(vcpu, gpa, gva, new, bytes, n))
+				ret = false;
+	srcu_read_unlock(&head->track_srcu, idx);
+	return ret;
+}
+
 /*
  * Notify the node that write access is intercepted and write emulation is
  * finished at this time.
  *
- * The node should figure out if the written page is the one that node is
- * interested in by itself.
+ * The node should figure out if the written page is the one that the node
+ * is interested in by itself.
  */
 void kvm_page_track_write(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
 			  const u8 *new, int bytes)
@@ -255,12 +331,41 @@ void kvm_page_track_write(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
 	srcu_read_unlock(&head->track_srcu, idx);
 }
 
+/*
+ * Notify the node that an instruction is about to be executed.
+ * Returning false doesn't stop the other nodes from being called,
+ * but it will stop the emulation with X86EMUL_RETRY_INSTR.
+ *
+ * The node should figure out if the written page is the one that the node
+ * is interested in by itself.
+ */
+bool kvm_page_track_preexec(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva)
+{
+	struct kvm_page_track_notifier_head *head;
+	struct kvm_page_track_notifier_node *n;
+	int idx;
+	bool ret = true;
+
+	head = &vcpu->kvm->arch.track_notifier_head;
+
+	if (hlist_empty(&head->track_notifier_list))
+		return ret;
+
+	idx = srcu_read_lock(&head->track_srcu);
+	hlist_for_each_entry_rcu(n, &head->track_notifier_list, node)
+		if (n->track_preexec)
+			if (!n->track_preexec(vcpu, gpa, gva, n))
+				ret = false;
+	srcu_read_unlock(&head->track_srcu, idx);
+	return ret;
+}
+
 /*
  * Notify the node that memory slot is being removed or moved so that it can
- * drop write-protection for the pages in the memory slot.
+ * drop active protection for the pages in the memory slot.
  *
- * The node should figure out it has any write-protected pages in this slot
- * by itself.
+ * The node should figure out if the written page is the one that the node
+ * is interested in by itself.
  */
 void kvm_page_track_flush_slot(struct kvm *kvm, struct kvm_memory_slot *slot)
 {

