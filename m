Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50FDAC282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 14:38:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1AC4E21773
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 14:38:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1AC4E21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D9E2A6B0005; Wed, 17 Apr 2019 10:38:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D4C6B6B0006; Wed, 17 Apr 2019 10:38:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C63556B0007; Wed, 17 Apr 2019 10:38:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id A5CEB6B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 10:38:46 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id 75so20982508qki.13
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 07:38:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=Zd2vxpGRD//G2hwrb6LUIqC8BzYrlvsuY0Xwg35QEdA=;
        b=h+5Tu55UQ3OXRZstkl74Wp8uEe2OCHjnDSfwurh9tJauL+Q/eUxKbsNnrUIY2K0xoy
         SNjBnI4/OTQP3p/6E+fU3T6Lwfsv60EReGzWynpfX5MP12p89IGqgpasOUshMyqulbDD
         Gnvedm/caR7qk+AzITzdJCrFQqRPXtz30t/VCFAFYxcumpZm5zESQLOg4kKYyRIXJ33U
         SwyGCVe3OMQ01xW1esFyoAZbuq2p00qQ94fOSZ4YAzB4p7rN5c773ykGGhcJhf9lglH8
         LomXSAgHTTgNk5qmIOG8vc8eZCzoF8k+QsSBd2Yk2vrZ5aRGpnrmgllS3OAy7LTmjmQw
         OYuw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWyYsX34so/AdbyHsDzeTIiZoD4zK/n7BgS0uBkxCV0B+W3/L+G
	B5UTCTsc6c/BzgL6Ul2mtNjZuihsC8vNgez1MJffNB8G7EM5wHkAYVfgPmwhW3IhBXqt2KMQumx
	YsPDctzlDR5Z7iRJgvGqbLTzvabVqPEcqT97HkEocrLHW9aefxd1WgpER+SBlnmKOZw==
X-Received: by 2002:ac8:2deb:: with SMTP id q40mr69691288qta.272.1555511926392;
        Wed, 17 Apr 2019 07:38:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyACPOeD+1ZwGqCLGZyG4pAmZsWqUeY/782ZpC+nqdOIILsALYn6zxW5VRUxLcSOqhlXgRA
X-Received: by 2002:ac8:2deb:: with SMTP id q40mr69691247qta.272.1555511925791;
        Wed, 17 Apr 2019 07:38:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555511925; cv=none;
        d=google.com; s=arc-20160816;
        b=C0EvhBWX17ndODRHzlqxA79Sffw5HEo69yqaBWuYU+KL0ABqSFAskRKGUcnxoEz7wi
         NSdEVydFHH5fsqV31ywf/GLk9AMyTG8SuFFGvWFaNwXWwPVdarksf18FHUP5LkwW1UrG
         2csZpzodw77Emy8ACEBPVnqH/hRPFyocmYisfQ3wAfsu1KWZPqhxaeB+OKQJVO8iOLLf
         JvJtr5VNSOzbmkVCcnjEhYfalCOCPz8NUXw7YXGoYCFyF5llB3EADPm5EASGHr/YFFJQ
         rNm1+3eV/m2NfPt6rTFmQUffjir/roRG4wpyWAUNf6wPZ1ZyWYNZHvkk8E5Gxevwq0jq
         HEZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=Zd2vxpGRD//G2hwrb6LUIqC8BzYrlvsuY0Xwg35QEdA=;
        b=RgiCSoKvD0gBP3B74zObVL9z3B3yDnkAADsXRcrrqxGbhps1ThJON3eLBeyN8oPub/
         hO9coNTlR8PFOSPGeqec2WoKawVAnkMKhqVveu0uGUlJe9mhDT3F6Mq3+vcFy4gMYwuu
         5+zoevF38Kz7atuWGkZamCC4RtSctZfDm9hYdAfFpiMKyQS4+nvptMDOTR8mLsvnRfpR
         D210q5xmGOFSi7q1rUCG72IChhSlyHeOUwzlTauXZLmaiPIfdbu1heXwJeB00IXqV1+Z
         833NKjgWOEy6l1vSUEO35Q9p0eEJtimZ8cZ+3uVH/gsNCQyrZq/dCq9vQFjuuOGbap/D
         +NIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m47si6351678qvc.223.2019.04.17.07.38.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 07:38:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D50B93092678;
	Wed, 17 Apr 2019 14:38:44 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 544795D704;
	Wed, 17 Apr 2019 14:38:43 +0000 (UTC)
Date: Wed, 17 Apr 2019 10:38:41 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Yue Haibing <yuehaibing@huawei.com>
Cc: bskeggs@redhat.com, airlied@linux.ie, daniel@ffwll.ch, jgg@mellanox.com,
	rcampbell@nvidia.com, leonro@mellanox.com,
	akpm@linux-foundation.org, sfr@canb.auug.org.au,
	linux-kernel@vger.kernel.org, nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-mm@kvack.org
Subject: Re: [PATCH] drm/nouveau: Fix DEVICE_PRIVATE dependencies
Message-ID: <20190417143841.GD3229@redhat.com>
References: <20190417142632.12992-1-yuehaibing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190417142632.12992-1-yuehaibing@huawei.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Wed, 17 Apr 2019 14:38:45 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 10:26:32PM +0800, Yue Haibing wrote:
> From: YueHaibing <yuehaibing@huawei.com>
> 
> During randconfig builds, I occasionally run into an invalid configuration
> 
> WARNING: unmet direct dependencies detected for DEVICE_PRIVATE
>   Depends on [n]: ARCH_HAS_HMM_DEVICE [=n] && ZONE_DEVICE [=n]
>   Selected by [y]:
>   - DRM_NOUVEAU_SVM [=y] && HAS_IOMEM [=y] && ARCH_HAS_HMM [=y] && DRM_NOUVEAU [=y] && STAGING [=y]
> 
> mm/memory.o: In function `do_swap_page':
> memory.c:(.text+0x2754): undefined reference to `device_private_entry_fault'
> 
> commit 5da25090ab04 ("mm/hmm: kconfig split HMM address space mirroring from device memory")
> split CONFIG_DEVICE_PRIVATE dependencies from
> ARCH_HAS_HMM to ARCH_HAS_HMM_DEVICE and ZONE_DEVICE,
> so enable DRM_NOUVEAU_SVM will trigger this warning,
> cause building failed.
> 
> Reported-by: Hulk Robot <hulkci@huawei.com>
> Fixes: 5da25090ab04 ("mm/hmm: kconfig split HMM address space mirroring from device memory")
> Signed-off-by: YueHaibing <yuehaibing@huawei.com>

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
>  drivers/gpu/drm/nouveau/Kconfig | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/gpu/drm/nouveau/Kconfig b/drivers/gpu/drm/nouveau/Kconfig
> index 00cd9ab..99e30c1 100644
> --- a/drivers/gpu/drm/nouveau/Kconfig
> +++ b/drivers/gpu/drm/nouveau/Kconfig
> @@ -74,7 +74,8 @@ config DRM_NOUVEAU_BACKLIGHT
>  
>  config DRM_NOUVEAU_SVM
>  	bool "(EXPERIMENTAL) Enable SVM (Shared Virtual Memory) support"
> -	depends on ARCH_HAS_HMM
> +	depends on ARCH_HAS_HMM_DEVICE
> +	depends on ZONE_DEVICE
>  	depends on DRM_NOUVEAU
>  	depends on STAGING
>  	select HMM_MIRROR
> -- 
> 2.7.4
> 
> 

