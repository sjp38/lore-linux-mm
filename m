Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0664A6B0260
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 12:10:34 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id b1so6515806pgc.5
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:10:33 -0800 (PST)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0072.outbound.protection.outlook.com. [104.47.41.72])
        by mx.google.com with ESMTPS id w5si8585707pfl.121.2016.12.16.09.10.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 16 Dec 2016 09:10:33 -0800 (PST)
Date: Fri, 16 Dec 2016 18:10:16 +0100
From: Robert Richter <robert.richter@cavium.com>
Subject: Re: [PATCH 2/2] arm64: mm: enable CONFIG_HOLES_IN_ZONE for NUMA
Message-ID: <20161216170947.GD4930@rric.localdomain>
References: <1481706707-6211-1-git-send-email-ard.biesheuvel@linaro.org>
 <1481706707-6211-3-git-send-email-ard.biesheuvel@linaro.org>
 <20161215153930.GA8111@rric.localdomain>
 <CAKv+Gu8K+mokbjzM8EpTJoCp3XAKK1_Doq1Zx=A2CCWTT6FbYg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CAKv+Gu8K+mokbjzM8EpTJoCp3XAKK1_Doq1Zx=A2CCWTT6FbYg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Will Deacon <will.deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Catalin Marinas <catalin.marinas@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Hanjun Guo <hanjun.guo@linaro.org>, Yisheng Xie <xieyisheng1@huawei.com>, James Morse <james.morse@arm.com>

On 15.12.16 16:07:26, Ard Biesheuvel wrote:
> On 15 December 2016 at 15:39, Robert Richter <robert.richter@cavium.com> wrote:
> > I was going to do some measurements but my kernel crashes now with a
> > page fault in efi_rtc_probe():
> >
> > [   21.663393] Unable to handle kernel paging request at virtual address 20251000
> > [   21.663396] pgd = ffff000009090000
> > [   21.663401] [20251000] *pgd=0000010ffff90003
> > [   21.663402] , *pud=0000010ffff90003
> > [   21.663404] , *pmd=0000000fdc030003
> > [   21.663405] , *pte=00e8832000250707
> >
> > The sparsemem config requires the whole section to be initialized.
> > Your patches do not address this.
> >
> 
> 96000047 is a third level translation fault, and the PTE address has
> RES0 bits set. I don't see how this is related to sparsemem, could you
> explain?

When initializing the whole section it works. Maybe it uncovers
another bug. Did not yet start debugging this.

> 
> > On 14.12.16 09:11:47, Ard Biesheuvel wrote:
> >> +config HOLES_IN_ZONE
> >> +     def_bool y
> >> +     depends on NUMA
> >
> > This enables pfn_valid_within() for arm64 and causes the check for
> > each page of a section. The arm64 implementation of pfn_valid() is
> > already expensive (traversing memblock areas). Now, this is increased
> > by a factor of 2^18 for 4k page size (16384 for 64k). We need to
> > initialize the whole section to avoid that.
> >
> 
> I know that. But if you want something for -stable, we should have
> something that is correct first, and only then care about the
> performance hit (if there is one)

I would prefer to check for a performance penalty *before* we put it
into stable. There is nor risk at all with the patch I am proposing.
See: https://lkml.org/lkml/2016/12/16/412

-Robert

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
