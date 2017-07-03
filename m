Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9E8B76B0279
	for <linux-mm@kvack.org>; Mon,  3 Jul 2017 19:49:20 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id f36so43128199ybj.11
        for <linux-mm@kvack.org>; Mon, 03 Jul 2017 16:49:20 -0700 (PDT)
Received: from mail-yb0-x235.google.com (mail-yb0-x235.google.com. [2607:f8b0:4002:c09::235])
        by mx.google.com with ESMTPS id b5si4889059ywa.116.2017.07.03.16.49.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jul 2017 16:49:19 -0700 (PDT)
Received: by mail-yb0-x235.google.com with SMTP id f194so148929yba.3
        for <linux-mm@kvack.org>; Mon, 03 Jul 2017 16:49:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170703211415.11283-2-jglisse@redhat.com>
References: <20170703211415.11283-1-jglisse@redhat.com> <20170703211415.11283-2-jglisse@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 3 Jul 2017 16:49:18 -0700
Message-ID: <CAPcyv4gXso2W0gxaeTsc7g9nTQnkO3WFNZfsdS95NvfYJupnxg@mail.gmail.com>
Subject: Re: [PATCH 1/5] mm/persistent-memory: match IORES_DESC name and enum
 memory_type one
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Mon, Jul 3, 2017 at 2:14 PM, J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com=
> wrote:
> Use consistent name between IORES_DESC and enum memory_type, rename
> MEMORY_DEVICE_PUBLIC to MEMORY_DEVICE_PERSISTENT. This is to free up
> the public name for CDM (cache coherent device memory) for which the
> term public is a better match.
>
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---
>  include/linux/memremap.h | 4 ++--
>  kernel/memremap.c        | 2 +-
>  2 files changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/include/linux/memremap.h b/include/linux/memremap.h
> index 57546a07a558..2299cc2d387d 100644
> --- a/include/linux/memremap.h
> +++ b/include/linux/memremap.h
> @@ -41,7 +41,7 @@ static inline struct vmem_altmap *to_vmem_altmap(unsign=
ed long memmap_start)
>   * Specialize ZONE_DEVICE memory into multiple types each having differe=
nts
>   * usage.
>   *
> - * MEMORY_DEVICE_PUBLIC:
> + * MEMORY_DEVICE_PERSISTENT:
>   * Persistent device memory (pmem): struct page might be allocated in di=
fferent
>   * memory and architecture might want to perform special actions. It is =
similar
>   * to regular memory, in that the CPU can access it transparently. Howev=
er,
> @@ -59,7 +59,7 @@ static inline struct vmem_altmap *to_vmem_altmap(unsign=
ed long memmap_start)
>   * include/linux/hmm.h and Documentation/vm/hmm.txt.
>   */
>  enum memory_type {
> -       MEMORY_DEVICE_PUBLIC =3D 0,
> +       MEMORY_DEVICE_PERSISTENT =3D 0,
>         MEMORY_DEVICE_PRIVATE,
>  };
>
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index b9baa6c07918..e82456c39a6a 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -350,7 +350,7 @@ void *devm_memremap_pages(struct device *dev, struct =
resource *res,
>         }
>         pgmap->ref =3D ref;
>         pgmap->res =3D &page_map->res;
> -       pgmap->type =3D MEMORY_DEVICE_PUBLIC;
> +       pgmap->type =3D MEMORY_DEVICE_PERSISTENT;
>         pgmap->page_fault =3D NULL;
>         pgmap->page_free =3D NULL;
>         pgmap->data =3D NULL;

I think we need a different name. There's nothing "persistent" about
the devm_memremap_pages() path. Why can't they share name, is the only
difference coherence? I'm thinking something like:

MEMORY_DEVICE_PRIVATE
MEMORY_DEVICE_COHERENT /* persistent memory and coherent devices */
MEMORY_DEVICE_IO /* "public", but not coherent */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
