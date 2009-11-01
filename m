Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 56C2F6B007D
	for <linux-mm@kvack.org>; Sun,  1 Nov 2009 06:56:36 -0500 (EST)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH 11/11] Send async PF when guest is not in userspace too.
Date: Sun,  1 Nov 2009 13:56:30 +0200
Message-Id: <1257076590-29559-12-git-send-email-gleb@redhat.com>
In-Reply-To: <1257076590-29559-1-git-send-email-gleb@redhat.com>
References: <1257076590-29559-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 arch/x86/kvm/mmu.c |   16 ++++++----------
 1 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 3d33994..21ec65a 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -2358,7 +2358,7 @@ static bool kvm_asyc_pf_is_done(struct kvm_vcpu *vcpu)
 
 	spin_lock(&vcpu->arch.mmu_async_pf_lock);
 	list_for_each_entry_safe(p, node, &vcpu->arch.mmu_async_pf_done, link) {
-		if (p->guest_task != vcpu->arch.pv_shm->current_task)
+		if (p->token != vcpu->arch.pv_shm->param)
 			continue;
 		list_del(&p->link);
 		found = true;
@@ -2370,7 +2370,7 @@ static bool kvm_asyc_pf_is_done(struct kvm_vcpu *vcpu)
 					  p->error_code);
 		put_page(p->page);
 		async_pf_work_free(p);
-		trace_kvm_mmu_async_pf_wait(vcpu->arch.pv_shm->current_task, 0);
+		trace_kvm_mmu_async_pf_wait(vcpu->arch.pv_shm->param, 0);
 	}
 	return found;
 }
@@ -2378,7 +2378,7 @@ static bool kvm_asyc_pf_is_done(struct kvm_vcpu *vcpu)
 int kvm_pv_wait_for_async_pf(struct kvm_vcpu *vcpu)
 {
 	++vcpu->stat.pf_async_wait;
-	trace_kvm_mmu_async_pf_wait(vcpu->arch.pv_shm->current_task, 1);
+	trace_kvm_mmu_async_pf_wait(vcpu->arch.pv_shm->param, 1);
 	wait_event(vcpu->wq, kvm_asyc_pf_is_done(vcpu));
 
 	return 0;
@@ -2386,17 +2386,13 @@ int kvm_pv_wait_for_async_pf(struct kvm_vcpu *vcpu)
 
 static bool can_do_async_pf(struct kvm_vcpu *vcpu)
 {
-	struct kvm_segment kvm_seg;
-
 	if (!vcpu->arch.pv_shm ||
 	    !(vcpu->arch.pv_shm->features & KVM_PV_SHM_FEATURES_ASYNC_PF) ||
-	    kvm_event_needs_reinjection(vcpu))
+	    kvm_event_needs_reinjection(vcpu) ||
+	    !kvm_x86_ops->interrupt_allowed(vcpu))
 		return false;
 
-	kvm_get_segment(vcpu, &kvm_seg, VCPU_SREG_CS);
-
-	/* is userspace code? TODO check VM86 mode */
-	return !!(kvm_seg.selector & 3);
+	return true;
 }
 
 static int setup_async_pf(struct kvm_vcpu *vcpu, gpa_t cr3, gva_t gva,
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
