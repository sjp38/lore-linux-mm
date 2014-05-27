Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id DE5856B0070
	for <linux-mm@kvack.org>; Tue, 27 May 2014 07:31:03 -0400 (EDT)
Received: by mail-ie0-f170.google.com with SMTP id at1so8720064iec.29
        for <linux-mm@kvack.org>; Tue, 27 May 2014 04:31:03 -0700 (PDT)
Received: from mail-ie0-x234.google.com (mail-ie0-x234.google.com [2607:f8b0:4001:c03::234])
        by mx.google.com with ESMTPS id z2si4879296igl.49.2014.05.27.04.31.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 27 May 2014 04:31:03 -0700 (PDT)
Received: by mail-ie0-f180.google.com with SMTP id tp5so8363511ieb.25
        for <linux-mm@kvack.org>; Tue, 27 May 2014 04:31:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140527103130.3A04BE009B@blue.fi.intel.com>
References: <1401166595-4792-1-git-send-email-vinayakm.list@gmail.com>
	<20140527103130.3A04BE009B@blue.fi.intel.com>
Date: Tue, 27 May 2014 15:31:02 +0400
Message-ID: <CALYGNiPTay15iACtwgRgG68cbb6a8gfh5cR0xfWDLSRESo3mLg@mail.gmail.com>
Subject: Re: [PATCH] mm: fix zero page check in vm_normal_page
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Vinayak Menon <vinayakm.list@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, May 27, 2014 at 2:31 PM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> Vinayak Menon wrote:
>> An issue was observed when a userspace task exits.
>> The page which hits error here is the zero page.
>> In zap_pte_range, vm_normal_page gets called, and it
>> returns a page address and not NULL, even though the
>> pte corresponds to zero pfn. In this case,
>> HAVE_PTE_SPECIAL is not set, and VM_MIXEDMAP is set
>> in vm_flags. In the case of VM_MIXEDMAP , only pfn_valid
>> is checked, and not is_zero_pfn. This results in
>> zero page being returned instead of NULL.
>>
>> BUG: Bad page map in process mediaserver  pte:9dff379f pmd:9bfbd831
>> page:c0ed8e60 count:1 mapcount:-1 mapping:  (null) index:0x0
>> page flags: 0x404(referenced|reserved)
>> addr:40c3f000 vm_flags:10220051 anon_vma:  (null) mapping:d9fe0764 index:fd
>> vma->vm_ops->fault:   (null)
>> vma->vm_file->f_op->mmap: binder_mmap+0x0/0x274
>
> How do we get zero_pfn there. We shouldn't use zero page for file mappings.
> binder does some tricks?

Its vm_ops doesn't provide ->fault method at all.
Seems like all ptes must be populated at the mmap time.
For some reason read page fault had happened and handle_pte_fault()
handled it in do_anonymous_page() which maps zero_page.

>
>> CPU: 0 PID: 1463 Comm: mediaserver Tainted: G        W    3.10.17+ #1
>> [<c001549c>] (unwind_backtrace+0x0/0x11c) from [<c001200c>] (show_stack+0x10/0x14)
>> [<c001200c>] (show_stack+0x10/0x14) from [<c0103d78>] (print_bad_pte+0x158/0x190)
>> [<c0103d78>] (print_bad_pte+0x158/0x190) from [<c01055f0>] (unmap_single_vma+0x2e4/0x598)
>> [<c01055f0>] (unmap_single_vma+0x2e4/0x598) from [<c010618c>] (unmap_vmas+0x34/0x50)
>> [<c010618c>] (unmap_vmas+0x34/0x50) from [<c010a9e4>] (exit_mmap+0xc8/0x1e8)
>> [<c010a9e4>] (exit_mmap+0xc8/0x1e8) from [<c00520f0>] (mmput+0x54/0xd0)
>> [<c00520f0>] (mmput+0x54/0xd0) from [<c005972c>] (do_exit+0x360/0x990)
>> [<c005972c>] (do_exit+0x360/0x990) from [<c0059ef0>] (do_group_exit+0x84/0xc0)
>> [<c0059ef0>] (do_group_exit+0x84/0xc0) from [<c0066de0>] (get_signal_to_deliver+0x4d4/0x548)
>> [<c0066de0>] (get_signal_to_deliver+0x4d4/0x548) from [<c0011500>] (do_signal+0xa8/0x3b8)
>>
>> Signed-off-by: Vinayak Menon <vinayakm.list@gmail.com>
>> ---
>>  mm/memory.c |    2 ++
>>  1 files changed, 2 insertions(+), 0 deletions(-)
>>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 037b812..c9a5027 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -771,6 +771,8 @@ struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
>>               if (vma->vm_flags & VM_MIXEDMAP) {
>>                       if (!pfn_valid(pfn))
>>                               return NULL;
>> +                     if (is_zero_pfn(pfn))
>> +                             return NULL;
>>                       goto out;
>>               } else {
>>                       unsigned long off;
>> --
>> 1.7.6
>>
>
> --
>  Kirill A. Shutemov
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
