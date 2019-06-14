Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36092C31E49
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 01:53:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1C4420B7C
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 01:53:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="M5oN6C8e"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1C4420B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C3FA6B000D; Thu, 13 Jun 2019 21:53:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 64DCA6B000E; Thu, 13 Jun 2019 21:53:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4ECAE6B0266; Thu, 13 Jun 2019 21:53:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 29DCB6B000D
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 21:53:20 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id e7so1207506ybk.22
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 18:53:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=wfrTohx7F8pzBumLpEjaUQ9N1cFt17QeYAZ9KiQw55o=;
        b=NhhAy4JuJjB7gbCAU15sUxqlIGowDl7+l0zV4CbnqpNhoymA2j/2tSZQUV6F909tnE
         eKL2WlKUUVK1agUIQm9eU+njVcNVDDaWR2Ar02tXRnTItinf93uFvEEMx+jfpnIThHuX
         XSq/R2QYjzCWmmI1a8es8E00LQHLsxFI/isRyhOv3CLmL8r295qxttNvo3VtDXgPZ8ig
         ycOJcPwkCqHSgELdd1Y7samFsMTHGltqt9Z0ru1XVBXY7/hdmeMnqo7pJupLByGkTlmD
         StLHjfmcaoXeyxEo+8LjyZFFgi0Wji1RfSANB35V+Nhtc9OjqAsSP49jEpgNOBxnIGn6
         guew==
X-Gm-Message-State: APjAAAWGFoh4wx4nHuTcmZOnDf0jt9Q4Xp66aIfqpWpRA3eNm+L9qDbl
	MEb5Kb00DUa0UKWGvE6IlELqAf+G8+nP86KvT779/Ru3S8xsIVxGffiAdRp1L7M9UQUOigBOZnJ
	rQxa5icwO57rsFOVEthiY7tLNf1GoshqfNgktTEmCdmX9fSF4uBUvyKUL35PcqCxzlw==
X-Received: by 2002:a0d:ecc5:: with SMTP id v188mr2844588ywe.154.1560477199917;
        Thu, 13 Jun 2019 18:53:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxBoeE15aoDQpeRMotc1YkPjh4W5EaqBgLPMARsx1ey4rIUGmnqpIykcajwtxvbvuRFQ4ph
X-Received: by 2002:a0d:ecc5:: with SMTP id v188mr2844577ywe.154.1560477199405;
        Thu, 13 Jun 2019 18:53:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560477199; cv=none;
        d=google.com; s=arc-20160816;
        b=ctr4lWUknUg6lCGlD5hUzO3p0yQuDoyV9MK/WCD8FxjMATSZ7twpouVZ2ahemUSSfL
         pGn1K9K8SXlH4zmO0ve5lxncEuKTQHhBvI5jN4iuEUsIKN5LWLu54+aqOmf8aGlU+HQV
         6w6q7CIpem75COJI6xwlQwi2RZah6g7fFJ3FlgQ5+1KT/+HlGnS/y8NlGkqeIsE3+TFX
         riEY0IInNP/kgf2yAnURLQQ9XXVk4rSSOscJgt94eGNygvQh4nqmg9NqLM/QwEbocY+T
         78rg6tzVLAiECZMfPxLOng0/He9sMGRON9+R9uDOKfyDaaFOFiVoIhHuPuz6k4d6T8dI
         JSuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=wfrTohx7F8pzBumLpEjaUQ9N1cFt17QeYAZ9KiQw55o=;
        b=fYCfPx6FwknWS5lMe6qYcWsbSZGGdfFxzB1C9LTk4KC05q+cftyNdT/6U9Ze+rSX/z
         /oI9Cf1v+j2ZKuH+5awySn+yxgJ97VWFWK2xaTJY8hOwkCr+Z2pRkv3d2yDoYEbQBwaM
         IuIXPBFxJubb8CtDc5yGqF9DjdP4AZTdRIAHa/9Yr/9Cu7vAB4csvH75UcGj8cjMGYZT
         hXAjeC1kB72iILE3H9RwmwfyLB5gI30M0Vi0yxPOVJe6u9K5ISqsLxFWLa72H0yMQKFf
         FUz6AHtOsOYrbKTemggSjCfoUKa0FeDgeC4lBWuVZQT4NHPCiootXKjAmk8eETSOVaTk
         xqTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=M5oN6C8e;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id 203si533409ywx.441.2019.06.13.18.53.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 18:53:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=M5oN6C8e;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d02fe0e0005>; Thu, 13 Jun 2019 18:53:19 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 13 Jun 2019 18:53:18 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 13 Jun 2019 18:53:18 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 14 Jun
 2019 01:53:15 +0000
Subject: Re: [Nouveau] [PATCH 22/22] mm: don't select MIGRATE_VMA_HELPER from
 HMM_MIRROR
To: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Jason Gunthorpe
	<jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>
CC: <linux-nvdimm@lists.01.org>, <linux-pci@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <dri-devel@lists.freedesktop.org>,
	<linux-mm@kvack.org>, <nouveau@lists.freedesktop.org>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-23-hch@lst.de>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <7f6c6837-93cd-3b89-63fb-7a60d906c70c@nvidia.com>
Date: Thu, 13 Jun 2019 18:53:15 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190613094326.24093-23-hch@lst.de>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1560477199; bh=wfrTohx7F8pzBumLpEjaUQ9N1cFt17QeYAZ9KiQw55o=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=M5oN6C8eycwH3ddNUoY7Cl0CYJ9M/JxsSi8COG6+zA3vleXm4hLAieJyd+Rnz+XkO
	 InXDP5bP6dg2R5z3V6QmIUAmqLRdfEEPnoHe11DQdqPOWEHe/dXotRaVsozwyC2/UP
	 xDBwMimCe618+axfU5Zd0Qi9Sdyc7jV9iEEzHuNuDhCf0KA4IYYIilK0/UogG1t7ci
	 H9FdBc2bPm+OVbr206w3w8msAwL3yKIwNn9F7Tj/HK8hN79yf7fVDe++57Ay62brrv
	 OTzs1WriOqHqdV4jj8ahLriHk1fr8Yt+cbZgV9a0zp+uG1qklpiRLsN8+Vm//XjXMt
	 Z2NZgCNIR4PKQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/13/19 2:43 AM, Christoph Hellwig wrote:
> The migrate_vma helper is only used by noveau to migrate device private
> pages around.  Other HMM_MIRROR users like amdgpu or infiniband don't
> need it.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  drivers/gpu/drm/nouveau/Kconfig | 1 +
>  mm/Kconfig                      | 1 -
>  2 files changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/gpu/drm/nouveau/Kconfig b/drivers/gpu/drm/nouveau/Kconfig
> index 66c839d8e9d1..96b9814e6d06 100644
> --- a/drivers/gpu/drm/nouveau/Kconfig
> +++ b/drivers/gpu/drm/nouveau/Kconfig
> @@ -88,6 +88,7 @@ config DRM_NOUVEAU_SVM
>  	depends on DRM_NOUVEAU
>  	depends on HMM_MIRROR
>  	depends on STAGING
> +	select MIGRATE_VMA_HELPER
>  	default n
>  	help
>  	  Say Y here if you want to enable experimental support for
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 73676cb4693f..eca88679b624 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -679,7 +679,6 @@ config HMM_MIRROR
>  	bool "HMM mirror CPU page table into a device page table"
>  	depends on MMU
>  	select MMU_NOTIFIER
> -	select MIGRATE_VMA_HELPER
>  	help
>  	  Select HMM_MIRROR if you want to mirror range of the CPU page table of a
>  	  process into a device page table. Here, mirror means "keep synchronized".
> 

For those who have out of tree drivers that need migrate_vma(), but are not
Nouveau, could we pretty please allow a way to select that independently?

It's not a big deal, as I expect the Nouveau option will normally be selected, 
but it would be nice. Because there is a valid configuration that involves 
Nouveau not being selected, but our driver still wanting to run.

Maybe we can add something like this on top of what you have?

diff --git a/mm/Kconfig b/mm/Kconfig
index eca88679b624..330996632513 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -670,7 +670,10 @@ config ZONE_DEVICE
          If FS_DAX is enabled, then say Y.
 
 config MIGRATE_VMA_HELPER
-       bool
+       bool "migrate_vma() helper routine"
+       help
+         Provides a migrate_vma() routine that GPUs and other
+         device drivers may need.
 
 config DEV_PAGEMAP_OPS
        bool



thanks,
-- 
John Hubbard
NVIDIA

