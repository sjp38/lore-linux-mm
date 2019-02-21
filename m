Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42E00C10F07
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 00:32:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E468E2146E
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 00:32:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="F/hPjWEI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E468E2146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9332F8E004F; Wed, 20 Feb 2019 19:32:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E0498E0002; Wed, 20 Feb 2019 19:32:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D0288E004F; Wed, 20 Feb 2019 19:32:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 51DC68E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 19:32:22 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id 69so14229599ybf.5
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 16:32:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=AKUcMecDPS2lquqhV8jTYP7IySEpsg6I/IpRahqUuPs=;
        b=O7nu9BxqxXCm0hQUEqkcf/sW5z4sk0g3wnjEm8KO7rNs6BnbnNBEUZ/FkDhaI4wt/5
         5yBYdnMkwVETRyYnhIk1qA8XyE00uU39/Bx0tR3f16pJGUefQpwsIv+HYpDu+oTvrB3h
         /clnIUhdjmQv1ChpwwhOsNyi0tqleQD5LiYgtvD6tD9iDSKz8w7QzFMR1Ty+OYfVcWj6
         vqqOqb+hBT9KuhvngVuuqgO4Yc9IUK03yizhP9ebwhFNJkXphlqRbxHepmkMoK8eGabk
         ZQ3WzKfhIsznj4a+7eMEGUSU4BiZzVvr9aQ40B7pfuUx1r0M7D8APkie7KLU1dHQIiHT
         ytXA==
X-Gm-Message-State: AHQUAuYMsI+anPSPDG/y/wkbMIDhMOBxPBQBrSWdejhRo/176UiwSmi/
	1vsromLnY6/OuNaDD3Ylw5jTq6z3iQkkRloX+YWz3Fnad9sQ7cankGJGgci65EKtSb9iNPBBs0v
	kLrJgL15IRcYCxHXRcGLqJjxeTft7zhvrmjBlRPUtFajYhugeHdYgRZ80N8vKuucYnw==
X-Received: by 2002:a81:4bc9:: with SMTP id y192mr30225201ywa.359.1550709142070;
        Wed, 20 Feb 2019 16:32:22 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbzugHSX3YyH41bjjLYpoCjQGDhdN9O2cNPXgmzpDmF2hYaVTa+iJ7BE0B30ttXyjug8yVq
X-Received: by 2002:a81:4bc9:: with SMTP id y192mr30225173ywa.359.1550709141455;
        Wed, 20 Feb 2019 16:32:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550709141; cv=none;
        d=google.com; s=arc-20160816;
        b=hynylwncJgVE6oE5qf1EDZTsKP8Dlhoty7nq7VWXzjUG3RpTvAhDtiGoD3cHJMusb6
         r4jpE1xeJTZlVfphxIShHxAcRPJLyfWx6LsLi8aEkZdwPL/qtQcm0et9yXpIH4XS7JAV
         /YCUmiQq1jEZt6yVzp1BrZD/7LGt+Aq5tCXbNz/g5cckmdWqh/1nPWfudh7H2Nqe3Acm
         +YIdStTZPPMeDxYfcNxjsq/KXf7GLoDKy3mQoMD3zs3dbuucAkEBBMaxbr2/cn+Kxlg2
         m+DlKJL7t3pZr3wjWS1XdHOuD/r2ft0CqSO6CkeU10EOLfZMbyvUOEs5rphMGNwy4rSU
         C/aw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=AKUcMecDPS2lquqhV8jTYP7IySEpsg6I/IpRahqUuPs=;
        b=sZh5uiGO4Er9fozZTA2OuTJGBJDn/CaOZBfC+IYWZq/zuMMlP+rfvLAai68EvAuRJ6
         gMILoX7hMFX2XP3OMeeI1dmX/DLBKkhJxP7WP3TsqFkyVqkpawMaldFngt/a+ptmRPro
         5o75HAwm4oZ08Uqzl0IVqoKwJrhhH2vSfmdJ2b68RH5xKCBcrpQ7SuZ90cqd2WkE9dR2
         j21m67P1/hqcaVRrtk+NXSMK5ymFv45Guy21gguYu4AlShy/qdOScbj+/iBE3XX2gZwU
         R1VonC4OuIMd9LQZUpNFHc6KYBZ3jxy3y/kXhyvm1P1qDTtOk+epLYaSf6uGwtWl1CNM
         Bkwg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="F/hPjWEI";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id m189si3367216ywf.150.2019.02.20.16.32.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 16:32:21 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="F/hPjWEI";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c6df19a0000>; Wed, 20 Feb 2019 16:32:26 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Wed, 20 Feb 2019 16:32:20 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Wed, 20 Feb 2019 16:32:20 -0800
Received: from [10.2.169.124] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Thu, 21 Feb
 2019 00:32:20 +0000
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
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <58ab7c36-36dd-700a-6a66-8c9abbf4076a@nvidia.com>
Date: Wed, 20 Feb 2019 16:32:09 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190221001557.GA24489@redhat.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1550709146; bh=AKUcMecDPS2lquqhV8jTYP7IySEpsg6I/IpRahqUuPs=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=F/hPjWEIiq0rtP83nPNcNfV8FCCM6rX4zsxgRjFcSEpGS2ULNyvbZQFmAL6opeuNR
	 ufUCYvQyFKF47viLH5KO1NHkK0dj2nm98vG6S9FPNMoX6Coa9Hwvm/pJFuYgj54VQ3
	 YeXtLqnWmginczAoEJaBVr16HrIG5DVqjnWerQrnurDvIYfVzCMa9ObjqNUjGZp2/X
	 3tiz8HL9fHgHmGr9sJIqxQgHjks31tYennCS9woo1QDMygIXtzkdhmbFtOXo7PcHmT
	 D/UbLLVOW9XaRMtl97qsVVmb5EYYDiKugdHGSJHsjSBetnKlQixNpgur0AF1tOIpOJ
	 ABP7uFleOyODQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/20/19 4:15 PM, Jerome Glisse wrote:
> On Wed, Feb 20, 2019 at 04:06:50PM -0800, John Hubbard wrote:
>> On 2/20/19 3:59 PM, Jerome Glisse wrote:
>>> On Wed, Feb 20, 2019 at 03:47:50PM -0800, John Hubbard wrote:
>>>> On 1/29/19 8:54 AM, jglisse@redhat.com wrote:
>>>>> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>>>>>
>>>>> Every time i read the code to check that the HMM structure does not
>>>>> vanish before it should thanks to the many lock protecting its remova=
l
>>>>> i get a headache. Switch to reference counting instead it is much
>>>>> easier to follow and harder to break. This also remove some code that
>>>>> is no longer needed with refcounting.
>>>>
>>>> Hi Jerome,
>>>>
>>>> That is an excellent idea. Some review comments below:
>>>>
>>>> [snip]
>>>>
>>>>>     static int hmm_invalidate_range_start(struct mmu_notifier *mn,
>>>>>     			const struct mmu_notifier_range *range)
>>>>>     {
>>>>>     	struct hmm_update update;
>>>>> -	struct hmm *hmm =3D range->mm->hmm;
>>>>> +	struct hmm *hmm =3D hmm_get(range->mm);
>>>>> +	int ret;
>>>>>     	VM_BUG_ON(!hmm);
>>>>> +	/* Check if hmm_mm_destroy() was call. */
>>>>> +	if (hmm->mm =3D=3D NULL)
>>>>> +		return 0;
>>>>
>>>> Let's delete that NULL check. It can't provide true protection. If the=
re
>>>> is a way for that to race, we need to take another look at refcounting=
.
>>>
>>> I will do a patch to delete the NULL check so that it is easier for
>>> Andrew. No need to respin.
>>
>> (Did you miss my request to make hmm_get/hmm_put symmetric, though?)
>=20
> Went over my mail i do not see anything about symmetric, what do you
> mean ?
>=20
> Cheers,
> J=C3=A9r=C3=B4me

I meant the comment that I accidentally deleted, before sending the email!
doh. Sorry about that. :) Here is the recreated comment:

diff --git a/mm/hmm.c b/mm/hmm.c
index a04e4b810610..b9f384ea15e9 100644

--- a/mm/hmm.c

+++ b/mm/hmm.c

@@ -50,6 +50,7 @@

  static const struct mmu_notifier_ops hmm_mmu_notifier_ops;

   */
  struct hmm {
  	struct mm_struct	*mm;
+	struct kref		kref;
  	spinlock_t		lock;
  	struct list_head	ranges;
  	struct list_head	mirrors;

@@ -57,6 +58,16 @@

  struct hmm {

  	struct rw_semaphore	mirrors_sem;
  };

+static inline struct hmm *hmm_get(struct mm_struct *mm)
+{
+	struct hmm *hmm =3D READ_ONCE(mm->hmm);
+
+	if (hmm && kref_get_unless_zero(&hmm->kref))
+		return hmm;
+
+	return NULL;
+}
+

So for this, hmm_get() really ought to be symmetric with
hmm_put(), by taking a struct hmm*. And the null check is
not helping here, so let's just go with this smaller version:

static inline struct hmm *hmm_get(struct hmm *hmm)
{
	if (kref_get_unless_zero(&hmm->kref))
		return hmm;

	return NULL;
}

...and change the few callers accordingly.

thanks,
--=20
John Hubbard
NVIDIA

