Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 93AE46B007E
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 09:45:14 -0400 (EDT)
Received: by mail-ig0-f177.google.com with SMTP id f1so153700823igr.1
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 06:45:14 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id c96si7342157ioa.83.2016.04.07.06.45.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Apr 2016 06:45:13 -0700 (PDT)
From: Frank Mehnert <frank.mehnert@oracle.com>
Subject: Re: Re: Re: PG_reserved and compound pages
Date: Thu, 07 Apr 2016 15:45:02 +0200
Message-ID: <20567553.kUaGmfXpqH@noys2>
In-Reply-To: <20160406153343.GJ24272@dhcp22.suse.cz>
References: <4482994.u2S3pScRyb@noys2> <3877205.TjDYue2aah@noys2> <20160406153343.GJ24272@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wednesday 06 April 2016 17:33:43 Michal Hocko wrote:
> On Wed 06-04-16 17:12:43, Frank Mehnert wrote:
> > Hi Michal,
> >=20
> > On Wednesday 06 April 2016 17:02:06 Michal Hocko wrote:
> > > [CCing linux-mm mailing list]
> > >=20
> > > On Wed 06-04-16 13:28:37, Frank Mehnert wrote:
> > > > Hi,
> > > >=20
> > > > Linux 4.5 introduced additional checks to ensure that compound =
pages
> > > > are
> > > > never marked as reserved. In our code we use PG_reserved to ens=
ure
> > > > that
> > > > the kernel does never swap out such pages, e.g.
> > >=20
> > > Are you putting your pages on the LRU list? If not how they could=
 get
> > > swapped out?
> >=20
> > No, we do nothing like that. It was my understanding that at least =
with
> > older kernels it was possible that pages allocated with alloc_pages=
()
> > could be swapped out or otherwise manipulated, I might be wrong.
>=20
> I do not see anything like that. All the evictable pages should be on=

> a LRU.

OK. It seems to work if I just don't mark these pages as 'PG_reserved'.=

Need to do further tests.

> > For
> > instance, it's also necessary that the physical address of the page=

> > is known and that it does never change. I know, there might be prob=
lems
> > with automatic NUMA page migration but that's another story.
>=20
> Do you map your pages to the userspace? If yes then vma with VM_IO or=

> VM_PFNMAP should keep any attempt away from those pages.

Yes, such memory objects are also mapped to userland. Do you think that=

VM_IO or VM_PFNMAP would guard against NUMA page migration? Because whe=
n
NUMA page migration was introduced (I believe with Linux 3.8) I tested
both flags and saw that they didn't prevent the migration on such VM
areas. Maybe this changed in the meantime, do you have more information=

about that?

The drawback of at least VM_IO is that such memory is not part of a cor=
e
dump. Actually currently we use vm_insert_page() for userland mapping
and mark the VM areas as

  VM_DONTEXPAND | VM_DONTDUMP

for such areas. We used VM_RESERVED for pre-3.7 kernels (old doc says
``VM_RESERVED tells the memory management system not to attempt to swap=

out this VMA; it should be set in most device mappings.'' but this didn=
't
work for 3.7+ anymore.

Thanks,

Frank
--=20
Dr.-Ing. Frank Mehnert | Software Development Director, VirtualBox
ORACLE Deutschland B.V. & Co. KG | Werkstr. 24 | 71384 Weinstadt, Germa=
ny

ORACLE Deutschland B.V. & Co. KG
Hauptverwaltung: Riesstra=C3=9Fe 25, D-80992 M=C3=BCnchen
Registergericht: Amtsgericht M=C3=BCnchen, HRA 95603

Komplement=C3=A4rin: ORACLE Deutschland Verwaltung B.V.
Hertogswetering 163/167, 3543 AS Utrecht, Niederlande
Handelsregister der Handelskammer Midden-Niederlande, Nr. 30143697
Gesch=C3=A4ftsf=C3=BChrer: Alexander van der Ven, Jan Schultheiss, Val =
Maher

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
