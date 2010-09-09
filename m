Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6D2716B004A
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 20:50:01 -0400 (EDT)
Received: by vws16 with SMTP id 16so926334vws.14
        for <linux-mm@kvack.org>; Wed, 08 Sep 2010 17:49:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1283892334-9238-1-git-send-email-gking@nvidia.com>
References: <1283892334-9238-1-git-send-email-gking@nvidia.com>
Date: Thu, 9 Sep 2010 08:49:59 +0800
Message-ID: <AANLkTi=GiU+N-1a00qxSFpDL8tz0_W3dpc32VXZBs9yZ@mail.gmail.com>
Subject: Re: [PATCH] bounce: call flush_dcache_page after bounce_copy_vec
From: Bryan Wu <bryan.wu@canonical.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Gary King <gking@nvidia.com>
Cc: linux-mm@kvack.org, tj@kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, "Jan, Sebastien" <s-jan@ti.com>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 8, 2010 at 4:45 AM, Gary King <gking@nvidia.com> wrote:
> I have been seeing problems on Tegra 2 (ARMv7 SMP) systems with HIGHMEM
> enabled on 2.6.35 (plus some patches targetted at 2.6.36 to perform
> cache maintenance lazily), and the root cause appears to be that the
> mm bouncing code is calling flush_dcache_page before it copies the
> bounce buffer into the bio.
>
> The patch below reorders these two operations, and eliminates numerous
> arbitrary application crashes on my dev system.
>

We also experience the package building failure on OMAP4 SMP system
with HIGHMEM enabled
on 2.6.35. Thanks a lot for this fixing, we will try it later soon.

-Bryan

> Gary
>
> --
> From 678c9bca8d8a8f254f28af91e69fad3aa1be7593 Mon Sep 17 00:00:00 2001
> From: Gary King <gking@nvidia.com>
> Date: Mon, 6 Sep 2010 15:37:12 -0700
> Subject: bounce: call flush_dcache_page after bounce_copy_vec
>
> the bounced page needs to be flushed after data is copied into it,
> to ensure that architecture implementations can synchronize
> instruction and data caches if necessary.
>
> Signed-off-by: Gary King <gking@nvidia.com>
> ---
> =A0mm/bounce.c | =A0 =A02 +-
> =A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/mm/bounce.c b/mm/bounce.c
> index 13b6dad..1481de6 100644
> --- a/mm/bounce.c
> +++ b/mm/bounce.c
> @@ -116,8 +116,8 @@ static void copy_to_high_bio_irq(struct bio *to, stru=
ct bio *from)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0vfrom =3D page_address(fromvec->bv_page) +=
 tovec->bv_offset;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 flush_dcache_page(tovec->bv_page);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bounce_copy_vec(tovec, vfrom);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 flush_dcache_page(tovec->bv_page);
> =A0 =A0 =A0 =A0}
> =A0}
>
> --
> 1.7.0.4
>
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
