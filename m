Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD2D3C76186
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 23:29:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D09B21773
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 23:29:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="jjOqVbu0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D09B21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E60578E0005; Mon, 29 Jul 2019 19:29:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E10CD8E0002; Mon, 29 Jul 2019 19:29:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D276A8E0005; Mon, 29 Jul 2019 19:29:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id B31B08E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 19:29:58 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id k21so46640762ywk.2
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 16:29:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=0+thxvZnJ+gcbF/O0zGGEBA6QvsuJ+b1Oc5FzJoq0pI=;
        b=p2bs4rfBN6NBYuH3lXJhr3L2dup89MJIbeJ76C0WKnpeYGUVjzr/egMbuayMVJFY6t
         ApGmEeg0EtjQarxbuqhogQoAe6IAHttVz54doIiLs4XC/zCQ0sO2F6AsjkoRQay4cJnn
         HKXCvAmLUOM9ZmHriMil0R92tGolwIQyCdc0fyQT95GJWzlWY09Jl5zScM2eVhpXTVBZ
         tYLB11gm6dZzHIsXqN38HjwIZx2LGkC56JWByrVtHr1tVPBQAQOD7DBvAYHwkOAK9Ntz
         4ZfUKSw+MHIN6OiSIlf3seF/Jmk9i0Ld975In7BemQMaxyvUIS3HzamN/bDC3im/kztL
         5g+w==
X-Gm-Message-State: APjAAAUDsgRM32DtzTWz4sMEoFxXkUClV6jpxV8ajuGomqNCjCFvDGXv
	p37ZvETv/NUy+nHaYCgzw6xcT6XJ5/s2Af4hbxjQdgpEZ2haA+63VD4KClwPGapf4XVNNu1nlV5
	EJ42ktyXD9lpzVT7BCgY5S6iGhlqMY9sbs3fm/+fV++c29G8litLbaHNE02nblzHTrw==
X-Received: by 2002:a25:6586:: with SMTP id z128mr67159967ybb.5.1564442998483;
        Mon, 29 Jul 2019 16:29:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwdG4msIME3FvA386e5F5qBY0Yc8Iikx+2COzn5UPXJ1352Bkx5j0cIOzHMSCtQEy5+VdoF
X-Received: by 2002:a25:6586:: with SMTP id z128mr67159956ybb.5.1564442998054;
        Mon, 29 Jul 2019 16:29:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564442998; cv=none;
        d=google.com; s=arc-20160816;
        b=XCvH0Q4RyzWZBIuPSAi2yUC2s5pcvPxpRp2F7H6Ig822sEnpdDeUP75b+SCuV6BBAm
         Fe7TTIRrdx1K2vqkvvC/jtKXBfTHyQninyNTGlyyxoNiggsw5L32ABlNIvX9gHiw4c0q
         Q2thpL4wvkuAaSmaXPIq5i9RrBz9DT53jTP5aU+Dd1xlKaO9uONhW2zxJ0tKpeATP6x+
         WL5JFmbmIcylpDCYi0CJvViKsAcLmj/Fcy2M2YbQyzU6x2Ob6uPEl8ltoBn/2+NRyDku
         dybgUtvO6IY9RGtbNyIsx+QDYOMJvZuet+s/mYemR+w7nr7SPgzfiHh2bKt0dojKBhoe
         tgKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=0+thxvZnJ+gcbF/O0zGGEBA6QvsuJ+b1Oc5FzJoq0pI=;
        b=OlEr42pJYdkiQTFBw0/K0QRU1JW49uGx2onBo2BM9BzAYU/z6ukUY4zPZocaIniv6s
         ZhWJoRCAMwxvD9aCpO/KVnB1f6qcIugVL5R6H02UXIZUC00UlUXlX4fOpOKiCTI9PdNU
         pKPHgpyqdfGLpZ76rQw06/Y6fgJsABFkx6XeoZGbtY0KDnu7wOSAvZpjr4qEWHLe9wrT
         NPuwaYWLYj4UHV4w8XLEnqlQ1Dsus2vmdypH26btc2a4AJ/cYQaKtQnNncylDtgngLPs
         K29dKXxco2Y5cTJHoP//cCaVwGkDW45fixvwguPPyXQPEeAid7lUJ9p0uf2czbjiS6Wu
         +t0w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=jjOqVbu0;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id e131si5739800ywb.406.2019.07.29.16.29.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 16:29:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=jjOqVbu0;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d3f81750000>; Mon, 29 Jul 2019 16:29:57 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Mon, 29 Jul 2019 16:29:57 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Mon, 29 Jul 2019 16:29:57 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 29 Jul
 2019 23:29:55 +0000
Subject: Re: [PATCH 7/9] mm: remove the unused MIGRATE_PFN_ERROR flag
To: Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs
	<bskeggs@redhat.com>
CC: Bharata B Rao <bharata@linux.ibm.com>, Andrew Morton
	<akpm@linux-foundation.org>, <linux-mm@kvack.org>,
	<nouveau@lists.freedesktop.org>, <dri-devel@lists.freedesktop.org>,
	<linux-kernel@vger.kernel.org>
References: <20190729142843.22320-1-hch@lst.de>
 <20190729142843.22320-8-hch@lst.de>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <32f08aa4-c9a3-9545-69aa-2cc3695e15df@nvidia.com>
Date: Mon, 29 Jul 2019 16:29:55 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190729142843.22320-8-hch@lst.de>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1564442997; bh=0+thxvZnJ+gcbF/O0zGGEBA6QvsuJ+b1Oc5FzJoq0pI=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=jjOqVbu0SE9IxctyMwqyl6NjiHxbcjJTt/QVPTeHFWZn91g7rXHLoSsXIJCkRMepQ
	 4RDY3eiq+JBeMQ2R9fiv8HeECvSmM4knWmk7sjO4TB+BOlqd8o0nizQlMk7DYq6sLe
	 +sqF9pqPZKgpUwuguZXMwVmav3HEr6qCsATcyT863EyZfvbK1jjnL6yqbPEQd9ijjJ
	 ydsHBn1jU60iHnXNioMmy0fn3Po4Y09SrgrhUiGTMRt6lWOqkn7isWclIxYgC0avDf
	 v8q4S08zaE3ikIRtGMn7WjLZkqBtGEBL5IeWH0mes0o8HnufoNHBj4X8jpeZ1nRHSl
	 igU0UgPAUNzQQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/29/19 7:28 AM, Christoph Hellwig wrote:
> We don't use this flag anymore, so remove it.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

> ---
>   include/linux/migrate.h | 1 -
>   1 file changed, 1 deletion(-)
> 
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index 093d67fcf6dd..229153c2c496 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -167,7 +167,6 @@ static inline int migrate_misplaced_transhuge_page(struct mm_struct *mm,
>   #define MIGRATE_PFN_LOCKED	(1UL << 2)
>   #define MIGRATE_PFN_WRITE	(1UL << 3)
>   #define MIGRATE_PFN_DEVICE	(1UL << 4)
> -#define MIGRATE_PFN_ERROR	(1UL << 5)
>   #define MIGRATE_PFN_SHIFT	6

The MIGRATE_PFN_SHIFT could be reduced to 5 since it is only used
to make room for the flags.

>   static inline struct page *migrate_pfn_to_page(unsigned long mpfn)
> 

