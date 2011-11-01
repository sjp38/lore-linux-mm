Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 075716B0069
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 12:41:58 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <6a9db6d9-6f13-4855-b026-ba668c29ddfa@default>
Date: Tue, 1 Nov 2011 09:41:38 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
 <75efb251-7a5e-4aca-91e2-f85627090363@default>
 <20111027215243.GA31644@infradead.org> <1319785956.3235.7.camel@lappy>
 <CAOzbF4fnD=CGR-nizZoBxmFSuAjFC3uAHf3wDj5RLneJvJhrOQ@mail.gmail.comCAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
 <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default20111031181651.GF3466@redhat.com>
 <60592afd-97aa-4eaf-b86b-f6695d31c7f1@default20111031223717.GI3466@redhat.com>
 <1b2e4f74-7058-4712-85a7-84198723e3ee@default
 20111101012017.GJ3466@redhat.com>
In-Reply-To: <20111101012017.GJ3466@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

> From: Andrea Arcangeli [mailto:aarcange@redhat.com]
> Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
>=20
> On Mon, Oct 31, 2011 at 04:36:04PM -0700, Dan Magenheimer wrote:
> > Do you see code doing this?  I am pretty sure zcache is
> > NOT doing an extra copy, it is compressing from the source
> > page.  And I am pretty sure Xen tmem is not doing the
> > extra copy either.
>=20
> So below you describe put as a copy of a page from the kernel into the
> newly allocated PAM space... I guess there's some improvement needed
> for the documentation at least, a compression is done sometime instead
> of a copy... I thought you always had to copy first sorry.

I suppose this documentation (note, it is in drivers/staging/zcache,
not in the proposed frontswap patchset) could be misleading.  It is
really tough in a short comment to balance between describing
the general concept to readers trying to understand the big
picture, and the high level of detail needed if you are trying
to really understand what is going on in the code.  But one
can always read the code.

> zcache_compress then does:
>
> =09ret =3D lzo1x_1_compress(from_va, PAGE_SIZE, dmem, out_len, wmem);
>                                    ^^^^^^^^
>=20
> tmem is called from frontswap_put_page.
>=20
> In turn called by swap_writepage:
>=20
> the above frontswap_ops.put_page points to the below
> zcache_frontswap_put_page which even shows a local_irq_save() for the
> whole time of the compression... did you ever check irq latency with
> zcache+frontswap? Wonder what the RT folks will say about
> zcache+frontswap considering local_irq_save is a blocker for preempt-RT.

This is a known problem: zcache is currently not very
good for high-response RT environments because it currently
compresses a page of data with interrupts disabled, which
takes (IIRC) about 20000 cycles.  (I suspect though, without proof,
that this is not the worst irq-disabled path in the kernel.)
As noted earlier, this is fixable at the cost of the extra copy
which could be implemented as an option later if needed.
Or, as always, the RT folks can just not enable zcache.
Or maybe smarter developers than me will find a solution
that will work even better.

Also, yes, as I said, zcache currently is written to assume
4k pagesize, but the tmem.c code/API (see below for more
on that file) is pagesize-independent.

> And zcache-main.c has #ifdef for both frontswap and cleancache
> #ifdef CONFIG_CLEANCACHE
> #include <linux/cleancache.h>
> #endif
> #ifdef CONFIG_FRONTSWAP
> #include <linux/frontswap.h>
> #endif

Yeah, remember zcache was merged before either cleancache or
frontswap, so this ugliness was necessary to get around the
chicken-and-egg problem.  Zcache will definitely need some
work before it is ready to move out of staging, and your
feedback here is useful for that, but I don't see that as
condemning frontswap, do you?

> This zcache functionality is all but pluggable if you've to create a
> new zcache slightly different implementation for each user
> (frontswap/cleancache etc...).

Not quite sure what you are saying here, but IIUC, the alternative
was to push the tmem semantics up into the hooks (e.g. into
swapfile.c).  This is what the very first tmem patch did, before
I was advised to (1) split cleancache and frontswap so that
they could be reviewed separately and (2) move the details
of tmem into a different "layer" (cleancache.c/h and frontswap.c/h).
So in order to move ugliness out of the core VM, a bit more
ugliness is required in the tmem shim/backend.

> =09struct page *page =3D (struct page *)(data);
> =09^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>
> And the cast of the page when it enters
> tmem to char:
>=20
> =09=09ret =3D tmem_put(pool, oidp, index, (char *)(page),
> =09=09=09=09PAGE_SIZE, 0, is_ephemeral(pool));
>=20
> Is so weird... and then it returns a page when it exits tmem and
> enters zcache again in zcache_pampd_create.
>=20
> And the "len" get lost at some point inside zcache but I guess that's
> fixable and not part of the API at least.... but the whole thing looks
> an exercise to pass through tmem. I don't really understand why one
> page must become a char at some point and what benefit it would ever
> provide.

This is the "fix highmem" bug fix from Seth Jennings.  The file
tmem.c in zcache is an attempt to separate out the core tmem
functionality and data structures so that it can (eventually)
be in the lib/ directory and be used by multiple backends.
(RAMster uses tmem.c unchanged.)  The code in tmem.c reflects
my "highmem-blindness" in that a single pointer is assumed to
be able to address the "PAMPD" (as opposed to a struct page *
and an offset, necessary for a 32-bit highmem system).  Seth
cleverly discovered this ugly two-line fix that (at least for now)
avoided major mods to tmem.c.

> I also don't understand how you plan to ever swap the compressed data
> considering it's hold outside of the kernel not anymore in a struct
> page. If swap compression was done right, the on-disk data should be
> stored in the compressed format in a compact way so you spend the CPU
> once and you also gain disk speed by writing less. How do you plan to
> achieve this with this design?

First ignoring frontswap, there is currently no way to move a
page of swap data from one swap device to another swap device
except by moving it first into RAM (in the swap cache), right?
Frontswap doesn't solve that problem either, though it would
be cool if it could.  The "partial swapoff" functionality
in the patch, added so that it can be called from frontswap_shrink,
enables pages to be pulled out of frontswap into swap cache
so that they can be moved if desired/necessary onto a real
swap device.

The selfballooning code in drivers/xen calls frontswap_shrink
to pull swap pages out of the Xen hypervisor when memory pressure
is reduced.  Frontswap_shrink is not yet called from zcache.

Note, however, that unlike swap-disks, compressed pages in
frontswap CAN be silently moved to another "device".  This is
the foundation of RAMster, which moves those compressed pages
to the RAM of another machine.  The device _could_ be some
special type of real-swap-disk, I suppose.

> I like the failing when the size of the compressed data is bigger than
> the uncompressed one, only in that case the data should go to swap
> uncompressed of course. That's something in software we can handle and
> hardware can't handle so well and that's why some older hardware
> compression for RAM probably didn't takeoff.

Yes, this is a good example of the most important feature of
tmem/frontswap:  Every frontswap_put can be rejected for whatever reason
the tmem backend chooses, entirely dynamically.  Not only is it true
that hardware can't handle this well, but the Linux block I/O subsystem
can't handle it either.  I've suggested in the frontswap documentation
that this is also a key to allowing "mixed RAM + phase-change RAM"
systems to be useful.

Also I think this is also why many linux vm/vfs/fs/bio developers
"don't like it much" (where "it" is cleancache or frontswap).
They are not used to losing control of data to some other
non-kernel-controlled entity and not used to being told "NO"
when they are trying to move data somewhere.  IOW, they are
control freaks and tmem is out of their control so it must
be defeated ;-)

> I've an hard time to be convinced this is the best way to do swap
> compression especially not seeing how it will ever reach swap on
> disk. But yes it's not doing an additional copy unlike the tmem_put
> comment would imply (it's disabling irqs for the whole duration of the
> compression though).

I hope the earlier explanation about frontswap_shrink helps.
It's also good to note that the only other successful Linux
implementation of swap compression is zram, and zram's
creator fully supports frontswap (https://lkml.org/lkml/2011/10/28/8)

So where are we now?  Are you now supportive of merging
frontswap?  If not, can you suggest any concrete steps
that will gain your support?

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
