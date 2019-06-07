Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C544C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 18:41:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 07646208C0
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 18:41:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="Wkrw1snf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 07646208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A4BD56B0005; Fri,  7 Jun 2019 14:41:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9FC8D6B0006; Fri,  7 Jun 2019 14:41:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C4E06B000A; Fri,  7 Jun 2019 14:41:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6EC666B0005
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 14:41:24 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id l184so2799971ybl.3
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 11:41:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=BXL7/wF1685JXXTrRB3MzSSsbcW5afztk5Rzsz/BPwQ=;
        b=Lcs0dxZiheatEgSRwuJeTL/hBTd50CLsefLX/vUW7bmEvKP/PHaGl7AdAS2CTUcwpu
         I/dMbwVajpPHGphlJvvjRB9SI75K2kKqAL2VMQhBwoGQrv/mrbPsLChy11pSMLvt+j4v
         VYohfltFLhSJJGPsatEikHBqMD1ZKpV/Fh2rrMdEmxyMO/yiGgg2zojWktP62iA07YOR
         KVai3mXv6FahHECtBhi1MT2k23BcaO2J0mzCunh1aSZ8yw46uBGMNYHwMY39E4pV28Qj
         jRdJKCv0pUr7RNvWm986bJLiyeyxburXPiXpJmcT0mxMDwPu9pjXuA48Rfa/wxVSl+el
         3PsQ==
X-Gm-Message-State: APjAAAUatn9AOwBA3jkezlnr7bWayRRzO+HVyVCZJn/HTxv8/RNYI7fK
	dWp/3h61V427FS31iNwgM30ez7xctfwHmC84u37eVsr9R68/JRAe4zs6nI6y4PDwDnoFUOVLPy2
	EyAbxIRFIBACZp+REukcJApCfx0GwnWoufqvHUL6oBPYjrFk+GyW7ZSN1PkUFHUwoWA==
X-Received: by 2002:a25:8703:: with SMTP id a3mr24183105ybl.231.1559932884166;
        Fri, 07 Jun 2019 11:41:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyVjblxao9UQAeMbjHy6126AHMS7M+a6+WZFTBrZ/qj7Rp9OqQgUZDv1Ucd/X1l3tpqSoaE
X-Received: by 2002:a25:8703:: with SMTP id a3mr24183087ybl.231.1559932883497;
        Fri, 07 Jun 2019 11:41:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559932883; cv=none;
        d=google.com; s=arc-20160816;
        b=wxQmxwpg/1rnzQgMpZymW5KLh1vmN75H3BxlMvxC0E+WOMIziK5/lSn9hG8QUPFIwA
         HQiGZDb1yvZL3Ejrs2M7/QdecwPYzkarLcagxYbnzwDAhTLN0OgWNnhO193pwzPSkFJE
         rBC1qLnvx2lGToWTB+K32ZFKp//LQ/pT3ExSNDyi0dDPX6w6PvDvGo6IC8EK4KzhbrDb
         Xy4REsrYnKSkynoEg8Ep6F2IHEiNIhvHJMKnY4YyD/0acAL5EL4XUIRIizKYf/fzR3VS
         yku6Dmn7Gi8NneMzNuSm29XeOIBhfSWybA95rM/1GmnlaTntvz0sVzVFPwjEcg8PiDIH
         yUXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=BXL7/wF1685JXXTrRB3MzSSsbcW5afztk5Rzsz/BPwQ=;
        b=NwozhYGnugUPKIfgDGqLquXwnlWfhz9AARfz4nk5dfBDr45875bznMiu2JbK5eLLrq
         io4siV+ITKPg5VDTEuV9cAKUaLlLVCSY/kav78Y15qlEi3Fqs+QjrO2GJR8XlnXTIBlD
         RaQ9nFiy7ku2KNZvEJiI9l3vhJL+0JHHXEzw0rLDPSOq+bHmdRmbmOoIjAjLOPC5kTdr
         6Fde7Ex2BrPJKVOs3FQ/AccyKqRo9+9DDO8MPZ+WvwHDsns1jJHakFGGbus+seC6iRIR
         WZ3SSBerNUNlu0V0F/lAbLO458weC5O/oiINrIRfG4NOslP7d6499MhMXn76qKfNwUIe
         JPjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Wkrw1snf;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id 84si764740ybz.117.2019.06.07.11.41.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 11:41:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Wkrw1snf;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cfaafd20001>; Fri, 07 Jun 2019 11:41:22 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 07 Jun 2019 11:41:22 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 07 Jun 2019 11:41:22 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 7 Jun
 2019 18:41:21 +0000
Subject: Re: [PATCH v2 hmm 03/11] mm/hmm: Hold a mmgrab from hmm to mm
To: Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, "John
 Hubbard" <jhubbard@nvidia.com>, <Felix.Kuehling@amd.com>
CC: <linux-rdma@vger.kernel.org>, <linux-mm@kvack.org>, Andrea Arcangeli
	<aarcange@redhat.com>, <dri-devel@lists.freedesktop.org>,
	<amd-gfx@lists.freedesktop.org>, Jason Gunthorpe <jgg@mellanox.com>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-4-jgg@ziepe.ca>
From: Ralph Campbell <rcampbell@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <605172dc-5c66-123f-61a3-8e6880678aef@nvidia.com>
Date: Fri, 7 Jun 2019 11:41:20 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190606184438.31646-4-jgg@ziepe.ca>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559932882; bh=BXL7/wF1685JXXTrRB3MzSSsbcW5afztk5Rzsz/BPwQ=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=Wkrw1snfHAMLfoxwtDrAaK5NrPSHE8tbm/7LuFI2XQAtYTox/3q2xrehM2lJJL18q
	 P/lK/orwO3+mod6CKV0QZm78jJRxIKuvbNOsQZhdd+1yRIPKKDJpL5YWOhc9vnhKch
	 UWKavQ8B/OXpV8YxtD2Qxuz8CaPCy8NIu1DMnM0y/udqNHlRe/2PVTqjEHpPLOTT8Z
	 m2SvCKaGpDUPdJbPo5rTpLyBiA5MJ07nzuPSxth9C5xwlF0gz+O9RKbQZjerlG99CH
	 yhyMU5sdcUbqnd3nDCzFo4CZyHozRpUrUPNHp9dYtOryQgA8jcqcd5zND+0Xlcs0Xq
	 ulL1B4XzCIYwA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 6/6/19 11:44 AM, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
>=20
> So long a a struct hmm pointer exists, so should the struct mm it is

s/a a/as a/

> linked too. Hold the mmgrab() as soon as a hmm is created, and mmdrop() i=
t
> once the hmm refcount goes to zero.
>=20
> Since mmdrop() (ie a 0 kref on struct mm) is now impossible with a !NULL
> mm->hmm delete the hmm_hmm_destroy().
>=20
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> Reviewed-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>

Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

> ---
> v2:
>   - Fix error unwind paths in hmm_get_or_create (Jerome/Jason)
> ---
>   include/linux/hmm.h |  3 ---
>   kernel/fork.c       |  1 -
>   mm/hmm.c            | 22 ++++------------------
>   3 files changed, 4 insertions(+), 22 deletions(-)
>=20
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 2d519797cb134a..4ee3acabe5ed22 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -586,14 +586,11 @@ static inline int hmm_vma_fault(struct hmm_mirror *=
mirror,
>   }
>  =20
>   /* Below are for HMM internal use only! Not to be used by device driver=
! */
> -void hmm_mm_destroy(struct mm_struct *mm);
> -
>   static inline void hmm_mm_init(struct mm_struct *mm)
>   {
>   	mm->hmm =3D NULL;
>   }
>   #else /* IS_ENABLED(CONFIG_HMM_MIRROR) */
> -static inline void hmm_mm_destroy(struct mm_struct *mm) {}
>   static inline void hmm_mm_init(struct mm_struct *mm) {}
>   #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
>  =20
> diff --git a/kernel/fork.c b/kernel/fork.c
> index b2b87d450b80b5..588c768ae72451 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -673,7 +673,6 @@ void __mmdrop(struct mm_struct *mm)
>   	WARN_ON_ONCE(mm =3D=3D current->active_mm);
>   	mm_free_pgd(mm);
>   	destroy_context(mm);
> -	hmm_mm_destroy(mm);
>   	mmu_notifier_mm_destroy(mm);
>   	check_mm(mm);
>   	put_user_ns(mm->user_ns);
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 8796447299023c..cc7c26fda3300e 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -29,6 +29,7 @@
>   #include <linux/swapops.h>
>   #include <linux/hugetlb.h>
>   #include <linux/memremap.h>
> +#include <linux/sched/mm.h>
>   #include <linux/jump_label.h>
>   #include <linux/dma-mapping.h>
>   #include <linux/mmu_notifier.h>
> @@ -82,6 +83,7 @@ static struct hmm *hmm_get_or_create(struct mm_struct *=
mm)
>   	hmm->notifiers =3D 0;
>   	hmm->dead =3D false;
>   	hmm->mm =3D mm;
> +	mmgrab(hmm->mm);
>  =20
>   	spin_lock(&mm->page_table_lock);
>   	if (!mm->hmm)
> @@ -109,6 +111,7 @@ static struct hmm *hmm_get_or_create(struct mm_struct=
 *mm)
>   		mm->hmm =3D NULL;
>   	spin_unlock(&mm->page_table_lock);
>   error:
> +	mmdrop(hmm->mm);
>   	kfree(hmm);
>   	return NULL;
>   }
> @@ -130,6 +133,7 @@ static void hmm_free(struct kref *kref)
>   		mm->hmm =3D NULL;
>   	spin_unlock(&mm->page_table_lock);
>  =20
> +	mmdrop(hmm->mm);
>   	mmu_notifier_call_srcu(&hmm->rcu, hmm_free_rcu);
>   }
>  =20
> @@ -138,24 +142,6 @@ static inline void hmm_put(struct hmm *hmm)
>   	kref_put(&hmm->kref, hmm_free);
>   }
>  =20
> -void hmm_mm_destroy(struct mm_struct *mm)
> -{
> -	struct hmm *hmm;
> -
> -	spin_lock(&mm->page_table_lock);
> -	hmm =3D mm_get_hmm(mm);
> -	mm->hmm =3D NULL;
> -	if (hmm) {
> -		hmm->mm =3D NULL;
> -		hmm->dead =3D true;
> -		spin_unlock(&mm->page_table_lock);
> -		hmm_put(hmm);
> -		return;
> -	}
> -
> -	spin_unlock(&mm->page_table_lock);
> -}
> -
>   static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
>   {
>   	struct hmm *hmm =3D container_of(mn, struct hmm, mmu_notifier);
>=20

