Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id ED9EA6B0033
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 08:03:57 -0400 (EDT)
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Mon, 10 Jun 2013 13:01:42 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 6D0342190023
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 13:07:11 +0100 (BST)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5AC3gSP50725090
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 12:03:42 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r5AC3qf2004597
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 06:03:52 -0600
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: [PATCH 1/4] PF: Add FAULT_FLAG_RETRY_NOWAIT for guest fault
Date: Mon, 10 Jun 2013 14:03:45 +0200
Message-Id: <1370865828-2053-2-git-send-email-dingel@linux.vnet.ibm.com>
In-Reply-To: <1370865828-2053-1-git-send-email-dingel@linux.vnet.ibm.com>
References: <1370865828-2053-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gleb Natapov <gleb@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, kvm@vger.kernel.org, linux-s390@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dominik Dingel <dingel@linux.vnet.ibm.com>

In case of a fault retry exit sie64a() with the gmap_fault indication set.
This makes it possbile to handle async page faults without the need for mm notifiers.

Based on a patch from Marin Schwidefsky.

Todo:
 - Add access to distinguish fault types to prevent double fault

Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
---
 arch/s390/include/asm/processor.h |  7 +++++++
 arch/s390/kvm/kvm-s390.c          | 15 +++++++++++++++
 arch/s390/mm/fault.c              | 29 +++++++++++++++++++++++++----
 arch/s390/mm/pgtable.c            |  1 +
 4 files changed, 48 insertions(+), 4 deletions(-)

diff --git a/arch/s390/include/asm/processor.h b/arch/s390/include/asm/processor.h
index 6b49987..938d92c 100644
--- a/arch/s390/include/asm/processor.h
+++ b/arch/s390/include/asm/processor.h
@@ -77,6 +77,13 @@ struct thread_struct {
         unsigned long ksp;              /* kernel stack pointer             */
 	mm_segment_t mm_segment;
 	unsigned long gmap_addr;	/* address of last gmap fault. */
+#define PFAULT_EN	1
+#define PFAULT_PEND	2
+	unsigned long gmap_pfault;	/*
+					 * indicator if pfault is enabled for a
+					 * guest and if a guest pfault is
+					 * pending
+					 */
 	struct per_regs per_user;	/* User specified PER registers */
 	struct per_event per_event;	/* Cause of the last PER trap */
 	unsigned long per_flags;	/* Flags to control debug behavior */
diff --git a/arch/s390/kvm/kvm-s390.c b/arch/s390/kvm/kvm-s390.c
index a44c0dc..c2ae2c4 100644
--- a/arch/s390/kvm/kvm-s390.c
+++ b/arch/s390/kvm/kvm-s390.c
@@ -706,6 +706,17 @@ static int kvm_s390_handle_requests(struct kvm_vcpu *vcpu)
 	return 0;
 }
 
+static void kvm_arch_fault_in_sync(struct kvm_vcpu *vcpu)
+{
+	hva_t fault_addr;
+	/* TODO let current->thread.gmap_pfault indicate read or write fault */
+	struct mm_struct *mm = current->mm;
+	down_read(&mm->mmap_sem);
+	fault_addr = __gmap_fault(current->thread.gmap_addr, vcpu->arch.gmap);
+	get_user_pages(current, mm, fault_addr, 1, 1, 0, NULL, NULL);
+	up_read(&mm->mmap_sem);
+}
+
 static int __vcpu_run(struct kvm_vcpu *vcpu)
 {
 	int rc;
@@ -739,6 +750,10 @@ static int __vcpu_run(struct kvm_vcpu *vcpu)
 	if (rc < 0) {
 		if (kvm_is_ucontrol(vcpu->kvm)) {
 			rc = SIE_INTERCEPT_UCONTROL;
+		} else if (test_bit(PFAULT_PEND,
+				    &current->thread.gmap_pfault)) {
+			kvm_arch_fault_in_sync(vcpu);
+			rc = 0;
 		} else {
 			VCPU_EVENT(vcpu, 3, "%s", "fault in sie instruction");
 			trace_kvm_s390_sie_fault(vcpu);
diff --git a/arch/s390/mm/fault.c b/arch/s390/mm/fault.c
index c5cfb6f..61b1644 100644
--- a/arch/s390/mm/fault.c
+++ b/arch/s390/mm/fault.c
@@ -50,6 +50,7 @@
 #define VM_FAULT_BADMAP		0x020000
 #define VM_FAULT_BADACCESS	0x040000
 #define VM_FAULT_SIGNAL		0x080000
+#define VM_FAULT_PFAULT		0x100000
 
 static unsigned long store_indication __read_mostly;
 
@@ -226,6 +227,7 @@ static noinline void do_fault_error(struct pt_regs *regs, int fault)
 			return;
 		}
 	case VM_FAULT_BADCONTEXT:
+	case VM_FAULT_PFAULT:
 		do_no_context(regs);
 		break;
 	case VM_FAULT_SIGNAL:
@@ -263,6 +265,9 @@ static noinline void do_fault_error(struct pt_regs *regs, int fault)
  */
 static inline int do_exception(struct pt_regs *regs, int access)
 {
+#ifdef CONFIG_PGSTE
+	struct gmap *gmap;
+#endif
 	struct task_struct *tsk;
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
@@ -301,9 +306,10 @@ static inline int do_exception(struct pt_regs *regs, int access)
 	down_read(&mm->mmap_sem);
 
 #ifdef CONFIG_PGSTE
-	if ((current->flags & PF_VCPU) && S390_lowcore.gmap) {
-		address = __gmap_fault(address,
-				     (struct gmap *) S390_lowcore.gmap);
+	gmap = (struct gmap *)
+		((current->flags & PF_VCPU) ? S390_lowcore.gmap : 0);
+	if (gmap) {
+		address = __gmap_fault(address, gmap);
 		if (address == -EFAULT) {
 			fault = VM_FAULT_BADMAP;
 			goto out_up;
@@ -312,6 +318,8 @@ static inline int do_exception(struct pt_regs *regs, int access)
 			fault = VM_FAULT_OOM;
 			goto out_up;
 		}
+		if (test_bit(PFAULT_EN, &current->thread.gmap_pfault))
+			flags |= FAULT_FLAG_RETRY_NOWAIT;
 	}
 #endif
 
@@ -368,9 +376,22 @@ retry:
 				      regs, address);
 		}
 		if (fault & VM_FAULT_RETRY) {
+#ifdef CONFIG_PGSTE
+			if (gmap &&
+			    test_bit(PFAULT_EN, &current->thread.gmap_pfault)) {
+				/* FAULT_FLAG_RETRY_NOWAIT has been set,
+				 * mmap_sem has not been released */
+				/* TODO use access to distinguish fault type */
+				set_bit(PFAULT_PEND,
+					&current->thread.gmap_pfault);
+				fault = VM_FAULT_PFAULT;
+				goto out_up;
+			}
+#endif
 			/* Clear FAULT_FLAG_ALLOW_RETRY to avoid any risk
 			 * of starvation. */
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
+			flags &= ~(FAULT_FLAG_ALLOW_RETRY |
+				   FAULT_FLAG_RETRY_NOWAIT);
 			flags |= FAULT_FLAG_TRIED;
 			down_read(&mm->mmap_sem);
 			goto retry;
diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
index 5fb7f19..14d067d 100644
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -540,6 +540,7 @@ unsigned long __gmap_fault(unsigned long address, struct gmap *gmap)
 	int rc;
 
 	current->thread.gmap_addr = address;
+	clear_bit(PFAULT_PEND, &current->thread.gmap_pfault);
 	segment_ptr = gmap_table_walk(address, gmap);
 	if (IS_ERR(segment_ptr))
 		return -EFAULT;
-- 
1.8.1.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
