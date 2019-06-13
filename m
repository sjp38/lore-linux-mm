Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C23FC31E4A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 19:53:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB33D2133D
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 19:53:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="fX5tey0o"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB33D2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66D466B000A; Thu, 13 Jun 2019 15:53:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 61F2B6B000C; Thu, 13 Jun 2019 15:53:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 50DCC8E0001; Thu, 13 Jun 2019 15:53:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 333516B000A
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 15:53:08 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id v205so19987ywb.11
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 12:53:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=Jb4g90Z1ba65oKYjTxGpf+f/32abJWQiXQLuIbWbzvY=;
        b=TOOEGRFUDQmAb+Uj4Oci+ai3qQ9IZO5LYpal2/erHFP7o1ncspE1EWjXxSaF57XuQk
         aBehKSOAmnA21oulblNolKqZhUZy6IVaE2FkpGnNxZx/fqnxTkL3vpPcPjRylqoF+E0o
         W/500CuPLxs7Aay6oSxjuMbVhnhIzFbgP1doZgd8/kU5u76zRAEmfJwGtAsIzVmExU04
         +oL+1OLlogAFLbbh0kE1fMcf5+zDL5LXum19TNOynuHJ1tIjoRYfBwAsihPwujQC5PG6
         ED45gUj10urKmiZeK3WCr8En9+hNlPexxkKcmYbFrCa5qTFfhMWY5fmIlUMFWmdJb0Pr
         7dig==
X-Gm-Message-State: APjAAAWPd5pdERr13izFPV/QwBhpmz0FNSb4f2D3dsebftPAoPY+K274
	MwYs2ClQ6DO9aQbvNaSsOlHQnnErLBc44oZeNw9quYXmZpDYsLL+jCHMmtV6/pegY/cptHw2oVh
	Nicq03Dj6ChDxjBpUnBVlZ/NbFzHO8Dpfe2C7h89DJEMmwRN0HN3xHu0KFDmtxAhdvQ==
X-Received: by 2002:a81:3a46:: with SMTP id h67mr44901155ywa.455.1560455587936;
        Thu, 13 Jun 2019 12:53:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxeXPhoQVSWXd9+o1p7zZ9gYAVq8oh6foVvM0nfEqG37qOFcR7qD/2nleRU+b+qbfBhdscf
X-Received: by 2002:a81:3a46:: with SMTP id h67mr44901142ywa.455.1560455587397;
        Thu, 13 Jun 2019 12:53:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560455587; cv=none;
        d=google.com; s=arc-20160816;
        b=GrO6cpNIDA+l3d1wnSiasn1xwsv4+GI72a6DNdRaSH6ISRx86+im5hRz6p/vQX5bDq
         tBhiOc0iWAVae8XZTLnJGbCgzTXWogQWSl0hc03kWURkPtHuxvXaQELluAOprm4fS/6n
         nJZ4fjZqo1mP7xqUxFj32eaWn6j4Y3+1IzUmCIwisP8oVTijuIqe4aRMaa9PiYsHV36r
         8swLvdjh0lLLWPyJS+s0IH57arxHLC9ZjkEyhbqSbQEfQG1Q5WX06JiR+XWExBnoueeK
         MS5C1799Pelr+iggz9qCfsALRoBjPEoZOueS3l0piNtsfRgB++eJ0Sli85Zl1leu2QmA
         Pgog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=Jb4g90Z1ba65oKYjTxGpf+f/32abJWQiXQLuIbWbzvY=;
        b=q5W7N6e9XcjYTfTLEbUJ8Oqf08Ax+ueDMbL7Dmt7dSOOMihkZ5eP88ccAJjk2pgJ+a
         WbHHihrAJpgIwt12c+6QlU/Cq3xewLEJ8Rrskm/0llkHHWnylYLWdINNsVC/X7ceRj74
         RzmefSt4vHrD97TaDFU4craEscvmB7/VMJ1/jaPFnmzH7SxeRBjlrzUfldPmd+RzZNyr
         Vh3wWB9I52RgD9X+6Eh1HbbwMycSnUmLuCeB1zIF1XJ8UNFCYX9Wti+xJWqKMiA55yxW
         5OJljGMwaXTeaqNJKy4gq+16jmDYGSlfJIf9c8ebo9lzKsLc7s7M9T0zn+HTQXFXxcag
         Y3sA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=fX5tey0o;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id n130si241868yba.172.2019.06.13.12.53.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 12:53:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=fX5tey0o;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d02a9a20000>; Thu, 13 Jun 2019 12:53:06 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Thu, 13 Jun 2019 12:53:06 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Thu, 13 Jun 2019 12:53:06 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 13 Jun
 2019 19:53:02 +0000
Subject: Re: [PATCH 18/22] mm: mark DEVICE_PUBLIC as broken
To: Jason Gunthorpe <jgg@mellanox.com>, Christoph Hellwig <hch@lst.de>
CC: Dan Williams <dan.j.williams@intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "nouveau@lists.freedesktop.org"
	<nouveau@lists.freedesktop.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "linux-nvdimm@lists.01.org"
	<linux-nvdimm@lists.01.org>, "linux-pci@vger.kernel.org"
	<linux-pci@vger.kernel.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-19-hch@lst.de> <20190613194430.GY22062@mellanox.com>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <a27251ad-a152-f84d-139d-e1a3bf01c153@nvidia.com>
Date: Thu, 13 Jun 2019 12:53:02 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190613194430.GY22062@mellanox.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1560455586; bh=Jb4g90Z1ba65oKYjTxGpf+f/32abJWQiXQLuIbWbzvY=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=fX5tey0oBNTieShQOoS4gHfsvizLQIZuWaHc6dzOwFFJidyDqIYU2AUhp266HRFrN
	 XrtOPBnaSUAKElzDHFexziLEsf0mgRvYpwoaL4sSYsIU1LcKrpDAHjizgl/yJjcdl3
	 p6Pf6shBbCxBVGLYCn7p1Sc7R72zptzPvDHZbEr82hLm46tnMp65GrRnZ3EbGnwLJz
	 23lgDPGqY/fbBOf3AXToJKAO/Z8B9A4BRpstqapMwDkQOz+kz4JCB2SNVDQH0ir2MJ
	 WzkLVK43aAga/2HoikuGF1iJ+5COBwso/r1BhSmM63r0HyIcQnSmXduf+EERM53rtq
	 kwroL2mZCH2Jw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 6/13/19 12:44 PM, Jason Gunthorpe wrote:
> On Thu, Jun 13, 2019 at 11:43:21AM +0200, Christoph Hellwig wrote:
>> The code hasn't been used since it was added to the tree, and doesn't
>> appear to actually be usable.  Mark it as BROKEN until either a user
>> comes along or we finally give up on it.
>>
>> Signed-off-by: Christoph Hellwig <hch@lst.de>
>>   mm/Kconfig | 1 +
>>   1 file changed, 1 insertion(+)
>>
>> diff --git a/mm/Kconfig b/mm/Kconfig
>> index 0d2ba7e1f43e..406fa45e9ecc 100644
>> +++ b/mm/Kconfig
>> @@ -721,6 +721,7 @@ config DEVICE_PRIVATE
>>   config DEVICE_PUBLIC
>>   	bool "Addressable device memory (like GPU memory)"
>>   	depends on ARCH_HAS_HMM
>> +	depends on BROKEN
>>   	select HMM
>>   	select DEV_PAGEMAP_OPS
> 
> This seems a bit harsh, we do have another kconfig that selects this
> one today:
> 
> config DRM_NOUVEAU_SVM
>          bool "(EXPERIMENTAL) Enable SVM (Shared Virtual Memory) support"
>          depends on ARCH_HAS_HMM
>          depends on DRM_NOUVEAU
>          depends on STAGING
>          select HMM_MIRROR
>          select DEVICE_PRIVATE
>          default n
>          help
>            Say Y here if you want to enable experimental support for
>            Shared Virtual Memory (SVM).
> 
> Maybe it should be depends on STAGING not broken?
> 
> or maybe nouveau_svm doesn't actually need DEVICE_PRIVATE?
> 
> Jason

I think you are confusing DEVICE_PRIVATE for DEVICE_PUBLIC.
DRM_NOUVEAU_SVM does use DEVICE_PRIVATE but not DEVICE_PUBLIC.

