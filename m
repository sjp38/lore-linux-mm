Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 788AC6B0072
	for <linux-mm@kvack.org>; Tue, 27 May 2014 07:43:50 -0400 (EDT)
Received: by mail-ig0-f170.google.com with SMTP id uy17so927943igb.1
        for <linux-mm@kvack.org>; Tue, 27 May 2014 04:43:50 -0700 (PDT)
Received: from mail-ie0-x230.google.com (mail-ie0-x230.google.com [2607:f8b0:4001:c03::230])
        by mx.google.com with ESMTPS id cu3si14432272icb.68.2014.05.27.04.43.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 27 May 2014 04:43:49 -0700 (PDT)
Received: by mail-ie0-f176.google.com with SMTP id rl12so8616390iec.21
        for <linux-mm@kvack.org>; Tue, 27 May 2014 04:43:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALYGNiPTay15iACtwgRgG68cbb6a8gfh5cR0xfWDLSRESo3mLg@mail.gmail.com>
References: <1401166595-4792-1-git-send-email-vinayakm.list@gmail.com>
	<20140527103130.3A04BE009B@blue.fi.intel.com>
	<CALYGNiPTay15iACtwgRgG68cbb6a8gfh5cR0xfWDLSRESo3mLg@mail.gmail.com>
Date: Tue, 27 May 2014 17:13:49 +0530
Message-ID: <CAOaiJ-kCfC0=gxS_3Eu8qEvvZOpK+WH0M8-2a3XOLAepW9s42g@mail.gmail.com>
Subject: Re: [PATCH] mm: fix zero page check in vm_normal_page
From: vinayak menon <vinayakm.list@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, May 27, 2014 at 5:01 PM, Konstantin Khlebnikov <koct9i@gmail.com> wrote:
> On Tue, May 27, 2014 at 2:31 PM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
>> Vinayak Menon wrote:
>>> An issue was observed when a userspace task exits.
>>> The page which hits error here is the zero page.
>>> In zap_pte_range, vm_normal_page gets called, and it
>>> returns a page address and not NULL, even though the
>>> pte corresponds to zero pfn. In this case,
>>> HAVE_PTE_SPECIAL is not set, and VM_MIXEDMAP is set
>>> in vm_flags. In the case of VM_MIXEDMAP , only pfn_valid
>>> is checked, and not is_zero_pfn. This results in
>>> zero page being returned instead of NULL.
>>>
>>> BUG: Bad page map in process mediaserver  pte:9dff379f pmd:9bfbd831
>>> page:c0ed8e60 count:1 mapcount:-1 mapping:  (null) index:0x0
>>> page flags: 0x404(referenced|reserved)
>>> addr:40c3f000 vm_flags:10220051 anon_vma:  (null) mapping:d9fe0764 index:fd
>>> vma->vm_ops->fault:   (null)
>>> vma->vm_file->f_op->mmap: binder_mmap+0x0/0x274
>>
>> How do we get zero_pfn there. We shouldn't use zero page for file mappings.
>> binder does some tricks?
>
> Its vm_ops doesn't provide ->fault method at all.
> Seems like all ptes must be populated at the mmap time.
> For some reason read page fault had happened and handle_pte_fault()
> handled it in do_anonymous_page() which maps zero_page.
>
When the task crashed, it was ptraced by debuggered and the areas were
dumped. And this resulted in the read page fault.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
