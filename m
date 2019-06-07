Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B7ADC2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 19:01:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E0DD20868
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 19:01:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="lijWUGub"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E0DD20868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ECF8D6B0005; Fri,  7 Jun 2019 15:01:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E80136B0006; Fri,  7 Jun 2019 15:01:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D97436B000A; Fri,  7 Jun 2019 15:01:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id BAB076B0005
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 15:01:49 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id l184so2843805ybl.3
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 12:01:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=Kx8oCHq1Rv6wVMPa9pb6SeAWwPMNVFkybn8lVkznCEc=;
        b=bQtyPZg9OYwmzLT7sWaZardtFKlNcCVEFfJjNtDSIx+Lg16Y6cdN9cBZEGsPpd/aeQ
         tYeU+GrZxkVa2gomQ5QUfZaoG51Ktup9WWoTog7pttoKpMqFy8Sm2TpI7aaBVTvBGy+6
         9pDwtOD13eute9NStb0+cpP0e0TerjxNeky+tDlkNZ0mtrajhBfo4kWfTw9t22A/BTON
         PaaovN/9fiWLtMMUn43pdmjHQE6MJrOnq+GPN7jTfTHjt1naG9q2m0vglINvr+cJIidF
         8VhYNJsOUDmled6+iMDy0dO7vnDsu5/u8UE6hLrZSVIfKu6bp7lm7+j+kYb/cABAf7HY
         m6bw==
X-Gm-Message-State: APjAAAXD2jvj0nwbR/TofpabRcSXPdAhzDOU4xq3QOEAaejwwONYQO+i
	R+J5ZIg2gV5oBsUhJ7aGGcYe/VTmoowTexgFg996XVZqymCD95mRMSoaN0wAtmUZloFtpRO5LAZ
	HvpSPzhxrCx7I6NBQrj48UEuTN4VNmSaw9IKi/JIm4/WAubqVk0iVw5gfBarqCaUcgA==
X-Received: by 2002:a81:348:: with SMTP id 69mr30552806ywd.384.1559934109484;
        Fri, 07 Jun 2019 12:01:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxzom+3pvHYQuAfSpIl7vzrANGdj13V60ujcl8xwmqcUge9TipjXksFKWzZczULap3Gdb/F
X-Received: by 2002:a81:348:: with SMTP id 69mr30552753ywd.384.1559934108782;
        Fri, 07 Jun 2019 12:01:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559934108; cv=none;
        d=google.com; s=arc-20160816;
        b=S4OowwmoUfL4NZvTFeqNTUTL6KFg4zFJsY31UPe5wyzcIjlHFxgsbNN3+iG+TXtYht
         sbjj8qwHPb8+R29KZbTyQUqtOELJnZmyk2zINkI1nr2D9bSsiHDRBycqU0hxEdxLc0fJ
         HgVRpiVvViMUD3Cv0F7gaDmQ6tIS4hVi90XZEUIxYA7uRwBMKNza7QqdbuqrD+4xZJLu
         6U0K5+0DIerCu2znMF0GWdZ4zsWnQJLxuaeUBSq7AHWpSigKkroXehMwEi+3fVhv50BL
         yei5pgmgnGQDvYxozZKxSTX5w+K4cOOmBOVD1YwylGKuPE5zY1biJy1keKiL4xZFK7s+
         Cf1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=Kx8oCHq1Rv6wVMPa9pb6SeAWwPMNVFkybn8lVkznCEc=;
        b=L3TLCQQ+/8rdrbGvB8kpTalXw3OXT8BcNHMJhI8pW27BbVzzhBPJRx9nPvwdR9g8A3
         DoC/XcavDWKgNMsCY9Ln0C664ld6jvmegcNRYFpiA7UhdO+/Th3L+AhGC9+S9bvU/0Hs
         jTQ5TzvprsUkp+iAeg1KcRU29vUPR+T4NrWcLN5jkd7qAP5sQBdvLKejT3ukqpf+/whp
         nBTNl2PAff4WaEOGfIllFtKz0u24ME84ygnuRu9rBD0o3TM0pmlnn3SeV0hCq6UxgPc+
         TVUgWdJWmj4YlojHwCBmggaAfYpZn8TU8YUQxqKS3mDvRpIyxTtSDOiTupp0ZPRo3Yd9
         dSJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=lijWUGub;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id e21si822486ybh.81.2019.06.07.12.01.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 12:01:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=lijWUGub;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cfab4990002>; Fri, 07 Jun 2019 12:01:45 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 07 Jun 2019 12:01:47 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 07 Jun 2019 12:01:47 -0700
Received: from rcampbell-dev.nvidia.com (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 7 Jun
 2019 19:01:45 +0000
Subject: Re: [PATCH v2 hmm 05/11] mm/hmm: Remove duplicate condition test
 before wait_event_timeout
To: Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, "John
 Hubbard" <jhubbard@nvidia.com>, <Felix.Kuehling@amd.com>
CC: <linux-rdma@vger.kernel.org>, <linux-mm@kvack.org>, Andrea Arcangeli
	<aarcange@redhat.com>, <dri-devel@lists.freedesktop.org>,
	<amd-gfx@lists.freedesktop.org>, Jason Gunthorpe <jgg@mellanox.com>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-6-jgg@ziepe.ca>
From: Ralph Campbell <rcampbell@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <6833be96-12a3-1a1c-1514-c148ba2dd87b@nvidia.com>
Date: Fri, 7 Jun 2019 12:01:45 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190606184438.31646-6-jgg@ziepe.ca>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559934105; bh=Kx8oCHq1Rv6wVMPa9pb6SeAWwPMNVFkybn8lVkznCEc=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=lijWUGubJCR64HCSORX4QLqG3zil2s0//JM6B87DqP7lBJ5ltD/J/GDcaS3G2ZX2e
	 gWemy5KFFY6h0iVAOYTmbphNBWI/LDNjC6c0xgS+2/+yBQohtbcmyE4AlfFOXpHeLQ
	 4YgDqKoU4mYZGqM+umLyKSpCK/E7doCn27H3GCULDP4SwQcK4nXs8qHf75pHYEke5V
	 rctRDR3GL/NH60mIG08uN5KRkBfiy+JXJoWm1LmB7A9hM2vDBjKAbzjpZxeZ8ZiLKT
	 8GMvc9iw2Ylz1UmEP1JPMDGnTs0Sr5zjQDRTNK9WwdjtY1TvsxYmK0vrSaq1WqcRhY
	 Z6k1iCiG9xexw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 6/6/19 11:44 AM, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
>=20
> The wait_event_timeout macro already tests the condition as its first
> action, so there is no reason to open code another version of this, all
> that does is skip the might_sleep() debugging in common cases, which is
> not helpful.
>=20
> Further, based on prior patches, we can no simplify the required conditio=
n
> test:
>   - If range is valid memory then so is range->hmm
>   - If hmm_release() has run then range->valid is set to false
>     at the same time as dead, so no reason to check both.
>   - A valid hmm has a valid hmm->mm.
>=20
> Also, add the READ_ONCE for range->valid as there is no lock held here.
>=20
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> Reviewed-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> ---
>   include/linux/hmm.h | 12 ++----------
>   1 file changed, 2 insertions(+), 10 deletions(-)
>=20
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 4ee3acabe5ed22..2ab35b40992b24 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -218,17 +218,9 @@ static inline unsigned long hmm_range_page_size(cons=
t struct hmm_range *range)
>   static inline bool hmm_range_wait_until_valid(struct hmm_range *range,
>   					      unsigned long timeout)
>   {
> -	/* Check if mm is dead ? */
> -	if (range->hmm =3D=3D NULL || range->hmm->dead || range->hmm->mm =3D=3D=
 NULL) {
> -		range->valid =3D false;
> -		return false;
> -	}
> -	if (range->valid)
> -		return true;
> -	wait_event_timeout(range->hmm->wq, range->valid || range->hmm->dead,
> +	wait_event_timeout(range->hmm->wq, range->valid,
>   			   msecs_to_jiffies(timeout));
> -	/* Return current valid status just in case we get lucky */
> -	return range->valid;
> +	return READ_ONCE(range->valid);
>   }
>  =20
>   /*
>=20

Since we are simplifying things, perhaps we should consider merging
hmm_range_wait_until_valid() info hmm_range_register() and
removing hmm_range_wait_until_valid() since the pattern
is to always call the two together.

In any case, this looks OK to me so you can add
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

