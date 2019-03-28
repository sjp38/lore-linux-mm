Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E48AFC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 21:41:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 85F0A2184E
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 21:41:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="hsLB4gq0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85F0A2184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F32B6B0293; Thu, 28 Mar 2019 17:41:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A0A96B0294; Thu, 28 Mar 2019 17:41:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EAA336B0295; Thu, 28 Mar 2019 17:41:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id B0B8B6B0293
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 17:41:04 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id h69so17250721pfd.21
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 14:41:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=i0yznMUZ3/E1QrRkk2+BDp44MTpSzcLV2/NZJ7ipR8Y=;
        b=pKas++GSzIQl5EmqohICPha+nKoLhG4aJuUfzuEA0oV0bovXH3+zVVfa9DXjjmAjYv
         7paAUJ6AdU4USjFfX2mxDhINksKIZTC6QpFFGtV7eyYElpg4vA/a6EFIvb2FjsbPmFM5
         Bk+xmGgvaAkzZLrP2TcEaQL5BSeNWJwgdmTPQx9wQ/bSeasEpkGo5ENK4KtB3VapY5bT
         HEWPsfSakBWoW0AN7jTEgP9cMrBrKIi24YU9ySjsKrsQoPPt1/j6kZMsxtiMx7Q1JNNa
         ZDZ4W59YJ9/B3M/eSdorgZiBIMuoUYZqDsQjWqfnVAInITRXZlVZhq1S1YinEZniY/BG
         RAEQ==
X-Gm-Message-State: APjAAAVZc+78DKoDXExpg6nHCqWEwyauKIwL3Mwu3HFwEVQgXQVP+ccM
	DWZ2Hr9wmjnB2W01RAm+j+v9AckpUzhwqbGqFXleFQI7zhOl35FrgCGTwNSOnca4IWwfLJgBjG8
	LBBSCfAS782+TL6dHEL7kmXl642JNBMRksDXECWlw8E74Jp6vL8xS1QD95BOKxK0tEA==
X-Received: by 2002:a63:9a4a:: with SMTP id e10mr40709872pgo.366.1553809264263;
        Thu, 28 Mar 2019 14:41:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzhR5uRxZ9huM3B4+y4TkKLfmV+5wb+f4ubNl/aNm5FHVvP3bbDZ+qBLE9kJUGjCmnnJJod
X-Received: by 2002:a63:9a4a:: with SMTP id e10mr40709839pgo.366.1553809263429;
        Thu, 28 Mar 2019 14:41:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553809263; cv=none;
        d=google.com; s=arc-20160816;
        b=rl3at0UEShR7LJQnp132vxFwXyaOH2Kdr04Shvu1yCciEx0WbBX3pU+ssv7Roil/fw
         r+6XGvMSRty30ft8QZrXgtrHWYJpJp60Uo5B7FQl+txjhgOA3/OvaAn09qkJcRxXzkdq
         4gkrQwL5BnEo+hsuQvSm0BOxgz7/K8+M7dPU4VUnOHQfAkqL2Snmwvnaq2sUp4owAf+n
         uwg43Opq993ls6P1mu6FRyFXb7TLO28sVj5Iatj11GyU8auZWwrBlZ/2jGWANM5wMLn/
         5aDE/cFZ9zBkvz8euufuic7OUaHNxOcot0fWC6rZAsXyh/SipqLs8Lgf5cgOMmE7MV+a
         Dz+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=i0yznMUZ3/E1QrRkk2+BDp44MTpSzcLV2/NZJ7ipR8Y=;
        b=0EUQu+I8IdpY+ZO+NL7fGDoel2x4bQ+Z8pwUuJginQu7p/sV/gRb2ibhiJpBkC6qAv
         pb21BpBpQaiZU0q6lXT4Tsar+EOoBNPCmgd5sItbf+bQgleLaFz8PmJUH2lAX+GXA5/B
         IbaewywVyjjyjHprp4bU5nx4p3kjy41XPtwN0FTDy8ykRfxRslJdLrhT+dHtZqZtdOMR
         dOElLW7jNGeb7DNwOvOuyJ3TCjynJhoNSEntbXgIO4ka6FQrQKMe9oULuKjgVkadIE1q
         5fwKJ+9CFTfxYeQU8jc6yZc7jKF8tbVNNZdinFh+fOPNP7oNkW7XUcH3To8qadlSdOfT
         DiJA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=hsLB4gq0;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id j10si191090plb.346.2019.03.28.14.41.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 14:41:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=hsLB4gq0;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c9d3f680002>; Thu, 28 Mar 2019 14:40:56 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 28 Mar 2019 14:41:02 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 28 Mar 2019 14:41:02 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 28 Mar
 2019 21:41:02 +0000
Subject: Re: [PATCH v2 10/11] mm/hmm: add helpers for driver to safely take
 the mmap_sem v2
To: Jerome Glisse <jglisse@redhat.com>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, Andrew Morton
	<akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-11-jglisse@redhat.com>
 <9df742eb-61ca-3629-a5f4-8ad1244ff840@nvidia.com>
 <20190328213047.GB13560@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <a16efd42-3e2b-1b72-c205-0c2659de2750@nvidia.com>
Date: Thu, 28 Mar 2019 14:41:02 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190328213047.GB13560@redhat.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1553809256; bh=i0yznMUZ3/E1QrRkk2+BDp44MTpSzcLV2/NZJ7ipR8Y=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=hsLB4gq0cl32Xmjnr15hA+tqHT/Wm6mRjsQHjiYXOxb3EDWzhHb2doD30UpNQybfY
	 mB4tQoX1AXWvQ5HPFUJRIchUWzThGP7EGYyFQMfgbFXZEsMPPzHYNNUuAEruEYAATZ
	 Lx1tSjutTd930HwXjaKfkA6+RaQCjKkoNR/W+VNmHKa9OZN7vjgBCelyu04RN+TuE2
	 CH/WaP2gqDl6BJg18YbrQZDC/VCdKl64fJ+TEtVyDmK9eMd40yueJ92m8BK46Mtm7i
	 1bvhyC5cS2dd7jFW5U7miBWcM+ZuAHGV2IIHcxw8nAdImfwI3AWyKyVWMdGYKUhyf9
	 rKvF/tjoIl6NA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/28/19 2:30 PM, Jerome Glisse wrote:
> On Thu, Mar 28, 2019 at 01:54:01PM -0700, John Hubbard wrote:
>> On 3/25/19 7:40 AM, jglisse@redhat.com wrote:
>>> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>>>
>>> The device driver context which holds reference to mirror and thus to
>>> core hmm struct might outlive the mm against which it was created. To
>>> avoid every driver to check for that case provide an helper that check
>>> if mm is still alive and take the mmap_sem in read mode if so. If the
>>> mm have been destroy (mmu_notifier release call back did happen) then
>>> we return -EINVAL so that calling code knows that it is trying to do
>>> something against a mm that is no longer valid.
>>>
>>> Changes since v1:
>>>     - removed bunch of useless check (if API is use with bogus argument
>>>       better to fail loudly so user fix their code)
>>>
>>> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>>> Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>> Cc: John Hubbard <jhubbard@nvidia.com>
>>> Cc: Dan Williams <dan.j.williams@intel.com>
>>> ---
>>>  include/linux/hmm.h | 50 ++++++++++++++++++++++++++++++++++++++++++---
>>>  1 file changed, 47 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
>>> index f3b919b04eda..5f9deaeb9d77 100644
>>> --- a/include/linux/hmm.h
>>> +++ b/include/linux/hmm.h
>>> @@ -438,6 +438,50 @@ struct hmm_mirror {
>>>  int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *m=
m);
>>>  void hmm_mirror_unregister(struct hmm_mirror *mirror);
>>> =20
>>> +/*
>>> + * hmm_mirror_mm_down_read() - lock the mmap_sem in read mode
>>> + * @mirror: the HMM mm mirror for which we want to lock the mmap_sem
>>> + * Returns: -EINVAL if the mm is dead, 0 otherwise (lock taken).
>>> + *
>>> + * The device driver context which holds reference to mirror and thus =
to core
>>> + * hmm struct might outlive the mm against which it was created. To av=
oid every
>>> + * driver to check for that case provide an helper that check if mm is=
 still
>>> + * alive and take the mmap_sem in read mode if so. If the mm have been=
 destroy
>>> + * (mmu_notifier release call back did happen) then we return -EINVAL =
so that
>>> + * calling code knows that it is trying to do something against a mm t=
hat is
>>> + * no longer valid.
>>> + */
>>> +static inline int hmm_mirror_mm_down_read(struct hmm_mirror *mirror)
>>
>> Hi Jerome,
>>
>> Let's please not do this. There are at least two problems here:
>>
>> 1. The hmm_mirror_mm_down_read() wrapper around down_read() requires a=20
>> return value. This is counter to how locking is normally done: callers d=
o
>> not normally have to check the return value of most locks (other than
>> trylocks). And sure enough, your own code below doesn't check the return=
 value.
>> That is a pretty good illustration of why not to do this.
>=20
> Please read the function description this is not about checking lock
> return value it is about checking wether we are racing with process
> destruction and avoid trying to take lock in such cases so that driver
> do abort as quickly as possible when a process is being kill.
>=20
>>
>> 2. This is a weird place to randomly check for semi-unrelated state, suc=
h=20
>> as "is HMM still alive". By that I mean, if you have to detect a problem
>> at down_read() time, then the problem could have existed both before and
>> after the call to this wrapper. So it is providing a false sense of secu=
rity,
>> and it is therefore actually undesirable to add the code.
>=20
> It is not, this function is use in device page fault handler which will
> happens asynchronously from CPU event or process lifetime when a process
> is killed or is dying we do want to avoid useless page fault work and
> we do want to avoid blocking the page fault queue of the device. This
> function reports to the caller that the process is dying and that it
> should just abort the page fault and do whatever other device specific
> thing that needs to happen.
>=20

But it's inherently racy, to check for a condition outside of any lock, so =
again,
it's a false sense of security.

>>
>> If you insist on having this wrapper, I think it should have approximate=
ly=20
>> this form:
>>
>> void hmm_mirror_mm_down_read(...)
>> {
>> 	WARN_ON(...)
>> 	down_read(...)
>> }=20
>=20
> I do insist as it is useful and use by both RDMA and nouveau and the
> above would kill the intent. The intent is do not try to take the lock
> if the process is dying.

Could you provide me a link to those examples so I can take a peek? I
am still convinced that this whole thing is a race condition at best.

>=20
>=20
>>
>>> +{
>>> +	struct mm_struct *mm;
>>> +
>>> +	/* Sanity check ... */
>>> +	if (!mirror || !mirror->hmm)
>>> +		return -EINVAL;
>>> +	/*
>>> +	 * Before trying to take the mmap_sem make sure the mm is still
>>> +	 * alive as device driver context might outlive the mm lifetime.
>>
>> Let's find another way, and a better place, to solve this problem.
>> Ref counting?
>=20
> This has nothing to do with refcount or use after free or anthing
> like that. It is just about checking wether we are about to do
> something pointless. If the process is dying then it is pointless
> to try to take the lock and it is pointless for the device driver
> to trigger handle_mm_fault().

Well, what happens if you let such pointless code run anyway?=20
Does everything still work? If yes, then we don't need this change.
If no, then we need a race-free version of this change.

thanks,
--=20
John Hubbard
NVIDIA

