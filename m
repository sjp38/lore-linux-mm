Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A76976B0279
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 23:55:07 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h21so21116250pfk.13
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 20:55:07 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id t28si5786358pfl.241.2017.06.08.20.55.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jun 2017 20:55:06 -0700 (PDT)
Subject: Re: [HMM 07/15] mm/ZONE_DEVICE: new type of ZONE_DEVICE for
 unaddressable memory v3
References: <20170524172024.30810-1-jglisse@redhat.com>
 <20170524172024.30810-8-jglisse@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <9d4efdd1-1a76-27e2-5e6b-86bfe13b9865@nvidia.com>
Date: Thu, 8 Jun 2017 20:55:05 -0700
MIME-Version: 1.0
In-Reply-To: <20170524172024.30810-8-jglisse@redhat.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: Dan Williams <dan.j.williams@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On 05/24/2017 10:20 AM, J=C3=A9r=C3=B4me Glisse wrote:
[...8<...]
> +#if IS_ENABLED(CONFIG_DEVICE_PRIVATE)
> +int device_private_entry_fault(struct vm_area_struct *vma,
> +		       unsigned long addr,
> +		       swp_entry_t entry,
> +		       unsigned int flags,
> +		       pmd_t *pmdp)
> +{
> +	struct page *page =3D device_private_entry_to_page(entry);
> +
> +	/*
> +	 * The page_fault() callback must migrate page back to system memory
> +	 * so that CPU can access it. This might fail for various reasons
> +	 * (device issue, device was unsafely unplugged, ...). When such
> +	 * error conditions happen, the callback must return VM_FAULT_SIGBUS.
> +	 *
> +	 * Note that because memory cgroup charges are accounted to the device
> +	 * memory, this should never fail because of memory restrictions (but
> +	 * allocation of regular system page might still fail because we are
> +	 * out of memory).
> +	 *
> +	 * There is a more in-depth description of what that callback can and
> +	 * cannot do, in include/linux/memremap.h
> +	 */
> +	return page->pgmap->page_fault(vma, addr, page, flags, pmdp);
> +}
> +EXPORT_SYMBOL(device_private_entry_fault);
> +#endif /* CONFIG_DEVICE_PRIVATE */
> +
>   static void pgmap_radix_release(struct resource *res)
>   {
>   	resource_size_t key, align_start, align_size, align_end;
> @@ -321,6 +351,10 @@ void *devm_memremap_pages(struct device *dev, struct=
 resource *res,
>   	}
>   	pgmap->ref =3D ref;
>   	pgmap->res =3D &page_map->res;
> +	pgmap->type =3D MEMORY_DEVICE_PUBLIC;
> +	pgmap->page_fault =3D NULL;
> +	pgmap->page_free =3D NULL;
> +	pgmap->data =3D NULL;
>  =20
>   	mutex_lock(&pgmap_lock);
>   	error =3D 0;
> diff --git a/mm/Kconfig b/mm/Kconfig
> index d744cff..f5357ff 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -736,6 +736,19 @@ config ZONE_DEVICE
>  =20
>   	  If FS_DAX is enabled, then say Y.
>  =20
> +config DEVICE_PRIVATE
> +	bool "Unaddressable device memory (GPU memory, ...)"
> +	depends on X86_64
> +	depends on ZONE_DEVICE
> +	depends on MEMORY_HOTPLUG
> +	depends on MEMORY_HOTREMOVE
> +	depends on SPARSEMEM_VMEMMAP
> +
> +	help
> +	  Allows creation of struct pages to represent unaddressable device
> +	  memory; i.e., memory that is only accessible from the device (or
> +	  group of devices).
> +

Hi Jerome,

CONFIG_DEVICE_PRIVATE has caused me some problems, because it's not coupled=
 to HMM_DEVMEM.

To fix this, my first choice would be to just s/DEVICE_PRIVATE/HMM_DEVMEM/g=
 , because I don't see=20
any value to DEVICE_PRIVATE as an independent Kconfig choice. It's complica=
ting the Kconfig choices,=20
and adding problems. However, if DEVICE_PRIVATE must be kept, then somethin=
g like this also fixes my=20
HMM tests:

From: John Hubbard <jhubbard@nvidia.com>
Date: Thu, 8 Jun 2017 20:13:13 -0700
Subject: [PATCH] hmm: select CONFIG_DEVICE_PRIVATE with HMM_DEVMEM

The HMM_DEVMEM feature is useless without the various
features that are guarded with CONFIG_DEVICE_PRIVATE.
Therefore, auto-select DEVICE_PRIVATE when selecting
HMM_DEVMEM.

Otherwise, you can easily end up with a partially
working HMM installation: if you select HMM_DEVMEM,
but do not select DEVICE_PRIVATE, then faulting and
migrating to a device (such as a GPU) works, but CPU
page faults are ignored, so the page never migrates
back to the CPU.

Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
  mm/Kconfig | 2 ++
  1 file changed, 2 insertions(+)

diff --git a/mm/Kconfig b/mm/Kconfig
index 46296d5d7570..23d2f5ec865e 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -318,6 +318,8 @@ config HMM_DEVMEM
  	bool "HMM device memory helpers (to leverage ZONE_DEVICE)"
  	depends on ARCH_HAS_HMM
  	select HMM
+	select DEVICE_PRIVATE
+
  	help
  	  HMM devmem is a set of helper routines to leverage the ZONE_DEVICE
  	  feature. This is just to avoid having device drivers to replicating a =
lot
--=20
2.13.1

This is a minor thing, and I don't think this needs to hold up merging HMM =
v23 into -mm, IMHO. But I=20
would like it fixed at some point.

thanks,
--
John Hubbard
NVIDIA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
