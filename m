Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 04CA56B0008
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 13:10:24 -0500 (EST)
Received: by mail-da0-f44.google.com with SMTP id z20so1728574dae.31
        for <linux-mm@kvack.org>; Fri, 18 Jan 2013 10:10:24 -0800 (PST)
Message-ID: <50F9900A.9070804@gmail.com>
Date: Fri, 18 Jan 2013 10:10:18 -0800
From: David Daney <ddaney.cavm@gmail.com>
MIME-Version: 1.0
Subject: 3.8-rc4 build regression (was: Re: 3.8-rc1 build failure with MIPS/SPARSEMEM)
References: <20121222122757.GB6847@blackmetal.musicnaut.iki.fi> <20121226003434.GA27760@otc-wbsnb-06>
In-Reply-To: <20121226003434.GA27760@otc-wbsnb-06>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ralf Baechle <ralf@linux-mips.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Aaro Koskinen <aaro.koskinen@iki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mips@linux-mips.org

Linus, Andrew and Ralf,

3.8 doesn't build on MIPS any more.

Please consider this patch ...

On 12/25/2012 04:34 PM, Kirill A. Shutemov wrote:
> On Sat, Dec 22, 2012 at 02:27:57PM +0200, Aaro Koskinen wrote:
>> Hi,
>>
>> It looks like commit 816422ad76474fed8052b6f7b905a054d082e59a
>> (asm-generic, mm: pgtable: consolidate zero page helpers) broke
>> MIPS/SPARSEMEM build in 3.8-rc1:
>>
>>    CHK     include/generated/uapi/linux/version.h
>>    CHK     include/generated/utsrelease.h
>>    Checking missing-syscalls for N32
>>    CC      arch/mips/kernel/asm-offsets.s
>> In file included from /home/aaro/git/linux/arch/mips/include/asm/pgtable.h:388:0,
>>                   from include/linux/mm.h:44,
>>                   from arch/mips/kernel/asm-offsets.c:14:
>> include/asm-generic/pgtable.h: In function 'my_zero_pfn':
>> include/asm-generic/pgtable.h:462:9: error: implicit declaration of function 'page_to_section' [-Werror=implicit-function-declaration]
>> In file included from arch/mips/kernel/asm-offsets.c:14:0:
>> include/linux/mm.h: At top level:
>> include/linux/mm.h:708:29: error: conflicting types for 'page_to_section'
>> In file included from /home/aaro/git/linux/arch/mips/include/asm/pgtable.h:388:0,
>>                   from include/linux/mm.h:44,
>>                   from arch/mips/kernel/asm-offsets.c:14:
>> include/asm-generic/pgtable.h:462:9: note: previous implicit declaration of 'page_to_section' was here
>> cc1: some warnings being treated as errors
>> make[1]: *** [arch/mips/kernel/asm-offsets.s] Error 1
>> make: *** [archprepare] Error 2
>
> The patch below works for me. Could you try?
>
>  From a123a406fdc3aee7ca0eae04b6b4a231872dbb51 Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill@shutemov.name>
> Date: Wed, 26 Dec 2012 03:19:55 +0300
> Subject: [PATCH] asm-generic, mm: pgtable: convert my_zero_pfn() to macros to
>   fix build
> MIME-Version: 1.0
> Content-Type: text/plain; charset=UTF-8
> Content-Transfer-Encoding: 8bit
>
> On MIPS if SPARSEMEM is enabled we've got this:
>
> In file included from /home/kas/git/public/linux/arch/mips/include/asm/pgtable.h:552,
>                   from include/linux/mm.h:44,
>                   from arch/mips/kernel/asm-offsets.c:14:
> include/asm-generic/pgtable.h: In function a??my_zero_pfna??:
> include/asm-generic/pgtable.h:466: error: implicit declaration of function a??page_to_sectiona??
> In file included from arch/mips/kernel/asm-offsets.c:14:
> include/linux/mm.h: At top level:
> include/linux/mm.h:738: error: conflicting types for a??page_to_sectiona??
> include/asm-generic/pgtable.h:466: note: previous implicit declaration of a??page_to_sectiona?? was here
>
> Due header files inter-dependencies, the only way I see to fix it is
> convert my_zero_pfn() for __HAVE_COLOR_ZERO_PAGE to macros.
>
> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>

I arrived (independently) at the identical solution.

Acked-by: David Daney <david.daney@cavium.com>


> ---
>   include/asm-generic/pgtable.h | 6 ++----
>   1 file changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
> index 701beab..5cf680a 100644
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -461,10 +461,8 @@ static inline int is_zero_pfn(unsigned long pfn)
>   	return offset_from_zero_pfn <= (zero_page_mask >> PAGE_SHIFT);
>   }
>
> -static inline unsigned long my_zero_pfn(unsigned long addr)
> -{
> -	return page_to_pfn(ZERO_PAGE(addr));
> -}
> +#define my_zero_pfn(addr)	page_to_pfn(ZERO_PAGE(addr))
> +
>   #else
>   static inline int is_zero_pfn(unsigned long pfn)
>   {
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
