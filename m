Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BCFAC4646B
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 08:17:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E3CAA208E3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 08:17:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E3CAA208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6966A6B0006; Wed, 26 Jun 2019 04:17:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6474C8E0003; Wed, 26 Jun 2019 04:17:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 55C748E0002; Wed, 26 Jun 2019 04:17:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 084796B0006
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 04:17:12 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b21so2014041edt.18
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 01:17:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Crc3JYCat1na4haY4XsuFJ/g4+/vtbKUcMy3E+sx+3U=;
        b=gXi0ZrEpbxbnYWPn2KhOSHP50Jl8/63VCP4ncAwLQMGSGy+KNSxx715ZMDxWE4hNlW
         Wx67hea+nnzIbAlugaVYuZAb5GvqXXj/V4XJxx5Os6RP8ahbmPsPuzPnftN2D7uLgk0y
         fOjfSeTU580WJdPvegoAWAnpcBfh+jTLoZIoQUJQQ0mfaXGDEU3zPf+kRJZvdAa/YGiS
         B3NXwlw/Z5ckqht552WiBYYMica8p8kvAiDJaFY233i6byo26yipDZ0eXvJDLwsaQAGa
         qOf4LNm5LDk56c8pqGr95LKcZ+miRhr6fwdJDPYR7MpI6mzF2Ezi0HsScMqISjUjqKC4
         fRHA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAULs0f7pGke/e7NKdmLg9f/kC8UnWqiSgODM21VStqxrMs08aZ2
	VoJlwcovMMsbzm5zmRV6wq4p1W6sSzpRPR53lRZI67X8yYVQFnnKSthuz4EoEaka8959xztKuS/
	8j2V+HGLIdMFO2lh0cmeo9Wks79LwL2+e5IROzj6S6lPu06ceBJp5xXDhPq9DdJ/n+Q==
X-Received: by 2002:a17:906:959:: with SMTP id j25mr2805048ejd.94.1561537031610;
        Wed, 26 Jun 2019 01:17:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwbLiWuxFW6vn5lg3BVk15A8JYJVfTe4zCUQu+B43IDqIxhNyO5nam7LXi5nob/MEdsohZ/
X-Received: by 2002:a17:906:959:: with SMTP id j25mr2805002ejd.94.1561537030858;
        Wed, 26 Jun 2019 01:17:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561537030; cv=none;
        d=google.com; s=arc-20160816;
        b=qGA4WTaqnEsWld2qgDNgGfZRswMSozscuuE8A34HU2oXses33XlDXsiGQZQ8mlkVtw
         z0t1ZO88XJO42HjhBlDJHDUENccAwImaSQ13LPJ0DwuL2xVl3L9Oh/EtBZU7VppSfq07
         zEtxl+Llzt7/rzEop2GHOlvSiFjDFSAa+jd7VuDHi7u+wL9KAMaRXLeAkJzgvYemP714
         779KYNrlH1Oa/v79JZXl2/wHTgQXdWFUgaVtG8iDgDEI9rh0JzSioij1NjO46V/nieJJ
         x6Ds2hZNKEPhY+6jBu608IPRZwTjLSrcFaF89HbC6yNSCr5LoUFag79Q1UnR5KjYrlB2
         mcHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=Crc3JYCat1na4haY4XsuFJ/g4+/vtbKUcMy3E+sx+3U=;
        b=mUmWUpOFyyQRl3xHKFtrhKaaHWjp7yYDs9lCwyhIuyZ79MX//or3zwHoFM1AsJw8ny
         SnaLxtAzbOwdX8PgQ33dGTDVu/EVlcOtJ7Jogi9SHC2HprdLvY/8G6l8p2Z1nEYH9/+M
         VyeyjuOoYLZ5Fv3ycwzmTXLeWVJyUOsva4EYDkFDp9+AgYqxXgBU1O8bhJlTIts5c8oQ
         Bco4UR7FB8xlSz9peMOmBFzszBZtH2I8y6BKYrQ9fru/pzKq65roSPzGnWRU240rNdj6
         badl3YGbCYie1dXe+borqrjMevEtziSI662vZpEm6d3j61CXYDCno9oxyW8yTuZlOvvR
         wvZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id v1si2053432ejd.397.2019.06.26.01.17.10
        for <linux-mm@kvack.org>;
        Wed, 26 Jun 2019 01:17:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id EE1232B;
	Wed, 26 Jun 2019 01:17:09 -0700 (PDT)
Received: from [10.162.40.140] (p8cg001049571a15.blr.arm.com [10.162.40.140])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A38793F246;
	Wed, 26 Jun 2019 01:17:06 -0700 (PDT)
Subject: Re: [PATCH v2 4/5] mm,memory_hotplug: allocate memmap from the added
 memory range for sparse-vmemmap
To: Oscar Salvador <osalvador@suse.de>, akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, pasha.tatashin@soleen.com,
 Jonathan.Cameron@huawei.com, david@redhat.com, vbabka@suse.cz,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190625075227.15193-1-osalvador@suse.de>
 <20190625075227.15193-5-osalvador@suse.de>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <3056b153-20a3-ac86-4a49-c26f8be4b2a6@arm.com>
Date: Wed, 26 Jun 2019 13:47:32 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190625075227.15193-5-osalvador@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Oscar,

On 06/25/2019 01:22 PM, Oscar Salvador wrote:
> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
> index 93ed0df4df79..d4b5661fa6b6 100644
> --- a/arch/arm64/mm/mmu.c
> +++ b/arch/arm64/mm/mmu.c
> @@ -765,7 +765,10 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
>  		if (pmd_none(READ_ONCE(*pmdp))) {
>  			void *p = NULL;
>  
> -			p = vmemmap_alloc_block_buf(PMD_SIZE, node);
> +			if (altmap)
> +				p = altmap_alloc_block_buf(PMD_SIZE, altmap);
> +			else
> +				p = vmemmap_alloc_block_buf(PMD_SIZE, node);
>  			if (!p)
>  				return -ENOMEM;

Is this really required to be part of this series ? I have an ongoing work
(reworked https://patchwork.kernel.org/patch/10882781/) enabling altmap
support on arm64 during memory hot add and remove path which is waiting on
arm64 memory-hot remove to be merged first.

- Anshuman

