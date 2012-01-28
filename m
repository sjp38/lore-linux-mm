Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id E3C946B004D
	for <linux-mm@kvack.org>; Fri, 27 Jan 2012 21:19:27 -0500 (EST)
Received: by pbaa12 with SMTP id a12so2635444pba.14
        for <linux-mm@kvack.org>; Fri, 27 Jan 2012 18:19:27 -0800 (PST)
Date: Fri, 27 Jan 2012 18:19:07 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH/RFC G-U-P experts] IB/umem: Modernize our get_user_pages()
 parameters
In-Reply-To: <CAG4TOxNEV2VY9wOE86p9RnKGqpruB32ci9Wq3yBt8O2zc7f05w@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1201271458130.3402@eggly.anvils>
References: <1327557574-6125-1-git-send-email-roland@kernel.org> <alpine.LSU.2.00.1201261133230.1369@eggly.anvils> <CAG4TOxNEV2VY9wOE86p9RnKGqpruB32ci9Wq3yBt8O2zc7f05w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-2087791211-1327717154=:3402"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roland Dreier <roland@kernel.org>
Cc: linux-rdma@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-2087791211-1327717154=:3402
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Thu, 26 Jan 2012, Roland Dreier wrote:
>=20
> Thanks for the thoughtful answer...

But I should have paid more attention to reading what you had written.
In particular to:

> > > This patch comes from me trying to do userspace RDMA on a memory
> > > region exported from a character driver and mapped with
> > >=20
> > >     mmap(... PROT_READ, MAP_PRIVATE ...)

Why MAP_PRIVATE?  There you are explicitly asking for COW: okay,
you wouldn't normally expect any COW while it's just PROT_READ, but
once you bring GUP into the picture, with use of write and force,
then you are just begging for COW with that MAP_PRIVATE.  Please
change it to MAP_SHARED - any reason why not?

I feel you're trying to handle two very different cases (rdma into
user-supplied anonymous memory, and exporting driver memory to the
user) with the same set of args to get_user_pages().  In fact, I
don't even see why you need get_user_pages() at all when exporting
driver memory to the user.  Ah, perhaps you don't, but you do want
your standard access method (which already involves GUP) not to
mess up when applied to such a mapping - is that it?

>=20
> > I think this is largely about the ZERO_PAGE. =A0If you do a read fault
> > on an untouched anonymous area, it maps in the ZERO_PAGE, and will
> > only give you your own private zeroed page when there's a write fault
> > to touch it.
> >
> > I think your ib_umem_get() is making sure to give the process its own
> > private zeroed page: if the area is PROT_READ, MAP_PRIVATE, userspace
> > will not be wanting to write into it, but presumably it expects to see
> > data placed in that page by the underlying driver, and it would be very
> > bad news if the driver wrote its data into the ZERO_PAGE.
>=20
> I think we are actually OK.  If umem->writable =3D=3D 0, that is actually
> a promise by the driver/HW that they are not going to write to this
> memory.  Mapping ZERO_PAGE to the hardware is fine in this case,
> since the hardware will just read zeroes exactly as it should.

Right, I got your use of the write flag the wrong way round
(it represents the needs of the driver end, not of the user end),
but we arrive at much the same issue.

>=20
> One question is whether we're OK if userspace maps some
> anonymous memory with PROT_WRITE but doesn't touch it,
> and then tries to map it to the hardware read-only.  In that case
> we hit get_user_pages() with write =3D=3D 0.  If I understand the code
> correctly, we end up mapping ZERO_PAGE in do_anonymous_page().
>=20
> But then if userspace writes to this anonymous memory, a COW
> will be triggered and the hardware will be left holding a different
> page than the one that is mapped into userspace (ie the device
> won't read what userspace writes).  Kind of the inverse of the
> problem I hit.

Yes.

>=20
> I don't have a good understanding of what force =3D=3D 1 means -- I
> guess the question is what happens if userspace tells us to
> write to a read-only mapping that userspace could have mapped
> writable?

The force flag allows GUP to override the current protections of the vma:
by default, GUP refuses to write to an area which was not mapped PROT_WRITE=
,
and refuses to read from an area which is mapped PROT_NONE; but sometimes
we want it to go ahead despite those current protections - in your case,
you want the driver to be able to write into an area which the user cannot.

I believe the force flag originated for ptrace, and in particular,
to allow a breakpoint to be written into an area of read-only text.

You ask in other mail about VM_MAYREAD and VM_MAYWRITE, their relation
to VM_READ and VM_WRITE: they show the permissions you are permitted to
add via mprotect.  So although you may not have VM_WRITE on an area at
present, if VM_MAYWRITE is set then you can later mprotect it PROT_WRITE.
And "force" takes those into consideration, refusing to write to an area
for which you don't have MAYWRITE permission.

But here it gets very weird.  Although write=3D1 force=3D1 checks MAYWRITE
(and you need to have opened the file for writing to have MAYWRITE on a
SHARED mmap), the fault which GUP write=3D1 force=3D1 generates on a curren=
tly
readonly shared mapping actually causes COW - you end up with an anonymous
page inside the shared mapping.  Nick and I hated that, and tried to argue
Linus out of it, but he dug his heels in; and realistically it's many years
too late to change.  I assume it originated as an additional layer of
protection, to prevent someone setting breakpoints, who happened to have
opened the object RW instead of RO, from corrupting their object file on
disk.  So although shared-write-force demands you have write permission
on the file, it ensures you don't write to it (unless VM_WRITE also set).

I don't like even mentioning that behaviour, it's aberrant, and everywhere
ignored; but I once did an audit, and didn't find anything so seriously
wrong as to merit complicating the code all over.

But I have to mention it to you now, because just as I suggest above that
your mmap should be MAP_SHARED not MAP_PRIVATE, I might want to suggest
that you should open the mmaped file RW; yet I fear that this aberrant
behaviour will defeat that anyway.  Something to try to see if it helps.

(In preparing to answer you, I got excited to find what looked like
an anomaly within the aberration: although you can fairly easily see
do_wp_page() falling through to COW in the case above, it looked to me
as if the "early C-O-W break" code in __do_fault() does not.  But in
practice it appears to, and eventually I realized that maybe_mkwrite
does not set the pte_write bit in this case, which causes GUP's next
follow_page to fail, so it goes to handle_mm_fault again, which this
time will go the do_wp_page way, implementing the behaviour described.)

>=20
> > And although the ZERO_PAGE gives the most vivid example, I think it goe=
s
> > beyond that to the wider issue of pages COWed after fork() - GUPping in
> > this way fixes the easy cases (and I've no desire again to go down that
> > rathole of fixing the most general cases).
>=20
> For IB / RDMA we kind of explicitly give up on COW after fork().
> But I guess I don't know what issue you're thinking of.  Is it
> similar to what I described above?  In other words, we have
> a readable mapping that we'll COW on a write fault, but the driver
> is only following the mapping for reading and so a COW will
> mess us up.

That's it; but you say that you give up on COW after fork(), just
as I say that I don't want to go down that rathole again.  There are
others who disagree, but you and I are on the same page (haha) there.

>=20
> Sigh, what a mess ... it seems what we really want to do is know
> if userspace might trigger a COW because or not, and only do a
> preemptive COW in that case.  (We're not really concerned with
> userspace fork()ing and setting up a COW in the future, since that's
> what we have MADV_DONTFORK for)
>=20
> The status quo works for userspace anonymous mappings but
> it doesn't work for my case of mapping a kernel buffer read-only
> into userspace.  And fixing my case breaks the anonymous case.
> Do you see a way out of this dilemma?  Do we need to add yet
> another flag to get_user_pages()?

I would prefer to avoid that, but it's always a possibility.
Of course, by new flag to __get_user_pages rather than more args
to get_user_pages.  But right now I'm still unclear why you're
doing get_user_pages at all in the mapped device case.

Hugh
--8323584-2087791211-1327717154=:3402--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
