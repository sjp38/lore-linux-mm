Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D55436B025F
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 16:36:18 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id w128so1056895pfd.3
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 13:36:18 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id u9si2224062pfi.142.2016.07.26.13.36.17
        for <linux-mm@kvack.org>;
        Tue, 26 Jul 2016 13:36:18 -0700 (PDT)
From: "Roberts, William C" <william.c.roberts@intel.com>
Subject: RE: [PATCH] [RFC] Introduce mmap randomization
Date: Tue, 26 Jul 2016 20:35:44 +0000
Message-ID: <476DC76E7D1DF2438D32BFADF679FC560125F3A8@ORSMSX103.amr.corp.intel.com>
References: <1469557631-5752-1-git-send-email-william.c.roberts@intel.com>
 <20160726192627.GB11776@node.shutemov.name>
 <476DC76E7D1DF2438D32BFADF679FC560125F23C@ORSMSX103.amr.corp.intel.com>
 <20160726202926.GC11776@node.shutemov.name>
In-Reply-To: <20160726202926.GC11776@node.shutemov.name>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>



> -----Original Message-----
> From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On
> Behalf Of Kirill A. Shutemov
> Sent: Tuesday, July 26, 2016 1:29 PM
> To: Roberts, William C <william.c.roberts@intel.com>
> Cc: linux-mm@kvack.org
> Subject: Re: [PATCH] [RFC] Introduce mmap randomization
>=20
> On Tue, Jul 26, 2016 at 07:57:45PM +0000, Roberts, William C wrote:
> >
> >
> > > -----Original Message-----
> > > From: Kirill A. Shutemov [mailto:kirill@shutemov.name]
> > > Sent: Tuesday, July 26, 2016 12:26 PM
> > > To: Roberts, William C <william.c.roberts@intel.com>
> > > Cc: linux-mm@kvack.org
> > > Subject: Re: [PATCH] [RFC] Introduce mmap randomization
> > >
> > > On Tue, Jul 26, 2016 at 11:27:11AM -0700, william.c.roberts@intel.com=
 wrote:
> > > > From: William Roberts <william.c.roberts@intel.com>
> > > >
> > > > This patch introduces the ability randomize mmap locations where
> > > > the address is not requested, for instance when ld is allocating
> > > > pages for shared libraries. It chooses to randomize based on the
> > > > current personality for ASLR.
> > > >
> > > > Currently, allocations are done sequentially within unmapped
> > > > address space gaps. This may happen top down or bottom up depending=
 on
> scheme.
> > > >
> > > > For instance these mmap calls produce contiguous mappings:
> > > > int size =3D getpagesize();
> > > > mmap(NULL, size, flags, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D
> > > 0x40026000
> > > > mmap(NULL, size, flags, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D
> > > 0x40027000
> > > >
> > > > Note no gap between.
> > > >
> > > > After patches:
> > > > int size =3D getpagesize();
> > > > mmap(NULL, size, flags, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D
> > > 0x400b4000
> > > > mmap(NULL, size, flags, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D
> > > 0x40055000
> > > >
> > > > Note gap between.
> > >
> > > And why is it good?
> >
> > Currently if you get an info leak and discover, say the address to
> > libX It's just a matter of adding/subtracting a fixed offset to find
> > libY. This will make rop a bit harder if you're trying to rop into a
> > different library than what was leaked.
> >
> > This also has a benefit outside of just libraries in that it
> > randomizes all the Mappings done via mmap from run to run. So you
> > don't get consistent, known offsets to things within the memory space.
> >
> > >
> > > > Using the test program mentioned here, that allocates fixed sized
> > > > blocks till exhaustion:
> > > > https://www.linux-mips.org/archives/linux-mips/2011-05/msg00252.ht
> > > > ml, no difference was noticed in the number of allocations. Most
> > > > varied from run to run, but were always within a few allocations
> > > > of one another between patched and un-patched runs.
> > > >
> > > > Performance Measurements:
> > > > Using strace with -T option and filtering for mmap on the program
> > > > ls shows a slowdown of approximate 3.7%
> > >
> > > NAK.
> > >
> > > It's just too costly. And no obvious benefits.
> >
> > Sorry I used to have the explanation in the message, a carless edit
> > removed it.
> >
> > The cost does suck, perhaps something like personality + KConfig option=
....
>=20
> Cost sucks even more than you've mentioned: you'll pay on every page faul=
t, as
> find_vma() would have more vmas in the tree and vmacache will not be that
> effective. That's something people spend a lot time to tune.

Yes that is very true. Perhaps randomizing in some other manner is more
Prudent, yet another mmap() flag?

>=20
> Taking this into account, I can't see any real-world application that wou=
ld opt-in
> for this security feature.

Dynamic linker?

>=20
> --
>  Kirill A. Shutemov
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in the body to
> majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
