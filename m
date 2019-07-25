Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D104EC76190
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 17:53:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8F8D0229F3
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 17:53:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="DhAx15tD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F8D0229F3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 11C9D6B000D; Thu, 25 Jul 2019 13:53:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A7188E0003; Thu, 25 Jul 2019 13:53:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E89358E0002; Thu, 25 Jul 2019 13:53:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id C339A6B000D
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 13:53:56 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id a9so1912736ybl.1
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 10:53:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=C/3jo0jsE8wFgw2iplq9k3+bvhgHMroF2GYfUpuZsE0=;
        b=RyC4tiaYl8lZck7rWfAXT8sWw53R+s97OCquQ552yH9EE1vFAqLbp59mmGSOUWT7Ju
         caeAlhmWIxaucnJG/NeA8HMXuxf9aELtqiVza2haVgbYlP+M5bi4JGaAr8RMX8XOo0aS
         1uCMnXI2zKGTG36aQqQzrr26z2LqJPvGxatiBodvJdhw3W1f9TE5joymJo7ogszse4KD
         vYBladLq/4QVIbYm4iX1O7cfvzGlWPxtW88ddSpnxvMBeBaosq/L3djcdFCavx9b5Y8p
         CHbmWivExt+mr89GDgYwpt87DoTai3niv9PZhnqML/zGeZ+/wC//XHZ9IuvRLOYrqKQm
         z8rw==
X-Gm-Message-State: APjAAAVVLAKucwnE/hyh+BP7sWCQ7nr3A/oZFWjqEGM+rJqomtGIj8qB
	AnZMluTYkMCzO73ro7OAHkXsG7hBKFvGyhnfhi4gEirQlSO7b//uE1FIVQfwWT2PhcZa9tIY2Kf
	Ta1o0wRtdBA02CRFBa6zv47bFP0gqILPTlYz3I8BdSJHZZU/uEud7NI+khjBKfnwOgQ==
X-Received: by 2002:a25:6586:: with SMTP id z128mr53420638ybb.5.1564077236470;
        Thu, 25 Jul 2019 10:53:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydzp3z7tVnfv4q+ds2XJHhwA8PDIv/uAPkQEtElaXbITGtti5Cchuxowu/BDt/a79z+9XZ
X-Received: by 2002:a25:6586:: with SMTP id z128mr53420604ybb.5.1564077235849;
        Thu, 25 Jul 2019 10:53:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564077235; cv=none;
        d=google.com; s=arc-20160816;
        b=RIEIe2QN6cZmZOmKOHDOlB1KJ0GaysSjXVKQ+K1qxemucRFKXCnIO/kyS3sJhf7zz5
         yHUgVcCwDx1JQLrMpSjen5GwifWI9+/OcMS7+oivmFN7dtsRhsE2jzSWrcCJXJ6VVdVQ
         I9qK9FrGbtQBasRy7/u6gTX61PdJhs0UEzmfEbivYqKWlXX4hw0sw/ykQJ4TC7tThqi5
         ec4usraZnbOuE4CQ7rt7tJU5eF5eR2M+qRtmT48OTke+4A90SAK5jK1ARCBPgzCzgtpc
         ib6vNxevL1dtssd1W3DBxx9eT7J50pTMt08Ld2UbW9VtqIiyY6mBXnYPV4IZlgBmzaZI
         vL6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=C/3jo0jsE8wFgw2iplq9k3+bvhgHMroF2GYfUpuZsE0=;
        b=xPJy38d7MqRLUdnUm+H1ov9heSr2OvrusZf/7gFoj9oHA2NTB1Hg/akTHwsZKxuLHy
         tp+fCUXmBChhhsi46A2d6iyzlmBZ/IKzSN4bvmNbRwLbQ2rlTBECD2blV5QTajaWCtbx
         1NeUWcBZ1bYY7AuJKajT9ezWiwf42pWlim/BsEUe+KQI/G+lygN1zYJhcjVzDTisqjXY
         xjdayGw29FiqBWqIcWZ2hoFVZl7N+/8fitLrx79MCY22FTZ2UpMYYhIYXciLsJGpaDGw
         hYvYfvKeNvZqOAXLtf80DDgwAotEpHpP18etrluK+7BB5vKeArKlKVo/efs7fP4zlZCy
         Hiag==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=DhAx15tD;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id w14si18759689ybq.255.2019.07.25.10.53.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 10:53:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=DhAx15tD;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d39ecb00000>; Thu, 25 Jul 2019 10:53:52 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 25 Jul 2019 10:53:54 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 25 Jul 2019 10:53:54 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 25 Jul
 2019 17:53:54 +0000
Subject: Re: [PATCH] mm/hmm: replace hmm_update with mmu_notifier_range
To: Jason Gunthorpe <jgg@ziepe.ca>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
	<nouveau@lists.freedesktop.org>, <dri-devel@lists.freedesktop.org>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Christoph Hellwig
	<hch@lst.de>, Ben Skeggs <bskeggs@redhat.com>
References: <20190723210506.25127-1-rcampbell@nvidia.com>
 <20190725011424.GA377@ziepe.ca>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <e101947a-da37-2a9f-c673-fe0a54965e18@nvidia.com>
Date: Thu, 25 Jul 2019 10:53:54 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190725011424.GA377@ziepe.ca>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1564077232; bh=C/3jo0jsE8wFgw2iplq9k3+bvhgHMroF2GYfUpuZsE0=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=DhAx15tDao86fNlJyG41mGVLdRS4/AWdLS624zZoNmWkk3D7BjMR5xCzjLZBoVLLx
	 afryURRZB/swcEevPYzWOT4IVLi5ZgHxsDCQxxQZNU6w1WG01nZ+jnybjiYlec0vWp
	 K6uyYQSPu7IuTdfmgboDdwx9/ORVCRuDPSJ/c/qeHQ3cU5SCDV+AE/nkHy+jt4ovLk
	 pQSLsmpMP9fnSGq/ZjIzvO2xYXfrRtfQD5SL0e1xKeJ9tGrj4h282I5a4ENoccpPue
	 GlSEJMxOnjXGYBZawJUxgLm5FITum1dRyJQiJGTyd/6mJ251nH2dme/+hCCQk3hiuA
	 UmXZ1fHXQ2LkQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/24/19 6:14 PM, Jason Gunthorpe wrote:
> On Tue, Jul 23, 2019 at 02:05:06PM -0700, Ralph Campbell wrote:
>> The hmm_mirror_ops callback function sync_cpu_device_pagetables() passes
>> a struct hmm_update which is a simplified version of struct
>> mmu_notifier_range. This is unnecessary so replace hmm_update with
>> mmu_notifier_range directly.
>>
>> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
>> Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
>> Cc: Jason Gunthorpe <jgg@mellanox.com>
>> Cc: Christoph Hellwig <hch@lst.de>
>> Cc: Ben Skeggs <bskeggs@redhat.com>
>>
>> This is based on 5.3.0-rc1 plus Christoph Hellwig's 6 patches
>> ("hmm_range_fault related fixes and legacy API removal v2").
>> Jason, I believe this is the patch you were requesting.
>=20
> Doesn't this need revision to include amgpu?
>=20
> drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c:         .sync_cpu_device_pagetabl=
es =3D amdgpu_mn_sync_pagetables_gfx,
> drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c:         .sync_cpu_device_pagetabl=
es =3D amdgpu_mn_sync_pagetables_hsa,
>=20
> Thanks,
> Jason
>=20

Yes. I have added this to v2 which I'll send out with Christoph's 2=20
patches and the hmm_range.vma removal patch you suggested.

