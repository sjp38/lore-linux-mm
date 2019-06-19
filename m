Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81CAAC31E51
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 03:34:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E8EB2082C
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 03:34:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="myoBF+ds"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E8EB2082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ADD866B0003; Tue, 18 Jun 2019 23:34:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8E738E0002; Tue, 18 Jun 2019 23:34:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 97D7E8E0001; Tue, 18 Jun 2019 23:34:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6089E6B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:34:53 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id z1so10751289pfb.7
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 20:34:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:subject:to:cc
         :references:in-reply-to:mime-version:user-agent:message-id
         :content-transfer-encoding;
        bh=aQYIiezoadkAUNJ9HxNcBE/gtfRYRxYn6A8Q2hhZFGI=;
        b=HgbyAP9zkKptLDyU7xe2HZcI6nBDeVz3XmcJXTVE91rediPghw0mCBgqGfHBwNAHi4
         LMuMxgvp1AFtP0aQm/XCUQlaq8357TRz9jTAT7cXfxFl+ICc4ZHP4XLsVgZazhTKFhsj
         gLEyT5k9YG0tka4lbK7m9aKS2YOGGe81hJ1kjdg++XM9FVXvp8bh/gZve1e83E52eiYW
         jU0v26ZTvt+J+MSfs1OBoJVRes+fsrjepc3m92WXpW0kLzQywxZ3NQtmeRaZkb7/OqF+
         lJeNCpOkux05LeEhRuEWvKwIOiMiXW1GGeQ7tdqHa9qUm47Lmrsml3+ShgWGgG6yhZ0U
         Kkfw==
X-Gm-Message-State: APjAAAUv4vODgsNxwbj5YFi4oyhkobLDXfoOicd7lV3EyT73vCxO0a7B
	R/Zm7ZTJcK4w5ABKQBDmY8jgZoivyprWlgUWdzdRKkKi7j2ID4y/EJeOfHl6+60f8x54Vx6rbWd
	mTJpq0HmB1aFglyFkWnBPckMccUWRoy6CddnGJggi8hQNkgxM3KvdyuUsWBL0eJOcZw==
X-Received: by 2002:a17:902:9041:: with SMTP id w1mr104213304plz.132.1560915292909;
        Tue, 18 Jun 2019 20:34:52 -0700 (PDT)
X-Received: by 2002:a17:902:9041:: with SMTP id w1mr104213243plz.132.1560915291842;
        Tue, 18 Jun 2019 20:34:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560915291; cv=none;
        d=google.com; s=arc-20160816;
        b=A89mltQ44kDyexH5orJNcq7/ILHXDoEyHLI/YcdCKzkNpZ2f9VfvaRZvi5VO+BWCLw
         vArdUAyAXWwbmRA+DxVtKU98/ErubObuXoJY5YXzaqiM94FSRbVdWhI41sxIo5CfuZIw
         +jozEx45r3s6xXTIX2UkUmXcec59xMdvM6XfIKmJGkN2K4Cu5Mq6cFJb2mvuyEfQXbLR
         uTZxLLwbgmWE1Gzk200CSjiALdEHdVSQ57SR0Ued12KPiInJ9Faf6yKmvvPF/9jNM+zq
         9nXmHXEA5HNjRsEXCKG27MMzBMFP3pViMHfJPC1EY2R8wFsQH3Gs4SHf8oM0JCGZUAKC
         wULQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:message-id:user-agent:mime-version
         :in-reply-to:references:cc:to:subject:from:date:dkim-signature;
        bh=aQYIiezoadkAUNJ9HxNcBE/gtfRYRxYn6A8Q2hhZFGI=;
        b=Gtb6DNupoZk8b+I92AIJZhC3kd0JsQ7K59uvqF/lBTNybhQxDxjzKzfsG1HSaQCqEg
         SpK5g0mC7KWmKAh4Mh3aseMw9Mznnc0qABRukx0rLX14FoPX5Q329/VyGWZwUz43Y5si
         gOXgkASE1jqAo43GW1YsKUJk+wtCc7pXrMhpepDoZrNaOcyGqObeKrRkh9dcjV/ktCiR
         S4YcMrvXCTUvJmcalCCAtL2HKhEHjphz5geUYkGWVHARb4AapFdXsSi1Q0f2zOR/J6iV
         Cpg8/x3j/Y5UmGOVphnuc6ECer7dQAeMd8DGdl8jsbBeI37aBphXsUb9V2/K1pRMJlVE
         ocHw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=myoBF+ds;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f3sor180606pjo.16.2019.06.18.20.34.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Jun 2019 20:34:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=myoBF+ds;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:subject:to:cc:references:in-reply-to:mime-version
         :user-agent:message-id:content-transfer-encoding;
        bh=aQYIiezoadkAUNJ9HxNcBE/gtfRYRxYn6A8Q2hhZFGI=;
        b=myoBF+ds9/I86aN2kC3Tp5vxrpURD4189UJaDRoG28R5cKBh7HSn/fj4i6nMB4L8/M
         7KQ/QjrXbuvq5QWQmx8tPLIFP7SCmcNLFOYvasChY39PAMEHyUpd/YzuYZRbpwsbWzqt
         7RygsRn1jDob+6UmK08r9uQvtLymAd5+9vwd9sZ2lswN3Hr7W5XwkUrleW1RsF9fW+zA
         jUucv1SmSA6HSqb4ZXxYgSu8+FbAduS5YKSfQxxFW1+xP0BXoeDhPPSR1y6RtwPfwqw9
         ItTD0gCZu1Y6PzP2n8OSoDjE62/gxLPku5W+m+nLs44wjN181gfucyuzwGMUSBbiF1jf
         7l8Q==
X-Google-Smtp-Source: APXvYqxRH0ZwHGLASQnJ41JHZYuDzVHzMWanDuSc5Jjtkv5qvkIM5gFElRTcgtkxS+8l7SMWkPuKmw==
X-Received: by 2002:a17:90a:24ac:: with SMTP id i41mr8667378pje.124.1560915291392;
        Tue, 18 Jun 2019 20:34:51 -0700 (PDT)
Received: from localhost (193-116-92-108.tpgi.com.au. [193.116.92.108])
        by smtp.gmail.com with ESMTPSA id r6sm164084pji.0.2019.06.18.20.34.49
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 18 Jun 2019 20:34:50 -0700 (PDT)
Date: Wed, 19 Jun 2019 13:29:46 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 4/4] mm/vmalloc: Hugepage vmalloc mappings
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org
Cc: Ard Biesheuvel <Ard.Biesheuvel@arm.com>,
	linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org
References: <20190610043838.27916-1-npiggin@gmail.com>
	<20190610043838.27916-4-npiggin@gmail.com>
	<a3b2dcb1-148e-b2f1-e181-92c16d868bc9@arm.com>
	<1560210095.fpemv3ultp.astroid@bobo.none>
	<2bd573d5-84ab-4b27-2126-863681ca3ef4@arm.com>
In-Reply-To: <2bd573d5-84ab-4b27-2126-863681ca3ef4@arm.com>
MIME-Version: 1.0
User-Agent: astroid/0.14.0 (https://github.com/astroidmail/astroid)
Message-Id: <1560913953.8b6zker0t3.astroid@bobo.none>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Anshuman Khandual's on June 11, 2019 4:59 pm:
> On 06/11/2019 05:46 AM, Nicholas Piggin wrote:
>> Anshuman Khandual's on June 10, 2019 6:53 pm:
>>> On 06/10/2019 10:08 AM, Nicholas Piggin wrote:
>>>> For platforms that define HAVE_ARCH_HUGE_VMAP, have vmap allow vmalloc=
 to
>>>> allocate huge pages and map them.
>>>
>>> IIUC that extends HAVE_ARCH_HUGE_VMAP from iormap to vmalloc.=20
>>>
>>>>
>>>> This brings dTLB misses for linux kernel tree `git diff` from 45,000 t=
o
>>>> 8,000 on a Kaby Lake KVM guest with 8MB dentry hash and mitigations=3D=
off
>>>> (performance is in the noise, under 1% difference, page tables are lik=
ely
>>>> to be well cached for this workload). Similar numbers are seen on POWE=
R9.
>>>
>>> Sure will try this on arm64.
>>>
>>>>
>>>> Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
>>>> ---
>>>>  include/asm-generic/4level-fixup.h |   1 +
>>>>  include/asm-generic/5level-fixup.h |   1 +
>>>>  include/linux/vmalloc.h            |   1 +
>>>>  mm/vmalloc.c                       | 132 +++++++++++++++++++++++-----=
-
>>>>  4 files changed, 107 insertions(+), 28 deletions(-)
>>>>
>>>> diff --git a/include/asm-generic/4level-fixup.h b/include/asm-generic/=
4level-fixup.h
>>>> index e3667c9a33a5..3cc65a4dd093 100644
>>>> --- a/include/asm-generic/4level-fixup.h
>>>> +++ b/include/asm-generic/4level-fixup.h
>>>> @@ -20,6 +20,7 @@
>>>>  #define pud_none(pud)			0
>>>>  #define pud_bad(pud)			0
>>>>  #define pud_present(pud)		1
>>>> +#define pud_large(pud)			0
>>>>  #define pud_ERROR(pud)			do { } while (0)
>>>>  #define pud_clear(pud)			pgd_clear(pud)
>>>>  #define pud_val(pud)			pgd_val(pud)
>>>> diff --git a/include/asm-generic/5level-fixup.h b/include/asm-generic/=
5level-fixup.h
>>>> index bb6cb347018c..c4377db09a4f 100644
>>>> --- a/include/asm-generic/5level-fixup.h
>>>> +++ b/include/asm-generic/5level-fixup.h
>>>> @@ -22,6 +22,7 @@
>>>>  #define p4d_none(p4d)			0
>>>>  #define p4d_bad(p4d)			0
>>>>  #define p4d_present(p4d)		1
>>>> +#define p4d_large(p4d)			0
>>>>  #define p4d_ERROR(p4d)			do { } while (0)
>>>>  #define p4d_clear(p4d)			pgd_clear(p4d)
>>>>  #define p4d_val(p4d)			pgd_val(p4d)
>>>
>>> Both of these are required from vmalloc_to_page() which as per a later =
comment
>>> should be part of a prerequisite patch before this series.
>>=20
>> I'm not sure what you mean. This patch is where they get used.
>=20
> In case you move out vmalloc_to_page() changes to a separate patch.

Sorry for the delay in reply.

I'll split this and see if we might be able to get it into next
merge window. I can have another try at the huge vmalloc patch
after that.

>=20
>>=20
>> Possibly I could split this and the vmalloc_to_page change out. I'll
>> consider it.
>>=20
>>>> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
>>>> index 812bea5866d6..4c92dc608928 100644
>>>> --- a/include/linux/vmalloc.h
>>>> +++ b/include/linux/vmalloc.h
>>>> @@ -42,6 +42,7 @@ struct vm_struct {
>>>>  	unsigned long		size;
>>>>  	unsigned long		flags;
>>>>  	struct page		**pages;
>>>> +	unsigned int		page_shift;
>>>
>>> So the entire vm_struct will be mapped with a single page_shift. It can=
not have
>>> mix and match mappings with PAGE_SIZE, PMD_SIZE, PUD_SIZE etc in case t=
he
>>> allocation fails for larger ones, falling back etc what over other reas=
ons.
>>=20
>> For now, yes. I have a bit of follow up work to improve that and make
>> it able to fall back, but it's a bit more churn and not a significant
>> benefit just yet because there are not a lot of very large vmallocs
>> (except the early hashes which can be satisfied with large allocs).
>=20
> Right but it will make this new feature complete like ioremap which logic=
ally
> supports till P4D (though AFAICT not used). If there are no actual vmallo=
c
> requests that large it is fine. Allocation attempts will start from the p=
age
> table level depending on the requested size. It is better to have PUD/P4D
> considerations now rather than trying to after fit it later.

I've considered them, which is why e.g., a shift gets passed around=20
rather than a bool for small/large.

I won't over complicate this page array data structure for something
that may never be supported though. I think we may actually be better
moving away from it in the vmalloc code and just referencing pages
from the page tables, so it's just something we can cross when we get
to it.

>>> Also should not we check for the alignment of the range [start...end] w=
ith
>>> respect to (1UL << [PAGE_SHIFT + page_shift]).
>>=20
>> The caller should if it specifies large page. Could check and -EINVAL
>> for incorrect alignment.
>=20
> That might be a good check here.

Will add.

>>>> @@ -474,27 +510,38 @@ struct page *vmalloc_to_page(const void *vmalloc=
_addr)
>>>>  	 */
>>>>  	VIRTUAL_BUG_ON(!is_vmalloc_or_module_addr(vmalloc_addr));
>>>> =20
>>>> +	pgd =3D pgd_offset_k(addr);
>>>>  	if (pgd_none(*pgd))
>>>>  		return NULL;
>>>> +
>>>
>>> Small nit. Stray line here.
>>>
>>> 'pgd' related changes here seem to be just cleanups and should not part=
 of this patch.
>>=20
>> Yeah I figure it doesn't matter to make small changes close by, but
>> maybe that's more frowned upon now for git blame?
>=20
> Right. But I guess it should be okay if you can make vmalloc_to_page()
> changes as a separate patch. This patch which adds a new feature should
> not have any clean ups IMHO.

Well... that alone would be a new feature too. Or could be considered
a bug fix, which makes it even more important not to contain
superfluous changes.

Is there a real prohibition on small slightly peripheral tidying
like this? I don't think I'd bother sending a lone patch just to
change a couple lines of spacing.

>>>>  	p4d =3D p4d_offset(pgd, addr);
>>>>  	if (p4d_none(*p4d))
>>>>  		return NULL;
>>>> -	pud =3D pud_offset(p4d, addr);
>>>> +#ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
>>>> +	if (p4d_large(*p4d))
>>>> +		return p4d_page(*p4d) + ((addr & ~P4D_MASK) >> PAGE_SHIFT);
>>>> +#endif
>>>> +	if (WARN_ON_ONCE(p4d_bad(*p4d)))
>>>> +		return NULL;
>>>> =20
>>>> -	/*
>>>> -	 * Don't dereference bad PUD or PMD (below) entries. This will also
>>>> -	 * identify huge mappings, which we may encounter on architectures
>>>> -	 * that define CONFIG_HAVE_ARCH_HUGE_VMAP=3Dy. Such regions will be
>>>> -	 * identified as vmalloc addresses by is_vmalloc_addr(), but are
>>>> -	 * not [unambiguously] associated with a struct page, so there is
>>>> -	 * no correct value to return for them.
>>>> -	 */
>>>
>>> What changed the situation so that we could return struct page for a hu=
ge
>>> mapping now ?
>>=20
>> For the PUD case? Nothing changed, per se, we I just calculate the
>> correct struct page now, so I may return it.
>=20
> I was just curious what prevented this earlier (before this series). The
> comment here and commit message which added this change making me wonder
> what was the reason for not doing this earlier. =20

Just not implemented I guess.

>>> AFAICT even after this patch, PUD/P4D level huge pages can only
>>> be created with ioremap_page_range() not with vmalloc() which creates P=
MD
>>> sized mappings only. Hence if it's okay to dereference struct page of a=
 huge
>>> mapping (not withstanding the comment here) it should be part of an ear=
lier
>>> patch fixing it first for existing ioremap_page_range() huge mappings.
>>=20
>> Possibly yes, we can consider 029c54b095995 to be a band-aid for huge
>> vmaps which is fixed properly by this change, in which case it could
>> make sense to break this into its own patch.
>=20
> On arm64 [pud|pmd]_bad() calls out huge mappings at PUD or PMD. I still w=
onder what
> Ard (copied him now) meant by "not [unambiguously] associated with a stru=
ct page".
> He also mentioned about compound pages in the commit message. Anyways the=
se makes
> sense (fetching the struct page) unless I am missing something. But shoul=
d be part
> of a separate patch.

I do somewhat see the intention of the commit message, but if we
consider the vmap/iomap layer's choice of page size as transparent to
the caller, and the vmalloc_to_page API has always been specifically
interested in the PAGE_SIZE struct page, then my patch is fine and
introduces no problems. It restores the API functionality to be the
same regardless of whether small or large pages were used for the
actual mapping.

>>>> +	if (IS_ENABLED(CONFIG_HAVE_ARCH_HUGE_VMAP)) {
>>>> +		unsigned long size_per_node;
>>>> +
>>>> +		size_per_node =3D size;
>>>> +		if (node =3D=3D NUMA_NO_NODE)
>>>> +			size_per_node /=3D num_online_nodes();
>>>> +		if (size_per_node >=3D PMD_SIZE)
>>>> +			shift =3D PMD_SHIFT;
>>>
>>> There are two problems here.
>>>
>>> 1. Should not size_per_node be aligned with PMD_SIZE to avoid wasting m=
emory later
>>>    because of alignment upwards (making it worse for NUMA_NO_NODE)
>>=20
>> I'm not sure what you mean, it's just a heuristic to check for node
>> interleaving, and use small pages if large can not interleave well.
>>=20
>>> 2. What about PUD_SIZE which is not considered here at all
>>=20
>> Yeah, not doing PUD pages at all. It would be pretty trivial to add=20
>> after PMD is working, but would it actually get used anywhere?
>=20
> But it should make this feature logically complete. Allocation attempts c=
an start
> at right pgtable level depending on the requested size. I dont think it w=
ill have
> any performance impact or something.

I disagree that's necessary or desirable for PMD support here. Sure
an arch might have PUD size within MAX_ORDER and implement that, but
it's just something that can be implemented when the time comes.

There's nothing about this patch that hinders being extendedto PUD
level I just won't add code that's not used and I can't test.

Thanks for the detailed review, I appreciate it.

Thanks,
Nick
=

