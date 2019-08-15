Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F106C3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 20:18:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD1672173E
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 20:18:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="Ju5cEMjQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD1672173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 700656B0275; Thu, 15 Aug 2019 16:18:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 68A1D6B0277; Thu, 15 Aug 2019 16:18:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5532D6B027A; Thu, 15 Aug 2019 16:18:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0108.hostedemail.com [216.40.44.108])
	by kanga.kvack.org (Postfix) with ESMTP id 2EE9D6B0275
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 16:18:56 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id CF335181AC9AE
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 20:18:55 +0000 (UTC)
X-FDA: 75825775830.20.chair87_30c6596c17c2c
X-HE-Tag: chair87_30c6596c17c2c
X-Filterd-Recvd-Size: 6394
Received: from mail-ed1-f66.google.com (mail-ed1-f66.google.com [209.85.208.66])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 20:18:55 +0000 (UTC)
Received: by mail-ed1-f66.google.com with SMTP id h13so3212670edq.10
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 13:18:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=AxiXdJJYXpzjPIpLv2Ddxotgylmhlwtib1+7lvBDYak=;
        b=Ju5cEMjQPSyBe5Qdc1WzBz5Ov2k2ICfZUob39j/oyK3i8LoFDj+5xFzSfZlAK54Kwp
         czoNKnAMW8wUiIKRq8iHCR5/hYI1EeQIJowboQ2123licx38xK3w8mH/nMX+ssbumUek
         cPcWRL0fjhtIgMYkonmtKhgvqZCvwdZP24IBnbbwIjzEdBBB5WJSqnDtzrYSbxY+Zf7o
         J3Ulenc6DRQk3xc+D0kIuO17NZVBAp2NHWEqj157pUGGo2AA8mNOyfundV2UHi4HUYFg
         I+SHJa5kYajDhB+N6oMpbnBI1K/s9bUciTkjsjkSRledR7MfCuC91DKOo+ACYc5l5E79
         zt3g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=AxiXdJJYXpzjPIpLv2Ddxotgylmhlwtib1+7lvBDYak=;
        b=A7RaJbsjY4PAtKJ98A4aB/3bBJ4ksBhmhXNce7ODtesfowgyb0zTHKfXlhL3yWkEua
         7fOGygo96w2CvycNQNwJJc1M3mtkHCdq9MJ4hWb4+Aq/LkbCoNwHMbUC9g2sGtZjSR4G
         IMJRZcXDZ5ZuF8/dGl1M14EP9Cy0+kS1FbYEtzb7aaf02P5QsQm/MUt0IOpS9wqUPagV
         BY98t+BJJLo+aSHJ/BioZkAHsl61d21yoTzeTmXwdL6bSt/ZljZCvW/KTGWJyIkVBdA4
         tsmKhGePTijTc0wpOQPt+fEerXAnzA7mB2qhAKKykDRm95m+AX8rWHiE1Ua32yCznJ1g
         +gwg==
X-Gm-Message-State: APjAAAXcFBNVgF1c9DRMnLSHA9BHovbBogreXjPgnrDzK/D/96X44n5V
	w80CVnDf5vDm5C54PQDfk4u+0yCRR6Piyq0Me4a+Tg==
X-Google-Smtp-Source: APXvYqxDqYmpkSZeqPgeXbtT8kCNF6W+EAndNXYXrDbS40C1YMhrbgAvoxEdsH1jiLldvnT389ZR52u5JUC9ZljwS7k=
X-Received: by 2002:aa7:d48c:: with SMTP id b12mr7277828edr.170.1565900333819;
 Thu, 15 Aug 2019 13:18:53 -0700 (PDT)
MIME-Version: 1.0
References: <20190801152439.11363-1-pasha.tatashin@soleen.com>
 <20190801152439.11363-3-pasha.tatashin@soleen.com> <e00455af-a9f6-82e1-4c0d-78fae01ae00a@arm.com>
In-Reply-To: <e00455af-a9f6-82e1-4c0d-78fae01ae00a@arm.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Thu, 15 Aug 2019 16:18:43 -0400
Message-ID: <CA+CK2bD-_34o0McpFwSYgEDyFa8MDXWUNid0GgVsUKC=ZiQzMg@mail.gmail.com>
Subject: Re: [PATCH v1 2/8] arm64, mm: transitional tables
To: James Morse <james.morse@arm.com>
Cc: James Morris <jmorris@namei.org>, Sasha Levin <sashal@kernel.org>, 
	"Eric W. Biederman" <ebiederm@xmission.com>, kexec mailing list <kexec@lists.infradead.org>, 
	LKML <linux-kernel@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>, 
	Catalin Marinas <catalin.marinas@arm.com>, will@kernel.org, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, Marc Zyngier <marc.zyngier@arm.com>, 
	Vladimir Murzin <vladimir.murzin@arm.com>, Matthias Brugger <matthias.bgg@gmail.com>, 
	Bhupesh Sharma <bhsharma@redhat.com>, linux-mm <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 2:11 PM James Morse <james.morse@arm.com> wrote:
>
> Hi Pavel,
>
> On 01/08/2019 16:24, Pavel Tatashin wrote:
> > There are cases where normal kernel pages tables, i.e. idmap_pg_dir
> > and swapper_pg_dir are not sufficient because they may be overwritten.
> >
> > This happens when we transition from one world to another: for example
> > during kexec kernel relocation transition, and also during hibernate
> > kernel restore transition.
> >
> > In these cases, if MMU is needed, the page table memory must be allocated
> > from a safe place. Transitional tables is intended to allow just that.
>
> > diff --git a/arch/arm64/include/asm/pgtable-hwdef.h b/arch/arm64/include/asm/pgtable-hwdef.h
> > index db92950bb1a0..dcb4f13c7888 100644
> > --- a/arch/arm64/include/asm/pgtable-hwdef.h
> > +++ b/arch/arm64/include/asm/pgtable-hwdef.h
> > @@ -110,6 +110,7 @@
> >  #define PUD_TABLE_BIT                (_AT(pudval_t, 1) << 1)
> >  #define PUD_TYPE_MASK                (_AT(pudval_t, 3) << 0)
> >  #define PUD_TYPE_SECT                (_AT(pudval_t, 1) << 0)
> > +#define PUD_SECT_RDONLY              (_AT(pudval_t, 1) << 7)         /* AP[2] */
>
> This shouldn't be needed. As far as I'm aware, we only get read-only pages in the linear
> map from debug-pagealloc, and the module aliases. Both of which require the linear map to
> be made of page-size mappings.
>
> Where are you seeing these?

This was done simply for generalization.

In old copy_pud:

445   set_pud(dst_pudp,
446   __pud(pud_val(pud) & ~PMD_SECT_RDONLY));

In new trans_table_copy_pud():
119                 if (!pud_table(src_pud)) {
120                         if (info->trans_flags & TRANS_MKWRITE)
121                                 pud_val(src_pud) &= ~PUD_SECT_RDONLY;

If you want, I can replace it with PMD_SECT_RDONLY

> > + * trans_flags
> > + *   - bitmap with flags that control how page table is filled.
> > + *     TRANS_MKWRITE: during page table copy make PTE, PME, and PUD page
> > + *                    writeable by removing RDONLY flag from PTE.
> > + *     TRANS_MKVALID: during page table copy, if PTE present, but not valid,
> > + *                    make it valid.
> > + *     TRANS_CHECKPFN: During page table copy, for every PTE entry check that
> > + *                     PFN that this PTE points to is valid. Otherwise return
> > + *                     -ENXIO
>
> Adding top-level global knobs to manipulate the copied linear map is going to lead to
> bugs. The existing code will only change the PTE in specific circumstances, that it tests
> for, that only happen at the PTE level.

I am simply doing the same what the old code is doing:

hibernate sets this flag if: debug_pagealloc_enabled() and trans_table
in this case check if pfn_valid() or not. This is part of
generalization, without which it is not possible to re-use the code
between kexec and hibernate.

>
>
> > + *     TRANS_FORCEMAP: During page map, if translation exists, force
> > + *                     overwrite it. Otherwise -ENXIO may be returned by
> > + *                     trans_table_map_* functions if conflict is detected.
>

I will remove it.

Thank you,
Pasha

