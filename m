Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 7A6A26B007B
	for <linux-mm@kvack.org>; Tue, 27 May 2014 08:10:27 -0400 (EDT)
Received: by mail-ig0-f181.google.com with SMTP id h3so959769igd.2
        for <linux-mm@kvack.org>; Tue, 27 May 2014 05:10:27 -0700 (PDT)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id b20si25708276icc.25.2014.05.27.05.10.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 27 May 2014 05:10:26 -0700 (PDT)
Received: by mail-ig0-f169.google.com with SMTP id hl10so953776igb.4
        for <linux-mm@kvack.org>; Tue, 27 May 2014 05:10:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALYGNiMv+eoPDub0=0T82-U7bdrH3MxoFJZ+Q1zfhLKeZecg1w@mail.gmail.com>
References: <1401166595-4792-1-git-send-email-vinayakm.list@gmail.com>
	<20140527103130.3A04BE009B@blue.fi.intel.com>
	<CALYGNiPTay15iACtwgRgG68cbb6a8gfh5cR0xfWDLSRESo3mLg@mail.gmail.com>
	<CAOaiJ-kCfC0=gxS_3Eu8qEvvZOpK+WH0M8-2a3XOLAepW9s42g@mail.gmail.com>
	<CALYGNiMv+eoPDub0=0T82-U7bdrH3MxoFJZ+Q1zfhLKeZecg1w@mail.gmail.com>
Date: Tue, 27 May 2014 17:40:26 +0530
Message-ID: <CAOaiJ-m8LjrnV868b7Z7-DDkGcubwQzCFOBYNDY7r=v5GuWkbw@mail.gmail.com>
Subject: Re: [PATCH] mm: fix zero page check in vm_normal_page
From: vinayak menon <vinayakm.list@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, May 27, 2014 at 5:18 PM, Konstantin Khlebnikov <koct9i@gmail.com> wrote:
> On Tue, May 27, 2014 at 3:43 PM, vinayak menon <vinayakm.list@gmail.com> wrote:
>> On Tue, May 27, 2014 at 5:01 PM, Konstantin Khlebnikov <koct9i@gmail.com> wrote:
>>> On Tue, May 27, 2014 at 2:31 PM, Kirill A. Shutemov
>>> <kirill.shutemov@linux.intel.com> wrote:
>>>> Vinayak Menon wrote:
>>>>> An issue was observed when a userspace task exits.
>>>>> The page which hits error here is the zero page.
>>>>> In zap_pte_range, vm_normal_page gets called, and it
>>>>> returns a page address and not NULL, even though the
>>>>> pte corresponds to zero pfn. In this case,
>>>>> HAVE_PTE_SPECIAL is not set, and VM_MIXEDMAP is set
>>>>> in vm_flags. In the case of VM_MIXEDMAP , only pfn_valid
>>>>> is checked, and not is_zero_pfn. This results in
>>>>> zero page being returned instead of NULL.
>>>>>
>>>>> BUG: Bad page map in process mediaserver  pte:9dff379f pmd:9bfbd831
>>>>> page:c0ed8e60 count:1 mapcount:-1 mapping:  (null) index:0x0
>>>>> page flags: 0x404(referenced|reserved)
>>>>> addr:40c3f000 vm_flags:10220051 anon_vma:  (null) mapping:d9fe0764 index:fd
>>>>> vma->vm_ops->fault:   (null)
>>>>> vma->vm_file->f_op->mmap: binder_mmap+0x0/0x274
>>>>
>>>> How do we get zero_pfn there. We shouldn't use zero page for file mappings.
>>>> binder does some tricks?
>>>
>>> Its vm_ops doesn't provide ->fault method at all.
>>> Seems like all ptes must be populated at the mmap time.
>>> For some reason read page fault had happened and handle_pte_fault()
>>> handled it in do_anonymous_page() which maps zero_page.
>>>
>> When the task crashed, it was ptraced by debuggered and the areas were
>> dumped. And this resulted in the read page fault.
>
> Anyway, this bug in the binder. It must either populate all PTEs in ->mmap()
> or provide ->fault() method. Falling into do_anonymous_page() isn't funny.

Ok. But in vm_normal_page shouldn't we check for zero_pfn in the case
of VM_MIXEDMAP ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
