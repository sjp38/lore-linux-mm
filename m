Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23295C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:09:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D04B421B24
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:09:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D04B421B24
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8094B8E011F; Mon, 11 Feb 2019 13:09:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B6BB8E0115; Mon, 11 Feb 2019 13:09:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 631848E011F; Mon, 11 Feb 2019 13:09:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 346BA8E0115
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 13:09:50 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id y31so512132qty.9
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 10:09:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:organization:message-id:date:user-agent
         :mime-version:in-reply-to;
        bh=BsB2XW0tUJl9MZB9fu+15jcrkYz6qOBb/22TfuymnQ4=;
        b=pusOYzzAjyLCFr4FlQDF87x46eIQ5E0o8VziFMLv/8AIyWbS0djZqEH8yudG2Hkwv7
         /RyGtUfOWrcellceDPGn9ext/aycxUaytu0PJtmamNpMZFvw4qzECDfjSA8l1tQ3cGKc
         gLT7IJ/9OzVGdaekqwZX3fqMttIxZFJjNsDhvVM1BereTlzm6apRupyIAODLxWfymshm
         W7rPs9BsJsEftW440ZUWW02My/Sar6bJK5GEzLd+xwy+GtBQl1N22YHG1Ijx494mK4wn
         q5olFlOyiI9Bz8ODlgRCdNjSuDsoaIrqqkd/lyp7/JEipqySXFgq7pOQr3wwifxdxoBx
         E54A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZedz1mrLvJiTEUzxbZslb8XC9XH5OV4T7nv7YXXASGNS5k3KcI
	6OtTDT0/11i+jqQEGT1d3LlT6ieK77NeqF7/JgSqkTqaMACP5xVDbgNJpsXgk8F9msiOu27kQH6
	XNodGGi+rVjlIjnMhvqM/K70A65LfeiA2AP5aySoc3x/3t9w6BOabsIEhoLb/1OV53Q==
X-Received: by 2002:ac8:7553:: with SMTP id b19mr24152772qtr.238.1549908589941;
        Mon, 11 Feb 2019 10:09:49 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaXoh75FjGC8MEErSKi6yZcssDOP28DlXXkWVzu3HirP02iOg/qdfMn8irVirPlj5k5x6jH
X-Received: by 2002:ac8:7553:: with SMTP id b19mr24152737qtr.238.1549908589390;
        Mon, 11 Feb 2019 10:09:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549908589; cv=none;
        d=google.com; s=arc-20160816;
        b=b5Mt7evje5UMCUCiAmkDfn12Kg0IuTl45v+nIsx1LFK/hzt7MhGQrUyoKQ6z7PUtGu
         MCXJwgPdcmOxFDhttsuLeaWqhiNWkJ93ReoREYfvIuy2nybNY3koSmr/xnZm/XhjxxkX
         z7XhtUAilfxtnehURs0HyvCuKbN68kFHdK1qwC/0XQ/zSLZ3kOATn9yc2gKsOJktc+d8
         5htdFLjyuXIW/CQ9Z71ktZHoU1p4sHkA+lu93bv+degwVNBQnIfPoD30TPYCU00oaYdK
         jtx8shIOcw5DC2o4f4m/Gpu0CynJbv/9DQ0eikgsLzXkNS6uwNlDP7z+A1J15zWJ8IcM
         OFSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:user-agent:date:message-id:organization
         :references:subject:cc:to:from;
        bh=BsB2XW0tUJl9MZB9fu+15jcrkYz6qOBb/22TfuymnQ4=;
        b=y+vpgoy1NoS9yhoSn8rwwKFDHfxuPAoZu48DcNHMDtQ6xE0Kum3RGbLsfXydD9QE8c
         NmjVbohw7A4QTLtydT52iru9znBXSdSEQkD9ZJc5Av5e6iTJe7io+p6JhTbwtI1o84vK
         qe7PKicZwKh5kqbb8DyBeVGBmIpNPPHtAYUyrX2y2tMKAfeLAPSPq0zPst6bSnxxvVUD
         rXplzHrFdU7+5Rs7e+2ezsvlmADgEPMxaX1U6JZbhD41Fv1NtewZaMG8HLseLC/JVJzV
         JOdHnAveuXXWUr9P/bDV7vFqXI5eaYN8KAROv/ynhuFLtUgRjFtpUXKUiM4Rwy9wny76
         eadQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q12si205322qvd.64.2019.02.11.10.09.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 10:09:49 -0800 (PST)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 74A21A82C;
	Mon, 11 Feb 2019 18:09:48 +0000 (UTC)
Received: from [10.18.17.32] (dhcp-17-32.bos.redhat.com [10.18.17.32])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id CF3D560C6B;
	Mon, 11 Feb 2019 18:09:42 +0000 (UTC)
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com,
 alexander.h.duyck@linux.intel.com, x86@kernel.org, mingo@redhat.com,
 bp@alien8.de, hpa@zytor.com, pbonzini@redhat.com, tglx@linutronix.de,
 akpm@linux-foundation.org
Subject: Re: [RFC PATCH 4/4] mm: Add merge page notifier
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
 <20190204181558.12095.83484.stgit@localhost.localdomain>
 <20190209195325-mutt-send-email-mst@kernel.org>
 <7fcb61d6-64f0-f3ae-5e32-0e9f587fdd49@redhat.com>
 <20190211091623-mutt-send-email-mst@kernel.org>
 <ac61d035-7c7b-bfec-c78b-b9387c40d3ea@redhat.com>
 <20190211123815-mutt-send-email-mst@kernel.org>
Organization: Red Hat Inc,
Message-ID: <ea3ab38d-36e7-d2fa-6ebf-df6c048e17e0@redhat.com>
Date: Mon, 11 Feb 2019 13:09:40 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190211123815-mutt-send-email-mst@kernel.org>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="c5ocnaYNnPDVZBKYZaAjEHZbi4GrRb2Dg"
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Mon, 11 Feb 2019 18:09:48 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--c5ocnaYNnPDVZBKYZaAjEHZbi4GrRb2Dg
Content-Type: multipart/mixed; boundary="d7qNngcBe97AVwp8UkiKrXYgbgVRREpbY";
 protected-headers="v1"
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com,
 alexander.h.duyck@linux.intel.com, x86@kernel.org, mingo@redhat.com,
 bp@alien8.de, hpa@zytor.com, pbonzini@redhat.com, tglx@linutronix.de,
 akpm@linux-foundation.org
Message-ID: <ea3ab38d-36e7-d2fa-6ebf-df6c048e17e0@redhat.com>
Subject: Re: [RFC PATCH 4/4] mm: Add merge page notifier

--d7qNngcBe97AVwp8UkiKrXYgbgVRREpbY
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 2/11/19 12:41 PM, Michael S. Tsirkin wrote:
> On Mon, Feb 11, 2019 at 11:24:02AM -0500, Nitesh Narayan Lal wrote:
>> On 2/11/19 9:17 AM, Michael S. Tsirkin wrote:
>>> On Mon, Feb 11, 2019 at 08:30:03AM -0500, Nitesh Narayan Lal wrote:
>>>> On 2/9/19 7:57 PM, Michael S. Tsirkin wrote:
>>>>> On Mon, Feb 04, 2019 at 10:15:58AM -0800, Alexander Duyck wrote:
>>>>>> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>>>>>>
>>>>>> Because the implementation was limiting itself to only providing h=
ints on
>>>>>> pages huge TLB order sized or larger we introduced the possibility=
 for free
>>>>>> pages to slip past us because they are freed as something less the=
n
>>>>>> huge TLB in size and aggregated with buddies later.
>>>>>>
>>>>>> To address that I am adding a new call arch_merge_page which is ca=
lled
>>>>>> after __free_one_page has merged a pair of pages to create a highe=
r order
>>>>>> page. By doing this I am able to fill the gap and provide full cov=
erage for
>>>>>> all of the pages huge TLB order or larger.
>>>>>>
>>>>>> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>=

>>>>> Looks like this will be helpful whenever active free page
>>>>> hints are added. So I think it's a good idea to
>>>>> add a hook.
>>>>>
>>>>> However, could you split adding the hook to a separate
>>>>> patch from the KVM hypercall based implementation?
>>>>>
>>>>> Then e.g. Nilal's patches could reuse it too.
>>>> With the current design of my patch-set, if I use this hook to repor=
t
>>>> free pages. I will end up making redundant hints for the same pfns.
>>>>
>>>> This is because the pages once freed by the host, are returned back =
to
>>>> the buddy.
>>> Suggestions on how you'd like to fix this? You do need this if
>>> you introduce a size cut-off right?
>> I do, there are two ways to go about it.
>>
>> One is to=C2=A0 use this and have a flag in the page structure indicat=
ing
>> whether that page has been freed/used or not.
> Not sure what do you mean. The refcount does this right?
I meant a flag using which I could determine whether a PFN has been
already freed by the host or not. This is to avoid repetitive free.
>
>> Though I am not sure if
>> this will be acceptable upstream.
>> Second is to find another place to invoke guest_free_page() post buddy=

>> merging.
> Might be easier.
>
>>>>>> ---
>>>>>>  arch/x86/include/asm/page.h |   12 ++++++++++++
>>>>>>  arch/x86/kernel/kvm.c       |   28 ++++++++++++++++++++++++++++
>>>>>>  include/linux/gfp.h         |    4 ++++
>>>>>>  mm/page_alloc.c             |    2 ++
>>>>>>  4 files changed, 46 insertions(+)
>>>>>>
>>>>>> diff --git a/arch/x86/include/asm/page.h b/arch/x86/include/asm/pa=
ge.h
>>>>>> index 4487ad7a3385..9540a97c9997 100644
>>>>>> --- a/arch/x86/include/asm/page.h
>>>>>> +++ b/arch/x86/include/asm/page.h
>>>>>> @@ -29,6 +29,18 @@ static inline void arch_free_page(struct page *=
page, unsigned int order)
>>>>>>  	if (static_branch_unlikely(&pv_free_page_hint_enabled))
>>>>>>  		__arch_free_page(page, order);
>>>>>>  }
>>>>>> +
>>>>>> +struct zone;
>>>>>> +
>>>>>> +#define HAVE_ARCH_MERGE_PAGE
>>>>>> +void __arch_merge_page(struct zone *zone, struct page *page,
>>>>>> +		       unsigned int order);
>>>>>> +static inline void arch_merge_page(struct zone *zone, struct page=
 *page,
>>>>>> +				   unsigned int order)
>>>>>> +{
>>>>>> +	if (static_branch_unlikely(&pv_free_page_hint_enabled))
>>>>>> +		__arch_merge_page(zone, page, order);
>>>>>> +}
>>>>>>  #endif
>>>>>> =20
>>>>>>  #include <linux/range.h>
>>>>>> diff --git a/arch/x86/kernel/kvm.c b/arch/x86/kernel/kvm.c
>>>>>> index 09c91641c36c..957bb4f427bb 100644
>>>>>> --- a/arch/x86/kernel/kvm.c
>>>>>> +++ b/arch/x86/kernel/kvm.c
>>>>>> @@ -785,6 +785,34 @@ void __arch_free_page(struct page *page, unsi=
gned int order)
>>>>>>  		       PAGE_SIZE << order);
>>>>>>  }
>>>>>> =20
>>>>>> +void __arch_merge_page(struct zone *zone, struct page *page,
>>>>>> +		       unsigned int order)
>>>>>> +{
>>>>>> +	/*
>>>>>> +	 * The merging logic has merged a set of buddies up to the
>>>>>> +	 * KVM_PV_UNUSED_PAGE_HINT_MIN_ORDER. Since that is the case, ta=
ke
>>>>>> +	 * advantage of this moment to notify the hypervisor of the free=

>>>>>> +	 * memory.
>>>>>> +	 */
>>>>>> +	if (order !=3D KVM_PV_UNUSED_PAGE_HINT_MIN_ORDER)
>>>>>> +		return;
>>>>>> +
>>>>>> +	/*
>>>>>> +	 * Drop zone lock while processing the hypercall. This
>>>>>> +	 * should be safe as the page has not yet been added
>>>>>> +	 * to the buddy list as of yet and all the pages that
>>>>>> +	 * were merged have had their buddy/guard flags cleared
>>>>>> +	 * and their order reset to 0.
>>>>>> +	 */
>>>>>> +	spin_unlock(&zone->lock);
>>>>>> +
>>>>>> +	kvm_hypercall2(KVM_HC_UNUSED_PAGE_HINT, page_to_phys(page),
>>>>>> +		       PAGE_SIZE << order);
>>>>>> +
>>>>>> +	/* reacquire lock and resume freeing memory */
>>>>>> +	spin_lock(&zone->lock);
>>>>>> +}
>>>>>> +
>>>>>>  #ifdef CONFIG_PARAVIRT_SPINLOCKS
>>>>>> =20
>>>>>>  /* Kick a cpu by its apicid. Used to wake up a halted vcpu */
>>>>>> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
>>>>>> index fdab7de7490d..4746d5560193 100644
>>>>>> --- a/include/linux/gfp.h
>>>>>> +++ b/include/linux/gfp.h
>>>>>> @@ -459,6 +459,10 @@ static inline struct zonelist *node_zonelist(=
int nid, gfp_t flags)
>>>>>>  #ifndef HAVE_ARCH_FREE_PAGE
>>>>>>  static inline void arch_free_page(struct page *page, int order) {=
 }
>>>>>>  #endif
>>>>>> +#ifndef HAVE_ARCH_MERGE_PAGE
>>>>>> +static inline void
>>>>>> +arch_merge_page(struct zone *zone, struct page *page, int order) =
{ }
>>>>>> +#endif
>>>>>>  #ifndef HAVE_ARCH_ALLOC_PAGE
>>>>>>  static inline void arch_alloc_page(struct page *page, int order) =
{ }
>>>>>>  #endif
>>>>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>>>>> index c954f8c1fbc4..7a1309b0b7c5 100644
>>>>>> --- a/mm/page_alloc.c
>>>>>> +++ b/mm/page_alloc.c
>>>>>> @@ -913,6 +913,8 @@ static inline void __free_one_page(struct page=
 *page,
>>>>>>  		page =3D page + (combined_pfn - pfn);
>>>>>>  		pfn =3D combined_pfn;
>>>>>>  		order++;
>>>>>> +
>>>>>> +		arch_merge_page(zone, page, order);
>>>>>>  	}
>>>>>>  	if (max_order < MAX_ORDER) {
>>>>>>  		/* If we are here, it means order is >=3D pageblock_order.
>>>> --=20
>>>> Regards
>>>> Nitesh
>>>>
>>>
>> --=20
>> Regards
>> Nitesh
>>
>
>
--=20
Regards
Nitesh


--d7qNngcBe97AVwp8UkiKrXYgbgVRREpbY--

--c5ocnaYNnPDVZBKYZaAjEHZbi4GrRb2Dg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkXcoRVGaqvbHPuAGo4ZA3AYyozkFAlxhumQACgkQo4ZA3AYy
oznUwQ/+Kqi1R0b3vCG91aTEPof4m7+/hWZAKTAtsmxfAFcIF51vEft0suA8xKZZ
qBfrn4KmUlCDMEEdkwuY1G2HwuKvo4KMxXVnmIWfl6PicT3S3Hi3sjItPB08a4ou
bINoBIjG3tawHsuEhKGWcLr0wc6uD3gcZhJWTwqLktFRbxLW95uUGe8pJTJibLIF
zFZcRczMONVkhScgJZ5oUnmvUr8nRPlCVPlRJPNu3rkzP8ks55Af5jQdhxWvhFeS
xf6DdsOzLcqjUAX7FMt5sUeiSv7pdl+8+8z91qDfYjAC3B/xLuQ6Q8SoMO2CR2AY
hiE31mJMq0WLnsJqPHPhT6hBSYd/EuyhMGu0NYFjjGTuvI/CgfJ2wOYkQpb/dBX6
wsY/O/OnRb6fPt3rNW3KhT4ASV/+TPVIu70UK1EAVJER72e7pIZAcyg6R5BiMOqH
T+X8d4WJBpN9Kp5KQBpo3I4iTdSSGqpwWxhOMpmGveZpb7cpZXVykECYHpDKQdAE
PCnJfBi/q53LV4emdQOWeGZcjJwp8SE6ZfkSw7T1cnVZ1HcfDwxMHVgGeE5085ZT
JbDgkJI82pGJ778gOKryt0vraR07xgXdgtJv9jJDCPfOVm7oyT5Oh8iWwSWVeHPI
Li7uZYIYRIDpdUrIVQ8vitiq0YYNAmPBpU/1uinRE+gm2jLhogQ=
=3dJa
-----END PGP SIGNATURE-----

--c5ocnaYNnPDVZBKYZaAjEHZbi4GrRb2Dg--

