Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id F0F026B02F4
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 19:24:32 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id g11so3920599uah.7
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 16:24:32 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id p104si2691234uap.66.2017.08.30.16.24.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 16:24:31 -0700 (PDT)
Subject: Re: [PATCH v7 9/9] sparc64: Add support for ADI (Application Data
 Integrity)
References: <3a687666c2e7972fb6d2379848f31006ac1dd59a.1502219353.git.khalid.aziz@oracle.com>
 <F65BCC2D-8FA4-453F-8378-3369C44B0319@oracle.com>
 <7b8216b8-e732-0b31-a374-1a817d4fbc80@oracle.com>
 <20170830.153830.2267882580011615008.davem@davemloft.net>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <b5d9bbb2-a575-ee47-33aa-11994edef702@oracle.com>
Date: Wed, 30 Aug 2017 17:23:37 -0600
MIME-Version: 1.0
In-Reply-To: <20170830.153830.2267882580011615008.davem@davemloft.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: anthony.yznaga@oracle.com, dave.hansen@linux.intel.com, corbet@lwn.net, bob.picco@oracle.com, steven.sistare@oracle.com, pasha.tatashin@oracle.com, mike.kravetz@oracle.com, mingo@kernel.org, nitin.m.gupta@oracle.com, kirill.shutemov@linux.intel.com, tom.hromatka@oracle.com, eric.saint.etienne@oracle.com, allen.pais@oracle.com, cmetcalf@mellanox.com, akpm@linux-foundation.org, geert@linux-m68k.org, tklauser@distanz.ch, atish.patra@oracle.com, vijay.ac.kumar@oracle.com, peterz@infradead.org, mhocko@suse.com, jack@suse.cz, lstoakes@gmail.com, hughd@google.com, thomas.tai@oracle.com, paul.gortmaker@windriver.com, ross.zwisler@linux.intel.com, dave.jiang@intel.com, willy@infradead.org, ying.huang@intel.com, zhongjiang@huawei.com, minchan@kernel.org, vegard.nossum@oracle.com, imbrenda@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, khalid@gonehiking.org

On 08/30/2017 04:38 PM, David Miller wrote:
> From: Khalid Aziz <khalid.aziz@oracle.com>
> Date: Wed, 30 Aug 2017 16:27:54 -0600
> 
>>>> +#define arch_calc_vm_prot_bits(prot, pkey)
>>>> sparc_calc_vm_prot_bits(prot)
>>>> +static inline unsigned long sparc_calc_vm_prot_bits(unsigned long
>>>> prot)
>>>> +{
>>>> +	if (prot & PROT_ADI) {
>>>> +		struct pt_regs *regs;
>>>> +
>>>> +		if (!current->mm->context.adi) {
>>>> +			regs = task_pt_regs(current);
>>>> +			regs->tstate |= TSTATE_MCDE;
>>>> +			current->mm->context.adi = true;
>>> If a process is multi-threaded when it enables ADI on some memory for
>>> the first time, TSTATE_MCDE will only be set for the calling thread
>>> and it will not be possible to enable it for the other threads.
>>> One possible way to handle this is to enable TSTATE_MCDE for all user
>>> threads when they are initialized if adi_capable() returns true.
>>>
>>
>> Or set TSTATE_MCDE unconditionally here by removing "if
>> (!current->mm->context.adi)"?
> 
> I think you have to make "ADI enabled" a property of the mm_struct.
> 
> Then you can broadcast to mm->cpu_vm_mask a per-cpu interrupt that
> updates regs->tstate of a thread using 'mm' is currently executing.
> 
> And in the context switch code you set TSTATE_MCDE if it's not set
> already.
> 
> That should cover all threaded case.

That is an interesting idea. This would enable TSTATE_MCDE on all 
threads of a process as soon as one thread enables it. If we consider 
the case where the parent creates a shared memory area and spawns a 
bunch of threads. These threads access the shared memory without ADI 
enabled. Now one of the threads decides to enable ADI on the shared 
memory. As soon as it does that, we enable TSTATE_MCDE across all 
threads and since threads are all using the same TTE for the shared 
memory, every thread becomes subject to ADI verification. If one of the 
other threads was in the middle of accessing the shared memory, it will 
get a sigsegv. If we did not enable TSTATE_MCDE across all threads, it 
could have continued execution without fault. In other words, updating 
TSTATE_MCDE across all threads will eliminate the option of running some 
threads with ADI enabled and some not while accessing the same shared 
memory. This could be necessary at least for short periods of time 
before threads can communicate with each other and all switch to 
accessing shared memory with ADI enabled using same tag. Does that sound 
like a valid use case or am I off in the weeds here?

Thanks,
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
