Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3696B6B0007
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 20:34:20 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id y7-v6so11092380plt.17
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 17:34:20 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h66-v6si16992591pfa.238.2018.07.09.17.34.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 17:34:18 -0700 (PDT)
Date: Mon, 9 Jul 2018 17:34:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 7/8] mm, hmm: Mark hmm_devmem_{add, add_resource}
 EXPORT_SYMBOL_GPL
Message-Id: <20180709173417.171c0d75ac3fd55b45881d3f@linux-foundation.org>
In-Reply-To: <CAPcyv4hCZ6jJkB=BLfoEn6146k7FG32=3J8ussZDXmAScQJkAg@mail.gmail.com>
References: <152938827880.17797.439879736804291936.stgit@dwillia2-desk3.amr.corp.intel.com>
	<152938831573.17797.15264540938029137916.stgit@dwillia2-desk3.amr.corp.intel.com>
	<CAPcyv4hCZ6jJkB=BLfoEn6146k7FG32=3J8ussZDXmAScQJkAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, Christoph Hellwig <hch@lst.de>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, 6 Jul 2018 16:53:11 -0700 Dan Williams <dan.j.williams@intel.com> w=
rote:

> On Mon, Jun 18, 2018 at 11:05 PM, Dan Williams <dan.j.williams@intel.com>=
 wrote:
> > The routines hmm_devmem_add(), and hmm_devmem_add_resource() are
> > now wrappers around the functionality provided by devm_memremap_pages()=
 to
> > inject a dev_pagemap instance and hook page-idle events. The
> > devm_memremap_pages() interface is base infrastructure for HMM which has
> > more and deeper ties into the kernel memory management implementation
> > than base ZONE_DEVICE.
> >
> > Originally, the HMM page structure creation routines copied the
> > devm_memremap_pages() code and reused ZONE_DEVICE. A cleanup to unify
> > the implementations was discussed during the initial review:
> > http://lkml.iu.edu/hypermail/linux/kernel/1701.2/00812.html
> >
> > Given that devm_memremap_pages() is marked EXPORT_SYMBOL_GPL by its
> > authors and the hmm_devmem_{add,add_resource} routines are simple
> > wrappers around that base, mark these routines as EXPORT_SYMBOL_GPL as
> > well.
> >
> > Cc: "J=E9r=F4me Glisse" <jglisse@redhat.com>
> > Cc: Logan Gunthorpe <logang@deltatee.com>
> > Reviewed-by: Christoph Hellwig <hch@lst.de>
> > Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>=20
> Currently OpenAFS is blocked from compiling with the 4.18 series due
> to the current state of put_page() inadvertently pulling in GPL-only
> symbols. This series, "PATCH v3 0/8] mm: Rework hmm to use
> devm_memremap_pages and other fixes" corrects that situation and
> corrects HMM's usage of EXPORT_SYMBOL_GPL.
>=20
> If HMM wants to export functionality to out-of-tree proprietary
> drivers it should do so without consuming GPL-only exports, or
> consuming internal-only public functions in its exports.
>=20
> In addition to duplicating devm_memremap_pages(), that should have
> been EXPORT_SYMBOL_GPL from the beginning, it is also exporting /
> consuming these GPL-only symbols via HMM's EXPORT_SYMBOL entry points.
>=20
>     mmu_notifier_unregister_no_release
>     percpu_ref
>     region_intersects
>     __class_create
>=20
> Those entry points also consume / export functionality that is
> currently not exported to any other driver.
>=20
>     alloc_pages_vma
>     walk_page_range
>=20
> Andrew, please consider applying this v3 series to fix this up (let me
> know if you need a resend).

A resend would be good.  And include the above info in the changelog.

I can't say I'm terribly happy with the HMM situation.  I was under the
impression that a significant number of significant in-tree drivers
would be using HMM but I've heard nothing since, apart from ongoing
nouveau work, which will be perfectly happy with GPL-only exports.

So yes, we should revisit the licensing situation and, if only nouveau
will be using HMM we should revisit HMM's overall usefulness.
