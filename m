Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id DB7456B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 02:24:14 -0400 (EDT)
Message-ID: <51FF44B7.8050704@cn.fujitsu.com>
Date: Mon, 05 Aug 2013 14:22:47 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 RESEND 13/18] x86, numa, mem_hotplug: Skip all the
 regions the kernel resides in.
References: <1375434877-20704-1-git-send-email-tangchen@cn.fujitsu.com> <1375434877-20704-14-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1375434877-20704-14-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hi tj,

I have resent the v2 patch-set. Would you please give some more
comments about the memblock and x86 booting code modification ?

And I'm also discussing with the ACPICA guys about the implementation
on ACPI side. I hope we can catch up with 3.12 this time.

Thanks.

On 08/02/2013 05:14 PM, Tang Chen wrote:
> At early time, memblock will reserve some memory for the kernel,
> such as the kernel code and data segments, initrd file, and so on=EF=BC=8C
> which means the kernel resides in these memory regions.
>
> Even if these memory regions are hotpluggable, we should not
> mark them as hotpluggable. Otherwise the kernel won't have enough
> memory to boot.
>
> This patch finds out which memory regions the kernel resides in,
> and skip them when finding all hotpluggable memory regions.
>
> Signed-off-by: Tang Chen<tangchen@cn.fujitsu.com>
> Reviewed-by: Zhang Yanfei<zhangyanfei@cn.fujitsu.com>
> ---
>   mm/memory=5Fhotplug.c |   45 ++++++++++++++++++++++++++++++++++++++++++=
+++
>   1 files changed, 45 insertions(+), 0 deletions(-)
>
> diff --git a/mm/memory=5Fhotplug.c b/mm/memory=5Fhotplug.c
> index ef9ccf8..10a30ef 100644
> --- a/mm/memory=5Fhotplug.c
> +++ b/mm/memory=5Fhotplug.c
> @@ -31,6 +31,7 @@
>   #include<linux/firmware-map.h>
>   #include<linux/stop=5Fmachine.h>
>   #include<linux/acpi.h>
> +#include<linux/memblock.h>
>
>   #include<asm/tlbflush.h>
>
> @@ -93,6 +94,40 @@ static void release=5Fmemory=5Fresource(struct resourc=
e *res)
>
>   #ifdef CONFIG=5FACPI=5FNUMA
>   /**
> + * kernel=5Fresides=5Fin=5Frange - Check if kernel resides in a memory r=
egion.
> + * @base: The base address of the memory region.
> + * @length: The length of the memory region.
> + *
> + * This function is used at early time. It iterates memblock.reserved an=
d check
> + * if the kernel has used any memory in [@base, @base + @length).
> + *
> + * Return true if the kernel resides in the memory region, false otherwi=
se.
> + */
> +static bool =5F=5Finit kernel=5Fresides=5Fin=5Fregion(phys=5Faddr=5Ft ba=
se, u64 length)
> +{
> +	int i;
> +	phys=5Faddr=5Ft start, end;
> +	struct memblock=5Fregion *region;
> +	struct memblock=5Ftype *reserved =3D&memblock.reserved;
> +
> +	for (i =3D 0; i<  reserved->cnt; i++) {
> +		region =3D&reserved->regions[i];
> +
> +		if (region->flags !=3D MEMBLOCK=5FHOTPLUG)
> +			continue;
> +
> +		start =3D region->base;
> +		end =3D region->base + region->size;
> +		if (end<=3D base || start>=3D base + length)
> +			continue;
> +
> +		return true;
> +	}
> +
> +	return false;
> +}
> +
> +/**
>    * find=5Fhotpluggable=5Fmemory - Find out hotpluggable memory from ACP=
I SRAT.
>    *
>    * This function did the following:
> @@ -129,6 +164,16 @@ void =5F=5Finit find=5Fhotpluggable=5Fmemory(void)
>
>   	while (ACPI=5FSUCCESS(acpi=5Fhotplug=5Fmem=5Faffinity(srat=5Fvaddr,&ba=
se,
>   						&size,&offset))) {
> +		/*
> +		 * At early time, memblock will reserve some memory for the
> +		 * kernel, such as the kernel code and data segments, initrd
> +		 * file, and so on=EF=BC=8Cwhich means the kernel resides in these
> +		 * memory regions. These regions should not be hotpluggable.
> +		 * So do not mark them as hotpluggable.
> +		 */
> +		if (kernel=5Fresides=5Fin=5Fregion(base, size))
> +			continue;
> +
>   		/* Will mark hotpluggable memory regions here */
>   	}
>
=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
