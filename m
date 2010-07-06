Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6693B6B024D
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 12:25:14 -0400 (EDT)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v4 12/12] Send async PF when guest is not in userspace too.
Date: Tue,  6 Jul 2010 19:25:00 +0300
Message-Id: <1278433500-29884-13-git-send-email-gleb@redhat.com>
In-Reply-To: <1278433500-29884-1-git-send-email-gleb@redhat.com>
References: <1278433500-29884-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>


Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 arch/x86/kvm/mmu.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 95a0a8b..297f399 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -2280,7 +2280,13 @@ static bool can_do_async_pf(struct kvm_vcpu *vcpu)
 	if (!vcpu->arch.apf_data || kvm_event_needs_reinjection(vcpu))
 		return false;
 
-	return !!kvm_x86_ops->get_cpl(vcpu);
+	if (vcpu->arch.apf_send_user_only)
+		return !!kvm_x86_ops->get_cpl(vcpu);
+
+	if (!kvm_x86_ops->interrupt_allowed(vcpu))
+		return false;
+
+	return true;
 }
 
 static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa, u32 error_code,
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
