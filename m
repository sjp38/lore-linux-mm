Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4901C43331
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 17:41:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0020206BB
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 17:41:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="KWbZvsNI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0020206BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FF406B0005; Fri,  6 Sep 2019 13:41:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2AEE16B0006; Fri,  6 Sep 2019 13:41:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C5B16B0007; Fri,  6 Sep 2019 13:41:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0243.hostedemail.com [216.40.44.243])
	by kanga.kvack.org (Postfix) with ESMTP id EE30D6B0005
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 13:41:30 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 98477440B
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 17:41:30 +0000 (UTC)
X-FDA: 75905212740.13.cat67_646d408bb2e07
X-HE-Tag: cat67_646d408bb2e07
X-Filterd-Recvd-Size: 5064
Received: from mail-ed1-f65.google.com (mail-ed1-f65.google.com [209.85.208.65])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 17:41:29 +0000 (UTC)
Received: by mail-ed1-f65.google.com with SMTP id f2so659448edw.3
        for <linux-mm@kvack.org>; Fri, 06 Sep 2019 10:41:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=VBkiR/7BisGtZVmNVXhHtJrfmofi1qU8Pxcjpjv/ZgU=;
        b=KWbZvsNIkISQq4DJ0Jn0+DC13xFv36DJ+INz1iCwsDURlinnxi/FqltluIcUdyKEH+
         rohLlAAcGa9S/ZYLvc1vTaR6e7aQaHawkNyzLp29w4f6Au1gxqx6ccQi15xWrUysZLko
         l0O4EcJcNb3Zxrza5Xu2Cdd0Q8c1MNJiep4Y23PuKjCm1JHlOUjUXO3rjxiUgpMuxdBZ
         195WYeYAEX+sfEiPtjph8YRPHJ5jQAWbkYH6/UE6sgH5I3Tkdk2sSbsvvqd+Xnpv0uvu
         1ilSBFkcIXgD0EgHuYTfM1YDM5ly+poGMtxFMSDOaOGhgSkdDDpWTmBO4MBPmbtsnmHo
         MKVg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=VBkiR/7BisGtZVmNVXhHtJrfmofi1qU8Pxcjpjv/ZgU=;
        b=CY5nb6rd4ru2ebo4RbRGGUceJhaoHpeEwCKkIO2gtQkQ6tP57yMrN6l5xQoV1cyJ67
         37HOHWStpoik82qbBQKk1LvbVDo5oc7FYc9kwSzsc5Qr5pYMWa++u7e6cpNk54/eNd1t
         xQuz8/ty5dYZr2605uZblISaVFJlSMgMBqMJyg+TBe1091sGBlhrt67aY1i/U7DSEcUu
         g0JMGBX7LXXEIo4Yh1JoL3L+F6P+brjamYdryVR0a9OT9aYQht9xWHTh+8u6Wln90/XW
         qnU8g0rn2WysvxKba93ZDxdztOwHIZFd4DQhMZxsIsfPePc6JOnPua438lkyYKBp3DnW
         Zoxg==
X-Gm-Message-State: APjAAAXVWAQ+Z7/8BbNq7zUaKCe7FXUrw57h4ABNaNXHzmOfp3Z/kjlK
	F7DPHmoHfdd9x3tdUqmwyjzN0f8FHGq8LqDqj9NQxA==
X-Google-Smtp-Source: APXvYqzdydAQq2XsQ/paSb9m4rgwscf0/CCdiPGGGSWL+1ARUwePukKygj3cKHXfmSeUdjAS/Egx8Zb0S9m9dpj+AVQ=
X-Received: by 2002:aa7:c40c:: with SMTP id j12mr11037477edq.80.1567791688713;
 Fri, 06 Sep 2019 10:41:28 -0700 (PDT)
MIME-Version: 1.0
References: <20190821183204.23576-1-pasha.tatashin@soleen.com>
 <20190821183204.23576-8-pasha.tatashin@soleen.com> <f1db863a-de57-2d1a-6bec-6020b2130964@arm.com>
In-Reply-To: <f1db863a-de57-2d1a-6bec-6020b2130964@arm.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Fri, 6 Sep 2019 13:41:17 -0400
Message-ID: <CA+CK2bDTVGm6pNRGQx7eAyEP6m0xr9X1No_=qgUOTDAoL9uigw@mail.gmail.com>
Subject: Re: [PATCH v3 07/17] arm64, hibernate: move page handling function to
 new trans_pgd.c
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
> > Now, that we abstracted the required functions move them to a new home.
> > Later, we will generalize these function in order to be useful outside
> > of hibernation.
>
> > diff --git a/arch/arm64/mm/trans_pgd.c b/arch/arm64/mm/trans_pgd.c
> > new file mode 100644
> > index 000000000000..00b62d8640c2
> > --- /dev/null
> > +++ b/arch/arm64/mm/trans_pgd.c
> > @@ -0,0 +1,211 @@
> > +// SPDX-License-Identifier: GPL-2.0
> > +
> > +/*
> > + * Copyright (c) 2019, Microsoft Corporation.
> > + * Pavel Tatashin <patatash@linux.microsoft.com>
>
> Hmmm, while line-count isn't a useful metric: this file contains 41% of the code that was
> in hibernate.c, but has stripped the substantial copyright-pedigree that the hibernate
> code had built up over the years.
> (counting lines identified by 'cloc' as code, not comments or blank)
>
> If you are copying or moving a non trivial quantity of code, you need to preserve the
> copyright. Something like 'Derived from the arm64 hibernate support which has:'....

I will do that.  The copyright thing was meant to appear in
"generalization" patch that comes later, where I unified most of the
code to be symmetric.
So, I will add it there, and also do the derived message that you suggested.

>
>
> > + */
> > +
> > +/*
> > + * Transitional tables are used during system transferring from one world to
> > + * another: such as during hibernate restore, and kexec reboots. During these
> > + * phases one cannot rely on page table not being overwritten.
>
> I think you need to mention that hibernate and kexec are rewriting memory, and may
> overwrite the live page tables, therefore ...

Will add, thank you.

Pasha

