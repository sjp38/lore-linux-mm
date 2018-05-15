Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5908C6B0271
	for <linux-mm@kvack.org>; Tue, 15 May 2018 07:42:04 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e16-v6so13048820pfn.5
        for <linux-mm@kvack.org>; Tue, 15 May 2018 04:42:04 -0700 (PDT)
Received: from mx142.netapp.com (mx142.netapp.com. [2620:10a:4005:8000:2306::b])
        by mx.google.com with ESMTPS id a7-v6si9426285pgv.47.2018.05.15.04.42.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 May 2018 04:42:03 -0700 (PDT)
Subject: Re: [PATCH] mm: Add new vma flag VM_LOCAL_CPU
References: <0efb5547-9250-6b6c-fe8e-cf4f44aaa5eb@netapp.com>
 <20180514191551.GA27939@bombadil.infradead.org>
 <7ec6fa37-8529-183d-d467-df3642bcbfd2@netapp.com>
 <20180515004137.GA5168@bombadil.infradead.org>
 <f3a66d8b-b9dc-b110-08aa-a63f0c309fb2@netapp.com>
 <20180515111159.GA31599@bombadil.infradead.org>
From: Boaz Harrosh <boazh@netapp.com>
Message-ID: <6999e635-e804-99d0-12fc-c13ff3e9ca58@netapp.com>
Date: Tue, 15 May 2018 14:41:41 +0300
MIME-Version: 1.0
In-Reply-To: <20180515111159.GA31599@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jeff Moyer <jmoyer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.
 Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Amit Golander <Amit.Golander@netapp.com>

On 15/05/18 14:11, Matthew Wilcox wrote:
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
>>
>> Yes I know, but that is exactly the point of this flag. I know that this
>> address is only ever accessed from a single core. Because it is an mmap (vma)
>> of an O_TMPFILE-exclusive file created in a core-pinned thread and I allow
>> only that thread any kind of access to this vma. Both the filehandle and the
>> mmaped pointer are kept on the thread stack and have no access from outside.
>>
>> So the all point of this flag is the kernel driver telling mm that this
>> address is enforced to only be accessed from one core-pinned thread.
> 
> You're still thinking about this from the wrong perspective.  If you
> were writing a program to attack this facility, how would you do it?
> It's not exactly hard to leak one pointer's worth of information.
> 

That would be very hard. Because that program would:
- need to be root
- need to start and pretend it is zus Server with the all mount
  thread thing, register new filesystem, grab some pmem devices.
- Mount the said filesystem on said pmem. Create core-pinned ZT threads
  for all CPUs, start accepting IO.
- And only then it can start leaking the pointer and do bad things.
  The bad things it can do to the application, not to the Kernel.
  And as a full filesystem it can do those bad things to the application
  through the front door directly not needing the mismatch tlb at all.

That said. It brings up a very important point that I wanted to talk about.
In this design the zuf(Kernel) and the zus(um Server) are part of the distribution.
I would like to have the zus module be signed by the distro's Kernel's key and
checked on loadtime. I know there is an effort by Redhat guys to try and sign all
/sbin/* servers and have Kernel check these. So this is not the first time people
have thought about that.

Thanks
Boaz
