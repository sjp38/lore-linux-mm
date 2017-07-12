Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 01CC66B052A
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 01:50:28 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 123so14983636pgj.4
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 22:50:27 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id r3si1220856plb.108.2017.07.11.22.50.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 22:50:26 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id y129so1730059pgy.3
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 22:50:26 -0700 (PDT)
Date: Wed, 12 Jul 2017 15:50:15 +1000
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [PATCH 2/5] mm/device-public-memory: device memory cache
 coherent with CPU v2
Message-ID: <20170712155015.2b77f958@firefly.ozlabs.ibm.com>
In-Reply-To: <20170711145744.GA5347@redhat.com>
References: <20170703211415.11283-1-jglisse@redhat.com>
	<20170703211415.11283-3-jglisse@redhat.com>
	<20170711141215.4fd1a972@firefly.ozlabs.ibm.com>
	<20170711145744.GA5347@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Balbir Singh <balbirs@au1.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Tue, 11 Jul 2017 10:57:44 -0400
Jerome Glisse <jglisse@redhat.com> wrote:

> On Tue, Jul 11, 2017 at 02:12:15PM +1000, Balbir Singh wrote:
> > On Mon,  3 Jul 2017 17:14:12 -0400
> > J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com> wrote:
> >  =20
> > > Platform with advance system bus (like CAPI or CCIX) allow device
> > > memory to be accessible from CPU in a cache coherent fashion. Add
> > > a new type of ZONE_DEVICE to represent such memory. The use case
> > > are the same as for the un-addressable device memory but without
> > > all the corners cases.
> > > =20
> >=20
> > Looks good overall, some comments inline.
> >   =20
>=20
> [...]
>=20
> > >  /*
> > > @@ -92,6 +100,8 @@ enum memory_type {
> > >   * The page_free() callback is called once the page refcount reaches=
 1
> > >   * (ZONE_DEVICE pages never reach 0 refcount unless there is a refco=
unt bug.
> > >   * This allows the device driver to implement its own memory managem=
ent.)
> > > + *
> > > + * For MEMORY_DEVICE_CACHE_COHERENT only the page_free() callback ma=
tter. =20
> >=20
> > Correct, but I wonder if we should in the long term allow for minor fau=
lts
> > (due to coherency) via this interface? =20
>=20
> This is something we can explore latter on.
>=20
> [...]
>=20

Agreed

> > > diff --git a/kernel/memremap.c b/kernel/memremap.c
> > > index e82456c39a6a..da74775f2247 100644
> > > --- a/kernel/memremap.c
> > > +++ b/kernel/memremap.c
> > > @@ -466,7 +466,7 @@ struct vmem_altmap *to_vmem_altmap(unsigned long =
memmap_start)
> > > =20
> > > =20
> > >  #ifdef CONFIG_DEVICE_PRIVATE =20
> >=20
> > Does the #ifdef above need to go as well? =20
>=20
> Good catch i should make that conditional on DEVICE_PUBLIC or whatever
> the name endup to be. I will make sure i test without DEVICE_PRIVATE
> config before posting again.
>=20
> [...]
>=20

I've been testing with this off, I should have sent you a patch, but
I thought I'd also update in the review.

> > > @@ -2541,11 +2551,21 @@ static void migrate_vma_insert_page(struct mi=
grate_vma *migrate,
> > >  	 */
> > >  	__SetPageUptodate(page);
> > > =20
> > > -	if (is_zone_device_page(page) && is_device_private_page(page)) {
> > > -		swp_entry_t swp_entry;
> > > +	if (is_zone_device_page(page)) {
> > > +		if (is_device_private_page(page)) {
> > > +			swp_entry_t swp_entry;
> > > =20
> > > -		swp_entry =3D make_device_private_entry(page, vma->vm_flags & VM_W=
RITE);
> > > -		entry =3D swp_entry_to_pte(swp_entry);
> > > +			swp_entry =3D make_device_private_entry(page, vma->vm_flags & VM_=
WRITE);
> > > +			entry =3D swp_entry_to_pte(swp_entry);
> > > +		}
> > > +#if IS_ENABLED(CONFIG_DEVICE_PUBLIC) =20
> >=20
> > Do we need this #if check? is_device_public_page(page)
> > will return false if the config is disabled =20
>=20
> pte_mkdevmap() is not define if ZONE_DEVICE is not enabled hence
> i had to protect this with #if/#endif to avoid build error.

pte_mkdevmap is always defined, could you please share the build
error.


Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
