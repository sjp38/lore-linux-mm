Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 5449E6B00EE
	for <linux-mm@kvack.org>; Mon,  5 Sep 2011 14:22:02 -0400 (EDT)
Received: by wwj26 with SMTP id 26so157794wwj.2
        for <linux-mm@kvack.org>; Mon, 05 Sep 2011 11:21:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1314971786-15140-3-git-send-email-m.szyprowski@samsung.com>
References: <1314971786-15140-1-git-send-email-m.szyprowski@samsung.com> <1314971786-15140-3-git-send-email-m.szyprowski@samsung.com>
From: Ohad Ben-Cohen <ohad@wizery.com>
Date: Mon, 5 Sep 2011 21:21:39 +0300
Message-ID: <CADMYwHyeP-1Rd1GxJx-z7XjrThK_H_bPB-_FZMb-_Y1VGeA4Dg@mail.gmail.com>
Subject: Re: [PATCH 2/2] ARM: Samsung: update/rewrite Samsung SYSMMU (IOMMU) driver
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Shariq Hasnain <shariq.hasnain@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Kyungmin Park <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>

Hi Marek,

On Fri, Sep 2, 2011 at 4:56 PM, Marek Szyprowski
<m.szyprowski@samsung.com> wrote:
...
> =A0arch/arm/plat-s5p/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0|=
 =A0 21 +-
> =A0arch/arm/plat-s5p/include/plat/sysmmu.h =A0 =A0 =A0 =A0| =A0119 ++--
> =A0arch/arm/plat-s5p/sysmmu.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =
=A0855 ++++++++++++++++++------

Please move the driver to drivers/iommu/, where all other IOMMU API users s=
it.

...
> diff --git a/arch/arm/plat-s5p/Kconfig b/arch/arm/plat-s5p/Kconfig
...
> +config IOMMU_API
> + =A0 =A0 =A0 bool

You don't need this anymore: this is already part of drivers/iommu/Kconfig.

> +static int s5p_sysmmu_unmap(struct iommu_domain *domain, unsigned long i=
ova,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int gfp_order)
> =A0{
...
> + =A0 =A0 =A0 if (SZ_1M =3D=3D len) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!page_1m(flpt_va))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bug_unmapping_prohibited(io=
va, len);
..
> + =A0 =A0 =A0 } else if (SZ_16M =3D=3D len) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int i;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* first loop to verify it actually is 16M =
mapping */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D 0; i < 16; ++i)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!page_16m(flpt_va + 4 *=
 i))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bug_unmappi=
ng_prohibited(iova, len);

Actually these are not bugs; iommu drivers need to unmap the page they
find in iova, and return the page size that was actually unmapped: you
may well receive a page size that is different from the page that maps
iova.

...
> +
> + =A0 =A0 =A0 return 0;

On success, need to return the size (in page order) of the page that
was unmapped.

Regards,
Ohad.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
