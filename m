Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D995BC76195
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 21:43:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8290821880
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 21:43:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="S4D0txoX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8290821880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2692E6B0006; Fri, 19 Jul 2019 17:43:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1CB946B0007; Fri, 19 Jul 2019 17:43:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F37776B0008; Fri, 19 Jul 2019 17:43:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id CF02A6B0006
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 17:43:22 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id b188so24643346ywb.10
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 14:43:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=k+MfdY4VFZ+1G6NydT7z1KYzEUKt/3lM29KKNcFF7DE=;
        b=UcBjDF8QEgBCDJPgxGF4bquiy2MGTSratGMd2fNgoOGv+D+LswPQw50m7unDnveNaP
         dXwIxsQVm3OCCfRZEOa8/i8Gpmr6CMqTkCeQ3B5feiLUgfR4vAf+fsiJWhI99I/frniw
         yCZvHZygSYibEmt3+zRpRwDb0ZPpKc+BnbLVN/jsb9Hwig1oqQAJjhb0IsyK6XSc8Qmt
         M+YmM2IEkFmtLup0S/h73P1+OM7M6j31eBzx+aaUDqXMLu5lr4kR7mJlopjVZ+IXJbAl
         vNwfuxScwVlKeyISKlX6+KHQ88Q4OLHob81M5WOrOhYgx0J5Blp6cBgP+YWNgz6uS2Kw
         6qcw==
X-Gm-Message-State: APjAAAVVBv+rOuRlyR43DHkGFwca5atnoEbHxbB8JwDAOFosIlvclyrW
	S5gPORGxKbHzsQWSF5vQMETz+cXaLU1PP0jm6vgMrM3+ZCMRIbGfBnlei5EYkF4IFOlc+bgr1YE
	908NgpjhXY2VZXQ3I3YsceVem2rY04/jaim9//oj4TiXUHdJCZ2gliuUBlqrPYzRiWg==
X-Received: by 2002:a25:7612:: with SMTP id r18mr36219262ybc.490.1563572602563;
        Fri, 19 Jul 2019 14:43:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxC6agj6S7bit8cDbuVoR5GGJ0MxlenHYqZmN6HRR4eEK0EPG7U3R5VaYqI7gqfkJ8VlcwG
X-Received: by 2002:a25:7612:: with SMTP id r18mr36219243ybc.490.1563572601929;
        Fri, 19 Jul 2019 14:43:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563572601; cv=none;
        d=google.com; s=arc-20160816;
        b=qwXGXabvvCawA9Xeu6LKD3jcFQp0+fafAbk9C5H9pRdfmGO13U6uQdeIMVGpR/rMJD
         1rJhLFAzKzcKMx04cziDnEWhW3l7qXokpzH5hoWDoJhRsRL80Fc6zE7JSlNmvg4KYMY+
         SRtpc49/h5OMzzy26AkhB3eCw2oNbj7yx/h3Q+cUxcw+2mly0OCmeXLf0GQ2lElnZQ3g
         pMa9dEfVDG86RWxyYkCED8W01RVfGZtA+3Az/+TKUk+JZPM5QGUi8PI/0xmx/zLVMUf0
         IkhAnxrFGivl5pvCM4thx0U5qcx1Egp45ITdKHiSK4NRGWPa8nPPrifwpFXKkKsLDeoy
         AMLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=k+MfdY4VFZ+1G6NydT7z1KYzEUKt/3lM29KKNcFF7DE=;
        b=HHNW9uVfqDlHWCMpjjaHwQAbwRUU+q4Wn6sMfSZpZKyvPFIEHaW+dLSF9BCKDa11hV
         nwC2ZFz8QFJxG2XovGRB2RMRxPwKJD00cTY9Jut2uDy7aPNE2LM7Ccu0+mMKSVEo6rwI
         Zx+fLMGdYbFBVCeaAoLFrosO/BKzgdphMJMuHTk+Lf+tUqZwZ1JM4G3w9dbhJSJ4RlzS
         pC2+mShxXw9n6cNxnjprwHv9yjILjKK4LrBezvj3Mh/tinnJaLgT5vp1L/6Ug2JJzRcr
         wvYZ19PAqOoC24N5b/yV7voo0aymEZCJR+gYUrhe4zti7Hddv7W6zUDU3oaWFAADv2n6
         47ew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=S4D0txoX;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id a75si11573221ywa.45.2019.07.19.14.43.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 14:43:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=S4D0txoX;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d3239760000>; Fri, 19 Jul 2019 14:43:18 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 19 Jul 2019 14:43:20 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 19 Jul 2019 14:43:20 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 19 Jul
 2019 21:43:18 +0000
Subject: Re: [PATCH v2 1/3] mm: document zone device struct page field usage
To: Ralph Campbell <rcampbell@nvidia.com>, <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>,
	Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, "Dave
 Hansen" <dave.hansen@linux.intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, "Kirill A . Shutemov"
	<kirill.shutemov@linux.intel.com>, Lai Jiangshan <jiangshanlai@gmail.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>, Pekka Enberg
	<penberg@kernel.org>, Randy Dunlap <rdunlap@infradead.org>, Andrey Ryabinin
	<aryabinin@virtuozzo.com>, Christoph Hellwig <hch@lst.de>, Jason Gunthorpe
	<jgg@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds
	<torvalds@linux-foundation.org>
References: <20190719192955.30462-1-rcampbell@nvidia.com>
 <20190719192955.30462-2-rcampbell@nvidia.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <e9b6204f-9c80-e724-6ab6-6f32aa762c8c@nvidia.com>
Date: Fri, 19 Jul 2019 14:43:17 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190719192955.30462-2-rcampbell@nvidia.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563572598; bh=k+MfdY4VFZ+1G6NydT7z1KYzEUKt/3lM29KKNcFF7DE=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=S4D0txoXh5ZlUY37eQf+2R6xEnAxjq7ugYhSFhHNeaZJc9gzt9AFqSTcqwxgF4ipI
	 OaPooSm3TY1Y/tCOgH4IQijSLZMX2+/CTLTxxnYrYVCT1Yd9vvXnBokWprsQCA0SBu
	 hFaFsXxrQ2orwUntRfq0/vwbW9AZnv6tZl6Z/QKbtny+xYzOMoTlK/jNOafxR/RuuN
	 OkUICjRl6gUjlig8xvZ/FwUkCxVyAe7+S9G64st1c0V2EQVHSwmZllERNtNjB8ynC0
	 +uZq4tzbY321dByCbFHF3UhYBdZPsV93HdC7nag52tX1rzhZGjdAo3WLONbyYZ5Bdy
	 Af+qRnzn1qvRw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/19/19 12:29 PM, Ralph Campbell wrote:
> Struct page for ZONE_DEVICE private pages uses the page->mapping and
> and page->index fields while the source anonymous pages are migrated to
> device private memory. This is so rmap_walk() can find the page when
> migrating the ZONE_DEVICE private page back to system memory.
> ZONE_DEVICE pmem backed fsdax pages also use the page->mapping and
> page->index fields when files are mapped into a process address space.
>=20
> Restructure struct page and add comments to make this more clear.
>=20
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> Reviewed-by: John Hubbard <jhubbard@nvidia.com>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Lai Jiangshan <jiangshanlai@gmail.com>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: Randy Dunlap <rdunlap@infradead.org>
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Jason Gunthorpe <jgg@mellanox.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> ---
>  include/linux/mm_types.h | 42 +++++++++++++++++++++++++++-------------
>  1 file changed, 29 insertions(+), 13 deletions(-)
>=20
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 3a37a89eb7a7..f6c52e44d40c 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -76,13 +76,35 @@ struct page {
>  	 * avoid collision and false-positive PageTail().
>  	 */
>  	union {
> -		struct {	/* Page cache and anonymous pages */
> -			/**
> -			 * @lru: Pageout list, eg. active_list protected by
> -			 * pgdat->lru_lock.  Sometimes used as a generic list
> -			 * by the page owner.
> -			 */
> -			struct list_head lru;
> +		struct {	/* Page cache, anonymous, ZONE_DEVICE pages */
> +			union {
> +				/**
> +				 * @lru: Pageout list, e.g., active_list
> +				 * protected by pgdat->lru_lock. Sometimes
> +				 * used as a generic list by the page owner.
> +				 */
> +				struct list_head lru;
> +				/**
> +				 * ZONE_DEVICE pages are never on the lru
> +				 * list so they reuse the list space.
> +				 * ZONE_DEVICE private pages are counted as
> +				 * being mapped so the @mapping and @index
> +				 * fields are used while the page is migrated
> +				 * to device private memory.
> +				 * ZONE_DEVICE MEMORY_DEVICE_FS_DAX pages also
> +				 * use the @mapping and @index fields when pmem
> +				 * backed DAX files are mapped.
> +				 */
> +				struct {
> +					/**
> +					 * @pgmap: Points to the hosting
> +					 * device page map.
> +					 */
> +					struct dev_pagemap *pgmap;
> +					/** @zone_device_data: opaque data. */

This is nice, and I think it's a solid step forward in documentation via
clearer code. I recall a number of email, and even face to face discussions=
,
in which the statement kept coming up: "remember, the ZONE_DEVICE pages use
mapping and index, too. Actually, that reminds me: page->private is often
in use in that case, too, so ZONE_DEVICE couldn't use that, either. I don't
think we need to explicitly say that, though, with this new layout.

nit: the above comment can be deleted, because it merely echoes the actual
code that directly follows it.

Either way, you can add:

	Reviewed-by: John Hubbard <jhubbard@nvidia.com>


thanks,
--=20
John Hubbard
NVIDIA

> +					void *zone_device_data;
> +				};
> +			};
>  			/* See page-flags.h for PAGE_MAPPING_FLAGS */
>  			struct address_space *mapping;
>  			pgoff_t index;		/* Our offset within mapping. */
> @@ -155,12 +177,6 @@ struct page {
>  			spinlock_t ptl;
>  #endif
>  		};
> -		struct {	/* ZONE_DEVICE pages */
> -			/** @pgmap: Points to the hosting device page map. */
> -			struct dev_pagemap *pgmap;
> -			void *zone_device_data;
> -			unsigned long _zd_pad_1;	/* uses mapping */
> -		};
> =20
>  		/** @rcu_head: You can use this to free a page by RCU. */
>  		struct rcu_head rcu_head;
>=20

