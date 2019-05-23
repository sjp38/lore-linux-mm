Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 107E6C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 17:57:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC5E62187F
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 17:57:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="nsqB1IeZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC5E62187F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6902A6B0296; Thu, 23 May 2019 13:57:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 61ACD6B0298; Thu, 23 May 2019 13:57:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E0756B0299; Thu, 23 May 2019 13:57:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 295D26B0296
	for <linux-mm@kvack.org>; Thu, 23 May 2019 13:57:58 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id q188so6047625ywc.15
        for <linux-mm@kvack.org>; Thu, 23 May 2019 10:57:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=L+NsLVitjlajK5Fndh2v4VhhHtFHNGHsvBcTolR7zkE=;
        b=gU3qjJS8LOYvWqfwWvnOOkozJ/pErD5qM+KjuEASrWDF49rpAKD9MySmdIdV1V+8aV
         5iAuhJ6SpEqKCOggH6EiC/yabhe/nYOlTZA+8HfKI83U3EtoSr/K7TyU5W5zpVeOovd1
         OfIQzHl4nPqEZQSPxixYNrzdfbsauJjI1nRLvm3VZirPeKveY4qPH14A2tevXZP3zqiS
         cbipjvmad2PXgJ2uEQxCpHEI4zSN01RVxbXxsltmlZOGUoLyKPVhde6qSgYOrp52H67+
         PJJVtfOhat7Qgjvx+sN4c0eN88mVSKdNKorlFC9P2qQJxETOHI7B/XXY137dlA/HMkGH
         eIwA==
X-Gm-Message-State: APjAAAXVesWVsBqdKDO6VGZce55rQVEqTOUw+tuKzMcQEt0msR1rMOuR
	J09itXZN/r9B8gZD6ztEwD1D9el31k/scq5Yqn83l9svudQ8etFbihXi+zEsoj4H2wI0sLt38Hn
	PfWZWZ03MwmbKrMx0WA15IaYrxf8MwvEw3M5ildGDTbrrsF3yXSmIs2alohrpvg/hYw==
X-Received: by 2002:a25:a2c1:: with SMTP id c1mr20607336ybn.40.1558634277858;
        Thu, 23 May 2019 10:57:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyDnVtYAxTVskH919+X2lZf/5M9ShJYTi6xD1GivU4RIp938poqLt0yI+9a031WQu93uOdm
X-Received: by 2002:a25:a2c1:: with SMTP id c1mr20607321ybn.40.1558634277371;
        Thu, 23 May 2019 10:57:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558634277; cv=none;
        d=google.com; s=arc-20160816;
        b=xpwWcHYDfdGD5cMMK2iF+w0QRaHT83Bsh2QTrhrikqCM70NVeb0UzEsgkTlmsye8Xq
         QftNzkeie+cqr1y+wVe7C91dgJ4sVQwBqVyfKmpWl/G4QRot+IcPQe3hATKcun+WDqzF
         /dXjxTFlF0ZPeoZ92NanFSY7Jqp1rr5hIg4hQfPfKu9SPjoMIPLs7mQcxW1r9YJAVN14
         GyFhZd44YPs5NSeBCeYgeGts+przHmIeKILAvr49OZmwnWfp9ewe/IyfoWrEYARZpS78
         mvuYvpVCBUuX7rRLTZW1OwFXYeklsBpKCDj7HReiHEwTKo2HPxRNir8jfbhnKnZK8QeE
         vlaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=L+NsLVitjlajK5Fndh2v4VhhHtFHNGHsvBcTolR7zkE=;
        b=XbZsp/S2tEWeEPYZIXCGUmeG4+zTwkFFdmKvkUCQ6l2mQXChIfrv843yEKKa2qWv0j
         X6Bj8/11MHMGV/+MMHULPjCOXiKdGDMdEdSd/k7FYjwEmtSyYy6Pf810B4FwW7p8SgZS
         y/PpoLEzwYPiTXQMP80j2BS18EiIJdpIu0eB+N6WjQgiWnZwvRPdIUPptQURI/+EUG1v
         8oWnbl+RZpcY6bOMBB8P7tgwLsmXeITMZi9M9o5L2xCV8BC5jGABFealKWoT/JVGx6Qn
         jGBDyCo6m1Y3zngIJPok7BZQ1xy5iDNQCgFqpkHnFXxkopo1Yby2Ft3UhUvoRg8uWj1o
         KFrA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=nsqB1IeZ;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id b68si3560725ywb.430.2019.05.23.10.57.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 10:57:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=nsqB1IeZ;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5ce6df1f0001>; Thu, 23 May 2019 10:57:52 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 23 May 2019 10:57:56 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 23 May 2019 10:57:56 -0700
Received: from [10.2.169.219] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 23 May
 2019 17:57:52 +0000
Subject: Re: [PATCH 1/1] infiniband/mm: convert put_page() to put_user_page*()
To: Jerome Glisse <jglisse@redhat.com>
CC: Andrew Morton <akpm@linux-foundation.org>, <linux-mm@kvack.org>, "Jason
 Gunthorpe" <jgg@ziepe.ca>, LKML <linux-kernel@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>, Doug Ledford
	<dledford@redhat.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, "Dennis
 Dalessandro" <dennis.dalessandro@intel.com>, Christian Benvenuti
	<benve@cisco.com>, Jan Kara <jack@suse.cz>, Jason Gunthorpe
	<jgg@mellanox.com>, Ira Weiny <ira.weiny@intel.com>
References: <20190523072537.31940-1-jhubbard@nvidia.com>
 <20190523072537.31940-2-jhubbard@nvidia.com>
 <20190523153133.GB5104@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <708b9fc4-9afd-345e-83f7-2ceae673a4fd@nvidia.com>
Date: Thu, 23 May 2019 10:56:56 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190523153133.GB5104@redhat.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1558634272; bh=L+NsLVitjlajK5Fndh2v4VhhHtFHNGHsvBcTolR7zkE=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=nsqB1IeZFCuxxH6mHCvcXZ7r8Pp4bj2szDVLBKtv72WLrTh+NFjrf0A9KJEyx6nYx
	 xdOeSAheQUOMNx3oiM4T5lPXrconSMMy+s+NQQGNgYdc8sEtCh47sE/Vm2HaLAaAiM
	 ZkDCNxXsOFRKAzoqGDNk4VwTtjSCvSWvNbEHPsRyJWAOhct4eHLdLrjBtMsYIdiBlt
	 5oCBCOxrHcv0zQQw/jFLI9tSx2R80yUokM0UWuJfUGjOnoC4ZlmwXm8CgKnBSRfcj9
	 tGwlXMkJwAUQcdbP4pb8SVB7v69N3DEB/BN9mMBxHFJfBkMi22AShiQE/7gH5lfnTw
	 1abZmIUAVz0tA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/23/19 8:31 AM, Jerome Glisse wrote:
[...]
>=20
> Reviewed-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>=20

Thanks for the review!

> Between i have a wishlist see below
[...]
>> diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/um=
em.c
>> index e7ea819fcb11..673f0d240b3e 100644
>> --- a/drivers/infiniband/core/umem.c
>> +++ b/drivers/infiniband/core/umem.c
>> @@ -54,9 +54,10 @@ static void __ib_umem_release(struct ib_device *dev, =
struct ib_umem *umem, int d
>>  =20
>>   	for_each_sg_page(umem->sg_head.sgl, &sg_iter, umem->sg_nents, 0) {
>>   		page =3D sg_page_iter_page(&sg_iter);
>> -		if (!PageDirty(page) && umem->writable && dirty)
>> -			set_page_dirty_lock(page);
>> -		put_page(page);
>> +		if (umem->writable && dirty)
>> +			put_user_pages_dirty_lock(&page, 1);
>> +		else
>> +			put_user_page(page);
>=20
> Can we get a put_user_page_dirty(struct page 8*pages, bool dirty, npages)=
 ?
>=20
> It is a common pattern that we might have to conditionaly dirty the pages
> and i feel it would look cleaner if we could move the branch within the
> put_user_page*() function.
>=20

This sounds reasonable to me, do others have a preference on this? Last tim=
e
we discussed it, I recall there was interest in trying to handle the sg lis=
ts,
which was where a lot of focus was. I'm not sure if there was a preference =
one=20
way or the other, on adding more of these helpers.


thanks,
--=20
John Hubbard
NVIDIA

