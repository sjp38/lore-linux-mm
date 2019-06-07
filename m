Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19660C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:21:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE152208C0
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:21:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="NCN0Fg0U"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE152208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 62F616B026E; Fri,  7 Jun 2019 16:21:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E0656B026F; Fri,  7 Jun 2019 16:21:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CE226B0270; Fri,  7 Jun 2019 16:21:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2DE4E6B026E
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 16:21:15 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id t128so3129043ywd.15
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 13:21:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=s2G5tJqOqHdqmW4ufsTMsGq7fV6vI/5SQtvIg06oOJQ=;
        b=dEOJnUb+ycs/QogWbOpOJ08KQYgJcklHpJGFx4aw2kj3gDJ29QVCH/JQp3beIFCIMR
         GerjKPhVxM6+h+DIxgsx0cI4Q1eUKYfSM9+fefx3UM8u1Qk8hsFloiA7pSAF/p0BNttN
         UwcOF5sbtG+UhCvbsQU0b5tABTKB/i7Hq/sw0nrnJLaBeqTb5lZUV5Bh6C48ZQjDFszG
         2tSfzkpIU/GHGFkWy/qu6ezTNT3voVd8oD9qAniV5pocpaamuGi/yv5owmrv9D7R5LMf
         Sax5k+lF3qoZK9GQbiWM8dwua86AYKEaBroULHE7s5plDuB4/3vHpS7pF91EGCpdaeOa
         8gXQ==
X-Gm-Message-State: APjAAAUThP09dISY4UPGzfrT2yfus9lu69QrPxtXwDVraZfqZDeX4AHc
	W94Y2Q26T23cYIvxyZg2Ros0SI+V9vbeEn2iG5bIM8NdxU2b1mzd0oH8VVvrkg24MtxBJXBq6Ik
	c4Xk5ss1IfjsG7+eEh/mV8KNuKLi8SA6bddUdOjv7UNB5KsmgK2JwAtZhsRoUBK2Dfg==
X-Received: by 2002:a25:e656:: with SMTP id d83mr26899354ybh.178.1559938874880;
        Fri, 07 Jun 2019 13:21:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwvwnIP8e6LX1av8sij0m8ZHS7Ed6pq1iUfRKoW5mx+R+vnZFgoQsKnY16PC0Ofk/lrsiA/
X-Received: by 2002:a25:e656:: with SMTP id d83mr26899329ybh.178.1559938874256;
        Fri, 07 Jun 2019 13:21:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559938874; cv=none;
        d=google.com; s=arc-20160816;
        b=ewLm3ruWndaFs0Igym5KyD3HXrqPVZnKoCxsWGI7e7+2Goq5OLmZ5LsXWVpW1fgt7N
         5obHqQtI7nKR2Dlul8fRHPg6YjeoJbnRQdr1rtBFDOXjTJpb/GzX+r3nluz5FzVnRNpr
         +YgBt3e3LMwkO6zoVKq+ysEqmrlhwJVA+CfLqwopwbi9QTUXSfwdZxSwbEGdGU6LaMxB
         Ybd9gKuN+oIr/QOQ+mWd37XEZqwgF1uLk0nbW+ifybiDKsSAjP1JHw6Z8Z3TIPszX/tm
         vfUHNqA989ZnXUPW0iAzXVJX/V5CpItXx5/FuAJHxvuTLB/URplpXpFCLJ+/Sj3yf0AJ
         RpqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=s2G5tJqOqHdqmW4ufsTMsGq7fV6vI/5SQtvIg06oOJQ=;
        b=fiYNF8ptfgLUfCZnHJY7U/PXaJ/DdUi9fnNrq81Ayv4lPaKfw0K9lqjT9eOiLG32ZV
         PXj4NhdX95BkocqKxTjb1NbDbPHK5/Top7v2uR3UM/XB482snDgFyrhVi1mSgVia/Bpj
         xPVR0RLLr1XCRiF/61t18VYRyjhjthHo6mNSSbufmSLnqnHQmb7Txnm3FvgcMEHgnCw2
         SvggIzGjDNTn594i0gH4Ag/4W03dVYYrGe5PFfEterH7sWzNiNfqldjCHsBmfqlN2pfv
         cdnXhfFr3tvvSREhV/s9ZuhRcwbZ0F75G9XdoHrRfLB7NL/49HW0O6e4YOwYTJ17GadC
         o4WA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=NCN0Fg0U;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id q13si866561ywj.344.2019.06.07.13.21.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 13:21:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=NCN0Fg0U;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cfac7290000>; Fri, 07 Jun 2019 13:20:58 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 07 Jun 2019 13:21:13 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 07 Jun 2019 13:21:13 -0700
Received: from rcampbell-dev.nvidia.com (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 7 Jun
 2019 20:21:13 +0000
Subject: Re: [PATCH v2 hmm 05/11] mm/hmm: Remove duplicate condition test
 before wait_event_timeout
To: Jason Gunthorpe <jgg@ziepe.ca>
CC: Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>,
	<Felix.Kuehling@amd.com>, <linux-rdma@vger.kernel.org>, <linux-mm@kvack.org>,
	Andrea Arcangeli <aarcange@redhat.com>, <dri-devel@lists.freedesktop.org>,
	<amd-gfx@lists.freedesktop.org>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-6-jgg@ziepe.ca>
 <6833be96-12a3-1a1c-1514-c148ba2dd87b@nvidia.com>
 <20190607191302.GR14802@ziepe.ca>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <e17aa8c5-790c-d977-2eb8-c18cdaa4cbb3@nvidia.com>
Date: Fri, 7 Jun 2019 13:21:12 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190607191302.GR14802@ziepe.ca>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559938858; bh=s2G5tJqOqHdqmW4ufsTMsGq7fV6vI/5SQtvIg06oOJQ=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=NCN0Fg0UVPlZxRyhrIn98xNmC3K2z4IoTGT1OhCjed+O27VsZm5NM4QHj4rep7Og8
	 XODt+Cfuu3++wYZ28eqx0HW9TvQbDlQa7GR5HED65qID4mb2JIKRmoA45K4klBPW8d
	 Hq9ZpycikWWyiLiytAFnSTukk41Y6Bdu07pDpoQJUazx56fZxlp5w715nqwbCmBrH9
	 0SozfIG/WwsFr9Wd2O4i9yDSRInWW5JjdIKRBYmN7gLDZDhpQnWus6UV4muO+t0Q2y
	 SU26zQ7D0iCbo3+CcpZH3Aw9SEq7F0+j2HJn+RdPvu4LX119xAGzDS2WLbGChPceXF
	 7EtJIWmAGa9mQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 6/7/19 12:13 PM, Jason Gunthorpe wrote:
> On Fri, Jun 07, 2019 at 12:01:45PM -0700, Ralph Campbell wrote:
>>
>> On 6/6/19 11:44 AM, Jason Gunthorpe wrote:
>>> From: Jason Gunthorpe <jgg@mellanox.com>
>>>
>>> The wait_event_timeout macro already tests the condition as its first
>>> action, so there is no reason to open code another version of this, all
>>> that does is skip the might_sleep() debugging in common cases, which is
>>> not helpful.
>>>
>>> Further, based on prior patches, we can no simplify the required condit=
ion
>>> test:
>>>    - If range is valid memory then so is range->hmm
>>>    - If hmm_release() has run then range->valid is set to false
>>>      at the same time as dead, so no reason to check both.
>>>    - A valid hmm has a valid hmm->mm.
>>>
>>> Also, add the READ_ONCE for range->valid as there is no lock held here.
>>>
>>> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
>>> Reviewed-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>>>    include/linux/hmm.h | 12 ++----------
>>>    1 file changed, 2 insertions(+), 10 deletions(-)
>>>
>>> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
>>> index 4ee3acabe5ed22..2ab35b40992b24 100644
>>> +++ b/include/linux/hmm.h
>>> @@ -218,17 +218,9 @@ static inline unsigned long hmm_range_page_size(co=
nst struct hmm_range *range)
>>>    static inline bool hmm_range_wait_until_valid(struct hmm_range *rang=
e,
>>>    					      unsigned long timeout)
>>>    {
>>> -	/* Check if mm is dead ? */
>>> -	if (range->hmm =3D=3D NULL || range->hmm->dead || range->hmm->mm =3D=
=3D NULL) {
>>> -		range->valid =3D false;
>>> -		return false;
>>> -	}
>>> -	if (range->valid)
>>> -		return true;
>>> -	wait_event_timeout(range->hmm->wq, range->valid || range->hmm->dead,
>>> +	wait_event_timeout(range->hmm->wq, range->valid,
>>>    			   msecs_to_jiffies(timeout));
>>> -	/* Return current valid status just in case we get lucky */
>>> -	return range->valid;
>>> +	return READ_ONCE(range->valid);
>>>    }
>>>    /*
>>>
>>
>> Since we are simplifying things, perhaps we should consider merging
>> hmm_range_wait_until_valid() info hmm_range_register() and
>> removing hmm_range_wait_until_valid() since the pattern
>> is to always call the two together.
>=20
> ? the hmm.rst shows the hmm_range_wait_until_valid being called in the
> (ret =3D=3D -EAGAIN) path. It is confusing because it should really just
> have the again label moved up above hmm_range_wait_until_valid() as
> even if we get the driver lock it could still be a long wait for the
> colliding invalidation to clear.
>=20
> What I want to get to is a pattern like this:
>=20
> pagefault():
>=20
>     hmm_range_register(&range);
> again:
>     /* On the slow path, if we appear to be live locked then we get
>        the write side of mmap_sem which will break the live lock,
>        otherwise this gets the read lock */
>     if (hmm_range_start_and_lock(&range))
>           goto err;
>=20
>     lockdep_assert_held(range->mm->mmap_sem);
>=20
>     // Optional: Avoid useless expensive work
>     if (hmm_range_needs_retry(&range))
>        goto again;
>     hmm_range_(touch vmas)
>=20
>     take_lock(driver->update);
>     if (hmm_range_end(&range) {
>         release_lock(driver->update);
>         goto again;
>     }
>     // Finish driver updates
>     release_lock(driver->update);
>=20
>     // Releases mmap_sem
>     hmm_range_unregister_and_unlock(&range);
>=20
> What do you think?
>=20
> Is it clear?
>=20
> Jason
>=20

Are you talking about acquiring mmap_sem in hmm_range_start_and_lock()?
Usually, the fault code has to lock mmap_sem for read in order to
call find_vma() so it can set range.vma.
If HMM drops mmap_sem - which I don't think it should, just return an
error to tell the caller to drop mmap_sem and retry - the find_vma()
will need to be repeated as well.
I'm also not sure about acquiring the mmap_sem for write as way to
mitigate thrashing. It seems to me that if a device and a CPU are
both faulting on the same page, some sort of backoff delay is needed
to let one side or the other make some progress.

Thrashing mitigation and how migrate_vma() plays in this is a
deep topic for thought.

