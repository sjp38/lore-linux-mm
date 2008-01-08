Message-ID: <4783A485.6090109@sgi.com>
Date: Tue, 08 Jan 2008 08:27:49 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/10] percpu: Per cpu code simplification V3
References: <20080108021142.585467000@sgi.com> <20080108090702.GB27671@elte.hu>
In-Reply-To: <20080108090702.GB27671@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> * travis@sgi.com <travis@sgi.com> wrote:
> 
>> This patchset simplifies the code that arches need to maintain to 
>> support per cpu functionality. Most of the code is moved into arch 
>> independent code. Only a minimal set of definitions is kept for each 
>> arch.
>>
>> The patch also unifies the x86 arch so that there is only a single 
>> asm-x86/percpu.h
>>
>> V1->V2:
>> - Add support for specifying attributes for per cpu declarations (preserves
>>   IA64 model(small) attribute).
>>   - Drop first patch that removes the model(small) attribute for IA64
>>   - Missing #endif in powerpc generic config /  Wrong Kconfig
>>   - Follow Randy's suggestions on how to do the Kconfig settings
>>
>> V2->V3:
>>   - fix x86_64 non-SMP case
>>   - change SHIFT_PTR to SHIFT_PERCPU_PTR
>>   - fix various percpu_modcopy()'s to reference correct per_cpu_offset()
>>   - s390 has a special way to determine the pointer to a per cpu area
> 
> thanks, i've picked up the x86 and core bits, for testing.
> 
> i had the patch below for v2, it's still needed (because i didnt apply 
> the s390/etc. bits), right?
> 
> 	Ingo

Yes, good point.  Thanks.

Mike

> 
> ------------->
> Subject: x86: let other arches build
> From: Ingo Molnar <mingo@elte.hu>
> 
> let architectures which still have the DEFINE_PER_CPU/etc. build
> properly.
> 
> Signed-off-by: Ingo Molnar <mingo@elte.hu>
> ---
>  include/linux/percpu.h |    2 ++
>  1 file changed, 2 insertions(+)
> 
> Index: linux-x86.q/include/linux/percpu.h
> ===================================================================
> --- linux-x86.q.orig/include/linux/percpu.h
> +++ linux-x86.q/include/linux/percpu.h
> @@ -14,6 +14,7 @@
>  #endif
>  
>  #ifdef CONFIG_SMP
> +#ifndef DEFINE_PER_CPU
>  #define DEFINE_PER_CPU(type, name)					\
>  	__attribute__((__section__(".data.percpu")))			\
>  	PER_CPU_ATTRIBUTES __typeof__(type) per_cpu__##name
> @@ -32,6 +33,7 @@
>  
>  #define EXPORT_PER_CPU_SYMBOL(var) EXPORT_SYMBOL(per_cpu__##var)
>  #define EXPORT_PER_CPU_SYMBOL_GPL(var) EXPORT_SYMBOL_GPL(per_cpu__##var)
> +#endif
>  
>  /* Enough to cover all DEFINE_PER_CPUs in kernel, including modules. */
>  #ifndef PERCPU_ENOUGH_ROOM

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
