Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BA9EC32753
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 21:51:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C06A0208C2
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 21:51:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="KJ6GRRsA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C06A0208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B1B76B0005; Wed, 14 Aug 2019 17:51:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 462076B0006; Wed, 14 Aug 2019 17:51:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 378F56B0007; Wed, 14 Aug 2019 17:51:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0001.hostedemail.com [216.40.44.1])
	by kanga.kvack.org (Postfix) with ESMTP id 150C46B0005
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 17:51:12 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id A65A72DFE
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 21:51:11 +0000 (UTC)
X-FDA: 75822379542.27.music13_4489e7141f542
X-HE-Tag: music13_4489e7141f542
X-Filterd-Recvd-Size: 3988
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com [216.228.121.143])
	by imf17.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 21:51:10 +0000 (UTC)
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d54824f0003>; Wed, 14 Aug 2019 14:51:11 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Wed, 14 Aug 2019 14:51:09 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Wed, 14 Aug 2019 14:51:09 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 14 Aug
 2019 21:51:02 +0000
Subject: Re: [PATCH v3 hmm 05/11] hmm: use mmu_notifier_get/put for 'struct
 hmm'
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
 <20190806231548.25242-6-jgg@ziepe.ca>
From: Ralph Campbell <rcampbell@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <66053b82-18d8-217a-b8fd-91981f66f512@nvidia.com>
Date: Wed, 14 Aug 2019 14:51:02 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190806231548.25242-6-jgg@ziepe.ca>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565819471; bh=P9RT5vwQ9P2MNi7AtBxwKiWdi93Rh+sGeCthaUvRAGA=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=KJ6GRRsAe+RAr5rTMPCCaxloTQYWmrR/WBzP+8kr7gip16nYfBHAmUHPXlbhEEm72
	 FR+1qaXQZT7vWEhXvkKhupPjaHOEDSaXlGsl5ePt7QdDbrhYX1ZOOgzO3bUjs5eGS9
	 +3p2cWPTV3vO98Xq4pfl3VknjdwX2ZPJG9es6I7cnO7o2mLiRqWlViag4cGHvpwwm6
	 fRmMqyawH4eX8IYtQuk53VGwfUdLDby5fwgRdPtR6hKzhsePeybHVahWLcd8M89osz
	 g43SKAfGSqwbLLkjdR3VJhZ4Z+aymGB3ltZywUlmcAZGnriaqzx9Dpc0q6MDtbY5EG
	 961klO2uRvQ9A==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 8/6/19 4:15 PM, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
> 
> This is a significant simplification, it eliminates all the remaining
> 'hmm' stuff in mm_struct, eliminates krefing along the critical notifier
> paths, and takes away all the ugly locking and abuse of page_table_lock.
> 
> mmu_notifier_get() provides the single struct hmm per struct mm which
> eliminates mm->hmm.
> 
> It also directly guarantees that no mmu_notifier op callback is callable
> while concurrent free is possible, this eliminates all the krefs inside
> the mmu_notifier callbacks.
> 
> The remaining krefs in the range code were overly cautious, drivers are
> already not permitted to free the mirror while a range exists.
> 
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>

Looks good.
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

