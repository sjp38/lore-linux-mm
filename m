Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id AB7FE6B02B4
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 22:59:21 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v9so733233pfk.5
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 19:59:21 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id 1si1359406plh.379.2017.06.14.19.59.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 19:59:20 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id s66so283984pfs.2
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 19:59:20 -0700 (PDT)
Date: Thu, 15 Jun 2017 12:59:09 +1000
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [HMM-CDM 5/5] mm/hmm: simplify kconfig and enable HMM and
 DEVICE_PUBLIC for ppc64
Message-ID: <20170615125909.2972e1da@firefly.ozlabs.ibm.com>
In-Reply-To: <20170615020709.GB4666@redhat.com>
References: <20170614201144.9306-1-jglisse@redhat.com>
	<20170614201144.9306-6-jglisse@redhat.com>
	<20170615114611.34e8f2a7@firefly.ozlabs.ibm.com>
	<20170615020709.GB4666@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <balbirs@au1.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Wed, 14 Jun 2017 22:07:09 -0400
Jerome Glisse <jglisse@redhat.com> wrote:

> On Thu, Jun 15, 2017 at 11:46:11AM +1000, Balbir Singh wrote:
> > On Wed, 14 Jun 2017 16:11:44 -0400
> > J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com> wrote:
> >  =20
> > > This just simplify kconfig and allow HMM and DEVICE_PUBLIC to be
> > > selected for ppc64 once ZONE_DEVICE is allowed on ppc64 (different
> > > patchset).
> > >=20
> > > Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> > > Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> > > Cc: Balbir Singh <balbirs@au1.ibm.com>
> > > Cc: Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>
> > > Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > > Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> > > ---
> > >  include/linux/hmm.h |  4 ++--
> > >  mm/Kconfig          | 27 ++++++---------------------
> > >  mm/hmm.c            |  4 ++--
> > >  3 files changed, 10 insertions(+), 25 deletions(-)
> > >=20
> > > diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> > > index f6713b2..720d18c 100644
> > > --- a/include/linux/hmm.h
> > > +++ b/include/linux/hmm.h
> > > @@ -327,7 +327,7 @@ int hmm_vma_fault(struct vm_area_struct *vma,
> > >  #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
> > > =20
> > > =20
> > > -#if IS_ENABLED(CONFIG_HMM_DEVMEM)
> > > +#if IS_ENABLED(CONFIG_DEVICE_PRIVATE) || IS_ENABLED(CONFIG_DEVICE_PU=
BLIC)
> > >  struct hmm_devmem;
> > > =20
> > >  struct page *hmm_vma_alloc_locked_page(struct vm_area_struct *vma,
> > > @@ -456,7 +456,7 @@ struct hmm_device {
> > >   */
> > >  struct hmm_device *hmm_device_new(void *drvdata);
> > >  void hmm_device_put(struct hmm_device *hmm_device);
> > > -#endif /* IS_ENABLED(CONFIG_HMM_DEVMEM) */
> > > +#endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
> > > =20
> > > =20
> > >  /* Below are for HMM internal use only! Not to be used by device dri=
ver! */
> > > diff --git a/mm/Kconfig b/mm/Kconfig
> > > index ad082b9..7de939a 100644
> > > --- a/mm/Kconfig
> > > +++ b/mm/Kconfig
> > > @@ -265,7 +265,7 @@ config ARCH_ENABLE_HUGEPAGE_MIGRATION
> > >  config ARCH_HAS_HMM
> > >  	bool
> > >  	default y
> > > -	depends on X86_64
> > > +	depends on X86_64 || PPC64 =20
> >=20
> > Ideally we want to make this (PPC64 && PPC_BOOK3S) =20
>=20
> BOOK3S really ? :)

Sorry what's wrong with that? I am not sure we want it for BOOK3E 64 bit
Or may be would just make ARCH_HAS_HMM a config set by the ARCH,
like ARCH_HAS_SET_MEMORY

>=20
> >  =20
> > >  	depends on ZONE_DEVICE
> > >  	depends on MMU && 64BIT
> > >  	depends on MEMORY_HOTPLUG
> > > @@ -277,7 +277,7 @@ config HMM
> > > =20
> > >  config HMM_MIRROR
> > >  	bool "HMM mirror CPU page table into a device page table"
> > > -	depends on ARCH_HAS_HMM
> > > +	depends on ARCH_HAS_HMM && X86_64 =20
> >=20
> > We would need HMM_MIRROR for the generation of hardware that does
> > not have CDM =20
>=20
> That would require could change to mirror code mostly ppc is missing
> something like pmd_index() iirc. So best to tackle that as separate
> patchset.
>=20

We do have pmd_index() and I think Reza's got the whole hmm to compile
on powerpc. I am OK tackling it later. Do you suspect there is a compile ti=
me
dependency? I got HMM_MIRROR to compile for me as well

> >  =20
> > >  	select MMU_NOTIFIER
> > >  	select HMM
> > >  	help
> > > @@ -287,15 +287,6 @@ config HMM_MIRROR
> > >  	  page tables (at PAGE_SIZE granularity), and must be able to recov=
er from
> > >  	  the resulting potential page faults.
> > > =20
> > > -config HMM_DEVMEM
> > > -	bool "HMM device memory helpers (to leverage ZONE_DEVICE)"
> > > -	depends on ARCH_HAS_HMM
> > > -	select HMM
> > > -	help
> > > -	  HMM devmem is a set of helper routines to leverage the ZONE_DEVICE
> > > -	  feature. This is just to avoid having device drivers to replicati=
ng a lot
> > > -	  of boiler plate code.  See Documentation/vm/hmm.txt.
> > > -
> > >  config PHYS_ADDR_T_64BIT
> > >  	def_bool 64BIT || ARCH_PHYS_ADDR_T_64BIT
> > > =20
> > > @@ -720,11 +711,8 @@ config ZONE_DEVICE
> > > =20
> > >  config DEVICE_PRIVATE
> > >  	bool "Unaddressable device memory (GPU memory, ...)"
> > > -	depends on X86_64
> > > -	depends on ZONE_DEVICE
> > > -	depends on MEMORY_HOTPLUG
> > > -	depends on MEMORY_HOTREMOVE
> > > -	depends on SPARSEMEM_VMEMMAP
> > > +	depends on ARCH_HAS_HMM && X86_64 =20
> >=20
> > Same as above
> >  =20
> > > +	select HMM
> > > =20
> > >  	help
> > >  	  Allows creation of struct pages to represent unaddressable device
> > > @@ -733,11 +721,8 @@ config DEVICE_PRIVATE
> > > =20
> > >  config DEVICE_PUBLIC
> > >  	bool "Unaddressable device memory (GPU memory, ...)" =20
> >=20
> > The unaddressable is a typo from above. =20
>=20
> Yup cut and paste thank for catching that.

Your welcome
Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
