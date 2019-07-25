Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C500C76194
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:19:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5BFEA218F0
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:19:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="OrB98rUK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5BFEA218F0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1589C6B0006; Thu, 25 Jul 2019 14:19:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 10B716B0007; Thu, 25 Jul 2019 14:19:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3A336B0008; Thu, 25 Jul 2019 14:19:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id D4ABE6B0006
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 14:19:10 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id n139so37483825ywd.22
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 11:19:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=Qao2t1CrfNdMKoMvCh94dTKdtpC+EI45d5wLIIGgET0=;
        b=ghCoG2hcj80/Z1j0FHFmUjIygq4dVsIqALSvlaxGS9T68A5odS3l3A7fx781aNuTQm
         pssXFZZGHDuevOS3WcwKN5Kpc92k6sXiPVyiALLsaVBF/N+9j6kfwmU/UdSRan3BpEkD
         q0+SdDeqRx9oTDz9JkzdHVhDyUHZMK98mYfhK06N5KP5pS/OZs1aJKi9cpP2O3a5gyA1
         N1SFF9p1JUvBOSUNv4TpQ7zrnbryfmS7EcOCCUPspEKeld5QsCCLE2OpSFy6nTogjfiI
         /3QKRQGb8kvkCBT1s/7iJ61zBK37nZIlgAKYomy3vho6iKdg6WMerJh6GOxRwq9Dvp1l
         Z98Q==
X-Gm-Message-State: APjAAAVPJEP8SJe5HM5DQspcuoLzwfUJ7fqYi0icpyoiE0QqMyxt1pec
	lhVY0/Fvu+7RxyaSF30QNu+44sV3kneo8XM2w6SyEejxt5dkO3y+iXPWOV82OMWtwY/n9m/qpGY
	T8GHvy2mLGDNa2KwfzAidjKNYKgSATeVsNwQF/V8aNr7obRqrBfMStvOR/sJtqgw4Vw==
X-Received: by 2002:a81:3785:: with SMTP id e127mr51996124ywa.242.1564078750671;
        Thu, 25 Jul 2019 11:19:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzvPW+5al/7E49ZkDhKnWd4TRLXihYyBfNiuDHaauvE56JEPB9tZUhXS6eSpGHd0Wt7bQBG
X-Received: by 2002:a81:3785:: with SMTP id e127mr51996102ywa.242.1564078750087;
        Thu, 25 Jul 2019 11:19:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564078750; cv=none;
        d=google.com; s=arc-20160816;
        b=MoLQPqAXfsFIuZsPm2JcsY9d984pnCvHXtKHhEMWEfPzEZL7xtGLTSGiQYnnPdhK06
         zZsxfSmFNYyioD0sjuXG8sXxIc7JHcfu0DTq/xBlrDiJktLQJpIZDrfqihk7pdshsFFU
         3lUwvviu4u26mc2ppZweCaPyWFg8AOBavIoAZ4kYrkfmJFKUk2rxLmCFaeOrITAFQZWv
         /fW4o/ODTf2YDfs70qZVMX8LtXD9HB3y1JDlt6YjnUVF9zopzkf1gPT2ErOlv8ffn5ll
         jRmw4E/+cR7HCwF/E5Pwgl/R7Jqn08u5avrPt/dUNnCcWm/7jcO5+mGQb8bkHwtohjHc
         H7aA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=Qao2t1CrfNdMKoMvCh94dTKdtpC+EI45d5wLIIGgET0=;
        b=rJ3ZchtnJVlntxDdBKxxgI2sdiozD/S9Ip0hW893hYv0Fu9isl9Rm/fztGyEr3ut9J
         B/brm2BH1cZazv3cSjRaHPo8Z4mf/WFhxqyDIKEP6p5z6bAKAy/VuzVaTCkqyvQLxx4t
         R058OsCsaKcWYraQrIdXHBIFjFQmeL1kZYhhfE+d3Ys+WIHSJLSX9Vh5GNWS7M3PekbV
         M/iKKT/Cs7O0a4GODQ+0yn5Ct7Sw/5USaoAwBJw7UtQRffVZHZhDDRznTAzUmhCAMyuY
         +VliBKH4BYZSYkeo5WLLDTuNZMc0YJdJjgIAlET3cr/aCP2SKmw9pCG79DLX6bzfPDOe
         PxRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=OrB98rUK;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id 207si17322350ywq.155.2019.07.25.11.19.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 11:19:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=OrB98rUK;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d39f2a50000>; Thu, 25 Jul 2019 11:19:17 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Thu, 25 Jul 2019 11:19:09 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Thu, 25 Jul 2019 11:19:09 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 25 Jul
 2019 18:19:08 +0000
Subject: Re: [PATCH v3 1/3] mm: document zone device struct page field usage
To: Christoph Hellwig <hch@lst.de>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, John Hubbard
	<jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Vlastimil Babka
	<vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Dave Hansen
	<dave.hansen@linux.intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, "Kirill A . Shutemov"
	<kirill.shutemov@linux.intel.com>, Lai Jiangshan <jiangshanlai@gmail.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>, Pekka Enberg
	<penberg@kernel.org>, Randy Dunlap <rdunlap@infradead.org>, Andrey Ryabinin
	<aryabinin@virtuozzo.com>, Jason Gunthorpe <jgg@mellanox.com>, Andrew Morton
	<akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
References: <20190724232700.23327-1-rcampbell@nvidia.com>
 <20190724232700.23327-2-rcampbell@nvidia.com> <20190725053821.GA24527@lst.de>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <8acce6b0-7e84-9dc6-9268-eaf0e814d994@nvidia.com>
Date: Thu, 25 Jul 2019 11:19:07 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190725053821.GA24527@lst.de>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1564078757; bh=Qao2t1CrfNdMKoMvCh94dTKdtpC+EI45d5wLIIGgET0=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=OrB98rUKTadk/d8iIGA0ZOIqqnVmAn2Gd/fFnuSL26pd/r5Tax28SSiAFMrnrbU+D
	 SInaELtAsdLvh1iYAAkif/sblYyfYzv3b9qGdoSGaZtsLotIAi/jJoglZpjOHgjsi1
	 Yn51vJ4bQCcYhCTwfcnYmvTNgvpkQOXXM8nWn+wuYBisyfzkxHWVL+79VJum4Mj5Pf
	 w3GDnLSrvzxCgFScHswqu3fju9uqDWp9eZW4sqcsystYZL0gCfffYhsaaDPtEdGcCJ
	 kWJq0QuG2fd9qi5LuW+Pa2TavLm2wnyDUWnB4mFBBnEFSdaKiSwy51ELb249H9GSRf
	 +KQD6RUNBkkoQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/24/19 10:38 PM, Christoph Hellwig wrote:
> On Wed, Jul 24, 2019 at 04:26:58PM -0700, Ralph Campbell wrote:
>> Struct page for ZONE_DEVICE private pages uses the page->mapping and
>> and page->index fields while the source anonymous pages are migrated to
>> device private memory. This is so rmap_walk() can find the page when
>> migrating the ZONE_DEVICE private page back to system memory.
>> ZONE_DEVICE pmem backed fsdax pages also use the page->mapping and
>> page->index fields when files are mapped into a process address space.
>>
>> Add comments to struct page and remove the unused "_zd_pad_1" field
>> to make this more clear.
> 
> I still think we should also fix up the layout, and I haven't seen
> a reply from Matthew justifying his curses for your patch that makes
> the struct page layout actually match how it is used.
> 

Well, I can kind of see this both ways since ZONE_DEVICE
MEMORY_DEVICE_DEVDAX and MEMORY_DEVICE_PCI_P2PDMA don't
seem to use the 3 words like MEMORY_DEVICE_PRIVATE and
MEMORY_DEVICE_FS_DAX.

I like v3 because not all of the ZONE_DEVICE types are handled
the same in regards to using the 3 words and there may be future
ZONE_DEVICE types that use the 3 words differently which might
require a union.

I agree, I would like to hear from Matthew on his thoughts.

