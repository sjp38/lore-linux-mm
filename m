Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1BADC32753
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 00:03:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B48D2086C
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 00:03:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="IgA9r9wi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B48D2086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D7E36B0003; Wed, 14 Aug 2019 20:03:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 389516B0005; Wed, 14 Aug 2019 20:03:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2C6496B000A; Wed, 14 Aug 2019 20:03:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0123.hostedemail.com [216.40.44.123])
	by kanga.kvack.org (Postfix) with ESMTP id 0D6FF6B0003
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 20:03:49 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id C430D8248AA7
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 00:03:48 +0000 (UTC)
X-FDA: 75822713736.11.ghost81_3e29af4170f18
X-HE-Tag: ghost81_3e29af4170f18
X-Filterd-Recvd-Size: 4284
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com [216.228.121.65])
	by imf26.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 00:03:46 +0000 (UTC)
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d54a1640000>; Wed, 14 Aug 2019 17:03:48 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Wed, 14 Aug 2019 17:03:46 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Wed, 14 Aug 2019 17:03:46 -0700
Received: from [10.2.171.178] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 15 Aug
 2019 00:03:45 +0000
Subject: Re: [RFC PATCH 2/2] mm/gup: introduce vaddr_pin_pages_remote()
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
 <90e5cd11-fb34-6913-351b-a5cc6e24d85d@nvidia.com>
 <20190814234959.GA463@iweiny-DESK2.sc.intel.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <2cbdf599-2226-99ae-b4d5-8909a0a1eadf@nvidia.com>
Date: Wed, 14 Aug 2019 17:02:17 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190814234959.GA463@iweiny-DESK2.sc.intel.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565827428; bh=hz8lTdgR0x8GaLCXZ+gwdewpGK5z8PDTvxWlhUrVd/U=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=IgA9r9wi9TjtWDXtQOaw18ttkfzxxnqWWK+KbZeDEl1Va/Ek14rGmc/fuZ8FVDdnK
	 F+xyO9NHzAtIOlP2woh9TTG0FbZbH+77iW7gIAu+unsfZC/stNXZzITa4Aqnt0yTNZ
	 vI4sZG0Qns16nkO3YBTG+kDr0a9dFuVA5wlTcvlVmhuQWN+nNgxRhw9igtUP6JRflT
	 uQDQO/ZLpW4Q4ozEdUVdHg4yVIQ2pCIEvM4IWIdCrd5uNC6owczN5yfsaZIYL+cTOC
	 uPCGn611bLCLb8ZDJV1A4g1ez8Fb2spQfxj6gwiWIq1/tkkUrxtUi8DkQ5uWZhQaz8
	 ImaSu3p4l2mSw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/14/19 4:50 PM, Ira Weiny wrote:
> On Tue, Aug 13, 2019 at 05:56:31PM -0700, John Hubbard wrote:
>> On 8/13/19 5:51 PM, John Hubbard wrote:
>>> On 8/13/19 2:08 PM, Ira Weiny wrote:
>>>> On Mon, Aug 12, 2019 at 05:07:32PM -0700, John Hubbard wrote:
>>>>> On 8/12/19 4:49 PM, Ira Weiny wrote:
>>>>>> On Sun, Aug 11, 2019 at 06:50:44PM -0700, john.hubbard@gmail.com wrote:
>>>>>>> From: John Hubbard <jhubbard@nvidia.com>
>>>>> ...
>>>> Finally, I struggle with converting everyone to a new call.  It is more
>>>> overhead to use vaddr_pin in the call above because now the GUP code is going
>>>> to associate a file pin object with that file when in ODP we don't need that
>>>> because the pages can move around.
>>>
>>> What if the pages in ODP are file-backed?
>>>
>>
>> oops, strike that, you're right: in that case, even the file system case is covered.
>> Don't mind me. :)
> 
> Ok so are we agreed we will drop the patch to the ODP code?  I'm going to keep
> the FOLL_PIN flag and addition in the vaddr_pin_pages.
> 

Yes. I hope I'm not overlooking anything, but it all seems to make sense to
let ODP just rely on the MMU notifiers.

thanks,
-- 
John Hubbard
NVIDIA

