Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id EBDCE6B0261
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 15:37:29 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id he10so59324885wjc.6
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 12:37:29 -0800 (PST)
Received: from mx4-phx2.redhat.com (mx4-phx2.redhat.com. [209.132.183.25])
        by mx.google.com with ESMTPS id n64si14737584wmn.101.2016.12.08.12.37.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Dec 2016 12:37:27 -0800 (PST)
Date: Thu, 8 Dec 2016 15:37:23 -0500 (EST)
From: Jerome Glisse <jglisse@redhat.com>
Message-ID: <2093258630.3273244.1481229443563.JavaMail.zimbra@redhat.com>
In-Reply-To: <7df66ace-ef29-c76b-d61c-88263a61c6d0@intel.com>
References: <1481215184-18551-1-git-send-email-jglisse@redhat.com> <1481215184-18551-6-git-send-email-jglisse@redhat.com> <be2861b4-d830-fbd7-e9eb-ebc8e4d913a2@intel.com> <152004793.3187283.1481215199204.JavaMail.zimbra@redhat.com> <7df66ace-ef29-c76b-d61c-88263a61c6d0@intel.com>
Subject: Re: [HMM v14 05/16] mm/ZONE_DEVICE/unaddressable: add support for
 un-addressable device memory
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

> On 12/08/2016 08:39 AM, Jerome Glisse wrote:
> >> On 12/08/2016 08:39 AM, J=C3=A9r=C3=B4me Glisse wrote:
> >>> > > Architecture that wish to support un-addressable device memory sh=
ould
> >>> > > make
> >>> > > sure to never populate the kernel linar mapping for the physical
> >>> > > range.
> >> >=20
> >> > Does the platform somehow provide a range of physical addresses for =
this
> >> > unaddressable area?  How do we know no memory will be hot-added in a
> >> > range we're using for unaddressable device memory, for instance?
> > That's what one of the big issue. No platform does not reserve any rang=
e so
> > there is a possibility that some memory get hotpluged and assign this
> > range.
> >=20
> > I pushed the range decision to higher level (ie it is the device driver
> > that
> > pick one) so right now for device driver using HMM (NVidia close driver=
 as
> > we don't have nouveau ready for that yet) it goes from the highest phys=
ical
> > address and scan down until finding an empty range big enough.
>=20
> I don't think you should be stealing physical address space for things
> that don't and can't have physical addresses.  Delegating this to
> individual device drivers and hoping that they all get it right seems
> like a recipe for disaster.

Well i expected device driver to use hmm_devmem_add() which does not take
physical address but use the above logic to pick one.

>=20
> Maybe worth adding to the changelog:
>=20
> =09This feature potentially breaks memory hotplug unless every
> =09driver using it magically predicts the future addresses of
> =09where memory will be hotplugged.

I will add debug printk to memory hotplug in case it fails because of some
un-addressable resource. If you really dislike memory hotplug being broken
then i can go down the way of allowing to hotplug memory above the max
physical memory limit. This require more changes but i believe this is
doable for some of the memory model (sparsemem and sparsemem extreme).

>=20
> BTW, how many more of these "big issues" does this set have?  I didn't
> see any mention of this in the changelogs.
=20
I am not sure what to say here. If you don't use HMM ie no device that
hotplug it. Then there is no chance of having issue. If you have a device
that use it then someone might try to do something stupid (try to kmap
and access such un-addressable page for instance). So i am not sure where
to draw the line.

Cheers,
J=C3=A9r=C3=B4me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
