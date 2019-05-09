Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2381C04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 16:22:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 490FB2173C
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 16:22:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="EUI93GA4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 490FB2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C80E76B000A; Thu,  9 May 2019 12:22:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C314F6B000C; Thu,  9 May 2019 12:22:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B20EF6B000D; Thu,  9 May 2019 12:22:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7AD826B000A
	for <linux-mm@kvack.org>; Thu,  9 May 2019 12:22:16 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id n3so1946101pff.4
        for <linux-mm@kvack.org>; Thu, 09 May 2019 09:22:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:dkim-signature;
        bh=ySdKjZ9iDZbJHfdPC29dq/u2NCS/NhGwmS58wZMyvw8=;
        b=OJSJUkI/2p6jOdBcXdIWudBdbCTTCGJorDTys4Ug3yEQtzWI/NpGgk0w90SKKfWzFh
         +tVk+7nOMpJH0wcqdcs9q3o5nd6vOvu2qA+ygYcF0vO3NMiviLo9onVNKAhTPyc5JwXz
         CMY+jHrwwmQIo8QUpiOZAffMKyaT5VDGCqyH7rOTX2trC3qa4M9RPOUSzcu2FzOzMDmQ
         zWOxYAmgzfvrz9jEXClUkwbgC02DfgmLFk0aRDM6kT8ZIwAQrRM5HBGZ2n06xJhZLNSk
         Y/SRNUp0lp1rfKn7uDcLujizEMsBKcKFEAFfYXGz19eG6J/sPNua/cvMbWce1MJV9p3N
         5m9w==
X-Gm-Message-State: APjAAAXs3M4RIP5PhO4D6mfUkOiCetiungI8JvMTNnIECRXBygVTa1PD
	kGtPBa3gNzrLZflUV/ixFwz5/2YYBZCDqYr6MAbWcYLRU/GxI3MWkFeMqqb15wLDTpgQ6rsuNik
	peM3ki+Sy4YzjlTiexIhbsX+73n8OoiwuUafUFtopMyfXAfyH3Kvx3k3s/yRs+UqJhg==
X-Received: by 2002:a62:be13:: with SMTP id l19mr6586420pff.137.1557418936039;
        Thu, 09 May 2019 09:22:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwd25vuOu3KUY8/bweUQwXjzkgihX6LJE3QR+n4nMEyqt45UWnajfbZ+FjWuEhLzuZePUSX
X-Received: by 2002:a62:be13:: with SMTP id l19mr6586293pff.137.1557418935053;
        Thu, 09 May 2019 09:22:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557418935; cv=none;
        d=google.com; s=arc-20160816;
        b=X+WFuhjEU7qDegeZlsI0hwNMBwx8STGWY5Jph0KjlULDa3YdTYnfi1zgQK9sdRXCe1
         rH41cdT+1pHPUKLrLd2bW+3sq2KrCRNTWGMcCz7MZKuMwEtot2q6w9P32g2e3/auWt2k
         yaJcH/SibTTg+jYWKAvz/Dvfq/n5nBOxeJ5MSN5D7vJiYfXI78aKjsD1wzUbXAOft+g+
         4wcgNO9nOQVgfGCPpBYIPCJjy/lr24M5BvRvVBpGqFxq33oz8Tehkjk9ll4nNMmlpUr0
         Z53Ne5SzLQ+g5NRSgnBR17+gLnGe8KuT7v8eZSMga4lfTXte/PhYSQTc7sTeSa70Q3Zr
         lOvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from;
        bh=ySdKjZ9iDZbJHfdPC29dq/u2NCS/NhGwmS58wZMyvw8=;
        b=OQKvCQ0go0Pe8ZC6NzCPmrWUkaTTlO9WUAmk9XZLN6J2DReb4a0thmeYSnLnVXNFhb
         KmS4wUvGSB8kSdF3xiz6n8soHTFvEhTjo2UFpYtVTWnhRJAZZJ57c59dnj6EBYMTfz2z
         8BByTOW+rtNQGdiSXFa96oXSKKaPwXXTZsC0nRV9g4Nd7QCNkI73hLPBFHLUfD54/KUa
         bwo32bUiZBiINp3+VpyFEu20p7D/N00uVMsaJjKtsND5pE37q1dIkoGT238fjeUYFq9/
         W+ePzw9WI/VuBR5Iqd7o4DvXU+F14hML5NL5km5knIHsfBEnv5he3Jfe1OkUrDik2Lk/
         N35w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=EUI93GA4;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id d18si3644829pgi.335.2019.05.09.09.22.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 09:22:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of ziy@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=EUI93GA4;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cd453920000>; Thu, 09 May 2019 09:21:38 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 09 May 2019 09:22:14 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 09 May 2019 09:22:14 -0700
Received: from [10.2.173.119] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 9 May
 2019 16:22:13 +0000
From: Zi Yan <ziy@nvidia.com>
To: Keith Busch <keith.busch@intel.com>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, Andrew Morton
	<akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: migrate: remove unused mode argument
Date: Thu, 9 May 2019 09:22:12 -0700
X-Mailer: MailMate (1.12.4r5629)
Message-ID: <E467C4E8-5049-4A3A-A95C-5F921372DBE5@nvidia.com>
In-Reply-To: <20190508210301.8472-1-keith.busch@intel.com>
References: <20190508210301.8472-1-keith.busch@intel.com>
MIME-Version: 1.0
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: multipart/signed;
	boundary="=_MailMate_D55B932C-DC6B-48B0-9229-E44DA113B614_=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1557418898; bh=ySdKjZ9iDZbJHfdPC29dq/u2NCS/NhGwmS58wZMyvw8=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:X-Mailer:Message-ID:
	 In-Reply-To:References:MIME-Version:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type;
	b=EUI93GA4ttAr2n8YJz3lLugkYHenkt+B2kD2AFgwpaIE14wmjmfQz9se4bF17j6XP
	 rtmP1nATTgjnm/aFPEysdnbpxwZIKd0KrpX2XB5xcw9rPlUtZ1je9hqWxQpsB6ubme
	 GVzTpoMf2aQld2/F60OWJ8/LuYKr7jWLAgKxDvNzvDqy87mdBWR5Rq4ULl8uPjAKZz
	 JH5F77RhNmP2rBczNB2NfZxSXhiGl7Js/TyJlFEV85PSXuZDyUzNs5qzaiK6/BRPVS
	 9kpCny6NlgJ65KgH7u5+YrrHvFHKBIuNTq/QsSuj2HUeB65pb3J1Oh1Ub1+80wI6Gp
	 /Pp0/T8zeYDrg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--=_MailMate_D55B932C-DC6B-48B0-9229-E44DA113B614_=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On 8 May 2019, at 14:03, Keith Busch wrote:

> migrate_page_move_mapping() doesn't use the mode argument. Remove it
> and update callers accordingly.
>
> Signed-off-by: Keith Busch <keith.busch@intel.com>
> ---
>  fs/aio.c                | 2 +-
>  fs/f2fs/data.c          | 2 +-
>  fs/iomap.c              | 2 +-
>  fs/ubifs/file.c         | 2 +-
>  include/linux/migrate.h | 3 +--
>  mm/migrate.c            | 7 +++----
>  6 files changed, 8 insertions(+), 10 deletions(-)
>
> diff --git a/fs/aio.c b/fs/aio.c
> index 3490d1fa0e16..1a1568861b4e 100644
> --- a/fs/aio.c
> +++ b/fs/aio.c
> @@ -425,7 +425,7 @@ static int aio_migratepage(struct address_space *ma=
pping, struct page *new,
>  	BUG_ON(PageWriteback(old));
>  	get_page(new);
>
> -	rc =3D migrate_page_move_mapping(mapping, new, old, mode, 1);
> +	rc =3D migrate_page_move_mapping(mapping, new, old, 1);
>  	if (rc !=3D MIGRATEPAGE_SUCCESS) {
>  		put_page(new);
>  		goto out_unlock;
> diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
> index 9727944139f2..0eb7a8cd3138 100644
> --- a/fs/f2fs/data.c
> +++ b/fs/f2fs/data.c
> @@ -2801,7 +2801,7 @@ int f2fs_migrate_page(struct address_space *mappi=
ng,
>  	/* one extra reference was held for atomic_write page */
>  	extra_count =3D atomic_written ? 1 : 0;
>  	rc =3D migrate_page_move_mapping(mapping, newpage,
> -				page, mode, extra_count);
> +				page, extra_count);
>  	if (rc !=3D MIGRATEPAGE_SUCCESS) {
>  		if (atomic_written)
>  			mutex_unlock(&fi->inmem_lock);
> diff --git a/fs/iomap.c b/fs/iomap.c
> index abdd18e404f8..f26f4846a00b 100644
> --- a/fs/iomap.c
> +++ b/fs/iomap.c
> @@ -571,7 +571,7 @@ iomap_migrate_page(struct address_space *mapping, s=
truct page *newpage,
>  {
>  	int ret;
>
> -	ret =3D migrate_page_move_mapping(mapping, newpage, page, mode, 0);
> +	ret =3D migrate_page_move_mapping(mapping, newpage, page, 0);
>  	if (ret !=3D MIGRATEPAGE_SUCCESS)
>  		return ret;
>
> diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
> index 5d2ffb1a45fc..d906ebc24049 100644
> --- a/fs/ubifs/file.c
> +++ b/fs/ubifs/file.c
> @@ -1481,7 +1481,7 @@ static int ubifs_migrate_page(struct address_spac=
e *mapping,
>  {
>  	int rc;
>
> -	rc =3D migrate_page_move_mapping(mapping, newpage, page, mode, 0);
> +	rc =3D migrate_page_move_mapping(mapping, newpage, page, 0);
>  	if (rc !=3D MIGRATEPAGE_SUCCESS)
>  		return rc;
>
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index e13d9bf2f9a5..7f04754c7f2b 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -77,8 +77,7 @@ extern void migrate_page_copy(struct page *newpage, s=
truct page *page);
>  extern int migrate_huge_page_move_mapping(struct address_space *mappin=
g,
>  				  struct page *newpage, struct page *page);
>  extern int migrate_page_move_mapping(struct address_space *mapping,
> -		struct page *newpage, struct page *page, enum migrate_mode mode,
> -		int extra_count);
> +		struct page *newpage, struct page *page, int extra_count);
>  #else
>
>  static inline void putback_movable_pages(struct list_head *l) {}
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 663a5449367a..85f46bfcf141 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -397,8 +397,7 @@ static int expected_page_refs(struct address_space =
*mapping, struct page *page)
>   * 3 for pages with a mapping and PagePrivate/PagePrivate2 set.
>   */
>  int migrate_page_move_mapping(struct address_space *mapping,
> -		struct page *newpage, struct page *page, enum migrate_mode mode,
> -		int extra_count)
> +		struct page *newpage, struct page *page, int extra_count)
>  {
>  	XA_STATE(xas, &mapping->i_pages, page_index(page));
>  	struct zone *oldzone, *newzone;
> @@ -684,7 +683,7 @@ int migrate_page(struct address_space *mapping,
>
>  	BUG_ON(PageWriteback(page));	/* Writeback must be complete */
>
> -	rc =3D migrate_page_move_mapping(mapping, newpage, page, mode, 0);
> +	rc =3D migrate_page_move_mapping(mapping, newpage, page, 0);
>
>  	if (rc !=3D MIGRATEPAGE_SUCCESS)
>  		return rc;
> @@ -783,7 +782,7 @@ static int __buffer_migrate_page(struct address_spa=
ce *mapping,
>  		}
>  	}
>
> -	rc =3D migrate_page_move_mapping(mapping, newpage, page, mode, 0);
> +	rc =3D migrate_page_move_mapping(mapping, newpage, page, 0);
>  	if (rc !=3D MIGRATEPAGE_SUCCESS)
>  		goto unlock_buffers;
>
> -- =

> 2.14.4

LGTM. Thanks. Reviewed-by: Zi Yan <ziy@nvidia.com>

--
Best Regards,
Yan Zi

--=_MailMate_D55B932C-DC6B-48B0-9229-E44DA113B614_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQJDBAEBAgAtFiEEh7yFAW3gwjwQ4C9anbJR82th+ooFAlzUU7QPHHppeUBudmlk
aWEuY29tAAoJEJ2yUfNrYfqKnUkQAK9rbLf2cOrj9h93jrKYpeYgZqnKGGcQyykq
+UA0H9ZxEjiDtHTVUD3FrV8x3Ob3lIA3JgDdFfrBN/B2NaeVKEfld+wWjJD5f2rI
+c0H+CF0KO4y2LLw271nnRy9FqAMMeQZyyIoyQwlbTSZZNedX02tslPWE+2bG2rv
9SHDXneZTqy7J+IpqwJxHJ852TceZxzdq4OasH9yGvhw7/WsMUd6DIGaDmmxvZe/
1F4udER7OU7n5fBIlz3kJlmQst8LbtIqtRc+h3O14xxmNmO+lYFMYTDsJNPVwoOJ
1IwjzC6Pqg1Z0vCPdoMiSis1YmdVca84bIhyN8OvKp57nvw5JsFSwhuWL7X9m3J5
YYqG4z2+9RKzvatfAcpAqwt54Em+SEZBdOL73K6yErZQ+1mnt84lxkcWjSoErNjG
/7BCpCqGC4iUe6t17vQyQCYYDTFT7BTB/vI4Rr5GMJJ6VzCLW1iFfty0H9LrHeoe
MO3fUJTaF3N40X16HqE3sjn4Uyzx/lO/LSqEhLqtS6+2jH/Ug70Hc7153MnLVrz0
vZ3iK7GdrEgN3TNO+cL6N1HleQnRiSZXGKx4TZmyQphtI+susUgcgHIO8rR6eAqO
57K0vx7x5OuPgvuMvlVSdM9WDI89UciKytujSWMZeDA74yTifCc8cC+HRYN+Y0sm
9AlPC9+M
=Yv8g
-----END PGP SIGNATURE-----

--=_MailMate_D55B932C-DC6B-48B0-9229-E44DA113B614_=--

