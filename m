Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE325C00307
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 16:00:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 734AD21670
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 16:00:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="DrtnmIYB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 734AD21670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 14EF76B0005; Fri,  6 Sep 2019 12:00:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0FEED6B0007; Fri,  6 Sep 2019 12:00:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F2EE46B0008; Fri,  6 Sep 2019 12:00:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0066.hostedemail.com [216.40.44.66])
	by kanga.kvack.org (Postfix) with ESMTP id CFF236B0005
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 12:00:32 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 6AEC1181AC9B4
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 16:00:32 +0000 (UTC)
X-FDA: 75904958304.12.arch47_5bea61a84e65b
X-HE-Tag: arch47_5bea61a84e65b
X-Filterd-Recvd-Size: 6094
Received: from mail-ed1-f67.google.com (mail-ed1-f67.google.com [209.85.208.67])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 16:00:31 +0000 (UTC)
Received: by mail-ed1-f67.google.com with SMTP id p2so5565200edx.11
        for <linux-mm@kvack.org>; Fri, 06 Sep 2019 09:00:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=QiD1TwL/Id//xaqpbzs1lfvzt5WvDuUNyjDuGVpOVM8=;
        b=DrtnmIYB0GfZaFo92tmzBcMPxFlqSxYyiLcJ2k29wb15hQ6tGomjNtco6mkGB1/KM2
         x/qlHJWajTbuieX2M+cfvfX55UTgvqs1Uqqdh/zAUvCkhd3+Fcz1NJg3UBYg5aeOo9Tm
         vVJfvpmco/i+W9Z/4qD1zlzKasNjrKFO5/Ho1uvF8kOY5UK6dhzqHE4cS7+V1M0dangv
         rVAfV2UegDXDzUcSB0oZhMswVkxyoHUZWqiANMarBjI4GS1rtAQUam4bqNJQTNMexDIb
         nU3dVhU/T2yurplUf7I30QZKtvs1WwsfVbJb7FR+dt4/8O55yYG2FkuRDk873NvXmwza
         NtuA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=QiD1TwL/Id//xaqpbzs1lfvzt5WvDuUNyjDuGVpOVM8=;
        b=pDlk09BtIKTwANKUOPbT8JjXrhrQdVqTH8blakmJl8/XHDe/CUhjlGweVOCWgoF3dG
         ES4JBkxrPovC20eWluUPTFCmH1f9jgqNOLj6XkwK6YuEwWP0alugFu9J+3ap2mkH9Bjk
         Wh4NeRUsmH1q/tF3r6U8MALsCfuQvHILNI2NASpwfcZWiW+MRgQpDHMBV1Rb8oaeFQw9
         gGVZqxpFUosGcPVXf/aeVgjgZ7MzeBbFECfgg9tOGsBwpy8BN9PlS1rmU5JYoCPZg8Ul
         3uPmlQtEnUuprV/giTvZs1kQsqK5KWe9eaDTvgoNYFDlijvNw7gA4b7u6lzNd7rPBXWP
         F56g==
X-Gm-Message-State: APjAAAXlzDyH+YUPppCBmRqpxeEoVgqLsuXL3K7wvv7j5cAM96Az32QF
	MunyRiPJtBp0rZ2dVTPiQ0aUaIKX6gmyUdr88kvxZQ==
X-Google-Smtp-Source: APXvYqy09fzh96BWcQzuCXWwESDoCG5MbuNp+4Sq/95dcElSvTDxaCmjYIch+D1tDPc4Btkhhy46Glw06rUTj79kprY=
X-Received: by 2002:aa7:c40c:: with SMTP id j12mr10481211edq.80.1567785630260;
 Fri, 06 Sep 2019 09:00:30 -0700 (PDT)
MIME-Version: 1.0
References: <20190821183204.23576-1-pasha.tatashin@soleen.com>
 <20190821183204.23576-7-pasha.tatashin@soleen.com> <bcc3f71f-97d2-dff4-c55a-4798c6e2bede@arm.com>
In-Reply-To: <bcc3f71f-97d2-dff4-c55a-4798c6e2bede@arm.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Fri, 6 Sep 2019 12:00:19 -0400
Message-ID: <CA+CK2bCwRm_AQHzrJ8tdjp5k6Yj+32yRsvQsOoy7b44GTdd6wQ@mail.gmail.com>
Subject: Re: [PATCH v3 06/17] arm64, hibernate: add trans_pgd public functions
To: James Morse <james.morse@arm.com>
Cc: James Morris <jmorris@namei.org>, Sasha Levin <sashal@kernel.org>, 
	"Eric W. Biederman" <ebiederm@xmission.com>, kexec mailing list <kexec@lists.infradead.org>, 
	LKML <linux-kernel@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>, 
	Catalin Marinas <catalin.marinas@arm.com>, will@kernel.org, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, Marc Zyngier <marc.zyngier@arm.com>, 
	Vladimir Murzin <vladimir.murzin@arm.com>, Matthias Brugger <matthias.bgg@gmail.com>, 
	Bhupesh Sharma <bhsharma@redhat.com>, linux-mm <linux-mm@kvack.org>, 
	Mark Rutland <mark.rutland@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 6, 2019 at 11:18 AM James Morse <james.morse@arm.com> wrote:
>
> Hi Pavel,
>
> On 21/08/2019 19:31, Pavel Tatashin wrote:
> > trans_pgd_create_copy() and trans_pgd_map_page() are going to be
> > the basis for public interface of new subsystem that handles page
>
> Please don't call this a subsystem. 'sound' and 'mm' are subsystems, this is just some
> shared code.

Sounds good: just could not find a better term to call trans_pgd_*. I
won't fix log commits.

>
> > tables for cases which are between kernels: kexec, and hibernate.
>
> Even though you've baked the get_safe_page() calls into trans_pgd_map_page()?

It is getting removed later. Just for a cleaner migration to new
place, get_safe_page() is included for now.

>
>
> > diff --git a/arch/arm64/kernel/hibernate.c b/arch/arm64/kernel/hibernate.c
> > index 750ecc7f2cbe..2e29d620b56c 100644
> > --- a/arch/arm64/kernel/hibernate.c
> > +++ b/arch/arm64/kernel/hibernate.c
> > @@ -182,39 +182,15 @@ int arch_hibernation_header_restore(void *addr)
>
> > +int trans_pgd_map_page(pgd_t *trans_pgd, void *page,
> > +                    unsigned long dst_addr,
> > +                    pgprot_t pgprot)
>
> If this thing is going to be exposed, its name should reflect that its creating a set of
> page tables, to map a single page.
>
> A function called 'map_page' with this prototype should 'obviously' map @page at @dst_addr
> in @trans_pgd using the provided @pgprot... but it doesn't.

Answered below...

>
> This is what 'create' was doing in the old name, if that wasn't obvious, its because
> naming things is hard!
> | trans_create_single_page_mapping()?
>
> (might be too verbose)
>
> I think this bites you in patch 8, where you 'generalise' this.

The new naming makes more sense to me. The old code had function named:

create_safe_exec_page()

It was doing four things: 1. creating the actual page via provided
allocator, 2. copying content from the provided page to new page, 3
creating a new page table. 4 mapping it to a new page table at
specified destination address

After, I generalize this the function the prototype looks like this:

int trans_pgd_map_page(struct trans_pgd_info *info, pgd_t *trans_pgd,
                                         void *page, unsigned long
dst_addr, pgprot_t pgprot)

The function only does the "4" from the old code: map the specified
page at dst_addr. The trans_pgd is already created. Of course, and
mapping function will have to allocate missing tables in the page
tables when necessary.

> > +     return 0;
> > +}
> > +
> > +/*
> > + * Copies length bytes, starting at src_start into an new page,
> > + * perform cache maintentance, then maps it at the specified address low
>
> Could you fix the spelling of maintenance as git thinks you've moved it?

I will.

Thank you,
Pasha

