Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5902B8E0018
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 11:48:39 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id j5so11862887qtk.11
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 08:48:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t77sor6208553qkg.16.2018.12.10.08.48.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Dec 2018 08:48:38 -0800 (PST)
Subject: Re: [PATCH] mm/zsmalloc.c: Fix zsmalloc 32-bit PAE support
References: <20181210142105.6750-1-rafael.tinoco@linaro.org>
 <20181210151506.phyjkfcg3skogtyh@kshutemo-mobl1>
From: Rafael David Tinoco <rafael.tinoco@linaro.org>
Message-ID: <32747ea1-7437-8055-a4f5-9f22378e57ae@linaro.org>
Date: Mon, 10 Dec 2018 14:48:25 -0200
MIME-Version: 1.0
In-Reply-To: <20181210151506.phyjkfcg3skogtyh@kshutemo-mobl1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Rafael David Tinoco <rafael.tinoco@linaro.org>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Christophe Leroy <christophe.leroy@c-s.fr>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Ram Pai <linuxram@us.ibm.com>, Nicholas Piggin <npiggin@gmail.com>, Vasily Gorbik <gor@linux.ibm.com>, Anthony Yznaga <anthony.yznaga@oracle.com>, Khalid Aziz <khalid.aziz@oracle.com>, Joerg Roedel <jroedel@suse.de>, Juergen Gross <jgross@suse.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Jiri Kosina <jkosina@suse.cz>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org

On 12/10/18 1:15 PM, Kirill A. Shutemov wrote:
> On Mon, Dec 10, 2018 at 12:21:05PM -0200, Rafael David Tinoco wrote:
>> diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
>> index 84bd9bdc1987..d808cfde3d19 100644
>> --- a/arch/x86/include/asm/pgtable_64_types.h
>> +++ b/arch/x86/include/asm/pgtable_64_types.h
>> @@ -64,8 +64,6 @@ extern unsigned int ptrs_per_p4d;
>>  #define P4D_SIZE		(_AC(1, UL) << P4D_SHIFT)
>>  #define P4D_MASK		(~(P4D_SIZE - 1))
>>  
>> -#define MAX_POSSIBLE_PHYSMEM_BITS	52
>> -
>>  #else /* CONFIG_X86_5LEVEL */
>>  
>>  /*
>> @@ -154,4 +152,6 @@ extern unsigned int ptrs_per_p4d;
>>  
>>  #define PGD_KERNEL_START	((PAGE_SIZE / 2) / sizeof(pgd_t))
>>  
>> +#define MAX_POSSIBLE_PHYSMEM_BITS (pgtable_l5_enabled() ? 52 : 46)
>> +
> 
> ...
> 
>>  #endif /* _ASM_X86_PGTABLE_64_DEFS_H */
>> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
>> index 0787d33b80d8..132c20b6fd4f 100644
>> --- a/mm/zsmalloc.c
>> +++ b/mm/zsmalloc.c
> 
> ...
> 
>> @@ -116,6 +100,25 @@
>>   */
>>  #define OBJ_ALLOCATED_TAG 1
>>  #define OBJ_TAG_BITS 1
>> +
>> +/*
>> + * MAX_POSSIBLE_PHYSMEM_BITS should be defined by all archs using zsmalloc:
>> + * Trying to guess it from MAX_PHYSMEM_BITS, or considering it BITS_PER_LONG,
>> + * proved to be wrong by not considering PAE capabilities, or using SPARSEMEM
>> + * only headers, leading to bad object encoding due to object index overflow.
>> + */
>> +#ifndef MAX_POSSIBLE_PHYSMEM_BITS
>> + #define MAX_POSSIBLE_PHYSMEM_BITS BITS_PER_LONG
>> + #error "MAX_POSSIBLE_PHYSMEM_BITS HAS to be defined by arch using zsmalloc";
>> +#else
>> + #ifndef CONFIG_64BIT
>> +  #if (MAX_POSSIBLE_PHYSMEM_BITS >= (BITS_PER_LONG + PAGE_SHIFT - OBJ_TAG_BITS))
>> +   #error "MAX_POSSIBLE_PHYSMEM_BITS is wrong for this arch";
>> +  #endif
>> + #endif
>> +#endif
>> +
>> +#define _PFN_BITS (MAX_POSSIBLE_PHYSMEM_BITS - PAGE_SHIFT)
>>  #define OBJ_INDEX_BITS	(BITS_PER_LONG - _PFN_BITS - OBJ_TAG_BITS)
>>  #define OBJ_INDEX_MASK	((_AC(1, UL) << OBJ_INDEX_BITS) - 1)
> 
> Have you tested it with CONFIG_X86_5LEVEL=y?
> 
> ASAICS, the patch makes OBJ_INDEX_BITS and what depends from it dynamic --
> it depends what paging mode we are booting in. ZS_SIZE_CLASSES depends
> indirectly on OBJ_INDEX_BITS and I don't see how struct zs_pool definition
> can compile with dynamic ZS_SIZE_CLASSES.
> 
> Hm?
> 

You're right, terribly sorry. This was a last time change.

mm/zsmalloc.c:256:21: error: variably modified ‘size_class’ at file scope

I'll revisit the patch. Any other comments are welcome.

Thank you
