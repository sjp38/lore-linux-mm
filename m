Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C71B36007FA
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 11:31:18 -0400 (EDT)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v5 12/12] Send async PF when guest is not in userspace too.
Date: Mon, 19 Jul 2010 18:31:02 +0300
Message-Id: <1279553462-7036-13-git-send-email-gleb@redhat.com>
In-Reply-To: <1279553462-7036-1-git-send-email-gleb@redhat.com>
References: <1279553462-7036-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

If guest indicates that it can handle async pf in kernel mode too send
it, but only if interrupt are enabled.

Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 arch/x86/kvm/mmu.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 12d1a7b..ed87b1c 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -2361,7 +2361,13 @@ static bool can_do_async_pf(struct kvm_vcpu *vcpu)
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
