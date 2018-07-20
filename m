Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 43F5E6B0005
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 15:51:49 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id o16-v6so6577926pgv.21
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 12:51:49 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h66-v6si2616385pfa.238.2018.07.20.12.51.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 12:51:48 -0700 (PDT)
Date: Fri, 20 Jul 2018 12:51:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 0/8] mm: Rework hmm to use devm_memremap_pages and
 other fixes
Message-Id: <20180720125146.02db0f40b4edc716c6f080d2@linux-foundation.org>
In-Reply-To: <37267986-A987-4AD7-96CE-C1D2F116A4AC@sinenomine.net>
References: <37267986-A987-4AD7-96CE-C1D2F116A4AC@sinenomine.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Vitale <mvitale@sinenomine.net>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Dan Williams <dan.j.williams@intel.org>, Joe Gorse <jgorse@sinenomine.net>, "release-team@openafs.org" <release-team@openafs.org>, Jerome Glisse <jglisse@redhat.com>

On Fri, 20 Jul 2018 14:43:14 +0000 Mark Vitale <mvitale@sinenomine.net> wro=
te:

> On Jul 11, 2018, Dan Williams wrote:
> > Changes since v3 [1]:
> > * Collect Logan's reviewed-by on patch 3
> > * Collect John's and Joe's tested-by on patch 8
> > * Update the changelog for patch 1 and 7 to better explain the
> >   EXPORT_SYMBOL_GPL rationale.
> > * Update the changelog for patch 2 to clarify that it is a cleanup to
> >   make the following patch-3 fix easier
> >
> > [1]: https://lkml.org/lkml/2018/6/19/108
> >
> > ---
> >=20
> > Hi Andrew,
> >=20
> > As requested, here is a resend of the devm_memremap_pages() fixups.
> > Please consider for 4.18.
>=20
> What is the status of this patchset?  OpenAFS is unable to build on
> Linux 4.18 without the last patch in this set:
>=20
> 8/8  mm: Fix exports that inadvertently make put_page() EXPORT_SYMBOL_GPL
>=20
> Will this be merged soon to linux-next, and ultimately to a Linux 4.18 rc?
>=20

Problem is, that patch is eighth in a series which we're waiting for
Jerome to review and the changelog starts with "Now that all producers
of dev_pagemap instances in the kernel are properly converted to
EXPORT_SYMBOL_GPL...".

Is it in fact a standalone patch?  Not sure.  I'll see what the build
system has to say about that.

And it will need a new changelog.  Such as



From: Dan Williams <dan.j.williams@intel.com>
Subject: mm: fix exports that inadvertently make put_page() EXPORT_SYMBOL_G=
PL

e76384884344 ("mm: introduce MEMORY_DEVICE_FS_DAX and
CONFIG_DEV_PAGEMAP_OPS") added two EXPORT_SYMBOL_GPL() symbols, but these
symbols are required by the inlined put_page(), thus accidentally making
put_page() a GPL export only.  This breaks OpenAFS (at least).

Mark them EXPORT_SYMBOL() instead.

Link: http://lkml.kernel.org/r/153128611970.2928.11310692420711601254.stgit=
@dwillia2-desk3.amr.corp.intel.com
Fixes: e76384884344 ("mm: introduce MEMORY_DEVICE_FS_DAX and CONFIG_DEV_PAG=
EMAP_OPS")
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
Reported-by: Joe Gorse <jhgorse@gmail.com>
Reported-by: John Hubbard <jhubbard@nvidia.com>
Tested-by: Joe Gorse <jhgorse@gmail.com>
Tested-by: John Hubbard <jhubbard@nvidia.com>
Cc: J=E9r=F4me Glisse <jglisse@redhat.com>
Cc: Mark Vitale <mvitale@sinenomine.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 kernel/memremap.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN kernel/memremap.c~mm-fix-exports-that-inadvertently-make-put_page=
-export_symbol_gpl kernel/memremap.c
--- a/kernel/memremap.c~mm-fix-exports-that-inadvertently-make-put_page-exp=
ort_symbol_gpl
+++ a/kernel/memremap.c
@@ -321,7 +321,7 @@ EXPORT_SYMBOL_GPL(get_dev_pagemap);
=20
 #ifdef CONFIG_DEV_PAGEMAP_OPS
 DEFINE_STATIC_KEY_FALSE(devmap_managed_key);
-EXPORT_SYMBOL_GPL(devmap_managed_key);
+EXPORT_SYMBOL(devmap_managed_key);
 static atomic_t devmap_enable;
=20
 /*
@@ -362,5 +362,5 @@ void __put_devmap_managed_page(struct pa
 	} else if (!count)
 		__put_page(page);
 }
-EXPORT_SYMBOL_GPL(__put_devmap_managed_page);
+EXPORT_SYMBOL(__put_devmap_managed_page);
 #endif /* CONFIG_DEV_PAGEMAP_OPS */
_
