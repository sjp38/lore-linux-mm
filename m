Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54B81C433FF
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 00:11:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12F98208C2
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 00:11:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="g0iXAp9G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12F98208C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A61CD6B0003; Wed, 14 Aug 2019 20:11:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A13456B0007; Wed, 14 Aug 2019 20:11:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 902366B0008; Wed, 14 Aug 2019 20:11:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0224.hostedemail.com [216.40.44.224])
	by kanga.kvack.org (Postfix) with ESMTP id 702B76B0003
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 20:11:40 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 1460752A9
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 00:11:40 +0000 (UTC)
X-FDA: 75822733560.13.pig22_82e2271c60939
X-HE-Tag: pig22_82e2271c60939
X-Filterd-Recvd-Size: 5570
Received: from mail-qt1-f196.google.com (mail-qt1-f196.google.com [209.85.160.196])
	by imf17.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 00:11:39 +0000 (UTC)
Received: by mail-qt1-f196.google.com with SMTP id l9so655109qtu.6
        for <linux-mm@kvack.org>; Wed, 14 Aug 2019 17:11:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=sa+zQVwF/Kg2yH2R3qjmRo+nBMZgWEgWy9VtHzhObIQ=;
        b=g0iXAp9GLKjmJUCykogXNEfQUbyHV9nCucIjUntdM1KKe6wGTXBPlF2UOoTWZOGfJl
         AmajYGKP63nxK6g4uAQuCBhnJ9E6JBx7+PoQJl4H925pXAjlhGkj572kQrS2NActiipP
         kxwRxIXOfJDm8mccWD6WHhV9xJyTZoODJcRJWpuRBg9qbQQk4EiIxDhaFEh+gSkvInRl
         wmPRmh/bNa5dNbX8qh2MmqKpcoUwYdco5Q1f/jvTQoW1q8UlyeXxKNaG6oETdo4lI4Kt
         Lzy3yHCgAJpdYNwrpVyOegXvj1unwKdFwN8pNkz4YjlDTDEUIixQQUpKRN+VZGMEPnlq
         qHLw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:content-transfer-encoding
         :in-reply-to:user-agent;
        bh=sa+zQVwF/Kg2yH2R3qjmRo+nBMZgWEgWy9VtHzhObIQ=;
        b=UL6DWTXx2t+9YiGvvp36E8EGLF3w+avGex0Iwau4ed3FnJ1SJcTXuiSBp64ENXelIK
         8XAKvsHNVVyxaqzPAflQSE5YYb/L8uATqzAU3ZukxvBDRHnpS8Re/nkZKM2dIa9xzWsV
         H4K2ZdLY7X05FItmlaCWvpJIuzJ29nOJxPPU6T+mDfehNQhfsNUTIz6a33rK0PaGhzd9
         jB60mVp+ABuj136uReCLmo9isq3YfPovkZycbZGn8GkBayixcR9+c4K2NyeCd+P3N7WR
         z+d+YewxJCMUePMizn5W6RpL/5FpEPO/638p9QEqRZ06rfZT7IX9XucMKvtUTJnuoRDm
         P/0g==
X-Gm-Message-State: APjAAAWmiDKiTveQHyF/XlHVZuiBcvhvZNDe9dyJnwK6J2gzDR99fBOo
	0iJcNiyjzEtHQCEboXmM4YeaBuh9FOQ=
X-Google-Smtp-Source: APXvYqycoMish4JR7Yhk7POc91EfS5nVJ1Ns5md0NOId7Ywyc7vJCJUYwUMZE0JVH6XYbdhlVPx8eg==
X-Received: by 2002:ad4:45e3:: with SMTP id q3mr1591887qvu.140.1565827898756;
        Wed, 14 Aug 2019 17:11:38 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id f20sm939480qtf.68.2019.08.14.17.11.38
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Aug 2019 17:11:38 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hy3Mf-0003aK-TC; Wed, 14 Aug 2019 21:11:37 -0300
Date: Wed, 14 Aug 2019 21:11:37 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Matthew Wilcox <willy@infradead.org>, Arnd Bergmann <arnd@arndb.de>,
	Balbir Singh <bsingharora@gmail.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 5/5] mm/hmm: WARN on illegal ->sync_cpu_device_pagetables
 errors
Message-ID: <20190815001137.GE11200@ziepe.ca>
References: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
 <20190814202027.18735-6-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190814202027.18735-6-daniel.vetter@ffwll.ch>
User-Agent: Mutt/1.9.4 (2018-02-28)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 14, 2019 at 10:20:27PM +0200, Daniel Vetter wrote:
> Similar to the warning in the mmu notifer, warning if an hmm mirror
> callback gets it's blocking vs. nonblocking handling wrong, or if it
> fails with anything else than -EAGAIN.
>=20
> Cc: Jason Gunthorpe <jgg@ziepe.ca>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Dan Carpenter <dan.carpenter@oracle.com>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Balbir Singh <bsingharora@gmail.com>
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: Souptick Joarder <jrdr.linux@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
> Cc: linux-mm@kvack.org
> Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
>  mm/hmm.c | 3 +++
>  1 file changed, 3 insertions(+)
>=20
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 16b6731a34db..52ac59384268 100644
> +++ b/mm/hmm.c
> @@ -205,6 +205,9 @@ static int hmm_invalidate_range_start(struct mmu_no=
tifier *mn,
>  			ret =3D -EAGAIN;
>  			break;
>  		}
> +		WARN(ret, "%pS callback failed with %d in %sblockable context\n",
> +		     mirror->ops->sync_cpu_device_pagetables, ret,
> +		     update.blockable ? "" : "non-");
>  	}
>  	up_read(&hmm->mirrors_sem);

Didn't I beat you to this?

	list_for_each_entry(mirror, &hmm->mirrors, list) {
		int rc;

		rc =3D mirror->ops->sync_cpu_device_pagetables(mirror, &update);
		if (rc) {
			if (WARN_ON(update.blockable || rc !=3D -EAGAIN))
				continue;
			ret =3D -EAGAIN;
			break;
		}
	}

Thanks,
Jason

