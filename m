Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1592B6B0003
	for <linux-mm@kvack.org>; Tue, 22 May 2018 12:06:10 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id g92-v6so12349657plg.6
        for <linux-mm@kvack.org>; Tue, 22 May 2018 09:06:10 -0700 (PDT)
Received: from mx141.netapp.com (mx141.netapp.com. [2620:10a:4005:8000:2306::a])
        by mx.google.com with ESMTPS id c2-v6si16292918plr.454.2018.05.22.09.06.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 09:06:07 -0700 (PDT)
Subject: Re: [PATCH] mm: Add new vma flag VM_LOCAL_CPU
References: <0efb5547-9250-6b6c-fe8e-cf4f44aaa5eb@netapp.com>
 <20180514191551.GA27939@bombadil.infradead.org>
 <7ec6fa37-8529-183d-d467-df3642bcbfd2@netapp.com>
 <20180515004137.GA5168@bombadil.infradead.org>
 <f3a66d8b-b9dc-b110-08aa-a63f0c309fb2@netapp.com>
 <010001637399f796-3ffe3ed2-2fb1-4d43-84f0-6a65b6320d66-000000@email.amazonses.com>
From: Boaz Harrosh <boazh@netapp.com>
Message-ID: <5aea6aa0-88cc-be7a-7012-7845499ced2c@netapp.com>
Date: Tue, 22 May 2018 19:05:48 +0300
MIME-Version: 1.0
In-Reply-To: <010001637399f796-3ffe3ed2-2fb1-4d43-84f0-6a65b6320d66-000000@email.amazonses.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>, Jeff Moyer <jmoyer@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.
 Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Amit Golander <Amit.Golander@netapp.com>

On 18/05/18 17:14, Christopher Lameter wrote:
> On Tue, 15 May 2018, Boaz Harrosh wrote:
> 
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
>>
>> So the all point of this flag is the kernel driver telling mm that this
>> address is enforced to only be accessed from one core-pinned thread.
> 
> But there are no provisions for probhiting accesses from other cores?
> 
> This means that a casual accidental write from a thread executing on
> another core can lead to arbitrary memory corruption because the cache
> flushing has been bypassed.
> 

No this is not accurate. A "casual accidental write" will not do any harm.
Only a well concerted malicious server can exploit this. A different thread
on a different core will need to hit the exact time to read from the exact
pointer at the narrow window while the IO is going on. fault-in a TLB at the
time of the valid mapping. Then later after the IO has ended and before any
of the threads where scheduled out, maliciously write. All the while the App
has freed its buffers and the buffer was used for something else.
Please bear in mind that this is only As root, in an /sbin/ executable signed
by the Kernel's key. I think that anyone who as gained such an access to the
system (i.e compiled and installed an /sbin server), Can just walk the front door.
He does not need to exploit this narrow random hole. Hell he can easily just
modprob a Kernel module.

And I do not understand. Every one is motivated in saying "no cannot be solved"
So lets start from the Beginning.

How can we implement "Private memory"?

You know how in the fork days. We have APIs for "shared memory".

I.E: All read/write memory defaults to private except special setup
     "shared memory"
This is vs Threads where all memory regions are shared.

[Q] How can we implement a "private memory" region.
.I.E All read/write memory defaults to shared except special setup
     "private memory"

Can this be done? How, please advise?

Thanks
Boaz
