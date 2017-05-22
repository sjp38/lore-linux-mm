Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 596126B02C3
	for <linux-mm@kvack.org>; Mon, 22 May 2017 17:17:58 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id w205so174205022oif.12
        for <linux-mm@kvack.org>; Mon, 22 May 2017 14:17:58 -0700 (PDT)
Received: from mail-oi0-x231.google.com (mail-oi0-x231.google.com. [2607:f8b0:4003:c06::231])
        by mx.google.com with ESMTPS id b13si7436560ote.241.2017.05.22.14.17.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 14:17:57 -0700 (PDT)
Received: by mail-oi0-x231.google.com with SMTP id h4so177904411oib.3
        for <linux-mm@kvack.org>; Mon, 22 May 2017 14:17:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170522165206.6284-8-jglisse@redhat.com>
References: <20170522165206.6284-1-jglisse@redhat.com> <20170522165206.6284-8-jglisse@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 22 May 2017 14:17:56 -0700
Message-ID: <CAPcyv4jJh8G7y-Gr-54iBVGrGDQwu=M=FXtkSpXyd=2oNqPcWA@mail.gmail.com>
Subject: Re: [HMM 07/15] mm/ZONE_DEVICE: new type of ZONE_DEVICE for
 unaddressable memory v2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Mon, May 22, 2017 at 9:51 AM, J=C3=A9r=C3=B4me Glisse <jglisse@redhat.co=
m> wrote:
> HMM (heterogeneous memory management) need struct page to support migrati=
on
> from system main memory to device memory.  Reasons for HMM and migration =
to
> device memory is explained with HMM core patch.
>
> This patch deals with device memory that is un-addressable memory (ie CPU
> can not access it). Hence we do not want those struct page to be manage
> like regular memory. That is why we extend ZONE_DEVICE to support differe=
nt
> types of memory.
>
> A persistent memory type is define for existing user of ZONE_DEVICE and a
> new device un-addressable type is added for the un-addressable memory typ=
e.
> There is a clear separation between what is expected from each memory typ=
e
> and existing user of ZONE_DEVICE are un-affected by new requirement and n=
ew
> use of the un-addressable type. All specific code path are protect with
> test against the memory type.
>
> Because memory is un-addressable we use a new special swap type for when
> a page is migrated to device memory (this reduces the number of maximum
> swap file).
>
> The main two additions beside memory type to ZONE_DEVICE is two callbacks=
.
> First one, page_free() is call whenever page refcount reach 1 (which mean=
s
> the page is free as ZONE_DEVICE page never reach a refcount of 0). This
> allow device driver to manage its memory and associated struct page.
>
> The second callback page_fault() happens when there is a CPU access to
> an address that is back by a device page (which are un-addressable by the
> CPU). This callback is responsible to migrate the page back to system
> main memory. Device driver can not block migration back to system memory,
> HMM make sure that such page can not be pin into device memory.
>
> If device is in some error condition and can not migrate memory back then
> a CPU page fault to device memory should end with SIGBUS.
>
> Changed since v1:
>   - rename to device private memory (from device unaddressable)
>
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
[..]
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 229afe3..d49d816 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -737,6 +737,19 @@ config ZONE_DEVICE
>
>           If FS_DAX is enabled, then say Y.
>
> +config DEVICE_UNADDRESSABLE
> +       bool "Unaddressable device memory (GPU memory, ...)"
> +       depends on X86_64
> +       depends on ZONE_DEVICE
> +       depends on MEMORY_HOTPLUG
> +       depends on MEMORY_HOTREMOVE
> +       depends on SPARSEMEM_VMEMMAP
> +
> +       help
> +         Allows creation of struct pages to represent unaddressable devi=
ce
> +         memory; i.e., memory that is only accessible from the device (o=
r
> +         group of devices).

Lets change config symbol naming from "device un-addressable memory"
to "device private memory" the same way we did for the code symbols.

With that change you can add:

Acked-by: Dan Williams <dan.j.williams@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
