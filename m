Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E6A4C3A5A3
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 20:16:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA97520674
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 20:16:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="mVWKFws1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA97520674
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 24FD96B0006; Tue, 27 Aug 2019 16:16:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D9386B0008; Tue, 27 Aug 2019 16:16:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C79F6B000A; Tue, 27 Aug 2019 16:16:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0128.hostedemail.com [216.40.44.128])
	by kanga.kvack.org (Postfix) with ESMTP id DD5D86B0006
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 16:16:16 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 59AEE824376B
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 20:16:16 +0000 (UTC)
X-FDA: 75869314752.09.light44_8dfa11f46b90d
X-HE-Tag: light44_8dfa11f46b90d
X-Filterd-Recvd-Size: 3670
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com [216.228.121.65])
	by imf25.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 20:16:15 +0000 (UTC)
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d658f8f0000>; Tue, 27 Aug 2019 13:16:15 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 27 Aug 2019 13:16:13 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 27 Aug 2019 13:16:13 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 27 Aug
 2019 20:16:13 +0000
Subject: Re: [PATCH 2/2] mm/hmm: hmm_range_fault() infinite loop
To: Jason Gunthorpe <jgg@ziepe.ca>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
	<amd-gfx@lists.freedesktop.org>, <dri-devel@lists.freedesktop.org>,
	<nouveau@lists.freedesktop.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph
 Hellwig <hch@lst.de>
References: <20190823221753.2514-1-rcampbell@nvidia.com>
 <20190823221753.2514-3-rcampbell@nvidia.com>
 <20190827184157.GA24929@ziepe.ca>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <f5c1f198-4bdd-3c23-428f-764f894b9997@nvidia.com>
Date: Tue, 27 Aug 2019 13:16:13 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190827184157.GA24929@ziepe.ca>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1566936975; bh=62vGPIEVS329R8EcQsp55qtpEj1Wy2MdKSgth1zICoc=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=mVWKFws1HRjcwMU4KK1X7p1o8yonqFQ3zcqupn0zPr5oGsS/Nhvvd7U/tPbwZwAKu
	 d4ZvKn9dlm8GRZaZo3GoGEUAhJEY4j2rxqDh9fRMAyKnIdpSvp/4gSN18uzPgTC3D+
	 LCNkfwT6+mHkxzSajlnGlbb9pZwCxUSUmGk8cyg/TQvNQ3Yc4oI5+EhyMvw18cN9qG
	 8gRZsKwWbJWVYUfmGLzf9oSNdx/aOV7wufOur1JtTdi8Ef46rMoQ09VwFP84JVX/x7
	 Sv8gB56HOLq0NoOPFdlcxpEMIttHaJTgCBnTpEGfDbQrxsw5uIH+qeHcstowwDqfQR
	 ENGgtWLuJWA7A==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 8/27/19 11:41 AM, Jason Gunthorpe wrote:
> On Fri, Aug 23, 2019 at 03:17:53PM -0700, Ralph Campbell wrote:
> 
>> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
>>   mm/hmm.c | 3 +++
>>   1 file changed, 3 insertions(+)
>>
>> diff --git a/mm/hmm.c b/mm/hmm.c
>> index 29371485fe94..4882b83aeccb 100644
>> +++ b/mm/hmm.c
>> @@ -292,6 +292,9 @@ static int hmm_vma_walk_hole_(unsigned long addr, unsigned long end,
>>   	hmm_vma_walk->last = addr;
>>   	i = (addr - range->start) >> PAGE_SHIFT;
>>   
>> +	if (write_fault && walk->vma && !(walk->vma->vm_flags & VM_WRITE))
>> +		return -EPERM;
> 
> Can walk->vma be NULL here? hmm_vma_do_fault() touches it
> unconditionally.
> 
> Jason
> 
walk->vma can be NULL. hmm_vma_do_fault() no longer touches it
unconditionally, that is what the preceding patch fixes.
I suppose I could change hmm_vma_walk_hole_() to check for NULL
and fill in the pfns[] array, I just chose to handle it in
hmm_vma_do_fault().

