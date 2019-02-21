Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE10DC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 00:42:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9FE2920880
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 00:42:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="YllVBZsE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9FE2920880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3AB138E0051; Wed, 20 Feb 2019 19:42:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 35A3E8E0002; Wed, 20 Feb 2019 19:42:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 249908E0051; Wed, 20 Feb 2019 19:42:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id F1EF58E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 19:42:58 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id 67so16576453ybm.23
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 16:42:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=zJjFztKuZcyHjRQdI0lnBbBKcCLEm7/jgvkf6lLt12o=;
        b=RpoEjj4Z6joIQaAJ96QaU/5jUSW96v44BOgbGUy1UtYwABk6DqnyRdp5HGv1o5WNNJ
         QfNms4A92Hu0fINnT0rHAsIe0ahvom4CEVHCGMqiNASPPV68BAQcrVgZjIe3NE5SK9w5
         IXcPK9xuhCBiPoCPYI3w1wUygETBz05jZNr4bL6y81rLaRBFPCtWKn4WsMtET4O49ohz
         fQR8UwWhMGxJAPKVibW9e7616s3VLQ16sRXEf/vC5dRFrjEEmu7jDf8YYJsEUI5W/QSy
         ZnBIT707djmqBgHdEr8ftxMf+S7nabZJDDk2o5Sq0vvreQoVEJ67TN56KbB+fkF03b/i
         skbw==
X-Gm-Message-State: AHQUAua/KLzyDQ7ERivjkKYu6gr3Tvc7M/+ffXoavHPqhsurFXwpi05A
	twiM+/cBqhke7UVssxlpzJrn5to6YUhGEDtSBOPSZuOk8km5A1aoyOJ3jdbJI0BpxDEsiu27ZU/
	x5SfJ5cpmMr/nB6tyUEatJ8j90Pv7hUimvBLvAvYLsQJCcJGPzUOcdTM7AITIJ4j+4Q==
X-Received: by 2002:a0d:ec05:: with SMTP id v5mr11901604ywe.165.1550709778684;
        Wed, 20 Feb 2019 16:42:58 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ias6Mv6tXcedtbh2j4pK52EY0VSqzOTKiryw+JzpIMuasZiGpxWg+YnZqWo7mHuLeDuIPBE
X-Received: by 2002:a0d:ec05:: with SMTP id v5mr11901578ywe.165.1550709778080;
        Wed, 20 Feb 2019 16:42:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550709778; cv=none;
        d=google.com; s=arc-20160816;
        b=DOYNjwaCV5XA7KXyvdkUaQzLnyJrtDcekNXT1GZnPrRXzZZm9NoB0indMTdes4+eyW
         hCcm3tQM2I8Zob7QIrmCKJ2x4XC4GTqQKWzUv8+OIgOopw3tIaKX6OJ59t+8AUCQ/PDF
         8ad5ko9hnQjJ6xYHKxzcXDEoCiDYvekgg5pjcp6ITMIOKrhpyjbAFkYtmHur/wtFkzdW
         CsibetcN/Y/uqaG8QH7B4WDuo7bDvk1alS6JHiaxJXE7VF+ncoykS7YJC0KuVmduz71L
         p6Fer/5MRAyWZVwfNAnjQQOHvMY5W5njBO5/QgBwICkf96mbrkxTaihaA5FB5ZLe30rn
         XQ1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=zJjFztKuZcyHjRQdI0lnBbBKcCLEm7/jgvkf6lLt12o=;
        b=pacFpau/+LtB+0Xd8Bo9Jh5j4Og9CBprPREPIGRex7YL3Mg5l3i9LRO2hypsz6esKi
         Mp4bGrOEAdxOPcC7YZVI5oSoAoIR+m+JFCEA7SZWshHKGi6EekQPWNpm/umNPfyP4UwY
         /rf6w1S7fP5SWl9kvCNzb2j3rVCwJ4htWUF1iuiecF7BO2oJP8BIicA7r+8gG5EzbCFA
         yQHAzdAfQherIJK70GNH2Chr8ETJp3G8L6kn9EKC83vGfL1j7qFgxnxPvkOdzAh7DfBx
         ozibo9sftnIRI95bzlz9YyESuYlPZEIv5DpsndIiRHHBwv/ZoumNSEiQ2rlinWpusfER
         mRcg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=YllVBZsE;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id x203si11820078ybb.22.2019.02.20.16.42.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 16:42:58 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=YllVBZsE;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c6df40f0000>; Wed, 20 Feb 2019 16:42:56 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Wed, 20 Feb 2019 16:42:57 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Wed, 20 Feb 2019 16:42:57 -0800
Received: from [10.2.169.124] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Thu, 21 Feb
 2019 00:42:56 +0000
Subject: Re: [PATCH 01/10] mm/hmm: use reference counting for HMM struct
To: Jerome Glisse <jglisse@redhat.com>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, Ralph Campbell
	<rcampbell@nvidia.com>, Andrew Morton <akpm@linux-foundation.org>
References: <20190129165428.3931-1-jglisse@redhat.com>
 <20190129165428.3931-2-jglisse@redhat.com>
 <1373673d-721e-a7a2-166f-244c16f236a3@nvidia.com>
 <20190220235933.GD11325@redhat.com>
 <dd448c6f-5ed7-ceb4-ca5e-c7650473a47c@nvidia.com>
 <20190221001557.GA24489@redhat.com>
 <58ab7c36-36dd-700a-6a66-8c9abbf4076a@nvidia.com>
 <20190221003716.GD24489@redhat.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <1ccab0d3-7e90-8e39-074d-02ffbfc68480@nvidia.com>
Date: Wed, 20 Feb 2019 16:42:45 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190221003716.GD24489@redhat.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1550709776; bh=zJjFztKuZcyHjRQdI0lnBbBKcCLEm7/jgvkf6lLt12o=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=YllVBZsEf42kejUVjFOuZvlb5cEgLEn85M+UZ5IXbtUwpmhqquuE7jXg4Ep+6Ga3Q
	 cgBvFqdJt0+u+fjr1nHTECxaftPzm+rhY+OiINXtCV3f3X0ewglRsPrZe4ulQnPtlE
	 YnJPJYyCvCEepAB9Z0qL4PQqlEHyZzZ9oj7TMC8aZZpDAyMZqRMbrxTz5UA77ynmmY
	 AB4YW6HuF/q2t1sqauZC6JSJUUy7CTu2B/sgspaNSWTmc1ZSps1xvqlq7N2P6UYEDt
	 m9ha/A3dZ+HmyEHyAMTBL2fhnmuA3e7kQf8WIPgU9uCxQiaCyUtsRhsTSHBM5ObB+6
	 OhOjjDlSsXN+Q==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/20/19 4:37 PM, Jerome Glisse wrote:
> On Wed, Feb 20, 2019 at 04:32:09PM -0800, John Hubbard wrote:
>> On 2/20/19 4:15 PM, Jerome Glisse wrote:
>>> On Wed, Feb 20, 2019 at 04:06:50PM -0800, John Hubbard wrote:
>>>> On 2/20/19 3:59 PM, Jerome Glisse wrote:
>>>>> On Wed, Feb 20, 2019 at 03:47:50PM -0800, John Hubbard wrote:
>>>>>> On 1/29/19 8:54 AM, jglisse@redhat.com wrote:
>>>>>>> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>>>>>>>
>>>>>>> Every time i read the code to check that the HMM structure does not
>>>>>>> vanish before it should thanks to the many lock protecting its remo=
val
>>>>>>> i get a headache. Switch to reference counting instead it is much
>>>>>>> easier to follow and harder to break. This also remove some code th=
at
>>>>>>> is no longer needed with refcounting.
>>>>>>
>>>>>> Hi Jerome,
>>>>>>
>>>>>> That is an excellent idea. Some review comments below:
>>>>>>
>>>>>> [snip]
>>>>>>
>>>>>>>      static int hmm_invalidate_range_start(struct mmu_notifier *mn,
>>>>>>>      			const struct mmu_notifier_range *range)
>>>>>>>      {
>>>>>>>      	struct hmm_update update;
>>>>>>> -	struct hmm *hmm =3D range->mm->hmm;
>>>>>>> +	struct hmm *hmm =3D hmm_get(range->mm);
>>>>>>> +	int ret;
>>>>>>>      	VM_BUG_ON(!hmm);
>>>>>>> +	/* Check if hmm_mm_destroy() was call. */
>>>>>>> +	if (hmm->mm =3D=3D NULL)
>>>>>>> +		return 0;
>>>>>>
>>>>>> Let's delete that NULL check. It can't provide true protection. If t=
here
>>>>>> is a way for that to race, we need to take another look at refcounti=
ng.
>>>>>
>>>>> I will do a patch to delete the NULL check so that it is easier for
>>>>> Andrew. No need to respin.
>>>>
>>>> (Did you miss my request to make hmm_get/hmm_put symmetric, though?)
>>>
>>> Went over my mail i do not see anything about symmetric, what do you
>>> mean ?
>>>
>>> Cheers,
>>> J=C3=A9r=C3=B4me
>>
>> I meant the comment that I accidentally deleted, before sending the emai=
l!
>> doh. Sorry about that. :) Here is the recreated comment:
>>
>> diff --git a/mm/hmm.c b/mm/hmm.c
>> index a04e4b810610..b9f384ea15e9 100644
>>
>> --- a/mm/hmm.c
>>
>> +++ b/mm/hmm.c
>>
>> @@ -50,6 +50,7 @@
>>
>>   static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
>>
>>    */
>>   struct hmm {
>>   	struct mm_struct	*mm;
>> +	struct kref		kref;
>>   	spinlock_t		lock;
>>   	struct list_head	ranges;
>>   	struct list_head	mirrors;
>>
>> @@ -57,6 +58,16 @@
>>
>>   struct hmm {
>>
>>   	struct rw_semaphore	mirrors_sem;
>>   };
>>
>> +static inline struct hmm *hmm_get(struct mm_struct *mm)
>> +{
>> +	struct hmm *hmm =3D READ_ONCE(mm->hmm);
>> +
>> +	if (hmm && kref_get_unless_zero(&hmm->kref))
>> +		return hmm;
>> +
>> +	return NULL;
>> +}
>> +
>>
>> So for this, hmm_get() really ought to be symmetric with
>> hmm_put(), by taking a struct hmm*. And the null check is
>> not helping here, so let's just go with this smaller version:
>>
>> static inline struct hmm *hmm_get(struct hmm *hmm)
>> {
>> 	if (kref_get_unless_zero(&hmm->kref))
>> 		return hmm;
>>
>> 	return NULL;
>> }
>>
>> ...and change the few callers accordingly.
>>
>=20
> What about renaning hmm_get() to mm_get_hmm() instead ?
>=20

For a get/put pair of functions, it would be ideal to pass
the same argument type to each. It looks like we are passing
around hmm*, and hmm retains a reference count on hmm->mm,
so I think you have a choice of using either mm* or hmm* as
the argument. I'm not sure that one is better than the other
here, as the lifetimes appear to be linked pretty tightly.

Whichever one is used, I think it would be best to use it
in both the _get() and _put() calls.

thanks,
--=20
John Hubbard
NVIDIA

