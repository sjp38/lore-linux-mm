Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 85B866B0008
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 11:52:39 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id g61-v6so14939868plb.10
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 08:52:39 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id q9-v6si3499841pll.449.2018.04.04.08.52.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 08:52:38 -0700 (PDT)
Subject: Re: [PATCH 09/11] x86/pti: enable global pages for shared areas
References: <20180404010946.6186729B@viggo.jf.intel.com>
 <20180404011007.A381CC8A@viggo.jf.intel.com>
 <5DEE9F6E-535C-4DBF-A513-69D9FD5C0235@vmware.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <50385d91-58a9-4b14-06bc-2340b99933c3@linux.intel.com>
Date: Wed, 4 Apr 2018 08:52:37 -0700
MIME-Version: 1.0
In-Reply-To: <5DEE9F6E-535C-4DBF-A513-69D9FD5C0235@vmware.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <namit@vmware.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, "keescook@google.com" <keescook@google.com>, Hugh Dickins <hughd@google.com>, Juergen Gross <jgross@suse.com>, "x86@kernel.org" <x86@kernel.org>

On 04/03/2018 09:45 PM, Nadav Amit wrote:
> Dave Hansen <dave.hansen@linux.intel.com> wrote:
> 
>>
>> From: Dave Hansen <dave.hansen@linux.intel.com>
>>
>> The entry/exit text and cpu_entry_area are mapped into userspace and
>> the kernel.  But, they are not _PAGE_GLOBAL.  This creates unnecessary
>> TLB misses.
>>
>> Add the _PAGE_GLOBAL flag for these areas.
>>
>> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Cc: Andy Lutomirski <luto@kernel.org>
>> Cc: Linus Torvalds <torvalds@linux-foundation.org>
>> Cc: Kees Cook <keescook@google.com>
>> Cc: Hugh Dickins <hughd@google.com>
>> Cc: Juergen Gross <jgross@suse.com>
>> Cc: x86@kernel.org
>> Cc: Nadav Amit <namit@vmware.com>
>> ---
>>
>> b/arch/x86/mm/cpu_entry_area.c |   10 +++++++++-
>> b/arch/x86/mm/pti.c            |   14 +++++++++++++-
>> 2 files changed, 22 insertions(+), 2 deletions(-)
>>
>> diff -puN arch/x86/mm/cpu_entry_area.c~kpti-why-no-global arch/x86/mm/cpu_entry_area.c
>> --- a/arch/x86/mm/cpu_entry_area.c~kpti-why-no-global	2018-04-02 16:41:17.157605167 -0700
>> +++ b/arch/x86/mm/cpu_entry_area.c	2018-04-02 16:41:17.162605167 -0700
>> @@ -27,8 +27,16 @@ EXPORT_SYMBOL(get_cpu_entry_area);
>> void cea_set_pte(void *cea_vaddr, phys_addr_t pa, pgprot_t flags)
>> {
>> 	unsigned long va = (unsigned long) cea_vaddr;
>> +	pte_t pte = pfn_pte(pa >> PAGE_SHIFT, flags);
>>
>> -	set_pte_vaddr(va, pfn_pte(pa >> PAGE_SHIFT, flags));
>> +	/*
>> +	 * The cpu_entry_area is shared between the user and kernel
>> +	 * page tables.  All of its ptes can safely be global.
>> +	 */
>> +	if (boot_cpu_has(X86_FEATURE_PGE))
>> +		pte = pte_set_flags(pte, _PAGE_GLOBAL);
> 
> I think it would be safer to check that the PTE is indeed present before
> setting _PAGE_GLOBAL. For example, percpu_setup_debug_store() sets PAGE_NONE
> for non-present entries. In this case, since PAGE_NONE and PAGE_GLOBAL use
> the same bit, everything would be fine, but it might cause bugs one day.

That's a reasonable safety thing to add, I think.

But, looking at it, I am wondering why we did this in
percpu_setup_debug_store():

        for (; npages; npages--, cea += PAGE_SIZE)
                cea_set_pte(cea, 0, PAGE_NONE);

Did we really want that to be PAGE_NONE, or was it supposed to create a
PTE that returns true for pte_none()?

>> 		/*
>> +		 * Setting 'target_pmd' below creates a mapping in both
>> +		 * the user and kernel page tables.  It is effectively
>> +		 * global, so set it as global in both copies.  Note:
>> +		 * the X86_FEATURE_PGE check is not _required_ because
>> +		 * the CPU ignores _PAGE_GLOBAL when PGE is not
>> +		 * supported.  The check keeps consistentency with
>> +		 * code that only set this bit when supported.
>> +		 */
>> +		if (boot_cpu_has(X86_FEATURE_PGE))
>> +			*pmd = pmd_set_flags(*pmd, _PAGE_GLOBAL);
> 
> Same here.

Is there  a reason that the pmd_none() check above this does not work?
