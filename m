Message-ID: <4785D064.1040501@de.ibm.com>
Date: Thu, 10 Jan 2008 08:59:32 +0100
From: Carsten Otte <cotte@de.ibm.com>
Reply-To: carsteno@de.ibm.com
MIME-Version: 1.0
Subject: Re: [rfc][patch 1/4] include: add callbacks to toggle reference counting
 for VM_MIXEDMAP pages
References: <20071214133817.GB28555@wotan.suse.de> <476A7D21.7070607@de.ibm.com> <20071221004556.GB31040@wotan.suse.de> <476B9000.2090707@de.ibm.com> <20071221102052.GB28484@wotan.suse.de> <476B96D6.2010302@de.ibm.com> <20071221104701.GE28484@wotan.suse.de> <1199784954.25114.27.camel@cotte.boeblingen.de.ibm.com> <1199891032.28689.9.camel@cotte.boeblingen.de.ibm.com> <1199891645.28689.22.camel@cotte.boeblingen.de.ibm.com> <6934efce0801091017t7f9041abs62904de3722cadc@mail.gmail.com>
In-Reply-To: <6934efce0801091017t7f9041abs62904de3722cadc@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jared Hulbert <jaredeh@gmail.com>
Cc: Nick Piggin <npiggin@suse.de>, carsteno@de.ibm.com, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>
List-ID: <linux-mm.kvack.org>

Jared Hulbert wrote:
> I think this should be:
> 
> default implementation:   convert pte_t to pfn, use pfn_valid()
> 
> Keep in mind the reason we are talking about using anything other than
> pfn_valid() in vm_normal_page() is because s390 has a non-standard
> pfn_valid() implementation.  It's s390 that's broken, not the rest of
> the world.  So lets not break everything else to fix s390:)  Or am I
> missing something?
I think you're bending the original meaning of pfn_valid() in this 
case: it is supposed to be true when a pfn refers to an accessable 
mapping. In fact, I consider pfn_valid() broken on arm if it returns 
false for a pfn that is perfectly valid for use in a pfnmap/mixedmap 
mapping. I think you're looking for 
pfn_has_struct_page_entry_for_it(), and that's different from the 
original meaning described above.
I think it would be plain wrong to assume all architectures have this 
meaning of pfn_valid() that arm has today.

>> s390 implementation:            query sw defined bit in pte
>> proposed arm implementation:    convert pte_t to pfn, use pfn_valid()
> 
> proposed arm implementation: default
> 
>> Signed-off-by: Carsten Otte <cotte@de.ibm.com>
>> ---
>> Index: linux-2.6/include/asm-generic/pgtable.h
>> ===================================================================
>> --- linux-2.6.orig/include/asm-generic/pgtable.h
>> +++ linux-2.6/include/asm-generic/pgtable.h
>> @@ -99,6 +99,11 @@ static inline void ptep_set_wrprotect(st
>>  }
>>  #endif
>>
>> +#ifndef __HAVE_ARCH_PTEP_NOREFCOUNT
>> +#define pte_set_norefcount(__pte)      (__pte)
>> +#define mixedmap_refcount_pte(__pte)   (1)
> 
> +#define mixedmap_refcount_pte(__pte)   pfn_valid(pte_pfn(__pte))
> 
> Should we rename "mixedmap_refcount_pte" to "mixedmap_normal_pte" or
> something else more neutral?  To me "mixedmap_refcount_pte" sounds
> like it's altering the pte.
Hmmmmh. Indeed, the wording is confusing here.
But anyway, I do want to play with Nick's PTE_SPECIAL thing next. 
Therefore, I'm not going to change that unless we conclude we want to 
go down this path.
Jared, did you try this on arm? Did it work for you with my proposed 
callback implementation?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
