Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id A60286B0038
	for <linux-mm@kvack.org>; Wed, 14 May 2014 17:18:08 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id rd3so111048pab.35
        for <linux-mm@kvack.org>; Wed, 14 May 2014 14:18:08 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id uk7si3110922pac.102.2014.05.14.14.18.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 14 May 2014 14:18:07 -0700 (PDT)
Message-ID: <5373DBE4.6030907@oracle.com>
Date: Wed, 14 May 2014 17:11:00 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: NULL ptr deref handling mmaping of special mappings
References: <53739201.6080604@oracle.com>	<20140514132312.573e5d3cf99276c3f0b82980@linux-foundation.org>	<5373D509.7090207@oracle.com> <20140514140305.7683c1c2f1e4fb0a63085a2a@linux-foundation.org>
In-Reply-To: <20140514140305.7683c1c2f1e4fb0a63085a2a@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>

On 05/14/2014 05:03 PM, Andrew Morton wrote:
> On Wed, 14 May 2014 16:41:45 -0400 Sasha Levin <sasha.levin@oracle.com> wrote:
> 
>> On 05/14/2014 04:23 PM, Andrew Morton wrote:
>>> On Wed, 14 May 2014 11:55:45 -0400 Sasha Levin <sasha.levin@oracle.com> wrote:
>>>
>>>> Hi all,
>>>>
>>>> While fuzzing with trinity inside a KVM tools guest running the latest -next
>>>> kernel I've stumbled on the following spew:
>>>>
>>>> [ 1634.969408] BUG: unable to handle kernel NULL pointer dereference at           (null)
>>>> [ 1634.970538] IP: special_mapping_fault (mm/mmap.c:2961)
>>>> [ 1634.971420] PGD 3334fc067 PUD 3334cf067 PMD 0
>>>> [ 1634.972081] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
>>>> [ 1634.972913] Dumping ftrace buffer:
>>>> [ 1634.975493]    (ftrace buffer empty)
>>>> [ 1634.977470] Modules linked in:
>>>> [ 1634.977513] CPU: 6 PID: 29578 Comm: trinity-c269 Not tainted 3.15.0-rc5-next-20140513-sasha-00020-gebce144-dirty #461
>>>> [ 1634.977513] task: ffff880333158000 ti: ffff88033351e000 task.ti: ffff88033351e000
>>>> [ 1634.977513] RIP: special_mapping_fault (mm/mmap.c:2961)
>>>
>>> Somebody's gone and broken the x86 oops output.  It used to say
>>> "special_mapping_fault+0x30/0x120" but the offset info has now
>>> disappeared.  That was useful for guesstimating whereabouts in the
>>> function it died.
>>
>> I'm the one who "broke" the oops output, but I thought I'm helping people
>> read that output instead of making it harder...
>>
>> What happened before is that due to my rather complex .config, the offsets
>> didn't make sense to anyone who didn't build the kernel with my .config,
>> so I had to repeatedly send it out to folks who attempted to get basic
>> things like line numbers.
>>
>>> The line number isn't very useful as it's not possible (or at least,
>>> not convenient) for others to reliably reproduce your kernel.
>>
>> I don't understand that part. I'm usually stating in the beginning of my
>> mails that I run my testing on the latest -next kernel.
> 
> Your "latest next kernel" apparently differes from mine ;( It would be
> useful if you could just quote the +/-5 lines, perhaps?

Oh, I see what happened. I have the remap_file_pages() get_file/fput fix
merged in which modified line count.

Yup, I'll start quoting the line themselves as well.

>> And indeed if
>> you look at today's -next, that line number would point to:
>>
>>         for (pages = vma->vm_private_data; pgoff && *pages; ++pages) <=== HERE
>>                 pgoff--;
>>
>> So I'm not sure how replacing the offset with line numbers is making things
>> worse? previously offsets were useless for people who tried to debug these
>> spews so that's why I switched it to line numbers in the first place.
>>
>>> <scrabbles with git for a while>
>>>
>>> : static int special_mapping_fault(struct vm_area_struct *vma,
>>> : 				struct vm_fault *vmf)
>>> : {
>>> : 	pgoff_t pgoff;
>>> : 	struct page **pages;
>>> : 
>>> : 	/*
>>> : 	 * special mappings have no vm_file, and in that case, the mm
>>> : 	 * uses vm_pgoff internally. So we have to subtract it from here.
>>> : 	 * We are allowed to do this because we are the mm; do not copy
>>> : 	 * this code into drivers!
>>> : 	 */
>>> : 	pgoff = vmf->pgoff - vma->vm_pgoff;
>>> : 
>>> : 	for (pages = vma->vm_private_data; pgoff && *pages; ++pages)
>>> : 		pgoff--;
>>> : 
>>> : 	if (*pages) {
>>> : 		struct page *page = *pages;
>>> : 		get_page(page);
>>> : 		vmf->page = page;
>>> : 		return 0;
>>> : 	}
>>> : 
>>> : 	return VM_FAULT_SIGBUS;
>>> : }
>>>
>>> OK so it might be the "if (*pages)".  So vma->vm_private_data was NULL
>>> and pgoff was zero.  As usual, I can't imagine what race would cause
>>> that :(
>>
>> Yup, it's the *pages part in the 'for' loop above that. I did find the
>> following in the vdso code:
>>
>>         vma = _install_special_mapping(mm,
>>                                        addr + image->size,
>>                                        image->sym_end_mapping - image->size,
>>                                        VM_READ,
>>                                        NULL);
>>
>> Which installs a mapping with a NULL ptr for pages (if I understand that
>> correctly), but that code has been there for a while now.
> 
> Well that's weird.  I don't see anything which permits that.  Maybe
> nobody faulted against that address before?
> 
> It's unclear what that code's actually doing and nobody bothered
> commenting it of course.  Maybe it's installing a guard page?
> 
> In my linux-next all that code got deleted by Andy's "x86, vdso:
> Reimplement vdso.so preparation in build-time C" anyway.  What kernel
> were you looking at?

Deleted? It appears in today's -next. arch/x86/vdso/vma.c:124 .

I don't see Andy's patch removing that code either.

I'm running next-20140514...


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
