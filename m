Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 072276007BA
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 09:13:09 -0500 (EST)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v3 12/12] Send async PF when guest is not in userspace too.
Date: Tue,  5 Jan 2010 16:12:54 +0200
Message-Id: <1262700774-1808-13-git-send-email-gleb@redhat.com>
In-Reply-To: <1262700774-1808-1-git-send-email-gleb@redhat.com>
References: <1262700774-1808-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>


Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 arch/x86/kvm/mmu.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 9fd29cb..7945abf 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -2204,7 +2204,13 @@ static bool can_do_async_pf(struct kvm_vcpu *vcpu)
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
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
