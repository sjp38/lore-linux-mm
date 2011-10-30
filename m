Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E585B6B0069
	for <linux-mm@kvack.org>; Sun, 30 Oct 2011 15:19:14 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <3ac142d4-a4ca-4a24-bf0b-69a90bd1d1a0@default>
Date: Sun, 30 Oct 2011 12:18:56 -0700 (PDT)
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
 <3982e04f-8607-4f0a-b855-2e7f31aaa6f7@default
 20139.5644.583790.903531@quad.stoffel.home>
In-Reply-To: <20139.5644.583790.903531@quad.stoffel.home>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stoffel <john@stoffel.org>
Cc: Johannes Weiner <jweiner@redhat.com>, Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

> From: John Stoffel [mailto:john@stoffel.org]
> Dan> Thanks for taking the time to read the LWN article and sending
> Dan> some feedback.  I admit that, after being immersed in the topic
> Dan> for three years, it's difficult to see it from the perspective of
> Dan> a new reader, so I apologize if I may have left out important
> Dan> stuff.  I hope you'll take the time to read this long reply.
>=20
> Will do.  But I'm not the person you need to convince here about the
> usefulness of this code and approach, it's the core VM developers,

True, but you are the one providing useful suggestions while
the core VM developers are mostly silent (except for saying things
like "don't like it much").  So thank you for your feedback
and for taking the time to provide it and for indulging my replies.

I/we will need to act on your suggestions, but I need to
answer a couple of points/questions you've raised.

> since they're the ones who will have to understand this stuff and know
> how to maintain it.  And keeping this maintainable is a key goal.

Absolutely agree.  Count the number of frontswap lines that affect
the current VM core code and note also how they are very clearly
identified.  It really is a very VERY small impact to the core VM
code (e.g. in the files swapfile.c and page_io.c).

(And it's worth noting, and I'm not arguing that it is conclusive,
just relevant, that my company has stood up and claimed responsibility
to maintain it.)

> Ok, so why not just a targetted swap compression function instead?
> Why is your method superior?

The designer/implementor of zram (which is the closest thing to
"targetted swap compression" in the kernel today) has stated
elsewhere on this thread that frontswap has advantages
over his own zram code.

And the frontswap patchset (did I mention how small the impact is?)
provides a lot more than just a foundation for compression (zcache).

> But that's besides the point.  How much overhead does TMEM incur when
> it's not being used, but when it's avaiable?

This is answered in frontswap.txt in the patchset, but:

ZERO overhead if CONFIG_FRONTSWAP=3Dn.  All the hooks compile into no-ops.

If CONFIG_FRONTSWAP=3Dy and no "tmem backend" registers to use it at
runtime, the overhead is one "compare pointer against NULL" for
every page actually swapped in or out, which is about as close to ZERO
overhead as any code can be.

If CONFIG_FRONTSWAP=3Dy AND a "tmem backend" does register, the
answer depends on which tmem backend and what it is doing (and
yes I agree more numbers are needed), but the overhead is
incurred only in the case where a page would otherwise have
actually been swapped in or out and can replace the horrible
cost of swapping pages.

> Dan> Frontswap is the last missing piece.  Why so much resistance?
>=20
> Because you haven't sold it well with numbers to show how much
> overhead it has?
>
> I'm being negative because I see no reason to use it.  And because I
> think you can do a better job of selling it and showing the benefits
> with real numbers.

In your environment where RAM is essentially infinite, and swapping
never occurs, I agree there would be no reason for you to enable it.
In which case there is no overhead to you.

Received loud and clear on the "need more real numbers" though
personally I don't have any machines with more than 4GB RAM so
I won't personally be testing any EDA environments with 144GB :-}

So, in the context of "costs nothing if you don't need it and has
very VERY small core code impact", and given that various kernel
developers and real users and real distros and real products say
on this thread that they DO need it, and given that there
are "some" real numbers (for one user, Xen, and agree that some
are needed for zcache)... and assuming that the core VM developers
bother to read the documentation already provided that addresses
the above, let me ask again...

Why so much resistance?

Thanks,
Dan

Oops, one more (but I have to use the X-word)...

> Load up a XEN box, have a VM spike it's memory usage and show how TMEM
> helps.  Compare it to a non-TMEM setup with the same load.

Yep, that's what the presentation URL I provided (for Xen) measures.
Overcommitment (more VMs than otherwise could fit in the physical
RAM) AND about a 8% performance improvement on all VMs doing
a kernel compile simultaneously.  Pretty impressive.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
