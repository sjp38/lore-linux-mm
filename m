Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F063C76191
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 02:25:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 132C8218B8
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 02:25:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="JHghyeeN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 132C8218B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 83EFD6B0003; Sun, 21 Jul 2019 22:25:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F0496B0006; Sun, 21 Jul 2019 22:25:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 705C28E0001; Sun, 21 Jul 2019 22:25:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 515F46B0003
	for <linux-mm@kvack.org>; Sun, 21 Jul 2019 22:25:35 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id f1so29789770ybq.3
        for <linux-mm@kvack.org>; Sun, 21 Jul 2019 19:25:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=R+oEYBF12a6qSQ/9qA6zFvvWBnLycevyTeAHjJjA370=;
        b=bSAZ3rWhifdEhRYC50dpwCaluhKH4s2dfq6HTK9Y8aH2WcAEF+wE+mT2F5yNFbWiWr
         VmkYymzjB56slX8xzmovfZzwqmWrMAzkthcmsy1TdRXn1eVz2f1o+BN4/5UKajKkmHm2
         2nkWS/wA2Ps95lzo0nP7+NjSk4ETb08ig+5rLTgXRhjOwxTzGFzgV7MG7YvKFJttjU8G
         6S+ryaCrEKVo4pYEsLCXCajA/tdofmSJZix/X5rwPvZMAD8MQhFwZT13qtXBC6pSTaDB
         BA9f3/tTdz0NwigjQ9DfdLiegO0bMtlMhKdRoIPY/ob/a5jjz1JuvJHQJwNhqXdopgWJ
         zmFg==
X-Gm-Message-State: APjAAAWnz86UP2IcTzKORSsOOMBaLrbQ75VAh5mEPGXlmYx8JlFzZ7Rx
	URhdUlOlem5AU6yKimEPK4HaHex7SqcQAdFI1eEWSNnmYYNDt4yQ2Vn0ZTQauc17SPRUOrnCvKY
	rgw4sv9WeY+M0VTo74eFKdpe9UiBhgG8/uRSTSZ12z6abedLDo5mNOBw398UiMRZZpQ==
X-Received: by 2002:a81:f00d:: with SMTP id p13mr38312389ywm.255.1563762334948;
        Sun, 21 Jul 2019 19:25:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwQpDY6NFFfC1IqaF6OtnoJL9DWTlXYdCar3bylDqLahJbHNJ8y5LOQrguUgvitoVoUHaGe
X-Received: by 2002:a81:f00d:: with SMTP id p13mr38312370ywm.255.1563762333794;
        Sun, 21 Jul 2019 19:25:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563762333; cv=none;
        d=google.com; s=arc-20160816;
        b=Iz9lqs/nXBDqpxDoIfosommb6HGZOvlUBT+dpHla2QiL9dugESwHisAxYdYNp12zkk
         oWjxVFORiD4eSSSGlfFb5AkZYZIlsqdozHaOiWtcd5KpoHbd7HeBScFc/lSFMzXemGca
         hHZceoVN7odqgrBbx4I+TjAEseH93xQ0KKpnuvc/lhmyMJXzeTMkghZgR0mDsyzASX9M
         uspCm7U8hD5gcWm5l84GdlUyYeYLs30iOiMicM2VNyWsBlc0tQF4wPjiCxCK8WdZ7yos
         6SFL3DIXxUdK22s7SuqKvsfwOSVZr3yd0DlLL0npkgWjGd/MzlQINhFrD2uL3Rj5JhNa
         1z7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=R+oEYBF12a6qSQ/9qA6zFvvWBnLycevyTeAHjJjA370=;
        b=syKZfDiR5UZrB1ZbgDEWfJOTEGi26bWUA7Zava/3yYAZl/BLYuuIENR8pHMhkJvf+P
         hgG5xYvzPmWH7G4a3H5uYoNP/OUSLDCV8Blvq7NeVeBfXKQiG8TBgPIbJ44Ya2Xt6c+x
         rQCscdvmctRUZABozVyveiasn66LULPwCMmD/XueTciD9GjtAKdIFGjTjpvSXXe88pM0
         T5pmD82NW9rnXvv6sTR0S2nPFIQZiID3x13iWdNEpyN7XHAoP079TCIKl++fZH37PFgc
         DCssqBBQy080v2ky5oOHNlAKp1G9XKlD25xUL6KOmOtXTzMsjfeLCSVp24RmuGi6b5zI
         VlkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=JHghyeeN;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id d81si13256005ybb.46.2019.07.21.19.25.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Jul 2019 19:25:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=JHghyeeN;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d351e9a0000>; Sun, 21 Jul 2019 19:25:30 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Sun, 21 Jul 2019 19:25:32 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Sun, 21 Jul 2019 19:25:32 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 22 Jul
 2019 02:25:32 +0000
Subject: Re: [PATCH 1/3] sgi-gru: Convert put_page() to get_user_page*()
To: Bharath Vedartham <linux.bhar@gmail.com>, <arnd@arndb.de>,
	<sivanich@sgi.com>, <gregkh@linuxfoundation.org>
CC: <ira.weiny@intel.com>, <jglisse@redhat.com>,
	<linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
References: <1563724685-6540-1-git-send-email-linux.bhar@gmail.com>
 <1563724685-6540-2-git-send-email-linux.bhar@gmail.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <dae42533-7e71-0e41-54a2-58c459761b3e@nvidia.com>
Date: Sun, 21 Jul 2019 19:25:31 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <1563724685-6540-2-git-send-email-linux.bhar@gmail.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563762330; bh=R+oEYBF12a6qSQ/9qA6zFvvWBnLycevyTeAHjJjA370=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=JHghyeeNy7gglOmX4/lc88T4YXMiAPg22iQHB0njPY7a7oWFps2m5biGSz5kP6cCF
	 Ufqr2MonNAXr6SGE028w8ITLYllg7Er5pY+TgaxitwJPzOgyqrKAbLZXBImYS2wvpc
	 3ZyZNjzU2/Io9qo1MXpKAwJQ6f5dDhmGnATrMrtWcItBZZcr549FB3juPENbqzw6YR
	 dz/gpLTZyf+Uq8QsyKJ4TOxWf8Tp/l8PoBuzAG6T8ABkteNXIawlPDjANTjYqvPpOG
	 +W/U33sGNuNk6F05nmXlv8k6Iwm1GeTEuI+xy3J2DhU+jckRN/Cn5VKbH9PALK8RbH
	 qdFlvyFC1E35A==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/21/19 8:58 AM, Bharath Vedartham wrote:
> For pages that were retained via get_user_pages*(), release those pages
> via the new put_user_page*() routines, instead of via put_page().
>=20
> This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
> ("mm: introduce put_user_page*(), placeholder versions").
>=20
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Dimitri Sivanich <sivanich@sgi.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
> ---
>  drivers/misc/sgi-gru/grufault.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20

Reviewed-by: John Hubbard <jhubbard@nvidia.com>

thanks,
--=20
John Hubbard
NVIDIA

> diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/grufa=
ult.c
> index 4b713a8..61b3447 100644
> --- a/drivers/misc/sgi-gru/grufault.c
> +++ b/drivers/misc/sgi-gru/grufault.c
> @@ -188,7 +188,7 @@ static int non_atomic_pte_lookup(struct vm_area_struc=
t *vma,
>  	if (get_user_pages(vaddr, 1, write ? FOLL_WRITE : 0, &page, NULL) <=3D =
0)
>  		return -EFAULT;
>  	*paddr =3D page_to_phys(page);
> -	put_page(page);
> +	put_user_page(page);
>  	return 0;
>  }
> =20
>=20

