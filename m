Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id D3CF96B0035
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 16:04:58 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so103059pab.1
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 13:04:58 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ot3si44610pdb.480.2014.07.10.13.04.56
        for <linux-mm@kvack.org>;
        Thu, 10 Jul 2014 13:04:57 -0700 (PDT)
Message-ID: <53BEF1E5.2000502@intel.com>
Date: Thu, 10 Jul 2014 13:04:53 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH RESEND -next 01/21] Add kernel address sanitizer infrastructure.
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>	<1404905415-9046-2-git-send-email-a.ryabinin@samsung.com>	<53BDA568.5030607@intel.com>	<53BE8333.6060404@samsung.com>	<53BEB77A.6020003@intel.com> <CAPAsAGwYZ9AVUoOMipZEe8jdmJfd=aULR+yoVH5FqzW1Qa75AQ@mail.gmail.com>
In-Reply-To: <CAPAsAGwYZ9AVUoOMipZEe8jdmJfd=aULR+yoVH5FqzW1Qa75AQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

On 07/10/2014 12:48 PM, Andrey Ryabinin wrote:
>>>> How does this interact with vmalloc() addresses or those from a kmap()?
>>>>
>>> It's used only for lowmem:
>>>
>>> static inline bool addr_is_in_mem(unsigned long addr)
>>> {
>>>       return likely(addr >= PAGE_OFFSET && addr < (unsigned long)high_memory);
>>> }
>>
>> That's fine, and definitely covers the common cases.  Could you make
>> sure to call this out explicitly?  Also, there's nothing to _keep_ this
>> approach working for things out of the direct map, right?  It would just
>> be a matter of updating the shadow memory to have entries for the other
>> virtual address ranges.
> 
> Why do you want shadow for things out of the direct map? If you want
> to catch use-after-free in vmalloc than DEBUG_PAGEALLOC will be
> enough. If you want catch out-of-bounds in vmalloc you don't need
> anything, because vmalloc allocates guarding hole in the end. Or do
> you want something else?

That's all true for page-size accesses.  Address sanitizer's biggest
advantage over using the page tables is that it can do checks at
sub-page granularity.  But, we don't have any APIs that I can think of
that _care_ about <PAGE_SIZE outside of the direct map (maybe zsmalloc,
but that's pretty obscure).

So I guess it doesn't matter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
