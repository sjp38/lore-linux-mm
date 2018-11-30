Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 46D0A6B582A
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 07:19:43 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c53so2795419edc.9
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 04:19:43 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a19si2295499edt.34.2018.11.30.04.19.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Nov 2018 04:19:42 -0800 (PST)
Subject: Re: [PATCH 1/2] x86/mm: Fix guard hole handling
References: <20181130115758.4425-1-kirill.shutemov@linux.intel.com>
 <20181130115758.4425-2-kirill.shutemov@linux.intel.com>
 <76b8ca15-405a-055f-41b3-532b116c3a8b@suse.com>
 <20181130121131.g3xvlvixv7mvlr7b@black.fi.intel.com>
From: Juergen Gross <jgross@suse.com>
Message-ID: <de576537-d524-aa2e-adc0-3fa969e4ffe2@suse.com>
Date: Fri, 30 Nov 2018 13:19:40 +0100
MIME-Version: 1.0
In-Reply-To: <20181130121131.g3xvlvixv7mvlr7b@black.fi.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org, boris.ostrovsky@oracle.com, bhe@redhat.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 30/11/2018 13:11, Kirill A. Shutemov wrote:
> On Fri, Nov 30, 2018 at 12:03:33PM +0000, Juergen Gross wrote:
>> On 30/11/2018 12:57, Kirill A. Shutemov wrote:
>>> There is a guard hole at the beginning of kernel address space, also
>>> used by hypervisors. It occupies 16 PGD entries.
>>>
>>> We do not state the reserved range directly, but calculate it relative
>>> to other entities: direct mapping and user space ranges.
>>>
>>> The calculation got broken by recent change in kernel memory layout: LDT
>>> remap range is now mapped before direct mapping and makes the calculation
>>> invalid.
>>>
>>> The breakage leads to crash on Xen dom0 boot[1].
>>>
>>> State the reserved range directly. It's part of kernel ABI (hypervisors
>>> expect it to be stable) and must not depend on changes in the rest of
>>> kernel memory layout.
>>>
>>> [1] https://lists.xenproject.org/archives/html/xen-devel/2018-11/msg03313.html
>>>
>>> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>>> Reported-by: Hans van Kranenburg <Hans.van.Kranenburg@mendix.com>
>>> Fixes: d52888aa2753 ("x86/mm: Move LDT remap out of KASLR region on 5-level paging")
>>> ---
>>>  arch/x86/include/asm/pgtable_64_types.h |  5 +++++
>>>  arch/x86/mm/dump_pagetables.c           |  8 ++++----
>>>  arch/x86/xen/mmu_pv.c                   | 11 ++++++-----
>>>  3 files changed, 15 insertions(+), 9 deletions(-)
>>>
>>> diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
>>> index 84bd9bdc1987..13aef22cee18 100644
>>> --- a/arch/x86/include/asm/pgtable_64_types.h
>>> +++ b/arch/x86/include/asm/pgtable_64_types.h
>>> @@ -111,6 +111,11 @@ extern unsigned int ptrs_per_p4d;
>>>   */
>>>  #define MAXMEM			(1UL << MAX_PHYSMEM_BITS)
>>>  
>>> +#define GUARD_HOLE_PGD_ENTRY	-256UL
>>> +#define GUARD_HOLE_SIZE		(16UL << PGDIR_SHIFT)
>>> +#define GUARD_HOLE_BASE_ADDR	(LDT_PGD_ENTRY << PGDIR_SHIFT)
>>
>> s/LDT_PGD_ENTRY/GUARD_HOLE_PGD_ENTRY/
> 
> Ughh..
> 
>>>From 4308d560cc2874a9f596512bcb4c601b2450653d Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Fri, 30 Nov 2018 14:29:42 +0300
> Subject: [PATCH 1/2] x86/mm: Fix guard hole handling
> 
> There is a guard hole at the beginning of kernel address space, also
> used by hypervisors. It occupies 16 PGD entries.
> 
> We do not state the reserved range directly, but calculate it relative
> to other entities: direct mapping and user space ranges.
> 
> The calculation got broken by recent change in kernel memory layout: LDT
> remap range is now mapped before direct mapping and makes the calculation
> invalid.
> 
> The breakage leads to crash on Xen dom0 boot[1].
> 
> State the reserved range directly. It's part of kernel ABI (hypervisors
> expect it to be stable) and must not depend on changes in the rest of
> kernel memory layout.
> 
> [1] https://lists.xenproject.org/archives/html/xen-devel/2018-11/msg03313.html
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Hans van Kranenburg <Hans.van.Kranenburg@mendix.com>
> Fixes: d52888aa2753 ("x86/mm: Move LDT remap out of KASLR region on 5-level paging")
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Reviewed-by: Juergen Gross <jgross@suse.com>


Juergen
