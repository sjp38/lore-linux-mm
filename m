Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 71D0B6B007B
	for <linux-mm@kvack.org>; Mon,  4 Oct 2010 11:56:47 -0400 (EDT)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v6 12/12] Send async PF when guest is not in userspace too.
Date: Mon,  4 Oct 2010 17:56:34 +0200
Message-Id: <1286207794-16120-13-git-send-email-gleb@redhat.com>
In-Reply-To: <1286207794-16120-1-git-send-email-gleb@redhat.com>
References: <1286207794-16120-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

If guest indicates that it can handle async pf in kernel mode too send
it, but only if interrupts are enabled.

Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 arch/x86/kvm/x86.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index cad4412..30b1cd1 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -6244,7 +6244,8 @@ void kvm_arch_async_page_not_present(struct kvm_vcpu *vcpu,
 		kvm_add_async_pf_gfn(vcpu, work->arch.gfn);
 
 		if (!(vcpu->arch.apf.msr_val & KVM_ASYNC_PF_ENABLED) ||
-		    kvm_x86_ops->get_cpl(vcpu) == 0)
+		    (vcpu->arch.apf.send_user_only &&
+		     kvm_x86_ops->get_cpl(vcpu) == 0))
 			vcpu->arch.mp_state = KVM_MP_STATE_HALTED;
 		else if (!apf_put_user(vcpu, KVM_PV_REASON_PAGE_NOT_PRESENT)) {
 			vcpu->arch.fault.error_code = 0;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
