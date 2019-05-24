Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06287C282E1
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 01:05:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AEA7B217D9
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 01:05:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="Gj9MdXQb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AEA7B217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 37C306B0007; Thu, 23 May 2019 21:05:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3057B6B0008; Thu, 23 May 2019 21:05:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A5916B000A; Thu, 23 May 2019 21:05:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id E9AB26B0007
	for <linux-mm@kvack.org>; Thu, 23 May 2019 21:05:06 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id j72so2825756ywa.5
        for <linux-mm@kvack.org>; Thu, 23 May 2019 18:05:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=SN+7sL6HemPw2Et2gfO0Vw1ZlZItZYzsD2goYpEBJkQ=;
        b=JfWMR1/O3Mp6nObFHqZVxY3bWlZEqw1Y+IYJwo2QcX0QUtp1G5o7eifkS78lEK3+tK
         H5Kn1LZhYmqOvOkA0Z7OOcfygq2wkhVjGdCL86hcfY/HEXdJcjJaFuqx/3sYRix12QPM
         GmyiMOQoxOpPIsvg6BdGeJ+1LHxAg0B/I7HrzMa09yGSlpV6Lk9aMiRnUllCRGgxij7S
         gdJ1JPF7glJdfDPnKkLmAVi+4eRR2bMhCPrhrlN9f1Ileox5UEZTW1k/l3riLG9dWmfW
         c+cPXzovGxkG7Ru9schZGyD7TYLyYhVwitYdswphDAR/WJ/36MMYIJDA9q5X3TEZmXkG
         9Vpw==
X-Gm-Message-State: APjAAAX0cumGT/wT0ON7RnvQs2ufbWZULRNxVki5qfmUGREM9AojCcv/
	e9RAksdsIuA+hqCxBmcUCgSo+b4lVVb+AqVwGepDLty+kCCyt2lnGv9OwmwtSRudCgbgUsHCtq+
	N53uCW59L0ILN4On1kBtWQQ1EkugpBTjreAYbtX9ddWWrtX4pAxMw2oek0a76y1/6Mw==
X-Received: by 2002:a25:4557:: with SMTP id s84mr22164245yba.504.1558659906645;
        Thu, 23 May 2019 18:05:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw7tOEcyKpqWW4HVOb5hZSE6ufrIhAjIXOQQfiuOwO7HiMZDaK1BL8NeGQSBfNCdWygJ/Mh
X-Received: by 2002:a25:4557:: with SMTP id s84mr22164215yba.504.1558659905947;
        Thu, 23 May 2019 18:05:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558659905; cv=none;
        d=google.com; s=arc-20160816;
        b=kxgUkR8RFDaL9i0llIZEKOs+spIOXGU/rKzrhFrYPLtce4L+wDwrALB31kgTUvKNn+
         PhONg/TkGLy5wzfIgljiixeBjw7WmLrcJuSjYGp6/MADgdwGA6CZ/scByD+mEyY6xoTc
         alFEwQbtSzrwbrgQ0Ci65t92kp0OkSAQe55yzo9EPjCl+Kv8N6x06Ua25DD8eVZkESEl
         8V/FkG/wpjl6ywNq8pbg0+S9KPb9Z2aCBmA4y8cdHo8tQQreFRN059Weag7qY6Sn5Jau
         0h/Qefz20s4q38KQ5WCLVnPRj8f3A98o6c7yHXSBARwYJiTFEVmxPLetkfKRivX7U4x3
         9ZOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=SN+7sL6HemPw2Et2gfO0Vw1ZlZItZYzsD2goYpEBJkQ=;
        b=l3NcBaC0rp8N21mvD2Uqe/vr6lpv1AawHKqKBRAt0SsSeWIKMBC6Du6NHkD3QWLzgI
         lclCzwwcyEmuYWImzPDOkZtCk+aQfrPjLXY/XaquhZtncch392zXqm+58RJ6Cp3nn9z2
         tzZOuuqrRNThJi5qXjx54V6bxxgozdKFS/1T7+AFZzBxJfL69GKZ7zpBXfegcGx+dnxZ
         dpB5FBJwiTqvN+H4TU08GNzqcA9rxWKzMeuSL21mNCHfbrARDwEBma1hG5Hxh2OE7BHG
         5WV2sC0HJx75+XEkSl1/5+ZDBUJXyuPRhDvYnOnG6UPGHsiOrpUCIPmEDkWhMYjhhTyu
         sscQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Gj9MdXQb;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id z2si313920ybn.84.2019.05.23.18.05.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 18:05:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Gj9MdXQb;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5ce743400000>; Thu, 23 May 2019 18:05:05 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 23 May 2019 18:05:04 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 23 May 2019 18:05:04 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 24 May
 2019 01:05:04 +0000
Subject: Re: [PATCH] mm/swap: Fix release_pages() when releasing devmap pages
To: <ira.weiny@intel.com>, Andrew Morton <akpm@linux-foundation.org>
CC: Michal Hocko <mhocko@suse.com>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, Dan Williams <dan.j.williams@intel.com>
References: <20190523223746.4982-1-ira.weiny@intel.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <2ac0f1cd-f076-a007-8152-c136efe60694@nvidia.com>
Date: Thu, 23 May 2019 18:05:04 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190523223746.4982-1-ira.weiny@intel.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1558659905; bh=SN+7sL6HemPw2Et2gfO0Vw1ZlZItZYzsD2goYpEBJkQ=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=Gj9MdXQbZ92cf7d41CUN+4e4JgAd2OYEpYqtn9+DSHMZIHT2a89BP7cO7AJbww848
	 Gx1ff+u3rLKJ+u2iuzhZo6i71uD/IpTovz3DtAXHHXGr5eduHw0WOWHSymxu1I9sSC
	 2sK7fUvvh1ARhTRpzYNLkhJBtbkyy+iakzhdSuSPhpkaUihk6GETp+YO4afjypqm0n
	 JmzQvP/2isAa/oslMGAt+I4mOz9884vn+diqq8S8Xy28UzPI5HA07tdGkSPGbdPmmC
	 40FqdTOgYLKi3RD1jtB1TCyLl0aAcpMHXJ4TuF5cxXSMZVR44dHPQZQT7q85oXegJp
	 CNFSuPvIjPopg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/23/19 3:37 PM, ira.weiny@intel.com wrote:
> From: Ira Weiny <ira.weiny@intel.com>
>=20
> Device pages can be more than type MEMORY_DEVICE_PUBLIC.
>=20
> Handle all device pages within release_pages()
>=20
> This was found via code inspection while determining if release_pages()
> and the new put_user_pages() could be interchangeable.
>=20
> Cc: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> ---
>  mm/swap.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
>=20
> diff --git a/mm/swap.c b/mm/swap.c
> index 3a75722e68a9..d1e8122568d0 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -739,15 +739,14 @@ void release_pages(struct page **pages, int nr)
>  		if (is_huge_zero_page(page))
>  			continue;
> =20
> -		/* Device public page can not be huge page */
> -		if (is_device_public_page(page)) {
> +		if (is_zone_device_page(page)) {
>  			if (locked_pgdat) {
>  				spin_unlock_irqrestore(&locked_pgdat->lru_lock,
>  						       flags);
>  				locked_pgdat =3D NULL;
>  			}
> -			put_devmap_managed_page(page);
> -			continue;
> +			if (put_devmap_managed_page(page))
> +				continue;
>  		}
> =20
>  		page =3D compound_head(page);
>=20

Reviewed-by: John Hubbard <jhubbard@nvidia.com>

thanks,
--=20
John Hubbard
NVIDIA

