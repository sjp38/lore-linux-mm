Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id C48D06B0397
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 04:48:38 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id x7so3352393qka.9
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 01:48:38 -0700 (PDT)
Received: from mail-qt0-x234.google.com (mail-qt0-x234.google.com. [2607:f8b0:400d:c0d::234])
        by mx.google.com with ESMTPS id l63si5679940qkb.301.2017.03.29.01.48.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Mar 2017 01:48:37 -0700 (PDT)
Received: by mail-qt0-x234.google.com with SMTP id i34so6901870qtc.0
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 01:48:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1489798493-16600-3-git-send-email-labbott@redhat.com>
References: <1489798493-16600-1-git-send-email-labbott@redhat.com> <1489798493-16600-3-git-send-email-labbott@redhat.com>
From: Benjamin Gaignard <benjamin.gaignard@linaro.org>
Date: Wed, 29 Mar 2017 10:48:36 +0200
Message-ID: <CA+M3ks6F_9dhfD4DLMJ=GNsr=H86_XLyiBHvzvz6+akjLSNBUw@mail.gmail.com>
Subject: Re: [RFC PATCHv2 02/21] cma: Introduce cma_for_each_area
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, =?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, Rom Lemarchand <romlem@google.com>, devel@driverdev.osuosl.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, Brian Starkey <brian.starkey@arm.com>, Daniel Vetter <daniel.vetter@intel.com>, Mark Brown <broonie@kernel.org>, Linux MM <linux-mm@kvack.org>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>

2017-03-18 1:54 GMT+01:00 Laura Abbott <labbott@redhat.com>:
>
> Frameworks (e.g. Ion) may want to iterate over each possible CMA area to
> allow for enumeration. Introduce a function to allow a callback.

even outside ION rework that could be useful

Reviewed-by: Benjamin Gaignard <benjamin.gaignard@linaro.org>

>
> Signed-off-by: Laura Abbott <labbott@redhat.com>
> ---
>  include/linux/cma.h |  2 ++
>  mm/cma.c            | 14 ++++++++++++++
>  2 files changed, 16 insertions(+)
>
> diff --git a/include/linux/cma.h b/include/linux/cma.h
> index d41d1f8..3e8fbf5 100644
> --- a/include/linux/cma.h
> +++ b/include/linux/cma.h
> @@ -34,4 +34,6 @@ extern int cma_init_reserved_mem(phys_addr_t base, phys=
_addr_t size,
>  extern struct page *cma_alloc(struct cma *cma, size_t count, unsigned in=
t align,
>                               gfp_t gfp_mask);
>  extern bool cma_release(struct cma *cma, const struct page *pages, unsig=
ned int count);
> +
> +extern int cma_for_each_area(int (*it)(struct cma *cma, void *data), voi=
d *data);
>  #endif
> diff --git a/mm/cma.c b/mm/cma.c
> index 0d187b1..9a040e1 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -498,3 +498,17 @@ bool cma_release(struct cma *cma, const struct page =
*pages, unsigned int count)
>
>         return true;
>  }
> +
> +int cma_for_each_area(int (*it)(struct cma *cma, void *data), void *data=
)
> +{
> +       int i;
> +
> +       for (i =3D 0; i < cma_area_count; i++) {
> +               int ret =3D it(&cma_areas[i], data);
> +
> +               if (ret)
> +                       return ret;
> +       }
> +
> +       return 0;
> +}
> --
> 2.7.4
>



--=20
Benjamin Gaignard

Graphic Study Group

Linaro.org =E2=94=82 Open source software for ARM SoCs

Follow Linaro: Facebook | Twitter | Blog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
