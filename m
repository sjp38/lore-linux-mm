Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3A0DC4646C
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 00:21:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70D1520644
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 00:21:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lCqYJd0f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70D1520644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C1618E0003; Mon, 24 Jun 2019 20:21:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0715F8E0002; Mon, 24 Jun 2019 20:21:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA2B28E0003; Mon, 24 Jun 2019 20:21:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B1D488E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 20:21:17 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id a20so10599836pfn.19
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:21:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:subject:to:cc
         :references:in-reply-to:mime-version:user-agent:message-id
         :content-transfer-encoding;
        bh=9GWfUGprvA4ILcpimuVJoGtm5PW6KPiiPRGCbFZh52w=;
        b=LHI6nT7FqymrBPxLxUHTtqHxeWKywl+vWZW7d0gTCTqG8fbzsww0yvvBt9HGwDVrUc
         anVV8+1xUGcQvnmkC4xDGjsLQ7xE8p/F3uZ9D+tkAbk59OQiiW8vuUEcfPTCBAuDUuZU
         XOKYMykJSKOVBwFJ3S07Me3wCgmMOT2sQqtim/AlLjfIBgpq+pOY8xYIayG8ZPX1d/to
         qWC0WXbNeSM7TuMq32gq7W5i9/lZopg0w6mSkEgvNWfl267SyKQevG1b3MkNef4CZLxQ
         UkV1lenW4g7Sh6fJ42QljN91yOZe9Ie3yJcK25K3TuaS6utfDx6meqm0IhR8vvvlmeQk
         FAgg==
X-Gm-Message-State: APjAAAVSjnygBlVqsiISiE+1zAiHeI6WJj+nzwputfCsTF4q5TzeA0fN
	LiKogMAJ7IpF84gcJbEZxkm5DiTf0A68dVBSUAFgp17izp+3PypTWTUHZWQVcp70Gz73tyL1ukQ
	VguLEqT55ZSQHlbDuoo3vI77OhYZ0EBsGiti7hG9dnctV1UuveojH2f2L/c2yNrcb3A==
X-Received: by 2002:a65:6481:: with SMTP id e1mr28083478pgv.408.1561422077243;
        Mon, 24 Jun 2019 17:21:17 -0700 (PDT)
X-Received: by 2002:a65:6481:: with SMTP id e1mr28083409pgv.408.1561422076342;
        Mon, 24 Jun 2019 17:21:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561422076; cv=none;
        d=google.com; s=arc-20160816;
        b=QYoWdDsq2RrwqhitXTlfstjS1cPm2QkRNyuWnuz4fHRYnZzEWJbSfM1lOp+/c6CJUr
         zTzDWTh+fAVmJy7UXtiyM7s8JLWXL7IjY1aVK9MKX9No0dFN+u5ngPU5GE13Ze5cTRrH
         BUl0apxbxrEbgK1p4Z+3OMbE8b6Ql7favGK+FcZhchfd99znuN9LJ3iq2DgieV5BXT2q
         eC/3sm8EWWE4FwBSwLKSGfrdQu4RUr2h01wvXPmg63mlFmULkgiO1JncB70ZvKJcn3Fp
         L5U371HUd/WJW6Y6A/nMYGFJkUyMOht0paVMVjIxNFN1X4nDEERsfK54og4x29pWYexM
         Y4ug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:message-id:user-agent:mime-version
         :in-reply-to:references:cc:to:subject:from:date:dkim-signature;
        bh=9GWfUGprvA4ILcpimuVJoGtm5PW6KPiiPRGCbFZh52w=;
        b=LSt3/VGOUBrmfkUe3lPKuUiTU/3dCmMzbVKbFKzGqDtK8SenO7VliNcWclUwmhW+NT
         URtwVrP8jjPQVxcXzT1VQlPqBtir6vnqlFjq46f91zhREGc/Hh0NcCV9UlzbPbjDl5a3
         aLMHQAFD3QxDXL2yAJOGm9+HrWLa8konrCPKwYPVhYN9bAhKeEVOY4wLuLL2ti3yI3yM
         Kr3iF89O7zEUbEcvlyP5BhVGBP/2NOVNEL9Fg+gU8B3AirlnvSkv1701SM99eTy1nIUl
         FgznAqHL40FNto7moc+hQhSzTXs3FQt+d9PytvuPOI26R1LaCA/kMC8Yb0Ovq/1rgMsp
         40mQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lCqYJd0f;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x6sor7963489pfa.60.2019.06.24.17.21.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 17:21:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lCqYJd0f;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:subject:to:cc:references:in-reply-to:mime-version
         :user-agent:message-id:content-transfer-encoding;
        bh=9GWfUGprvA4ILcpimuVJoGtm5PW6KPiiPRGCbFZh52w=;
        b=lCqYJd0fDqFS6i7DNl565RTG+AMIJ12ZQw/A8KlWcTmhSBSVfi7R1JjAyw0diyQp5w
         0icVERPM79uGIRc4rPDhlMIs9Eo2BQh1ycTUT9KC3ODr0hA1PyMBys+Jaotlrqmw8rAA
         Wt8yT3wpCentyV+O8DJ5e6cvFVmdPSqFV2Kc8+YOWKsXjw4VYlWdsJC5lXkAL0PqpP0o
         73Yf4SJ4tYZJkdlgJGAysG7Ig2VZPMOIU5e0ItUS6tJ6xASc27CJzVnMXH5w13pWwPWd
         Jr57070WGncwHZKG0t81ad61He+o8mdJstJQKs1+pRI7NVN6/ZXpvO99jSOqxg8lWbPb
         L5Ag==
X-Google-Smtp-Source: APXvYqyinR+SxTKAhy01mEzpneT2onpFntPNglVujvIPVOk7YeZhmGjQ045hT6anajo5VX8LeLss3w==
X-Received: by 2002:a65:4c0c:: with SMTP id u12mr35552980pgq.130.1561422075888;
        Mon, 24 Jun 2019 17:21:15 -0700 (PDT)
Received: from localhost ([1.129.213.195])
        by smtp.gmail.com with ESMTPSA id j23sm13670632pgb.63.2019.06.24.17.21.14
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 24 Jun 2019 17:21:14 -0700 (PDT)
Date: Tue, 25 Jun 2019 10:20:14 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 3/3] mm/vmalloc: fix vmalloc_to_page for huge vmap
 mappings
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Ard Biesheuvel
	<ard.biesheuvel@linaro.org>, Christophe Leroy <christophe.leroy@c-s.fr>,
	linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org,
	Mark Rutland <mark.rutland@arm.com>
References: <20190623094446.28722-1-npiggin@gmail.com>
	<20190623094446.28722-4-npiggin@gmail.com>
	<8668f76d-faad-4e57-2f7b-f2b8969b1026@arm.com>
In-Reply-To: <8668f76d-faad-4e57-2f7b-f2b8969b1026@arm.com>
MIME-Version: 1.0
User-Agent: astroid/0.14.0 (https://github.com/astroidmail/astroid)
Message-Id: <1561421882.9uwq6zqlvo.astroid@bobo.none>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Anshuman Khandual's on June 24, 2019 4:52 pm:
>=20
>=20
> On 06/23/2019 03:14 PM, Nicholas Piggin wrote:
>> vmalloc_to_page returns NULL for addresses mapped by larger pages[*].
>> Whether or not a vmap is huge depends on the architecture details,
>> alignments, boot options, etc., which the caller can not be expected
>> to know. Therefore HUGE_VMAP is a regression for vmalloc_to_page.
>>=20
>> This change teaches vmalloc_to_page about larger pages, and returns
>> the struct page that corresponds to the offset within the large page.
>> This makes the API agnostic to mapping implementation details.
>>=20
>> [*] As explained by commit 029c54b095995 ("mm/vmalloc.c: huge-vmap:
>>     fail gracefully on unexpected huge vmap mappings")
>>=20
>> Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
>> ---
>>  include/asm-generic/4level-fixup.h |  1 +
>>  include/asm-generic/5level-fixup.h |  1 +
>>  mm/vmalloc.c                       | 37 +++++++++++++++++++-----------
>>  3 files changed, 26 insertions(+), 13 deletions(-)
>>=20
>> diff --git a/include/asm-generic/4level-fixup.h b/include/asm-generic/4l=
evel-fixup.h
>> index e3667c9a33a5..3cc65a4dd093 100644
>> --- a/include/asm-generic/4level-fixup.h
>> +++ b/include/asm-generic/4level-fixup.h
>> @@ -20,6 +20,7 @@
>>  #define pud_none(pud)			0
>>  #define pud_bad(pud)			0
>>  #define pud_present(pud)		1
>> +#define pud_large(pud)			0
>>  #define pud_ERROR(pud)			do { } while (0)
>>  #define pud_clear(pud)			pgd_clear(pud)
>>  #define pud_val(pud)			pgd_val(pud)
>> diff --git a/include/asm-generic/5level-fixup.h b/include/asm-generic/5l=
evel-fixup.h
>> index bb6cb347018c..c4377db09a4f 100644
>> --- a/include/asm-generic/5level-fixup.h
>> +++ b/include/asm-generic/5level-fixup.h
>> @@ -22,6 +22,7 @@
>>  #define p4d_none(p4d)			0
>>  #define p4d_bad(p4d)			0
>>  #define p4d_present(p4d)		1
>> +#define p4d_large(p4d)			0
>>  #define p4d_ERROR(p4d)			do { } while (0)
>>  #define p4d_clear(p4d)			pgd_clear(p4d)
>>  #define p4d_val(p4d)			pgd_val(p4d)
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index 4c9e150e5ad3..4be98f700862 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -36,6 +36,7 @@
>>  #include <linux/rbtree_augmented.h>
>> =20
>>  #include <linux/uaccess.h>
>> +#include <asm/pgtable.h>
>>  #include <asm/tlbflush.h>
>>  #include <asm/shmparam.h>
>> =20
>> @@ -284,26 +285,36 @@ struct page *vmalloc_to_page(const void *vmalloc_a=
ddr)
>> =20
>>  	if (pgd_none(*pgd))
>>  		return NULL;
>> +
>>  	p4d =3D p4d_offset(pgd, addr);
>>  	if (p4d_none(*p4d))
>>  		return NULL;
>> -	pud =3D pud_offset(p4d, addr);
>> +	if (WARN_ON_ONCE(p4d_bad(*p4d)))
>> +		return NULL;
>=20
> The warning here is a required addition but it needs to be moved after p4=
d_large()
> check. Please see the next comment below.
>=20
>> +#ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
>> +	if (p4d_large(*p4d))
>> +		return p4d_page(*p4d) + ((addr & ~P4D_MASK) >> PAGE_SHIFT);
>> +#endif
>> =20
>> -	/*
>> -	 * Don't dereference bad PUD or PMD (below) entries. This will also
>> -	 * identify huge mappings, which we may encounter on architectures
>> -	 * that define CONFIG_HAVE_ARCH_HUGE_VMAP=3Dy. Such regions will be
>> -	 * identified as vmalloc addresses by is_vmalloc_addr(), but are
>> -	 * not [unambiguously] associated with a struct page, so there is
>> -	 * no correct value to return for them.
>> -	 */
>> -	WARN_ON_ONCE(pud_bad(*pud));
>> -	if (pud_none(*pud) || pud_bad(*pud))
>> +	pud =3D pud_offset(p4d, addr);
>> +	if (pud_none(*pud))
>> +		return NULL;
>> +	if (WARN_ON_ONCE(pud_bad(*pud)))
>>  		return NULL;
>> +#ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
>> +	if (pud_large(*pud))
>> +		return pud_page(*pud) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
>> +#endif
>> +
>=20
> pud_bad() on arm64 returns true when the PUD does not point to a next pag=
e
> table page implying the fact that it might be a large/huge entry. I am no=
t
> sure if the semantics holds good for other architectures too. But on arm6=
4
> if pud_large() is true, then pud_bad() will be true as well. So pud_bad()
> check must happen after pud_large() check. So the sequence here should be
>=20
> 1. pud_none()	--> Nothing is in here, return NULL
> 2. pud_large()	--> Return offset page address from the huge page mapping
> 3. pud_bad()	--> Return NULL as there is no more page table level left
>=20
> Checking pud_bad() first can return NULL for a valid huge mapping.
>=20
>>  	pmd =3D pmd_offset(pud, addr);
>> -	WARN_ON_ONCE(pmd_bad(*pmd));
>> -	if (pmd_none(*pmd) || pmd_bad(*pmd))
>> +	if (pmd_none(*pmd))
>> +		return NULL;
>> +	if (WARN_ON_ONCE(pmd_bad(*pmd)))
>>  		return NULL;
>> +#ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
>> +	if (pmd_large(*pmd))
>> +		return pmd_page(*pmd) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
>> +#endif
>=20
> Ditto.
>=20
> I see that your previous proposal had this right which got changed in thi=
s
> manner after my comments. Sorry about it.
>=20
> It was recently when I learned (correctly) that expected semantics of pxx=
_bad()
> is that - It does not point to the next page table page.  Hence I wonder =
why is
> this not renamed as pxx_table() instead to make it absolutely clear.
>=20

Okay, I'll change it and resend. It worked okay on powerpc but it
looks like the usual precedent is testing for large before bad so we
will have to go with that.

Thanks,
Nick
=

