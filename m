Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 77BDF6B5FD9
	for <linux-mm@kvack.org>; Sat,  1 Sep 2018 22:21:10 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id q12-v6so8859993pgp.6
        for <linux-mm@kvack.org>; Sat, 01 Sep 2018 19:21:10 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id d32-v6si13682201pla.93.2018.09.01.19.21.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Sep 2018 19:21:09 -0700 (PDT)
Message-Id: <20180901124811.469883138@intel.com>
Date: Sat, 01 Sep 2018 19:28:19 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [RFC][PATCH 1/5] [PATCH 1/5] kvm: register in task_struct
References: <20180901112818.126790961@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=0001-kvm-register-in-task_struct.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Fengguang Wu <fengguang.wu@intel.com>, Peng DongX <dongx.peng@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Huang Ying <ying.huang@intel.com>, Brendan Gregg <bgregg@netflix.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

The added pointer will be used by the /proc/PID/idle_bitmap code to
quickly identify QEMU task and walk EPT/NPT accordingly. For virtual
machines, the A bits will be set in guest page tables and EPT/NPT,
rather than the QEMU task page table.

This costs 8 bytes in task_struct which could be wasteful for the
majority normal tasks. The alternative is to add a flag only, and
let it find the corresponding VM in kvm vm_list.

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 include/linux/sched.h | 10 ++++++++++
 virt/kvm/kvm_main.c   |  1 +
 2 files changed, 11 insertions(+)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 43731fe51c97..26c8549bbc28 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -38,6 +38,7 @@ struct cfs_rq;
 struct fs_struct;
 struct futex_pi_state;
 struct io_context;
+struct kvm;
 struct mempolicy;
 struct nameidata;
 struct nsproxy;
@@ -1179,6 +1180,9 @@ struct task_struct {
 	/* Used by LSM modules for access restriction: */
 	void				*security;
 #endif
+#if IS_ENABLED(CONFIG_KVM)
+        struct kvm                      *kvm;
+#endif
 
 	/*
 	 * New fields for task_struct should be added above here, so that
@@ -1898,4 +1902,10 @@ static inline void rseq_syscall(struct pt_regs *regs)
 
 #endif
 
+#if IS_ENABLED(CONFIG_KVM)
+static inline struct kvm *task_kvm(struct task_struct *t) { return t->kvm; }
+#else
+static inline struct kvm *task_kvm(struct task_struct *t) { return NULL; }
+#endif
+
 #endif
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 8b47507faab5..0c483720de8d 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -3892,6 +3892,7 @@ static void kvm_uevent_notify_change(unsigned int type, struct kvm *kvm)
 	if (type == KVM_EVENT_CREATE_VM) {
 		add_uevent_var(env, "EVENT=create");
 		kvm->userspace_pid = task_pid_nr(current);
+		current->kvm = kvm;
 	} else if (type == KVM_EVENT_DESTROY_VM) {
 		add_uevent_var(env, "EVENT=destroy");
 	}
-- 
2.15.0
