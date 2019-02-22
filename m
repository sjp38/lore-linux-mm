Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B972C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 19:04:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B0A19206BB
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 19:04:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="m7owq4vS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0A19206BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 673FA8E0133; Fri, 22 Feb 2019 14:04:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 621C68E0123; Fri, 22 Feb 2019 14:04:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 512558E0133; Fri, 22 Feb 2019 14:04:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1E5F78E0123
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 14:04:07 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id x64so1946407ywc.6
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 11:04:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=IFpaaIptLrwQE87JJJzJIYC6OGivJZKshlLacnhoUH0=;
        b=rEeFWFFpLYidMfonARDcc4O0aEOwFNn1u+hE9vKj7c7JnY6vwyG3UuP5/oNE6uvChI
         /gnakhI220UpzDTnpqpBpFi30g2SnK4PtjnWvka45g+EQsyYnlkSeYaDsFkVcmoWGIHU
         wML1xdeClL+z7JCW29FNv9WAN4y6e+5khN9UEa6O1E4Deb+RqZYt6T7GDnlM9gQ/7CFK
         DoHJTysaS/aFE2hOjG+cAr3wWNFTft0lPmz0x6niCwWYZPFj0KYlz/J4yNxfr6EaO7jn
         eCmGuH11OqpicplGLa/nKbdBe6Tx3ELTB9Q45ROA39NcprAVeJDs/qxzrKEmy1FeY9+A
         HUkQ==
X-Gm-Message-State: AHQUAuZ0OkuW3NdO0MPX8zU0GKAtdNp7ZBogme7+yZbOIz542u4o5Krv
	lKcFgNylaOdFJ5uazmThhxBW0xdyS4Kea9Rt+jX7z6voHLdeec+aLVqTDzGqU6rxmYzYH36wryA
	owfEUiEgjItWbJEhKypNQckOZJDmyIEw24ZFJJVZ/Uzc0cHJtFja1YrNrCs4652q/jA==
X-Received: by 2002:a25:57d6:: with SMTP id l205mr4727711ybb.227.1550862246860;
        Fri, 22 Feb 2019 11:04:06 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY9H+9ChmcZx63D/tAhwLy+6T0j0MgvuJ0ePqS0hl1Fz1uQ3Su4SEpC9iyPitsX+3DetvmI
X-Received: by 2002:a25:57d6:: with SMTP id l205mr4727644ybb.227.1550862246009;
        Fri, 22 Feb 2019 11:04:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550862246; cv=none;
        d=google.com; s=arc-20160816;
        b=F7tKReHvyaZSQQBIOtgYNrIlexAJljt9QvPxktLIKAV0Hv0rAQcC8X8g77teW4ZhXn
         Ez5ivwOIEu0JrD5RxoTlysY+A04Zmp134C8doAKsrFmdE7yNq1II6BuNrJ9LlRWqwywY
         jrPGJI6DVhROP7eFzJlxItfdwWs4OEe0ZURmIOIzFGzP5iOCN62rAaTqBDG7bE3jvqjk
         DQdnFcm/2G8vmG5dcam0oRW6yzVwPUpxvoswuURAQCoV1p8We/G022wnJtdG4/2dBF7F
         qpGbRxBQZrrUnU1Zm6Kwaxbq8RZOx6vzMnKlMDCSE3JcAO9ABXvpBVCTbaIpO7UF9Lki
         MDSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=IFpaaIptLrwQE87JJJzJIYC6OGivJZKshlLacnhoUH0=;
        b=byOmS+bo3xMRtpVTnLzFtWUG3LrndAEGdVT3i9Jkzsi8QwPQ6gJTcwfDNtgLxDY+Rk
         8/bOYCULmFyBz0Zb+0Or9G8qoMEOsNaFb+5ykDpcOofvL2B6vGwy6ETd4mfQvfrt/gdx
         ES2sgbJgJgP5104/YRP9lmBj5I5x5AIaLZUJrS9uwtw16hKpdHpxbs4hbBOF/MY9ABJg
         5VQ1+14DM3Qj6CqQmLvI3BgIR0kd01EfYyh2miV2IKJlnZfaBzcojXtzI0JPPt5SqILK
         XuyB0H8b1jAuWc013vLicwLcj2Q6/8p7Ap4HNyVAvZLzOiHqM93UJZPDwONaXv82Hnw+
         Jn3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=m7owq4vS;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id j126si1310281ywb.404.2019.02.22.11.04.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 11:04:05 -0800 (PST)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=m7owq4vS;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c7047aa0000>; Fri, 22 Feb 2019 11:04:11 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 22 Feb 2019 11:04:05 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 22 Feb 2019 11:04:05 -0800
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Fri, 22 Feb
 2019 19:04:04 +0000
Subject: Re: [PATCH v5 3/9] mm/mmu_notifier: convert
 mmu_notifier_range->blockable to a flags
To: <jglisse@redhat.com>, <linux-mm@kvack.org>, Andrew Morton
	<akpm@linux-foundation.org>
CC: <linux-kernel@vger.kernel.org>, =?UTF-8?Q?Christian_K=c3=b6nig?=
	<christian.koenig@amd.com>, Joonas Lahtinen
	<joonas.lahtinen@linux.intel.com>, Jani Nikula <jani.nikula@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>, Jan Kara <jack@suse.cz>, Andrea
 Arcangeli <aarcange@redhat.com>, Peter Xu <peterx@redhat.com>, Felix Kuehling
	<Felix.Kuehling@amd.com>, Jason Gunthorpe <jgg@mellanox.com>, Ross Zwisler
	<zwisler@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Paolo Bonzini
	<pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>, John Hubbard <jhubbard@nvidia.com>,
	<kvm@vger.kernel.org>, <dri-devel@lists.freedesktop.org>,
	<linux-rdma@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>
References: <20190219200430.11130-1-jglisse@redhat.com>
 <20190219200430.11130-4-jglisse@redhat.com>
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <ee8c7218-76d4-437b-91d4-66c07f3700d5@nvidia.com>
Date: Fri, 22 Feb 2019 11:04:04 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.0
MIME-Version: 1.0
In-Reply-To: <20190219200430.11130-4-jglisse@redhat.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1550862251; bh=IFpaaIptLrwQE87JJJzJIYC6OGivJZKshlLacnhoUH0=;
	h=X-PGP-Universal:Subject:To:CC:References:From:Message-ID:Date:
	 User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=m7owq4vS//y5MpqMTiKuT6s5znD26AjJqrf0Rv/92Dcg3Ymg5WDaEgE2Yg2S/8jGS
	 frqhi2qWqvcWIflCXCpUTQl2pUUleboeVZ54BQRNQff/ptGzMB59v1o1mxcDLOPjS/
	 lfxfL7JTJQNDd34SPJOHhYSTc6QfJ9nRyD9I2JGJ/pSnISg2VxG1TjZ4azUTERYsBX
	 aSkLuendkmUUNBqVHvLhqoaLHXs9rzjrxIlRlLguIvbwG78XtpgjXvxa6QbEdfWbXh
	 L2eya6zWp7HS71dmdU9oAN0ac+Og7tEbq32y5w58CWiA8hpx5ouuUpFR5gpkIrH/Ni
	 hNcbp/rT/IwFw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2/19/19 12:04 PM, jglisse@redhat.com wrote:
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>=20
> Use an unsigned field for flags other than blockable and convert
> the blockable field to be one of those flags.
>=20
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Christian K=C3=B6nig <christian.koenig@amd.com>
> Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
> Cc: Jani Nikula <jani.nikula@linux.intel.com>
> Cc: Rodrigo Vivi <rodrigo.vivi@intel.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Peter Xu <peterx@redhat.com>
> Cc: Felix Kuehling <Felix.Kuehling@amd.com>
> Cc: Jason Gunthorpe <jgg@mellanox.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Ross Zwisler <zwisler@kernel.org>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Cc: Radim Kr=C4=8Dm=C3=A1=C5=99 <rkrcmar@redhat.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Christian Koenig <christian.koenig@amd.com>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: kvm@vger.kernel.org
> Cc: dri-devel@lists.freedesktop.org
> Cc: linux-rdma@vger.kernel.org
> Cc: Arnd Bergmann <arnd@arndb.de>
> ---
>   include/linux/mmu_notifier.h | 11 +++++++----
>   1 file changed, 7 insertions(+), 4 deletions(-)
>=20
> diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
> index e630def131ce..c8672c366f67 100644
> --- a/include/linux/mmu_notifier.h
> +++ b/include/linux/mmu_notifier.h
> @@ -25,11 +25,13 @@ struct mmu_notifier_mm {
>   	spinlock_t lock;
>   };
>  =20
> +#define MMU_NOTIFIER_RANGE_BLOCKABLE (1 << 0)
> +
>   struct mmu_notifier_range {
>   	struct mm_struct *mm;
>   	unsigned long start;
>   	unsigned long end;
> -	bool blockable;
> +	unsigned flags;
>   };
>  =20
>   struct mmu_notifier_ops {
> @@ -229,7 +231,7 @@ extern void __mmu_notifier_invalidate_range(struct mm=
_struct *mm,
>   static inline bool
>   mmu_notifier_range_blockable(const struct mmu_notifier_range *range)
>   {
> -	return range->blockable;
> +	return (range->flags & MMU_NOTIFIER_RANGE_BLOCKABLE);
>   }
>  =20
>   static inline void mmu_notifier_release(struct mm_struct *mm)
> @@ -275,7 +277,7 @@ static inline void
>   mmu_notifier_invalidate_range_start(struct mmu_notifier_range *range)
>   {
>   	if (mm_has_notifiers(range->mm)) {
> -		range->blockable =3D true;
> +		range->flags |=3D MMU_NOTIFIER_RANGE_BLOCKABLE;
>   		__mmu_notifier_invalidate_range_start(range);
>   	}
>   }
> @@ -284,7 +286,7 @@ static inline int
>   mmu_notifier_invalidate_range_start_nonblock(struct mmu_notifier_range =
*range)
>   {
>   	if (mm_has_notifiers(range->mm)) {
> -		range->blockable =3D false;
> +		range->flags &=3D ~MMU_NOTIFIER_RANGE_BLOCKABLE;
>   		return __mmu_notifier_invalidate_range_start(range);
>   	}
>   	return 0;
> @@ -331,6 +333,7 @@ static inline void mmu_notifier_range_init(struct mmu=
_notifier_range *range,
>   	range->mm =3D mm;
>   	range->start =3D start;
>   	range->end =3D end;
> +	range->flags =3D 0;
>   }
>  =20
>   #define ptep_clear_flush_young_notify(__vma, __address, __ptep)		\
>=20

Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

