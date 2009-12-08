Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3B36460021B
	for <linux-mm@kvack.org>; Mon,  7 Dec 2009 19:32:54 -0500 (EST)
Message-ID: <4B1D9EF2.4010406@kernel.org>
Date: Tue, 08 Dec 2009 09:33:54 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/vmalloc: don't use vmalloc_end
References: <4B1D3A3302000078000241CD@vpn.id2.novell.com> <20091207153552.0fadf335.akpm@linux-foundation.org>
In-Reply-To: <20091207153552.0fadf335.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Beulich <JBeulich@novell.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>
List-ID: <linux-mm.kvack.org>

On 12/08/2009 08:35 AM, Andrew Morton wrote:
> (cc linux-ia64)
> 
> On Mon, 07 Dec 2009 16:24:03 +0000
> "Jan Beulich" <JBeulich@novell.com> wrote:
> 
>> At least on ia64 vmalloc_end is a global variable that VMALLOC_END
>> expands to. Hence having a local variable named vmalloc_end and
>> initialized from VMALLOC_END won't work on such platforms. Rename
>> these variables, and for consistency also rename vmalloc_start.
>>
> 
> erk.  So does 2.6.32's vmalloc() actually work correctly on ia64?
> 
> Perhaps vmalloc_end wasn't a well chosen name for an arch-specific
> global variable.
> 
> arch/m68k/include/asm/pgtable_mm.h does the same thing.  Did it break too?

Hmmm... ISTR writing a patch updating ia64 so that it doesn't use that
macro.  Looking it up....  Yeap, 126b3fcdecd350cad9700908d0ad845084e26a31
in percpu#for-next.

    ia64: don't alias VMALLOC_END to vmalloc_end
    
    If CONFIG_VIRTUAL_MEM_MAP is enabled, ia64 defines macro VMALLOC_END
    as unsigned long variable vmalloc_end which is adjusted to prepare
    room for vmemmap.  This becomes probnlematic if a local variables
    vmalloc_end is defined in some function (not very unlikely) and
    VMALLOC_END is used in the function - the function thinks its
    referencing the global VMALLOC_END value but would be referencing its
    own local vmalloc_end variable.
    
    There's no reason VMALLOC_END should be a macro.  Just define it as an
    unsigned long variable if CONFIG_VIRTUAL_MEM_MAP is set to avoid nasty
    surprises.
    
    Signed-off-by: Tejun Heo <tj@kernel.org>
    Acked-by: Tony Luck <tony.luck@intel.com>
    Cc: Fenghua Yu <fenghua.yu@intel.com>
    Cc: linux-ia64 <linux-ia64@vger.kernel.org>
    Cc: Christoph Lameter <cl@linux-foundation.org>

2.6.32 doesn't use new allocator on ia64 yet and the above commit will
be sent to Linus soon which will also enable new allocator.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
