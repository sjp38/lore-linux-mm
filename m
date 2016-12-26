Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 192246B0038
	for <linux-mm@kvack.org>; Mon, 26 Dec 2016 14:02:53 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id iq1so20802713wjb.1
        for <linux-mm@kvack.org>; Mon, 26 Dec 2016 11:02:53 -0800 (PST)
Received: from mx4-phx2.redhat.com (mx4-phx2.redhat.com. [209.132.183.25])
        by mx.google.com with ESMTPS id w3si39030117wjp.149.2016.12.26.11.02.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Dec 2016 11:02:51 -0800 (PST)
Date: Mon, 26 Dec 2016 14:02:46 -0500 (EST)
From: Jerome Glisse <jglisse@redhat.com>
Message-ID: <897363324.7325313.1482778965996.JavaMail.zimbra@redhat.com>
In-Reply-To: <5860DEE7.5040505@linux.vnet.ibm.com>
References: <1481215184-18551-1-git-send-email-jglisse@redhat.com> <1481215184-18551-6-git-send-email-jglisse@redhat.com> <be2861b4-d830-fbd7-e9eb-ebc8e4d913a2@intel.com> <152004793.3187283.1481215199204.JavaMail.zimbra@redhat.com> <7df66ace-ef29-c76b-d61c-88263a61c6d0@intel.com> <2093258630.3273244.1481229443563.JavaMail.zimbra@redhat.com> <5860DEE7.5040505@linux.vnet.ibm.com>
Subject: Re: [HMM v14 05/16] mm/ZONE_DEVICE/unaddressable: add support for
 un-addressable device memory
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Dave Hansen <dave.hansen@intel.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

> On 12/09/2016 02:07 AM, Jerome Glisse wrote:
> >> On 12/08/2016 08:39 AM, Jerome Glisse wrote:
> >>>> > >> On 12/08/2016 08:39 AM, J=C3=A9r=C3=B4me Glisse wrote:
> >>>>>>> > >>> > > Architecture that wish to support un-addressable device
> >>>>>>> > >>> > > memory should
> >>>>>>> > >>> > > make
> >>>>>>> > >>> > > sure to never populate the kernel linar mapping for the
> >>>>>>> > >>> > > physical
> >>>>>>> > >>> > > range.
> >>>>> > >> >=20
> >>>>> > >> > Does the platform somehow provide a range of physical addres=
ses
> >>>>> > >> > for this
> >>>>> > >> > unaddressable area?  How do we know no memory will be hot-ad=
ded
> >>>>> > >> > in a
> >>>>> > >> > range we're using for unaddressable device memory, for insta=
nce?
> >>> > > That's what one of the big issue. No platform does not reserve an=
y
> >>> > > range so
> >>> > > there is a possibility that some memory get hotpluged and assign =
this
> >>> > > range.
> >>> > >=20
> >>> > > I pushed the range decision to higher level (ie it is the device
> >>> > > driver
> >>> > > that
> >>> > > pick one) so right now for device driver using HMM (NVidia close
> >>> > > driver as
> >>> > > we don't have nouveau ready for that yet) it goes from the highes=
t
> >>> > > physical
> >>> > > address and scan down until finding an empty range big enough.
> >> >=20
> >> > I don't think you should be stealing physical address space for thin=
gs
> >> > that don't and can't have physical addresses.  Delegating this to
> >> > individual device drivers and hoping that they all get it right seem=
s
> >> > like a recipe for disaster.
> > Well i expected device driver to use hmm_devmem_add() which does not ta=
ke
> > physical address but use the above logic to pick one.
> >=20
> >> >=20
> >> > Maybe worth adding to the changelog:
> >> >=20
> >> > =09This feature potentially breaks memory hotplug unless every
> >> > =09driver using it magically predicts the future addresses of
> >> > =09where memory will be hotplugged.
> > I will add debug printk to memory hotplug in case it fails because of s=
ome
> > un-addressable resource. If you really dislike memory hotplug being bro=
ken
> > then i can go down the way of allowing to hotplug memory above the max
> > physical memory limit. This require more changes but i believe this is
> > doable for some of the memory model (sparsemem and sparsemem extreme).
>=20
> Did not get that. Hotplug memory request will come within the max physica=
l
> memory limit as they are real RAM. The address range also would have been
> specified. How it can be added beyond the physical limit irrespective of
> which we memory model we use.
>=20

Maybe what you do not know is that on x86 we do not have resource reserve b=
y the
patform for the device memory (the PCIE bar never cover the whole memory so=
 this
range can not be use).

Right now i pick random unuse physical address range for device memory and =
thus
real memory might later be hotplug just inside the range i took and hotplug=
 will
fail because i already registered a resource for my device memory. This is =
an
x86 platform limitation.

Now if i bump the maximum physical memory by one bit than i can hotplug dev=
ice
memory inside that extra bit range and be sure that i will never have any r=
eal
memory conflict (as i am above the architectural limit).

Allowing to bump the maximum physical memory have implication and i can not=
 just
bump MAX_PHYSMEM_BITS as it will have repercusion that i don't want. Now in=
 some
memory model i can allow hotplug to happen above the MAX_PHYSMEM_BITS witho=
ut
having to change MAX_PHYSMEM_BITS and allowing page_to_pfn() and pfn_to_pag=
e()
to work above MAX_PHYSMEM_BITS again without changing it.

Memory model like SPARSEMEM_VMEMMAP are problematic as i would need to chan=
ge the
kernel virtual memory map for the architecture and it is not something i wa=
nt to
do.

In the meantime people using HMM are "~happy~" enough with memory hotplug f=
ailing.

Cheers,
J=C3=A9r=C3=B4me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
