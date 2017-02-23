Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 49E1F6B0038
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 01:55:52 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id v63so37089348pgv.0
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 22:55:52 -0800 (PST)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id g10si3471137pln.268.2017.02.22.22.55.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Feb 2017 22:55:51 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC PATCH 04/14] mm/migrate: Add new migrate mode MIGRATE_MT
Date: Thu, 23 Feb 2017 06:54:30 +0000
Message-ID: <20170223065429.GB7336@hori1.linux.bs1.fc.nec.co.jp>
References: <20170217150551.117028-1-zi.yan@sent.com>
 <20170217150551.117028-5-zi.yan@sent.com>
In-Reply-To: <20170217150551.117028-5-zi.yan@sent.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <7C32D14FD977964591A41B43B9497B5A@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "dnellans@nvidia.com" <dnellans@nvidia.com>, "apopple@au1.ibm.com" <apopple@au1.ibm.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>, "zi.yan@cs.rutgers.edu" <zi.yan@cs.rutgers.edu>

On Fri, Feb 17, 2017 at 10:05:41AM -0500, Zi Yan wrote:
> From: Zi Yan <ziy@nvidia.com>
>=20
> This change adds a new migration mode called MIGRATE_MT to enable multi
> threaded page copy implementation inside copy_huge_page() function by
> selectively calling copy_pages_mthread() when requested. But it still
> falls back using the regular page copy mechanism instead the previous
> multi threaded attempt fails. It also attempts multi threaded copy for
> regular pages.
>=20
> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> ---
>  include/linux/migrate_mode.h |  1 +
>  mm/migrate.c                 | 25 ++++++++++++++++++-------
>  2 files changed, 19 insertions(+), 7 deletions(-)
>=20
> diff --git a/include/linux/migrate_mode.h b/include/linux/migrate_mode.h
> index 89c170060e5b..d344ad60f499 100644
> --- a/include/linux/migrate_mode.h
> +++ b/include/linux/migrate_mode.h
> @@ -12,6 +12,7 @@ enum migrate_mode {
>  	MIGRATE_SYNC_LIGHT	=3D 1<<1,
>  	MIGRATE_SYNC		=3D 1<<2,
>  	MIGRATE_ST		=3D 1<<3,
> +	MIGRATE_MT		=3D 1<<4,

Could you update the comment above this definition to cover the new flags.

Thanks,
Naoya Horiguchi

>  };
> =20
>  #endif		/* MIGRATE_MODE_H_INCLUDED */
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 87253cb9b50a..21307219428d 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -601,6 +601,7 @@ static void copy_huge_page(struct page *dst, struct p=
age *src,
>  {
>  	int i;
>  	int nr_pages;
> +	int rc =3D -EFAULT;
> =20
>  	if (PageHuge(src)) {
>  		/* hugetlbfs page */
> @@ -617,10 +618,14 @@ static void copy_huge_page(struct page *dst, struct=
 page *src,
>  		nr_pages =3D hpage_nr_pages(src);
>  	}
> =20
> -	for (i =3D 0; i < nr_pages; i++) {
> -		cond_resched();
> -		copy_highpage(dst + i, src + i);
> -	}
> +	if (mode & MIGRATE_MT)
> +		rc =3D copy_pages_mthread(dst, src, nr_pages);
> +
> +	if (rc)
> +		for (i =3D 0; i < nr_pages; i++) {
> +			cond_resched();
> +			copy_highpage(dst + i, src + i);
> +		}
>  }
> =20
>  /*
> @@ -631,10 +636,16 @@ void migrate_page_copy(struct page *newpage, struct=
 page *page,
>  {
>  	int cpupid;
> =20
> -	if (PageHuge(page) || PageTransHuge(page))
> +	if (PageHuge(page) || PageTransHuge(page)) {
>  		copy_huge_page(newpage, page, mode);
> -	else
> -		copy_highpage(newpage, page);
> +	} else {
> +		if (mode & MIGRATE_MT) {
> +			if (copy_pages_mthread(newpage, page, 1))
> +				copy_highpage(newpage, page);
> +		} else {
> +			copy_highpage(newpage, page);
> +		}
> +	}
> =20
>  	if (PageError(page))
>  		SetPageError(newpage);
> --=20
> 2.11.0
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
