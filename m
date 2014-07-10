Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f178.google.com (mail-vc0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4618E6B0035
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 15:48:47 -0400 (EDT)
Received: by mail-vc0-f178.google.com with SMTP id ij19so148458vcb.23
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 12:48:46 -0700 (PDT)
Received: from mail-vc0-x22b.google.com (mail-vc0-x22b.google.com [2607:f8b0:400c:c03::22b])
        by mx.google.com with ESMTPS id b5si94511vdj.25.2014.07.10.12.48.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 10 Jul 2014 12:48:46 -0700 (PDT)
Received: by mail-vc0-f171.google.com with SMTP id id10so161235vcb.2
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 12:48:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53BEB77A.6020003@intel.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1404905415-9046-2-git-send-email-a.ryabinin@samsung.com>
	<53BDA568.5030607@intel.com>
	<53BE8333.6060404@samsung.com>
	<53BEB77A.6020003@intel.com>
Date: Thu, 10 Jul 2014 23:48:45 +0400
Message-ID: <CAPAsAGwYZ9AVUoOMipZEe8jdmJfd=aULR+yoVH5FqzW1Qa75AQ@mail.gmail.com>
Subject: Re: [RFC/PATCH RESEND -next 01/21] Add kernel address sanitizer infrastructure.
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

2014-07-10 19:55 GMT+04:00 Dave Hansen <dave.hansen@intel.com>:
> On 07/10/2014 05:12 AM, Andrey Ryabinin wrote:
>> On 07/10/14 00:26, Dave Hansen wrote:
>>> On 07/09/2014 04:29 AM, Andrey Ryabinin wrote:
>>>> Address sanitizer dedicates 1/8 of the low memory to the shadow memory and uses direct
>>>> mapping with a scale and offset to translate a memory address to its corresponding
>>>> shadow address.
>>>>
>>>> Here is function to translate address to corresponding shadow address:
>>>>
>>>>      unsigned long kasan_mem_to_shadow(unsigned long addr)
>>>>      {
>>>>                 return ((addr - PAGE_OFFSET) >> KASAN_SHADOW_SCALE_SHIFT)
>>>>                              + kasan_shadow_start;
>>>>      }
>>>
>>> How does this interact with vmalloc() addresses or those from a kmap()?
>>>
>> It's used only for lowmem:
>>
>> static inline bool addr_is_in_mem(unsigned long addr)
>> {
>>       return likely(addr >= PAGE_OFFSET && addr < (unsigned long)high_memory);
>> }
>
> That's fine, and definitely covers the common cases.  Could you make
> sure to call this out explicitly?  Also, there's nothing to _keep_ this
> approach working for things out of the direct map, right?  It would just
> be a matter of updating the shadow memory to have entries for the other
> virtual address ranges.

Why do you want shadow for things out of the direct map?
If you want to catch use-after-free in vmalloc than DEBUG_PAGEALLOC
will be enough.
If you want catch out-of-bounds in vmalloc you don't need anything,
because vmalloc
allocates guarding hole in the end.
Or do you want something else?

>
> addr_is_in_mem() is a pretty bad name for what it's doing. :)
>
> I'd probably call it something like kasan_tracks_vaddr().
>
Agree

> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



-- 
Best regards,
Andrey Ryabinin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
