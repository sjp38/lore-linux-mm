Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 197F6C76186
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 23:42:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C00582070B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 23:42:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="dkCF/sqU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C00582070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A3E78E0005; Mon, 29 Jul 2019 19:42:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 52E5B8E0002; Mon, 29 Jul 2019 19:42:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3A6B48E0005; Mon, 29 Jul 2019 19:42:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 116A48E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 19:42:09 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id d135so46662333ywd.0
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 16:42:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=mEZj3q5EnGdFR96z4O+Iz+WRmNblkDEHHCZr6fLsRoI=;
        b=F1mzHorK09aQK8/H3yeCLjA2Dy8m6skqq02bOM/3a1FXtoP5fn1lPa+XTRzeqPU9rk
         9DxMCthKXQmC7guj460L3ioXvt8BvEoJjxkG1YaUgXN6MgQU3XKcwvEVqw88ZCdkza99
         W9DqvdZJ33S2Kei4tN8iCGY+Ql87e9ncbEI3eHyVHwDCcTlGVtgOXB+brb0PD2joNdyV
         3S6FP7sIsb+gMtiill+k94w3RG9IYBIC74xcwAWzQYXD9aN+lc+bcsiNiy0r+yuimJL8
         K3pL0TJt+p9X0Or4RE6D7Ie+L9pNeQBXM0E1oFIdHi+t39p7kPt48NVOB4/eboaTj8x6
         FQsQ==
X-Gm-Message-State: APjAAAXlNIWD3zRlU7fEoyEntZKV6fJ9FWCfp7rLhTzM7n0ZEmV3DcMJ
	vCGt2BQmL7H1tn7bS0WXyqRs4FyI0PjKIPPJKopV/EB1iJTa3TidNO6f9JXe/KGFsjOqvqe9fvB
	reXxBsmU/tkKWi8DQSTMmJUIQw+sjQ2TJR8sttJADhYY9aqpC0tM34477Lhufp+DDkw==
X-Received: by 2002:a25:1283:: with SMTP id 125mr71265101ybs.55.1564443728843;
        Mon, 29 Jul 2019 16:42:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzE813BVdZRn8w9u9fXpbGjHmaUtSIBPgOYwD2oQBeRaFsM+U6cnHMA/hIcQLEoY4932oXp
X-Received: by 2002:a25:1283:: with SMTP id 125mr71265086ybs.55.1564443728253;
        Mon, 29 Jul 2019 16:42:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564443728; cv=none;
        d=google.com; s=arc-20160816;
        b=jrK/JjrzLpqQFXy7h7jrTTOCIDHMDC7HJqmNs2UkjzFYlq9pndfSnbqcoa3P1jBnhP
         LAQCUitdzF063W/N947n/CCLkTTnl19ziolfA3a1v8rzFCQPjmfcRd2HSzBqU/DLMHhc
         WRSAiMglf0x5NyetsUmEwUdc2Cst6BiIbiQ5cLd/stQTjsX12pPYacx4njdmkQFwmK8l
         R5bXmnJHKFQcEP2o1vPmoOMSHcOYAQXTa76UV8xUTM1R9DJsUG5EC1SqNutQ/YrVkipz
         XVSO91FvdIhK3V1CCoHofUJF3M2+aw59msrnnJzv8VIxHIrVGI0PbD7Pmuc1Q7WHKwVG
         rJ6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=mEZj3q5EnGdFR96z4O+Iz+WRmNblkDEHHCZr6fLsRoI=;
        b=rPBEVJ2umOkMbHdjC5+El+Km3zYQNz4WHfipS4HLZUprHy/TrKyY6buyyw0J+vvjcc
         PIfhuAzIxrI2VrKoxzVxEsKGNnO6M9oCNAM8Ya/bsb7m3NKhO/yVcI6KeLwIAKr/5e2x
         gbVhGUSy/I3jlpd5WNgG1WxZYd01mlXSKvCPHCFEHQmWFDteDG4bldSFRHmDFJ3SGr43
         XX4WuMEqDZJy7iznvbCbH8AdoLzos88OWHehx1OSyzEgrgk7lko7NyGioeXX3t+8TQxM
         a/34uibVn2tu72SW1cBeb0QLxOYmdcmdCnGw+GD4UT/z30kjfWyyHHL7fwQl+WexN0Cx
         Z6zA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="dkCF/sqU";
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id a65si20794631ywh.462.2019.07.29.16.42.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 16:42:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="dkCF/sqU";
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d3f844f0000>; Mon, 29 Jul 2019 16:42:07 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 29 Jul 2019 16:42:07 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 29 Jul 2019 16:42:07 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 29 Jul
 2019 23:42:02 +0000
Subject: Re: [PATCH 9/9] mm: remove the MIGRATE_PFN_WRITE flag
To: Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs
	<bskeggs@redhat.com>
CC: Bharata B Rao <bharata@linux.ibm.com>, Andrew Morton
	<akpm@linux-foundation.org>, <linux-mm@kvack.org>,
	<nouveau@lists.freedesktop.org>, <dri-devel@lists.freedesktop.org>,
	<linux-kernel@vger.kernel.org>
References: <20190729142843.22320-1-hch@lst.de>
 <20190729142843.22320-10-hch@lst.de>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <1f0ef337-6ca5-54fa-e627-41a46be73f2b@nvidia.com>
Date: Mon, 29 Jul 2019 16:42:01 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190729142843.22320-10-hch@lst.de>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1564443727; bh=mEZj3q5EnGdFR96z4O+Iz+WRmNblkDEHHCZr6fLsRoI=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=dkCF/sqUubSJ16D0gzxWuIiRNyylExBkjSHrf+wBYiOEClAdNIcs4OLHo2fvbGIoX
	 1HoTvy5tiILWD6dBrPFwdRF2JWe6qCogaekLOh7Q9mzfJygH45h8qJ5PLN8swqY07T
	 H1AJG4slDbp8zFXaoA4gVYQpxo9dk3Ja5/reP1N0iQzGM2uEGVxa5oPVE2ahLha6XU
	 XU7vinMQxUun59ktKiGlAoPT5x2NslQA58ySa1FgSzuEL5AR9P4hKjpvOH9Ww28B4H
	 /6XKbzh2v/KF3c26Bvn4BAaIQuv9vhITJ4xA1s6tfjdxhUZXgaQvU2ZRaV1RuodxD0
	 NRxR0aABTDx7Q==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/29/19 7:28 AM, Christoph Hellwig wrote:
> The MIGRATE_PFN_WRITE is only used locally in migrate_vma_collect_pmd,
> where it can be replaced with a simple boolean local variable.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

> ---
>   include/linux/migrate.h | 1 -
>   mm/migrate.c            | 9 +++++----
>   2 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index 8b46cfdb1a0e..ba74ef5a7702 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -165,7 +165,6 @@ static inline int migrate_misplaced_transhuge_page(struct mm_struct *mm,
>   #define MIGRATE_PFN_VALID	(1UL << 0)
>   #define MIGRATE_PFN_MIGRATE	(1UL << 1)
>   #define MIGRATE_PFN_LOCKED	(1UL << 2)
> -#define MIGRATE_PFN_WRITE	(1UL << 3)
>   #define MIGRATE_PFN_SHIFT	6
>   
>   static inline struct page *migrate_pfn_to_page(unsigned long mpfn)
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 74735256e260..724f92dcc31b 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -2212,6 +2212,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
>   		unsigned long mpfn, pfn;
>   		struct page *page;
>   		swp_entry_t entry;
> +		bool writable = false;
>   		pte_t pte;
>   
>   		pte = *ptep;
> @@ -2240,7 +2241,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
>   			mpfn = migrate_pfn(page_to_pfn(page)) |
>   					MIGRATE_PFN_MIGRATE;
>   			if (is_write_device_private_entry(entry))
> -				mpfn |= MIGRATE_PFN_WRITE;
> +				writable = true;
>   		} else {
>   			if (is_zero_pfn(pfn)) {
>   				mpfn = MIGRATE_PFN_MIGRATE;
> @@ -2250,7 +2251,8 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
>   			}
>   			page = vm_normal_page(migrate->vma, addr, pte);
>   			mpfn = migrate_pfn(pfn) | MIGRATE_PFN_MIGRATE;
> -			mpfn |= pte_write(pte) ? MIGRATE_PFN_WRITE : 0;
> +			if (pte_write(pte))
> +				writable = true;
>   		}
>   
>   		/* FIXME support THP */
> @@ -2284,8 +2286,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
>   			ptep_get_and_clear(mm, addr, ptep);
>   
>   			/* Setup special migration page table entry */
> -			entry = make_migration_entry(page, mpfn &
> -						     MIGRATE_PFN_WRITE);
> +			entry = make_migration_entry(page, writable);
>   			swp_pte = swp_entry_to_pte(entry);
>   			if (pte_soft_dirty(pte))
>   				swp_pte = pte_swp_mksoft_dirty(swp_pte);
> 

MIGRATE_PFN_WRITE may mot being used but that seems like a bug to me.
If a page is migrated to device memory, it could be mapped at the same
time to avoid a device page fault but it would need the flag to know
whether to map it RW or RO. But I suppose that could be inferred from
the vma->vm_flags.

