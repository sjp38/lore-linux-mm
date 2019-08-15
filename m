Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 783B2C32753
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 03:02:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34A932084F
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 03:02:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="XTPlfaZq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34A932084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA1A26B0003; Wed, 14 Aug 2019 23:02:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C51D36B0005; Wed, 14 Aug 2019 23:02:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B19896B0007; Wed, 14 Aug 2019 23:02:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0216.hostedemail.com [216.40.44.216])
	by kanga.kvack.org (Postfix) with ESMTP id 885D26B0003
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 23:02:39 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id EB78E180AD7C1
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 03:02:38 +0000 (UTC)
X-FDA: 75823164396.23.anger86_16e2681a20d28
X-HE-Tag: anger86_16e2681a20d28
X-Filterd-Recvd-Size: 5461
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com [216.228.121.143])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 03:02:37 +0000 (UTC)
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d54cb4d0000>; Wed, 14 Aug 2019 20:02:38 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Wed, 14 Aug 2019 20:02:35 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Wed, 14 Aug 2019 20:02:35 -0700
Received: from [10.2.171.178] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 15 Aug
 2019 03:02:35 +0000
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
 <90e5cd11-fb34-6913-351b-a5cc6e24d85d@nvidia.com>
 <20190814234959.GA463@iweiny-DESK2.sc.intel.com>
 <2cbdf599-2226-99ae-b4d5-8909a0a1eadf@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <ac834ac6-39bd-6df9-fca4-70b9520b6c34@nvidia.com>
Date: Wed, 14 Aug 2019 20:01:07 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <2cbdf599-2226-99ae-b4d5-8909a0a1eadf@nvidia.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565838158; bh=js0ktMLqazhLeNtKUqGKXRVLaL+xYtzOUslnLnPKWrA=;
	h=X-PGP-Universal:Subject:From:To:CC:References:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=XTPlfaZqCyoOkKTP/r8mDwIymC5MxnezHFmD0//uQIiKOJ6IPTeTUA1p3VZlF17YV
	 xnZd7t9ukap3d3DjWQWuxbe2qlutEUCWuedoJaFBgRd6MAWQNyBw6IR2s1Y86dVZ5o
	 Pyl2BZzwLn2bhGifE/hUFBFSlhxo3/CCkm3iGEA3+cS4rkmIjMXfcLZoTCAHY70u31
	 EeoadX1I5HTbkzaavW/OJFtvILT1ayxT9DX+MhwWu6YLd7DVR1YJiOvdXI4JOlFxkv
	 6XacJ1tBE0P3nROa4M5MC3Y3kuSIzsLsK8eSWBPWOJJXJgMPMzklUdxf8jtERQc1/1
	 6z+g4lrMYRapA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/14/19 5:02 PM, John Hubbard wrote:
> On 8/14/19 4:50 PM, Ira Weiny wrote:
>> On Tue, Aug 13, 2019 at 05:56:31PM -0700, John Hubbard wrote:
>>> On 8/13/19 5:51 PM, John Hubbard wrote:
>>>> On 8/13/19 2:08 PM, Ira Weiny wrote:
>>>>> On Mon, Aug 12, 2019 at 05:07:32PM -0700, John Hubbard wrote:
>>>>>> On 8/12/19 4:49 PM, Ira Weiny wrote:
>>>>>>> On Sun, Aug 11, 2019 at 06:50:44PM -0700, john.hubbard@gmail.com wr=
ote:
>>>>>>>> From: John Hubbard <jhubbard@nvidia.com>
>>>>>> ...
>>>>> Finally, I struggle with converting everyone to a new call.=C2=A0 It =
is more
>>>>> overhead to use vaddr_pin in the call above because now the GUP code =
is going
>>>>> to associate a file pin object with that file when in ODP we don't ne=
ed that
>>>>> because the pages can move around.
>>>>
>>>> What if the pages in ODP are file-backed?
>>>>
>>>
>>> oops, strike that, you're right: in that case, even the file system cas=
e is covered.
>>> Don't mind me. :)
>>
>> Ok so are we agreed we will drop the patch to the ODP code?=C2=A0 I'm go=
ing to keep
>> the FOLL_PIN flag and addition in the vaddr_pin_pages.
>>
>=20
> Yes. I hope I'm not overlooking anything, but it all seems to make sense =
to
> let ODP just rely on the MMU notifiers.
>=20

Hold on, I *was* forgetting something: this was a two part thing, and you'r=
e
conflating the two points, but they need to remain separate and distinct. T=
here
were:

1. FOLL_PIN is necessary because the caller is clearly in the use case that
requires it--however briefly they might be there. As Jan described it,

"Anything that gets page reference and then touches page data (e.g. direct =
IO)
needs the new kind of tracking so that filesystem knows someone is messing =
with
the page data." [1]

2. Releasing the pin: for ODP, we can use MMU notifiers instead of requirin=
g a
lease.

This second point does not invalidate the first point. Therefore, I still s=
ee the
need for the call within ODP, to something that sets FOLL_PIN. And that mea=
ns
either vaddr_pin_[user?]_pages_remote, or some other wrapper of your choice=
. :)

I guess shows that the API might need to be refined. We're trying to solve
two closely related issues, but they're not identical.

thanks,
--=20
John Hubbard
NVIDIA

