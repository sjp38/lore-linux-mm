Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A31BF6B025D
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 12:25:25 -0400 (EDT)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v4 07/12] Maintain memslot version number
Date: Tue,  6 Jul 2010 19:24:55 +0300
Message-Id: <1278433500-29884-8-git-send-email-gleb@redhat.com>
In-Reply-To: <1278433500-29884-1-git-send-email-gleb@redhat.com>
References: <1278433500-29884-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

Code that depends on particular memslot layout can track changes and
adjust to new layout.

Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 include/linux/kvm_host.h |    1 +
 virt/kvm/kvm_main.c      |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
index e796326..64f62f1 100644
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -177,6 +177,7 @@ struct kvm {
 	raw_spinlock_t requests_lock;
 	struct mutex slots_lock;
 	struct mm_struct *mm; /* userspace tied to this vm */
+	u32 memslot_version;
 	struct kvm_memslots *memslots;
 	struct srcu_struct srcu;
 #ifdef CONFIG_KVM_APIC_ARCHITECTURE
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index a60b6b0..733558c 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -730,6 +730,7 @@ skip_lpage:
 	slots->memslots[mem->slot] = new;
 	old_memslots = kvm->memslots;
 	rcu_assign_pointer(kvm->memslots, slots);
+	kvm->memslot_version++;
 	synchronize_srcu_expedited(&kvm->srcu);
 
 	kvm_arch_commit_memory_region(kvm, mem, old, user_alloc);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
