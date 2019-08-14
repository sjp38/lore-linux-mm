Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C34EC32757
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 20:32:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E3B52133F
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 20:32:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="bWazUH1o"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E3B52133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B2F336B0007; Wed, 14 Aug 2019 16:32:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ADF626B0008; Wed, 14 Aug 2019 16:32:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CEAA6B000A; Wed, 14 Aug 2019 16:32:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0166.hostedemail.com [216.40.44.166])
	by kanga.kvack.org (Postfix) with ESMTP id 7C6F06B0007
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 16:32:22 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 3506F3A91
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 20:32:22 +0000 (UTC)
X-FDA: 75822180924.20.time09_6bec7f2c58662
X-HE-Tag: time09_6bec7f2c58662
X-Filterd-Recvd-Size: 4122
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com [216.228.121.64])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 20:32:21 +0000 (UTC)
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d546fdf0001>; Wed, 14 Aug 2019 13:32:31 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Wed, 14 Aug 2019 13:32:20 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Wed, 14 Aug 2019 13:32:20 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 14 Aug
 2019 20:32:13 +0000
Subject: Re: [PATCH v3 hmm 02/11] mm/mmu_notifiers: do not speculatively
 allocate a mmu_notifier_mm
To: Jason Gunthorpe <jgg@ziepe.ca>, <linux-mm@kvack.org>
CC: Andrea Arcangeli <aarcange@redhat.com>, Christoph Hellwig <hch@lst.de>,
	John Hubbard <jhubbard@nvidia.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, "Kuehling, Felix" <Felix.Kuehling@amd.com>, "Alex
 Deucher" <alexander.deucher@amd.com>, =?UTF-8?Q?Christian_K=c3=b6nig?=
	<christian.koenig@amd.com>, "David (ChunMing) Zhou" <David1.Zhou@amd.com>,
	Dimitri Sivanich <sivanich@sgi.com>, <dri-devel@lists.freedesktop.org>,
	<amd-gfx@lists.freedesktop.org>, <linux-kernel@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>, <iommu@lists.linux-foundation.org>,
	<intel-gfx@lists.freedesktop.org>, Gavin Shan <shangw@linux.vnet.ibm.com>,
	Andrea Righi <andrea@betterlinux.com>, Jason Gunthorpe <jgg@mellanox.com>
References: <20190806231548.25242-1-jgg@ziepe.ca>
 <20190806231548.25242-3-jgg@ziepe.ca>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <d2d8d6a8-7ac5-8f04-c11a-61140fccc5e1@nvidia.com>
Date: Wed, 14 Aug 2019 13:32:13 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190806231548.25242-3-jgg@ziepe.ca>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565814751; bh=q5g/jOMKlOwEYLFivYM3g535tx3Zkm1ReT5LriUi6Cs=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=bWazUH1oIGAphw/LWLwGrPnKZAno5v5obKf5t/eNR0RapozA5skQevZ5NNUWMTqSs
	 kQOZhem/RWC7YrXGqUQcoX9RNPOMaSjczbb19BupGsQlBWLQzrHehLyn5MRQxPoeRz
	 uRp+VPoBZXaU5WWDPyHzy/zn86IiYdKiYmtZuXSgMvZILtqwXmEIOyiTigq4o1+c8b
	 VlbXt4UAjtud+BNmrZDyOUAgEsUrePtigZDeaGw1BwQ9WQfGiUlfYRa7z7VO+ymAOg
	 wk1HgI2Ck8lmve8YFdkbz1IbY9uFTOy/smB0ozBuN1+Xs3FmWnPICy4oobSEcCxgmw
	 VWUvGnEtlLyrQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 8/6/19 4:15 PM, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
> 
> A prior commit e0f3c3f78da2 ("mm/mmu_notifier: init notifier if necessary")
> made an attempt at doing this, but had to be reverted as calling
> the GFP_KERNEL allocator under the i_mmap_mutex causes deadlock, see
> commit 35cfa2b0b491 ("mm/mmu_notifier: allocate mmu_notifier in advance").
> 
> However, we can avoid that problem by doing the allocation only under
> the mmap_sem, which is already happening.
> 
> Since all writers to mm->mmu_notifier_mm hold the write side of the
> mmap_sem reading it under that sem is deterministic and we can use that to
> decide if the allocation path is required, without speculation.
> 
> The actual update to mmu_notifier_mm must still be done under the
> mm_take_all_locks() to ensure read-side coherency.
> 
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>

Looks good to me.
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

