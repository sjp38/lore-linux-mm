Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 556CEC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 20:14:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E74462064A
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 20:14:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="R5LCsQ2R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E74462064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5708A6B0003; Wed, 14 Aug 2019 16:14:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 520986B0005; Wed, 14 Aug 2019 16:14:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4371E6B0007; Wed, 14 Aug 2019 16:14:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0069.hostedemail.com [216.40.44.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2170E6B0003
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 16:14:29 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id B7BE6181AC9AE
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 20:14:28 +0000 (UTC)
X-FDA: 75822135816.09.doll62_61336f67e4a46
X-HE-Tag: doll62_61336f67e4a46
X-Filterd-Recvd-Size: 3766
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com [216.228.121.143])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 20:14:27 +0000 (UTC)
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d546ba40000>; Wed, 14 Aug 2019 13:14:28 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Wed, 14 Aug 2019 13:14:26 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Wed, 14 Aug 2019 13:14:26 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 14 Aug
 2019 20:14:24 +0000
Subject: Re: [PATCH v3 hmm 01/11] mm/mmu_notifiers: hoist
 do_mmu_notifier_register down_write to the caller
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
	Andrea Righi <andrea@betterlinux.com>, Jason Gunthorpe <jgg@mellanox.com>,
	Christoph Hellwig <hch@infradead.org>
References: <20190806231548.25242-1-jgg@ziepe.ca>
 <20190806231548.25242-2-jgg@ziepe.ca>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <1391be01-932c-68ca-0160-e08ed2a0243d@nvidia.com>
Date: Wed, 14 Aug 2019 13:14:24 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190806231548.25242-2-jgg@ziepe.ca>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565813668; bh=l693Dsnz2cNYZkVUIa0hGWj4gZqviofo6oB5vcHDRgE=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=R5LCsQ2RGYP/aRbOOTYVqp3+mNbaFthG3djuEbE/Q5RcS9mR/XTArigIkLJIJcoUm
	 2K4ojNSONT0DPE3p48KuDCnr8/b/xkcFIsjgMnEh2A4XHosGTEQqAsOIgDIYpKjhA6
	 rkPNvw30YaNhLDpHwnvQ22Rq+l1U9m2Nr7cxGupNe9zheNvIiYxkmouASaeFKHn1Ne
	 hfrZ3XyWn84qlbZhdg2Z+7hrQwZnGR5tn9y+gosmO+PTqodnJTwNCIDxM/tYLWvgwz
	 yiPA4kvRNQ0JR0eN4UhFvOmVWdRm65jh/bJrrdWl3KFGl5AiupxGl6Jnjo5KFXd1mW
	 QlJuphdrdgDvw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 8/6/19 4:15 PM, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
> 
> This simplifies the code to not have so many one line functions and extra
> logic. __mmu_notifier_register() simply becomes the entry point to
> register the notifier, and the other one calls it under lock.
> 
> Also add a lockdep_assert to check that the callers are holding the lock
> as expected.
> 
> Suggested-by: Christoph Hellwig <hch@infradead.org>
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>

Nice clean up.
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

