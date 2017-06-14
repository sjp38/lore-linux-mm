Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 406276B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 19:10:35 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id q78so11937494pfj.9
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 16:10:35 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id p5si924772pgc.140.2017.06.14.16.10.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 16:10:34 -0700 (PDT)
Subject: Re: [HMM-CDM 5/5] mm/hmm: simplify kconfig and enable HMM and
 DEVICE_PUBLIC for ppc64
References: <20170614201144.9306-1-jglisse@redhat.com>
 <20170614201144.9306-6-jglisse@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <9aeed880-c200-a070-a7a4-212ee38c15ed@nvidia.com>
Date: Wed, 14 Jun 2017 16:10:32 -0700
MIME-Version: 1.0
In-Reply-To: <20170614201144.9306-6-jglisse@redhat.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: David Nellans <dnellans@nvidia.com>, Balbir Singh <balbirs@au1.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 06/14/2017 01:11 PM, J=C3=A9r=C3=B4me Glisse wrote:
> This just simplify kconfig and allow HMM and DEVICE_PUBLIC to be
> selected for ppc64 once ZONE_DEVICE is allowed on ppc64 (different
> patchset).
>=20
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> Cc: Balbir Singh <balbirs@au1.ibm.com>
> Cc: Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>
> Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> ---
>   include/linux/hmm.h |  4 ++--
>   mm/Kconfig          | 27 ++++++---------------------
>   mm/hmm.c            |  4 ++--
>   3 files changed, 10 insertions(+), 25 deletions(-)
>=20
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index f6713b2..720d18c 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -327,7 +327,7 @@ int hmm_vma_fault(struct vm_area_struct *vma,
>   #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
>  =20
>  =20
> -#if IS_ENABLED(CONFIG_HMM_DEVMEM)
> +#if IS_ENABLED(CONFIG_DEVICE_PRIVATE) || IS_ENABLED(CONFIG_DEVICE_PUBLIC=
)
>   struct hmm_devmem;
>  =20
>   struct page *hmm_vma_alloc_locked_page(struct vm_area_struct *vma,
> @@ -456,7 +456,7 @@ struct hmm_device {
>    */
>   struct hmm_device *hmm_device_new(void *drvdata);
>   void hmm_device_put(struct hmm_device *hmm_device);
> -#endif /* IS_ENABLED(CONFIG_HMM_DEVMEM) */
> +#endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
>  =20
>  =20
>   /* Below are for HMM internal use only! Not to be used by device driver=
! */
> diff --git a/mm/Kconfig b/mm/Kconfig
> index ad082b9..7de939a 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -265,7 +265,7 @@ config ARCH_ENABLE_HUGEPAGE_MIGRATION
>   config ARCH_HAS_HMM
>   	bool
>   	default y
> -	depends on X86_64
> +	depends on X86_64 || PPC64
>   	depends on ZONE_DEVICE
>   	depends on MMU && 64BIT
>   	depends on MEMORY_HOTPLUG
> @@ -277,7 +277,7 @@ config HMM
>  =20
>   config HMM_MIRROR
>   	bool "HMM mirror CPU page table into a device page table"
> -	depends on ARCH_HAS_HMM
> +	depends on ARCH_HAS_HMM && X86_64
>   	select MMU_NOTIFIER
>   	select HMM
>   	help

Hi Jerome,

There are still some problems with using this configuration. First and fore=
most, it is still=20
possible (and likely, given the complete dissimilarity in naming, and diffe=
rence in location on the=20
screen) to choose HMM_MIRROR, and *not* to choose either DEVICE_PRIVATE or =
DEVICE_PUBLIC. And then=20
we end up with a swath of important page fault handling code being ifdef'd =
out, and one ends up=20
having to investigate why.

As for solutions, at least for the x86 (DEVICE_PRIVATE)case, we could do th=
is:

diff --git a/mm/Kconfig b/mm/Kconfig
index 7de939a29466..f64182d7b956 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -279,6 +279,7 @@ config HMM_MIRROR
         bool "HMM mirror CPU page table into a device page table"
         depends on ARCH_HAS_HMM && X86_64
         select MMU_NOTIFIER
+       select DEVICE_PRIVATE
         select HMM
         help
           Select HMM_MIRROR if you want to mirror range of the CPU page ta=
ble of a

...and that is better than the other direction (having HMM_MIRROR depend on=
 DEVICE_PRIVATE), because=20
in the latter case, HMM_MIRROR will disappear (and it's several lines above=
) until you select=20
DEVICE_PRIVATE. That is hard to work with for the user.

The user will tend to select HMM_MIRROR, but it is *not* obvious that he/sh=
e should also select=20
DEVICE_PRIVATE. So Kconfig should do it for them.

In fact, I'm not even sure if the DEVICE_PRIVATE and DEVICE_PUBLIC actually=
 need Kconfig protection,=20
but if they don't, then life would be easier for whoever is configuring the=
ir kernel.


> @@ -287,15 +287,6 @@ config HMM_MIRROR
>   	  page tables (at PAGE_SIZE granularity), and must be able to recover =
from
>   	  the resulting potential page faults.
>  =20
> -config HMM_DEVMEM
> -	bool "HMM device memory helpers (to leverage ZONE_DEVICE)"
> -	depends on ARCH_HAS_HMM
> -	select HMM
> -	help
> -	  HMM devmem is a set of helper routines to leverage the ZONE_DEVICE
> -	  feature. This is just to avoid having device drivers to replicating a=
 lot
> -	  of boiler plate code.  See Documentation/vm/hmm.txt.
> -

Yes, probably good to remove HMM_DEVMEM as a separate conig choice.

>   config PHYS_ADDR_T_64BIT
>   	def_bool 64BIT || ARCH_PHYS_ADDR_T_64BIT
>  =20
> @@ -720,11 +711,8 @@ config ZONE_DEVICE
>  =20
>   config DEVICE_PRIVATE
>   	bool "Unaddressable device memory (GPU memory, ...)"
> -	depends on X86_64
> -	depends on ZONE_DEVICE
> -	depends on MEMORY_HOTPLUG
> -	depends on MEMORY_HOTREMOVE
> -	depends on SPARSEMEM_VMEMMAP
> +	depends on ARCH_HAS_HMM && X86_64
> +	select HMM
>  =20
>   	help
>   	  Allows creation of struct pages to represent unaddressable device
> @@ -733,11 +721,8 @@ config DEVICE_PRIVATE
>  =20
>   config DEVICE_PUBLIC
>   	bool "Unaddressable device memory (GPU memory, ...)"

Typo: this is a copy-and-paste from DEVICE_PRIVATE, but the "Unaddressable"=
 part wasn't changed, so=20
you'll end up with two identical-looking lines in `make menuconfig`.

Maybe "Directly addressable device memory"? And make the line less identica=
l to DEVICE_PRIVATE?

thanks,
--
John Hubbard
NVIDIA

> -	depends on X86_64
> -	depends on ZONE_DEVICE
> -	depends on MEMORY_HOTPLUG
> -	depends on MEMORY_HOTREMOVE
> -	depends on SPARSEMEM_VMEMMAP
> +	depends on ARCH_HAS_HMM
> +	select HMM
>  =20
>   	help
>   	  Allows creation of struct pages to represent addressable device
> diff --git a/mm/hmm.c b/mm/hmm.c
> index aed110e..085cc06 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -747,7 +747,7 @@ EXPORT_SYMBOL(hmm_vma_fault);
>   #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
>  =20
>  =20
> -#if IS_ENABLED(CONFIG_HMM_DEVMEM)
> +#if IS_ENABLED(CONFIG_DEVICE_PRIVATE) || IS_ENABLED(CONFIG_DEVICE_PUBLIC=
)
>   struct page *hmm_vma_alloc_locked_page(struct vm_area_struct *vma,
>   				       unsigned long addr)
>   {
> @@ -1306,4 +1306,4 @@ static int __init hmm_init(void)
>   }
>  =20
>   device_initcall(hmm_init);
> -#endif /* IS_ENABLED(CONFIG_HMM_DEVMEM) */
> +#endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
> --=20
> 2.9.3
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
