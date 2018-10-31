Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4ACE36B0007
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 16:41:19 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id w126-v6so13003276oib.18
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 13:41:19 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r17sor9353129otb.187.2018.10.31.13.41.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Oct 2018 13:41:18 -0700 (PDT)
MIME-Version: 1.0
References: <9cf5c075-c83f-0915-99ef-b2aa59eca685@arm.com>
In-Reply-To: <9cf5c075-c83f-0915-99ef-b2aa59eca685@arm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 31 Oct 2018 13:41:06 -0700
Message-ID: <CAPcyv4gZyDWYiQ8DHwei+FQRL22LGo3Sr6a-9VPESnuRJy7jtg@mail.gmail.com>
Subject: Re: __HAVE_ARCH_PTE_DEVMAP - bug or intended behaviour?
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: Linux MM <linux-mm@kvack.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>

On Wed, Oct 31, 2018 at 10:08 AM Robin Murphy <robin.murphy@arm.com> wrote:
>
> Hi mm folks,
>
> I'm looking at ZONE_DEVICE support for arm64, and trying to make sense
> of a build failure has led me down the rabbit hole of pfn_t.h, and
> specifically __HAVE_ARCH_PTE_DEVMAP in this first instance.
>
> The failure itself is a link error in remove_migration_pte() due to a
> missing definition of pte_mkdevmap(), but I'm a little confused at the
> fact that it's explicitly declared without a definition, as if that
> breakage is deliberate.

It's deliberate, it's only there to allow mm/memory.c to compile. The
compiler can see that pfn_t_devmap(pfn) is always false in the
!__HAVE_ARCH_PTE_DEVMAP case and throws away the attempt to link to
pte_devmap().

The summary is that an architecture needs to devote a free/software
pte bit for Linux to indicate "device pfns".
