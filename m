Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 398026B002C
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 18:20:33 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <372657c9-02c3-4a9d-a283-86e655db8916@default>
Date: Wed, 12 Oct 2011 15:20:19 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [Xen-devel] Re: RFC -- new zone type
References: <20110928180909.GA7007@labbmf-linux.qualcomm.comCAOFJiu1_HaboUMqtjowA2xKNmGviDE55GUV4OD1vN2hXUf4-kQ@mail.gmail.com>
 <c2d9add1-0095-4319-8936-db1b156559bf@default20111005165643.GE7007@labbmf-linux.qualcomm.com>
 <cc1256f9-4808-4d74-a321-6a3ec129cc05@default20111006230348.GF7007@labbmf-linux.qualcomm.com>
 <4d0a5da4-00de-40dd-8d75-8ed6e3d0831c@default>
 <4E8F2242.3030406@linux.vnet.ibm.com
 20111007171958.GG7007@labbmf-linux.qualcomm.com>
In-Reply-To: <20111007171958.GG7007@labbmf-linux.qualcomm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Larry Bassel <lbassel@codeaurora.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Xen-devel@lists.xensource.com

> From: Larry Bassel [mailto:lbassel@codeaurora.org]
>=20
> As this area must be very large and contiguous, I can't use kmalloc or si=
milar
> allocation APIs -- I imagine I'll carve it out early in boot with
> memblock_remove() -- luckily this area is of fixed size. If this memory
> were in ZONE_HIGHMEM, I'd just have to use kmap to get a temporary mappin=
g
> to use when the page is copied to or from "normal" system memory (or am
> I missing something here?). Whether this area is in highmem or not, I ima=
gine
> I'll need to write an allocator to allocate/free pages from the "dual-pur=
pose"
> memory when it is cleancache.

Yep.  It would also be very nice if you could allocate the
metadata (tmem data structures) from the same "dual-purpose"
memory as then all of the data structures can simply be discarded
when you need the memory for the "big-100MB-block" purpose.
Zeroing a single pointer would be enough to "free" all
data and metadata.

Sadly I don't think this will work when the dual-purpose memory
is in highmem... you will need to walk the metadata and
free it all up when you free the cleancache pages.
=20
> > I did write a patch a while back that allows xvmalloc to use highmem
> > pages in it's storage pool.  Although, from looking at the history of t=
his
> > conversation, you'd be writing a different backend for tmem and not usi=
ng
> > zcache anyway.
>=20
> We're going to want a backend which is (at least to a
> first approximation) a simplification of zcache
> -- no compression and no frontswap is needed.
> Possibly we'll start with zcache and remove things we don't need.

Agree that's your best bet.  Let us know how it goes, especially if
you eventually plan for the driver to be submitted upstream.

> > Currently the tmem code is in the zcache driver.  However, if there are
> > going to be other backends designed for it, we may need to move it into=
 its
> > own module so it can be shared.

I think the longterm home for tmem.c/tmem.h should be in the "lib"
subdirectory of the linux tree, but it will require another driver
or two to use it before the linux maintainers will consider that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
