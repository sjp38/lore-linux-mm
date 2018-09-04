Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 25A7B6B6C5E
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 03:43:59 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id x145-v6so3246276oia.10
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 00:43:59 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r185-v6si13638519oif.34.2018.09.04.00.43.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Sep 2018 00:43:58 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w847eCIx159533
	for <linux-mm@kvack.org>; Tue, 4 Sep 2018 03:43:57 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2m9m1u4jv2-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Sep 2018 03:43:57 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Tue, 4 Sep 2018 08:43:55 +0100
Subject: Re: [RFC][PATCH 1/5] [PATCH 1/5] kvm: register in task_struct
References: <D3FBF73C-3C33-4F94-8BBB-CE6C70B81A70@oracle.com>
 <0ef9ccdc-3eae-f0b9-5304-8552cb94d166@de.ibm.com>
 <20180904002818.nq2ejxlsn4o34anl@wfg-t540p.sh.intel.com>
 <20180904004621.aqhemgpefwtq3kif@wfg-t540p.sh.intel.com>
 <F0A5145C-E401-43E8-9FE9-56A4470CD13E@oracle.com>
 <20180904071552.f4cmxo7hwtjw22dc@wfg-t540p.sh.intel.com>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Date: Tue, 4 Sep 2018 09:43:50 +0200
MIME-Version: 1.0
In-Reply-To: <20180904071552.f4cmxo7hwtjw22dc@wfg-t540p.sh.intel.com>
Content-Language: en-US
Message-Id: <45efb10a-a55a-b917-589c-de55e88ec18f@de.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>, Nikita Leshenko <nikita.leshchenko@oracle.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, dongx.peng@intel.com, jingqi.liu@intel.com, eddie.dong@intel.com, dave.hansen@intel.com, ying.huang@intel.com, bgregg@netflix.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org



On 09/04/2018 09:15 AM, Fengguang Wu wrote:
> On Tue, Sep 04, 2018 at 08:37:03AM +0200, Nikita Leshenko wrote:
>> On 4 Sep 2018, at 2:46, Fengguang Wu <fengguang.wu@intel.com> wrote:
>>>
>>> Here it goes:
>>>
>>> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
>>> index 99ce070e7dcb..27c5446f3deb 100644
>>> --- a/include/linux/mm_types.h
>>> +++ b/include/linux/mm_types.h
>>> @@ -27,6 +27,7 @@ typedef int vm_fault_t;
>>> struct address_space;
>>> struct mem_cgroup;
>>> struct hmm;
>>> +struct kvm;
>>> /*
>>> * Each physical page in the system has a struct page associated with
>>> @@ -489,10 +490,19 @@ struct mm_struct {
>>> A A A A /* HMM needs to track a few things per mm */
>>> A A A A struct hmm *hmm;
>>> #endif
>>> +#if IS_ENABLED(CONFIG_KVM)
>>> +A A A  struct kvm *kvm;
>>> +#endif
>>> } __randomize_layout;
>>> extern struct mm_struct init_mm;
>>> +#if IS_ENABLED(CONFIG_KVM)
>>> +static inline struct kvm *mm_kvm(struct mm_struct *mm) { return mm->kvm; }
>>> +#else
>>> +static inline struct kvm *mm_kvm(struct mm_struct *mm) { return NULL; }
>>> +#endif
>>> +
>>> static inline void mm_init_cpumask(struct mm_struct *mm)
>>> {
>>> #ifdef CONFIG_CPUMASK_OFFSTACK
>>> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
>>> index 0c483720de8d..dca6156a7b35 100644
>>> --- a/virt/kvm/kvm_main.c
>>> +++ b/virt/kvm/kvm_main.c
>>> @@ -3892,7 +3892,7 @@ static void kvm_uevent_notify_change(unsigned int type, struct kvm *kvm)
>>> A A A A if (type == KVM_EVENT_CREATE_VM) {
>>> A A A A A A A  add_uevent_var(env, "EVENT=create");
>>> A A A A A A A  kvm->userspace_pid = task_pid_nr(current);
>>> -A A A A A A A  current->kvm = kvm;
>>> +A A A A A A A  current->mm->kvm = kvm;
>> I think you also need to reset kvm to NULL once the VM is
>> destroyed, otherwise it would point to dangling memory.
> 
> Good point! Here is the incremental patch:
> 
> --- a/virt/kvm/kvm_main.c
> +++ b/virt/kvm/kvm_main.c
> @@ -3894,6 +3894,7 @@ static void kvm_uevent_notify_change(unsigned int type, struct kvm *kvm)
> A A A A A A A A A A A A A A  kvm->userspace_pid = task_pid_nr(current);
> A A A A A A A A A A A A A A  current->mm->kvm = kvm;
> A A A A A A  } else if (type == KVM_EVENT_DESTROY_VM) {
> +A A A A A A A A A A A A A A  current->mm->kvm = NULL;
> A A A A A A A A A A A A A A  add_uevent_var(env, "EVENT=destroy");
> A A A A A A  }
> A A A A A A  add_uevent_var(env, "PID=%d", kvm->userspace_pid);

I think you should put both code snippets somewhere else. This has probably nothing to do
with the uevent. Instead this should go into kvm_destroy_vm and kvm_create_vm. Make sure
to take care of the error handling.

Can you point us to the original discussion about the why and what you are
trying to achieve?
