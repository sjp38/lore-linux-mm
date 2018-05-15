Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id BFB256B0291
	for <linux-mm@kvack.org>; Tue, 15 May 2018 09:19:31 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id v26-v6so31839pgc.14
        for <linux-mm@kvack.org>; Tue, 15 May 2018 06:19:31 -0700 (PDT)
Received: from mx143.netapp.com (mx143.netapp.com. [2620:10a:4005:8000:2306::c])
        by mx.google.com with ESMTPS id v12-v6si15109pgs.538.2018.05.15.06.19.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 May 2018 06:19:28 -0700 (PDT)
Subject: Re: [PATCH] mm: Add new vma flag VM_LOCAL_CPU
References: <0efb5547-9250-6b6c-fe8e-cf4f44aaa5eb@netapp.com>
 <20180514191551.GA27939@bombadil.infradead.org>
 <7ec6fa37-8529-183d-d467-df3642bcbfd2@netapp.com>
 <20180515004137.GA5168@bombadil.infradead.org>
 <f3a66d8b-b9dc-b110-08aa-a63f0c309fb2@netapp.com>
 <20180515120750.lro2qbskw5cptc5o@lakrids.cambridge.arm.com>
From: Boaz Harrosh <boazh@netapp.com>
Message-ID: <a9a3af34-6ea0-5639-e9b9-2aa11825f11b@netapp.com>
Date: Tue, 15 May 2018 16:19:09 +0300
MIME-Version: 1.0
In-Reply-To: <20180515120750.lro2qbskw5cptc5o@lakrids.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Matthew Wilcox <willy@infradead.org>, Jeff Moyer <jmoyer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.
 Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van
 Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Amit Golander <Amit.Golander@netapp.com>

On 15/05/18 15:07, Mark Rutland wrote:
> On Tue, May 15, 2018 at 01:43:23PM +0300, Boaz Harrosh wrote:
>> On 15/05/18 03:41, Matthew Wilcox wrote:
>>> On Mon, May 14, 2018 at 10:37:38PM +0300, Boaz Harrosh wrote:
>>>> On 14/05/18 22:15, Matthew Wilcox wrote:
>>>>> On Mon, May 14, 2018 at 08:28:01PM +0300, Boaz Harrosh wrote:
>>>>>> On a call to mmap an mmap provider (like an FS) can put
>>>>>> this flag on vma->vm_flags.
>>>>>>
>>>>>> The VM_LOCAL_CPU flag tells the Kernel that the vma will be used
>>>>>> from a single-core only, and therefore invalidation (flush_tlb) of
>>>>>> PTE(s) need not be a wide CPU scheduling.
>>>>>
>>>>> I still don't get this.  You're opening the kernel up to being exploited
>>>>> by any application which can persuade it to set this flag on a VMA.
>>>>>
>>>>
>>>> No No this is not an application accessible flag this can only be set
>>>> by the mmap implementor at ->mmap() time (Say same as VM_VM_MIXEDMAP).
>>>>
>>>> Please see the zuf patches for usage (Again apologise for pushing before
>>>> a user)
>>>>
>>>> The mmap provider has all the facilities to know that this can not be
>>>> abused, not even by a trusted Server.
>>>
>>> I don't think page tables work the way you think they work.
>>>
>>> +               err = vm_insert_pfn_prot(zt->vma, zt_addr, pfn, prot);
>>>
>>> That doesn't just insert it into the local CPU's page table.  Any CPU
>>> which directly accesses or even prefetches that address will also get
>>> the translation into its cache.
>>>
>>
>> Yes I know, but that is exactly the point of this flag. I know that this
>> address is only ever accessed from a single core. Because it is an mmap (vma)
>> of an O_TMPFILE-exclusive file created in a core-pinned thread and I allow
>> only that thread any kind of access to this vma. Both the filehandle and the
>> mmaped pointer are kept on the thread stack and have no access from outside.
> 
> Even if (in the specific context of your application) software on other
> cores might not explicitly access this area, that does not prevent
> allocations into TLBs, and TLB maintenance *cannot* be elided.
> 
> Even assuming that software *never* explicitly accesses an address which
> it has not mapped is insufficient.
> 
> For example, imagine you have two threads, each pinned to a CPU, and
> some local_cpu_{mmap,munmap} which uses your new flag:
> 
> 	CPU0				CPU1
> 	x = local_cpu_mmap(...);
> 	do_things_with(x);
> 					// speculatively allocates TLB
> 					// entries for X.
> 
> 	// only invalidates local TLBs
> 	local_cpu_munmap(x);
> 
> 					// TLB entries for X still live
> 	
> 					y = local_cpu_mmap(...);
> 
> 					// if y == x, we can hit the

But this y == x is not possible. The x here is held throughout the
lifetime  of CPU0-pinned thread. And cannot be allocated later to
another thread.

In fact if that file holding the VMA closes we know the server
crashed and we cleanly close everything.
(Including properly zapping all maps)

> 					// stale TLB entry, and access
> 					// the wrong page
> 					do_things_with(y);
> 

So even if the CPU pre fetched that TLB no one in the system will use
this address until proper close. Where everything is properly flushed.

> Consider that after we free x, the kernel could reuse the page for any
> purpose (e.g. kernel page tables), so this is a major risk.
> 

So yes. We never free x. We hold it for the entire duration of the ZT-thread
(ZThread is that core-pinned thread per-core we are using)
And each time we map some application buffers into that vma and local_tlb
invalidate when done.

When x is de-allocated, do to a close or a crash, it is all properly zapped.

> This flag simply is not safe, unless the *entire* mm is only ever
> accessed from a single CPU. In that case, we don't need the flag anyway,
> as the mm already has a cpumask.
> 

Did you please see that other part of the thread, and my answer to Andrew?
why is the vma->vm_mm cpumask so weird. It is neither all bits set nor
a single bit set. It is very common (20% of the time) for mm_cpumask(vma->vm_mm)
to be a single bit set. Exactly in an application where I have a thread-per-core
Please look at that? (I'll ping you from that email)

> Thanks,
> Mark.
> 

Thanks
Boaz
