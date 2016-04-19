Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D79786B007E
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 06:34:24 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id fg3so24566640obb.3
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 03:34:24 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id f18si3688152igt.62.2016.04.19.03.34.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Apr 2016 03:34:24 -0700 (PDT)
From: Frank Mehnert <frank.mehnert@oracle.com>
Subject: Re: Re: Re: Re: PG_reserved and compound pages
Date: Tue, 19 Apr 2016 12:34:09 +0200
Message-ID: <23955157.iZGXo4h7Qs@noys2>
In-Reply-To: <20160407152234.GE32755@dhcp22.suse.cz>
References: <4482994.u2S3pScRyb@noys2> <20567553.kUaGmfXpqH@noys2> <20160407152234.GE32755@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Michal,

On Thursday 07 April 2016 17:22:35 Michal Hocko wrote:
> On Thu 07-04-16 15:45:02, Frank Mehnert wrote:
> > On Wednesday 06 April 2016 17:33:43 Michal Hocko wrote:
> [...]
>=20
> > > Do you map your pages to the userspace? If yes then vma with VM_I=
O or
> > > VM_PFNMAP should keep any attempt away from those pages.
> >=20
> > Yes, such memory objects are also mapped to userland. Do you think =
that
> > VM_IO or VM_PFNMAP would guard against NUMA page migration?
>=20
> Both auto numa and manual numa migration checks vma_migratable and th=
at
> excludes both VM flags.
>=20
> > Because when
> > NUMA page migration was introduced (I believe with Linux 3.8) I tes=
ted
> > both flags and saw that they didn't prevent the migration on such V=
M
> > areas. Maybe this changed in the meantime, do you have more informa=
tion
> > about that?
>=20
> I haven't checked the history much but vma_migratable should be there=

> for quite some time. Maybe it wasn't used in the past. Dunno

I did some further tests and indeed, with Linux 3.8 ... Linux 3.12 I wa=
s
able to reproduce NUMA page faults while with Linux 3.14 (3.13 didn't r=
un
for some reason on my hardware) I'm no longer able to reproduce NUMA pa=
ge
faults. The important point is that with Linux 3.8, all pages are unmap=
ped
from time to time and in the page fault handler a decision is made if t=
he
page should be migrated to another NUMA node or not. So even if
vma_migratable() returns FALSE it wouldn't help us as the page has alre=
ady
faulted.

But as I said, the behaviour with Linux >=3D 3.14 is different which he=
lps
us a lot!

> > The drawback of at least VM_IO is that such memory is not part of a=
 core
> > dump.
>=20
> that seems to be correct as per vma_dump_size
>=20
> > Actually currently we use vm_insert_page() for userland mapping
> > and mark the VM areas as
> >=20
> >   VM_DONTEXPAND | VM_DONTDUMP
>=20
> but that means that it won't end up in the dump either. Or am I missi=
ng
> your point.

I guess you are right and we probably don't get these pages into core d=
umps
either. We can live with that.

Thank you for your suggestions and explanations, it was very helpful!

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
