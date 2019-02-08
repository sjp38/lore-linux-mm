Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7DAC5C169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 21:06:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35975218D2
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 21:06:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35975218D2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C81808E009E; Fri,  8 Feb 2019 16:06:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C330F8E009B; Fri,  8 Feb 2019 16:06:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B22128E009E; Fri,  8 Feb 2019 16:06:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 857048E009B
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 16:06:00 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id m37so4990104qte.10
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 13:06:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to;
        bh=LwIs/eNZM8fTdlMZS7uaaFPc22Bj/0ybNhhbaM1sHzI=;
        b=gimTk+acuOSJYgDTLrmVKPmvu+bKxAjzZyYkop2TXZqtOTixXub4ctTXT9pQCOGehV
         RTbf19Zp+4IBPAv+2tCRdiB1Ol0ZxWDw+oHVGiYfh8S75auLpa3xTT6g+nkFOeVpo7vv
         1o+NlOG7cbh8H6Y46odtWr0C3oeWcCHgTa1BH4xC30uoEjr7IGeIgKdr9DULGzbC5C6T
         KTV6TNa8EgSXLZxQgV1lvqQtptZyQIw939sfBHn3ta+GMaCrkieR3eVQSS/PCqvcJVrJ
         TjwN60J1mXEQG5+zPzlni2BkLZf0hVGdimL32nyDFVrhVyFrCHGL4s/Cv+lgUwnqAd9M
         65EA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuYXY6DSkp0PM7M6yihzKYoCPwffio89CfpdslGefFkp6tQgKYxB
	hrzVEkSfVsB5ziaEKZj9yt/3WLWUhru/CGYY1Osh2WXu1Bs26/7BIf/h5SoRjdnbvDBJA8n8h4T
	BKmgAjUJg7I2z3PwF0blYdMKygX41ustoFhriwaqUHxec23EofHSBsaR6LYxCMvaRNg==
X-Received: by 2002:ac8:4792:: with SMTP id k18mr18175366qtq.294.1549659960300;
        Fri, 08 Feb 2019 13:06:00 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbLpow3YBRZo6OM+hF8GwluZWLQRjvohhnLLn/coJfDuKJcIE2dY8ToKvl16zL/8McP1ed8
X-Received: by 2002:ac8:4792:: with SMTP id k18mr18175333qtq.294.1549659959809;
        Fri, 08 Feb 2019 13:05:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549659959; cv=none;
        d=google.com; s=arc-20160816;
        b=QAtJGVN7RztG3QmI+Sir+yJdQP28xKO49buat3xlIGJpWR5txhs9tk4sGaOeBlHz9/
         Z+bioEpraP/6psKa1X3+2rg7uaPCYh5TWCWmzZg2hhVdUWdh2gEFMr22pL/fHzvjFOlC
         sJkyJD2Gbk8K91BeiCAAcc2xMRwgAoZ//U+Ke6hmrLr9a+Kavomg2JvggUnAbiI2h0t4
         vxwz7hWcka0YvtsjrJyJuYWe6X7xDfMbsI7UWuDMaGF2GEj9LaqAqSI1x/4DmFntMNAN
         YcZupq/VKgiwxBo7l09qSlO01aAzkOq9loQpgywWhfjav35ZoH9vZFTtbqMqkhSYQInE
         3y/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:user-agent:date:message-id:organization
         :autocrypt:openpgp:from:references:cc:to:subject;
        bh=LwIs/eNZM8fTdlMZS7uaaFPc22Bj/0ybNhhbaM1sHzI=;
        b=Cn6wJTvAGY4AYzILupMdJ2qdWRmTlrCC/W72E9Bq/Y5njGHvukUxjxZlZT7k/oa1Jl
         zJequ78M5b4bCYzxBxXUfSUZx9lyVg9KOpjTUAnu8Dxa3tJn8rH6XUj4LK9Dn7QxTaQH
         pKGBcY1NU6fy8KZQfA2KLSWpkbi8bHGvfPQiHqF909VMUyCLpjO6fW2jojUuljbvfuZ4
         L6sCYtncX079MnFuEzKYHvWErVq6nbEpHEtVuBbM5wOw0JWW2GNmFleNj6AZtCFdpXfd
         gNm3l4azLtbdD87kf7yTF0LseEROki2HbrBkuvBIAXpkbNjhUvSlZFNhSwjx6MF3x3HQ
         /JsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v128si2365390qki.86.2019.02.08.13.05.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Feb 2019 13:05:59 -0800 (PST)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BD18459478;
	Fri,  8 Feb 2019 21:05:58 +0000 (UTC)
Received: from [10.40.206.40] (unknown [10.40.206.40])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id E8CF21852C;
	Fri,  8 Feb 2019 21:05:50 +0000 (UTC)
Subject: Re: [RFC PATCH 3/4] kvm: Add guest side support for free memory hints
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>,
 Luiz Capitulino <lcapitulino@redhat.com>,
 Alexander Duyck <alexander.duyck@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
 rkrcmar@redhat.com, x86@kernel.org, mingo@redhat.com, bp@alien8.de,
 hpa@zytor.com, pbonzini@redhat.com, tglx@linutronix.de,
 akpm@linux-foundation.org
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
 <20190204181552.12095.46287.stgit@localhost.localdomain>
 <20190207132104.17a296da@doriath>
 <34c93e5a05a7dc93e38364733f8832f2e1b2dcb3.camel@linux.intel.com>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <5f5c03ac-0d21-d92b-1772-f26773437019@redhat.com>
Date: Fri, 8 Feb 2019 16:05:48 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <34c93e5a05a7dc93e38364733f8832f2e1b2dcb3.camel@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="buBbfmkGrgb9qyScBYbGXuzydHVEykMEJ"
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Fri, 08 Feb 2019 21:05:59 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--buBbfmkGrgb9qyScBYbGXuzydHVEykMEJ
Content-Type: multipart/mixed; boundary="DbNdtYN4o8nLIgLlGD1ViUxA0kuqQwqic";
 protected-headers="v1"
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>,
 Luiz Capitulino <lcapitulino@redhat.com>,
 Alexander Duyck <alexander.duyck@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
 rkrcmar@redhat.com, x86@kernel.org, mingo@redhat.com, bp@alien8.de,
 hpa@zytor.com, pbonzini@redhat.com, tglx@linutronix.de,
 akpm@linux-foundation.org
Message-ID: <5f5c03ac-0d21-d92b-1772-f26773437019@redhat.com>
Subject: Re: [RFC PATCH 3/4] kvm: Add guest side support for free memory hints
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
 <20190204181552.12095.46287.stgit@localhost.localdomain>
 <20190207132104.17a296da@doriath>
 <34c93e5a05a7dc93e38364733f8832f2e1b2dcb3.camel@linux.intel.com>
In-Reply-To: <34c93e5a05a7dc93e38364733f8832f2e1b2dcb3.camel@linux.intel.com>

--DbNdtYN4o8nLIgLlGD1ViUxA0kuqQwqic
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US


On 2/7/19 1:44 PM, Alexander Duyck wrote:
> On Thu, 2019-02-07 at 13:21 -0500, Luiz Capitulino wrote:
>> On Mon, 04 Feb 2019 10:15:52 -0800
>> Alexander Duyck <alexander.duyck@gmail.com> wrote:
>>
>>> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>>>
>>> Add guest support for providing free memory hints to the KVM hypervis=
or for
>>> freed pages huge TLB size or larger. I am restricting the size to
>>> huge TLB order and larger because the hypercalls are too expensive to=
 be
>>> performing one per 4K page. Using the huge TLB order became the obvio=
us
>>> choice for the order to use as it allows us to avoid fragmentation of=
 higher
>>> order memory on the host.
>>>
>>> I have limited the functionality so that it doesn't work when page
>>> poisoning is enabled. I did this because a write to the page after do=
ing an
>>> MADV_DONTNEED would effectively negate the hint, so it would be wasti=
ng
>>> cycles to do so.
>>>
>>> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>>> ---
>>>  arch/x86/include/asm/page.h |   13 +++++++++++++
>>>  arch/x86/kernel/kvm.c       |   23 +++++++++++++++++++++++
>>>  2 files changed, 36 insertions(+)
>>>
>>> diff --git a/arch/x86/include/asm/page.h b/arch/x86/include/asm/page.=
h
>>> index 7555b48803a8..4487ad7a3385 100644
>>> --- a/arch/x86/include/asm/page.h
>>> +++ b/arch/x86/include/asm/page.h
>>> @@ -18,6 +18,19 @@
>>> =20
>>>  struct page;
>>> =20
>>> +#ifdef CONFIG_KVM_GUEST
>>> +#include <linux/jump_label.h>
>>> +extern struct static_key_false pv_free_page_hint_enabled;
>>> +
>>> +#define HAVE_ARCH_FREE_PAGE
>>> +void __arch_free_page(struct page *page, unsigned int order);
>>> +static inline void arch_free_page(struct page *page, unsigned int or=
der)
>>> +{
>>> +	if (static_branch_unlikely(&pv_free_page_hint_enabled))
>>> +		__arch_free_page(page, order);
>>> +}
>>> +#endif
>>> +
>>>  #include <linux/range.h>
>>>  extern struct range pfn_mapped[];
>>>  extern int nr_pfn_mapped;
>>> diff --git a/arch/x86/kernel/kvm.c b/arch/x86/kernel/kvm.c
>>> index 5c93a65ee1e5..09c91641c36c 100644
>>> --- a/arch/x86/kernel/kvm.c
>>> +++ b/arch/x86/kernel/kvm.c
>>> @@ -48,6 +48,7 @@
>>>  #include <asm/tlb.h>
>>> =20
>>>  static int kvmapf =3D 1;
>>> +DEFINE_STATIC_KEY_FALSE(pv_free_page_hint_enabled);
>>> =20
>>>  static int __init parse_no_kvmapf(char *arg)
>>>  {
>>> @@ -648,6 +649,15 @@ static void __init kvm_guest_init(void)
>>>  	if (kvm_para_has_feature(KVM_FEATURE_PV_EOI))
>>>  		apic_set_eoi_write(kvm_guest_apic_eoi_write);
>>> =20
>>> +	/*
>>> +	 * The free page hinting doesn't add much value if page poisoning
>>> +	 * is enabled. So we only enable the feature if page poisoning is
>>> +	 * no present.
>>> +	 */
>>> +	if (!page_poisoning_enabled() &&
>>> +	    kvm_para_has_feature(KVM_FEATURE_PV_UNUSED_PAGE_HINT))
>>> +		static_branch_enable(&pv_free_page_hint_enabled);
>>> +
>>>  #ifdef CONFIG_SMP
>>>  	smp_ops.smp_prepare_cpus =3D kvm_smp_prepare_cpus;
>>>  	smp_ops.smp_prepare_boot_cpu =3D kvm_smp_prepare_boot_cpu;
>>> @@ -762,6 +772,19 @@ static __init int kvm_setup_pv_tlb_flush(void)
>>>  }
>>>  arch_initcall(kvm_setup_pv_tlb_flush);
>>> =20
>>> +void __arch_free_page(struct page *page, unsigned int order)
>>> +{
>>> +	/*
>>> +	 * Limit hints to blocks no smaller than pageblock in
>>> +	 * size to limit the cost for the hypercalls.
>>> +	 */
>>> +	if (order < KVM_PV_UNUSED_PAGE_HINT_MIN_ORDER)
>>> +		return;
>>> +
>>> +	kvm_hypercall2(KVM_HC_UNUSED_PAGE_HINT, page_to_phys(page),
>>> +		       PAGE_SIZE << order);
>> Does this mean that the vCPU executing this will get stuck
>> here for the duration of the hypercall? Isn't that too long,
>> considering that the zone lock is taken and madvise in the
>> host block on semaphores?
> I'm pretty sure the zone lock isn't held when this is called. The lock
> isn't acquired until later in the path. This gets executed just before
> the page poisoning call which would take time as well since it would
> have to memset an entire page. This function is called as a part of
> free_pages_prepare, the zone locks aren't acquired until we are calling=

> into either free_one_page and a few spots before calling
> __free_one_page.
>
> My other function in patch 4 which does this from inside of
> __free_one_page does have to release the zone lock since it is taken
> there.
>
Considering hypercall's are costly, will it not make sense to coalesce
the pages you are reporting and make a single hypercall for a bunch of
pages?

--=20
Nitesh


--DbNdtYN4o8nLIgLlGD1ViUxA0kuqQwqic--

--buBbfmkGrgb9qyScBYbGXuzydHVEykMEJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkXcoRVGaqvbHPuAGo4ZA3AYyozkFAlxd7ywACgkQo4ZA3AYy
oznUcA//W6PN3OWp72UV0enWn5KHRqQFpaTS/2k/xtL+s84LjGKksBr2OfPfbny/
ujYor3gi2fOxAU7j9CGDqRXMfrUnD2L78K8uc3PTmwWYHgpthsXGfbxCnjOw7/82
zyqOJeEY2UiTK/sBqek4MVQGydmkOQzFjGLp9Z36Lx+BG3AmOJdJiCdPV9NUJqT8
5kwNznHO+cTEBkjH19CejKs+ufHrfvzwSOTTMXYmIDBw72emBz7cE9vxno4vxaiz
P6ZSvpewdfKF6VTfdJdFTUwBSh1ekKGBjlyRMjC6YTzPQTjeCBoWN1ouQ8UpzKQl
nvZZwBymfV1FV/VyBQjPxqxBV8ag08I33yqkxA8cdyEtqQXiIym1MilxFR4tkGYQ
SrTz4QiBH/9J2UT+zVv4D8Wj+evAQw1kuYVO/IWDp7H4AXZ7I+TSF+0/R9x/zOYI
1EHHcF/KLlpZFNgqa4uQ818Th4gzQuismB0iPOWQ7/IfKPEGgCD/SkioYH/Ww7ht
wiSe0mlInFXk3Y/noJICnTyJM2byEk+sZ1dFd3q4btC5gtRnDKSh1pvY4rjDs2nK
E8mgBKL30gm5pZDih/qAv2Gc9Dlr4h0yh+IHRHNCe/E1vAXsFbTCFi7aYAvj/SXo
zwV+mE+YC1MN8cpVG6EuRV9hqf4wm+Zli69sqB/NOelcm+t3OqA=
=V4BY
-----END PGP SIGNATURE-----

--buBbfmkGrgb9qyScBYbGXuzydHVEykMEJ--

