Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B8A775F004E
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 05:23:17 -0400 (EDT)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v7 12/12] Send async PF when guest is not in userspace too.
Date: Thu, 14 Oct 2010 11:22:56 +0200
Message-Id: <1287048176-2563-13-git-send-email-gleb@redhat.com>
In-Reply-To: <1287048176-2563-1-git-send-email-gleb@redhat.com>
References: <1287048176-2563-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

If guest indicates that it can handle async pf in kernel mode too send
it, but only if interrupts are enabled.

Acked-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 arch/x86/kvm/x86.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 1e442df..51cff2f 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -6248,7 +6248,8 @@ void kvm_arch_async_page_not_present(struct kvm_vcpu *vcpu,
 	kvm_add_async_pf_gfn(vcpu, work->arch.gfn);
 
 	if (!(vcpu->arch.apf.msr_val & KVM_ASYNC_PF_ENABLED) ||
-	    kvm_x86_ops->get_cpl(vcpu) == 0)
+	    (vcpu->arch.apf.send_user_only &&
+	     kvm_x86_ops->get_cpl(vcpu) == 0))
 		kvm_make_request(KVM_REQ_APF_HALT, vcpu);
 	else if (!apf_put_user(vcpu, KVM_PV_REASON_PAGE_NOT_PRESENT)) {
 		vcpu->arch.fault.error_code = 0;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
