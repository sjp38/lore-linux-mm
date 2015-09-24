Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id 136E76B0262
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 12:30:41 -0400 (EDT)
Received: by oixx17 with SMTP id x17so44226648oix.0
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 09:30:40 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id m184si1446445oib.35.2015.09.24.09.30.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Sep 2015 09:30:40 -0700 (PDT)
Message-ID: <5604247A.7010303@oracle.com>
Date: Thu, 24 Sep 2015 12:27:38 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: Multiple potential races on vma->vm_flags
References: <CAAeHK+z8o96YeRF-fQXmoApOKXa0b9pWsQHDeP=5GC_hMTuoDg@mail.gmail.com> <55EC9221.4040603@oracle.com> <20150907114048.GA5016@node.dhcp.inet.fi> <55F0D5B2.2090205@oracle.com> <20150910083605.GB9526@node.dhcp.inet.fi> <CAAeHK+xSFfgohB70qQ3cRSahLOHtamCftkEChEgpFpqAjb7Sjg@mail.gmail.com> <20150911103959.GA7976@node.dhcp.inet.fi> <alpine.LSU.2.11.1509111734480.7660@eggly.anvils> <55F8572D.8010409@oracle.com> <20150924131141.GA7623@redhat.com>
In-Reply-To: <20150924131141.GA7623@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrey Konovalov <andreyknvl@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

On 09/24/2015 09:11 AM, Oleg Nesterov wrote:
> On 09/15, Sasha Levin wrote:
>>
>> I've modified my tests to stress the exit path of processes with many vmas,
>> and hit the following NULL ptr deref (not sure if it's related to the original issue):
> 
> I am shy to ask. Looks like I am the only stupid one who needs
> more info...
> 
>> [1181047.935563] kasan: GPF could be caused by NULL-ptr deref or user memory accessgeneral protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC KASAN
> 
> Well, I know absolutely nothing about kasan, to the point I can't even
> unserstand where does this message come from. grep didn't help. But this
> doesn't matter...

The reason behind this message is that NULL ptr derefs when using kasan are
manifested as GFPs. This is because in order to validate an access to a given
memory address kasan would check (shadow_base + (mem_offset >> 3)), so in the case of
a NULL it would try to access shadow_base + 0, which would GFP.

>> [1181047.937223] Modules linked in:
>> [1181047.937772] CPU: 4 PID: 21912 Comm: trinity-c341 Not tainted 4.3.0-rc1-next-20150914-sasha-00043-geddd763-dirty #2554
>> [1181047.939387] task: ffff8804195c8000 ti: ffff880433f00000 task.ti: ffff880433f00000
>> [1181047.940533] RIP: unmap_vmas (mm/memory.c:1337)
> 
> I do not know which tree/branch do you use. In Linus's tree mm/memory.c:1337 is

I'm running -next + Kirill's THP patchset.

> 	struct mm_struct *mm = vma->vm_mm;

void unmap_vmas(struct mmu_gather *tlb,
                struct vm_area_struct *vma, unsigned long start_addr,
                unsigned long end_addr)
{
        struct mm_struct *mm = vma->vm_mm;

        mmu_notifier_invalidate_range_start(mm, start_addr, end_addr);
        for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next)
                unmap_single_vma(tlb, vma, start_addr, end_addr, NULL); <--- this
        mmu_notifier_invalidate_range_end(mm, start_addr, end_addr);
}

> but this doesn't match the asm below,
> 
>>    0:   08 80 3c 02 00 0f       or     %al,0xf00023c(%rax)
>>    6:   85 22                   test   %esp,(%rdx)
>>    8:   01 00                   add    %eax,(%rax)
>>    a:   00 48 8b                add    %cl,-0x75(%rax)
>>    d:   43                      rex.XB
>>    e:   40                      rex
>>    f:   48 8d b8 c8 04 00 00    lea    0x4c8(%rax),%rdi
>>   16:   48 89 45 d0             mov    %rax,-0x30(%rbp)
>>   1a:   48 b8 00 00 00 00 00    movabs $0xdffffc0000000000,%rax
>>   21:   fc ff df
>>   24:   48 89 fa                mov    %rdi,%rdx
>>   27:   48 c1 ea 03             shr    $0x3,%rdx
>>   2b:*  80 3c 02 00             cmpb   $0x0,(%rdx,%rax,1)               <-- trapping instruction
>>   2f:   0f 85 ee 00 00 00       jne    0x123
>>   35:   48 8b 45 d0             mov    -0x30(%rbp),%rax
>>   39:   48 83 b8 c8 04 00 00    cmpq   $0x0,0x4c8(%rax)
>>   40:   00
> 
> And I do not see anything similar in "objdump -d". So could you at least
> show mm/memory.c:1337 in your tree?
> 
> Hmm. movabs $0xdffffc0000000000,%rax above looks suspicious, this looks
> like kasan_mem_to_shadow(). So perhaps this code was generated by kasan?
> (I can't check, my gcc is very old). Or what?

This is indeed kasan code. 0xdffffc0000000000 is the shadow base, and you see
kasan trying to access shadow base + (ptr >> 3), which is why we get GFP.

Looking at the assembly, the address we were trying to access was:

 RDI: 00000000000004c8

> Any chance you can tell us where exactly we hit NULL-deref in unmap_vmas?

I hope the information above helped, please let me know if it didn't and you
need anything else.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
