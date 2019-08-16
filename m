Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7FFEC3A59E
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 22:36:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4ECE3206C2
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 22:36:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="PhxrYof6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4ECE3206C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8CAB96B0007; Fri, 16 Aug 2019 18:36:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 87BC96B000A; Fri, 16 Aug 2019 18:36:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 743AD6B000C; Fri, 16 Aug 2019 18:36:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0201.hostedemail.com [216.40.44.201])
	by kanga.kvack.org (Postfix) with ESMTP id 54AFA6B0007
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 18:36:23 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id E4E4D180AD809
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 22:36:22 +0000 (UTC)
X-FDA: 75829751004.07.face83_8ef353483fd06
X-HE-Tag: face83_8ef353483fd06
X-Filterd-Recvd-Size: 5461
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com [216.228.121.64])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 22:36:22 +0000 (UTC)
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d572ff00000>; Fri, 16 Aug 2019 15:36:32 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 16 Aug 2019 15:36:20 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 16 Aug 2019 15:36:20 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 16 Aug
 2019 22:36:20 +0000
Subject: Re: [RFC PATCH 2/2] mm/gup: introduce vaddr_pin_pages_remote()
To: Ira Weiny <ira.weiny@intel.com>
CC: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>, Dan Williams
	<dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jason
 Gunthorpe <jgg@ziepe.ca>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, LKML <linux-kernel@vger.kernel.org>,
	<linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>
References: <2cbdf599-2226-99ae-b4d5-8909a0a1eadf@nvidia.com>
 <ac834ac6-39bd-6df9-fca4-70b9520b6c34@nvidia.com>
 <20190815132622.GG14313@quack2.suse.cz>
 <20190815133510.GA21302@quack2.suse.cz>
 <20190815173237.GA30924@iweiny-DESK2.sc.intel.com>
 <b378a363-f523-518d-9864-e2f8e5bd0c34@nvidia.com>
 <58b75fa9-1272-b683-cb9f-722cc316bf8f@nvidia.com>
 <20190816154108.GE3041@quack2.suse.cz>
 <20190816183337.GA371@iweiny-DESK2.sc.intel.com>
 <a584cfbd-b458-dce9-4144-3b542bcf163d@nvidia.com>
 <20190816215954.GA19549@iweiny-DESK2.sc.intel.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <640f1339-053c-cbf0-9817-190780e7c970@nvidia.com>
Date: Fri, 16 Aug 2019 15:36:20 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190816215954.GA19549@iweiny-DESK2.sc.intel.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565994992; bh=CTCyp/aBoRnxBjXkaIIyJIGilrAQeNG9YV2788igcYY=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=PhxrYof65P+7bYxBq/W2mCjm9jByjwTqKaS5X7/PAc5//vsap7YNMMEC3LHYxvdwr
	 ATp9tbG/ziHLwnAU89vAQ/dKiUsZ7vUJJJHVoOG81z9PmnMiUrvOPRzcU01gDeqRfn
	 vT4x92YK/fBmlkv3zXqXHdG6A/MwG3mUSdnFqeNh3u6k2mNmlmK24cEU/l/7vjVmTi
	 Cb6aeOoHst6SazASa4TZbwxTwSk4M/CZhpHJy6Vc+NeyKCy9l20wBAcUGGZY9lShpV
	 JfwFh0i/ucxEJZDwSXXThNCJPJyArlzmPqUTzGaIMkb67jRhTLo3nyy4jZ1xbcZ2Ih
	 c9QzrkEFrKwvg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/16/19 2:59 PM, Ira Weiny wrote:
> On Fri, Aug 16, 2019 at 11:50:09AM -0700, John Hubbard wrote:
...
>>> John could you send a formal patch using vaddr_pin* and I'll add it to the
>>> tree?
>>>
>>
>> Yes...hints about which struct file to use here are very welcome, btw. This part
>> of mm is fairly new to me.
> 
> I'm still working out the final semantics of vaddr_pin*.  But right now you
> don't need a vaddr_pin if you don't specify FOLL_LONGTERM.
> 

ah OK.

> Since case 1, this case, does not need FOLL_LONGTERM I think it is safe to
> simply pass NULL here.
> 
> OTOH we could just track this against the mm_struct.  But I don't think we need
> to because this pin should be transient.
> 

Thanks for looking at that, I'm definitely in learning mode here.

> And this is why I keep leaning toward _not_ putting these flags in the
> vaddr_pin*() calls.  I know this is what I did but I think I'm wrong.  It should
> be the caller specifying what they want and the vaddr_pin*() calls check that
> what they are asking for is correct.
> 

Yes. I think we're nearly done finding the right balance of wrapper calls and
FOLL_* flags. I've seen Jan and others asking that the call sites do *not*
set the flags, but we also know that FOLL_PIN and FOLL_LONGTERM need to vary
independently.

That means either:

a) another trivial wrapper calls, on top of vaddr_pin_*(), for each supported 
combination of FOLL_PIN and FOLL_LONGTERM, or

b) just setting FOLL_PIN and FOLL_LONGTERM at each callsite.

I think either way is easy to grep for, so it's hard to get too excited
(fortunately) about which one to pick. Let's start simple with (b) and it's 
easy to convert later if someone wants that.

Meanwhile, we do need to pull the flag setting out of vaddr_pin_pages().

So I will post these small patches for your mmotm-rdmafsdax-b0-v4 branch,
shortly:

1) Add FOLL_PIN 

   --also I guess it's time to add comments documenting FOLL_PIN and
FOLL_LONGTERM use, stealing Jan's and others' wording for the 4 cases,
from earlier. :)

2) Add vaddr_pin_user_pages_remote(), which will not set FOLL_PIN or FOLL_LONGTERM
itself. And add the caller, which will.

thanks,
-- 
John Hubbard
NVIDIA

