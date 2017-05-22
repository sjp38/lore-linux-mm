Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id BC9E1831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 15:29:55 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id d142so172295001oib.7
        for <linux-mm@kvack.org>; Mon, 22 May 2017 12:29:55 -0700 (PDT)
Received: from mail-oi0-x229.google.com (mail-oi0-x229.google.com. [2607:f8b0:4003:c06::229])
        by mx.google.com with ESMTPS id y32si7724930oty.29.2017.05.22.12.29.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 12:29:54 -0700 (PDT)
Received: by mail-oi0-x229.google.com with SMTP id b204so174572887oii.1
        for <linux-mm@kvack.org>; Mon, 22 May 2017 12:29:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170522165206.6284-9-jglisse@redhat.com>
References: <20170522165206.6284-1-jglisse@redhat.com> <20170522165206.6284-9-jglisse@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 22 May 2017 12:29:53 -0700
Message-ID: <CAPcyv4hodnCFEy8iyb3jQPJ=TNj-L2uZQKJqb7JTqSv=YE0BDg@mail.gmail.com>
Subject: Re: [HMM 08/15] mm/ZONE_DEVICE: special case put_page() for device
 private pages
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Mon, May 22, 2017 at 9:51 AM, J=C3=A9r=C3=B4me Glisse <jglisse@redhat.co=
m> wrote:
> A ZONE_DEVICE page that reach a refcount of 1 is free ie no longer
> have any user. For device private pages this is important to catch
> and thus we need to special case put_page() for this.
>
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---
>  include/linux/mm.h | 30 ++++++++++++++++++++++++++++++
>  kernel/memremap.c  |  1 -
>  2 files changed, 30 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index a825dab..11f7bac 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -23,6 +23,7 @@
>  #include <linux/page_ext.h>
>  #include <linux/err.h>
>  #include <linux/page_ref.h>
> +#include <linux/memremap.h>
>
>  struct mempolicy;
>  struct anon_vma;
> @@ -795,6 +796,20 @@ static inline bool is_device_private_page(const stru=
ct page *page)
>         return ((page_zonenum(page) =3D=3D ZONE_DEVICE) &&
>                 (page->pgmap->type =3D=3D MEMORY_DEVICE_PRIVATE));
>  }
> +
> +static inline void put_zone_device_private_page(struct page *page)
> +{
> +       int count =3D page_ref_dec_return(page);
> +
> +       /*
> +        * If refcount is 1 then page is freed and refcount is stable as =
nobody
> +        * holds a reference on the page.
> +        */
> +       if (count =3D=3D 1)
> +               page->pgmap->page_free(page, page->pgmap->data);
> +       else if (!count)
> +               __put_page(page);
> +}
>  #else
>  static inline bool is_zone_device_page(const struct page *page)
>  {
> @@ -805,6 +820,10 @@ static inline bool is_device_private_page(const stru=
ct page *page)
>  {
>         return false;
>  }
> +
> +static inline void put_zone_device_private_page(struct page *page)
> +{
> +}
>  #endif
>
>  static inline void get_page(struct page *page)
> @@ -822,6 +841,17 @@ static inline void put_page(struct page *page)
>  {
>         page =3D compound_head(page);
>
> +       /*
> +        * For private device pages we need to catch refcount transition =
from
> +        * 2 to 1, when refcount reach one it means the private device pa=
ge is
> +        * free and we need to inform the device driver through callback.=
 See
> +        * include/linux/memremap.h and HMM for details.
> +        */
> +       if (unlikely(is_device_private_page(page))) {

Since I presume HMM is a niche use case can we make this a
"static_branch_unlikely(&hmm_key) && is_device_private_page(page))"?
That way non-hmm platforms see minimal overhead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
