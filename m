Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 19EEA6B006A
	for <linux-mm@kvack.org>; Sun, 10 Jan 2010 20:51:57 -0500 (EST)
From: "Zheng, Shaohui" <shaohui.zheng@intel.com>
Date: Mon, 11 Jan 2010 09:51:27 +0800
Subject: RE: [PATCH - resend ] memory-hotplug: create /sys/firmware/memmap
	entry for new memory(v3)
Message-ID: <DA586906BA1FFC4384FCFD6429ECE86031560F78@shzsmsx502.ccr.corp.intel.com>
References: <DA586906BA1FFC4384FCFD6429ECE86031560B8D@shzsmsx502.ccr.corp.intel.com>
 <20100108110810.GA6153@localhost>
In-Reply-To: <20100108110810.GA6153@localhost>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: "Wu, Fengguang" <fengguang.wu@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "ak@linux.intel.com" <ak@linux.intel.com>, "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, "x86@kernel.org" <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

Thanks for fengguang's careful review, I will send out the modified patch s=
oon.

Thanks & Regards,
Shaohui


-----Original Message-----
From: Wu, Fengguang=20
Sent: Friday, January 08, 2010 7:08 PM
To: Zheng, Shaohui
Cc: linux-mm@kvack.org; akpm@linux-foundation.org; linux-kernel@vger.kernel=
.org; ak@linux.intel.com; y-goto@jp.fujitsu.com; Dave Hansen; x86@kernel.or=
g
Subject: Re: [PATCH - resend ] memory-hotplug: create /sys/firmware/memmap =
entry for new memory(v3)

On Fri, Jan 08, 2010 at 11:16:13AM +0800, Zheng, Shaohui wrote:
> Resend the patch to the mailing-list, the original patch URL is at=20
> http://patchwork.kernel.org/patch/69071/. It is already reviewed, but It =
is still not=20
> accepted and no comments, I guess that it should be ignored since we have=
 so many=20
> patches each day, send it again. =20
>=20
> memory-hotplug: create /sys/firmware/memmap entry for hot-added memory
>=20
> Interface firmware_map_add was not called in explicit, Remove it and add =
function
> firmware_map_add_hotplug as hotplug interface of memmap.
>=20
> When we hot-add new memory, sysfs does not export memmap entry for it. we=
 add
>  a call in function add_memory to function firmware_map_add_hotplug.
>=20
> Add a new function add_sysfs_fw_map_entry to create memmap entry, it can =
avoid=20
> duplicated codes.
>=20
> Thanks for the careful review from Fengguang Wu and Dave Hansen.
>=20
> Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
> Acked-by: Andi Kleen <ak@linux.intel.com>
> Acked-by: Yasunori Goto <y-goto@jp.fujitsu.com>
> Acked-by: Dave Hansen <dave@linux.vnet.ibm.com>
> Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
> diff --git a/drivers/firmware/memmap.c b/drivers/firmware/memmap.c
> index 56f9234..ec8c3d4 100644
> --- a/drivers/firmware/memmap.c
> +++ b/drivers/firmware/memmap.c
> @@ -123,52 +123,75 @@ static int firmware_map_add_entry(u64 start, u64 en=
d,
>  }
> =20
>  /**
> - * firmware_map_add() - Adds a firmware mapping entry.
> + * Add memmap entry on sysfs
> + */
> +static int add_sysfs_fw_map_entry(struct firmware_map_entry *entry) {

Minor style issue:

ERROR: open brace '{' following function declarations go on the next line
#31: FILE: drivers/firmware/memmap.c:128:
+static int add_sysfs_fw_map_entry(struct firmware_map_entry *entry) {

total: 1 errors, 0 warnings, 145 lines checked

patches/memory-hotplug-create-sys-firmware-memmap-entry-for-new-memory-v3.p=
atch
has style problems, please review.  If any of these e rrors
are false positives report them to the maintainer, see CHECKPATCH in
MAINTAINERS.
[Zheng, Shaohui] My carelessness, will change it in new patch.

> +	static int map_entries_nr;
> +	static struct kset *mmap_kset;
> +
> +	if (!mmap_kset) {
> +		mmap_kset =3D kset_create_and_add("memmap", NULL, firmware_kobj);
> +		if (WARN_ON(!mmap_kset))

This WARN_ON() may never trigger, or when things go terribly wrong it
repeatedly produce a dozen stack dumps, which don't really help
diagnose the root cause.  Better to just remove it.
[Zheng, Shaohui] Agree.

> +			return -ENOMEM;
> +	}
> +
> +	entry->kobj.kset =3D mmap_kset;
> +	if (kobject_add(&entry->kobj, NULL, "%d", map_entries_nr++))
> +		kobject_put(&entry->kobj);
> +
> +	return 0;
> +}
> +
> +/**
> + * firmware_map_add_early() - Adds a firmware mapping entry.
>   * @start: Start of the memory range.
>   * @end:   End of the memory range (inclusive).
>   * @type:  Type of the memory range.
>   *
> - * This function uses kmalloc() for memory
> - * allocation. Use firmware_map_add_early() if you want to use the bootm=
em
> - * allocator.
> + * Adds a firmware mapping entry. This function uses the bootmem allocat=
or
> + * for memory allocation.
>   *
>   * That function must be called before late_initcall.
>   *
>   * Returns 0 on success, or -ENOMEM if no memory could be allocated.
>   **/
> -int firmware_map_add(u64 start, u64 end, const char *type)
> +int __init firmware_map_add_early(u64 start, u64 end, const char *type)
>  {
>  	struct firmware_map_entry *entry;
> =20
> -	entry =3D kmalloc(sizeof(struct firmware_map_entry), GFP_ATOMIC);
> -	if (!entry)
> +	entry =3D alloc_bootmem(sizeof(struct firmware_map_entry));
> +	if (WARN_ON(!entry))

Ditto.
[Zheng, Shaohui] Agree.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
