Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DC7CC06510
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 20:11:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C20EF2184B
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 20:11:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="IUcePnf0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C20EF2184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E67F6B0003; Tue,  2 Jul 2019 16:11:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 397518E0003; Tue,  2 Jul 2019 16:11:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2AC478E0001; Tue,  2 Jul 2019 16:11:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 06DB86B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 16:11:34 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id i63so3214802ywc.1
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 13:11:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=pJF5x4345qO6YQIaFfIRkH4NCd5wxJwRshnLYN1SQEs=;
        b=SI3qW6oQC4zqGxPyLR7/kvP0iYfOkmBDYATQ+QgPMEZW2tXfsXql++02Hw0CR73koO
         OaOfvbliSQ72IFunztC6j2gXHC9srdedzTEELlFzVw0QqC/1U34LtWnrrGfYe1IZj/xE
         ircdj1wdockQdV8QqQAF01jCVDOZEcDlZw3QP8MHU1fzg977o9qzLH2cudKGzH7SnmL2
         Am0tfPQOQrvUYXUqXw9RguisUuA3QUxHtqrJLviYAqbIlp3C7iacgoj7MwrAh9CPDq3J
         QvDAEmnomvMPxncw1PPVtF0p2X1Dnc8el2fQsEkAnm9bWmiTq1MDVlS2Bc66bfY0X3Yx
         w7EQ==
X-Gm-Message-State: APjAAAX1EGWviXy+CJ3ClltCa1ia7eaM3ZcKZ8p0IkJ+KM/WQ5U0fsb3
	arT7dEF/LcPJ0ed1AYFdRE3QG6P7JRSEzTUY55KNZD+cdWyrkxhsRssl5bGrxPW3DKQsJ/nYKAd
	gpgbfZ5dRuOlemE2yM2rfjAGcMdYJzjZDv/lrcjL7SAziY3+PhoeoJSRv5l1kJg6C+A==
X-Received: by 2002:a05:6902:4e1:: with SMTP id w1mr4397892ybs.331.1562098293762;
        Tue, 02 Jul 2019 13:11:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqypK6XAeEN+t2QTP6iTbBK5+d53yIS2S/uUC5WLzw+IoRSOGe1o8NOasASCjUlv1scdNtED
X-Received: by 2002:a05:6902:4e1:: with SMTP id w1mr4397869ybs.331.1562098293235;
        Tue, 02 Jul 2019 13:11:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562098293; cv=none;
        d=google.com; s=arc-20160816;
        b=j5iY2qgS57E9ZND6e/hUK/UH0kYchlZoaCjY3vBHu9sFo0bayfXrjzgNw+wV2o8OTW
         OGGJiJWusd4ccb3YOPIe9x+2b5XtcY0jjtga7CP3egA7Ew+m++8a1WvqkLCLbrGjsisk
         gYEpp3X86/65ij66nvhHpe6UhWoqbaWVk+buSdedTCUPFM6EQM4Pj8CwyM040kpJQs7P
         rDUF/6ynzdw85SjeYLRp+RMZWDoZIWNKUpo9Awe83Cbbn1eF06Unn5GLwuqJH8i3PPGf
         1SkeLpPQ64XNSPBY7Z1WIzwnM9kon9Q+LeEcQdKbFaH/8VcggyomFf4UF4uQ1HrItXL0
         fztQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=pJF5x4345qO6YQIaFfIRkH4NCd5wxJwRshnLYN1SQEs=;
        b=J3L1R2TFZrNioyzhCbZBuuBJoO7ni8pM4E0vZZqEBU8CvDW2CoYQ+cnC/hTT6sorhu
         JWTirAifTaGvAnrqyrCFETDDddplQV1dI1cnb6PdRVXuMW3iuI7JsOAV9FkvtNV78cjy
         9e7bmp+N2/3Z2aJbwVxBXMA1eSjZ0dm/6VHmfW/ClWfginpbP3p9440XYVN8zNHqNEFq
         MgtDuLAD/3paLfvaKQ20qCS7/lKoJSDLMN0ulePRTyhN4KCHIUTugTqELG6l+cBcBiP3
         AKWiGnsust/jo3NvppfseVXRjxpJN1EqQKdXUUFZ2mFubNcV0rK4tM/AxxXrRfV1RJ2n
         zuEg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=IUcePnf0;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id x4si6350153ywe.21.2019.07.02.13.11.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 13:11:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=IUcePnf0;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d1bba730000>; Tue, 02 Jul 2019 13:11:31 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 02 Jul 2019 13:11:32 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 02 Jul 2019 13:11:32 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 2 Jul
 2019 20:11:28 +0000
Subject: Re: [RFC] mm/hmm: pass mmu_notifier_range to
 sync_cpu_device_pagetables
To: Jason Gunthorpe <jgg@mellanox.com>, Christoph Hellwig <hch@lst.de>
CC: Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>,
	"Felix.Kuehling@amd.com" <Felix.Kuehling@amd.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, Andrea Arcangeli
	<aarcange@redhat.com>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>
References: <20190608001452.7922-1-rcampbell@nvidia.com>
 <20190702195317.GT31718@mellanox.com>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <b0252869-588f-0333-1878-1f90b8b0c17b@nvidia.com>
Date: Tue, 2 Jul 2019 13:11:28 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190702195317.GT31718@mellanox.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1562098291; bh=pJF5x4345qO6YQIaFfIRkH4NCd5wxJwRshnLYN1SQEs=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=IUcePnf0Csnlm1B5f0YiScyxFBIq1oVLcXkX1R9Dzr/JAedpYocU+1YoARltFSzXL
	 iLdan7eOA9VcM2WT0J99ARUqKv5co1QJpNjVJxlyi6VrWEaAa0ctcAejwHVY5FPzkK
	 6qPdataKyAZrPuuUre4m/2Ync8rx0qmtlLizKB0GuEBNOc7D6cSYMtShRnxwP6YfbL
	 3wiZCF40d0ZkSYRtNGF6wQbfuTiye4gz/az2kzjXcRQxdB6y8stFF9aKIkrjk41ZR6
	 r8/YZuQpFxYBeyEUBl5MVMoyTkBxn2IdZdr2j6jfNvfE62puz7tcnkRFcL9kLfVfv5
	 5CgD7awfl1YKw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/2/19 12:53 PM, Jason Gunthorpe wrote:
> On Fri, Jun 07, 2019 at 05:14:52PM -0700, Ralph Campbell wrote:
>> HMM defines its own struct hmm_update which is passed to the
>> sync_cpu_device_pagetables() callback function. This is
>> sufficient when the only action is to invalidate. However,
>> a device may want to know the reason for the invalidation and
>> be able to see the new permissions on a range, update device access
>> rights or range statistics. Since sync_cpu_device_pagetables()
>> can be called from try_to_unmap(), the mmap_sem may not be held
>> and find_vma() is not safe to be called.
>> Pass the struct mmu_notifier_range to sync_cpu_device_pagetables()
>> to allow the full invalidation information to be used.
>>
>> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
>> ---
>>
>> I'm sending this out now since we are updating many of the HMM APIs
>> and I think it will be useful.
> 
> This make so much sense, I'd like to apply this in hmm.git, is there
> any objection?
> 
> Jason
> 
Not from me. :-)

Thanks!

