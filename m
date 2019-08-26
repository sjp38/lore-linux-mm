Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64DEBC3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 18:21:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2EB2020850
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 18:21:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="iRJskzvc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2EB2020850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F1B126B05C8; Mon, 26 Aug 2019 14:21:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA4E86B05CF; Mon, 26 Aug 2019 14:21:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D93F16B05D0; Mon, 26 Aug 2019 14:21:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0239.hostedemail.com [216.40.44.239])
	by kanga.kvack.org (Postfix) with ESMTP id B35666B05C8
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 14:21:55 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 3FC30824CA27
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 18:21:55 +0000 (UTC)
X-FDA: 75865397790.11.run70_67fd0bbf0125d
X-HE-Tag: run70_67fd0bbf0125d
X-Filterd-Recvd-Size: 4414
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com [216.228.121.64])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 18:21:54 +0000 (UTC)
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d6423430000>; Mon, 26 Aug 2019 11:21:55 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Mon, 26 Aug 2019 11:21:53 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Mon, 26 Aug 2019 11:21:53 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 26 Aug
 2019 18:21:49 +0000
Subject: Re: [PATCH 1/2] mm/hmm: hmm_range_fault() NULL pointer bug
To: Jason Gunthorpe <jgg@mellanox.com>
CC: Christoph Hellwig <hch@lst.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Andrew Morton
	<akpm@linux-foundation.org>
References: <20190823221753.2514-1-rcampbell@nvidia.com>
 <20190823221753.2514-2-rcampbell@nvidia.com> <20190824223754.GA21891@lst.de>
 <e2ecc1a7-0d2f-5957-e6cb-b3c86c085d80@nvidia.com>
 <20190826180937.GI27031@mellanox.com>
From: Ralph Campbell <rcampbell@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <9351886a-34b4-4d6f-95b0-d25007a38e61@nvidia.com>
Date: Mon, 26 Aug 2019 11:21:49 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190826180937.GI27031@mellanox.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1566843715; bh=SGzNXU9OUMJ4sxgAgwF2vBiAW3WFDK29f9kkvuUtX/U=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=iRJskzvc2xmRxSFweduukFPXuLO46IayfypAROJ04qHuHouqTkdxRWJBjEvfWz26t
	 nH11/K1bIcpCtfQ3PCzTwQ7OjiV89AbFCKVp2GG/u7oavfNQjSfTIN9Ay9sY6QisRX
	 Lw8C5CzNnDbqQDuqVHy8esNTkALJED132k9sS3BGQHah1iO+M08Lear0RteTgH3Plb
	 +ypJuyFZ7wu0/IIAGodcN57KhvsrhSSHhMSpq1VtFDlL1oWxG7Yp0WVpo+rUHAmyWi
	 mHRx0pP0zK6O9mcrC5LbmewxrhxFYmw5xcF/RjJ6Svoenp5d4wFxOGfjSn8PYeN7b2
	 yZgNdr/Pbptmw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 8/26/19 11:09 AM, Jason Gunthorpe wrote:
> On Mon, Aug 26, 2019 at 11:02:12AM -0700, Ralph Campbell wrote:
>>
>> On 8/24/19 3:37 PM, Christoph Hellwig wrote:
>>> On Fri, Aug 23, 2019 at 03:17:52PM -0700, Ralph Campbell wrote:
>>>> Although hmm_range_fault() calls find_vma() to make sure that a vma exists
>>>> before calling walk_page_range(), hmm_vma_walk_hole() can still be called
>>>> with walk->vma == NULL if the start and end address are not contained
>>>> within the vma range.
>>>
>>> Should we convert to walk_vma_range instead?  Or keep walk_page_range
>>> but drop searching the vma ourselves?
>>>
>>> Except for that the patch looks good to me:
>>>
>>> Reviewed-by: Christoph Hellwig <hch@lst.de>
>>>
>>
>> I think keeping the call to walk_page_range() makes sense.
>> Jason is hoping to be able to snapshot a range with & without vmas
>> and have the pfns[] filled with empty/valid entries as appropriate.
>>
>> I plan to repost my patch changing hmm_range_fault() to use
>> walk.test_walk which will remove the call to find_vma().
>> Jason had some concerns about testing it so that's why I have
>> been working on some HMM self tests before resending it.
> 
> I'm really excited to see tests for hmm_range_fault()!
> 
> Did you find this bug with the tests??
> 
> Jason
> 

Yes, I found both bugs with the tests.
I started with Jerome's hmm_dummy driver and user level test code.
Hopefully I can send it out this week.

