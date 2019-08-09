Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA456C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:06:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 60830214C6
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:06:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60830214C6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 96C876B02DE; Fri,  9 Aug 2019 12:02:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 945B46B02DF; Fri,  9 Aug 2019 12:02:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7BD086B02E0; Fri,  9 Aug 2019 12:02:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 26FE86B02DE
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:02:46 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id u17so1064778wmd.6
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:02:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=m1u3dAUowG1bwENfLOMXjLL+1YYWL00ZFb4YmpqEHzs=;
        b=kWQDwdAXC2t/Iws/EhaeKT/hY/WRxR5Nb/iVg8UgVbRlocdrmXNJZfqo1BqWWno9Jf
         H8GJeZbvYwF4e3tqp1i7Y1BQVSuKOf8SGnfWwbNOxr0SDPxDAgYMqD5HR5XUNgX23YEi
         FYtWb6pNTu+woQ1rlJpuRD0DSc/544W5IcnlWXDNiH/3ZJc90KbKI9mBWNSjcD8ZDYwG
         501RrQ/Ey7+hjVEf+3MBLBkOPomor+zNw/UyDCXS9uCJ8Xnao/BHesi26zfj0e60wVmk
         jurnOPzlRXvSesH1SG6j/c+gtdy5UPqpHtcm4U0Qo/lc08subC0ZwEsEi+Er7mBwVXFR
         OI/Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAWl+bZvV1tp7L6sjGMp9sRuvrxXOdkqsi8ezxrfrPNlTw8LktFu
	JiWNnM1DVDW0PA0YiQjutQLXdvl8094xWMChAfBTHKsRfKR2TVOfMbfuz/N8DeyqgkIlXxEEXeg
	tiBUjvMzy8/Za0T7QkNXQ15Mc3n3TzXVPAa+8yJCXWkHD4pRF59r/RKxhnm5vVjq8Aw==
X-Received: by 2002:adf:9b9d:: with SMTP id d29mr2229788wrc.132.1565366565730;
        Fri, 09 Aug 2019 09:02:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqznvW/tS17MHVpjQc27iUdqRF/ZWtnkKBLVdgZ7g3Xbc9ElSVxYRmtjm/u1dXiSpSibh7/B
X-Received: by 2002:adf:9b9d:: with SMTP id d29mr2219417wrc.132.1565366461106;
        Fri, 09 Aug 2019 09:01:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366461; cv=none;
        d=google.com; s=arc-20160816;
        b=qjoU6xAJPBKCutMFh4/v0+duBuxyy+Ax5JegDRcboAlzVPk7Al4w6iSuZqzQXVGFgB
         HK2qLRB3XTyWurZ8btLk0gBVYfMFj+IRr8Zi08ZIFIevX1tKmgCYSInZRNF0ySDdxlqo
         DqaeurxLSSfnb3qpRk2RknbxFpUcPFqY13kP/rhu27sFDW7iEUreSyqcfIJMiZbbXcq2
         44BCPBosQooEVy7N58MKB+shrYxGUaQETA7j47Q4jClOTf2al74Ecadxe4p3sweiCH0v
         7xwu20PRR+6Y67CE3NVip+x5wQqMtO7ExSMDnxIRdS5VZ9ZODdbYGlBZoXjWnPkKwvNH
         2zWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=m1u3dAUowG1bwENfLOMXjLL+1YYWL00ZFb4YmpqEHzs=;
        b=VH60NsyYY9rKKF6fXwnHo8X6Neqes6uUnaqB2NGsg8nJuf154MJMuEFkJxaF+7K3nx
         o+jM/zfDeiixd0ZQZXh4TzC/r4BnE9igFH4jdWf+RLAJ+J+/rKnF7zr5Ze1R5WBGe1o3
         tHL5VEyu3YaJ8+nEv/dZBJISq8y/fCG97gLCbhYSnxXdWQgineUqS5BfCiBmlukGzLUc
         D9xx8b7cVllCAMMUBZQXz0drrdABqyl6QgAaSI0/758DTr6KjYErbOIX28t4NIjsG03M
         /iCNn8wcmSFKmbLAOhPPHwSDIitZ2mjUADiZWUDUYLWPAgcOqDCLAcCElGrzXv8Zff2R
         Krug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id t11si6901013wrv.312.2019.08.09.09.01.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 7FAAD301ACC2;
	Fri,  9 Aug 2019 19:01:00 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 341AA305B7A0;
	Fri,  9 Aug 2019 19:01:00 +0300 (EEST)
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
	Sean Christopherson <sean.j.christopherson@intel.com>,
	Joerg Roedel <joro@8bytes.org>
Subject: [RFC PATCH v6 24/92] kvm: x86: wire in the preread/prewrite/preexec page trackers
Date: Fri,  9 Aug 2019 18:59:39 +0300
Message-Id: <20190809160047.8319-25-alazar@bitdefender.com>
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

These are needed by the introspection subsystem.

CC: Sean Christopherson <sean.j.christopherson@intel.com>
CC: Joerg Roedel <joro@8bytes.org>
Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/include/asm/kvm_emulate.h |  1 +
 arch/x86/kvm/emulate.c             | 10 +++++-
 arch/x86/kvm/mmu.c                 | 37 ++++++++++++++-------
 arch/x86/kvm/x86.c                 | 52 ++++++++++++++++++++++++------
 4 files changed, 79 insertions(+), 21 deletions(-)

diff --git a/arch/x86/include/asm/kvm_emulate.h b/arch/x86/include/asm/kvm_emulate.h
index 93c4bf598fb0..97cb592687cb 100644
--- a/arch/x86/include/asm/kvm_emulate.h
+++ b/arch/x86/include/asm/kvm_emulate.h
@@ -444,6 +444,7 @@ bool x86_page_table_writing_insn(struct x86_emulate_ctxt *ctxt);
 #define EMULATION_OK 0
 #define EMULATION_RESTART 1
 #define EMULATION_INTERCEPTED 2
+#define EMULATION_RETRY_INSTR 3
 void init_decode_cache(struct x86_emulate_ctxt *ctxt);
 int x86_emulate_insn(struct x86_emulate_ctxt *ctxt);
 int emulator_task_switch(struct x86_emulate_ctxt *ctxt,
diff --git a/arch/x86/kvm/emulate.c b/arch/x86/kvm/emulate.c
index c338984c850d..34431cf31f74 100644
--- a/arch/x86/kvm/emulate.c
+++ b/arch/x86/kvm/emulate.c
@@ -5366,7 +5366,12 @@ int x86_decode_insn(struct x86_emulate_ctxt *ctxt, void *insn, int insn_len)
 					ctxt->memopp->addr.mem.ea + ctxt->_eip);
 
 done:
-	return (rc != X86EMUL_CONTINUE) ? EMULATION_FAILED : EMULATION_OK;
+	if (rc == X86EMUL_RETRY_INSTR)
+		return EMULATION_RETRY_INSTR;
+	else if (rc == X86EMUL_CONTINUE)
+		return EMULATION_OK;
+	else
+		return EMULATION_FAILED;
 }
 
 bool x86_page_table_writing_insn(struct x86_emulate_ctxt *ctxt)
@@ -5736,6 +5741,9 @@ int x86_emulate_insn(struct x86_emulate_ctxt *ctxt)
 	if (rc == X86EMUL_INTERCEPTED)
 		return EMULATION_INTERCEPTED;
 
+	if (rc == X86EMUL_RETRY_INSTR)
+		return EMULATION_RETRY_INSTR;
+
 	if (rc == X86EMUL_CONTINUE)
 		writeback_registers(ctxt);
 
diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index a86b165cf6dd..ff053f17b8c2 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -1111,9 +1111,13 @@ static void account_shadowed(struct kvm *kvm, struct kvm_mmu_page *sp)
 	slot = __gfn_to_memslot(slots, gfn);
 
 	/* the non-leaf shadow pages are keeping readonly. */
-	if (sp->role.level > PT_PAGE_TABLE_LEVEL)
-		return kvm_slot_page_track_add_page(kvm, slot, gfn,
-						    KVM_PAGE_TRACK_WRITE);
+	if (sp->role.level > PT_PAGE_TABLE_LEVEL) {
+		kvm_slot_page_track_add_page(kvm, slot, gfn,
+					     KVM_PAGE_TRACK_PREWRITE);
+		kvm_slot_page_track_add_page(kvm, slot, gfn,
+					     KVM_PAGE_TRACK_WRITE);
+		return;
+	}
 
 	kvm_mmu_gfn_disallow_lpage(slot, gfn);
 }
@@ -1128,9 +1132,13 @@ static void unaccount_shadowed(struct kvm *kvm, struct kvm_mmu_page *sp)
 	gfn = sp->gfn;
 	slots = kvm_memslots_for_spte_role(kvm, sp->role);
 	slot = __gfn_to_memslot(slots, gfn);
-	if (sp->role.level > PT_PAGE_TABLE_LEVEL)
-		return kvm_slot_page_track_remove_page(kvm, slot, gfn,
-						       KVM_PAGE_TRACK_WRITE);
+	if (sp->role.level > PT_PAGE_TABLE_LEVEL) {
+		kvm_slot_page_track_remove_page(kvm, slot, gfn,
+						KVM_PAGE_TRACK_PREWRITE);
+		kvm_slot_page_track_remove_page(kvm, slot, gfn,
+						KVM_PAGE_TRACK_WRITE);
+		return;
+	}
 
 	kvm_mmu_gfn_allow_lpage(slot, gfn);
 }
@@ -2884,7 +2892,8 @@ static bool mmu_need_write_protect(struct kvm_vcpu *vcpu, gfn_t gfn,
 {
 	struct kvm_mmu_page *sp;
 
-	if (kvm_page_track_is_active(vcpu, gfn, KVM_PAGE_TRACK_WRITE))
+	if (kvm_page_track_is_active(vcpu, gfn, KVM_PAGE_TRACK_PREWRITE) ||
+	    kvm_page_track_is_active(vcpu, gfn, KVM_PAGE_TRACK_WRITE))
 		return true;
 
 	for_each_gfn_indirect_valid_sp(vcpu->kvm, sp, gfn) {
@@ -4006,15 +4015,21 @@ static bool page_fault_handle_page_track(struct kvm_vcpu *vcpu,
 	if (unlikely(error_code & PFERR_RSVD_MASK))
 		return false;
 
-	if (!(error_code & PFERR_PRESENT_MASK) ||
-	      !(error_code & PFERR_WRITE_MASK))
+	if (!(error_code & PFERR_PRESENT_MASK))
 		return false;
 
 	/*
-	 * guest is writing the page which is write tracked which can
+	 * guest is reading/writing/fetching the page which is
+	 * read/write/execute tracked which can
 	 * not be fixed by page fault handler.
 	 */
-	if (kvm_page_track_is_active(vcpu, gfn, KVM_PAGE_TRACK_WRITE))
+	if (((error_code & PFERR_USER_MASK)
+		&& kvm_page_track_is_active(vcpu, gfn, KVM_PAGE_TRACK_PREREAD))
+	    || ((error_code & PFERR_WRITE_MASK)
+		&& (kvm_page_track_is_active(vcpu, gfn, KVM_PAGE_TRACK_PREWRITE)
+		 || kvm_page_track_is_active(vcpu, gfn, KVM_PAGE_TRACK_WRITE)))
+	    || ((error_code & PFERR_FETCH_MASK)
+		&& kvm_page_track_is_active(vcpu, gfn, KVM_PAGE_TRACK_PREEXEC)))
 		return true;
 
 	return false;
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index d3d159986243..7aef002be551 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -5065,6 +5065,7 @@ static int kvm_read_guest_virt_helper(gva_t addr, void *val, unsigned int bytes,
 {
 	void *data = val;
 	int r = X86EMUL_CONTINUE;
+	bool data_ready;
 
 	while (bytes) {
 		gpa_t gpa = vcpu->arch.walk_mmu->gva_to_gpa(vcpu, addr, access,
@@ -5075,6 +5076,13 @@ static int kvm_read_guest_virt_helper(gva_t addr, void *val, unsigned int bytes,
 
 		if (gpa == UNMAPPED_GVA)
 			return X86EMUL_PROPAGATE_FAULT;
+		if (!kvm_page_track_preread(vcpu, gpa, addr, data, toread,
+						&data_ready))
+			return X86EMUL_RETRY_INSTR;
+		if (data_ready) {
+			WARN_ON(toread > bytes); /* TODO */
+			return X86EMUL_CONTINUE;
+		}
 		ret = kvm_vcpu_read_guest_page(vcpu, gpa >> PAGE_SHIFT, data,
 					       offset, toread);
 		if (ret < 0) {
@@ -5106,6 +5114,9 @@ static int kvm_fetch_guest_virt(struct x86_emulate_ctxt *ctxt,
 	if (unlikely(gpa == UNMAPPED_GVA))
 		return X86EMUL_PROPAGATE_FAULT;
 
+	if (!kvm_page_track_preexec(vcpu, gpa, addr))
+		return X86EMUL_RETRY_INSTR;
+
 	offset = addr & (PAGE_SIZE-1);
 	if (WARN_ON(offset + bytes > PAGE_SIZE))
 		bytes = (unsigned)PAGE_SIZE - offset;
@@ -5284,13 +5295,26 @@ static int vcpu_mmio_gva_to_gpa(struct kvm_vcpu *vcpu, unsigned long gva,
 int emulator_write_phys(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
 			const void *val, int bytes)
 {
-	int ret;
-
-	ret = kvm_vcpu_write_guest(vcpu, gpa, val, bytes);
-	if (ret < 0)
-		return 0;
+	if (!kvm_page_track_prewrite(vcpu, gpa, gva, val, bytes))
+		return X86EMUL_RETRY_INSTR;
+	if (kvm_vcpu_write_guest(vcpu, gpa, val, bytes) < 0)
+		return X86EMUL_UNHANDLEABLE;
 	kvm_page_track_write(vcpu, gpa, gva, val, bytes);
-	return 1;
+	return X86EMUL_CONTINUE;
+}
+
+static int emulator_read_phys(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
+			      void *val, int bytes)
+{
+	bool data_ready;
+
+	if (!kvm_page_track_preread(vcpu, gpa, gva, val, bytes, &data_ready))
+		return X86EMUL_RETRY_INSTR;
+	if (data_ready)
+		return X86EMUL_CONTINUE;
+	if (kvm_vcpu_read_guest(vcpu, gpa, val, bytes) < 0)
+		return X86EMUL_UNHANDLEABLE;
+	return X86EMUL_CONTINUE;
 }
 
 struct read_write_emulator_ops {
@@ -5320,7 +5344,7 @@ static int read_prepare(struct kvm_vcpu *vcpu, void *val, int bytes)
 static int read_emulate(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
 			void *val, int bytes)
 {
-	return !kvm_vcpu_read_guest(vcpu, gpa, val, bytes);
+	return emulator_read_phys(vcpu, gpa, gva, val, bytes);
 }
 
 static int write_emulate(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
@@ -5395,8 +5419,11 @@ static int emulator_read_write_onepage(unsigned long addr, void *val,
 			return X86EMUL_PROPAGATE_FAULT;
 	}
 
-	if (!ret && ops->read_write_emulate(vcpu, gpa, addr, val, bytes))
-		return X86EMUL_CONTINUE;
+	if (!ret) {
+		ret = ops->read_write_emulate(vcpu, gpa, addr, val, bytes);
+		if (ret == X86EMUL_CONTINUE || ret == X86EMUL_RETRY_INSTR)
+			return ret;
+	}
 
 	/*
 	 * Is this MMIO handled locally?
@@ -5531,6 +5558,9 @@ static int emulator_cmpxchg_emulated(struct x86_emulate_ctxt *ctxt,
 	if (is_error_page(page))
 		goto emul_write;
 
+	if (!kvm_page_track_prewrite(vcpu, gpa, addr, new, bytes))
+		return X86EMUL_RETRY_INSTR;
+
 	kaddr = kmap_atomic(page);
 	kaddr += offset_in_page(gpa);
 	switch (bytes) {
@@ -6416,6 +6446,8 @@ int x86_emulate_instruction(struct kvm_vcpu *vcpu,
 
 		trace_kvm_emulate_insn_start(vcpu);
 		++vcpu->stat.insn_emulation;
+		if (r == EMULATION_RETRY_INSTR)
+			return EMULATE_DONE;
 		if (r != EMULATION_OK)  {
 			if (emulation_type & EMULTYPE_TRAP_UD)
 				return EMULATE_FAIL;
@@ -6457,6 +6489,8 @@ int x86_emulate_instruction(struct kvm_vcpu *vcpu,
 
 	r = x86_emulate_insn(ctxt);
 
+	if (r == EMULATION_RETRY_INSTR)
+		return EMULATE_DONE;
 	if (r == EMULATION_INTERCEPTED)
 		return EMULATE_DONE;
 

