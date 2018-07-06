Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6EABC6B0003
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 19:53:13 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id u11-v6so13731135oif.22
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 16:53:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m67-v6sor6573613oif.314.2018.07.06.16.53.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Jul 2018 16:53:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <152938831573.17797.15264540938029137916.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152938827880.17797.439879736804291936.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152938831573.17797.15264540938029137916.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 6 Jul 2018 16:53:11 -0700
Message-ID: <CAPcyv4hCZ6jJkB=BLfoEn6146k7FG32=3J8ussZDXmAScQJkAg@mail.gmail.com>
Subject: Re: [PATCH v3 7/8] mm, hmm: Mark hmm_devmem_{add, add_resource} EXPORT_SYMBOL_GPL
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, Christoph Hellwig <hch@lst.de>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Jun 18, 2018 at 11:05 PM, Dan Williams <dan.j.williams@intel.com> w=
rote:
> The routines hmm_devmem_add(), and hmm_devmem_add_resource() are
> now wrappers around the functionality provided by devm_memremap_pages() t=
o
> inject a dev_pagemap instance and hook page-idle events. The
> devm_memremap_pages() interface is base infrastructure for HMM which has
> more and deeper ties into the kernel memory management implementation
> than base ZONE_DEVICE.
>
> Originally, the HMM page structure creation routines copied the
> devm_memremap_pages() code and reused ZONE_DEVICE. A cleanup to unify
> the implementations was discussed during the initial review:
> http://lkml.iu.edu/hypermail/linux/kernel/1701.2/00812.html
>
> Given that devm_memremap_pages() is marked EXPORT_SYMBOL_GPL by its
> authors and the hmm_devmem_{add,add_resource} routines are simple
> wrappers around that base, mark these routines as EXPORT_SYMBOL_GPL as
> well.
>
> Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Currently OpenAFS is blocked from compiling with the 4.18 series due
to the current state of put_page() inadvertently pulling in GPL-only
symbols. This series, "PATCH v3 0/8] mm: Rework hmm to use
devm_memremap_pages and other fixes" corrects that situation and
corrects HMM's usage of EXPORT_SYMBOL_GPL.

If HMM wants to export functionality to out-of-tree proprietary
drivers it should do so without consuming GPL-only exports, or
consuming internal-only public functions in its exports.

In addition to duplicating devm_memremap_pages(), that should have
been EXPORT_SYMBOL_GPL from the beginning, it is also exporting /
consuming these GPL-only symbols via HMM's EXPORT_SYMBOL entry points.

    mmu_notifier_unregister_no_release
    percpu_ref
    region_intersects
    __class_create

Those entry points also consume / export functionality that is
currently not exported to any other driver.

    alloc_pages_vma
    walk_page_range

Andrew, please consider applying this v3 series to fix this up (let me
know if you need a resend).
