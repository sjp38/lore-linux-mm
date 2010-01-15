Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D6FE36B0047
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 22:41:22 -0500 (EST)
From: "Zheng, Shaohui" <shaohui.zheng@intel.com>
Date: Fri, 15 Jan 2010 11:41:14 +0800
Subject: RE: [PATCH-RESEND v4] memory-hotplug: create /sys/firmware/memmap
 entry for new memory
Message-ID: <DA586906BA1FFC4384FCFD6429ECE86034FF8354@shzsmsx502.ccr.corp.intel.com>
References: <DA586906BA1FFC4384FCFD6429ECE86031560F92@shzsmsx502.ccr.corp.intel.com>
 <20100113142827.26b2269e.akpm@linux-foundation.org>
In-Reply-To: <20100113142827.26b2269e.akpm@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "ak@linux.intel.com" <ak@linux.intel.com>, "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, "x86@kernel.org" <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jan 2010 10:00:11 +0800
"Zheng, Shaohui" <shaohui.zheng@intel.com> wrote:

> Resend the memmap patch v4 to mailing-list after follow up fengguang's re=
view=20
> comments.=20
>=20
> memory-hotplug: create /sys/firmware/memmap entry for hot-added memory
>=20
> Interface firmware_map_add was not called in explict, Remove it and add f=
unction
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

Please describe the format of the proposed sysfs file.  Example output
would be suitable.

> @@ -123,20 +123,40 @@ static int firmware_map_add_entry(u64 start, u64 en=
d,
>  }
> =20
>  /**
> - * firmware_map_add() - Adds a firmware mapping entry.
> + * Add memmap entry on sysfs
> + */
> +static int add_sysfs_fw_map_entry(struct firmware_map_entry *entry)
> +{
> +	static int map_entries_nr;
> +	static struct kset *mmap_kset;
> +
> +	if (!mmap_kset) {
> +		mmap_kset =3D kset_create_and_add("memmap", NULL, firmware_kobj);
> +		if (!mmap_kset)
> +			return -ENOMEM;
> +	}

This is a bit racy if two threads execute it at the same time.  I guess
it doesn't matter.
[Zheng, Shaohui] function add_sysfs_fw_map_entry will be called when OS boo=
ts up and we hot-add memory, it never has chance to be execute in two threa=
ds, it should be okay.


> +	entry->kobj.kset =3D mmap_kset;
> +	if (kobject_add(&entry->kobj, NULL, "%d", map_entries_nr++))
> +		kobject_put(&entry->kobj);

hm.  Is this refcounting correct?
[Zheng, Shaohui] all objects of firmware_map_entry shares the same kset, I =
use a static pointer to store it. When create next entry, we can get the re=
ference easier. I already test it, it works fine.

> +
> +	return 0;
> +}

One caller of add_sysfs_fw_map_entry() is __meminit and the other is
__init.  So this function can be __meminit?
[Zheng, Shaohui] function add_sysfs_fw_map_entry() should be still here aft=
er booting up, it will be called when we hot-add new memory, so it can not =
be _init. __meminit should be the correct since this function is related me=
mory hot-plug.

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
> @@ -148,27 +168,31 @@ int firmware_map_add(u64 start, u64 end, const char=
 *type)
>  }
> =20
>  /**
> - * firmware_map_add_early() - Adds a firmware mapping entry.
> + * firmware_map_add_hotplug() - Adds a firmware mapping entry when we do
> + * memory hotplug.
>   * @start: Start of the memory range.
>   * @end:   End of the memory range (inclusive).
>   * @type:  Type of the memory range.
>   *
> - * Adds a firmware mapping entry. This function uses the bootmem allocat=
or
> - * for memory allocation. Use firmware_map_add() if you want to use kmal=
loc().
> - *
> - * That function must be called before late_initcall.
> + * Adds a firmware mapping entry. This function is for memory hotplug, i=
t is
> + * simiar with function firmware_map_add_early. the only difference is t=
hat

s/simiar/similar/
s/with/to/
s/the/The/
s/function firmware_map_add_early/firmware_map_add_early()/
[Zheng, Shaohui] sorry for my carelessness.
=09
> + * it will create the syfs entry dynamically.
>   *
>   * Returns 0 on success, or -ENOMEM if no memory could be allocated.
>   **/
> -int __init firmware_map_add_early(u64 start, u64 end, const char *type)
> +int __meminit firmware_map_add_hotplug(u64 start, u64 end, const char *t=
ype)
>  {
>  	struct firmware_map_entry *entry;
> =20
> -	entry =3D alloc_bootmem(sizeof(struct firmware_map_entry));
> -	if (WARN_ON(!entry))
> +	entry =3D kzalloc(sizeof(struct firmware_map_entry), GFP_ATOMIC);
> +	if (!entry)
>  		return -ENOMEM;
> =20
> -	return firmware_map_add_entry(start, end, type, entry);
> +	firmware_map_add_entry(start, end, type, entry);
> +	/* create the memmap entry */
> +	add_sysfs_fw_map_entry(entry);
> +
> +	return 0;
>  }
> =20
>  /*
> @@ -214,18 +238,10 @@ static ssize_t memmap_attr_show(struct kobject *kob=
j,
>   */
>  static int __init memmap_init(void)
>  {
> -	int i =3D 0;
>  	struct firmware_map_entry *entry;
> -	struct kset *memmap_kset;
> -
> -	memmap_kset =3D kset_create_and_add("memmap", NULL, firmware_kobj);
> -	if (WARN_ON(!memmap_kset))
> -		return -ENOMEM;
> =20
>  	list_for_each_entry(entry, &map_entries, list) {
> -		entry->kobj.kset =3D memmap_kset;
> -		if (kobject_add(&entry->kobj, NULL, "%d", i++))
> -			kobject_put(&entry->kobj);
> +		add_sysfs_fw_map_entry(entry);
>  	}

The braces are now unneeded.  checkpatch used to warn about this I
think.  Either someone broke checkpatch or it doesn't understand
list_for_each_entry().
[Zheng, Shaohui] I will remove the unneeded braces.

>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
