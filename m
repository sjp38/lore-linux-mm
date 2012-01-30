Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 774BC6B004D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 15:34:55 -0500 (EST)
Received: by dake40 with SMTP id e40so4900980dak.14
        for <linux-mm@kvack.org>; Mon, 30 Jan 2012 12:34:54 -0800 (PST)
Date: Mon, 30 Jan 2012 12:34:30 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH/RFC G-U-P experts] IB/umem: Modernize our get_user_pages()
 parameters
In-Reply-To: <CAL1RGDXqguZ2QKV=yjLXtk2n_Ag4Nf3CW+kF2BFQFR4ySTNaRA@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1201301217530.4505@eggly.anvils>
References: <1327557574-6125-1-git-send-email-roland@kernel.org> <alpine.LSU.2.00.1201261133230.1369@eggly.anvils> <CAG4TOxNEV2VY9wOE86p9RnKGqpruB32ci9Wq3yBt8O2zc7f05w@mail.gmail.com> <alpine.LSU.2.00.1201271458130.3402@eggly.anvils>
 <CAL1RGDXqguZ2QKV=yjLXtk2n_Ag4Nf3CW+kF2BFQFR4ySTNaRA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-318211294-1327955682=:4505"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roland Dreier <roland@kernel.org>
Cc: linux-rdma@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-318211294-1327955682=:4505
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Mon, 30 Jan 2012, Roland Dreier wrote:
> On Fri, Jan 27, 2012 at 6:19 PM, Hugh Dickins <hughd@google.com> wrote:
> >> > > This patch comes from me trying to do userspace RDMA on a memory
> >> > > region exported from a character driver and mapped with
> >> > >
> >> > > =A0 =A0 mmap(... PROT_READ, MAP_PRIVATE ...)
> >
> > Why MAP_PRIVATE? =A0There you are explicitly asking for COW: okay,
> > you wouldn't normally expect any COW while it's just PROT_READ, but
> > once you bring GUP into the picture, with use of write and force,
> > then you are just begging for COW with that MAP_PRIVATE. =A0Please
> > change it to MAP_SHARED - any reason why not?
>=20
> I have no idea of the history there... probably could be changed with
> no problems.
>=20
> However, get_user_pages has this comment:
>=20
>  * @force:=09whether to force write access even if user mapping is
>  *=09=09readonly. This will result in the page being COWed even
>  *=09=09in MAP_SHARED mappings. You do not want this.
>=20
> but I don't see where in the code FOLL_FORCE does COW
> for MAP_SHARED mappings.

It ends up being implemented by the conditionals do_wp_page().

> But on the OTOH I don't see
> why we set force in the first place.  Why wouldn't we respect
> the user's mapping permissions.
>=20
> > I feel you're trying to handle two very different cases (rdma into
> > user-supplied anonymous memory, and exporting driver memory to the
> > user) with the same set of args to get_user_pages(). =A0In fact, I
> > don't even see why you need get_user_pages() at all when exporting
> > driver memory to the user. =A0Ah, perhaps you don't, but you do want
> > your standard access method (which already involves GUP) not to
> > mess up when applied to such a mapping - is that it?
>=20
> Exactly.  Right now we have the libibverbs userspace API, which
> basically lets userspace create an abstract "memory region" (MR)
> that is then given to the RDMA hardware to do IO on.  Userspace does
>=20
>     mr =3D ibv_reg_mr(..., buf, size, access_flags);
>=20
> where access flags say whether we're going to let the hardware
> read and/or write the memory.
>=20
> Ideally userspace should not have to know where the memory
> underlying its "buf" came from or what type of mapping it is.
>=20
> Certainly there are still more unresolved issues around the case
> where userspace wants to map, say, part of a GPUs PCI memory
> (which won't have any underlying page structs at all), but I'm at
> least hoping we can come up with a way to handle both anonymous
> private maps (which will be COWed from the zero page when
> the memory is touched for writing) and shared mappings of kernel
> memory exported by a driver's mmap method.
>=20
>=20
> So I guess I'm left thinking that it seems at least plausible that
> what we want is a new FOLL_ flag for __get_user_pages() that triggers
> COW exactly on the pages that userspace might trigger COW on,
> and avoids COW otherwise -- ie do FOLL_WRITE exactly for the
> pages that have VM_WRITE in their mapping.

The hardest part about implementing that is deciding what snappy
name to give the FOLL_ flag.

And it's a comprehensible semantic which sounds good and plausible,
but I'm afraid we might be deceiving ourselves.

>=20
> I don't think we want to do the "force" semantics or deal with the
> VM_MAYWRITE possiblity -- the access we give the hardware on
> behalf of userspace should just match the access that userspace
> actually has.  It seems that if we don't try to get pages for writing
> when VM_WRITE isn't set, we don't need force anymore.

I suspect you never needed or wanted the weird force behaviour on
shared maywrite, but that you did need the force COW behaviour on
private currently-unwritable maywrite.  You (or your forebears)
defined that interface to use the force flag, I'm guessing it was
for a reason; now you want to change it not to use the force flag,
and it sounds good, but I'm afraid you'll discover down the line
what the force flag was for.

Can you, for example, enforce the permissions set up by the user?
I mean, if they do the ibv_reg_mr() on a private readonly area,
so __get_user_pages with the FOLL_APPROPRIATELY flag will fault
in ZERO_PAGEs, can you enforce that RDMA will never spray data
into those pages?

Hugh
--8323584-318211294-1327955682=:4505--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
