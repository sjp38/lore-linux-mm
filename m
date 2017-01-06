Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id E9F736B0069
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 12:58:35 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id 189so699036059oif.3
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 09:58:35 -0800 (PST)
Received: from mail-oi0-x229.google.com (mail-oi0-x229.google.com. [2607:f8b0:4003:c06::229])
        by mx.google.com with ESMTPS id q205si1656784oic.174.2017.01.06.09.58.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jan 2017 09:58:35 -0800 (PST)
Received: by mail-oi0-x229.google.com with SMTP id 128so428903210oig.0
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 09:58:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1483721203-1678-4-git-send-email-jglisse@redhat.com>
References: <1483721203-1678-1-git-send-email-jglisse@redhat.com> <1483721203-1678-4-git-send-email-jglisse@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 6 Jan 2017 09:58:34 -0800
Message-ID: <CAPcyv4hTAiOqZ+HEid4maxmi96ciUkXx2h01ORBEQLOwd85-0Q@mail.gmail.com>
Subject: Re: [HMM v15 03/16] mm/ZONE_DEVICE/devmem_pages_remove: allow early
 removal of device memory
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Fri, Jan 6, 2017 at 8:46 AM, J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com=
> wrote:
> Some device driver manage multiple physical devices memory from a single
> fake device driver. In that case the fake device might outlive the real
> device and ZONE_DEVICE and its resource allocated for a real device would
> waste resources in the meantime.
>
> This patch allow early removal of ZONE_DEVICE and associated resource,
> before device driver is tear down.
>
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---
>  include/linux/memremap.h |  7 +++++++
>  kernel/memremap.c        | 14 ++++++++++++++
>  2 files changed, 21 insertions(+)
>
> diff --git a/include/linux/memremap.h b/include/linux/memremap.h
> index f7e0609..32314d2 100644
> --- a/include/linux/memremap.h
> +++ b/include/linux/memremap.h
> @@ -53,6 +53,7 @@ struct dev_pagemap {
>  void *devm_memremap_pages(struct device *dev, struct resource *res,
>                 struct percpu_ref *ref, struct vmem_altmap *altmap);
>  struct dev_pagemap *find_dev_pagemap(resource_size_t phys);
> +int devm_memremap_pages_remove(struct device *dev, struct dev_pagemap *p=
gmap);
>
>  static inline bool dev_page_allow_migrate(const struct page *page)
>  {
> @@ -78,6 +79,12 @@ static inline struct dev_pagemap *find_dev_pagemap(res=
ource_size_t phys)
>         return NULL;
>  }
>
> +static inline int devm_memremap_pages_remove(struct device *dev,
> +                                            struct dev_pagemap *pgmap)
> +{
> +       return -EINVAL;
> +}
> +
>  static inline bool dev_page_allow_migrate(const struct page *page)
>  {
>         return false;
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index 07665eb..250ef25 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -387,6 +387,20 @@ void *devm_memremap_pages(struct device *dev, struct=
 resource *res,
>  }
>  EXPORT_SYMBOL(devm_memremap_pages);
>
> +static int devm_page_map_match(struct device *dev, void *data, void *mat=
ch_data)
> +{
> +       struct page_map *page_map =3D data;
> +
> +       return &page_map->pgmap =3D=3D match_data;
> +}
> +
> +int devm_memremap_pages_remove(struct device *dev, struct dev_pagemap *p=
gmap)
> +{
> +       return devres_release(dev, &devm_memremap_pages_release,
> +                             &devm_page_map_match, pgmap);
> +}
> +EXPORT_SYMBOL(devm_memremap_pages_remove);

I think this should be called devm_memunmap_pages() to mirror
devm_memunmap(), and it should take the virtual address returned from
devm_memremap_pages() not pgmap which is an internal detail.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
