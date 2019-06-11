Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B7EDC43218
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 00:19:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B5D720820
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 00:19:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TBlGmlc2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B5D720820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B9B6C6B026B; Mon, 10 Jun 2019 20:19:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B4BF36B026C; Mon, 10 Jun 2019 20:19:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A144E6B026D; Mon, 10 Jun 2019 20:19:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 61DCF6B026B
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 20:19:17 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id j36so7916629pgb.20
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 17:19:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:subject:to:cc
         :references:in-reply-to:mime-version:user-agent:message-id
         :content-transfer-encoding;
        bh=kf1YyuZJhLbGytx9oEnxtDtE8fc9RKGSzHH7TIul9Sc=;
        b=BzdCbTAcuv7J74ihO8WasCrNgVTXSJkiSI1Z4Mw0TV7pQP85Wk9k3Vyie5iTvz4Kbs
         HTzytWiOLVLiElcQTkY1GwbwvQZFmaT5F1j8yrjJgjaL7plmRjXGz5ASZvWX1SdkRbXC
         gQhkvmlQKa26alUXvqCgoV7M30/MrMDWa1289l0ZuS7NzVuJ6tbHcrD76dyp7d9Sc70o
         lzBEO4jgsP8RgeYGyfr/G9qtBl5nxN0AybDz6dlrffSoA+jqEhbj1pT0DkyUHP2N6e/C
         m6DfnC6NrhWD93kf3V6eAS6hXE2Qx80DWy9br6qllgrRis6Pvh4swk+8f2hbHTBlyfoL
         czIQ==
X-Gm-Message-State: APjAAAUdjfeGAn91uJG3oIYlVRVBnzozGqFuTSlBcr1nIs+hQ8BJk/kb
	w+raPHdzy1ZrymOrgQm+/xyyWMN9iRx85SKmtd9zt8m1L4WG7W5NIVnC5NFwLV2CTIQB5/WkImt
	4IxLN018DYStnUl/pqg10ZRxAQv69p+XqS2ukaBHisyomqjGNeLKs7D3Ob2RBUeA7dQ==
X-Received: by 2002:a63:3710:: with SMTP id e16mr17591660pga.391.1560212356847;
        Mon, 10 Jun 2019 17:19:16 -0700 (PDT)
X-Received: by 2002:a63:3710:: with SMTP id e16mr17591586pga.391.1560212355297;
        Mon, 10 Jun 2019 17:19:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560212355; cv=none;
        d=google.com; s=arc-20160816;
        b=vKh90uiPSzyLIuS2lV3hd5wH3mm1B0ljfay4tu1ZJCtSJmZY6ZpwX6I3jzO8fkazCe
         vm+MbBVPSJcb3ncPpJCcsfU8IlEFbro5ydjOkIoSrFKW1qQuCk+hCheBfie4gXeZSb56
         c6jXdzImpPEup9BWIM0nCDXADFlvuh7DQnQ50OCWhq6r6dT8e1McaLM52CwueR9rMU66
         tGTxKXxel2z0pBE6HuNAu/0WBNH0DIWORpTJRKTAKJJD0BN3DOVhPLAYJz3Gkar1rLvB
         5/cDF2+yHO+H/sRF+2H5qbShf5mNSqC1y1qYJKnOkfbnagqM2j654B+c5fCMLYUNAkpJ
         7YNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:message-id:user-agent:mime-version
         :in-reply-to:references:cc:to:subject:from:date:dkim-signature;
        bh=kf1YyuZJhLbGytx9oEnxtDtE8fc9RKGSzHH7TIul9Sc=;
        b=oEQi89NzDBQ7b079lSGwWMFeWV4gl+az0VKCwxUSc6APVRTSjEsu7X68GXMW6oaL4I
         ftXVHlFOB6Zris6MTxw+GJvXS93WW6MBagHquRBMV12z+ZnRPrZnT07DPKPmOEqaBKK5
         UAS8MlwUVX3gwuOpLQf+5+Fq0VuzZYFVukHATpkpHqaIpRDCEywn1Gw1HYKt2TMhPf7A
         J0FtnCkJYA//qbgBBIEpjWcaaRsL83eiiNb3j50rfe6mi62X7GdaO4xQYZ2Bz94WVIur
         LWVvX1q8Ujxw7L1fEU0jEq/W5tW5cFtZN1cH1VTUdEDk6WPDTy1QQVFRRAqS/HRTq4H4
         t8PA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TBlGmlc2;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p31sor1103205pjp.0.2019.06.10.17.19.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Jun 2019 17:19:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TBlGmlc2;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:subject:to:cc:references:in-reply-to:mime-version
         :user-agent:message-id:content-transfer-encoding;
        bh=kf1YyuZJhLbGytx9oEnxtDtE8fc9RKGSzHH7TIul9Sc=;
        b=TBlGmlc2oLGUtlyY46DOUgonwGAEtYMUYdhm0cllicVyUI/BPgtgaOmnAjGaaYVHzN
         A0fjwALwgLUqGviO7+StCoG6dyy0wYnm7XmChvKgXgwT8Qjjns2QmYK+mW/FoML5bG+A
         jI7xyqR0jHWWYVOYiZ3sfsdno+Jo5DA0eutICcA+OwAf67XO70Y0G1KMUivaBlvI6Zm+
         CcNuKo09YMTLWA3A2/BkVQQ4J+GLspGgjZ15hGainVhKSWVO6jsyRTKcillUNWrUzeU1
         FUZnJYaP4sXXynKeHQ2XsEKgLlkAnWTdksA+RORUON2cc0iaaywOWy3W2KaeST5PzSl/
         PHyg==
X-Google-Smtp-Source: APXvYqxgMYWWPx1ZQFXfw2cg/UbyzAwuDoyfR2sYAnz5rU+dlw9qzLHOiKLcKWY6Wi9DH2lgoB0iGA==
X-Received: by 2002:a17:90a:778b:: with SMTP id v11mr24564239pjk.132.1560212354810;
        Mon, 10 Jun 2019 17:19:14 -0700 (PDT)
Received: from localhost (60-241-56-246.tpgi.com.au. [60.241.56.246])
        by smtp.gmail.com with ESMTPSA id p65sm9713021pfp.58.2019.06.10.17.19.13
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 10 Jun 2019 17:19:14 -0700 (PDT)
Date: Tue, 11 Jun 2019 10:16:43 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 4/4] mm/vmalloc: Hugepage vmalloc mappings
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org
Cc: linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org
References: <20190610043838.27916-1-npiggin@gmail.com>
	<20190610043838.27916-4-npiggin@gmail.com>
	<a3b2dcb1-148e-b2f1-e181-92c16d868bc9@arm.com>
In-Reply-To: <a3b2dcb1-148e-b2f1-e181-92c16d868bc9@arm.com>
MIME-Version: 1.0
User-Agent: astroid/0.14.0 (https://github.com/astroidmail/astroid)
Message-Id: <1560210095.fpemv3ultp.astroid@bobo.none>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Anshuman Khandual's on June 10, 2019 6:53 pm:
> On 06/10/2019 10:08 AM, Nicholas Piggin wrote:
>> For platforms that define HAVE_ARCH_HUGE_VMAP, have vmap allow vmalloc t=
o
>> allocate huge pages and map them.
>=20
> IIUC that extends HAVE_ARCH_HUGE_VMAP from iormap to vmalloc.=20
>=20
>>=20
>> This brings dTLB misses for linux kernel tree `git diff` from 45,000 to
>> 8,000 on a Kaby Lake KVM guest with 8MB dentry hash and mitigations=3Dof=
f
>> (performance is in the noise, under 1% difference, page tables are likel=
y
>> to be well cached for this workload). Similar numbers are seen on POWER9=
.
>=20
> Sure will try this on arm64.
>=20
>>=20
>> Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
>> ---
>>  include/asm-generic/4level-fixup.h |   1 +
>>  include/asm-generic/5level-fixup.h |   1 +
>>  include/linux/vmalloc.h            |   1 +
>>  mm/vmalloc.c                       | 132 +++++++++++++++++++++++------
>>  4 files changed, 107 insertions(+), 28 deletions(-)
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
>=20
> Both of these are required from vmalloc_to_page() which as per a later co=
mment
> should be part of a prerequisite patch before this series.

I'm not sure what you mean. This patch is where they get used.

Possibly I could split this and the vmalloc_to_page change out. I'll
consider it.

>> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
>> index 812bea5866d6..4c92dc608928 100644
>> --- a/include/linux/vmalloc.h
>> +++ b/include/linux/vmalloc.h
>> @@ -42,6 +42,7 @@ struct vm_struct {
>>  	unsigned long		size;
>>  	unsigned long		flags;
>>  	struct page		**pages;
>> +	unsigned int		page_shift;
>=20
> So the entire vm_struct will be mapped with a single page_shift. It canno=
t have
> mix and match mappings with PAGE_SIZE, PMD_SIZE, PUD_SIZE etc in case the
> allocation fails for larger ones, falling back etc what over other reason=
s.

For now, yes. I have a bit of follow up work to improve that and make
it able to fall back, but it's a bit more churn and not a significant
benefit just yet because there are not a lot of very large vmallocs
(except the early hashes which can be satisfied with large allocs).

>=20
>>  	unsigned int		nr_pages;
>>  	phys_addr_t		phys_addr;
>>  	const void		*caller;
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index dd27cfb29b10..0cf8e861caeb 100644
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
>> @@ -440,6 +441,41 @@ static int vmap_pages_range(unsigned long start, un=
signed long end,
>>  	return ret;
>>  }
>> =20
>> +#ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
>> +static int vmap_hpages_range(unsigned long start, unsigned long end,
>=20
> A small nit (if you agree) s/hpages/huge_pages/

Hmm. It's not actually a good function name because it can do small
pages as well. vmap_pages_size_range or something may be better.

>=20
>> +				   pgprot_t prot, struct page **pages,
>=20
> Re-order (prot <---> pages) just to follow the standard like before.

Will do.

>> +				   unsigned int page_shift)
>> +{
>> +	unsigned long addr =3D start;
>> +	unsigned int i, nr =3D (end - start) >> (PAGE_SHIFT + page_shift);
>=20
> s/nr/nr_huge_pages ?

Sure.

> Also should not we check for the alignment of the range [start...end] wit=
h
> respect to (1UL << [PAGE_SHIFT + page_shift]).

The caller should if it specifies large page. Could check and -EINVAL
for incorrect alignment.

>> +
>> +	for (i =3D 0; i < nr; i++) {
>> +		int err;
>> +
>> +		err =3D vmap_range_noflush(addr,
>> +					addr + (PAGE_SIZE << page_shift),
>> +					__pa(page_address(pages[i])), prot,
>> +					PAGE_SHIFT + page_shift);
>> +		if (err)
>> +			return err;
>> +
>> +		addr +=3D PAGE_SIZE << page_shift;
>> +	}
>> +	flush_cache_vmap(start, end);
>> +
>> +	return nr;
>> +}
>> +#else
>> +static int vmap_hpages_range(unsigned long start, unsigned long end,
>> +			   pgprot_t prot, struct page **pages,
>> +			   unsigned int page_shift)
>> +{
>> +	BUG_ON(page_shift !=3D PAGE_SIZE);
>> +	return vmap_pages_range(start, end, prot, pages);
>> +}
>> +#endif
>> +
>> +
>>  int is_vmalloc_or_module_addr(const void *x)
>>  {
>>  	/*
>> @@ -462,7 +498,7 @@ struct page *vmalloc_to_page(const void *vmalloc_add=
r)
>>  {
>>  	unsigned long addr =3D (unsigned long) vmalloc_addr;
>>  	struct page *page =3D NULL;
>> -	pgd_t *pgd =3D pgd_offset_k(addr);
>> +	pgd_t *pgd;
>>  	p4d_t *p4d;
>>  	pud_t *pud;
>>  	pmd_t *pmd;
>> @@ -474,27 +510,38 @@ struct page *vmalloc_to_page(const void *vmalloc_a=
ddr)
>>  	 */
>>  	VIRTUAL_BUG_ON(!is_vmalloc_or_module_addr(vmalloc_addr));
>> =20
>> +	pgd =3D pgd_offset_k(addr);
>>  	if (pgd_none(*pgd))
>>  		return NULL;
>> +
>=20
> Small nit. Stray line here.
>=20
> 'pgd' related changes here seem to be just cleanups and should not part o=
f this patch.

Yeah I figure it doesn't matter to make small changes close by, but
maybe that's more frowned upon now for git blame?

>>  	p4d =3D p4d_offset(pgd, addr);
>>  	if (p4d_none(*p4d))
>>  		return NULL;
>> -	pud =3D pud_offset(p4d, addr);
>> +#ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
>> +	if (p4d_large(*p4d))
>> +		return p4d_page(*p4d) + ((addr & ~P4D_MASK) >> PAGE_SHIFT);
>> +#endif
>> +	if (WARN_ON_ONCE(p4d_bad(*p4d)))
>> +		return NULL;
>> =20
>> -	/*
>> -	 * Don't dereference bad PUD or PMD (below) entries. This will also
>> -	 * identify huge mappings, which we may encounter on architectures
>> -	 * that define CONFIG_HAVE_ARCH_HUGE_VMAP=3Dy. Such regions will be
>> -	 * identified as vmalloc addresses by is_vmalloc_addr(), but are
>> -	 * not [unambiguously] associated with a struct page, so there is
>> -	 * no correct value to return for them.
>> -	 */
>=20
> What changed the situation so that we could return struct page for a huge
> mapping now ?

For the PUD case? Nothing changed, per se, we I just calculate the
correct struct page now, so I may return it.

> AFAICT even after this patch, PUD/P4D level huge pages can only
> be created with ioremap_page_range() not with vmalloc() which creates PMD
> sized mappings only. Hence if it's okay to dereference struct page of a h=
uge
> mapping (not withstanding the comment here) it should be part of an earli=
er
> patch fixing it first for existing ioremap_page_range() huge mappings.

Possibly yes, we can consider 029c54b095995 to be a band-aid for huge
vmaps which is fixed properly by this change, in which case it could
make sense to break this into its own patch.

>=20
>> -	WARN_ON_ONCE(pud_bad(*pud));
>> -	if (pud_none(*pud) || pud_bad(*pud))
>> +	pud =3D pud_offset(p4d, addr);
>> +	if (pud_none(*pud))
>> +		return NULL;
>> +#ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
>> +	if (pud_large(*pud))
>> +		return pud_page(*pud) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
>> +#endif
>> +	if (WARN_ON_ONCE(pud_bad(*pud)))
>>  		return NULL;
>> +
>>  	pmd =3D pmd_offset(pud, addr);
>> -	WARN_ON_ONCE(pmd_bad(*pmd));
>> -	if (pmd_none(*pmd) || pmd_bad(*pmd))
>> +	if (pmd_none(*pmd))
>> +		return NULL;
>> +#ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
>> +	if (pmd_large(*pmd))
>> +		return pmd_page(*pmd) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
>> +#endif
>> +	if (WARN_ON_ONCE(pmd_bad(*pmd)))
>>  		return NULL;
>=20
> At each page table level, we are checking in this order
>=20
> pXX_none() --> pXX_large() --> pXX_bad()
>=20
> Are not these alternative orders bit better
>=20
> pXX_bad() --> pXX_none() --> pXX_large()
>=20
> Or
>=20
> pXX_none() --> pXX_bad() --> pXX_large()
>=20
> Checking for pXX_bad() at the end does not make much sense.

Yeah the order tends to go none->bad. It's not 100% clear we can
test bad before none (at least it goes against convention). But good
point should be changed to your last sequence I think.

>=20
>> =20
>>  	ptep =3D pte_offset_map(pmd, addr);
>> @@ -502,6 +549,7 @@ struct page *vmalloc_to_page(const void *vmalloc_add=
r)
>>  	if (pte_present(pte))
>>  		page =3D pte_page(pte);
>>  	pte_unmap(ptep);
>> +
>=20
> Small nit. Stray line here.

I don't mind adding some lines here and there, like here. It is an
unrelated (alleged-)cleanup though.

>=20
>>  	return page;
>>  }
>>  EXPORT_SYMBOL(vmalloc_to_page);
>> @@ -2185,8 +2233,9 @@ static struct vm_struct *__get_vm_area_node(unsign=
ed long size,
>>  		return NULL;
>> =20
>>  	if (flags & VM_IOREMAP)
>> -		align =3D 1ul << clamp_t(int, get_count_order_long(size),
>> -				       PAGE_SHIFT, IOREMAP_MAX_ORDER);
>> +		align =3D max(align,
>> +				1ul << clamp_t(int, get_count_order_long(size),
>> +				       PAGE_SHIFT, IOREMAP_MAX_ORDER));
>> =20
>>  	area =3D kzalloc_node(sizeof(*area), gfp_mask & GFP_RECLAIM_MASK, node=
);
>>  	if (unlikely(!area))
>> @@ -2398,7 +2447,7 @@ static void __vunmap(const void *addr, int dealloc=
ate_pages)
>>  			struct page *page =3D area->pages[i];
>> =20
>>  			BUG_ON(!page);
>> -			__free_pages(page, 0);
>> +			__free_pages(page, area->page_shift);
>=20
> area->page_shift' turns out to be effective page order. I think the name =
here is bit
> misleading. s/page_shift/page_order or nr_pages should be better IMHO. pa=
ge_shift is
> not actual shift (1UL << area->shift to get size) nor does it sound like =
page 'order'.

Yeah good point.

>>  		}
>> =20
>>  		kvfree(area->pages);
>> @@ -2541,14 +2590,17 @@ static void *__vmalloc_area_node(struct vm_struc=
t *area, gfp_t gfp_mask,
>>  				 pgprot_t prot, int node)
>>  {
>>  	struct page **pages;
>> +	unsigned long addr =3D (unsigned long)area->addr;
>> +	unsigned long size =3D get_vm_area_size(area);
>> +	unsigned int page_shift =3D area->page_shift;
>> +	unsigned int shift =3D page_shift + PAGE_SHIFT;
>>  	unsigned int nr_pages, array_size, i;
>>  	const gfp_t nested_gfp =3D (gfp_mask & GFP_RECLAIM_MASK) | __GFP_ZERO;
>>  	const gfp_t alloc_mask =3D gfp_mask | __GFP_NOWARN;
>>  	const gfp_t highmem_mask =3D (gfp_mask & (GFP_DMA | GFP_DMA32)) ?
>> -					0 :
>> -					__GFP_HIGHMEM;
>> +					0 : __GFP_HIGHMEM;
>> =20
>> -	nr_pages =3D get_vm_area_size(area) >> PAGE_SHIFT;
>> +	nr_pages =3D size >> shift;
>>  	array_size =3D (nr_pages * sizeof(struct page *));
>> =20
>>  	area->nr_pages =3D nr_pages;
>> @@ -2569,10 +2621,8 @@ static void *__vmalloc_area_node(struct vm_struct=
 *area, gfp_t gfp_mask,
>>  	for (i =3D 0; i < area->nr_pages; i++) {
>>  		struct page *page;
>> =20
>> -		if (node =3D=3D NUMA_NO_NODE)
>> -			page =3D alloc_page(alloc_mask|highmem_mask);
>> -		else
>> -			page =3D alloc_pages_node(node, alloc_mask|highmem_mask, 0);
>> +		page =3D alloc_pages_node(node,
>> +				alloc_mask|highmem_mask, page_shift);
>=20
> alloc_mask remains the exact same like before even for these high order p=
ages.

Is there a problem there? I don't see.

>> =20
>>  		if (unlikely(!page)) {
>>  			/* Successfully allocated i pages, free them in __vunmap() */
>> @@ -2584,8 +2634,9 @@ static void *__vmalloc_area_node(struct vm_struct =
*area, gfp_t gfp_mask,
>>  			cond_resched();
>>  	}
>> =20
>> -	if (map_vm_area(area, prot, pages))
>> +	if (vmap_hpages_range(addr, addr + size, prot, pages, page_shift) < 0)
>>  		goto fail;
>> +
>>  	return area->addr;
>> =20
>>  fail:
>> @@ -2619,22 +2670,39 @@ void *__vmalloc_node_range(unsigned long size, u=
nsigned long align,
>>  			pgprot_t prot, unsigned long vm_flags, int node,
>>  			const void *caller)
>>  {
>> -	struct vm_struct *area;
>> +	struct vm_struct *area =3D NULL;
>>  	void *addr;
>>  	unsigned long real_size =3D size;
>> +	unsigned long real_align =3D align;
>> +	unsigned int shift =3D PAGE_SHIFT;
>> =20
>>  	size =3D PAGE_ALIGN(size);
>>  	if (!size || (size >> PAGE_SHIFT) > totalram_pages())
>>  		goto fail;
>> =20
>> +	if (IS_ENABLED(CONFIG_HAVE_ARCH_HUGE_VMAP)) {
>> +		unsigned long size_per_node;
>> +
>> +		size_per_node =3D size;
>> +		if (node =3D=3D NUMA_NO_NODE)
>> +			size_per_node /=3D num_online_nodes();
>> +		if (size_per_node >=3D PMD_SIZE)
>> +			shift =3D PMD_SHIFT;
>=20
> There are two problems here.
>=20
> 1. Should not size_per_node be aligned with PMD_SIZE to avoid wasting mem=
ory later
>    because of alignment upwards (making it worse for NUMA_NO_NODE)

I'm not sure what you mean, it's just a heuristic to check for node
interleaving, and use small pages if large can not interleave well.

> 2. What about PUD_SIZE which is not considered here at all

Yeah, not doing PUD pages at all. It would be pretty trivial to add=20
after PMD is working, but would it actually get used anywhere?

> 3. We should have similar knobs like ioremap controlling different size h=
uge mappings
>=20
> static int __read_mostly ioremap_p4d_capable;
> static int __read_mostly ioremap_pud_capable;
> static int __read_mostly ioremap_pmd_capable;
> static int __read_mostly ioremap_huge_disabled;
>=20
> while also giving arch a chance to weigh in through similar overrides lik=
e these.
>=20
> arch_ioremap_[pud|pmd]_supported() ---> probably unifying it for vmalloc(=
)=20

I'm not sure if that makes sense. IO mappings I could see maybe having
some quirks or bugs or support issues. Cacheable mappings should be the
"base" for supporting larger pages, if the platform has trouble with
those then it should just avoid the feature I think.

Or is there a good reason to add the option? I don't mind, I just want
to avoid proliferation.

>> +	}
>> +again:
>> +	align =3D max(real_align, 1UL << shift);
>> +	size =3D ALIGN(real_size, align);
>> +
>>  	area =3D __get_vm_area_node(size, align, VM_ALLOC | VM_UNINITIALIZED |
>>  				vm_flags, start, end, node, gfp_mask, caller);
>>  	if (!area)
>>  		goto fail;
>> =20
>> +	area->page_shift =3D shift - PAGE_SHIFT;
>> +
>>  	addr =3D __vmalloc_area_node(area, gfp_mask, prot, node);
>>  	if (!addr)
>> -		return NULL;
>> +		goto fail;
>> =20
>>  	/*
>>  	 * In this function, newly allocated vm_struct has VM_UNINITIALIZED
>> @@ -2648,8 +2716,16 @@ void *__vmalloc_node_range(unsigned long size, un=
signed long align,
>>  	return addr;
>> =20
>>  fail:
>> -	warn_alloc(gfp_mask, NULL,
>> +	if (shift =3D=3D PMD_SHIFT) {
>> +		shift =3D PAGE_SHIFT;
>> +		goto again;
>> +	}
>=20
> PUD_SHIFT should be accommodated here as well while falling back to lower
> mapping sizes in case previous allocation attempt fails.
>=20

This also would be part of PUD support.

Thanks,
Nick
=

