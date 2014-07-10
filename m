Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id DEE2D6B0035
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 11:58:16 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fb1so11414343pad.0
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 08:58:16 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id zy5si48866082pbc.35.2014.07.10.08.58.12
        for <linux-mm@kvack.org>;
        Thu, 10 Jul 2014 08:58:13 -0700 (PDT)
Message-ID: <53BEB77A.6020003@intel.com>
Date: Thu, 10 Jul 2014 08:55:38 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH RESEND -next 01/21] Add kernel address sanitizer infrastructure.
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com> <1404905415-9046-2-git-send-email-a.ryabinin@samsung.com> <53BDA568.5030607@intel.com> <53BE8333.6060404@samsung.com>
In-Reply-To: <53BE8333.6060404@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

On 07/10/2014 05:12 AM, Andrey Ryabinin wrote:
> On 07/10/14 00:26, Dave Hansen wrote:
>> On 07/09/2014 04:29 AM, Andrey Ryabinin wrote:
>>> Address sanitizer dedicates 1/8 of the low memory to the shadow memory and uses direct
>>> mapping with a scale and offset to translate a memory address to its corresponding
>>> shadow address.
>>>
>>> Here is function to translate address to corresponding shadow address:
>>>
>>>      unsigned long kasan_mem_to_shadow(unsigned long addr)
>>>      {
>>>                 return ((addr - PAGE_OFFSET) >> KASAN_SHADOW_SCALE_SHIFT)
>>>                              + kasan_shadow_start;
>>>      }
>>
>> How does this interact with vmalloc() addresses or those from a kmap()?
>> 
> It's used only for lowmem:
> 
> static inline bool addr_is_in_mem(unsigned long addr)
> {
> 	return likely(addr >= PAGE_OFFSET && addr < (unsigned long)high_memory);
> }

That's fine, and definitely covers the common cases.  Could you make
sure to call this out explicitly?  Also, there's nothing to _keep_ this
approach working for things out of the direct map, right?  It would just
be a matter of updating the shadow memory to have entries for the other
virtual address ranges.

addr_is_in_mem() is a pretty bad name for what it's doing. :)

I'd probably call it something like kasan_tracks_vaddr().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
