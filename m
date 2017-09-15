Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8336C6B0033
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 21:10:44 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id k101so3337797iod.1
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 18:10:44 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s22si119866oih.120.2017.09.14.18.10.42
        for <linux-mm@kvack.org>;
        Thu, 14 Sep 2017 18:10:43 -0700 (PDT)
Date: Fri, 15 Sep 2017 02:10:36 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH v8 10/11] arm64/kasan: explicitly zero kasan shadow memory
Message-ID: <20170915011035.GA6936@remoulade>
References: <20170914223517.8242-1-pasha.tatashin@oracle.com>
 <20170914223517.8242-11-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170914223517.8242-11-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, Steven.Sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

On Thu, Sep 14, 2017 at 06:35:16PM -0400, Pavel Tatashin wrote:
> To optimize the performance of struct page initialization,
> vmemmap_populate() will no longer zero memory.
> 
> We must explicitly zero the memory that is allocated by vmemmap_populate()
> for kasan, as this memory does not go through struct page initialization
> path.
> 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
> Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
> Reviewed-by: Bob Picco <bob.picco@oracle.com>
> ---
>  arch/arm64/mm/kasan_init.c | 42 ++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 42 insertions(+)
> 
> diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
> index 81f03959a4ab..e78a9ecbb687 100644
> --- a/arch/arm64/mm/kasan_init.c
> +++ b/arch/arm64/mm/kasan_init.c
> @@ -135,6 +135,41 @@ static void __init clear_pgds(unsigned long start,
>  		set_pgd(pgd_offset_k(start), __pgd(0));
>  }
>  
> +/*
> + * Memory that was allocated by vmemmap_populate is not zeroed, so we must
> + * zero it here explicitly.
> + */
> +static void
> +zero_vmemmap_populated_memory(void)
> +{
> +	struct memblock_region *reg;
> +	u64 start, end;
> +
> +	for_each_memblock(memory, reg) {
> +		start = __phys_to_virt(reg->base);
> +		end = __phys_to_virt(reg->base + reg->size);
> +
> +		if (start >= end)
> +			break;
> +
> +		start = (u64)kasan_mem_to_shadow((void *)start);
> +		end = (u64)kasan_mem_to_shadow((void *)end);
> +
> +		/* Round to the start end of the mapped pages */
> +		start = round_down(start, SWAPPER_BLOCK_SIZE);
> +		end = round_up(end, SWAPPER_BLOCK_SIZE);
> +		memset((void *)start, 0, end - start);
> +	}
> +
> +	start = (u64)kasan_mem_to_shadow(_text);
> +	end = (u64)kasan_mem_to_shadow(_end);
> +
> +	/* Round to the start end of the mapped pages */
> +	start = round_down(start, SWAPPER_BLOCK_SIZE);
> +	end = round_up(end, SWAPPER_BLOCK_SIZE);
> +	memset((void *)start, 0, end - start);
> +}

I really don't see the need to duplicate the existing logic to iterate over
memblocks, calculate the addresses, etc.

Why can't we just have a zeroing wrapper? e.g. something like the below.

I really don't see why we couldn't have a generic function in core code to do
this, even if vmemmap_populate() doesn't.

Thanks,
Mark.

---->8----
diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
index 81f0395..698d065 100644
--- a/arch/arm64/mm/kasan_init.c
+++ b/arch/arm64/mm/kasan_init.c
@@ -135,6 +135,17 @@ static void __init clear_pgds(unsigned long start,
                set_pgd(pgd_offset_k(start), __pgd(0));
 }
 
+void kasan_populate_shadow(unsigned long shadow_start, unsigned long shadow_end,
+                          nid_t nid)
+{
+       shadow_start = round_down(shadow_start, SWAPPER_BLOCK_SIZE);
+       shadow_end = round_up(shadow_end, SWAPPER_BLOCK_SIZE);
+
+       vmemmap_populate(shadow_start, shadow_end, nid);
+
+       memset((void *)shadow_start, 0, shadow_end - shadow_start);
+}
+
 void __init kasan_init(void)
 {
        u64 kimg_shadow_start, kimg_shadow_end;
@@ -161,8 +172,8 @@ void __init kasan_init(void)
 
        clear_pgds(KASAN_SHADOW_START, KASAN_SHADOW_END);
 
-       vmemmap_populate(kimg_shadow_start, kimg_shadow_end,
-                        pfn_to_nid(virt_to_pfn(lm_alias(_text))));
+       kasah_populate_shadow(kimg_shadow_start, kimg_shadow_end,
+                             pfn_to_nid(virt_to_pfn(lm_alias(_text))));
 
        /*
         * vmemmap_populate() has populated the shadow region that covers the
@@ -191,9 +202,9 @@ void __init kasan_init(void)
                if (start >= end)
                        break;
 
-               vmemmap_populate((unsigned long)kasan_mem_to_shadow(start),
-                               (unsigned long)kasan_mem_to_shadow(end),
-                               pfn_to_nid(virt_to_pfn(start)));
+               kasan_populate_shadow((unsigned long)kasan_mem_to_shadow(start),
+                                     (unsigned long)kasan_mem_to_shadow(end),
+                                     pfn_to_nid(virt_to_pfn(start)));
        }
 
        /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
