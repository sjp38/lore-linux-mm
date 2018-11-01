Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3CC8A6B0008
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 16:59:04 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id v4so14691471otb.0
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 13:59:04 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z24sor3797372otj.26.2018.11.01.13.59.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Nov 2018 13:59:02 -0700 (PDT)
MIME-Version: 1.0
References: <9cf5c075-c83f-0915-99ef-b2aa59eca685@arm.com> <CAPcyv4gZyDWYiQ8DHwei+FQRL22LGo3Sr6a-9VPESnuRJy7jtg@mail.gmail.com>
 <35bd3ed6-1a67-85a0-7b04-0b355660a950@arm.com>
In-Reply-To: <35bd3ed6-1a67-85a0-7b04-0b355660a950@arm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 1 Nov 2018 13:58:50 -0700
Message-ID: <CAPcyv4gWMRK9hPoZveLSChOLhsCPqD8_gJgu4EzFLtDedjBChg@mail.gmail.com>
Subject: Re: __HAVE_ARCH_PTE_DEVMAP - bug or intended behaviour?
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: Linux MM <linux-mm@kvack.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>

On Thu, Nov 1, 2018 at 1:10 PM Robin Murphy <robin.murphy@arm.com> wrote:
>
> On 31/10/2018 20:41, Dan Williams wrote:
> > On Wed, Oct 31, 2018 at 10:08 AM Robin Murphy <robin.murphy@arm.com> wrote:
> >>
> >> Hi mm folks,
> >>
> >> I'm looking at ZONE_DEVICE support for arm64, and trying to make sense
> >> of a build failure has led me down the rabbit hole of pfn_t.h, and
> >> specifically __HAVE_ARCH_PTE_DEVMAP in this first instance.
> >>
> >> The failure itself is a link error in remove_migration_pte() due to a
> >> missing definition of pte_mkdevmap(), but I'm a little confused at the
> >> fact that it's explicitly declared without a definition, as if that
> >> breakage is deliberate.
> >
> > It's deliberate, it's only there to allow mm/memory.c to compile. The
> > compiler can see that pfn_t_devmap(pfn) is always false in the
> > !__HAVE_ARCH_PTE_DEVMAP case and throws away the attempt to link to
> > pte_devmap().
> >
> > The summary is that an architecture needs to devote a free/software
> > pte bit for Linux to indicate "device pfns".
>
> Thanks for the explanation(s), that's been super helpful. So
> essentially, the WIP configuration I currently have
> (ARCH_HAS_ZONE_DEVICE=y but !__HAVE_ARCH_PTE_DEVMAP) is fundamentally
> incomplete, and even if I convince a ZONE_DEVICE=y config to build with
> the devmap stubs, it would end up going wrong in exciting ways at
> runtime - is that the gist of it?

Yes, exactly.

> If that is the case, then I might also
> have a go at streamlining some of the configs to make those dependencies
> more apparent.

Sounds good.
