Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A104FC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 23:48:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 484AD20859
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 23:48:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="S8IIpL/H"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 484AD20859
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD44F8E0048; Wed, 20 Feb 2019 18:48:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C856F8E0002; Wed, 20 Feb 2019 18:48:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B4D138E0048; Wed, 20 Feb 2019 18:48:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8A0F38E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 18:48:06 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id d16so4293899ybs.3
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 15:48:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=jHAQ1S277wSPNw74bcLNCENbRjTn4cQT73HLzs0TA7s=;
        b=E2q1uym6R0YG+blYagSoBpLPlwmcGPzplgkuEIyNrW6EcPb6jpmMiBNornDEXsqwff
         C/PpJf9+c/k5CuiGz9H4xUUXjBIId0uakS/XXhabvu/2i/MmHHj6Mw2oi3X2QvH2E/Kx
         Wpzjd3Di6jAx0gYFzKtoiW1zDyocfZHWjXDT5ruGVvtleCN75LitLc49lyDfNH5TBnuc
         U4dxn/Ufl4lHQ4th2BUN5VfPu7hRPCpeLHTDNILmYUx2/izr0inB1c8H6hFlW6ZHRMD9
         ygO9kNtB8qh5Tb/1CmEgzEl8Kx5e4ih+a2Q6EZyQAS5hGDNc1Hlrzdm/LN4lo61iq2Xg
         Hqzw==
X-Gm-Message-State: AHQUAuaNGUAjyvnQgTC9FJv6i0rF54Nc+zIWXndcPuqX0BsLj1mXdPMX
	HJQStuPZhzbWINXHVitZ4EZDJwA2mO+Aud86Ej+mNMPvbgm33y8KoaIwiT62W0AaB+LS820uemK
	mfZsVnbqUy0p2VVpr5bsbQwn4OY+vsGMaIY6WMqHbpU+9Rref6XV0Zfqm8G1sKudhHQ==
X-Received: by 2002:a25:c805:: with SMTP id y5mr31530770ybf.68.1550706486268;
        Wed, 20 Feb 2019 15:48:06 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia9ZD3FenWuIzEgEg3eRfwWsVPg+c34lJu7IORdlb4dNDfZSZx1zwiGYEtiBYanqeU89ykG
X-Received: by 2002:a25:c805:: with SMTP id y5mr31530737ybf.68.1550706485555;
        Wed, 20 Feb 2019 15:48:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550706485; cv=none;
        d=google.com; s=arc-20160816;
        b=yTU67zFQiELSvR9DWhrs1Sugwmiid+f2erD0zj8u9/JYP2JCv37Z7SYK2/SEfPp5XH
         AGU4Y8l1rr8pi/DJvygL9RiAhvUmZru5FjhfO77adyxO4jpe2PYW7PkTd/vmnovaZw/9
         7Lfbcqjkk0QcwsO0X4Gz48J9lDIqAYrVsg/uA5UlZd608RJMnGGjhgwqEQ+iWqMG86LG
         mvdunwCCJtIQa/j/5INf2QvQXTTabf7zxZR125f/MiS3Ez2IqnI4n6O9bhmFeJcPgOeF
         QbBiPhw+MaYp4kbnH0CAc2dDs8PDzNGudAeWg1pEYR0mO7ODDykBpuBbiW26TLsT0OyL
         mFeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=jHAQ1S277wSPNw74bcLNCENbRjTn4cQT73HLzs0TA7s=;
        b=Rf+8myeRwuO74nvJL9KOoxrfUDxsERHAOrKxOsrMktx2hYX7cTAmlCdqAzIWI41zdi
         HmMKWTSO+mpKuA8pCAHVEXHhFipfni4BfY+vx8dp4yXP3CEZfiTDUoBoGeo8M0sgJpf3
         jSKnczWUkHZaLnJV1DA0OWV6PeHlZGU3vbeF0RT5ZX0gr3wREW2YvZ8MOwpG1aJVoBrQ
         M16QO8UDvOcZbf59nxqrXJLyUSMJ5VznK2HjKm3MyRrr4lQX3poynCN7zv2kKCybcWv+
         RhHc1hIgoI9qvfvWZkFHRh21h10ee3G9knee+Ge6xnr4YiXmvwIZN5C3OeDIzoQyVLbY
         BFFg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="S8IIpL/H";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id s195si11827067ybs.199.2019.02.20.15.48.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 15:48:05 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="S8IIpL/H";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c6de73d0000>; Wed, 20 Feb 2019 15:48:13 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Wed, 20 Feb 2019 15:48:04 -0800
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Wed, 20 Feb 2019 15:48:04 -0800
Received: from [10.2.169.124] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Wed, 20 Feb
 2019 23:48:01 +0000
Subject: Re: [PATCH 01/10] mm/hmm: use reference counting for HMM struct
To: <jglisse@redhat.com>, <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>,
	Andrew Morton <akpm@linux-foundation.org>
References: <20190129165428.3931-1-jglisse@redhat.com>
 <20190129165428.3931-2-jglisse@redhat.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <1373673d-721e-a7a2-166f-244c16f236a3@nvidia.com>
Date: Wed, 20 Feb 2019 15:47:50 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190129165428.3931-2-jglisse@redhat.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1550706493; bh=jHAQ1S277wSPNw74bcLNCENbRjTn4cQT73HLzs0TA7s=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=S8IIpL/Hp0VGxgHTwAkM2gbYHBrtTCjE3Yfp1s+vcLE6/tZcpI4EmwwOuuyTTwKJC
	 X60eczHn4cvEZrq8SFZtL62Qf6Fb3tKQC1K6avJSmN6HP6qlMNL6f8zQXE4+2BIWsB
	 uWbXwuwj/JiAaFZsWNABDJRNj4oNd/+RcIkjGJUNC6CnFzM4q8JRZrFTfk8F2bCmDT
	 SfXDR85wxL9uszLKCRw+Y/ToofuIDv06tBlx2gfsg11TC390l157HJj4q8UMQbtH0k
	 cUyKraxBfClV88yj6mvGTfqnNMMlS8i09pReH9DxmH+8HD/2qEeBqGd2PX2dPBUWeG
	 LQasmnrnYNX5A==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 1/29/19 8:54 AM, jglisse@redhat.com wrote:
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>=20
> Every time i read the code to check that the HMM structure does not
> vanish before it should thanks to the many lock protecting its removal
> i get a headache. Switch to reference counting instead it is much
> easier to follow and harder to break. This also remove some code that
> is no longer needed with refcounting.

Hi Jerome,

That is an excellent idea. Some review comments below:

[snip]

>   static int hmm_invalidate_range_start(struct mmu_notifier *mn,
>   			const struct mmu_notifier_range *range)
>   {
>   	struct hmm_update update;
> -	struct hmm *hmm =3D range->mm->hmm;
> +	struct hmm *hmm =3D hmm_get(range->mm);
> +	int ret;
>  =20
>   	VM_BUG_ON(!hmm);
>  =20
> +	/* Check if hmm_mm_destroy() was call. */
> +	if (hmm->mm =3D=3D NULL)
> +		return 0;

Let's delete that NULL check. It can't provide true protection. If there
is a way for that to race, we need to take another look at refcounting.

Is there a need for mmgrab()/mmdrop(), to keep the mm around while HMM
is using it?


> +
>   	update.start =3D range->start;
>   	update.end =3D range->end;
>   	update.event =3D HMM_UPDATE_INVALIDATE;
>   	update.blockable =3D range->blockable;
> -	return hmm_invalidate_range(hmm, true, &update);
> +	ret =3D hmm_invalidate_range(hmm, true, &update);
> +	hmm_put(hmm);
> +	return ret;
>   }
>  =20
>   static void hmm_invalidate_range_end(struct mmu_notifier *mn,
>   			const struct mmu_notifier_range *range)
>   {
>   	struct hmm_update update;
> -	struct hmm *hmm =3D range->mm->hmm;
> +	struct hmm *hmm =3D hmm_get(range->mm);
>  =20
>   	VM_BUG_ON(!hmm);
>  =20
> +	/* Check if hmm_mm_destroy() was call. */
> +	if (hmm->mm =3D=3D NULL)
> +		return;
> +

Another one to delete, same reasoning as above.

[snip]

> @@ -717,14 +746,18 @@ int hmm_vma_get_pfns(struct hmm_range *range)
>   	hmm =3D hmm_register(vma->vm_mm);
>   	if (!hmm)
>   		return -ENOMEM;
> -	/* Caller must have registered a mirror, via hmm_mirror_register() ! */
> -	if (!hmm->mmu_notifier.ops)
> +
> +	/* Check if hmm_mm_destroy() was call. */
> +	if (hmm->mm =3D=3D NULL) {
> +		hmm_put(hmm);
>   		return -EINVAL;
> +	}
>  =20

Another hmm->mm NULL check to remove.

[snip]
> @@ -802,25 +842,27 @@ EXPORT_SYMBOL(hmm_vma_get_pfns);
>    */
>   bool hmm_vma_range_done(struct hmm_range *range)
>   {
> -	unsigned long npages =3D (range->end - range->start) >> PAGE_SHIFT;
> -	struct hmm *hmm;
> +	bool ret =3D false;
>  =20
> -	if (range->end <=3D range->start) {
> +	/* Sanity check this really should not happen. */
> +	if (range->hmm =3D=3D NULL || range->end <=3D range->start) {
>   		BUG();
>   		return false;
>   	}
>  =20
> -	hmm =3D hmm_register(range->vma->vm_mm);
> -	if (!hmm) {
> -		memset(range->pfns, 0, sizeof(*range->pfns) * npages);
> -		return false;
> -	}
> -
> -	spin_lock(&hmm->lock);
> +	spin_lock(&range->hmm->lock);
>   	list_del_rcu(&range->list);
> -	spin_unlock(&hmm->lock);
> +	ret =3D range->valid;
> +	spin_unlock(&range->hmm->lock);
>  =20
> -	return range->valid;
> +	/* Is the mm still alive ? */
> +	if (range->hmm->mm =3D=3D NULL)
> +		ret =3D false;


And another one here.


> +
> +	/* Drop reference taken by hmm_vma_fault() or hmm_vma_get_pfns() */
> +	hmm_put(range->hmm);
> +	range->hmm =3D NULL;
> +	return ret;
>   }
>   EXPORT_SYMBOL(hmm_vma_range_done);
>  =20
> @@ -880,6 +922,8 @@ int hmm_vma_fault(struct hmm_range *range, bool block=
)
>   	struct hmm *hmm;
>   	int ret;
>  =20
> +	range->hmm =3D NULL;
> +
>   	/* Sanity check, this really should not happen ! */
>   	if (range->start < vma->vm_start || range->start >=3D vma->vm_end)
>   		return -EINVAL;
> @@ -891,14 +935,18 @@ int hmm_vma_fault(struct hmm_range *range, bool blo=
ck)
>   		hmm_pfns_clear(range, range->pfns, range->start, range->end);
>   		return -ENOMEM;
>   	}
> -	/* Caller must have registered a mirror using hmm_mirror_register() */
> -	if (!hmm->mmu_notifier.ops)
> +
> +	/* Check if hmm_mm_destroy() was call. */
> +	if (hmm->mm =3D=3D NULL) {
> +		hmm_put(hmm);
>   		return -EINVAL;
> +	}

And here.

>  =20
>   	/* FIXME support hugetlb fs */
>   	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL) ||
>   			vma_is_dax(vma)) {
>   		hmm_pfns_special(range);
> +		hmm_put(hmm);
>   		return -EINVAL;
>   	}
>  =20
> @@ -910,6 +958,7 @@ int hmm_vma_fault(struct hmm_range *range, bool block=
)
>   		 * operations such has atomic access would not work.
>   		 */
>   		hmm_pfns_clear(range, range->pfns, range->start, range->end);
> +		hmm_put(hmm);
>   		return -EPERM;
>   	}
>  =20
> @@ -945,7 +994,16 @@ int hmm_vma_fault(struct hmm_range *range, bool bloc=
k)
>   		hmm_pfns_clear(range, &range->pfns[i], hmm_vma_walk.last,
>   			       range->end);
>   		hmm_vma_range_done(range);
> +		hmm_put(hmm);
> +	} else {
> +		/*
> +		 * Transfer hmm reference to the range struct it will be drop
> +		 * inside the hmm_vma_range_done() function (which _must_ be
> +		 * call if this function return 0).
> +		 */
> +		range->hmm =3D hmm;

Is that thread-safe? Is there anything preventing two or more threads from
changing range->hmm at the same time?



thanks,
--=20
John Hubbard
NVIDIA

