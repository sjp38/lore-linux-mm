Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F857C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 19:01:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E0B2720657
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 19:01:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="YPy7Q3OM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E0B2720657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 84B5F8E012F; Fri, 22 Feb 2019 14:01:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 821478E0123; Fri, 22 Feb 2019 14:01:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E9F78E012F; Fri, 22 Feb 2019 14:01:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3FBF48E0123
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 14:01:04 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id o8so2035511ybp.1
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 11:01:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=x3ep/Gi+sTbOk9gLW6cFVFGUmrcJKXma0tiO4b4QgOg=;
        b=gjP9bBuOH+kb9IFZLU/+kbbdVWFkj0yufSJi5lwETQYfMs4WGzzinffHD0HeduVMow
         r5M1pOIc1vJ3hMFErydW3XY8iOVrZxKU8+4J+pEW9hjr+I5PXvHsfW848IbFW+dDDwi+
         ctUXeVj9/kit1qdKASaa450t/y2DdJN4LLogAT5pSqPo42xJfbRL6uGlEOEx+Wz/zbdI
         M4M2vz4yvUC3c0j14B+y2pQ47VuJsE13Ah3RWLXKX4q5oZNAaJ9++wWu044SjwXTg43I
         79F8IAmhERf0dUMupVjukte3duBbyA7xgM48+Ks6J35vfM4XxefEebZyjiroqHYMJerv
         GPHA==
X-Gm-Message-State: AHQUAub62AgatIOaOf7zewiuLtbkfqv/B02cOB4OkIj/GwPAT7htySPa
	Spri/iGRmYmCduPtuKq7SGAaCdbvafg0x58Z6X3ASJiPxKbjcDYgDJUK39lyZjgVoIAodZhZIFf
	BTR7tiKsu64cFDXzWvW/to8I+W23DZ9f6208LAQMDtQyBw6cJadGRU2vnV7L9o1XJdA==
X-Received: by 2002:a25:9c42:: with SMTP id x2mr4438381ybo.199.1550862063933;
        Fri, 22 Feb 2019 11:01:03 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYt4ovSV1LD/JDxcP2IumvVdvRGDk1jLJxM3k3wJBeyfl+XPuuQS7OGk22epPcEOsl9uqrG
X-Received: by 2002:a25:9c42:: with SMTP id x2mr4438305ybo.199.1550862063077;
        Fri, 22 Feb 2019 11:01:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550862063; cv=none;
        d=google.com; s=arc-20160816;
        b=D4jk7PDmmQpkWqcm3JXHutMzqqZngeJOtj/yD3Gy53sF37oKu1gt5SBKuVj07KKTDf
         7VaLcme3S4/n8Qhy8hiaakrc4OleLmeBblNPeAW9jSZDxa+kbxDRrA+j3vU8c0cIe6HB
         SA4o2LafCZKkkiq0Mz5xXaXzjGlbFpRYMUFlAHy8bv9Bq+1quGTsnOFgMyJ/ZsknjkxJ
         D1Ms1bDEGwJzqBADcrqLkDxKNleTlm/Qk0PiDZ5ahVcnjFKxQURrm6IPIijwtfo6iwYe
         WuefEgq98nbce0/OKI2enTIx/vVJt0vXFgnnWXsw3hE60xhNhTFnrZrYTAJJo6bsNKxk
         I7oA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=x3ep/Gi+sTbOk9gLW6cFVFGUmrcJKXma0tiO4b4QgOg=;
        b=UlYMS7wwZy7xWrYK0yMIvLjw46ylHtzAYTN2u+f2/DyVFHQc0beQCBhi5eNtPqB2N/
         uAf76IKCmz3kjGSSQr5sUgRMX8it4QSXOIR4r+AAW/LL1V1VkRjrGzAcgKOZFxTeIPCz
         sgy20JM+DwTZArDqNFRjeI57BciTlg25bqUzQVGMU2a5Kf4fEBKsrNUPRafbGXz82ijx
         F0MW9bgObfSSuXifQEaKGeUOM+Jwx8JqUTtJKqrL+ujMDw9e9EYmedAfMlPROvbCrvZG
         qtmYIjvUUxsIzKWuyQg5H/KpA5TzP3k6c6RSKWb4sBX0f93+uweGAOxwYbJtLv2h+9JI
         MMkg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=YPy7Q3OM;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id l1si1314070ywm.40.2019.02.22.11.01.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 11:01:03 -0800 (PST)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=YPy7Q3OM;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c7046eb0002>; Fri, 22 Feb 2019 11:01:00 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Fri, 22 Feb 2019 11:01:02 -0800
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Fri, 22 Feb 2019 11:01:02 -0800
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Fri, 22 Feb
 2019 19:01:01 +0000
Subject: Re: [PATCH v5 1/9] mm/mmu_notifier: helper to test if a range
 invalidation is blockable
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
	<linux-rdma@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>, Arnd Bergmann
	<arnd@arndb.de>
References: <20190219200430.11130-1-jglisse@redhat.com>
 <20190219200430.11130-2-jglisse@redhat.com>
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <db289f99-3b47-1af6-cbfb-a15155c382c6@nvidia.com>
Date: Fri, 22 Feb 2019 11:01:01 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.0
MIME-Version: 1.0
In-Reply-To: <20190219200430.11130-2-jglisse@redhat.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1550862060; bh=x3ep/Gi+sTbOk9gLW6cFVFGUmrcJKXma0tiO4b4QgOg=;
	h=X-PGP-Universal:Subject:To:CC:References:From:Message-ID:Date:
	 User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=YPy7Q3OMR8x41jv2A+iuoBr/NEseguMVKb+xW4/BDY4vP1uynrzZVXtz7+vwpM0pz
	 Z/LQ2s6yAsC0aqxH7hKB6PjUog2hYAlv4K8t1r3RbU01x874oUNH2UqLURkDAJsU7s
	 B7DLZ1FeBqXJzAZTTCj0VKnGkHzhW11xY3osITv6Eb92BvzgpmCb2rltVgZb2g+XA6
	 AE8qO3v6CnAX5iQGjGqzGCJU4mfd1LX4fPrNL8V+VZffI4zZg8m1uA9BlgARC/LKio
	 ufrKrUUb7kcM/5Tr73O5hPzWqT1VfVbH8kLc2sf8I6ExkxpreHxsqNxyggmViUJIdD
	 uMbIo5Ay2VvHQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2/19/19 12:04 PM, jglisse@redhat.com wrote:
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>=20
> Simple helpers to test if range invalidation is blockable. Latter
> patches use cocinnelle to convert all direct dereference of range->
> blockable to use this function instead so that we can convert the
> blockable field to an unsigned for more flags.
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
> Cc: Andrew Morton <akpm@linux-foundation.org>
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
> Cc: linux-fsdevel@vger.kernel.org
> Cc: Arnd Bergmann <arnd@arndb.de>
> ---
>   include/linux/mmu_notifier.h | 11 +++++++++++
>   1 file changed, 11 insertions(+)
>=20
> diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
> index 4050ec1c3b45..e630def131ce 100644
> --- a/include/linux/mmu_notifier.h
> +++ b/include/linux/mmu_notifier.h
> @@ -226,6 +226,12 @@ extern void __mmu_notifier_invalidate_range_end(stru=
ct mmu_notifier_range *r,
>   extern void __mmu_notifier_invalidate_range(struct mm_struct *mm,
>   				  unsigned long start, unsigned long end);
>  =20
> +static inline bool
> +mmu_notifier_range_blockable(const struct mmu_notifier_range *range)
> +{
> +	return range->blockable;
> +}
> +
>   static inline void mmu_notifier_release(struct mm_struct *mm)
>   {
>   	if (mm_has_notifiers(mm))
> @@ -455,6 +461,11 @@ static inline void _mmu_notifier_range_init(struct m=
mu_notifier_range *range,
>   #define mmu_notifier_range_init(range, mm, start, end) \
>   	_mmu_notifier_range_init(range, start, end)
>  =20
> +static inline bool
> +mmu_notifier_range_blockable(const struct mmu_notifier_range *range)
> +{
> +	return true;
> +}
>  =20
>   static inline int mm_has_notifiers(struct mm_struct *mm)
>   {

Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

