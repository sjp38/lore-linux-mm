Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id BCE166B002C
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 15:40:29 -0500 (EST)
Received: by dadv6 with SMTP id v6so7596889dad.14
        for <linux-mm@kvack.org>; Tue, 07 Feb 2012 12:40:28 -0800 (PST)
Date: Tue, 7 Feb 2012 12:39:58 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH/RFC G-U-P experts] IB/umem: Modernize our get_user_pages()
 parameters
In-Reply-To: <CAL1RGDVSBb1DVsfvuz=ijRZX06crsqQfKoXWJ+6FO4xi3aYyTg@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1202071225250.2024@eggly.anvils>
References: <1327557574-6125-1-git-send-email-roland@kernel.org> <alpine.LSU.2.00.1201261133230.1369@eggly.anvils> <CAG4TOxNEV2VY9wOE86p9RnKGqpruB32ci9Wq3yBt8O2zc7f05w@mail.gmail.com> <alpine.LSU.2.00.1201271458130.3402@eggly.anvils>
 <CAL1RGDXqguZ2QKV=yjLXtk2n_Ag4Nf3CW+kF2BFQFR4ySTNaRA@mail.gmail.com> <alpine.LSU.2.00.1201301217530.4505@eggly.anvils> <CAL1RGDVSBb1DVsfvuz=ijRZX06crsqQfKoXWJ+6FO4xi3aYyTg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-1093247129-1328647211=:2024"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roland Dreier <roland@kernel.org>
Cc: linux-rdma@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-1093247129-1328647211=:2024
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Mon, 6 Feb 2012, Roland Dreier wrote:
> Sorry for the slow reply, I got caught in other business...

Negative problem!

>=20
> On Mon, Jan 30, 2012 at 12:34 PM, Hugh Dickins <hughd@google.com> wrote:
> > The hardest part about implementing that is deciding what snappy
> > name to give the FOLL_ flag.
>=20
> Yes... FOLL_SOFT_COW ?  FOLL_READONLY_COW ?
> (plus a good comment explaining it I guess)

I don't grok either of those - surely not READONLY_COW.

FOLL_PREPARE is the closest I've got.  I'd have said FOLL_TOUCH
if that weren't already taken.  FOLL_WRITE_IF_ABLE?

>=20
> >> I don't think we want to do the "force" semantics or deal with the
> >> VM_MAYWRITE possiblity -- the access we give the hardware on
> >> behalf of userspace should just match the access that userspace
> >> actually has. =A0It seems that if we don't try to get pages for writin=
g
> >> when VM_WRITE isn't set, we don't need force anymore.
> >
> > I suspect you never needed or wanted the weird force behaviour on
> > shared maywrite, but that you did need the force COW behaviour on
> > private currently-unwritable maywrite. =A0You (or your forebears)
> > defined that interface to use the force flag, I'm guessing it was
> > for a reason; now you want to change it not to use the force flag,
> > and it sounds good, but I'm afraid you'll discover down the line
> > what the force flag was for.
>=20
> Actually I think I understand why the original code passed !write
> as the force parameter.
>=20
> If the user is registering memory with read-only access, there are
> two common cases.  Possibly the underlying memory really has
> a read-only mapping, but probably more often it is just an ordinary
> buffer allocated in userspace with malloc() or the like.
>=20
> In the second case, it's quite likely we have a read/write mapping
> of anonymous pages.  We'll expose it read-only for RDMA but the
> userspace process will write data into the memory via ordinary CPU
> access.  However, if we do ibv_reg_mr() before initializing the memory
> it's quite possible that the mapping actually points to the zero page,
> waiting for a CPU write to trigger a COW.
>=20
> So in the second case, doing GUP without the write flag will leave
> the COW untriggered, and we'll end up mapping the zero page to
> the hardware, and RDMA won't read the data that userspace actually
> writes.  So (without GUP extension as we're discussing in this thread)
> we're forced to pass write=3D=3D1 to GUP, even if we expect hardware
> to only do reads.
>=20
> But if we pass write=3D=3D1, then GUP on the first case (mapping that
> is genuinely read-only) will fail, unless we pass force=3D=3D1 too.  But
> this should only succeed if we're going to only access the memory
> read-only, so we should set force to !writable-access-by-rdma.
>=20
> Which I think explains why the code is the way it is.  But clearly
> we could do better if we had a better way of telling GUP our real
> intentions -- ie the FOLL_READONLY_COW flag.

You've persuaded me.  Yes, you have been using force because that was
the only tool available at the time, to get close to the sensible
behaviour you are now asking for.

>=20
> > Can you, for example, enforce the permissions set up by the user?
> > I mean, if they do the ibv_reg_mr() on a private readonly area,
> > so __get_user_pages with the FOLL_APPROPRIATELY flag will fault
> > in ZERO_PAGEs, can you enforce that RDMA will never spray data
> > into those pages?
>=20
> Yes, the access flags passed into ibv_reg_mr() are enforced by
> the RDMA hardware, so if no write access is request, no write
> access is possible.

Okay, if you enforce the agreed permissions in hardware, that's fine.

>=20
> And presumably if we do GUP with write=3D=3D1, force=3D=3D0 that will
> fail on a read-only mapping?

That's right.

Hugh
--8323584-1093247129-1328647211=:2024--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
