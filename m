Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id D07C36B6ABB
	for <linux-mm@kvack.org>; Mon,  3 Sep 2018 20:46:28 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id p22-v6so1011807pfj.7
        for <linux-mm@kvack.org>; Mon, 03 Sep 2018 17:46:28 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id k64-v6si17884887pge.129.2018.09.03.17.46.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Sep 2018 17:46:27 -0700 (PDT)
Date: Tue, 4 Sep 2018 08:46:21 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH 1/5] [PATCH 1/5] kvm: register in task_struct
Message-ID: <20180904004621.aqhemgpefwtq3kif@wfg-t540p.sh.intel.com>
References: <D3FBF73C-3C33-4F94-8BBB-CE6C70B81A70@oracle.com>
 <0ef9ccdc-3eae-f0b9-5304-8552cb94d166@de.ibm.com>
 <20180904002818.nq2ejxlsn4o34anl@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20180904002818.nq2ejxlsn4o34anl@wfg-t540p.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Nikita Leshenko <nikita.leshchenko@oracle.com>, akpm@linux-foundation.org, linux-mm@kvack.org, dongx.peng@intel.com, jingqi.liu@intel.com, eddie.dong@intel.com, dave.hansen@intel.com, ying.huang@intel.com, bgregg@netflix.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Sep 04, 2018 at 08:28:18AM +0800, Fengguang Wu wrote:
>Hi Christian and Nikita,
>
>On Mon, Sep 03, 2018 at 06:03:49PM +0200, Christian Borntraeger wrote:
>>
>>
>>On 09/03/2018 04:10 PM, Nikita Leshenko wrote:
>>> On September 2, 2018 5:21:15 AM, fengguang.wu@intel.com wrote:
>>>> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
>>>> index 8b47507faab5..0c483720de8d 100644
>>>> --- a/virt/kvm/kvm_main.c
>>>> +++ b/virt/kvm/kvm_main.c
>>>> @@ -3892,6 +3892,7 @@ static void kvm_uevent_notify_change(unsigned int type, struct kvm *kvm)
>>>>  	if (type == KVM_EVENT_CREATE_VM) {
>>>>  		add_uevent_var(env, "EVENT=create");
>>>>  		kvm->userspace_pid = task_pid_nr(current);
>>>> +		current->kvm = kvm;
>>>
>>> Is it OK to store `kvm` on the task_struct? What if the thread that
>>> originally created the VM exits? From the documentation it seems
>>> like a VM is associated with an address space and not a specific
>>> thread, so maybe it should be stored on mm_struct?
>>
>>Yes, ioctls accessing the kvm can happen from all threads.
>
>Good point, thank you for the tips! I'll move kvm pointer to mm_struct.
>
>>> From Documentation/virtual/kvm/api.txt:
>>>    Only run VM ioctls from the same process (address space) that was used
>>>    to create the VM.
>>>
>>> -Nikita

Here it goes:

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 99ce070e7dcb..27c5446f3deb 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -27,6 +27,7 @@ typedef int vm_fault_t;
 struct address_space;
 struct mem_cgroup;
 struct hmm;
+struct kvm;
 
 /*
  * Each physical page in the system has a struct page associated with
@@ -489,10 +490,19 @@ struct mm_struct {
 	/* HMM needs to track a few things per mm */
 	struct hmm *hmm;
 #endif
+#if IS_ENABLED(CONFIG_KVM)
+	struct kvm *kvm;
+#endif
 } __randomize_layout;
 
 extern struct mm_struct init_mm;
 
+#if IS_ENABLED(CONFIG_KVM)
+static inline struct kvm *mm_kvm(struct mm_struct *mm) { return mm->kvm; }
+#else
+static inline struct kvm *mm_kvm(struct mm_struct *mm) { return NULL; }
+#endif
+
 static inline void mm_init_cpumask(struct mm_struct *mm)
 {
 #ifdef CONFIG_CPUMASK_OFFSTACK
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 0c483720de8d..dca6156a7b35 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -3892,7 +3892,7 @@ static void kvm_uevent_notify_change(unsigned int type, struct kvm *kvm)
 	if (type == KVM_EVENT_CREATE_VM) {
 		add_uevent_var(env, "EVENT=create");
 		kvm->userspace_pid = task_pid_nr(current);
-		current->kvm = kvm;
+		current->mm->kvm = kvm;
 	} else if (type == KVM_EVENT_DESTROY_VM) {
 		add_uevent_var(env, "EVENT=destroy");
 	}
