Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21B12C072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 17:47:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A8A3C20879
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 17:47:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="mTS5eeo9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8A3C20879
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7900C6B027B; Fri, 24 May 2019 13:47:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7421F6B027C; Fri, 24 May 2019 13:47:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6092B6B027D; Fri, 24 May 2019 13:47:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 412456B027B
	for <linux-mm@kvack.org>; Fri, 24 May 2019 13:47:19 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id p123so4388264ywg.3
        for <linux-mm@kvack.org>; Fri, 24 May 2019 10:47:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=qRb0ajS0I8Fd/puP/J82uzs9SBibx4DBasaEA2ysW0w=;
        b=TiUK+goHLgzBZVEEb/ZqA3NN68/YxjFnclVk/DTMD2CbGlx3OARKLg9JN6H2SbWjqX
         ZAgRMJAHy3afbg38ylnd2WLcYs5hUuVALmxvpO1BbB3JYuQgmuXV5gl7mRALz6QnsQv/
         hK+6tl4ziYzeCvSlodC8LKd4T96frjEyQ68UuV5zxpRPRJarbib0biJwyD6IBjrJO4SQ
         2TYJt+oivRBmXqzLLmDOvvv37D8knTkIIf8BM6/wJgYrUKdMtIa0Tfo/SNQJgS8j9+i1
         JjFymozeXzIF/SwtFiGYHk22X7/7QjltiAPhOoHGeTc/8hxRI6senCczHLCJXHt0gUEB
         2epQ==
X-Gm-Message-State: APjAAAUw2Jew2gFbWMcmm54tWaQ4dZ/Inzq726orGpsF9DqtXg7vSbXW
	tBRlCUxcjT5/dTjPNsIeULnfz/ZV6DrPBTWqYqufqIrefLBZsb9NOICKhuVx8JYO0hcIqi9a868
	fv/5dZyHn14I4+WZ0rI1d5Z3hmXFUloN0jGX48RhtaBv+Z1SdMHdZTEHZeM+zIKU5dQ==
X-Received: by 2002:a81:5d5:: with SMTP id 204mr50268868ywf.78.1558720038940;
        Fri, 24 May 2019 10:47:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzH0CX4A8Cn9lMW8DPPcuU0zs3EgIJi+D3XkRA4+FzyfyZ3Ob2wl1FuFk6DSNVLO4b0ef8d
X-Received: by 2002:a81:5d5:: with SMTP id 204mr50268849ywf.78.1558720038220;
        Fri, 24 May 2019 10:47:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558720038; cv=none;
        d=google.com; s=arc-20160816;
        b=FLehdJIA68U4jjSVKWT/pXV1ZplI7sBCi0G+c3QKmnznZCqJKVXuRGajVrj89xF14/
         mRvxTLNnPu92kROBShTK39GJCyCZ91Mk/trteLuS44Et0Qsq7ca3QNG5zvApquzBbVQA
         k6eRGP5JbUP5b137m+S2swT8Ik1v5ihxnom6WaY9fWR8FPd98e5M6HUdq/n4o8D+b1+N
         sBHsmN++5cQJDqCsSY8EciqhEPQ0sNz5x6+JBaSxWSqETZRtWqt8lCndf3Lqq62jF7wT
         m+CphRUeeFXG6dDUI5uHOBeB9CmvK9V5laxqtgh5y3TN1Hy6q4OgtXThGynXYEtHVIcs
         0jCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=qRb0ajS0I8Fd/puP/J82uzs9SBibx4DBasaEA2ysW0w=;
        b=Grjc9inGpTynA3x4bRYQa1fJQDG3oE8NWEkrc4IQ7ikczWy7btMTuC/mg2KgIou5n0
         fA2VjUzyhAZArcRERaOwkGS9O5DC5hoIuA5tS+WMDODEDW05bGgnE5HFcNfDac9k688z
         EEjAiwNQZzJwWzTqqoXYP+K7lMqQ+r63Vkq27lFTuoBogHYFogqOij8zFFk67o1eWhJ0
         kxa5E0Wm83jOOXlJ8ywE1ZLz9VfwZ7XczSMbOyp4Iwdj+MVUAvflqp9gAYxOgQrUmiDr
         +citcTZyL67DondGMy137jMcv5gpG2wsPZcqUNf5L04FzhmRpYWyyi725aVnLlfXV681
         o+qg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=mTS5eeo9;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id 199si1035944ywr.323.2019.05.24.10.47.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 May 2019 10:47:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=mTS5eeo9;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5ce82e200000>; Fri, 24 May 2019 10:47:12 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Fri, 24 May 2019 10:47:17 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Fri, 24 May 2019 10:47:17 -0700
Received: from rcampbell-dev.nvidia.com (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 24 May
 2019 17:47:16 +0000
Subject: Re: [RFC PATCH 00/11] mm/hmm: Various revisions from a locking/code
 review
To: Jerome Glisse <jglisse@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>
CC: <linux-rdma@vger.kernel.org>, <linux-mm@kvack.org>, John Hubbard
	<jhubbard@nvidia.com>
References: <20190523153436.19102-1-jgg@ziepe.ca>
 <20190524143649.GA14258@ziepe.ca> <20190524164902.GA3346@redhat.com>
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <7f82b770-85a3-9b01-48b2-9e458191b8d6@nvidia.com>
Date: Fri, 24 May 2019 10:47:16 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190524164902.GA3346@redhat.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1558720032; bh=qRb0ajS0I8Fd/puP/J82uzs9SBibx4DBasaEA2ysW0w=;
	h=X-PGP-Universal:Subject:To:CC:References:From:Message-ID:Date:
	 User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=mTS5eeo9kN3Hn6cvGB3rhrBCAJphkmRKtKIm0oBTT3gSSakWE1OEEcCwn1DeWcuZR
	 wsd1Yd6uj3Z5UPuHWtELjKrC/xA7uosN+Yu/BCkak/he9/lISmHuEasWNGErEQWyye
	 +uPiIZ0O/eejIw5L2jvwBHzJwMUkMVA49044qNy98vdRViJAkSCuqc4mCsHG0IdJXk
	 ZHdCFah0g7xwsYAVScHQAL12h5Do+cMG5MWqI2/qeLWepRW+z7tYmB7G3DDEue+nDn
	 8TDRP+9QOR1Z63mmeQCllVxtEtRfHTnHcQtQn+hglLnSvcmzyUmVYj6gVfJmtsRXSt
	 wE83ETEw3CajQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 5/24/19 9:49 AM, Jerome Glisse wrote:
> On Fri, May 24, 2019 at 11:36:49AM -0300, Jason Gunthorpe wrote:
>> On Thu, May 23, 2019 at 12:34:25PM -0300, Jason Gunthorpe wrote:
>>> From: Jason Gunthorpe <jgg@mellanox.com>
>>>
>>> This patch series arised out of discussions with Jerome when looking =
at the
>>> ODP changes, particularly informed by use after free races we have al=
ready
>>> found and fixed in the ODP code (thanks to syzkaller) working with mm=
u
>>> notifiers, and the discussion with Ralph on how to resolve the lifeti=
me model.
>>
>> So the last big difference with ODP's flow is how 'range->valid'
>> works.
>>
>> In ODP this was done using the rwsem umem->umem_rwsem which is
>> obtained for read in invalidate_start and released in invalidate_end.
>>
>> Then any other threads that wish to only work on a umem which is not
>> undergoing invalidation will obtain the write side of the lock, and
>> within that lock's critical section the virtual address range is known=

>> to not be invalidating.
>>
>> I cannot understand how hmm gets to the same approach. It has
>> range->valid, but it is not locked by anything that I can see, so when=

>> we test it in places like hmm_range_fault it seems useless..
>>
>> Jerome, how does this work?
>>
>> I have a feeling we should copy the approach from ODP and use an
>> actual lock here.
>=20
> range->valid is use as bail early if invalidation is happening in
> hmm_range_fault() to avoid doing useless work. The synchronization
> is explained in the documentation:
>=20
>=20
> Locking within the sync_cpu_device_pagetables() callback is the most im=
portant
> aspect the driver must respect in order to keep things properly synchro=
nized.
> The usage pattern is::
>=20
>   int driver_populate_range(...)
>   {
>        struct hmm_range range;
>        ...
>=20
>        range.start =3D ...;
>        range.end =3D ...;
>        range.pfns =3D ...;
>        range.flags =3D ...;
>        range.values =3D ...;
>        range.pfn_shift =3D ...;
>        hmm_range_register(&range);
>=20
>        /*
>         * Just wait for range to be valid, safe to ignore return value =
as we
>         * will use the return value of hmm_range_snapshot() below under=
=20the
>         * mmap_sem to ascertain the validity of the range.
>         */
>        hmm_range_wait_until_valid(&range, TIMEOUT_IN_MSEC);
>=20
>   again:
>        down_read(&mm->mmap_sem);
>        ret =3D hmm_range_snapshot(&range);
>        if (ret) {
>            up_read(&mm->mmap_sem);
>            if (ret =3D=3D -EAGAIN) {
>              /*
>               * No need to check hmm_range_wait_until_valid() return va=
lue
>               * on retry we will get proper error with hmm_range_snapsh=
ot()
>               */
>              hmm_range_wait_until_valid(&range, TIMEOUT_IN_MSEC);
>              goto again;
>            }
>            hmm_range_unregister(&range);
>            return ret;
>        }
>        take_lock(driver->update);
>        if (!hmm_range_valid(&range)) {
>            release_lock(driver->update);
>            up_read(&mm->mmap_sem);
>            goto again;
>        }
>=20
>        // Use pfns array content to update device page table
>=20
>        hmm_range_unregister(&range);
>        release_lock(driver->update);
>        up_read(&mm->mmap_sem);
>        return 0;
>   }
>=20
> The driver->update lock is the same lock that the driver takes inside i=
ts
> sync_cpu_device_pagetables() callback. That lock must be held before ca=
lling
> hmm_range_valid() to avoid any race with a concurrent CPU page table up=
date.
>=20
>=20
> Cheers,
> J=C3=A9r=C3=B4me


Given the above, the following patch looks necessary to me.
Also, looking at drivers/gpu/drm/nouveau/nouveau_svm.c, it
doesn't check the return value to avoid calling up_read(&mm->mmap_sem).
Besides, it's better to keep the mmap_sem lock/unlock in the caller.

diff --git a/mm/hmm.c b/mm/hmm.c
index 836adf613f81..8b6ef97a8d71 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1092,10 +1092,8 @@ long hmm_range_fault(struct hmm_range *range,=20
bool block)

=20 	do {
=20 		/* If range is no longer valid force retry. */
-		if (!range->valid) {
-			up_read(&hmm->mm->mmap_sem);
+		if (!range->valid)
=20 			return -EAGAIN;
-		}

=20 		vma =3D find_vma(hmm->mm, start);
=20 		if (vma =3D=3D NULL || (vma->vm_flags & device_vma))

-------------------------------------------------------------------------=
----------
This email message is for the sole use of the intended recipient(s) and m=
ay contain
confidential information.  Any unauthorized review, use, disclosure or di=
stribution
is prohibited.  If you are not the intended recipient, please contact the=
=20sender by
reply email and destroy all copies of the original message.
-------------------------------------------------------------------------=
----------

