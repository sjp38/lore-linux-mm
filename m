Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id E52E36B0069
	for <linux-mm@kvack.org>; Sun, 30 Oct 2011 17:50:16 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <f64fa61a-6a93-430a-bc51-53acb5e2e1ea@default>
Date: Sun, 30 Oct 2011 14:50:01 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
 <75efb251-7a5e-4aca-91e2-f85627090363@default>
 <20111027215243.GA31644@infradead.org> <1319785956.3235.7.camel@lappy>
 <CAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
 <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default>
 <CAOJsxLEE-qf9me1SAZLFiEVhHVnDh7BDrSx1+abe9R4mfkhD=g@mail.gmail.com>
 <20111028163053.GC1319@redhat.com>
 <b86860d2-3aac-4edd-b460-bd95cb1103e6@default>
 <20138.62532.493295.522948@quad.stoffel.home>
 <3982e04f-8607-4f0a-b855-2e7f31aaa6f7@default>
 <20139.5644.583790.903531@quad.stoffel.home>
 <3ac142d4-a4ca-4a24-bf0b-69a90bd1d1a0@default
 1320005162.15403.14.camel@nimitz>
In-Reply-To: <1320005162.15403.14.camel@nimitz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: John Stoffel <john@stoffel.org>, Johannes Weiner <jweiner@redhat.com>, Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Jonathan Corbet <corbet@lwn.net>

> From: Dave Hansen [mailto:dave@linux.vnet.ibm.com]
> Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)

Thanks Dave (I think ;-) for chiming in.

> On Sun, 2011-10-30 at 12:18 -0700, Dan Magenheimer wrote:
> > > since they're the ones who will have to understand this stuff and kno=
w
> > > how to maintain it.  And keeping this maintainable is a key goal.
> >
> > Absolutely agree.  Count the number of frontswap lines that affect
> > the current VM core code and note also how they are very clearly
> > identified.  It really is a very VERY small impact to the core VM
> > code (e.g. in the files swapfile.c and page_io.c).
>=20
> Granted, the impact on the core VM in lines of code is small.  But, I
> think the behavioral impact is potentially huge since tmem's hooks add
> non-trivial amounts of framework underneath the VM in core paths.  In
> zcache's case, this means a bunch of allocations and an entirely new
> allocator memory allocator being used in the swap paths.

True BUT (and this is a big BUT) it ONLY affects the core VM
path if both CONFIG_FRONTSWAP=3Dy AND if a "tmem backend" such as
zcache registers it.  So not only is the code maintenance
impact very VERY small (which you granted), but there is
no impact on users or distros or products that don't turn it
on.  I also should repeat that the core VM changes introduced
by frontswap have remained essentially identical since first
proposed circa 2.6.18... the impacted swap code is NOT frequently-
changing code.  My point in my "Absolutely agree" above, is
that the maintenance burden to core VM developers is low.

> We're certainly still shaking bugs out of the interactions there like
> with zcache_direct_reclaim_lock.  Granted, that's not a
> tmem/frontswap/cleancache bug, but it does speak to the difficulty and
> subtlety of writing one of those frameworks underneath the tmem API.

IMHO, that's coming perilously close to saying "we don't accept
code that has bugs in it".  How many significant pieces of functionality
have been added to the kernel EVER where there were NO bugs found in
the next few months?  How much MERGED functionality (such as new
filesystems) has gone into the kernel years before it was broadly deployed?

Zcache is currently a staging driver for a reason... I admit it...
I wrote zcache in a couple of months (and mostly over the holidays)
and it was really the first major Linux kernel driver I'd done.
I was surprised as hell when GregKH took it into staging.  But
it works pretty darn well.  Why?  Because it is built on the
foundation of cleancache and frontswap, which _just work_!!
And Seth Jennings (also of IBM for those that don't know) has been
doing a great job of finding and fixing bottlenecks, as well as
looking at some interesting enhancements.  I think he found ONE bug
so far... because I hadn't tested on 32-bit highmem machines.
Clearly, Seth and IBM see some value in zcache (perhaps, as Ed
Tomlinson pointed out, because AIX has similar capability?)

But let's not forget that there would be no zcache for Seth or
IBM to work on if you hadn't already taken the frontswap patchset
into your tree.  Frontswap is an ENABLER for zcache, as well as
for Xen tmem, for RAMster and (soon according to two kernel developers)
possibly also for KVM.  Given the tiny maintenance cost, why
not merge it?

So if you are saying that frontswap is not quite ready to be
merged, fine, I can accept that.  But there are now a number
of features, developers, distros, and products depending on it,
so there's a few of us who would like to hear CONCRETE STEPS
we need to achieve to make it ready.  (John Stoffel is the only
one to suggest any... not counting documentation he didn't
read, the big one is getting some measurements to show zcache
is valuable.  Hoping Seth can help with that?)

Got any suggestions?

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
