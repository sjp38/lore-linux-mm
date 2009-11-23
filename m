Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 9F9D86B0078
	for <linux-mm@kvack.org>; Mon, 23 Nov 2009 09:09:27 -0500 (EST)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v2 12/12] Send async PF when guest is not in userspace too.
Date: Mon, 23 Nov 2009 16:06:07 +0200
Message-Id: <1258985167-29178-13-git-send-email-gleb@redhat.com>
In-Reply-To: <1258985167-29178-1-git-send-email-gleb@redhat.com>
References: <1258985167-29178-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>


Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 arch/x86/kvm/mmu.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 1225c31..a538d82 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -2204,10 +2204,11 @@ int kvm_arch_setup_async_pf(struct kvm_vcpu *vcpu, gpa_t cr3, gva_t gva,
 
 static bool can_do_async_pf(struct kvm_vcpu *vcpu)
 {
-	if (!vcpu->arch.apf_data || kvm_event_needs_reinjection(vcpu))
+	if (!vcpu->arch.apf_data || kvm_event_needs_reinjection(vcpu) ||
+	    !kvm_x86_ops->interrupt_allowed(vcpu))
 		return false;
 
-	return !!kvm_x86_ops->get_cpl(vcpu);
+	return true;
 }
 
 static int tdp_page_fault(struct kvm_vcpu *vcpu, gpa_t cr3, gva_t gpa,
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
