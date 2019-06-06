Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BBACC04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 21:08:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59D13208C0
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 21:08:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="YMIH7Umh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59D13208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CDE306B02DE; Thu,  6 Jun 2019 17:08:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C8E1A6B02DF; Thu,  6 Jun 2019 17:08:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B2F186B02E1; Thu,  6 Jun 2019 17:08:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 898716B02DE
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 17:08:17 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id y81so1120739oig.19
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 14:08:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=Y4XntF7b7G4DQ81sR0y/Jn2xedJWjLJRstkFUo/OuT8=;
        b=E8egNhr7DB1IXIqkIOyq+IfOyS0QABTtA+YRt0Xt1JsFdV9vBuHufmBMQ216qGBGvN
         p8u/DXYI/Lh4sQSCR57p7CE+L3hOIKgyNfB8T/Oq6lpBbXDjMWsD2KKXhtnwoBS054RX
         RpRnIiYiHOLK0On4vOyjhFlRQ8o7QFY7zl1ugr55Dm/7RveC9Kmf2lpH3va6bFIgCufv
         ym55R6LML+uA/orzVu8urAkNrbtP34VJ97pOPwBgkErcpDusL3YPnWyBiNfVYocY1saW
         qayly5mwsNkrjBjd3ogPWmdmVizYQFIG9JatMQit4RuT+sDHkgNpv5d+sGO3R5cJ7kOC
         zViQ==
X-Gm-Message-State: APjAAAXo2nkSE+u4LLTx3YTyAozShSQBDKJr+FgapPxSt/pFDQtsVPJy
	6vn8/eogJDHrnNvnfFHP6FynI23VeFkxlSNG0iUjyePcsSgN0QJwqKSmAfVRO9wbvKSWoSq+XBd
	2nC43vX22Q5Jku9HSU8kBrf4L593uUCnS3t1uV4FHILQxbd50OMJJr2v5r6CQLsUs7w==
X-Received: by 2002:aca:37d6:: with SMTP id e205mr1447229oia.165.1559855297118;
        Thu, 06 Jun 2019 14:08:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxcRfOHZ/LUp0YW2DhZ/NmgzpF3LtRcSosTVb3lbJrkTNKgCZV5nfjodPmMlPhXJmSSYxW5
X-Received: by 2002:aca:37d6:: with SMTP id e205mr1447177oia.165.1559855296082;
        Thu, 06 Jun 2019 14:08:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559855296; cv=none;
        d=google.com; s=arc-20160816;
        b=gM3wQwaDAF8bTD0hdkff9KkUGwneh2ZLl56/3T2a3nHU0s4tod1/geVDpGENXgjzD+
         jpCBExjWcd6zdYlUD6W/BQ5zbMTuFLxXMzh2GiqkVIxaVWtrzN5qURKv126i7L13l+Lo
         DTKP7G1jMSOfE7SXzOO93yJSGlQkCEiIg5EeRShyh16bh3FUhyPK7LOI4eQem4Eautvh
         B/daw8Nbs2BmriwKOrQALQN0w28i4wEwtjgFiX8PjRbvwdQkzg4HDSE2rYAjUHd53QGR
         +lFxiYhRIlUpVI3ZsCMUk09emQtu/RydvggzpCCm13jZsumNAjlwQJNr2+Nz4h92slpZ
         toXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=Y4XntF7b7G4DQ81sR0y/Jn2xedJWjLJRstkFUo/OuT8=;
        b=R4nuaZU2Yb+px15DR2zqmiXceWEfEHRQeDD8A2ulqogG9BdMbkKkVwZ7bqAfLrpKlT
         oFdvJtuytZqHOtbFwkZ8Hbz+H0720KCGoTO4AKkU0Tq2eN4wbNRiQ//sEZEOYZy1e/gj
         s/cR6blrz8cT+Toev7dddQ9R+VQ6gOCy2Sxp04IyRL3VsuhBE39/IvW5NQtt+eVUdliY
         tcXtl72szRd/F/ecpKmDSfGP2zyb6PDgUPolBWMDVXq735tnF0NVFA17emUqf+nzqV76
         /KfNa1EKDDnPxDTgc4Cy+G+AvQT6rBI4HTVnr6Y4UkNSzwiTOXtY+At1/xCBQDxv407w
         xPog==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=YMIH7Umh;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id n66si192980oig.38.2019.06.06.14.08.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 14:08:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=YMIH7Umh;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cf980b00000>; Thu, 06 Jun 2019 14:08:00 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 06 Jun 2019 14:08:15 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 06 Jun 2019 14:08:15 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 6 Jun
 2019 21:08:15 +0000
Subject: Re: [PATCH 4/5] mm/hmm: hmm_vma_fault() doesn't always call
 hmm_range_unregister()
To: Jason Gunthorpe <jgg@ziepe.ca>
CC: Felix Kuehling <Felix.Kuehling@amd.com>, Philip Yang
	<Philip.Yang@amd.com>, Alex Deucher <alexander.deucher@amd.com>,
	<linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, John Hubbard
	<jhubbard@nvidia.com>, Ira Weiny <ira.weiny@intel.com>, Dan Williams
	<dan.j.williams@intel.com>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh
	<bsingharora@gmail.com>, Dan Carpenter <dan.carpenter@oracle.com>, "Matthew
 Wilcox" <willy@infradead.org>, Souptick Joarder <jrdr.linux@gmail.com>,
	"Andrew Morton" <akpm@linux-foundation.org>
References: <20190506232942.12623-1-rcampbell@nvidia.com>
 <20190506232942.12623-5-rcampbell@nvidia.com>
 <20190606145018.GA3658@ziepe.ca>
 <45c7f8ae-36b2-60cc-7d1d-d13ddd402d4b@nvidia.com>
 <20190606195404.GJ17373@ziepe.ca>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <716383df-9985-03b4-bd0c-93de87bffa90@nvidia.com>
Date: Thu, 6 Jun 2019 14:08:14 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190606195404.GJ17373@ziepe.ca>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559855280; bh=Y4XntF7b7G4DQ81sR0y/Jn2xedJWjLJRstkFUo/OuT8=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=YMIH7Umhi4BIMhgVQhYRmUeQw1+kXYUpAhobvb7PiW1Vf+rDjc0Hn9H3i5vjlY58R
	 Ki+k06AVcac5VD5x4cnYgL6j4SSyhmQqpp7FmMoBYSBdHn1utQ8MWkrdRYI4L5qWf2
	 CsX6cpb+rH3mzDRwHkEPm8MqtFvTDP3V7TjDq54dSuVRPQ0YIRMIGmAioXkwEnMSKY
	 TYHX1WxoxUPWQx1T/Xog6YC/Y4acWP0UuaeT68p1n3EFgjEIl9gREBcBvj4dI6wj0L
	 5WNge292oaRHVcYfEP9Jl1UAbp69ACRJKuVUQfYbkY5SV99iyL9EXbwtFHPWupfdnO
	 KQ25V6EZu+cJg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 6/6/19 12:54 PM, Jason Gunthorpe wrote:
> On Thu, Jun 06, 2019 at 12:44:36PM -0700, Ralph Campbell wrote:
>>
>> On 6/6/19 7:50 AM, Jason Gunthorpe wrote:
>>> On Mon, May 06, 2019 at 04:29:41PM -0700, rcampbell@nvidia.com wrote:
>>>> From: Ralph Campbell <rcampbell@nvidia.com>
>>>>
>>>> The helper function hmm_vma_fault() calls hmm_range_register() but is
>>>> missing a call to hmm_range_unregister() in one of the error paths.
>>>> This leads to a reference count leak and ultimately a memory leak on
>>>> struct hmm.
>>>>
>>>> Always call hmm_range_unregister() if hmm_range_register() succeeded.
>>>>
>>>> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
>>>> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>>>> Cc: John Hubbard <jhubbard@nvidia.com>
>>>> Cc: Ira Weiny <ira.weiny@intel.com>
>>>> Cc: Dan Williams <dan.j.williams@intel.com>
>>>> Cc: Arnd Bergmann <arnd@arndb.de>
>>>> Cc: Balbir Singh <bsingharora@gmail.com>
>>>> Cc: Dan Carpenter <dan.carpenter@oracle.com>
>>>> Cc: Matthew Wilcox <willy@infradead.org>
>>>> Cc: Souptick Joarder <jrdr.linux@gmail.com>
>>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>>>    include/linux/hmm.h | 3 ++-
>>>>    1 file changed, 2 insertions(+), 1 deletion(-)
>>>
>>>> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
>>>> index 35a429621e1e..fa0671d67269 100644
>>>> +++ b/include/linux/hmm.h
>>>> @@ -559,6 +559,7 @@ static inline int hmm_vma_fault(struct hmm_range *=
range, bool block)
>>>>    		return (int)ret;
>>>>    	if (!hmm_range_wait_until_valid(range, HMM_RANGE_DEFAULT_TIMEOUT))=
 {
>>>> +		hmm_range_unregister(range);
>>>>    		/*
>>>>    		 * The mmap_sem was taken by driver we release it here and
>>>>    		 * returns -EAGAIN which correspond to mmap_sem have been
>>>> @@ -570,13 +571,13 @@ static inline int hmm_vma_fault(struct hmm_range=
 *range, bool block)
>>>>    	ret =3D hmm_range_fault(range, block);
>>>>    	if (ret <=3D 0) {
>>>> +		hmm_range_unregister(range);
>>>
>>> While this seems to be a clear improvement, it seems there is still a
>>> bug in nouveau_svm.c around here as I see it calls hmm_vma_fault() but
>>> never calls hmm_range_unregister() for its on stack range - and
>>> hmm_vma_fault() still returns with the range registered.
>>>
>>> As hmm_vma_fault() is only used by nouveau and is marked as
>>> deprecated, I think we need to fix nouveau, either by dropping
>>> hmm_range_fault(), or by adding the missing unregister to nouveau in
>>> this patch.
>>
>> I will send a patch for nouveau to use hmm_range_register() and
>> hmm_range_fault() and do some testing with OpenCL.
>=20
> wow, thanks, I'd like to also really like to send such a thing through
> hmm.git - do you know who the nouveau maintainers are so we can
> collaborate on patch planning this?

Ben Skeggs <bskeggs@redhat.com> is the maintainer and
nouveau@lists.freedesktop.org is the mailing list for changes.
I'll be sure to CC them for the patch.

>> I can also send a separate patch to then remove hmm_vma_fault()
>> but I guess that should be after AMD's changes.
>=20
> Let us wait to hear back from AMD how they can consume hmm.git - I'd
> very much like to get everything done in one kernel cycle!
>=20
> Regards,
> Jason
>=20

