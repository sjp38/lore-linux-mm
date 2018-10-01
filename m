Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id BC65A6B0003
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 03:24:29 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i76-v6so812890pfk.14
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 00:24:29 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id w17-v6si11690324plp.335.2018.10.01.00.24.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Oct 2018 00:24:28 -0700 (PDT)
Message-ID: <1538407463.3190.1.camel@intel.com>
Subject: Re: [RFC PATCH 01/11] nios2: update_mmu_cache clear the old entry
 from the TLB
From: Ley Foon Tan <ley.foon.tan@intel.com>
Date: Mon, 01 Oct 2018 23:24:23 +0800
In-Reply-To: <20180929113712.6dcfeeb3@roar.ozlabs.ibm.com>
References: <20180923150830.6096-1-npiggin@gmail.com>
	 <20180923150830.6096-2-npiggin@gmail.com>
	 <20180929113712.6dcfeeb3@roar.ozlabs.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Guenter Roeck <linux@roeck-us.net>, nios2-dev@lists.rocketboards.org, linux-mm@kvack.org

On Sat, 2018-09-29 at 11:37 +1000, Nicholas Piggin wrote:
> Hi,
>=20
> Did you get a chance to look at these?
>=20
> This first patch 1/11 solves the lockup problem that Guenter reported
> with my changes to core mm code. So I plan to resubmit my patches
> to Andrew's -mm tree with this patch to avoid nios2 breakage.
>=20
> Thanks,
> Nick

Do you have git repo that contains these patches? If not, can you send
them as attachment to my email?


Regards
Ley Foon
>=20
> On Mon, 24 Sep 2018 01:08:20 +1000
> Nicholas Piggin <npiggin@gmail.com> wrote:
>=20
> >=20
> > Fault paths like do_read_fault will install a Linux pte with the
> > young
> > bit clear. The CPU will fault again because the TLB has not been
> > updated, this time a valid pte exists so handle_pte_fault will just
> > set the young bit with ptep_set_access_flags, which flushes the
> > TLB.
> >=20
> > The TLB is flushed so the next attempt will go to the fast TLB
> > handler
> > which loads the TLB with the new Linux pte. The access then
> > proceeds.
> >=20
> > This design is fragile to depend on the young bit being clear after
> > the initial Linux fault. A proposed core mm change to immediately
> > set
> > the young bit upon such a fault, results in ptep_set_access_flags
> > not
> > flushing the TLB because it finds no change to the pte. The
> > spurious
> > fault fix path only flushes the TLB if the access was a store. If
> > it
> > was a load, then this results in an infinite loop of page faults.
> >=20
> > This change adds a TLB flush in update_mmu_cache, which removes
> > that
> > TLB entry upon the first fault. This will cause the fast TLB
> > handler
> > to load the new pte and avoid the Linux page fault entirely.
> >=20
> > Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
> > ---
> > =C2=A0arch/nios2/mm/cacheflush.c | 2 ++
> > =C2=A01 file changed, 2 insertions(+)
> >=20
> > diff --git a/arch/nios2/mm/cacheflush.c
> > b/arch/nios2/mm/cacheflush.c
> > index 506f6e1c86d5..d58e7e80dc0d 100644
> > --- a/arch/nios2/mm/cacheflush.c
> > +++ b/arch/nios2/mm/cacheflush.c
> > @@ -204,6 +204,8 @@ void update_mmu_cache(struct vm_area_struct
> > *vma,
> > =C2=A0	struct page *page;
> > =C2=A0	struct address_space *mapping;
> > =C2=A0
> > +	flush_tlb_page(vma, address);
> > +
> > =C2=A0	if (!pfn_valid(pfn))
> > =C2=A0		return;
> > =C2=A0
