Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id A72FD8E0006
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:07 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id y8so15205734pgq.12
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:07 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id e68si15371744pfb.101.2018.12.26.05.37.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:06 -0800 (PST)
Message-Id: <20181226133351.894160986@intel.com>
Date: Wed, 26 Dec 2018 21:15:00 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [RFC][PATCH v2 14/21] kvm: register in mm_struct
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=0009-kvm-register-in-mm_struct.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Nikita Leshenko <nikita.leshchenko@oracle.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Fengguang Wu <fengguang.wu@intel.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Fan Du <fan.du@intel.com>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

VM is associated with an address space and not a specific thread.

>>From Documentation/virtual/kvm/api.txt:
   Only run VM ioctls from the same process (address space) that was used
   to create the VM.

CC: Nikita Leshenko <nikita.leshchenko@oracle.com>
CC: Christian Borntraeger <borntraeger@de.ibm.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 include/linux/mm_types.h |   11 +++++++++++
 virt/kvm/kvm_main.c      |    3 +++
 2 files changed, 14 insertions(+)

--- linux.orig/include/linux/mm_types.h	2018-12-23 19:58:06.993417137 +0800
+++ linux/include/linux/mm_types.h	2018-12-23 19:58:06.993417137 +0800
@@ -27,6 +27,7 @@ typedef int vm_fault_t;
 struct address_space;
 struct mem_cgroup;
 struct hmm;
+struct kvm;
 
 /*
  * Each physical page in the system has a struct page associated with
@@ -496,6 +497,10 @@ struct mm_struct {
 		/* HMM needs to track a few things per mm */
 		struct hmm *hmm;
 #endif
+
+#if IS_ENABLED(CONFIG_KVM)
+		struct kvm *kvm;
+#endif
 	} __randomize_layout;
 
 	/*
@@ -507,6 +512,12 @@ struct mm_struct {
 
 extern struct mm_struct init_mm;
 
+#if IS_ENABLED(CONFIG_KVM)
+static inline struct kvm *mm_kvm(struct mm_struct *mm) { return mm->kvm; }
+#else
+static inline struct kvm *mm_kvm(struct mm_struct *mm) { return NULL; }
+#endif
+
 /* Pointer magic because the dynamic array size confuses some compilers. */
 static inline void mm_init_cpumask(struct mm_struct *mm)
 {
--- linux.orig/virt/kvm/kvm_main.c	2018-12-23 19:58:06.993417137 +0800
+++ linux/virt/kvm/kvm_main.c	2018-12-23 19:58:06.993417137 +0800
@@ -727,6 +727,7 @@ static void kvm_destroy_vm(struct kvm *k
 	struct mm_struct *mm = kvm->mm;
 
 	kvm_uevent_notify_change(KVM_EVENT_DESTROY_VM, kvm);
+	mm->kvm = NULL;
 	kvm_destroy_vm_debugfs(kvm);
 	kvm_arch_sync_events(kvm);
 	spin_lock(&kvm_lock);
@@ -3224,6 +3225,8 @@ static int kvm_dev_ioctl_create_vm(unsig
 		fput(file);
 		return -ENOMEM;
 	}
+
+	kvm->mm->kvm = kvm;
 	kvm_uevent_notify_change(KVM_EVENT_CREATE_VM, kvm);
 
 	fd_install(r, file);
