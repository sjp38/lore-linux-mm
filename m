From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: kmemleak: Unable to handle kernel paging request
Date: Sat, 14 Jun 2014 07:44:13 +1000
Message-ID: <1402695853.20360.17.camel@pasglop>
References: <CAOJe8K3fy3XFxDdVc3y1hiMAqUCPmkUhECU7j5TT=E=gxwBqHg@mail.gmail.com>
	 <20140611173851.GA5556@MacBook-Pro.local>
	 <CAOJe8K1TgTDX5=LdE9r6c0ami7TRa7zr0hL_uu6YpiWrsePAgQ@mail.gmail.com>
	 <B01EB0A1-992B-49F4-93AE-71E4BA707795@arm.com>
	 <CAOJe8K3LDhhPWbtdaWt23mY+2vnw5p05+eyk2D8fovOxC10cgA@mail.gmail.com>
	 <CAOJe8K2WaJUP9_buwgKw89fxGe56mGP1Mn8rDUO9W48KZzmybA@mail.gmail.com>
	 <20140612143916.GB8970@arm.com>
	 <CAOJe8K3zN+fFWumKaGx3Tmv5JRZu10_FZ6R3Tjjc+nc-KVB0hg@mail.gmail.com>
	 <20140613085640.GA21018@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140613085640.GA21018@arm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Denis Kirjanov <kda@linux-powerpc.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linuxppc-dev@lists.ozlabs.org, Paul Mackerras <paulus@samba.org>
List-Id: linux-mm.kvack.org

On Fri, 2014-06-13 at 09:56 +0100, Catalin Marinas wrote:

> OK, so that's the DART table allocated via alloc_dart_table(). Is
> dart_tablebase removed from the kernel linear mapping after allocation?

Yes.

> If that's the case, we need to tell kmemleak to ignore this block (see
> patch below, untested). But I still can't explain how commit
> d4c54919ed863020 causes this issue.
> 
> (also cc'ing the powerpc list and maintainers)

We remove the DART from the linear mapping because it has to be mapped
non-cachable and having it in the linear mapping would cause cache
paradoxes. We also can't just change the caching attributes in the
linear mapping because we use 16M pages for it and 970 CPUs don't
support cache-inhibited 16M pages :-( And due to the MMU segmentation
model, we also can't mix & match page sizes in that area.

So we just unmap it, and ioremap it elsewhere.

Cheers,
Ben.

> ---------------8<--------------------------
> 
> >From 09a7f1c97166c7bdca7ca4e8a4ff2774f3706ea3 Mon Sep 17 00:00:00 2001
> From: Catalin Marinas <catalin.marinas@arm.com>
> Date: Fri, 13 Jun 2014 09:44:21 +0100
> Subject: [PATCH] powerpc/kmemleak: Do not scan the DART table
> 
> The DART table allocation is registered to kmemleak via the
> memblock_alloc_base() call. However, the DART table is later unmapped
> and dart_tablebase VA no longer accessible. This patch tells kmemleak
> not to scan this block and avoid an unhandled paging request.
> 
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> ---
>  arch/powerpc/sysdev/dart_iommu.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/arch/powerpc/sysdev/dart_iommu.c b/arch/powerpc/sysdev/dart_iommu.c
> index 62c47bb76517..9e5353ff6d1b 100644
> --- a/arch/powerpc/sysdev/dart_iommu.c
> +++ b/arch/powerpc/sysdev/dart_iommu.c
> @@ -476,6 +476,11 @@ void __init alloc_dart_table(void)
>  	 */
>  	dart_tablebase = (unsigned long)
>  		__va(memblock_alloc_base(1UL<<24, 1UL<<24, 0x80000000L));
> +	/*
> +	 * The DART space is later unmapped from the kernel linear mapping and
> +	 * accessing dart_tablebase during kmemleak scanning will fault.
> +	 */
> +	kmemleak_no_scan((void *)dart_tablebase);
>  
>  	printk(KERN_INFO "DART table allocated at: %lx\n", dart_tablebase);
>  }
