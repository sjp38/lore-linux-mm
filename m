Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2D9A06B026D
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 14:07:12 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id w141so7834612wme.1
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 11:07:12 -0800 (PST)
Received: from mx02.buh.bitdefender.com (mx02.bbu.dsd.mx.bitdefender.com. [91.199.104.133])
        by mx.google.com with ESMTPS id p12si9499606wrh.443.2017.12.18.11.07.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 11:07:11 -0800 (PST)
From: =?UTF-8?q?Adalber=20Laz=C4=83r?= <alazar@bitdefender.com>
Subject: [RFC PATCH v4 14/18] kvm: x86: hook in kvmi_cr_event()
Date: Mon, 18 Dec 2017 21:06:38 +0200
Message-Id: <20171218190642.7790-15-alazar@bitdefender.com>
In-Reply-To: <20171218190642.7790-1-alazar@bitdefender.com>
References: <20171218190642.7790-1-alazar@bitdefender.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, =?UTF-8?q?Mihai=20Don=C8=9Bu?= <mdontu@bitdefender.com>, Adalbert Lazar <alazar@bitdefender.com>

From: Adalbert Lazar <alazar@bitdefender.com>

Notify the guest introspection tool that cr{0,3,4} is going to be
changed. The function kvmi_cr_event() will load in crX the new value
if the tool permits it.

Signed-off-by: Mihai DonE?u <mdontu@bitdefender.com>
---
 arch/x86/kvm/x86.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index caf50b7307a4..8f5cc81c8760 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -676,6 +676,9 @@ int kvm_set_cr0(struct kvm_vcpu *vcpu, unsigned long cr0)
 	if (!(cr0 & X86_CR0_PG) && kvm_read_cr4_bits(vcpu, X86_CR4_PCIDE))
 		return 1;
 
+	if (!kvmi_cr_event(vcpu, 0, old_cr0, &cr0))
+		return 1;
+
 	kvm_x86_ops->set_cr0(vcpu, cr0);
 
 	if ((cr0 ^ old_cr0) & X86_CR0_PG) {
@@ -816,6 +819,9 @@ int kvm_set_cr4(struct kvm_vcpu *vcpu, unsigned long cr4)
 			return 1;
 	}
 
+	if (!kvmi_cr_event(vcpu, 4, old_cr4, &cr4))
+		return 1;
+
 	if (kvm_x86_ops->set_cr4(vcpu, cr4))
 		return 1;
 
@@ -832,11 +838,13 @@ EXPORT_SYMBOL_GPL(kvm_set_cr4);
 
 int kvm_set_cr3(struct kvm_vcpu *vcpu, unsigned long cr3)
 {
+	unsigned long old_cr3 = kvm_read_cr3(vcpu);
+
 #ifdef CONFIG_X86_64
 	cr3 &= ~CR3_PCID_INVD;
 #endif
 
-	if (cr3 == kvm_read_cr3(vcpu) && !pdptrs_changed(vcpu)) {
+	if (cr3 == old_cr3 && !pdptrs_changed(vcpu)) {
 		kvm_mmu_sync_roots(vcpu);
 		kvm_make_request(KVM_REQ_TLB_FLUSH, vcpu);
 		return 0;
@@ -849,6 +857,9 @@ int kvm_set_cr3(struct kvm_vcpu *vcpu, unsigned long cr3)
 		   !load_pdptrs(vcpu, vcpu->arch.walk_mmu, cr3))
 		return 1;
 
+	if (!kvmi_cr_event(vcpu, 3, old_cr3, &cr3))
+		return 1;
+
 	vcpu->arch.cr3 = cr3;
 	__set_bit(VCPU_EXREG_CR3, (ulong *)&vcpu->arch.regs_avail);
 	kvm_mmu_new_cr3(vcpu);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
