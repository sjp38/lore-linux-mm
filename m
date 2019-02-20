Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46821C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 22:40:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8AE220851
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 22:40:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="eeREBfQx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8AE220851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7FE7E8E0041; Wed, 20 Feb 2019 17:40:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7AE758E0002; Wed, 20 Feb 2019 17:40:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 69CBC8E0041; Wed, 20 Feb 2019 17:40:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3B9858E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 17:40:33 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id h2so16046482ywm.11
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 14:40:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=3YmVsn1xjix5KcAoIKQqJBJt7OBuvYd0dgjyNItw0t0=;
        b=r11sd6LNoqg07C8mXV1LjhDEAv2UB/67YWHY2R/EsaKEuwJda1UYcNwoJidihDUQn8
         N5C5pKDo7KNVY8BmfMdBSeu+aSd4sTYlpz6MXB7JsVGw14mKW76gcMEjxFJAMRiroKCY
         eI8aorbS3qsg1Idf8+Vrv4EUmGtUjxe6m4s694BJJVbUhdkczbfmw/rfgmyHx+91f+Oy
         Zca9mNZgI4RClLFPqul7ZxQdzuX5dFnDxRhHJYJcjubvpua3LFlyNmkTcIc63qyfXVKm
         WdM55MEghN4r9Lgah6SJpYWqAKUbNRacJDNAXYGkS4AdcU1nvtAFmMSFj++JRFg2ph7j
         A5QQ==
X-Gm-Message-State: AHQUAuZkVrqxZmI07moHrrtLenzsVqCfeUqFhquocE0vxSoA7AezkXTA
	1ZGQsxzD0va7aCoPua2gMeCS6C+LKaK+p+6iwiUOW2zcfsVKI9FHu8+wA/rvpxtUM/edlC/s152
	SZ9LAIPykvOqXvrhrOj7LIJ5bfNVfyeUPoaXHTUaCvCVjogzPykqH8l5+k+VM/4Quqw==
X-Received: by 2002:a81:29cc:: with SMTP id p195mr29079281ywp.32.1550702432854;
        Wed, 20 Feb 2019 14:40:32 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaOI1iCciIXnv24EmTKZmYFAacEf49kpvd42gCZ2LwIwldOQR7smo1cjRkzqKOceeCGe//J
X-Received: by 2002:a81:29cc:: with SMTP id p195mr29079243ywp.32.1550702432235;
        Wed, 20 Feb 2019 14:40:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550702432; cv=none;
        d=google.com; s=arc-20160816;
        b=ILnnUX4b9RT4wNgO2Lvfxt95b1uLPQaOICKRMyEXWc7cAFxtnjoIdXcwHDAtR9st4D
         1nzRphdxmAQY2z5tRTGudIMZA/kO1X3+xGO6+8ShNKyUEVIDWGMd6px0ZFaFY5Snp6S+
         FTlyRGgxxRizop8evXEca+Wyo9o/0HwBruERqbWzwJ0C5A/dzuCiNeK3YqZaUi10frNN
         ni7bgN6P7NHn6qv6X/CjmnF0AmQ2dx6EYck8KlkfBeG9mGFltuE4AUVrmyhQ+bifJABH
         MFbotVkgQlocyYnTNG9ZnKMiOptHOTfAuIMCT3tGIKxRUwzzHY4Cdr4aBrbAqVDqIaeQ
         TJ9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=3YmVsn1xjix5KcAoIKQqJBJt7OBuvYd0dgjyNItw0t0=;
        b=QuqxUTIjSaY9dTFLXHfUpvbAY7+8Ep9koP92GT/mNYhRPX20+UbnmGw340dp12zpCJ
         noG7MQHcFdY+kBsuFXqv/cZvU9x+PPCGPY7fjnIR0t78C/Au95+t94VlEHTZP2Oy+X8d
         GcOPpoj+3HU6rPY6O/gz9uTQ8dB0CijASd29RHBnbgx6syH27MvXrrcc6hoL3YB0KRDp
         RCWNnz+m7Tf60B6E5J4A/zw2q/ywfd8kk78W+8MWgYuo0HLphUhMGbB1QiNLTaFN+KVu
         dVPpOVGieYyzJApuvNV/8RWE3AprC+JsP7FjyvQPsOV0Ada4tn1Yh40feHsnrtGCVB4/
         KkcA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=eeREBfQx;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id s5si3057519ybk.465.2019.02.20.14.40.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 14:40:32 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=eeREBfQx;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c6dd7650000>; Wed, 20 Feb 2019 14:40:37 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Wed, 20 Feb 2019 14:40:31 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Wed, 20 Feb 2019 14:40:31 -0800
Received: from [10.2.169.124] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Wed, 20 Feb
 2019 22:40:30 +0000
Subject: Re: [PATCH 10/10] mm/hmm: add helpers for driver to safely take the
 mmap_sem
To: Jerome Glisse <jglisse@redhat.com>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, Andrew Morton
	<akpm@linux-foundation.org>, Ralph Campbell <rcampbell@nvidia.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
 <20190129165428.3931-11-jglisse@redhat.com>
 <16e62992-c937-6b05-ae37-a287294c0005@nvidia.com>
 <20190220221933.GB29398@redhat.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <41888fd2-6154-4f85-7949-7a59c434d047@nvidia.com>
Date: Wed, 20 Feb 2019 14:40:20 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190220221933.GB29398@redhat.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1550702437; bh=3YmVsn1xjix5KcAoIKQqJBJt7OBuvYd0dgjyNItw0t0=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=eeREBfQx4+0jbaUJhdAhoJoIvh9Nufbr8sMxBdLSkwJdNk+Ks9zyMef+LAUWNxe6r
	 2zNEUqxO4yy5q8/vke3L+xNRj6XwRQOMygozBpIm3P6oMaH0Kuk15c47J2AIjmKq2C
	 jCuAGJrGnawuDBDz6E2+ea0lgGFum7T1Xe5l/1wNk43fJUwOCacNnVWS2OlZP8d2BI
	 l785uPOCmKr8DqE8oAOo9SjVO8IvoVXnj7EBbCOOQ/U6xcEeNT57l+LkaeQkN7UG1p
	 AIcqNfmVm+2Qom+LSOllG1JrSBn7nOOQ+SK45rFGR06w5v7kgUiVQszV0pz86UfEPR
	 8aBaYo6ECp7Ew==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/20/19 2:19 PM, Jerome Glisse wrote:
> On Wed, Feb 20, 2019 at 01:59:13PM -0800, John Hubbard wrote:
>> On 1/29/19 8:54 AM, jglisse@redhat.com wrote:
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
>>> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>> Cc: Ralph Campbell <rcampbell@nvidia.com>
>>> Cc: John Hubbard <jhubbard@nvidia.com>
>>> ---
>>>    include/linux/hmm.h | 50 ++++++++++++++++++++++++++++++++++++++++++-=
--
>>>    1 file changed, 47 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
>>> index b3850297352f..4a1454e3efba 100644
>>> --- a/include/linux/hmm.h
>>> +++ b/include/linux/hmm.h
>>> @@ -438,6 +438,50 @@ struct hmm_mirror {
>>>    int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct =
*mm);
>>>    void hmm_mirror_unregister(struct hmm_mirror *mirror);
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
>>
>> Hi Jerome,
>>
>> Are you thinking that, throughout the HMM API, there is a problem that
>> the mm may have gone away, and so driver code needs to be littered with
>> checks to ensure that mm is non-NULL? If so, why doesn't HMM take a
>> reference on mm->count?
>>
>> This solution here cannot work. I think you'd need refcounting in order
>> to avoid this kind of problem. Just doing a check will always be open to
>> races (see below).
>>
>>
>>> +static inline int hmm_mirror_mm_down_read(struct hmm_mirror *mirror)
>>> +{
>>> +	struct mm_struct *mm;
>>> +
>>> +	/* Sanity check ... */
>>> +	if (!mirror || !mirror->hmm)
>>> +		return -EINVAL;
>>> +	/*
>>> +	 * Before trying to take the mmap_sem make sure the mm is still
>>> +	 * alive as device driver context might outlive the mm lifetime.
>>> +	 *
>>> +	 * FIXME: should we also check for mm that outlive its owning
>>> +	 * task ?
>>> +	 */
>>> +	mm =3D READ_ONCE(mirror->hmm->mm);
>>> +	if (mirror->hmm->dead || !mm)
>>> +		return -EINVAL;
>>> +
>>
>> Nothing really prevents mirror->hmm->mm from changing to NULL right here=
.
>=20
> This is really just to catch driver mistake, if driver does not call
> hmm_mirror_unregister() then the !mm will never be true ie the
> mirror->hmm->mm can not go NULL until the last reference to hmm_mirror
> is gone.

In that case, then this again seems unnecessary, and in fact undesirable.
If the driver code has a bug, then let's let the backtrace from a NULL
dereference just happen, loud and clear.

This patch, at best, hides bugs. And it adds code that should simply be
unnecessary, so I don't like it. :)  Let's make it go away.

>=20
>>
>>> +	down_read(&mm->mmap_sem);
>>> +	return 0;
>>> +}
>>> +
>>
>> ...maybe better to just drop this patch from the series, until we see a
>> pattern of uses in the calling code.
>=20
> It use by nouveau now.

Maybe you'd have to remove that use case in a couple steps, depending on th=
e
order that patches are going in.


thanks,
--=20
John Hubbard
NVIDIA

