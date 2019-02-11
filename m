Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42EA6C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 13:30:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A74D720855
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 13:30:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A74D720855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F50B8E00E3; Mon, 11 Feb 2019 08:30:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 17F718E00C3; Mon, 11 Feb 2019 08:30:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 044A78E00E3; Mon, 11 Feb 2019 08:30:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id CABE78E00C3
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 08:30:30 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id u32so12920887qte.1
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 05:30:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:subject
         :to:cc:references:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to;
        bh=Vb8rN/l5NVGZB2gcMiGlsZUBJJ0Vi1AUid4nLx3ExeA=;
        b=RdIQsPXRz9VNZYs+VxryjoRfwCdKNp85gJhBWrT7HW1eLtNUU5zJqlX98KuDn/2/Io
         nMmAlT99rh8Yuslu0DmT7xC4Gsn5BjeP3gtC0keMWB/IyaHjkPctUbVrR0Wq3GXlaed8
         3pmkeX70anQB8WqKeuA+9IVRgDHsra0z2HRPx1NkzQ5RiEEgUOOWsvrS+Bgvy6W0eqr0
         xLHPz3CAOyokPMzgLbUJvAIjcYPI2zKjEQJ3ZC1Yn0tfqvgnrAMNbIutqy+c2NPE95DO
         flUyamLRrA31ThVxOYOiifKVGX4LQ4bneJ9ORYO965zgMvbfpU+96kBNS2DggDvIbl5u
         691A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubdXZ1NoYo76dwUoMZbTrMazqyNtVDogG5RnxJ4FLDn/sMd/3NQ
	/b3gl0v4pmuINi8HnvlvqQPstJaWkRakbdQ91m0bu7vuW0OBfXWDdq4Qhh3mwzWX8mwHo6vUvoX
	BGCE86d0lO8zw5enK5h09TLCC9TRP5IZp7SzDauTGuNkgDicWKR2g4+CFmcCGQ2n4cA==
X-Received: by 2002:aed:3ae4:: with SMTP id o91mr27577914qte.251.1549891830467;
        Mon, 11 Feb 2019 05:30:30 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYdIdLfbwpI5TCJ0MaH8SS1Ai14wUEUtqkcnkeZpKYE3rPDKmwSgx6OscHtmukKwI72TE/b
X-Received: by 2002:aed:3ae4:: with SMTP id o91mr27577866qte.251.1549891829778;
        Mon, 11 Feb 2019 05:30:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549891829; cv=none;
        d=google.com; s=arc-20160816;
        b=FCQaxkmf4casxziZGD1MbmXwQQUGgQuOY2co+mGsS8wIKl4XryitqRYoX8d1KF1irU
         nHihSif6LGFS2lU8luM5DKfi0LZK0Z9135NyvVmMjB6APhJkbgqi5Jb3w3XqPaGDxG7u
         MfJV61ivrEwyI6FqJ1dxhkfSyjbdVXp+FrrXbShjf7aP+yoBmU7a0YNnh5vT936yyV65
         rsx57FPHKjfSljJoQTmDt9OiOVAPLWNfy8GvvHqvHYH3iJNZd3Ui4SsEhuz98xcRCR+0
         3W1ten8rRlyP1adGYjcODALMxz8yjLXyolJTCsfz1kay7RHpKX/TrzddVhpbFvDWTRCM
         ApKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:user-agent:date:message-id:organization
         :autocrypt:openpgp:references:cc:to:subject:from;
        bh=Vb8rN/l5NVGZB2gcMiGlsZUBJJ0Vi1AUid4nLx3ExeA=;
        b=m7MKhtjkCna/r6bE4s7smHZP7ikyr9D1AeEBcL5FnmnIPDmrY5yik1Imksn3wK6Jek
         CJZnZsDBg3CX6QurwCz+JElqr0Fq2EoJdFe5HYe5WZofcGqNHQdWVahrQ84gkBxH9fP1
         Nse0LiQMY9AU56R3ubXbFVx2skmGnXH3qRGiHcSVGYNhQSlQ6/QEyZP3wEOjI3FJr/bx
         Suq8HpFuorRbeMBL5Lj5Y83m+y3Adx3tyhsKJ+XwSGkWwZBOqSAEw81cqFOCfSXaXRGd
         3j5OxIoxZ29IUPjZmjHoMaOu8zsUqRR4iYQkKKcNjL43V3cwSTg1B2ksoSm9I3hKrSVX
         uOjw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q31si3780230qte.30.2019.02.11.05.30.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 05:30:29 -0800 (PST)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D678358E33;
	Mon, 11 Feb 2019 13:30:28 +0000 (UTC)
Received: from [10.18.17.32] (dhcp-17-32.bos.redhat.com [10.18.17.32])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 34BE66012B;
	Mon, 11 Feb 2019 13:30:05 +0000 (UTC)
From: Nitesh Narayan Lal <nitesh@redhat.com>
Subject: Re: [RFC PATCH 4/4] mm: Add merge page notifier
To: "Michael S. Tsirkin" <mst@redhat.com>,
 Alexander Duyck <alexander.duyck@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
 rkrcmar@redhat.com, alexander.h.duyck@linux.intel.com, x86@kernel.org,
 mingo@redhat.com, bp@alien8.de, hpa@zytor.com, pbonzini@redhat.com,
 tglx@linutronix.de, akpm@linux-foundation.org
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
 <20190204181558.12095.83484.stgit@localhost.localdomain>
 <20190209195325-mutt-send-email-mst@kernel.org>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <7fcb61d6-64f0-f3ae-5e32-0e9f587fdd49@redhat.com>
Date: Mon, 11 Feb 2019 08:30:03 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190209195325-mutt-send-email-mst@kernel.org>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="bgcetFPJzTNKp4nh9DgTAgO3id5Syb3GZ"
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Mon, 11 Feb 2019 13:30:29 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--bgcetFPJzTNKp4nh9DgTAgO3id5Syb3GZ
Content-Type: multipart/mixed; boundary="rxrbFi0rimh0fffvwaHt9J6zKSdjFAYyj";
 protected-headers="v1"
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>,
 Alexander Duyck <alexander.duyck@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
 rkrcmar@redhat.com, alexander.h.duyck@linux.intel.com, x86@kernel.org,
 mingo@redhat.com, bp@alien8.de, hpa@zytor.com, pbonzini@redhat.com,
 tglx@linutronix.de, akpm@linux-foundation.org
Message-ID: <7fcb61d6-64f0-f3ae-5e32-0e9f587fdd49@redhat.com>
Subject: Re: [RFC PATCH 4/4] mm: Add merge page notifier
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
 <20190204181558.12095.83484.stgit@localhost.localdomain>
 <20190209195325-mutt-send-email-mst@kernel.org>
In-Reply-To: <20190209195325-mutt-send-email-mst@kernel.org>

--rxrbFi0rimh0fffvwaHt9J6zKSdjFAYyj
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US


On 2/9/19 7:57 PM, Michael S. Tsirkin wrote:
> On Mon, Feb 04, 2019 at 10:15:58AM -0800, Alexander Duyck wrote:
>> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>>
>> Because the implementation was limiting itself to only providing hints=
 on
>> pages huge TLB order sized or larger we introduced the possibility for=
 free
>> pages to slip past us because they are freed as something less then
>> huge TLB in size and aggregated with buddies later.
>>
>> To address that I am adding a new call arch_merge_page which is called=

>> after __free_one_page has merged a pair of pages to create a higher or=
der
>> page. By doing this I am able to fill the gap and provide full coverag=
e for
>> all of the pages huge TLB order or larger.
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> Looks like this will be helpful whenever active free page
> hints are added. So I think it's a good idea to
> add a hook.
>
> However, could you split adding the hook to a separate
> patch from the KVM hypercall based implementation?
>
> Then e.g. Nilal's patches could reuse it too.
With the current design of my patch-set, if I use this hook to report
free pages. I will end up making redundant hints for the same pfns.

This is because the pages once freed by the host, are returned back to
the buddy.

>
>
>> ---
>>  arch/x86/include/asm/page.h |   12 ++++++++++++
>>  arch/x86/kernel/kvm.c       |   28 ++++++++++++++++++++++++++++
>>  include/linux/gfp.h         |    4 ++++
>>  mm/page_alloc.c             |    2 ++
>>  4 files changed, 46 insertions(+)
>>
>> diff --git a/arch/x86/include/asm/page.h b/arch/x86/include/asm/page.h=

>> index 4487ad7a3385..9540a97c9997 100644
>> --- a/arch/x86/include/asm/page.h
>> +++ b/arch/x86/include/asm/page.h
>> @@ -29,6 +29,18 @@ static inline void arch_free_page(struct page *page=
, unsigned int order)
>>  	if (static_branch_unlikely(&pv_free_page_hint_enabled))
>>  		__arch_free_page(page, order);
>>  }
>> +
>> +struct zone;
>> +
>> +#define HAVE_ARCH_MERGE_PAGE
>> +void __arch_merge_page(struct zone *zone, struct page *page,
>> +		       unsigned int order);
>> +static inline void arch_merge_page(struct zone *zone, struct page *pa=
ge,
>> +				   unsigned int order)
>> +{
>> +	if (static_branch_unlikely(&pv_free_page_hint_enabled))
>> +		__arch_merge_page(zone, page, order);
>> +}
>>  #endif
>> =20
>>  #include <linux/range.h>
>> diff --git a/arch/x86/kernel/kvm.c b/arch/x86/kernel/kvm.c
>> index 09c91641c36c..957bb4f427bb 100644
>> --- a/arch/x86/kernel/kvm.c
>> +++ b/arch/x86/kernel/kvm.c
>> @@ -785,6 +785,34 @@ void __arch_free_page(struct page *page, unsigned=
 int order)
>>  		       PAGE_SIZE << order);
>>  }
>> =20
>> +void __arch_merge_page(struct zone *zone, struct page *page,
>> +		       unsigned int order)
>> +{
>> +	/*
>> +	 * The merging logic has merged a set of buddies up to the
>> +	 * KVM_PV_UNUSED_PAGE_HINT_MIN_ORDER. Since that is the case, take
>> +	 * advantage of this moment to notify the hypervisor of the free
>> +	 * memory.
>> +	 */
>> +	if (order !=3D KVM_PV_UNUSED_PAGE_HINT_MIN_ORDER)
>> +		return;
>> +
>> +	/*
>> +	 * Drop zone lock while processing the hypercall. This
>> +	 * should be safe as the page has not yet been added
>> +	 * to the buddy list as of yet and all the pages that
>> +	 * were merged have had their buddy/guard flags cleared
>> +	 * and their order reset to 0.
>> +	 */
>> +	spin_unlock(&zone->lock);
>> +
>> +	kvm_hypercall2(KVM_HC_UNUSED_PAGE_HINT, page_to_phys(page),
>> +		       PAGE_SIZE << order);
>> +
>> +	/* reacquire lock and resume freeing memory */
>> +	spin_lock(&zone->lock);
>> +}
>> +
>>  #ifdef CONFIG_PARAVIRT_SPINLOCKS
>> =20
>>  /* Kick a cpu by its apicid. Used to wake up a halted vcpu */
>> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
>> index fdab7de7490d..4746d5560193 100644
>> --- a/include/linux/gfp.h
>> +++ b/include/linux/gfp.h
>> @@ -459,6 +459,10 @@ static inline struct zonelist *node_zonelist(int =
nid, gfp_t flags)
>>  #ifndef HAVE_ARCH_FREE_PAGE
>>  static inline void arch_free_page(struct page *page, int order) { }
>>  #endif
>> +#ifndef HAVE_ARCH_MERGE_PAGE
>> +static inline void
>> +arch_merge_page(struct zone *zone, struct page *page, int order) { }
>> +#endif
>>  #ifndef HAVE_ARCH_ALLOC_PAGE
>>  static inline void arch_alloc_page(struct page *page, int order) { }
>>  #endif
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index c954f8c1fbc4..7a1309b0b7c5 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -913,6 +913,8 @@ static inline void __free_one_page(struct page *pa=
ge,
>>  		page =3D page + (combined_pfn - pfn);
>>  		pfn =3D combined_pfn;
>>  		order++;
>> +
>> +		arch_merge_page(zone, page, order);
>>  	}
>>  	if (max_order < MAX_ORDER) {
>>  		/* If we are here, it means order is >=3D pageblock_order.
--=20
Regards
Nitesh


--rxrbFi0rimh0fffvwaHt9J6zKSdjFAYyj--

--bgcetFPJzTNKp4nh9DgTAgO3id5Syb3GZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkXcoRVGaqvbHPuAGo4ZA3AYyozkFAlxheNwACgkQo4ZA3AYy
oznBhQ/8DTHV/Y4PGtL9dxvGU/FlAdRnEuPMHPw6hDGr5qcWCC9bkX9dfGAtoATp
veCftnpMxcub00ObTcYFDsLg6OoJ5ThlgvZfQ/tKkzJO2X2AoMlW1GGF+jWRPSW6
5Zmw4/IRJEW433Hg73MfAili6l3YpgvHv1EJ95hsA318j/14YmQKMB3OPKR7e8kk
2R+0oD5QrS3hrjcsRWDOEBquMAt2JigPLv8TzqA+IdqdwNjFQ6vumXloMDUBVCym
RADoNTWfAm1uHgLdlLNf2Fcoj8b2J/CVxWx7NgM3n+uPbU6PtcrLdXDFuR5wVjhN
+GazNsOM/Y3joNNlB+dBmNwBFTDJEZgJDhJVxLpxVCHcMi8oB+iuWVf6MZ87ivr+
8Rd/GReIo2wVDVb27T4Le/tcX9VIk3AOVTgZ3VwodHLT7a4/JJGKsmCko8nrr8EX
XiYZzwsLaiGdQQx63ALUmDhOXN97uu8JLyIzs8+OHYklPs4mYMXYwaQruGRcRvUt
2HoY2UvARFy/7lfqQb8++gbwPPCsVbni0n1ERxinOtJV6kLkpB5u9pHEvTnIlqlp
Xkn5pCqPqNV+X3F36GDsVnQ+vBXj3Uyd0/Wywr1JaW1ZWBVl3oP/KGoxc5JfU6/z
faUhCYxovWqoTXQVtm60a0lu7w+Jis1ed4ZhhE+Br4bJYWbHALs=
=X2Bz
-----END PGP SIGNATURE-----

--bgcetFPJzTNKp4nh9DgTAgO3id5Syb3GZ--

