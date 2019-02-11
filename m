Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CFF6C4151A
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 16:24:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35D4221B69
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 16:24:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35D4221B69
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C46C38E00FA; Mon, 11 Feb 2019 11:24:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD0DC8E00F6; Mon, 11 Feb 2019 11:24:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A4AF08E00FA; Mon, 11 Feb 2019 11:24:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 724528E00F6
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:24:30 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id w124so12700885qkc.14
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 08:24:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to;
        bh=9oppxhfoOtgCuRDjh26C6V0OMf3W2oDb2rAhfB0TZQ4=;
        b=jrNqLMG+qW+cxKq0yzbEe1KiJZ9CiSiba+ZcdliMliijdouTdBF/qtdJHgX/UeZkdi
         hPBA+tUop9tvtBIgGIQ8w2jDkL6ZGoKM+hqeO7FGj+92kx0+g/LrOMaFnzVOyykCcODv
         FjhFCcqF7MbSCLdywZ0eJgB8vJ4X/hMZLMY1LTyH2PvRiJff5/u8txt5KVb4tKPWq4ha
         GUYHVBlWqXAMGh3QCxN4FVMJPGHPhFvodFGrybHNsZdgrFKmClWJ/oBW8GfMHsdC9BWc
         RNmI1ZAkfCT6dsSH8MNs+OBM+rrZpEBk6qu3VtZofuLP98zS6fyoQ9NqS8WDQe/rSSx5
         lnLw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAua35NP6CUXFgqyUjeyoynYSKRK5sbXIywu5JUy9DrgHNeuM+xW3
	hqHnIlsu7NUMaXJOvIaooGRMULjsPvr2BKJxenq3v4eiXg7HUJ2vChq5J/dR6sp3X1q66N7orK5
	Oraira8nkJVm1JR7B7VvDd9MV2wPxxkcIK3rgVYERxeeIqnyPeREtNUb0b+i2qmH8Yg==
X-Received: by 2002:ac8:2da3:: with SMTP id p32mr22930076qta.138.1549902269835;
        Mon, 11 Feb 2019 08:24:29 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ/mVQDwt2mqhkiROEz5mZEklTOVb77daRacut1QePWyGldlXwLDUrZu54CGgM0TXcOlCLo
X-Received: by 2002:ac8:2da3:: with SMTP id p32mr22930031qta.138.1549902269084;
        Mon, 11 Feb 2019 08:24:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549902269; cv=none;
        d=google.com; s=arc-20160816;
        b=nfBotzPJKI2cvrXh08sLyjxTGfYU4jaHdaM5mEiQXBfKVxdT5auk//2biigwRWsEQ6
         15ATgCbPR5URrfusWMNg8e6KtjCGabPbjTpgLDh6stIHqVTv4/JTK0Kmm28HclePROix
         iOS4rWszx3swv9pzlrXlOmLuowtVM5gBACFqwNGC1LpFoE7KqLCgeN8N34urd2GWLGse
         byYd9oakgLrxA+uTHBiXZRTqvJtr8kgVi9k7PkGTz31csLAB/Rza6dD0VtQl7hQ/wyVy
         wwQdLBwPrfP50V96tISP6HLhhGOZZ1JScNVEb1/SfVJR5dG0+0qABqQPRkYoP27wkRrG
         p1IA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:user-agent:date:message-id:organization
         :autocrypt:openpgp:from:references:cc:to:subject;
        bh=9oppxhfoOtgCuRDjh26C6V0OMf3W2oDb2rAhfB0TZQ4=;
        b=OAECd4Tz9ZdyIBt7K9/jewH4FQs+uQUsI2FZxUuMhV+5wnBeWuYwbUmtFD7zwutU36
         oeYWzllYeh6D8EGo0WCMZxBQ+LYW7ovGoU0SMbGzIIGa5ZzhJl2hXJMYfYIFpTCz8Um6
         +GzhzEhQQE4YIFL0rQt1QfpqSUPE5TfhgG5ueNNkE/BbXKBEvUnI8JQaceVRO+U61Xk5
         h5CBS8r0ewNUIzyxd1xV5f+0uPjRKo4PEFJJD3lwODadq4sHWs4m+wz+9LzDpS8Ffiz5
         skoGYZAKlybYkx/qW6+rgdM3YWODNTlxhipTG49ya8xIR3ZmYZzOXwQOe1sy6HkT9pYR
         F9Ag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l187si341042qkf.178.2019.02.11.08.24.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 08:24:29 -0800 (PST)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 01732B1EE;
	Mon, 11 Feb 2019 16:24:28 +0000 (UTC)
Received: from [10.18.17.32] (dhcp-17-32.bos.redhat.com [10.18.17.32])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id CB664648B6;
	Mon, 11 Feb 2019 16:24:03 +0000 (UTC)
Subject: Re: [RFC PATCH 4/4] mm: Add merge page notifier
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com,
 alexander.h.duyck@linux.intel.com, x86@kernel.org, mingo@redhat.com,
 bp@alien8.de, hpa@zytor.com, pbonzini@redhat.com, tglx@linutronix.de,
 akpm@linux-foundation.org
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
 <20190204181558.12095.83484.stgit@localhost.localdomain>
 <20190209195325-mutt-send-email-mst@kernel.org>
 <7fcb61d6-64f0-f3ae-5e32-0e9f587fdd49@redhat.com>
 <20190211091623-mutt-send-email-mst@kernel.org>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <ac61d035-7c7b-bfec-c78b-b9387c40d3ea@redhat.com>
Date: Mon, 11 Feb 2019 11:24:02 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190211091623-mutt-send-email-mst@kernel.org>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="qXx3fZQQSn93zl79DSJ7RyaJquTUjxsqL"
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Mon, 11 Feb 2019 16:24:28 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--qXx3fZQQSn93zl79DSJ7RyaJquTUjxsqL
Content-Type: multipart/mixed; boundary="IyEb9NGqXcudpVZ93K6BModc8xL8gsLEU";
 protected-headers="v1"
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com,
 alexander.h.duyck@linux.intel.com, x86@kernel.org, mingo@redhat.com,
 bp@alien8.de, hpa@zytor.com, pbonzini@redhat.com, tglx@linutronix.de,
 akpm@linux-foundation.org
Message-ID: <ac61d035-7c7b-bfec-c78b-b9387c40d3ea@redhat.com>
Subject: Re: [RFC PATCH 4/4] mm: Add merge page notifier
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
 <20190204181558.12095.83484.stgit@localhost.localdomain>
 <20190209195325-mutt-send-email-mst@kernel.org>
 <7fcb61d6-64f0-f3ae-5e32-0e9f587fdd49@redhat.com>
 <20190211091623-mutt-send-email-mst@kernel.org>
In-Reply-To: <20190211091623-mutt-send-email-mst@kernel.org>

--IyEb9NGqXcudpVZ93K6BModc8xL8gsLEU
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US


On 2/11/19 9:17 AM, Michael S. Tsirkin wrote:
> On Mon, Feb 11, 2019 at 08:30:03AM -0500, Nitesh Narayan Lal wrote:
>> On 2/9/19 7:57 PM, Michael S. Tsirkin wrote:
>>> On Mon, Feb 04, 2019 at 10:15:58AM -0800, Alexander Duyck wrote:
>>>> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>>>>
>>>> Because the implementation was limiting itself to only providing hin=
ts on
>>>> pages huge TLB order sized or larger we introduced the possibility f=
or free
>>>> pages to slip past us because they are freed as something less then
>>>> huge TLB in size and aggregated with buddies later.
>>>>
>>>> To address that I am adding a new call arch_merge_page which is call=
ed
>>>> after __free_one_page has merged a pair of pages to create a higher =
order
>>>> page. By doing this I am able to fill the gap and provide full cover=
age for
>>>> all of the pages huge TLB order or larger.
>>>>
>>>> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>>> Looks like this will be helpful whenever active free page
>>> hints are added. So I think it's a good idea to
>>> add a hook.
>>>
>>> However, could you split adding the hook to a separate
>>> patch from the KVM hypercall based implementation?
>>>
>>> Then e.g. Nilal's patches could reuse it too.
>> With the current design of my patch-set, if I use this hook to report
>> free pages. I will end up making redundant hints for the same pfns.
>>
>> This is because the pages once freed by the host, are returned back to=

>> the buddy.
> Suggestions on how you'd like to fix this? You do need this if
> you introduce a size cut-off right?

I do, there are two ways to go about it.

One is to=C2=A0 use this and have a flag in the page structure indicating=

whether that page has been freed/used or not. Though I am not sure if
this will be acceptable upstream.
Second is to find another place to invoke guest_free_page() post buddy
merging.

>
>>>
>>>> ---
>>>>  arch/x86/include/asm/page.h |   12 ++++++++++++
>>>>  arch/x86/kernel/kvm.c       |   28 ++++++++++++++++++++++++++++
>>>>  include/linux/gfp.h         |    4 ++++
>>>>  mm/page_alloc.c             |    2 ++
>>>>  4 files changed, 46 insertions(+)
>>>>
>>>> diff --git a/arch/x86/include/asm/page.h b/arch/x86/include/asm/page=
=2Eh
>>>> index 4487ad7a3385..9540a97c9997 100644
>>>> --- a/arch/x86/include/asm/page.h
>>>> +++ b/arch/x86/include/asm/page.h
>>>> @@ -29,6 +29,18 @@ static inline void arch_free_page(struct page *pa=
ge, unsigned int order)
>>>>  	if (static_branch_unlikely(&pv_free_page_hint_enabled))
>>>>  		__arch_free_page(page, order);
>>>>  }
>>>> +
>>>> +struct zone;
>>>> +
>>>> +#define HAVE_ARCH_MERGE_PAGE
>>>> +void __arch_merge_page(struct zone *zone, struct page *page,
>>>> +		       unsigned int order);
>>>> +static inline void arch_merge_page(struct zone *zone, struct page *=
page,
>>>> +				   unsigned int order)
>>>> +{
>>>> +	if (static_branch_unlikely(&pv_free_page_hint_enabled))
>>>> +		__arch_merge_page(zone, page, order);
>>>> +}
>>>>  #endif
>>>> =20
>>>>  #include <linux/range.h>
>>>> diff --git a/arch/x86/kernel/kvm.c b/arch/x86/kernel/kvm.c
>>>> index 09c91641c36c..957bb4f427bb 100644
>>>> --- a/arch/x86/kernel/kvm.c
>>>> +++ b/arch/x86/kernel/kvm.c
>>>> @@ -785,6 +785,34 @@ void __arch_free_page(struct page *page, unsign=
ed int order)
>>>>  		       PAGE_SIZE << order);
>>>>  }
>>>> =20
>>>> +void __arch_merge_page(struct zone *zone, struct page *page,
>>>> +		       unsigned int order)
>>>> +{
>>>> +	/*
>>>> +	 * The merging logic has merged a set of buddies up to the
>>>> +	 * KVM_PV_UNUSED_PAGE_HINT_MIN_ORDER. Since that is the case, take=

>>>> +	 * advantage of this moment to notify the hypervisor of the free
>>>> +	 * memory.
>>>> +	 */
>>>> +	if (order !=3D KVM_PV_UNUSED_PAGE_HINT_MIN_ORDER)
>>>> +		return;
>>>> +
>>>> +	/*
>>>> +	 * Drop zone lock while processing the hypercall. This
>>>> +	 * should be safe as the page has not yet been added
>>>> +	 * to the buddy list as of yet and all the pages that
>>>> +	 * were merged have had their buddy/guard flags cleared
>>>> +	 * and their order reset to 0.
>>>> +	 */
>>>> +	spin_unlock(&zone->lock);
>>>> +
>>>> +	kvm_hypercall2(KVM_HC_UNUSED_PAGE_HINT, page_to_phys(page),
>>>> +		       PAGE_SIZE << order);
>>>> +
>>>> +	/* reacquire lock and resume freeing memory */
>>>> +	spin_lock(&zone->lock);
>>>> +}
>>>> +
>>>>  #ifdef CONFIG_PARAVIRT_SPINLOCKS
>>>> =20
>>>>  /* Kick a cpu by its apicid. Used to wake up a halted vcpu */
>>>> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
>>>> index fdab7de7490d..4746d5560193 100644
>>>> --- a/include/linux/gfp.h
>>>> +++ b/include/linux/gfp.h
>>>> @@ -459,6 +459,10 @@ static inline struct zonelist *node_zonelist(in=
t nid, gfp_t flags)
>>>>  #ifndef HAVE_ARCH_FREE_PAGE
>>>>  static inline void arch_free_page(struct page *page, int order) { }=

>>>>  #endif
>>>> +#ifndef HAVE_ARCH_MERGE_PAGE
>>>> +static inline void
>>>> +arch_merge_page(struct zone *zone, struct page *page, int order) { =
}
>>>> +#endif
>>>>  #ifndef HAVE_ARCH_ALLOC_PAGE
>>>>  static inline void arch_alloc_page(struct page *page, int order) { =
}
>>>>  #endif
>>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>>> index c954f8c1fbc4..7a1309b0b7c5 100644
>>>> --- a/mm/page_alloc.c
>>>> +++ b/mm/page_alloc.c
>>>> @@ -913,6 +913,8 @@ static inline void __free_one_page(struct page *=
page,
>>>>  		page =3D page + (combined_pfn - pfn);
>>>>  		pfn =3D combined_pfn;
>>>>  		order++;
>>>> +
>>>> +		arch_merge_page(zone, page, order);
>>>>  	}
>>>>  	if (max_order < MAX_ORDER) {
>>>>  		/* If we are here, it means order is >=3D pageblock_order.
>> --=20
>> Regards
>> Nitesh
>>
>
>
--=20
Regards
Nitesh


--IyEb9NGqXcudpVZ93K6BModc8xL8gsLEU--

--qXx3fZQQSn93zl79DSJ7RyaJquTUjxsqL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkXcoRVGaqvbHPuAGo4ZA3AYyozkFAlxhoaIACgkQo4ZA3AYy
ozmlFg/+JqGEyRG/6eSJo76R07PR4myO0ukkvUcxhPRYRQPFKG+64BaaZam/k58p
jVYWns005s/F4ZvmavRpwY5VgmEOiBMpjijEn886elQfGVG95hAyxiFAgbsNYxmB
lSX3KYc5VrICx71byZenddUZPSz1t8vXKdOP4x2r95aPFOmEd0kV7GdL/zaq2EQ2
YGlVnKd3dpwkSb4h0HZFOKcZ2g7XsZfCkHCxKBMWuFSu9C0XwRTD76MgyKtOc926
wxrmel0oJnRxbNF9jCj70qaaTuWYvwrIMPySrHlid0VM3t0mUoj2cgfatnAdj+3e
rI4NGZdj8niD4rvbGMkCs0Rxs8TIXyiywxjFjVrp/rEnOJI/Vmi0T7MrlzYWab4Z
lCQRI/4vNI4CaaBannrN8ctD3Fl4dOH+DM+B9ifyk9mns0SkQqy96Kjroh3o7CKG
x9kGKzdSUqyJXb+E61QtaCyWpFMHFdOlmvv5AtYWQyNvoJEcQ5anytzX2BM7WZbe
oo/WXq84O0V87UVId0JkCAJoB1jGrc1WsxpqM3+vzZvdaV+carbQrWx4ZgVItXov
FsoWQMoPLexeJdZk+Af+HgJiJimOfZEyLTbyS2Vh6wAcewLGbhbImKYt6xjNTfd8
Le9j2oqkdEtHF+Efcate4JFjvgnhV+ygWkuixjISTRY9Vf1AvVs=
=R7Q8
-----END PGP SIGNATURE-----

--qXx3fZQQSn93zl79DSJ7RyaJquTUjxsqL--

