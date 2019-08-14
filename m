Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B403C32750
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 00:56:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 205BF205C9
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 00:56:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="pb3lAkxG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 205BF205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E4C16B0005; Tue, 13 Aug 2019 20:56:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 993DA6B0006; Tue, 13 Aug 2019 20:56:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 882AF6B0007; Tue, 13 Aug 2019 20:56:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0201.hostedemail.com [216.40.44.201])
	by kanga.kvack.org (Postfix) with ESMTP id 6B30E6B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 20:56:35 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 114FF8248AA1
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 00:56:35 +0000 (UTC)
X-FDA: 75819217950.08.fly54_1c272f40cbf44
X-HE-Tag: fly54_1c272f40cbf44
X-Filterd-Recvd-Size: 4179
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com [216.228.121.65])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 00:56:33 +0000 (UTC)
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d535c420000>; Tue, 13 Aug 2019 17:56:34 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Tue, 13 Aug 2019 17:56:31 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Tue, 13 Aug 2019 17:56:31 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 14 Aug
 2019 00:56:31 +0000
Subject: Re: [RFC PATCH 2/2] mm/gup: introduce vaddr_pin_pages_remote()
From: John Hubbard <jhubbard@nvidia.com>
To: Ira Weiny <ira.weiny@intel.com>
CC: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig
	<hch@infradead.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner
	<david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jason Gunthorpe
	<jgg@ziepe.ca>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, LKML
	<linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
	<linux-fsdevel@vger.kernel.org>, <linux-rdma@vger.kernel.org>
References: <20190812015044.26176-1-jhubbard@nvidia.com>
 <20190812015044.26176-3-jhubbard@nvidia.com>
 <20190812234950.GA6455@iweiny-DESK2.sc.intel.com>
 <38d2ff2f-4a69-e8bd-8f7c-41f1dbd80fae@nvidia.com>
 <20190813210857.GB12695@iweiny-DESK2.sc.intel.com>
 <a1044a0d-059c-f347-bd68-38be8478bf20@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <90e5cd11-fb34-6913-351b-a5cc6e24d85d@nvidia.com>
Date: Tue, 13 Aug 2019 17:56:31 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <a1044a0d-059c-f347-bd68-38be8478bf20@nvidia.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565744194; bh=B3YJYqlMW/Nxmi5w427DPkTLK+35GlKeQUmyIqwgbAQ=;
	h=X-PGP-Universal:Subject:From:To:CC:References:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=pb3lAkxG2jaq8faEuI4gHuG/y2mFdtVCVx2wmdFURM6MMK0LE9ZIfzarYhLjFCV9x
	 I4qkXlCYNapn9xvrWYGT8UIP0jz4syBdNwjPk1H39QXcnI0Gcujrna5uWL444p2Td7
	 QgJ6MrmnfOwUGp8cxQb8YdzplLtomAmCwn9/a7C5dtEhAXO5qAkMN6EYWf1zUC0wVL
	 BgjN6i4WEPA9KZhfpLPxwNp4vV9YMKUyONd1+nLDTmQ8Bl9vSy857RVNGNwatbrXGb
	 MjqfA4UxaXhWLS5vVCExkS7Q53ivS9Pe0EBVBMhQjgJlmcG7M+rGIMqAJWMHluoAg3
	 niFswF6dhE7Og==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/13/19 5:51 PM, John Hubbard wrote:
> On 8/13/19 2:08 PM, Ira Weiny wrote:
>> On Mon, Aug 12, 2019 at 05:07:32PM -0700, John Hubbard wrote:
>>> On 8/12/19 4:49 PM, Ira Weiny wrote:
>>>> On Sun, Aug 11, 2019 at 06:50:44PM -0700, john.hubbard@gmail.com wrote:
>>>>> From: John Hubbard <jhubbard@nvidia.com>
>>> ...
>> Finally, I struggle with converting everyone to a new call.  It is more
>> overhead to use vaddr_pin in the call above because now the GUP code is going
>> to associate a file pin object with that file when in ODP we don't need that
>> because the pages can move around.
> 
> What if the pages in ODP are file-backed? 
> 

oops, strike that, you're right: in that case, even the file system case is covered.
Don't mind me. :)

>>
>> This overhead may be fine, not sure in this case, but I don't see everyone
>> wanting it.

So now I see why you said that, but I will note that ODP hardware is rare,
and will likely remain rare: replayable page faults require really special 
hardware, and after all this time, we still only have CPUs, GPUs, and the
Mellanox cards that do it.

That leaves a lot of other hardware to take care of.

thanks,
-- 
John Hubbard
NVIDIA


