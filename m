Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 864B5C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 22:08:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 341552077B
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 22:08:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="hYe8t4t6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 341552077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 832598E013E; Fri, 22 Feb 2019 17:08:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E1558E0137; Fri, 22 Feb 2019 17:08:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D03B8E013E; Fri, 22 Feb 2019 17:08:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 47BF78E0137
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 17:08:07 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id 4so2373140ybx.9
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 14:08:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=c6gjUvJdtuDPbgDm3cSS4FUPb8+FP6+GXo3xKSKYPas=;
        b=PoNDIOOsctVMDZohkBtbKvmiIzjB1AJWhXbpA47K3q4Kid5Ssq+P5sMLcuCOxi7j69
         EhECnNnpZ8LCh2M8Fe/v9tRcbPfdQX+Dz+t1G86/myuHT6FF7agH/kvSs4NplkNrShFV
         PXjlTKHyvKQxddLJ5p4a/mY3uz/wckwex55c9lJNQxJQik4UWC+VD+g8f06h4WunxTE6
         x34uh41mcwV75Fw/P5MtRSScgWafATOQSOrxKrkvrHWURMqBHw08Q+3bVfAhpmeAFtLH
         cArFu4DVUDx8JFS1z45Pup2zAtQeB5TIe5yJWRrn0n01hivpsIUMkgpscmmOr7yDDWsN
         lPkg==
X-Gm-Message-State: AHQUAub1KpzsoANpzJS4d3gh2OAzvYR22sXEztGRFakC1A4Ecq6crcQu
	i4dC7ieR2doW47FdJt7cMO5amuARfNwRov5smebiYVrBg+YEZBMuBhd4TJVY7bwGPxYyLXKBqa6
	MnFfDcvAf1ipKeqB3+IQbM+WfNAyUNUHo2o690XnDQBp9BvFImBdGvAXSu1s+5t19dQ==
X-Received: by 2002:a81:5503:: with SMTP id j3mr5302947ywb.355.1550873287025;
        Fri, 22 Feb 2019 14:08:07 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYYw90pc9rnO6SITMzMkl57z1Jpi/Ds3mriGnlk9hLFRS1qQ85FpHp6zCNuTjEjiFLQAwbd
X-Received: by 2002:a81:5503:: with SMTP id j3mr5302900ywb.355.1550873286242;
        Fri, 22 Feb 2019 14:08:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550873286; cv=none;
        d=google.com; s=arc-20160816;
        b=xmxWZXrbHuocOVm/5yLO0POamxeL+cNJb2bFcgeJVLLM4hvzpb/yDLxlK4sds1MB/N
         DPsZbi8kl+BDaPxRBCqmSArxiMCtPOT3/Rf0vn3K7XFin9QHART3u4ZGUg0AIlWOr1e6
         t2Y12M+CiD/tJd4S21Go7QrSQ3VES8mNudZcf8bi+F0WzaWYcu6ZlUOcL5W/Jp2p2pRN
         cK4zccCKFlrTwHNRBaLActY9DQZlAVOikxAdJchzNVeATqKQx8VehDwvuOZbU0QlqyGo
         UeVQtucTnCgwISqf2l4NL9gbVl86CukXuL9ug22X+wDOQD6BvLPmadJQjauktSSdxalN
         HGeQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=c6gjUvJdtuDPbgDm3cSS4FUPb8+FP6+GXo3xKSKYPas=;
        b=z7PAjG6ErBuUurq14tIqVn9wLaU0qGtqx33xH1B7XZYgzpmLA8oeZFLaHfEeqc54n9
         YvjfYeJdcE/lifh9YhzTIBt9dOX6PiLO4WRdiRorPQUmB//zB/HFsQbAWWnEVoprP+WK
         ENAFJvH3BSvn4gXEeChOfw3Nex0+BFeZgNF5RPZbL3RIQwS5VMjJmj6EbFALW4jLkjfc
         TRdM5YAOsOkOjVTKetku9/jfItbKcu8kocJpSRlsm/Q9z/7P306JBVl+dm5y779ltPnu
         umH3ckT41osM0kVrXU9ezaIZbyLjIDVyMAZqZBA7GDTvjUjoCXR2YHcfxpidTB/KAtZP
         PGgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=hYe8t4t6;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id y11si1541863ybp.153.2019.02.22.14.08.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 14:08:06 -0800 (PST)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=hYe8t4t6;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c7072cd0000>; Fri, 22 Feb 2019 14:08:13 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 22 Feb 2019 14:08:05 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 22 Feb 2019 14:08:05 -0800
Received: from rcampbell-dev.nvidia.com (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Fri, 22 Feb
 2019 22:08:04 +0000
Subject: Re: [PATCH v5 7/9] mm/mmu_notifier: pass down vma and reasons why mmu
 notifier is happening v2
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
 <20190219200430.11130-8-jglisse@redhat.com>
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <176dfe29-e7ca-632f-5d65-551ac2ee9ec4@nvidia.com>
Date: Fri, 22 Feb 2019 14:08:04 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.0
MIME-Version: 1.0
In-Reply-To: <20190219200430.11130-8-jglisse@redhat.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1550873293; bh=c6gjUvJdtuDPbgDm3cSS4FUPb8+FP6+GXo3xKSKYPas=;
	h=X-PGP-Universal:Subject:To:CC:References:From:Message-ID:Date:
	 User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=hYe8t4t6dhUmcR4NBgSyeLqKjhrdU8uR+WitbPZdxTqShufo43Th9neByTvHRG4EJ
	 WtUp1XkSwH16AEt+KyGnfE3KeiQWZSi0akoZU528zh5x1c9jO/ujtv6fUMtWF+GEwS
	 o3ftp/u62CzsilZNA2W0d7sAI6k0+gI9NVb2uunB9ndpK8USOxULXp0dcu0vvEpWlR
	 SG5xPtuYaD74T+XM/W3rI7Mkn+3+CW3YHr57TKrQFMjytqpu3S32JBfxvYl7d5jGc3
	 uKv1HEOpHOzblQOBTG2OXMEY1d3Vm5l0nZQEr8QFdz3UT28Lk82b6KBfAk9GzGlxe9
	 Rg2T8U/x+l3uQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2/19/19 12:04 PM, jglisse@redhat.com wrote:
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>=20
> CPU page table update can happens for many reasons, not only as a result
> of a syscall (munmap(), mprotect(), mremap(), madvise(), ...) but also
> as a result of kernel activities (memory compression, reclaim, migration,
> ...).
>=20
> Users of mmu notifier API track changes to the CPU page table and take
> specific action for them. While current API only provide range of virtual
> address affected by the change, not why the changes is happening
>=20
> This patch is just passing down the new informations by adding it to the
> mmu_notifier_range structure.
>=20
> Changes since v1:
>      - Initialize flags field from mmu_notifier_range_init() arguments
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
>   include/linux/mmu_notifier.h | 6 +++++-
>   1 file changed, 5 insertions(+), 1 deletion(-)
>=20
> diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
> index 62f94cd85455..0379956fff23 100644
> --- a/include/linux/mmu_notifier.h
> +++ b/include/linux/mmu_notifier.h
> @@ -58,10 +58,12 @@ struct mmu_notifier_mm {
>   #define MMU_NOTIFIER_RANGE_BLOCKABLE (1 << 0)
>  =20
>   struct mmu_notifier_range {
> +	struct vm_area_struct *vma;
>   	struct mm_struct *mm;
>   	unsigned long start;
>   	unsigned long end;
>   	unsigned flags;
> +	enum mmu_notifier_event event;
>   };
>  =20
>   struct mmu_notifier_ops {
> @@ -363,10 +365,12 @@ static inline void mmu_notifier_range_init(struct m=
mu_notifier_range *range,
>   					   unsigned long start,
>   					   unsigned long end)
>   {
> +	range->vma =3D vma;
> +	range->event =3D event;
>   	range->mm =3D mm;
>   	range->start =3D start;
>   	range->end =3D end;
> -	range->flags =3D 0;
> +	range->flags =3D flags;
>   }
>  =20
>   #define ptep_clear_flush_young_notify(__vma, __address, __ptep)		\
>=20

Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

