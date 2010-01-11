Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3A24E6B006A
	for <linux-mm@kvack.org>; Sun, 10 Jan 2010 21:21:04 -0500 (EST)
From: "Zheng, Shaohui" <shaohui.zheng@intel.com>
Date: Mon, 11 Jan 2010 10:20:22 +0800
Subject: RE: [PATCH - resend] Memory-Hotplug: Fix the bug on interface
	/dev/mem for 64-bit kernel(v1)
Message-ID: <DA586906BA1FFC4384FCFD6429ECE86031560FC1@shzsmsx502.ccr.corp.intel.com>
References: <DA586906BA1FFC4384FCFD6429ECE86031560BAC@shzsmsx502.ccr.corp.intel.com>
 <20100108124851.GB6153@localhost>
In-Reply-To: <20100108124851.GB6153@localhost>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: "Wu, Fengguang" <fengguang.wu@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "ak@linux.intel.com" <ak@linux.intel.com>, "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, "x86@kernel.org" <x86@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Thanks Fengguang, see and comments in the email. Only a few different under=
standing on variable max_low_pfn.

Thanks & Regards,
Shaohui


-----Original Message-----
From: Wu, Fengguang=20
Sent: Friday, January 08, 2010 8:49 PM
To: Zheng, Shaohui
Cc: linux-mm@kvack.org; akpm@linux-foundation.org; linux-kernel@vger.kernel=
.org; ak@linux.intel.com; y-goto@jp.fujitsu.com; Dave Hansen; x86@kernel.or=
g; KAMEZAWA Hiroyuki
Subject: Re: [PATCH - resend] Memory-Hotplug: Fix the bug on interface /dev=
/mem for 64-bit kernel(v1)

On Fri, Jan 08, 2010 at 11:32:07AM +0800, Zheng, Shaohui wrote:
> Resend the patch to the mailing-list, the original patch URL is=20
> http://patchwork.kernel.org/patch/69075/, it is not accepted without comm=
ents,
> sent it again to review.
>=20
> Memory-Hotplug: Fix the bug on interface /dev/mem for 64-bit kernel
>=20
> The new added memory can not be access by interface /dev/mem, because we =
do not
>  update the variable high_memory. This patch add a new e820 entry in e820=
 table,
>  and update max_pfn, max_low_pfn and high_memory.
>=20
> We add a function update_pfn in file arch/x86/mm/init.c to udpate these
>  varibles. Memory hotplug does not make sense on 32-bit kernel, so we did=
 not
>  concern it in this function.
>=20
> Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
> CC: Andi Kleen <ak@linux.intel.com>
> CC: Wu Fengguang <fengguang.wu@intel.com>
> CC: Li Haicheng <Haicheng.li@intel.com>
>=20
> ---
> diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
> index f50447d..b986246 100644
> --- a/arch/x86/kernel/e820.c
> +++ b/arch/x86/kernel/e820.c
> @@ -110,8 +110,8 @@ int __init e820_all_mapped(u64 start, u64 end, unsign=
ed type)
>  /*
>   * Add a memory region to the kernel e820 map.
>   */
> -static void __init __e820_add_region(struct e820map *e820x, u64 start, u=
64 size,
> -					 int type)
> +static void __meminit __e820_add_region(struct e820map *e820x, u64 start=
,
> +					 u64 size, int type)
>  {
>  	int x =3D e820x->nr_map;
> =20
> @@ -126,7 +126,7 @@ static void __init __e820_add_region(struct e820map *=
e820x, u64 start, u64 size,
>  	e820x->nr_map++;
>  }
> =20
> -void __init e820_add_region(u64 start, u64 size, int type)
> +void __meminit e820_add_region(u64 start, u64 size, int type)
>  {
>  	__e820_add_region(&e820, start, size, type);
>  }
> diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
> index d406c52..0474459 100644
> --- a/arch/x86/mm/init.c
> +++ b/arch/x86/mm/init.c
> @@ -1,6 +1,7 @@
>  #include <linux/initrd.h>
>  #include <linux/ioport.h>
>  #include <linux/swap.h>
> +#include <linux/bootmem.h>
> =20
>  #include <asm/cacheflush.h>
>  #include <asm/e820.h>
> @@ -386,3 +387,30 @@ void free_initrd_mem(unsigned long start, unsigned l=
ong end)
>  	free_init_pages("initrd memory", start, end);
>  }
>  #endif
> +
> +/**
> + * After memory hotplug, the variable max_pfn, max_low_pfn and high_memo=
ry will
> + * be affected, it will be updated in this function. Memory hotplug does=
 not
> + * make sense on 32-bit kernel, so we do did not concern it in this func=
tion.
> + */
> +void __meminit __attribute__((weak)) update_pfn(u64 start, u64 size)
> +{
> +#ifdef CONFIG_X86_64
> +	unsigned long limit_low_pfn =3D 1UL<<(32 - PAGE_SHIFT);
> +	unsigned long start_pfn =3D start >> PAGE_SHIFT;
> +	unsigned long end_pfn =3D (start + size) >> PAGE_SHIFT;

Strictly speaking, should use "end_pfn =3D PFN_UP(start + size);".
[Zheng, Shaohui] I will use PFN_UP to replace it in new version.

> +	if (end_pfn > max_pfn) {
> +		max_pfn =3D end_pfn;
> +		high_memory =3D (void *)__va(max_pfn * PAGE_SIZE - 1) + 1;
> +	}
> +
> +	/* if add to low memory, update max_low_pfn */
> +	if (unlikely(start_pfn < limit_low_pfn)) {
> +		if (end_pfn <=3D limit_low_pfn)
> +			max_low_pfn =3D end_pfn;
> +		else
> +			max_low_pfn =3D limit_low_pfn;

X86_64 actually always set max_low_pfn=3Dmax_pfn, in setup_arch():
[Zheng, Shaohui] there should be some misunderstanding, I read the code car=
efully, if the total memory is under 4G, it always max_low_pfn=3Dmax_pfn. I=
f the total memory is larger than 4G, max_low_pfn means the end of low ram.=
 It set max_low_pfn =3D e820_end_of_low_ram_pfn();.

 899 #ifdef CONFIG_X86_64
 900         if (max_pfn > max_low_pfn) {
 901                 max_pfn_mapped =3D init_memory_mapping(1UL<<32,
 902                                                      max_pfn<<PAGE_SHI=
FT);
 903                 /* can we preseve max_low_pfn ?*/
 904                 max_low_pfn =3D max_pfn;
 905         }
 906 #endif

max_low_pfn is used in

- e820_mark_nosave_regions(max_low_pfn);
- dump_pagetable()
- blk_queue_bounce_limit()
- increase_reservation()

and _seems_ to mean "end of direct addressable pfn".

> +	}
> +#endif /* CONFIG_X86_64 */
> +}
> diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
> index b10ec49..6693414 100644
> --- a/include/linux/bootmem.h
> +++ b/include/linux/bootmem.h
> @@ -13,6 +13,7 @@
> =20
>  extern unsigned long max_low_pfn;
>  extern unsigned long min_low_pfn;
> +extern void update_pfn(u64 start, u64 size);
> =20
>  /*
>   * highest page
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 030ce8a..ee7b2d6 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -523,6 +523,14 @@ int __ref add_memory(int nid, u64 start, u64 size)
>  		BUG_ON(ret);
>  	}
> =20
> +	/* update e820 table */

This comment can be eliminated - you already have the very readable printk =
:)
[Zheng, Shaohui] I will remove this comment

> +	printk(KERN_INFO "Adding memory region to e820 table (start:%016Lx, siz=
e:%016Lx).\n",
> +			 (unsigned long long)start, (unsigned long long)size);
> +	e820_add_region(start, size, E820_RAM);

> +	/* update max_pfn, max_low_pfn and high_memory */
> +	update_pfn(start, size);

How about renaming function to update_end_of_memory_vars()?
[Zheng, Shaohui] Agree.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
