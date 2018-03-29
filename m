Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 29BF16B0003
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 03:50:33 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id u9so132428qtg.2
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 00:50:33 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id v5si2578336qkb.257.2018.03.29.00.50.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Mar 2018 00:50:31 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2T7oIi9033763
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 03:50:30 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2h0s3px0hc-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 03:50:29 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 29 Mar 2018 08:50:24 +0100
Subject: Re: [PATCH v8 22/24] mm: Speculative page fault handler return VMA
References: <1518794738-4186-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1518794738-4186-23-git-send-email-ldufour@linux.vnet.ibm.com>
 <CADAEsF9RLY7Cf=xhW2zcM_a94OgpGFNEqZnkp1T-poP-wBT4Nw@mail.gmail.com>
 <CADAEsF8wRRG7CUFxTS49mj6mtxgJER+1x2u=0kTq+fQo5m+gTg@mail.gmail.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Thu, 29 Mar 2018 09:50:14 +0200
MIME-Version: 1.0
In-Reply-To: <CADAEsF8wRRG7CUFxTS49mj6mtxgJER+1x2u=0kTq+fQo5m+gTg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <e3622744-623f-ae7b-855d-4c1018a0bef5@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, kirill@shutemov.name, ak@linux.intel.com, Michal Hocko <mhocko@kernel.org>, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, Balbir Singh <bsingharora@gmail.com>, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 29/03/2018 05:06, Ganesh Mahendran wrote:
> 2018-03-29 10:26 GMT+08:00 Ganesh Mahendran <opensource.ganesh@gmail.com>:
>> Hi, Laurent
>>
>> 2018-02-16 23:25 GMT+08:00 Laurent Dufour <ldufour@linux.vnet.ibm.com>:
>>> When the speculative page fault handler is returning VM_RETRY, there is a
>>> chance that VMA fetched without grabbing the mmap_sem can be reused by the
>>> legacy page fault handler.  By reusing it, we avoid calling find_vma()
>>> again. To achieve, that we must ensure that the VMA structure will not be
>>> freed in our back. This is done by getting the reference on it (get_vma())
>>> and by assuming that the caller will call the new service
>>> can_reuse_spf_vma() once it has grabbed the mmap_sem.
>>>
>>> can_reuse_spf_vma() is first checking that the VMA is still in the RB tree
>>> , and then that the VMA's boundaries matched the passed address and release
>>> the reference on the VMA so that it can be freed if needed.
>>>
>>> In the case the VMA is freed, can_reuse_spf_vma() will have returned false
>>> as the VMA is no more in the RB tree.
>>
>> when I applied this patch to arm64, I got a crash:

Hi Ganesh,

Glad to see that you're enabling it on arm64.

I didn't give this arch a try, so feel free to propose patches on top of the
SPF series for this, I'll do my best to give them updated.

>>
>> [    6.088296] Unable to handle kernel NULL pointer dereference at
>> virtual address 00000000
>> [    6.088307] pgd = ffffff9d67735000
>> [    6.088313] [00000000] *pgd=00000001795e3003,
>> *pud=00000001795e3003, *pmd=0000000000000000
>> [    6.088372] ------------[ cut here ]------------
>> [    6.088377] Kernel BUG at ffffff9d64f65960 [verbose debug info unavailable]
>> [    6.088384] Internal error: Oops - BUG: 96000045 [#1] PREEMPT SMP
>> [    6.088389] BUG: Bad rss-counter state mm:ffffffe8f3861040 idx:0 val:90
>> [    6.088393] BUG: Bad rss-counter state mm:ffffffe8f3861040 idx:1 val:58
>> [    6.088398] Modules linked in:
>> [    6.088408] CPU: 1 PID: 621 Comm: qseecomd Not tainted 4.4.78-perf+ #88
>> [    6.088413] Hardware name: Qualcomm Technologies, Inc. SDM 636
>> PM660 + PM660L MTP E7S (DT)
>> [    6.088419] task: ffffffe8f6208000 ti: ffffffe872a8c000 task.ti:
>> ffffffe872a8c000
>> [    6.088432] PC is at __rb_erase_color+0x108/0x240
>> [    6.088441] LR is at vma_interval_tree_remove+0x244/0x24c
>> [    6.088447] pc : [<ffffff9d64f65960>] lr : [<ffffff9d64d9c2d8>]
>> pstate: 604001c5
>> [    6.088451] sp : ffffffe872a8fa50
>> [    6.088455] x29: ffffffe872a8fa50 x28: 0000000000000008
>> [    6.088462] x27: 0000000000000009 x26: 0000000000000000
>> [    6.088470] x25: ffffffe8f458fb80 x24: 000000768ff87000
>> [    6.088477] x23: 0000000000000000 x22: 0000000000000000
>> [    6.088484] x21: ffffff9d64d9be7c x20: ffffffe8f3ff0680
>> [    6.088492] x19: ffffffe8f212e9b0 x18: 0000000000000074
>> [    6.088499] x17: 0000000000000007 x16: 000000000000000e
>> [    6.088507] x15: ffffff9d65c88000 x14: 0000000000000001
>> [    6.088514] x13: 0000000000192d76 x12: 0000000000989680
>> [    6.088521] x11: 00000000001fffff x10: ffffff9d661ded1b
>> [    6.088528] x9 : 0000007691759000 x8 : 0000000007691759
>> [    6.088535] x7 : 0000000000000000 x6 : ffffffe871ebada8
>> [    6.088541] x5 : 00000000000000e1 x4 : ffffffe8f212e958
>> [    6.088548] x3 : 00000000000000e9 x2 : 0000000000000000
>> [    6.088555] x1 : ffffffe8f212f110 x0 : ffffffe8f212e9b1
>> [    6.088564]
>> [    6.088564] PC: 0xffffff9d64f65920:
>> [    6.088568] 5920  f9000002 aa0103e0 aa1603e1 d63f02a0 aa1603e1
>> f9400822 f9000662 f9000833
>> [    6.088590] 5940  1400003b f9400a61 f9400020 370002c0 f9400436
>> b2400260 f9000a76 f9000433
>> [    6.088610] 5960  f90002c0 f9400260 f9000020 f9000261 f27ef400
>> 54000100 f9400802 eb13005f
>> [    6.088630] 5980  54000061 f9000801 14000004 f9000401 14000002
>> f9000281 aa1303e0 d63f02a0
>> [    6.088652]
>> [    6.088652] LR: 0xffffff9d64d9c298:
>> [    6.088656] c298  f9403083 b4000083 f9400c63 eb03005f 9a832042
>> f9403883 eb02007f 540000a0
>> [    6.088676] c2b8  f9003882 f9402c82 927ef442 b5fffd22 b4000080
>> f0ffffe2 9139f042 94072561
>> [    6.088695] c2d8  a8c17bfd d65f03c0 a9bf7bfd 910003fd f9400003
>> d2800000 b40000e3 f9400c65
>> [    6.088715] c2f8  d1016063 eb0100bf 54000063 aa0303e0 97fffef2
>> a8c17bfd d65f03c0 a9bf7bfd
>> [    6.088735]
>> [    6.088735] SP: 0xffffffe872a8fa10:
>> [    6.088740] fa10  64d9c2d8 ffffff9d 72a8fa50 ffffffe8 64f65960
>> ffffff9d 604001c5 00000000
>> [    6.088759] fa30  71d67d70 ffffffe8 71c281e8 ffffffe8 00000000
>> 00000080 64daa90c ffffff9d
>> [    6.088779] fa50  72a8fa90 ffffffe8 64d9c2d8 ffffff9d 71ebada8
>> ffffffe8 f3ff0678 ffffffe8
>> [    6.088799] fa70  72a8fb80 ffffffe8 00000000 00000000 00000000
>> 00000000 00000001 00000000
>> [    6.088818]
>> [    6.088823] Process qseecomd (pid: 621, stack limit = 0xffffffe872a8c028)
>> [    6.088828] Call trace:
>> [    6.088834] Exception stack(0xffffffe872a8f860 to 0xffffffe872a8f990)
>> [    6.088841] f860: ffffffe8f212e9b0 0000008000000000
>> 0000000082b37000 ffffff9d64f65960
>> [    6.088848] f880: 00000000604001c5 ffffff9d672c8680
>> ffffff9d672c9c00 ffffff9d672d3ab7
>> [    6.088855] f8a0: ffffffe872a8f8f0 ffffff9d64db9bfc
>> 0000000000000000 ffffffe8f9402c00
>> [    6.088861] f8c0: ffffffe872a8c000 0000000000000000
>> ffffffe872a8f920 ffffff9d64db9bfc
>> [    6.088867] f8e0: 0000000000000000 ffffffe8f9402b00
>> ffffffe872a8fa10 ffffff9d64dba568
>> [    6.088874] f900: ffffffbe61c759c0 ffffffe871d67d70
>> ffffffe8f9402c00 1de56fb006cba396
>> [    6.088881] f920: ffffffe8f212e9b1 ffffffe8f212f110
>> 0000000000000000 00000000000000e9
>> [    6.088888] f940: ffffffe8f212e958 00000000000000e1
>> ffffffe871ebada8 0000000000000000
>> [    6.088895] f960: 0000000007691759 0000007691759000
>> ffffff9d661ded1b 00000000001fffff
>> [    6.088901] f980: 0000000000989680 0000000000192d76
>> [    6.088908] [<ffffff9d64f65960>] __rb_erase_color+0x108/0x240
>> [    6.088915] [<ffffff9d64d9c2d8>] vma_interval_tree_remove+0x244/0x24c
>> [    6.088924] [<ffffff9d64da4b5c>] __remove_shared_vm_struct+0x74/0x88
>> [    6.088930] [<ffffff9d64da52b8>] unlink_file_vma+0x40/0x54
>> [    6.088937] [<ffffff9d64d9f928>] free_pgtables+0xb8/0xfc
>> [    6.088945] [<ffffff9d64da6b84>] exit_mmap+0x78/0x13c
>> [    6.088953] [<ffffff9d64c9f5f4>] mmput+0x40/0xe8
>> [    6.088961] [<ffffff9d64ca5af0>] do_exit+0x3ac/0x8d8
>> [    6.088966] [<ffffff9d64ca6090>] do_group_exit+0x44/0x9c
>> [    6.088974] [<ffffff9d64cb10d0>] get_signal+0x4e8/0x524
>> [    6.088981] [<ffffff9d64c87ea0>] do_signal+0xac/0x93c
>> [    6.088989] [<ffffff9d64c88a0c>] do_notify_resume+0x18/0x58
>> [    6.088995] [<ffffff9d64c83038>] work_pending+0x10/0x14
>> [    6.089003] Code: f9400436 b2400260 f9000a76 f9000433 (f90002c0)
>> [    6.089009] ---[ end trace 224ce5f97841b6a5 ]---
>> [    6.110819] Kernel panic - not syncing: Fatal exception
>>
>> Thanks.
> 
> Fixed by below patch:

I guess you don't have only the following patch to enable that feature on arm64...

Please send the complete set of patch so that I could review this.

Thanks,
Laurent.

> 
> diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
> index f6838c0..9c61b0e 100644
> --- a/arch/arm64/mm/fault.c
> +++ b/arch/arm64/mm/fault.c
> @@ -240,18 +240,18 @@
> 
>  static int __do_page_fault(struct mm_struct *mm, unsigned long addr,
>     unsigned int mm_flags, unsigned long vm_flags,
> -   struct task_struct *tsk, struct vm_area_struct *spf_vma)
> +   struct task_struct *tsk, struct vm_area_struct **spf_vma)
>  {
>   struct vm_area_struct *vma;
>   int fault;
> 
>  #ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> - if (spf_vma) {
> - if (can_reuse_spf_vma(spf_vma, addr))
> - vma = spf_vma;
> + if (*spf_vma) {
> + if (can_reuse_spf_vma(*spf_vma, addr))
> + vma = *spf_vma;
>   else
>   vma =  find_vma(mm, addr);
> - spf_vma = NULL;
> + *spf_vma = NULL;
>   } else
>  #endif
>   vma = find_vma(mm, addr);
> @@ -393,7 +389,7 @@
>  #endif
>   }
> 
> - fault = __do_page_fault(mm, addr, mm_flags, vm_flags, tsk, spf_vma);
> + fault = __do_page_fault(mm, addr, mm_flags, vm_flags, tsk, &spf_vma);
> 
>   /*
>   * If we need to retry but a fatal signal is pending, handle the
> @@ -480,6 +476,11 @@
>   return 0;
> 
>  no_context:
> + if (spf_vma) {
> + put_vma(spf_vma);
> + spf_vma = NULL;
> + }
> +
>   __do_kernel_fault(mm, addr, esr, regs);
>   return 0;
>  }
> 
> 
>>
>>>
>>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>>> ---
>>>  include/linux/mm.h |   5 +-
>>>  mm/memory.c        | 136 +++++++++++++++++++++++++++++++++--------------------
>>>  2 files changed, 88 insertions(+), 53 deletions(-)
>>>
>>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>>> index c383a4e2ceb3..0cd31a37bb3d 100644
>>> --- a/include/linux/mm.h
>>> +++ b/include/linux/mm.h
>>> @@ -1355,7 +1355,10 @@ extern int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
>>>                 unsigned int flags);
>>>  #ifdef CONFIG_SPECULATIVE_PAGE_FAULT
>>>  extern int handle_speculative_fault(struct mm_struct *mm,
>>> -                                   unsigned long address, unsigned int flags);
>>> +                                   unsigned long address, unsigned int flags,
>>> +                                   struct vm_area_struct **vma);
>>> +extern bool can_reuse_spf_vma(struct vm_area_struct *vma,
>>> +                             unsigned long address);
>>>  #endif /* CONFIG_SPECULATIVE_PAGE_FAULT */
>>>  extern int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
>>>                             unsigned long address, unsigned int fault_flags,
>>> diff --git a/mm/memory.c b/mm/memory.c
>>> index 2ef686405154..1f5ce5ff79af 100644
>>> --- a/mm/memory.c
>>> +++ b/mm/memory.c
>>> @@ -4307,13 +4307,22 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
>>>  /* This is required by vm_normal_page() */
>>>  #error "Speculative page fault handler requires __HAVE_ARCH_PTE_SPECIAL"
>>>  #endif
>>> -
>>>  /*
>>>   * vm_normal_page() adds some processing which should be done while
>>>   * hodling the mmap_sem.
>>>   */
>>> +
>>> +/*
>>> + * Tries to handle the page fault in a speculative way, without grabbing the
>>> + * mmap_sem.
>>> + * When VM_FAULT_RETRY is returned, the vma pointer is valid and this vma must
>>> + * be checked later when the mmap_sem has been grabbed by calling
>>> + * can_reuse_spf_vma().
>>> + * This is needed as the returned vma is kept in memory until the call to
>>> + * can_reuse_spf_vma() is made.
>>> + */
>>>  int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
>>> -                            unsigned int flags)
>>> +                            unsigned int flags, struct vm_area_struct **vma)
>>>  {
>>>         struct vm_fault vmf = {
>>>                 .address = address,
>>> @@ -4322,7 +4331,6 @@ int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
>>>         p4d_t *p4d, p4dval;
>>>         pud_t pudval;
>>>         int seq, ret = VM_FAULT_RETRY;
>>> -       struct vm_area_struct *vma;
>>>  #ifdef CONFIG_NUMA
>>>         struct mempolicy *pol;
>>>  #endif
>>> @@ -4331,14 +4339,16 @@ int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
>>>         flags &= ~(FAULT_FLAG_ALLOW_RETRY|FAULT_FLAG_KILLABLE);
>>>         flags |= FAULT_FLAG_SPECULATIVE;
>>>
>>> -       vma = get_vma(mm, address);
>>> -       if (!vma)
>>> +       *vma = get_vma(mm, address);
>>> +       if (!*vma)
>>>                 return ret;
>>> +       vmf.vma = *vma;
>>>
>>> -       seq = raw_read_seqcount(&vma->vm_sequence); /* rmb <-> seqlock,vma_rb_erase() */
>>> +       /* rmb <-> seqlock,vma_rb_erase() */
>>> +       seq = raw_read_seqcount(&vmf.vma->vm_sequence);
>>>         if (seq & 1) {
>>> -               trace_spf_vma_changed(_RET_IP_, vma, address);
>>> -               goto out_put;
>>> +               trace_spf_vma_changed(_RET_IP_, vmf.vma, address);
>>> +               return ret;
>>>         }
>>>
>>>         /*
>>> @@ -4346,9 +4356,9 @@ int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
>>>          * with the VMA.
>>>          * This include huge page from hugetlbfs.
>>>          */
>>> -       if (vma->vm_ops) {
>>> -               trace_spf_vma_notsup(_RET_IP_, vma, address);
>>> -               goto out_put;
>>> +       if (vmf.vma->vm_ops) {
>>> +               trace_spf_vma_notsup(_RET_IP_, vmf.vma, address);
>>> +               return ret;
>>>         }
>>>
>>>         /*
>>> @@ -4356,18 +4366,18 @@ int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
>>>          * because vm_next and vm_prev must be safe. This can't be guaranteed
>>>          * in the speculative path.
>>>          */
>>> -       if (unlikely(!vma->anon_vma)) {
>>> -               trace_spf_vma_notsup(_RET_IP_, vma, address);
>>> -               goto out_put;
>>> +       if (unlikely(!vmf.vma->anon_vma)) {
>>> +               trace_spf_vma_notsup(_RET_IP_, vmf.vma, address);
>>> +               return ret;
>>>         }
>>>
>>> -       vmf.vma_flags = READ_ONCE(vma->vm_flags);
>>> -       vmf.vma_page_prot = READ_ONCE(vma->vm_page_prot);
>>> +       vmf.vma_flags = READ_ONCE(vmf.vma->vm_flags);
>>> +       vmf.vma_page_prot = READ_ONCE(vmf.vma->vm_page_prot);
>>>
>>>         /* Can't call userland page fault handler in the speculative path */
>>>         if (unlikely(vmf.vma_flags & VM_UFFD_MISSING)) {
>>> -               trace_spf_vma_notsup(_RET_IP_, vma, address);
>>> -               goto out_put;
>>> +               trace_spf_vma_notsup(_RET_IP_, vmf.vma, address);
>>> +               return ret;
>>>         }
>>>
>>>         if (vmf.vma_flags & VM_GROWSDOWN || vmf.vma_flags & VM_GROWSUP) {
>>> @@ -4376,48 +4386,39 @@ int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
>>>                  * boundaries but we want to trace it as not supported instead
>>>                  * of changed.
>>>                  */
>>> -               trace_spf_vma_notsup(_RET_IP_, vma, address);
>>> -               goto out_put;
>>> +               trace_spf_vma_notsup(_RET_IP_, vmf.vma, address);
>>> +               return ret;
>>>         }
>>>
>>> -       if (address < READ_ONCE(vma->vm_start)
>>> -           || READ_ONCE(vma->vm_end) <= address) {
>>> -               trace_spf_vma_changed(_RET_IP_, vma, address);
>>> -               goto out_put;
>>> +       if (address < READ_ONCE(vmf.vma->vm_start)
>>> +           || READ_ONCE(vmf.vma->vm_end) <= address) {
>>> +               trace_spf_vma_changed(_RET_IP_, vmf.vma, address);
>>> +               return ret;
>>>         }
>>>
>>> -       if (!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE,
>>> +       if (!arch_vma_access_permitted(vmf.vma, flags & FAULT_FLAG_WRITE,
>>>                                        flags & FAULT_FLAG_INSTRUCTION,
>>> -                                      flags & FAULT_FLAG_REMOTE)) {
>>> -               trace_spf_vma_access(_RET_IP_, vma, address);
>>> -               ret = VM_FAULT_SIGSEGV;
>>> -               goto out_put;
>>> -       }
>>> +                                      flags & FAULT_FLAG_REMOTE))
>>> +               goto out_segv;
>>>
>>>         /* This is one is required to check that the VMA has write access set */
>>>         if (flags & FAULT_FLAG_WRITE) {
>>> -               if (unlikely(!(vmf.vma_flags & VM_WRITE))) {
>>> -                       trace_spf_vma_access(_RET_IP_, vma, address);
>>> -                       ret = VM_FAULT_SIGSEGV;
>>> -                       goto out_put;
>>> -               }
>>> -       } else if (unlikely(!(vmf.vma_flags & (VM_READ|VM_EXEC|VM_WRITE)))) {
>>> -               trace_spf_vma_access(_RET_IP_, vma, address);
>>> -               ret = VM_FAULT_SIGSEGV;
>>> -               goto out_put;
>>> -       }
>>> +               if (unlikely(!(vmf.vma_flags & VM_WRITE)))
>>> +                       goto out_segv;
>>> +       } else if (unlikely(!(vmf.vma_flags & (VM_READ|VM_EXEC|VM_WRITE))))
>>> +               goto out_segv;
>>>
>>>  #ifdef CONFIG_NUMA
>>>         /*
>>>          * MPOL_INTERLEAVE implies additional check in mpol_misplaced() which
>>>          * are not compatible with the speculative page fault processing.
>>>          */
>>> -       pol = __get_vma_policy(vma, address);
>>> +       pol = __get_vma_policy(vmf.vma, address);
>>>         if (!pol)
>>>                 pol = get_task_policy(current);
>>>         if (pol && pol->mode == MPOL_INTERLEAVE) {
>>> -               trace_spf_vma_notsup(_RET_IP_, vma, address);
>>> -               goto out_put;
>>> +               trace_spf_vma_notsup(_RET_IP_, vmf.vma, address);
>>> +               return ret;
>>>         }
>>>  #endif
>>>
>>> @@ -4479,9 +4480,8 @@ int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
>>>                 vmf.pte = NULL;
>>>         }
>>>
>>> -       vmf.vma = vma;
>>> -       vmf.pgoff = linear_page_index(vma, address);
>>> -       vmf.gfp_mask = __get_fault_gfp_mask(vma);
>>> +       vmf.pgoff = linear_page_index(vmf.vma, address);
>>> +       vmf.gfp_mask = __get_fault_gfp_mask(vmf.vma);
>>>         vmf.sequence = seq;
>>>         vmf.flags = flags;
>>>
>>> @@ -4491,16 +4491,22 @@ int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
>>>          * We need to re-validate the VMA after checking the bounds, otherwise
>>>          * we might have a false positive on the bounds.
>>>          */
>>> -       if (read_seqcount_retry(&vma->vm_sequence, seq)) {
>>> -               trace_spf_vma_changed(_RET_IP_, vma, address);
>>> -               goto out_put;
>>> +       if (read_seqcount_retry(&vmf.vma->vm_sequence, seq)) {
>>> +               trace_spf_vma_changed(_RET_IP_, vmf.vma, address);
>>> +               return ret;
>>>         }
>>>
>>>         mem_cgroup_oom_enable();
>>>         ret = handle_pte_fault(&vmf);
>>>         mem_cgroup_oom_disable();
>>>
>>> -       put_vma(vma);
>>> +       /*
>>> +        * If there is no need to retry, don't return the vma to the caller.
>>> +        */
>>> +       if (!(ret & VM_FAULT_RETRY)) {
>>> +               put_vma(vmf.vma);
>>> +               *vma = NULL;
>>> +       }
>>>
>>>         /*
>>>          * The task may have entered a memcg OOM situation but
>>> @@ -4513,9 +4519,35 @@ int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
>>>         return ret;
>>>
>>>  out_walk:
>>> -       trace_spf_vma_notsup(_RET_IP_, vma, address);
>>> +       trace_spf_vma_notsup(_RET_IP_, vmf.vma, address);
>>>         local_irq_enable();
>>> -out_put:
>>> +       return ret;
>>> +
>>> +out_segv:
>>> +       trace_spf_vma_access(_RET_IP_, vmf.vma, address);
>>> +       /*
>>> +        * We don't return VM_FAULT_RETRY so the caller is not expected to
>>> +        * retrieve the fetched VMA.
>>> +        */
>>> +       put_vma(vmf.vma);
>>> +       *vma = NULL;
>>> +       return VM_FAULT_SIGSEGV;
>>> +}
>>> +
>>> +/*
>>> + * This is used to know if the vma fetch in the speculative page fault handler
>>> + * is still valid when trying the regular fault path while holding the
>>> + * mmap_sem.
>>> + * The call to put_vma(vma) must be made after checking the vma's fields, as
>>> + * the vma may be freed by put_vma(). In such a case it is expected that false
>>> + * is returned.
>>> + */
>>> +bool can_reuse_spf_vma(struct vm_area_struct *vma, unsigned long address)
>>> +{
>>> +       bool ret;
>>> +
>>> +       ret = !RB_EMPTY_NODE(&vma->vm_rb) &&
>>> +               vma->vm_start <= address && address < vma->vm_end;
>>>         put_vma(vma);
>>>         return ret;
>>>  }
>>> --
>>> 2.7.4
>>>
> 
