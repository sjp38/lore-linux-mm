Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C70A8C4CEC6
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 17:17:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87A24206A5
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 17:17:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="kRrrpxim"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87A24206A5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 205F16B0003; Thu, 12 Sep 2019 13:17:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B5AD6B0007; Thu, 12 Sep 2019 13:17:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A4ED6B0008; Thu, 12 Sep 2019 13:17:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0203.hostedemail.com [216.40.44.203])
	by kanga.kvack.org (Postfix) with ESMTP id E10AA6B0003
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 13:16:59 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 4BB6A180AD803
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 17:16:59 +0000 (UTC)
X-FDA: 75926923758.13.swing07_5a099c59c0851
X-HE-Tag: swing07_5a099c59c0851
X-Filterd-Recvd-Size: 3635
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com [216.228.121.65])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 17:16:58 +0000 (UTC)
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d7a7d8d0000>; Thu, 12 Sep 2019 10:17:01 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 12 Sep 2019 10:16:57 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 12 Sep 2019 10:16:57 -0700
Received: from DRHQMAIL107.nvidia.com (10.27.9.16) by HQMAIL111.nvidia.com
 (172.20.187.18) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 12 Sep
 2019 17:16:57 +0000
Received: from rcampbell-dev.nvidia.com (172.20.13.39) by
 DRHQMAIL107.nvidia.com (10.27.9.16) with Microsoft SMTP Server (TLS) id
 15.0.1473.3; Thu, 12 Sep 2019 17:16:51 +0000
Subject: Re: [PATCH 1/4] mm/hmm: make full use of walk_page_range()
To: Christoph Hellwig <hch@lst.de>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
	<amd-gfx@lists.freedesktop.org>, <dri-devel@lists.freedesktop.org>,
	<nouveau@lists.freedesktop.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>, Andrew Morton
	<akpm@linux-foundation.org>
References: <20190911222829.28874-1-rcampbell@nvidia.com>
 <20190911222829.28874-2-rcampbell@nvidia.com> <20190912082613.GA14368@lst.de>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <973b7159-513f-0776-668d-8ba1adf87f1c@nvidia.com>
Date: Thu, 12 Sep 2019 10:16:51 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190912082613.GA14368@lst.de>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 DRHQMAIL107.nvidia.com (10.27.9.16)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1568308621; bh=0I/msTXMK3oeVIVr50/e/aSOEcjBKVeKIFb7hH02Hio=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=kRrrpximNrle4ueUTW3i6O9Mb0HqYE3SBDqBD8uvc6Pk1mWY4I5cAXt9LeMFFnbUQ
	 rPbvrrX80AI7hACgTF3cHGGmoLyY1fF8xdUTnIpP57+U+5o/qmkuje1REYgxux/tHo
	 epw+5Jl8KJNz5hkr0Slxr8vkyWnuGEIaql8P7F2UXYkothY48LnIZ30eP/FQjOB6pB
	 gAObbpf2n5+xP6fIRhEHSJ7RZnSaexO5cHoQ8IIegdQ59WsiLu29hkDVFSJQTAzeIv
	 fw996tl3wwsXISYoWQd9OcLICHrROIYQbJsIdSGB0yVRwkRzQcW03EG0Zg+rQLB2ol
	 UxoOO/UNTLxSQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 9/12/19 1:26 AM, Christoph Hellwig wrote:
>> +static int hmm_pfns_fill(unsigned long addr,
>> +			 unsigned long end,
>> +			 struct hmm_range *range,
>> +			 enum hmm_pfn_value_e value)
> 
> Nit: can we use the space a little more efficient, e.g.:
> 
> static int hmm_pfns_fill(unsigned long addr, unsigned long end,
> 		struct hmm_range *range, enum hmm_pfn_value_e value)
> 
>> +static int hmm_vma_walk_test(unsigned long start,
>> +			     unsigned long end,
>> +			     struct mm_walk *walk)
> 
> Same here.
> 
>> +	if (!(vma->vm_flags & VM_READ)) {
>> +		(void) hmm_pfns_fill(start, end, range, HMM_PFN_NONE);
> 
> There should be no need for the void cast here.
> 

OK. I'll post a v2 with the these changes.
Thanks for the reviews.

