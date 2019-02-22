Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBF9BC4360F
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 22:42:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78E20206C0
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 22:42:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="Nc3wStqM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78E20206C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 188A18E0142; Fri, 22 Feb 2019 17:42:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 138608E0141; Fri, 22 Feb 2019 17:42:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F41BA8E0142; Fri, 22 Feb 2019 17:42:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id CDCD98E0141
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 17:42:10 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id 124so2417992ybl.10
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 14:42:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=mtXo/OgTrDWenFtgKz94DgciMW8dOaQHFFYZnjJ+Qp0=;
        b=Y9yeZweJX3N0kM2ycQIYSTdQJMjWjsFbYj7FAvgOW1q89ku6GFgL6uMs94gzgxAD2u
         o921jvPra1EkWsRWB5ODkAhK8ddPqDfAS6qH9XkGWS/kfNv+2dd4rza02J6T4TRYu0Br
         sAqcVGEBYckWcCzZPADocnBZi74gtit6VRsxDhFhRl/VJcNBkL7+RgN9i+eNr0wuszOA
         ElWQsDR2b8Ls+iaPbZh//UcQrCPmGAnd0URnl8Rv6n6tPOv+ZwdyNV/CJLQDpfU3NHFl
         xBpIYJ5QsO8ywDhraxlJT5tQXWM021TioN5FEk+3896plgeAaEzMW2sqidEvkaAg4QQR
         bMnA==
X-Gm-Message-State: AHQUAuaJA9ueKI50ncBawm68Ly7acIBYtVliHQeifVk+NQVV6M8Uordh
	4hlE5G668kyESKrw+ruT7qm8GUxr/lLi7Wckh609gVBl18ENHSWRfJXrtvNIccH/aEmSsug54Wq
	L1+TpJImuBsHLHGjIUuaVdKOcAPQM707zL7voNOjYR46oNlINKTKRi9GBva2UOfToig==
X-Received: by 2002:a81:71c5:: with SMTP id m188mr5375202ywc.353.1550875330519;
        Fri, 22 Feb 2019 14:42:10 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib7HRJanOk73hMiQxWzUZDgrb2kkK9c2PI53iX91hHzNpY9qNS4SrYjEVEAp61NUJo9XezH
X-Received: by 2002:a81:71c5:: with SMTP id m188mr5375161ywc.353.1550875329721;
        Fri, 22 Feb 2019 14:42:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550875329; cv=none;
        d=google.com; s=arc-20160816;
        b=AtptKMBOXRfNOqNwXC1KxqnYpaRwzKwdGSOcOMOAAN2jJ1SO/qyGSQHl0DXJa+ROeW
         fYpDnzcjv2ocl8SAQqzyM6VAN001PrxYZzZ3IYoNBVzGnlRdcfgxx2a8+zb/nbBhCmec
         f3IXWiy62bYQl/1dIqhv6qRe+5nwwfreJYfF9jVRel/oliHFwEJIw/K0+rcLNAa52bnn
         9wInOD5HbnvKy+CtlUSZBBYf/Q66sLEPhy/pKEFpz8v0uGgGunB28UGUWWxoQEGJpSWr
         nZ/2m4adJ+XdJWSRQHDWYO8M3nHp6u46wyqAalUwO7ylVz6/bdp5Ng3stWAhBblCWAS0
         Ee+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=mtXo/OgTrDWenFtgKz94DgciMW8dOaQHFFYZnjJ+Qp0=;
        b=x4VrlCSRpm6dtOTMMRebZvrNLBsleLOuqvbD+S9fEDwialBBlZxU/xZ1hF5AhitXDb
         OF9AT2cMote3dbPBDvpcI2BxwFYqT+1WN3BN4mpWvIT0/MurF6VccThJlPJzlgSLWjMH
         NXRlSduj7HlNy8/dKmVlFHZ/Qzw98LZU2FiOfKC1hI2Jr54HfPkeqB7I3hGlpGVCQOqE
         S+UfHBnEOHPQQi4wqJ7C/c+cZIyoNgsv/wtsqHDbiDJMi/7P0k8b1uQrfpfPjuiaKXWD
         HfQUpiB1DlL+gqYOr6y92XgXla6w5ITv1cVOIBBoKn14UVQTmS7N9ClZps4t4gQbFAsv
         /FwA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Nc3wStqM;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id j66si1235852ywc.423.2019.02.22.14.42.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 14:42:09 -0800 (PST)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Nc3wStqM;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c707abe0000>; Fri, 22 Feb 2019 14:42:06 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 22 Feb 2019 14:42:08 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 22 Feb 2019 14:42:08 -0800
Received: from rcampbell-dev.nvidia.com (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Fri, 22 Feb
 2019 22:42:08 +0000
Subject: Re: [PATCH v5 8/9] mm/mmu_notifier:
 mmu_notifier_range_update_to_read_only() helper
To: <jglisse@redhat.com>, <linux-mm@kvack.org>, Andrew Morton
	<akpm@linux-foundation.org>
CC: <linux-kernel@vger.kernel.org>, =?UTF-8?Q?Christian_K=c3=b6nig?=
	<christian.koenig@amd.com>, Joonas Lahtinen
	<joonas.lahtinen@linux.intel.com>, Jani Nikula <jani.nikula@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>, Jan Kara <jack@suse.cz>, Andrea
 Arcangeli <aarcange@redhat.com>, Peter Xu <peterx@redhat.com>, Felix Kuehling
	<Felix.Kuehling@amd.com>, Jason Gunthorpe <jgg@mellanox.com>, Ross Zwisler
	<zwisler@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Paolo Bonzini
	<pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>, John Hubbard <jhubbard@nvidia.com>,
	<kvm@vger.kernel.org>, <dri-devel@lists.freedesktop.org>,
	<linux-rdma@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>
References: <20190219200430.11130-1-jglisse@redhat.com>
 <20190219200430.11130-9-jglisse@redhat.com>
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <9da5e3b9-7f4a-49ee-bf80-024e5aed20a1@nvidia.com>
Date: Fri, 22 Feb 2019 14:42:08 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.0
MIME-Version: 1.0
In-Reply-To: <20190219200430.11130-9-jglisse@redhat.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1550875326; bh=mtXo/OgTrDWenFtgKz94DgciMW8dOaQHFFYZnjJ+Qp0=;
	h=X-PGP-Universal:Subject:To:CC:References:From:Message-ID:Date:
	 User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=Nc3wStqMc92w+r1iPlq9rgZ+vhAdWvC7XW8dkhwHHCmx+cNeaVKN6yWaoSYkFGqvT
	 uhymWbKVsZcyJTFIgkUtdKMW/Tsuv33gN/wOITb98h85ko32ucaIGihP8IVsWu63e+
	 RLiXSb3H/jUiJzFLcXYhasBMoZ4g7EP2Tp1xfl0aq1qDPn4bEwy8XsCtD5FknLXjCx
	 S/Ipg5VGk57i+O7iRu0wRw+y7pSIDnIzcLzfrQz7q0vQ0X4njJ7g8SGd51l5tKEN25
	 Wioa0sixuhaYxOZPKygwhRvB0YPxY2SUyYImiqOF25igrTWAzBCLUYZ2vfJlAi2rRs
	 M8uWU0XGYlSmQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2/19/19 12:04 PM, jglisse@redhat.com wrote:
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>=20
> Helper to test if a range is updated to read only (it is still valid
> to read from the range). This is useful for device driver or anyone
> who wish to optimize out update when they know that they already have
> the range map read only.
>=20
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Christian K=C3=B6nig <christian.koenig@amd.com>
> Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
> Cc: Jani Nikula <jani.nikula@linux.intel.com>
> Cc: Rodrigo Vivi <rodrigo.vivi@intel.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Peter Xu <peterx@redhat.com>
> Cc: Felix Kuehling <Felix.Kuehling@amd.com>
> Cc: Jason Gunthorpe <jgg@mellanox.com>
> Cc: Ross Zwisler <zwisler@kernel.org>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Cc: Radim Kr=C4=8Dm=C3=A1=C5=99 <rkrcmar@redhat.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Christian Koenig <christian.koenig@amd.com>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: kvm@vger.kernel.org
> Cc: dri-devel@lists.freedesktop.org
> Cc: linux-rdma@vger.kernel.org
> Cc: Arnd Bergmann <arnd@arndb.de>
> ---
>   include/linux/mmu_notifier.h |  4 ++++
>   mm/mmu_notifier.c            | 10 ++++++++++
>   2 files changed, 14 insertions(+)
>=20
> diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
> index 0379956fff23..b6c004bd9f6a 100644
> --- a/include/linux/mmu_notifier.h
> +++ b/include/linux/mmu_notifier.h
> @@ -259,6 +259,8 @@ extern void __mmu_notifier_invalidate_range_end(struc=
t mmu_notifier_range *r,
>   				  bool only_end);
>   extern void __mmu_notifier_invalidate_range(struct mm_struct *mm,
>   				  unsigned long start, unsigned long end);
> +extern bool
> +mmu_notifier_range_update_to_read_only(const struct mmu_notifier_range *=
range);
>  =20
>   static inline bool
>   mmu_notifier_range_blockable(const struct mmu_notifier_range *range)
> @@ -568,6 +570,8 @@ static inline void mmu_notifier_mm_destroy(struct mm_=
struct *mm)
>   {
>   }
>  =20
> +#define mmu_notifier_range_update_to_read_only(r) false
> +
>   #define ptep_clear_flush_young_notify ptep_clear_flush_young
>   #define pmdp_clear_flush_young_notify pmdp_clear_flush_young
>   #define ptep_clear_young_notify ptep_test_and_clear_young
> diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
> index abd88c466eb2..ee36068077b6 100644
> --- a/mm/mmu_notifier.c
> +++ b/mm/mmu_notifier.c
> @@ -395,3 +395,13 @@ void mmu_notifier_unregister_no_release(struct mmu_n=
otifier *mn,
>   	mmdrop(mm);
>   }
>   EXPORT_SYMBOL_GPL(mmu_notifier_unregister_no_release);
> +
> +bool
> +mmu_notifier_range_update_to_read_only(const struct mmu_notifier_range *=
range)
> +{
> +	if (!range->vma || range->event !=3D MMU_NOTIFY_PROTECTION_VMA)
> +		return false;
> +	/* Return true if the vma still have the read flag set. */
> +	return range->vma->vm_flags & VM_READ;
> +}
> +EXPORT_SYMBOL_GPL(mmu_notifier_range_update_to_read_only);
>=20

Don't you have to check for !WRITE & READ?
mprotect() can change the permissions from R/O to RW and
end up calling mmu_notifier_range_init() and=20
mmu_notifier_invalidate_range_start()/end().

I'm not sure how useful this is since only applies to the
MMU_NOTIFY_PROTECTION_VMA case.
Anyway, you can add

Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

