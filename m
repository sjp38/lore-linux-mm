Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id A388E6B0261
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 01:40:17 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id w207so4948390oiw.1
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 22:40:17 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id r82si3483791itd.47.2016.07.26.22.40.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jul 2016 22:40:16 -0700 (PDT)
Subject: Re: [PATCH] mm: correctly handle errors during VMA merging
References: <1469514843-23778-1-git-send-email-vegard.nossum@oracle.com>
 <20160726114823.GC7370@node.shutemov.name> <5797C5E4.9010208@oracle.com>
 <20160726203053.GD11776@node.shutemov.name>
From: Vegard Nossum <vegard.nossum@oracle.com>
Message-ID: <57984932.4010803@oracle.com>
Date: Wed, 27 Jul 2016 07:40:02 +0200
MIME-Version: 1.0
In-Reply-To: <20160726203053.GD11776@node.shutemov.name>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Leon Yu <chianglungyu@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Rik van Riel <riel@redhat.com>, Daniel Forrest <dan.forrest@ssec.wisc.edu>

On 07/26/2016 10:30 PM, Kirill A. Shutemov wrote:
> On Tue, Jul 26, 2016 at 10:19:48PM +0200, Vegard Nossum wrote:
>> On 07/26/2016 01:48 PM, Kirill A. Shutemov wrote:
>>> On Tue, Jul 26, 2016 at 08:34:03AM +0200, Vegard Nossum wrote:
>>>> Using trinity + fault injection I've been running into this bug a lot:
>>>>
>>>>      ==================================================================
>>>>      BUG: KASAN: out-of-bounds in mprotect_fixup+0x523/0x5a0 at addr ffff8800b9e7d740
>>
>> [...]
>>
>>>> What's happening is that we're doing an mprotect() on a range that spans
>>>> three existing adjacent mappings. The first two are merged fine, but if
>>>> we merge the last one and anon_vma_clone() runs out of memory, we return
>>>> an error and mprotect_fixup() tries to use the (now stale) pointer. It
>>>> goes like this:
>>>>
>>>>      SyS_mprotect()
>>>>        - mprotect_fixup()
>>>>           - vma_merge()
>>>>              - vma_adjust()
>>>>                 // first merge
>>>>                 - kmem_cache_free(vma)
>>>>                 - goto again;
>>>>                 // second merge
>>>>                 - anon_vma_clone()
>>>>                    - kmem_cache_alloc()
>>>>                       - return NULL
>>>>                    - kmem_cache_alloc()
>>>>                       - return NULL
>>>>                    - return -ENOMEM
>>>>                 - return -ENOMEM
>>>>              - return NULL
>>>>           - vma->vm_start // use-after-free
>>>>
>>>> In other words, it is possible to run into a memory allocation error
>>>> *after* part of the merging work has already been done. In this case,
>>>> we probably shouldn't return an error back to userspace anyway (since
>>>> it would not reflect the partial work that was done).
>>>>
>>>> I *think* the solution might be to simply ignore the errors from
>>>> vma_adjust() and carry on with distinct VMAs for adjacent regions that
>>>> might otherwise have been represented with a single VMA.
>>>>
>>>> I have a reproducer that runs into the bug within a few seconds when
>>>> fault injection is enabled -- with the patch I no longer see any
>>>> problems.
>>>>
>>>> The patch and resulting code admittedly look odd and I'm *far* from
>>>> an expert on mm internals, so feel free to propose counter-patches and
>>>> I can give the reproducer a spin.
>>>
>>> Could you give this a try (barely tested):
>>
>> No apparent problems using either the quick reproducer or trinity (used
>> to take 1-5 hours) after ~8 hours of testing :-)
>
> Good. I'll prepare proper patch tomorrow.
>
> I assume I can use your Tested-by, right?

Tested-by: Vegard Nossum <vegard.nossum@oracle.com>

Feel free to reuse any or all parts of the commit message I wrote for my
patch.

Thanks!


Vegard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
