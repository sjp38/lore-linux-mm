Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1E0BF6B0003
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 16:36:01 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id a80-v6so6030943itd.6
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 13:36:01 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q15-v6sor13426730ioi.4.2018.10.31.13.35.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Oct 2018 13:35:59 -0700 (PDT)
MIME-Version: 1.0
References: <9cf5c075-c83f-0915-99ef-b2aa59eca685@arm.com> <20181031190047.GA5148@redhat.com>
In-Reply-To: <20181031190047.GA5148@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 31 Oct 2018 13:35:47 -0700
Message-ID: <CAA9_cmfA9GS+1M1aSyv1ty5jKY3iho3CERhnRAruWJW3PfmpgA@mail.gmail.com>
Subject: Re: __HAVE_ARCH_PTE_DEVMAP - bug or intended behaviour?
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: robin.murphy@arm.com, linux-mm <linux-mm@kvack.org>

On Wed, Oct 31, 2018 at 12:00 PM Jerome Glisse <jglisse@redhat.com> wrote:
>
> On Wed, Oct 31, 2018 at 05:08:23PM +0000, Robin Murphy wrote:
> > Hi mm folks,
> >
> > I'm looking at ZONE_DEVICE support for arm64, and trying to make sense of a
> > build failure has led me down the rabbit hole of pfn_t.h, and specifically
> > __HAVE_ARCH_PTE_DEVMAP in this first instance.
> >
> > The failure itself is a link error in remove_migration_pte() due to a
> > missing definition of pte_mkdevmap(), but I'm a little confused at the fact
> > that it's explicitly declared without a definition, as if that breakage is
> > deliberate.
> >
> > So, is the !__HAVE_ARCH_PTE_DEVMAP case actually expected to work? If not,
> > then it seems to me that the relevant code could just be gated by
> > CONFIG_ZONE_DEVICE directly to remove the confusion. If it is, though, then
> > what should the generic definitions of p??_mkdevmap() be? I guess either way
> > I still need to figure out the implications of _PAGE_DEVMAP at the arch end
> > and whether/how arm64 should implement it, but given this initial hurdle
> > it's not clear exactly where to go next.
>
> AFAIR you can get ZONE_DEVICE without PTE_DEVMAP, PTE_DEVMAP is an
> optimization for pte_devmap() test ie being able to only have to
> look at pte value to determine if it is a pte pointing to a ZONE_DEVICE
> page versus needing to lookup the struct page.

No, it's not an optimization it's required for get_user_pages(). The
gup path uses the PTE_DEVMAP flag to determine that it needs to first
pin a device hosting the pfn (get_dev_pagemap()), before pinning any
associated pages. This allows device teardown operations to coordinate
with in-flight gup requests.

> As all architecture so far all have PTE_DEVMAP it might very well
> be that the !_HAVE_ARCH_PTE_DEVMAP case is broken (either from the
> start or because of changes made since it was added). It kind of
> looks broken at least when i glance at it now (ie the default
> pte_devmap() should lookup struct page and check if it is a ZONE
> DEVICE page).

That's the wrong way round because the 'struct page' object could be
freed at any time if you don't have a dev_pagemap() reference. So,
ZONE_DEVICE requires P??_DEVMAP.

> So your life will be easier if you can do __HAVE_ARCH_PTE_DEVMAP
> as you will not need to debug the !__HAVE_ARCH_PTE_DEVMAP case.

Per above, no.
