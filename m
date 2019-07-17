Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A4F8C76192
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 01:20:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B2DC21871
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 01:20:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="WO09GKZi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B2DC21871
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA8F36B0003; Tue, 16 Jul 2019 21:20:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D32BC8E0001; Tue, 16 Jul 2019 21:20:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD2266B0006; Tue, 16 Jul 2019 21:20:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 986796B0003
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 21:20:29 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id j144so17631151ywa.15
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 18:20:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=Vyc38CvrMI+IuIuIo5NTAipNHSrHTq4RP4d6/FH8/Ss=;
        b=t2LlGCmFfh3yjDnxpBkjLjtXLz0cVIUIL3poJq7HDMu8jQ2JxRPJtwce7y8hEmQYDP
         ELB7l4LOl+6pEZhkBlMCB2kQPeGPOQYKIX4kbajo30erB43L0ygaSvs/Zw88bMk17VJa
         7axZyX1dLSf8JH5cgu9Iv1LbaR7TqcZ8DNoqbhXR4F3ictIv7H748SdPXlBz5++9NjnR
         07caL/3wajNquG/pfKN3iRKHqLFhbR6Ju87PbdgI/5FMdiLvMqlxyrmUvJnG08ymralY
         YY2uroXDBBjNmXyWRk4xq8oSwO4ZLl3hNGL+bTDYfS+eDwxQakwaaNja9dafwtYbgMTn
         5ZEQ==
X-Gm-Message-State: APjAAAWmPrY/1CjT8ULrQ18IUX8Khp/rOyiK9JxyKVxd+R7sOtycdxfz
	I2mJb5N8u43ubqnTU+9eq6+9QTD3VWdHTuQyzxRUP/IY2NFY/58WAY3jgmvWEWK76Vbp53LDxaI
	xQgGoVmbXYqIqBIMbE95oCp7gz30oCDPI+VuDFfqjRId2RR3l7uy+vlN7QMsNkfdXgQ==
X-Received: by 2002:a25:5d04:: with SMTP id r4mr20779221ybb.124.1563326429325;
        Tue, 16 Jul 2019 18:20:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqye/ULZVzYcdSoagJ0DshgNlJzKQHhFAxdcizil7ldjNUafQMNBbhyIWrxz8YY5ycoBbufX
X-Received: by 2002:a25:5d04:: with SMTP id r4mr20779201ybb.124.1563326428596;
        Tue, 16 Jul 2019 18:20:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563326428; cv=none;
        d=google.com; s=arc-20160816;
        b=Qu9BapRZuVnu7IeluDxL6wqQ1t/fCaQa6YPJlv1Y/Uy9FU50ol10BQFc7/RY4e+F+z
         jH1YXBkXlWvJ3mmzrAZeS0saPpHo/U37jGOyX4cYFDaBqagZH9rb46OiwblXNksosN7M
         E8NP2YnevboCQ+BOldZTTG8ZA3oFt1onYEFyvR0L7vXQGQemptkuFAbGbLWqV7HavMWg
         f3pXmhy3uwT8MQIfjhsLkzjgAT//eLdxSybAbjHWEAd3SmIfUIEiksm87yeLmzqM6Npu
         ZzTvl1I1rm+iAtAL39Uiqr20c7UvzyI/MpMkLXAEZAXRp/KZR6S1rqrLhlRouj/oebt0
         smRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=Vyc38CvrMI+IuIuIo5NTAipNHSrHTq4RP4d6/FH8/Ss=;
        b=k9q51TgkhRqitj8lnoIGG4GV2eUmqqdG+gTxhw9DBgCZJdjD0IPPWE6KlsbT/dD7xB
         4p1ZPKu7jwQPZXHtxK3nx0wOnCVGTZH0lFVI0n20BYmPtdCbWafMrCnNtsIHEGVN/Kg2
         vmv8vLw3vmRiQEZbhDxH18A5NnEH8HZ+96j/hWVmXJX5612sw3V5DNpabaiTaG7iPGMN
         imknQ98JRx1I2vU3ga2yAOaYi+caE8JpLQTzauZ0ZJpQ/pHnYpwmw6p5sZqgL7KDT+6v
         lhiKLb59cU6RrWc/fYBov6gy9GoPXQbV3dd3F91v/RqnJdiBqtEx5U6dpMZTrWq1/qbU
         LMVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=WO09GKZi;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id e186si8785345ywh.355.2019.07.16.18.20.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 18:20:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=WO09GKZi;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d2e77db0000>; Tue, 16 Jul 2019 18:20:27 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Tue, 16 Jul 2019 18:20:27 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Tue, 16 Jul 2019 18:20:27 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 17 Jul
 2019 01:20:24 +0000
Subject: Re: [PATCH 1/3] mm: document zone device struct page reserved fields
To: Ralph Campbell <rcampbell@nvidia.com>, <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Matthew Wilcox <mawilcox@microsoft.com>,
	Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, "Dave
 Hansen" <dave.hansen@linux.intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, "Kirill A . Shutemov"
	<kirill.shutemov@linux.intel.com>, Lai Jiangshan <jiangshanlai@gmail.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>, Pekka Enberg
	<penberg@kernel.org>, Randy Dunlap <rdunlap@infradead.org>, Andrey Ryabinin
	<aryabinin@virtuozzo.com>, Christoph Hellwig <hch@lst.de>, Jason Gunthorpe
	<jgg@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds
	<torvalds@linux-foundation.org>
References: <20190717001446.12351-1-rcampbell@nvidia.com>
 <20190717001446.12351-2-rcampbell@nvidia.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <26a47482-c736-22c4-c21b-eb5f82186363@nvidia.com>
Date: Tue, 16 Jul 2019 18:20:23 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190717001446.12351-2-rcampbell@nvidia.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563326427; bh=Vyc38CvrMI+IuIuIo5NTAipNHSrHTq4RP4d6/FH8/Ss=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=WO09GKZipFxahEW5auLlDTfWxasD4caJ5DWx+kkRN+SKTnZgpslwxIm1aMHk+NDM5
	 oNro819e/6ny7tzneXhd7c3oFzjSAfCUAoyg+4fgYv94zvnDGpVTnEH8JC0Fs8u7i+
	 lQFDuRTd/mCIaObX6wuhRGeGlJh0q0TTi2K7OSbNLS61IcAvpK7XcAWEuW9NNbCZtC
	 UVULswtoe3nVubu594nPb/vsUveh4uHeRbIdotQnPxCVYRhb6saCW2Rv6oSuZtwhTa
	 yF2goo651+RXsGS6KJKvH/SqVF2bnh+pTJ8e85MDItskjDETciEas0UvsrqFTt/u9Z
	 UFW14TArW4Q/g==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/16/19 5:14 PM, Ralph Campbell wrote:
> Struct page for ZONE_DEVICE private pages uses the reserved fields when
> anonymous pages are migrated to device private memory. This is so
> the page->mapping and page->index fields are preserved and the page can
> be migrated back to system memory.
> Document this in comments so it is more clear.
>=20
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> Cc: Matthew Wilcox <mawilcox@microsoft.com>
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
>  include/linux/mm_types.h | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
>=20
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 3a37a89eb7a7..d6ea74e20306 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -159,7 +159,14 @@ struct page {
>  			/** @pgmap: Points to the hosting device page map. */
>  			struct dev_pagemap *pgmap;
>  			void *zone_device_data;
> -			unsigned long _zd_pad_1;	/* uses mapping */
> +			/*
> +			 * The following fields are used to hold the source
> +			 * page anonymous mapping information while it is
> +			 * migrated to device memory. See migrate_page().
> +			 */
> +			unsigned long _zd_pad_1;	/* aliases mapping */
> +			unsigned long _zd_pad_2;	/* aliases index */
> +			unsigned long _zd_pad_3;	/* aliases private */

Actually, I do think this helps. It's hard to document these fields, and
the ZONE_DEVICE pages have a really complicated situation during migration
to a device.=20

Additionally, I'm not sure, but should we go even further, and do this on t=
he=20
other side of the alias:

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index d6ea74e20306..c5ce5989d8a8 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -83,7 +83,12 @@ struct page {
                         * by the page owner.
                         */
                        struct list_head lru;
-                       /* See page-flags.h for PAGE_MAPPING_FLAGS */
+                       /*
+                        * See page-flags.h for PAGE_MAPPING_FLAGS.
+                        *
+                        * Also: the next three fields (mapping, index and
+                        * private) are all used by ZONE_DEVICE pages.
+                        */
                        struct address_space *mapping;
                        pgoff_t index;          /* Our offset within mappin=
g. */
                        /**

?

Either way, you can add:

    Reviewed-by: John Hubbard <jhubbard@nvidia.com>


thanks,
--=20
John Hubbard
NVIDIA

