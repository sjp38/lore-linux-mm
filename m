Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9CFAE6B0005
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 12:56:14 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id h89so18131913qtd.18
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 09:56:14 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id p60si719974qtd.1.2018.04.05.09.56.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Apr 2018 09:56:08 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w35Gtxwq001277
	for <linux-mm@kvack.org>; Thu, 5 Apr 2018 12:56:07 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2h5kt5v9fk-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 05 Apr 2018 12:56:06 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 5 Apr 2018 17:55:45 +0100
Subject: Re: [mm] b1f0502d04: INFO:trying_to_register_non-static_key
References: <20180317075119.u6yuem2bhxvggbz3@inn>
 <792c0f75-7e7f-cd81-44ae-4205f6e4affc@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1803251510040.80485@chino.kir.corp.google.com>
 <aa6f2ff1-ff67-106a-e0e4-522ac82a7bf0@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1804031748120.27686@chino.kir.corp.google.com>
 <147e8be3-2c33-2111-aacc-dc2bb932fa8c@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1804041451220.152749@chino.kir.corp.google.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Thu, 5 Apr 2018 18:55:35 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1804041451220.152749@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <d16459e8-de93-7261-d7e0-fe62160c04e0@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: kernel test robot <fengguang.wu@intel.com>, paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, lkp@01.org

On 04/04/2018 23:53, David Rientjes wrote:
> On Wed, 4 Apr 2018, Laurent Dufour wrote:
> 
>>> I also think the following is needed:
>>>
>>> diff --git a/fs/exec.c b/fs/exec.c
>>> --- a/fs/exec.c
>>> +++ b/fs/exec.c
>>> @@ -312,6 +312,10 @@ static int __bprm_mm_init(struct linux_binprm *bprm)
>>>  	vma->vm_flags = VM_SOFTDIRTY | VM_STACK_FLAGS | VM_STACK_INCOMPLETE_SETUP;
>>>  	vma->vm_page_prot = vm_get_page_prot(vma->vm_flags);
>>>  	INIT_LIST_HEAD(&vma->anon_vma_chain);
>>> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
>>> +	seqcount_init(&vma->vm_sequence);
>>> +	atomic_set(&vma->vm_ref_count, 0);
>>> +#endif
>>>
>>>  	err = insert_vm_struct(mm, vma);
>>>  	if (err)
>>
>> No, this not needed because the vma is allocated with kmem_cache_zalloc() so
>> vm_ref_count is 0, and insert_vm_struc() will later call
>> __vma_link_rb() which will call seqcount_init().
>>
>> Furhtermore, in case of error, the vma structure is freed without calling
>> get_vma() so there is risk of lockdep warning.
>>
> 
> Perhaps you're working from a different tree than I am, or you fixed the 
> lockdep warning differently when adding to dup_mmap() and mmap_region().
> 
> I got the following two lockdep errors.
> 
> I fixed it locally by doing the seqcount_init() and atomic_set() 
> everywhere a vma could be initialized.

That's weird, I don't get that on my side with lockdep activated.

There is a call to seqcount_init() in dup_mmap(), in mmap_region() and
__vma_link_rb() and that's enough to cover all the case.

That's being said, it'll be better call seqcount_init each time as soon as a
vma structure is allocated. For the vm_ref_count value, as most of the time the
vma is zero allocated, I don't think this is needed.
I just have to check when new_vma = *old_vma is done, but this often just
follow a vma allocation.
> 
> INFO: trying to register non-static key.
> the code is fine but needs lockdep annotation.
> turning off the locking correctness validator.
> CPU: 12 PID: 1 Comm: init Not tainted
> Call Trace:
>  [<ffffffff8b12026f>] dump_stack+0x67/0x98
>  [<ffffffff8a92b616>] register_lock_class+0x1e6/0x4e0
>  [<ffffffff8a92cfe9>] __lock_acquire+0xb9/0x1710
>  [<ffffffff8a92ef3a>] lock_acquire+0xba/0x200
>  [<ffffffff8aa827df>] mprotect_fixup+0x10f/0x310
>  [<ffffffff8aade3fd>] setup_arg_pages+0x12d/0x230
>  [<ffffffff8ab4564a>] load_elf_binary+0x44a/0x1740
>  [<ffffffff8aadde9b>] search_binary_handler+0x9b/0x1e0
>  [<ffffffff8ab44e96>] load_script+0x206/0x270
>  [<ffffffff8aadde9b>] search_binary_handler+0x9b/0x1e0
>  [<ffffffff8aae0355>] do_execveat_common.isra.32+0x6b5/0x9d0
>  [<ffffffff8aae069c>] do_execve+0x2c/0x30
>  [<ffffffff8a80047b>] run_init_process+0x2b/0x30
>  [<ffffffff8b1358d4>] kernel_init+0x54/0x110
>  [<ffffffff8b2001ca>] ret_from_fork+0x3a/0x50
> 
> and
> 
> INFO: trying to register non-static key.
> the code is fine but needs lockdep annotation.
> turning off the locking correctness validator.
> CPU: 21 PID: 1926 Comm: mkdir Not tainted
> Call Trace:
>  [<ffffffff985202af>] dump_stack+0x67/0x98
>  [<ffffffff97d2b616>] register_lock_class+0x1e6/0x4e0
>  [<ffffffff97d2cfe9>] __lock_acquire+0xb9/0x1710
>  [<ffffffff97d2ef3a>] lock_acquire+0xba/0x200
>  [<ffffffff97e73c09>] unmap_page_range+0x89/0xaa0
>  [<ffffffff97e746af>] unmap_single_vma+0x8f/0x100
>  [<ffffffff97e74a1b>] unmap_vmas+0x4b/0x90
>  [<ffffffff97e7f833>] exit_mmap+0xa3/0x1c0
>  [<ffffffff97cc1b23>] mmput+0x73/0x120
>  [<ffffffff97ccbacd>] do_exit+0x2bd/0xd60
>  [<ffffffff97ccc5b7>] SyS_exit+0x17/0x20
>  [<ffffffff97c01f1d>] do_syscall_64+0x6d/0x1a0
>  [<ffffffff9860005a>] entry_SYSCALL_64_after_hwframe+0x26/0x9b
> 
> I think it would just be better to generalize vma allocation to initialize 
> certain fields and init both spf fields properly for 
> CONFIG_SPECULATIVE_PAGE_FAULT.  It's obviously too delicate as is.
> 
