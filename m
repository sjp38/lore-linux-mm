Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90B10C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 22:19:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 246212184E
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 22:19:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="UacjadgK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 246212184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 963276B0008; Thu, 28 Mar 2019 18:19:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9110A6B000C; Thu, 28 Mar 2019 18:19:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D8D96B000D; Thu, 28 Mar 2019 18:19:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5B15C6B0008
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 18:19:09 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id x66so217152ywx.1
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 15:19:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=jJMfrUQ6CQSACtkEAmcif7KeGPtMnfrOgzF7WE0eF5w=;
        b=RCGZkGAL6vuoAMOo1Z0LeWRAqm6J2go4Oz/UsaZ8wonZG2JPoMK9aASBzMOFcwWBmB
         V36KMgqe2E2IwkD90wU8y+NNUD0qEPMVFH+jqdDlQs4BxDCArTPhVct7pScMWPlNI0iR
         gHI61aDTutCw0mzjtlb0yOZ4m2YhhyxEvq2YNwgktf/O3HMWmiqlHp1yRkeykt7BteCm
         7mW3Udbncl+4KBxbhsEFstDKWBqPZuop+f3f39GYHVP9pa5Jf6ddlAr3TWdvfM/UTqcR
         Cs5fzuu/8Ymnd3DXjgzdc3nFofvX4kC5WuuRFiCTwDl8eTnXtTvY0TpQ4GQiw0gy3+pR
         f50w==
X-Gm-Message-State: APjAAAXkgV1wFxe7dc0DtMJQnbDNnfSNLs67JwTQBm7CAwmSGh8Jj4Za
	6KA9OP2owlqWPdhUOV6rBVkfkK50kPwglvRslB9mPwiEQOKIXQRwNtnJxEHX7ZBhl1AG3/XxZ6Z
	V8DVWY4PqfghJSZO5/Y4FQUT6l4BBBqmDLDG86Ifd1gR5ZQjCnGfaBfXIuWxutHAPPA==
X-Received: by 2002:a81:5cc5:: with SMTP id q188mr28639092ywb.497.1553811549018;
        Thu, 28 Mar 2019 15:19:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzia2lMRstX4/TTLFdS6DSrJhqG5a7ChJUu4i+xOvXkYPG4tvZHLMHuNXb5jAmoXaDzX9I8
X-Received: by 2002:a81:5cc5:: with SMTP id q188mr28639055ywb.497.1553811548307;
        Thu, 28 Mar 2019 15:19:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553811548; cv=none;
        d=google.com; s=arc-20160816;
        b=f0K9qmNo49H8lyCeNcnOYQBbtArrqmURlcCTdsamX22loEKi2Css96VBdBq9r9KDGG
         bG9/t2Q5TQ2nzl39XHu8NQGCB4S0hR5zZu8XMVfnCJncXM0LCCgGzmEleYS6tG+eM8SH
         Vrr46NjMhcko24Z+f5lPutF6tZemmnAwsfVOMldPmfI43mhAvVMd5UtFjEhh0eJw5KRt
         TudZ8IQQo6NZjIVw0mlOEty73yCudTFYuZjaJSGwy3iep9ooW+KXmfwroxDgy+6DC7fj
         xX3LuUCGdnMemQhOiyh3dxqpd3ppXDwCG+p0PclCbp4L/eXC/nYGh/Yon3PcJTp8RnxD
         1UbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=jJMfrUQ6CQSACtkEAmcif7KeGPtMnfrOgzF7WE0eF5w=;
        b=xfbch6yHz8Y51sof4dGsIPoeDq5eB1eDUroNlXfQOGPQSmakO0jwjphr3AY3XWpmLc
         jCaSrBHEqCRh/QR5E7Ut3vSCpCO8jzTwWn8AmpH5eV1oCX6NMEYYvTL/CYE2PJ4ueW53
         /SkeWtV5ulNrqYrB2OBzLQQxjbabpzjMWRBwrGLpSzorORHuXIbf5nXUr7FuZoMhbsM/
         4C21vzd7MHqirFBUcypxLjk8QVZVtSPgWqfkjfE7kFm5wWK+h7z3JFMNrvOYcyy7jdiG
         mn4rCzGUEWjV2HIjybI83/veUB1wqsw7Uhgx2wAzPGPGgn6/7d6zwCaCX2gJOqkJMQfr
         svAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=UacjadgK;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id q2si202619ywq.114.2019.03.28.15.19.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 15:19:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=UacjadgK;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c9d485e0002>; Thu, 28 Mar 2019 15:19:10 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 28 Mar 2019 15:19:07 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 28 Mar 2019 15:19:07 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 28 Mar
 2019 22:19:07 +0000
Subject: Re: [PATCH v2 07/11] mm/hmm: add default fault flags to avoid the
 need to pre-fill pfns arrays.
To: Jerome Glisse <jglisse@redhat.com>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, Andrew Morton
	<akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-8-jglisse@redhat.com>
 <2f790427-ea87-b41e-b386-820ccdb7dd38@nvidia.com>
 <20190328221203.GF13560@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <555ad864-d1f9-f513-9666-0d3d05dbb85d@nvidia.com>
Date: Thu, 28 Mar 2019 15:19:06 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190328221203.GF13560@redhat.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1553811550; bh=jJMfrUQ6CQSACtkEAmcif7KeGPtMnfrOgzF7WE0eF5w=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=UacjadgKHzvAwTEQAvISLIZ4eiYYPo74LHrArJGMFC03x/Ly//uXfiEyio5p1sQss
	 Vbwvv3KaugGTvElhTgYpeMVfIu5XTrecJMBGJCtGZkCGVEJ8f3EwBC8IOq8VOp5t1N
	 jfp4n0hCVLBI12DuVL6Rgec99eco0RxwWdPP7VPiND/hbjHGS1TPhUMEY9ZwFnTj9g
	 G78t/l152sIsg8JJYWPCkCKNjCA9pIHVWoRjdImDrwrWA8CR8Ru4jvfGaUwKZMV43W
	 Fd6pOrVdVYtk05qofS2yIOnWYPmMfaFCFbPfJLhV7Tl9PMIu7Rfww/80oBGPrbnDl5
	 MQGEpo/UnHrkg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/28/19 3:12 PM, Jerome Glisse wrote:
> On Thu, Mar 28, 2019 at 02:59:50PM -0700, John Hubbard wrote:
>> On 3/25/19 7:40 AM, jglisse@redhat.com wrote:
>>> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>>>
>>> The HMM mirror API can be use in two fashions. The first one where the =
HMM
>>> user coalesce multiple page faults into one request and set flags per p=
fns
>>> for of those faults. The second one where the HMM user want to pre-faul=
t a
>>> range with specific flags. For the latter one it is a waste to have the=
 user
>>> pre-fill the pfn arrays with a default flags value.
>>>
>>> This patch adds a default flags value allowing user to set them for a r=
ange
>>> without having to pre-fill the pfn array.
>>>
>>> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>>> Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>> Cc: John Hubbard <jhubbard@nvidia.com>
>>> Cc: Dan Williams <dan.j.williams@intel.com>
>>> ---
>>>  include/linux/hmm.h |  7 +++++++
>>>  mm/hmm.c            | 12 ++++++++++++
>>>  2 files changed, 19 insertions(+)
>>>
>>> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
>>> index 79671036cb5f..13bc2c72f791 100644
>>> --- a/include/linux/hmm.h
>>> +++ b/include/linux/hmm.h
>>> @@ -165,6 +165,8 @@ enum hmm_pfn_value_e {
>>>   * @pfns: array of pfns (big enough for the range)
>>>   * @flags: pfn flags to match device driver page table
>>>   * @values: pfn value for some special case (none, special, error, ...=
)
>>> + * @default_flags: default flags for the range (write, read, ...)
>>> + * @pfn_flags_mask: allows to mask pfn flags so that only default_flag=
s matter
>>>   * @pfn_shifts: pfn shift value (should be <=3D PAGE_SHIFT)
>>>   * @valid: pfns array did not change since it has been fill by an HMM =
function
>>>   */
>>> @@ -177,6 +179,8 @@ struct hmm_range {
>>>  	uint64_t		*pfns;
>>>  	const uint64_t		*flags;
>>>  	const uint64_t		*values;
>>> +	uint64_t		default_flags;
>>> +	uint64_t		pfn_flags_mask;
>>>  	uint8_t			pfn_shift;
>>>  	bool			valid;
>>>  };
>>> @@ -521,6 +525,9 @@ static inline int hmm_vma_fault(struct hmm_range *r=
ange, bool block)
>>>  {
>>>  	long ret;
>>> =20
>>> +	range->default_flags =3D 0;
>>> +	range->pfn_flags_mask =3D -1UL;
>>
>> Hi Jerome,
>>
>> This is nice to have. Let's constrain it a little bit more, though: the =
pfn_flags_mask
>> definitely does not need to be a run time value. And we want some assura=
nce that
>> the mask is=20
>> 	a) large enough for the flags, and
>> 	b) small enough to avoid overrunning the pfns field.
>>
>> Those are less certain with a run-time struct field, and more obviously =
correct with
>> something like, approximately:
>>
>>  	#define PFN_FLAGS_MASK 0xFFFF
>>
>> or something.
>>
>> In other words, this is more flexibility than we need--just a touch too =
much,
>> IMHO.
>=20
> This mirror the fact that flags are provided as an array and some devices=
 use
> the top bits for flags (read, write, ...). So here it is the safe default=
 to
> set it to -1. If the caller want to leverage this optimization it can ove=
rride
> the default_flags value.
>=20

Optimization? OK, now I'm a bit lost. Maybe this is another place where I c=
ould
use a peek at the calling code. The only flags I've seen so far use the bot=
tom
3 bits and that's it.=20

Maybe comments here?

>>
>>> +
>>>  	ret =3D hmm_range_register(range, range->vma->vm_mm,
>>>  				 range->start, range->end);
>>>  	if (ret)
>>> diff --git a/mm/hmm.c b/mm/hmm.c
>>> index fa9498eeb9b6..4fe88a196d17 100644
>>> --- a/mm/hmm.c
>>> +++ b/mm/hmm.c
>>> @@ -415,6 +415,18 @@ static inline void hmm_pte_need_fault(const struct=
 hmm_vma_walk *hmm_vma_walk,
>>>  	if (!hmm_vma_walk->fault)
>>>  		return;
>>> =20
>>> +	/*
>>> +	 * So we not only consider the individual per page request we also
>>> +	 * consider the default flags requested for the range. The API can
>>> +	 * be use in 2 fashions. The first one where the HMM user coalesce
>>> +	 * multiple page fault into one request and set flags per pfns for
>>> +	 * of those faults. The second one where the HMM user want to pre-
>>> +	 * fault a range with specific flags. For the latter one it is a
>>> +	 * waste to have the user pre-fill the pfn arrays with a default
>>> +	 * flags value.
>>> +	 */
>>> +	pfns =3D (pfns & range->pfn_flags_mask) | range->default_flags;
>>
>> Need to verify that the mask isn't too large or too small.
>=20
> I need to check agin but default flag is anded somewhere to limit
> the bit to the one we expect.

Right, but in general, the *mask* could be wrong. It would be nice to have
an assert, and/or a comment, or something to verify the mask is proper.

Really, a hardcoded mask is simple and correct--unless it *definitely* must
vary for devices of course.

thanks,
--=20
John Hubbard
NVIDIA

