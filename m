Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id C1A3A6B004D
	for <linux-mm@kvack.org>; Fri, 27 Jan 2012 21:31:26 -0500 (EST)
Received: by pbaa12 with SMTP id a12so2642506pba.14
        for <linux-mm@kvack.org>; Fri, 27 Jan 2012 18:31:26 -0800 (PST)
Date: Fri, 27 Jan 2012 18:31:07 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH/RFC G-U-P experts] IB/umem: Modernize our get_user_pages()
 parameters
In-Reply-To: <CAL1RGDVBR49QrAbkZ0Wa9Gh98HTwjtsQbFQ4Ws3Ra7rEjT1Mng@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1201271819260.3402@eggly.anvils>
References: <1327557574-6125-1-git-send-email-roland@kernel.org> <alpine.LSU.2.00.1201261133230.1369@eggly.anvils> <CAG4TOxNEV2VY9wOE86p9RnKGqpruB32ci9Wq3yBt8O2zc7f05w@mail.gmail.com> <CAL1RGDVBR49QrAbkZ0Wa9Gh98HTwjtsQbFQ4Ws3Ra7rEjT1Mng@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-1830867477-1327717873=:3402"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roland Dreier <roland@kernel.org>
Cc: linux-rdma@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-1830867477-1327717873=:3402
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Fri, 27 Jan 2012, Roland Dreier wrote:

> > Sigh, what a mess ... it seems what we really want to do is know
> > if userspace might trigger a COW because or not, and only do a
> > preemptive COW in that case. =A0(We're not really concerned with
> > userspace fork()ing and setting up a COW in the future, since that's
> > what we have MADV_DONTFORK for)
> >
> > The status quo works for userspace anonymous mappings but
> > it doesn't work for my case of mapping a kernel buffer read-only
> > into userspace. =A0And fixing my case breaks the anonymous case.
> > Do you see a way out of this dilemma? =A0Do we need to add yet
> > another flag to get_user_pages()?
>=20
> So thinking about this a bit more... it seems what we want is at least
> to first order that we do the equivalent of write=3D=3D1 exactly when the=
 vma
> for a mapping has VM_WRITE set

My first impression is that that's not what you want at all: that will
not do a preliminary COW of anonymous page to be written into by the
driver when the user only wants VM_READ access.  But perhaps I'm
worrying about the second order while you're sticking to first order.

Or perhaps I'm misunderstanding the context in which you want to do
this: are you now accepting to do a different get_user_pages in the
anonymous and driver-memory cases, and this suggestion was for the
driver-memory case only?

> (or is it VMA_MAYWRITE / force=3D=3D1?
> I don't quite understand the distinction between WRITE and MAYWRITE).

I may have told you more than you wanted to know in the other mail.

>=20
> Right now, one call to get_user_pages() might involve more than one vma,
> but we could simulate the above by doing find_vma() and making sure our
> call to get_user_pages() goes one vma at a time.  Of course that would be
> inefficient since get_user_pages() will redo the find_vma() internally, s=
o it
> would I guess make sense to add another FOLL_ flag to tell
> get_user_pages() to do this?

I cannot go further, without explanation for why you need get_user_pages
in the driver-memory case at all.

>=20
> Am I all wet, or am I becoming an MM hacker?

Certainly more than I'll ever be an RDMA hacker,

Hugh
--8323584-1830867477-1327717873=:3402--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
