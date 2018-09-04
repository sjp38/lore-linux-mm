Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id B4CE26B6C42
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 03:16:00 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 33-v6so1464664plf.19
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 00:16:00 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id y22-v6si20369023pgj.436.2018.09.04.00.15.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Sep 2018 00:15:59 -0700 (PDT)
Date: Tue, 4 Sep 2018 15:15:52 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH 1/5] [PATCH 1/5] kvm: register in task_struct
Message-ID: <20180904071552.f4cmxo7hwtjw22dc@wfg-t540p.sh.intel.com>
References: <D3FBF73C-3C33-4F94-8BBB-CE6C70B81A70@oracle.com>
 <0ef9ccdc-3eae-f0b9-5304-8552cb94d166@de.ibm.com>
 <20180904002818.nq2ejxlsn4o34anl@wfg-t540p.sh.intel.com>
 <20180904004621.aqhemgpefwtq3kif@wfg-t540p.sh.intel.com>
 <F0A5145C-E401-43E8-9FE9-56A4470CD13E@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <F0A5145C-E401-43E8-9FE9-56A4470CD13E@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikita Leshenko <nikita.leshchenko@oracle.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, akpm@linux-foundation.org, linux-mm@kvack.org, dongx.peng@intel.com, jingqi.liu@intel.com, eddie.dong@intel.com, dave.hansen@intel.com, ying.huang@intel.com, bgregg@netflix.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Sep 04, 2018 at 08:37:03AM +0200, Nikita Leshenko wrote:
>On 4 Sep 2018, at 2:46, Fengguang Wu <fengguang.wu@intel.com> wrote:
>>
>> Here it goes:
>>
>> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
>> index 99ce070e7dcb..27c5446f3deb 100644
>> --- a/include/linux/mm_types.h
>> +++ b/include/linux/mm_types.h
>> @@ -27,6 +27,7 @@ typedef int vm_fault_t;
>> struct address_space;
>> struct mem_cgroup;
>> struct hmm;
>> +struct kvm;
>> /*
>> * Each physical page in the system has a struct page associated with
>> @@ -489,10 +490,19 @@ struct mm_struct {
>> 	/* HMM needs to track a few things per mm */
>> 	struct hmm *hmm;
>> #endif
>> +#if IS_ENABLED(CONFIG_KVM)
>> +	struct kvm *kvm;
>> +#endif
>> } __randomize_layout;
>> extern struct mm_struct init_mm;
>> +#if IS_ENABLED(CONFIG_KVM)
>> +static inline struct kvm *mm_kvm(struct mm_struct *mm) { return mm->kvm; }
>> +#else
>> +static inline struct kvm *mm_kvm(struct mm_struct *mm) { return NULL; }
>> +#endif
>> +
>> static inline void mm_init_cpumask(struct mm_struct *mm)
>> {
>> #ifdef CONFIG_CPUMASK_OFFSTACK
>> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
>> index 0c483720de8d..dca6156a7b35 100644
>> --- a/virt/kvm/kvm_main.c
>> +++ b/virt/kvm/kvm_main.c
>> @@ -3892,7 +3892,7 @@ static void kvm_uevent_notify_change(unsigned int type, struct kvm *kvm)
>> 	if (type == KVM_EVENT_CREATE_VM) {
>> 		add_uevent_var(env, "EVENT=create");
>> 		kvm->userspace_pid = task_pid_nr(current);
>> -		current->kvm = kvm;
>> +		current->mm->kvm = kvm;
>I think you also need to reset kvm to NULL once the VM is
>destroyed, otherwise it would point to dangling memory.

Good point! Here is the incremental patch:

--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -3894,6 +3894,7 @@ static void kvm_uevent_notify_change(unsigned int type, struct kvm *kvm)
                kvm->userspace_pid = task_pid_nr(current);
                current->mm->kvm = kvm;
        } else if (type == KVM_EVENT_DESTROY_VM) {
+               current->mm->kvm = NULL;
                add_uevent_var(env, "EVENT=destroy");
        }
        add_uevent_var(env, "PID=%d", kvm->userspace_pid);

Thanks,
Fengguang
