Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5FBAF6B026A
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 14:07:08 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id a141so7303556wma.8
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 11:07:08 -0800 (PST)
Received: from mx02.buh.bitdefender.com (mx02.bbu.dsd.mx.bitdefender.com. [91.199.104.133])
        by mx.google.com with ESMTPS id y188si4005wmy.267.2017.12.18.11.07.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 11:07:07 -0800 (PST)
From: =?UTF-8?q?Adalber=20Laz=C4=83r?= <alazar@bitdefender.com>
Subject: [RFC PATCH v4 11/18] kvm: x86: hook in the page tracking
Date: Mon, 18 Dec 2017 21:06:35 +0200
Message-Id: <20171218190642.7790-12-alazar@bitdefender.com>
In-Reply-To: <20171218190642.7790-1-alazar@bitdefender.com>
References: <20171218190642.7790-1-alazar@bitdefender.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, =?UTF-8?q?Mihai=20Don=C8=9Bu?= <mdontu@bitdefender.com>, Adalbert Lazar <alazar@bitdefender.com>, =?UTF-8?q?Nicu=C8=99or=20C=C3=AE=C8=9Bu?= <ncitu@bitdefender.com>

From: Adalbert Lazar <alazar@bitdefender.com>

Inform the guest introspection tool that a read/write/execute access is
happening on a page of interest (configured via a KVMI_SET_PAGE_ACCESS
request).

The introspection tool can respond to allow the emulation to continue,
with or without custom input (for read access), retry to guest (if the
tool has changed the program counter, has emulated the instruction or
the page is no longer of interest).

Signed-off-by: Mihai DonE?u <mdontu@bitdefender.com>
Signed-off-by: NicuE?or CA(R)E?u <ncitu@bitdefender.com>
---
 arch/x86/include/asm/kvm_emulate.h |  1 +
 arch/x86/kvm/emulate.c             |  9 +++++++-
 arch/x86/kvm/mmu.c                 |  3 +++
 arch/x86/kvm/x86.c                 | 46 +++++++++++++++++++++++++++++---------
 4 files changed, 48 insertions(+), 11 deletions(-)

diff --git a/arch/x86/include/asm/kvm_emulate.h b/arch/x86/include/asm/kvm_emulate.h
index b24b1c8b3979..e257cae3a745 100644
--- a/arch/x86/include/asm/kvm_emulate.h
+++ b/arch/x86/include/asm/kvm_emulate.h
@@ -438,6 +438,7 @@ bool x86_page_table_writing_insn(struct x86_emulate_ctxt *ctxt);
 #define EMULATION_OK 0
 #define EMULATION_RESTART 1
 #define EMULATION_INTERCEPTED 2
+#define EMULATION_USER_EXIT 3
 void init_decode_cache(struct x86_emulate_ctxt *ctxt);
 int x86_emulate_insn(struct x86_emulate_ctxt *ctxt);
 int emulator_task_switch(struct x86_emulate_ctxt *ctxt,
diff --git a/arch/x86/kvm/emulate.c b/arch/x86/kvm/emulate.c
index abe74f779f9d..94886040f8f1 100644
--- a/arch/x86/kvm/emulate.c
+++ b/arch/x86/kvm/emulate.c
@@ -5263,7 +5263,12 @@ int x86_decode_insn(struct x86_emulate_ctxt *ctxt, void *insn, int insn_len)
 					ctxt->memopp->addr.mem.ea + ctxt->_eip);
 
 done:
-	return (rc != X86EMUL_CONTINUE) ? EMULATION_FAILED : EMULATION_OK;
+	if (rc == X86EMUL_RETRY_INSTR)
+		return EMULATION_USER_EXIT;
+	else if (rc == X86EMUL_CONTINUE)
+		return EMULATION_OK;
+	else
+		return EMULATION_FAILED;
 }
 
 bool x86_page_table_writing_insn(struct x86_emulate_ctxt *ctxt)
@@ -5633,6 +5638,8 @@ int x86_emulate_insn(struct x86_emulate_ctxt *ctxt)
 	if (rc == X86EMUL_INTERCEPTED)
 		return EMULATION_INTERCEPTED;
 
+	if (rc == X86EMUL_RETRY_INSTR)
+		return EMULATION_USER_EXIT;
 	if (rc == X86EMUL_CONTINUE)
 		writeback_registers(ctxt);
 
diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 19dc17b00db2..18205c710233 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -5066,6 +5066,9 @@ int kvm_mmu_page_fault(struct kvm_vcpu *vcpu, gva_t cr2, u64 error_code,
 
 	if (mmio_info_in_cache(vcpu, cr2, direct))
 		emulation_type = 0;
+	if (kvm_page_track_is_active(vcpu, gpa_to_gfn(cr2),
+				     KVM_PAGE_TRACK_PREEXEC))
+		emulation_type = EMULTYPE_NO_REEXECUTE;
 emulate:
 	er = x86_emulate_instruction(vcpu, cr2, emulation_type, insn, insn_len);
 
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 9889e96f64e6..caf50b7307a4 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -4501,6 +4501,9 @@ static int kvm_fetch_guest_virt(struct x86_emulate_ctxt *ctxt,
 	if (unlikely(gpa == UNMAPPED_GVA))
 		return X86EMUL_PROPAGATE_FAULT;
 
+	if (!kvm_page_track_preexec(vcpu, gpa))
+		return X86EMUL_RETRY_INSTR;
+
 	offset = addr & (PAGE_SIZE-1);
 	if (WARN_ON(offset + bytes > PAGE_SIZE))
 		bytes = (unsigned)PAGE_SIZE - offset;
@@ -4622,13 +4625,26 @@ static int vcpu_mmio_gva_to_gpa(struct kvm_vcpu *vcpu, unsigned long gva,
 int emulator_write_phys(struct kvm_vcpu *vcpu, gpa_t gpa,
 			const void *val, int bytes)
 {
-	int ret;
-
-	ret = kvm_vcpu_write_guest(vcpu, gpa, val, bytes);
-	if (ret < 0)
-		return 0;
+	if (!kvm_page_track_prewrite(vcpu, gpa, val, bytes))
+		return X86EMUL_RETRY_INSTR;
+	if (kvm_vcpu_write_guest(vcpu, gpa, val, bytes) < 0)
+		return X86EMUL_UNHANDLEABLE;
 	kvm_page_track_write(vcpu, gpa, val, bytes);
-	return 1;
+	return X86EMUL_CONTINUE;
+}
+
+static int emulator_read_phys(struct kvm_vcpu *vcpu, gpa_t gpa,
+			      void *val, int bytes)
+{
+	bool data_ready;
+
+	if (!kvm_page_track_preread(vcpu, gpa, val, bytes, &data_ready))
+		return X86EMUL_RETRY_INSTR;
+	if (data_ready)
+		return X86EMUL_CONTINUE;
+	if (kvm_vcpu_read_guest(vcpu, gpa, val, bytes) < 0)
+		return X86EMUL_UNHANDLEABLE;
+	return X86EMUL_CONTINUE;
 }
 
 struct read_write_emulator_ops {
@@ -4658,7 +4674,7 @@ static int read_prepare(struct kvm_vcpu *vcpu, void *val, int bytes)
 static int read_emulate(struct kvm_vcpu *vcpu, gpa_t gpa,
 			void *val, int bytes)
 {
-	return !kvm_vcpu_read_guest(vcpu, gpa, val, bytes);
+	return emulator_read_phys(vcpu, gpa, val, bytes);
 }
 
 static int write_emulate(struct kvm_vcpu *vcpu, gpa_t gpa,
@@ -4733,8 +4749,11 @@ static int emulator_read_write_onepage(unsigned long addr, void *val,
 			return X86EMUL_PROPAGATE_FAULT;
 	}
 
-	if (!ret && ops->read_write_emulate(vcpu, gpa, val, bytes))
-		return X86EMUL_CONTINUE;
+	if (!ret) {
+		ret = ops->read_write_emulate(vcpu, gpa, val, bytes);
+		if (ret == X86EMUL_CONTINUE || ret == X86EMUL_RETRY_INSTR)
+			return ret;
+	}
 
 	/*
 	 * Is this MMIO handled locally?
@@ -4869,6 +4888,9 @@ static int emulator_cmpxchg_emulated(struct x86_emulate_ctxt *ctxt,
 	if (is_error_page(page))
 		goto emul_write;
 
+	if (!kvm_page_track_prewrite(vcpu, gpa, new, bytes))
+		return X86EMUL_RETRY_INSTR;
+
 	kaddr = kmap_atomic(page);
 	kaddr += offset_in_page(gpa);
 	switch (bytes) {
@@ -5721,7 +5743,9 @@ int x86_emulate_instruction(struct kvm_vcpu *vcpu,
 
 		trace_kvm_emulate_insn_start(vcpu);
 		++vcpu->stat.insn_emulation;
-		if (r != EMULATION_OK)  {
+		if (r == EMULATION_USER_EXIT)
+			return EMULATE_DONE;
+		if (r != EMULATION_OK) {
 			if (emulation_type & EMULTYPE_TRAP_UD)
 				return EMULATE_FAIL;
 			if (reexecute_instruction(vcpu, cr2, write_fault_to_spt,
@@ -5758,6 +5782,8 @@ int x86_emulate_instruction(struct kvm_vcpu *vcpu,
 
 	r = x86_emulate_insn(ctxt);
 
+	if (r == EMULATION_USER_EXIT)
+		return EMULATE_DONE;
 	if (r == EMULATION_INTERCEPTED)
 		return EMULATE_DONE;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
