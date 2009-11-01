Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id CEC596B0062
	for <linux-mm@kvack.org>; Sun,  1 Nov 2009 06:56:36 -0500 (EST)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH 10/11] Handle async PF in non preemptable context.
Date: Sun,  1 Nov 2009 13:56:29 +0200
Message-Id: <1257076590-29559-11-git-send-email-gleb@redhat.com>
In-Reply-To: <1257076590-29559-1-git-send-email-gleb@redhat.com>
References: <1257076590-29559-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

If async page fault is received by idle task or when preemp_count is
not zero guest cannot reschedule, so make "wait for page" hypercall
and comtinue only after a page is ready.

Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 arch/x86/kernel/kvm.c |   16 +++++++++++++++-
 1 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/arch/x86/kernel/kvm.c b/arch/x86/kernel/kvm.c
index 79d291f..1bd8b8d 100644
--- a/arch/x86/kernel/kvm.c
+++ b/arch/x86/kernel/kvm.c
@@ -162,10 +162,24 @@ int kvm_handle_pf(struct pt_regs *regs, unsigned long error_code)
 	switch (reason) {
 	default:
 		return 0;
-	case KVM_PV_REASON_PAGE_NP:
+	case KVM_PV_REASON_PAGE_NP: {
+		int cpu, idle;
+		cpu = get_cpu();
+		idle = idle_cpu(cpu);
+		put_cpu();
+
+		/*
+		 * We cannot reschedule. Wait for page to be ready.
+		 */
+		if (idle || preempt_count()) {
+			kvm_hypercall0(KVM_HC_WAIT_FOR_ASYNC_PF);
+			break;
+		}
+
 		/* real page is missing. */
 		apf_task_wait(current, token);
 		break;
+	}
 	case KVM_PV_REASON_PAGE_READY:
 		apf_task_wake(token);
 		break;
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
