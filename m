Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6018C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 23:31:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C95F20651
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 23:31:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="ksFZrQt2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C95F20651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B6398E0005; Mon, 29 Jul 2019 19:31:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 167E18E0002; Mon, 29 Jul 2019 19:31:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 02E5D8E0005; Mon, 29 Jul 2019 19:31:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id D6BFE8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 19:31:28 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id 63so45557395ybl.12
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 16:31:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=O8zN+ilqdowg6XJWOKGWaqeRnGFJG/18lWzHA9AhwWg=;
        b=OYYXq3ymliwlVZ9zaXpYjCup4wUhDqMnOnP7MpftMTxI47S9o8XAoks0tqfbcMjxMr
         b8FShy1Rf2uKQYMWnGmA6dEi/2X5ervguanoFiOrYntuB0/FpmIDdrc6FMEf18F91ts8
         O6/cjQa9vCb66dFmz04NECxFE3hc2/JQSDT9r3I/160I2e7UWuN0C1PjqKDl670mHRoH
         O/waZAwMTYmoI2P/8FNCXlbxKg9sy0JZgi2joPhSb0sFuWQmpkl0BkOwGF+y28Rb125D
         DHS9wuH/VpGvB/j1OTXV3L4offc5rcanyV0/vcA/aN5j68pmmA4gFAJFZxYS9aR+NF8+
         4Wdw==
X-Gm-Message-State: APjAAAX2krjC6jPjgyqu6twFUHxymxsXsiRFxgk5hn/YNwqLA3rzUBh0
	g1Oajrdco8mX/0RoEWtw5gE0rjo2fyTHhnR7DxL9T5c/zF7USSlmUJck7o78KE7F9TfTzc/mDK5
	R742vUteR6wh4ydcDUYsMmLCBpKBO/ZugPp+SBL2KsV5nRjlF0kEATMPe4leG1PkcBw==
X-Received: by 2002:a25:9c08:: with SMTP id c8mr71996916ybo.461.1564443088632;
        Mon, 29 Jul 2019 16:31:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwKNXgaXpS1dfkCY1Yki/5RJFN4/wL1A7vjRYYfRho5lxYZYmBuqB6VoajoWINNyvMX4aDU
X-Received: by 2002:a25:9c08:: with SMTP id c8mr71996884ybo.461.1564443088125;
        Mon, 29 Jul 2019 16:31:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564443088; cv=none;
        d=google.com; s=arc-20160816;
        b=fVhOI2JOQ0ODNK/8DjMWlgEBSFHnL29tRyp8znuJ0qD/xV1ehXYCPvwyPAtgKBD/2n
         DKpHsuU32n7IpRfKEpYvr8LQBhtPzIrzM54cx4QwttUrlu9QQaJyYhdHwPL2BK0Epzx1
         KQYaxnSNVCSqTb9CoDHAtJYI3QHFDUWrgLXwzAqbye6aMbIh6yDpeU9m59eXaJCHLMWQ
         JljvVd08RnhFKMXdeKRnSGz3a3vmFyG8M6fO8csKVulkPwCg/+KqFhj223Fz9mssajF6
         zXf7SOuNmbVOMYatAnhyglS6x2qp4+R/mVME4BdU07v2/LHqXjDXNEdzRp8YccV1yvUo
         WVlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=O8zN+ilqdowg6XJWOKGWaqeRnGFJG/18lWzHA9AhwWg=;
        b=odmtJ8M4DuWr9c1Km7CRxNxOaGljn0QSK0spHFzPiToDecXcV5SZc2qNvTK2dyqdZQ
         ca37AaXRYRfxTbjz+E8AuPpCmsFo8QkWLcMX1YY22U4Q4av9uFQlyXm9VjvWU1sQilU9
         MB1HhEFkUUBumuMAUniaqG3KxLObT15nU6fDhtiBmvgDYePaGWjNzkDp9MyXBsVRfiBH
         UF8hZ27gevIJXClr7HNO9ybnkXvGnKrKp+jK6oxhPEH5Llov9q42fYy7PkGrhwJd0AUn
         VVfiwuffK2HCq48/H0oxLBXFH7gfv6pN3qZNBhSx5ZM+X5oiS8PbqcdFEP9MtzN7ShMz
         c5SQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=ksFZrQt2;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id e142si14240599ybf.304.2019.07.29.16.31.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 16:31:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=ksFZrQt2;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d3f81d70000>; Mon, 29 Jul 2019 16:31:35 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Mon, 29 Jul 2019 16:31:27 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Mon, 29 Jul 2019 16:31:27 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 29 Jul
 2019 23:31:21 +0000
Subject: Re: [PATCH 8/9] mm: remove the unused MIGRATE_PFN_DEVICE flag
To: Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs
	<bskeggs@redhat.com>
CC: Bharata B Rao <bharata@linux.ibm.com>, Andrew Morton
	<akpm@linux-foundation.org>, <linux-mm@kvack.org>,
	<nouveau@lists.freedesktop.org>, <dri-devel@lists.freedesktop.org>,
	<linux-kernel@vger.kernel.org>
References: <20190729142843.22320-1-hch@lst.de>
 <20190729142843.22320-9-hch@lst.de>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <ef44f3bf-0f99-c76b-bf4b-6770545b5e38@nvidia.com>
Date: Mon, 29 Jul 2019 16:31:21 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190729142843.22320-9-hch@lst.de>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1564443095; bh=O8zN+ilqdowg6XJWOKGWaqeRnGFJG/18lWzHA9AhwWg=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=ksFZrQt2v45qX2vcjwJOYMc2IYWSZCkT/o6FR2ewt0B28A8Pwta4vodqAlIT7qjJ9
	 zqGQu+CeunJs69LRMBaqQpcPotQy5akTZlYOxF8zf4tZ8NOYJ3kFXTJallM2SgRtki
	 OjfEHbYJ0N+6ddvwlV642w+rlUwTQJ5ngnGzTgj51qvcxlg9bPNwz5KN7gch3/y9wY
	 iKWVWCvXxV8WHLpLQUMgKR+iDgLBdEkyUwwunjFL3LfUHbMCmOhwdSeXZT/NMGHcYm
	 zT4LqGYJMVqQKdyWKkoJt2M0YVcRGLOqrwkAr5+KyToFtSthkJ2Uvd7vW5Cci8rLNL
	 bU4mBP2GsvKFg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/29/19 7:28 AM, Christoph Hellwig wrote:
> No one ever checks this flag, and we could easily get that information
> from the page if needed.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

> ---
>   drivers/gpu/drm/nouveau/nouveau_dmem.c | 3 +--
>   include/linux/migrate.h                | 1 -
>   mm/migrate.c                           | 4 ++--
>   3 files changed, 3 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nouveau/nouveau_dmem.c
> index 6cb930755970..f04686a2c21f 100644
> --- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
> +++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
> @@ -582,8 +582,7 @@ static unsigned long nouveau_dmem_migrate_copy_one(struct nouveau_drm *drm,
>   			*dma_addr))
>   		goto out_dma_unmap;
>   
> -	return migrate_pfn(page_to_pfn(dpage)) |
> -		MIGRATE_PFN_LOCKED | MIGRATE_PFN_DEVICE;
> +	return migrate_pfn(page_to_pfn(dpage)) | MIGRATE_PFN_LOCKED;
>   
>   out_dma_unmap:
>   	dma_unmap_page(dev, *dma_addr, PAGE_SIZE, DMA_BIDIRECTIONAL);
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index 229153c2c496..8b46cfdb1a0e 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -166,7 +166,6 @@ static inline int migrate_misplaced_transhuge_page(struct mm_struct *mm,
>   #define MIGRATE_PFN_MIGRATE	(1UL << 1)
>   #define MIGRATE_PFN_LOCKED	(1UL << 2)
>   #define MIGRATE_PFN_WRITE	(1UL << 3)
> -#define MIGRATE_PFN_DEVICE	(1UL << 4)
>   #define MIGRATE_PFN_SHIFT	6
>   
>   static inline struct page *migrate_pfn_to_page(unsigned long mpfn)
> diff --git a/mm/migrate.c b/mm/migrate.c
> index dc4e60a496f2..74735256e260 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -2237,8 +2237,8 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
>   				goto next;
>   
>   			page = device_private_entry_to_page(entry);
> -			mpfn = migrate_pfn(page_to_pfn(page))|
> -				MIGRATE_PFN_DEVICE | MIGRATE_PFN_MIGRATE;
> +			mpfn = migrate_pfn(page_to_pfn(page)) |
> +					MIGRATE_PFN_MIGRATE;
>   			if (is_write_device_private_entry(entry))
>   				mpfn |= MIGRATE_PFN_WRITE;
>   		} else {
> 

