Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 4129E6B0069
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 17:01:02 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <b8a0ca71-a31b-488a-9a92-2502d4a6e9bf@default>
Date: Tue, 1 Nov 2011 14:00:34 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
 <75efb251-7a5e-4aca-91e2-f85627090363@default>
 <20111027215243.GA31644@infradead.org> <1319785956.3235.7.camel@lappy>
 <CAOzbF4fnD=CGR-nizZoBxmFSuAjFC3uAHf3wDj5RLneJvJhrOQ@mail.gmail.comCAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
 <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default20111031181651.GF3466@redhat.com>
 <60592afd-97aa-4eaf-b86b-f6695d31c7f1@default20111031223717.GI3466@redhat.com>
 <1b2e4f74-7058-4712-85a7-84198723e3ee@default20111101012017.GJ3466@redhat.com>
 <6a9db6d9-6f13-4855-b026-ba668c29ddfa@default
 20111101180702.GL3466@redhat.com>
In-Reply-To: <20111101180702.GL3466@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

> From: Andrea Arcangeli [mailto:aarcange@redhat.com]
> Sent: Tuesday, November 01, 2011 12:07 PM
> To: Dan Magenheimer
> Cc: Pekka Enberg; Cyclonus J; Sasha Levin; Christoph Hellwig; David Rient=
jes; Linus Torvalds; linux-
> mm@kvack.org; LKML; Andrew Morton; Konrad Wilk; Jeremy Fitzhardinge; Seth=
 Jennings; ngupta@vflare.org;
> Chris Mason; JBeulich@novell.com; Dave Hansen; Jonathan Corbet
> Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)

Hi Andrea --

Pardon me for complaining about my typing fingers, but it seems
like you are making statements and asking questions as if you
are not reading the whole reply before you start responding
to the first parts.  So it's going to be hard to answer each
sub-thread in order.  So let me hit a couple of the high
points first.

> This basically proofs the API must be fixed....

Let me emphasize and repeat: Many of your comments
here are addressing zcache, which is a staging driver.
You are commenting on intra-zcache APIs only, _not_ on the
tmem ABI.  I realize there is some potential confusion here
since the file in the zcache directory is called tmem.c;
but it is NOT defining or implementing the tmem ABI/API used
by the kernel.  The ONLY kernel API that need be debated here
is the code in the frontswap patchset, which provides
registration for a set of function pointers (see the
struct frontswap_ops in frontswap.h in the patch) and
provides the function calls (API) between the frontswap
(and cleancache) "frontends" and the "backends" in
the driver directory.  The zcache file "tmem.c" is simply
a very early attempt to tease out core operations and
data structures that are likely to be common to multiple
tmem users.

Everything in zcache (including tmem.c) is completely open
to evolution as needed (by KVM or other users) and this
will need to happen before zcache is promoted out of staging.
So your comments will be very useful when "we" work
on that promotion process.

So, I'm going to attempt to ignore the portions of your
reply that are commenting specifically about zcache coding
issues and reply to the parts that potentially affect
acceptance of the frontswap patchset, but if I miss anything
important to you, please let me know.

> About the rest of zcache I think it's interesting but because it works
> inside tmem I'm unsure how we're going to write it to disk.
>=20
> The local_irq_save would be nice to understand why it's needed for
> frontswap but not for pagecache.

It's because the already-merged cleancache hooks that call
cleancache_put are invoked from mm/vfs code where irqs are
already disabled.  This is not true for the hook calling
frontswap_get, but since there's a lot of shared code,
I disabled irqs for frontswap_get also.

> All that VM code never runs from
> irqs, so it's hard to see how the irq disabling is relevant. A bit fat
> comment on why local_irq_save is needed in zcache code (in staging
> already) would be helpful. Maybe it's tmem that can run from irq?  The
> only thing running from irqs is the tlb flush and I/O completion
> handlers, everything else in the VM isn't irq/softirq driven so we
> never have to clear irqs.

Other than the fact that cleancache_put is called with
irqs disabled (and, IIRC, sometimes cleancache_flush?)
and the coding complications that causes, you are correct.

Preemption does need to be disabled though and, IIRC,
in some cases, softirqs.

> My feeling is this zcache should be based on a memory pool abstraction
> that we can write to disk with a bio and working with "pages".

Possible I suppose.  But unless you can teach bio to deal
with dynamically time-and-size varying devices, you are
not implementing the most important value of the tmem concept,
you are just re-implementing zram.  And, as I said, Nitin
supports frontswap because it is better than zram for
exactly this (dynamicity) reason:  https://lkml.org/lkml/2011/10/28/8=20

> I'm also not sure how you balance the pressure in the tmem pool, when
> you fail the allocation and swap to disk, or when you keep moving to
> compressed swap.

Just like all existing memory management code, zcache depends
on some heuristics, which can be improved as necessary over time.
Some of the metrics that feed into the heuristics are in
debugfs so they can be manipulated as zcache continue to
develop.  (See zv_page_count_policy_percent for example...
yes this is still a bit primitive.  And before you start up
about dynamic sizing, this is only a maximum.)

For Xen, there is a "memmax" for each guest, and Xen tmem disallows
a guest from using a page for swap (tmem calls it a "persistent" pool)
if it has reached its memmax.  Thus unless a tmem-enabled guest
is "giving", it can never expect to "get".

For KVM, you can overcommit in the host, so you could choose a
different heuristic... if you are willing to accept host swapping
(which I think is evil :-)
=20
> > This is a known problem: zcache is currently not very
> > good for high-response RT environments because it currently
> > compresses a page of data with interrupts disabled, which
> > takes (IIRC) about 20000 cycles.  (I suspect though, without proof,
> > that this is not the worst irq-disabled path in the kernel.)
>=20
> That's certainly more than the irq latency so it's probably something
> the rt folks don't want and yes they should keep it in mind not to use
> frontswap+zcache in embedded RT environments.

Well, you have yet to convince me that an extra copy is
so damning, especially on a modern many-core CPU where it
can be done in 256 cycles and especially when the cache-pollution
for the copy is necessary for the subsequent compression anyway.

But for now, yes, don't turn on zcache in embedded RT.

> Besides there was no benchmark comparing zram performance to zcache
> performance so latency aside we miss a lot of info.

Think of zcache as zram PLUS dynamicity PLUS ability to dynamically
trade off memory utilization against compressed page cache.

> And what is the exact reason of the local_irq_save for doing it
> zerocopy?

(Answered above I think? If not, let me know.)

> Would I'd like is a mechanism where you:
>=20
> 1) add swapcache to zcache (with fallback to swap immediately if zcache
>    allocation fails)

Current swap code pre-selects the swap device several layers
higher in the call chain, so this requires fairly major surgery
on the swap subsystem... and the long bug-tail that implies.

> 2) when some threshold is hit or zcache allocation fails, we write the
>    compressed data in a compact way to swap (freeing zcache memory),
>    or swapcache directly to swap if no zcache is present

Has efficient writing (and reading) of smaller-than-page chunks
through blkio every been implemented?  I know compression can be
done "behind the curtain" of many I/O devices, but am unaware
that the same functionality exists in the kernel.  If it doesn't
exist, this requires fairly major surgery on the blkio subsystem.
If it does exist, I doubt the swap subsystem is capable of using
it without major surgery.

> 3) newly added swapcache is added to zcache (old zcache was written to
>    swap device compressed and freed)
>=20
> Once we already did the compression it's silly to write to disk the
> uncompressed data. Ok initially it's ok because compacting the stuff
> on disk is super tricky but we want a design that will allow writing
> the zcache to disk and add new swapcache to zcache, instead of the
> current way of swapping the new swapcache to disk uncompressed and not
> being able to writeout the compressed zcache.
>=20
> If nobody called zcache_get and uncompressed it, it means it's
> probably less likely to be used than the newly added swapcache that
> wants to be compressed.

Yeah, I agree that sounds like a cool high-level design for a
swap subsystem rewrite.  Problem is it doesn't replace the dynamicity
to do what frontswap does for virtualization and multiple physical
machines (RAMster).  Just not as flexible.

And do you really want to rewrite the swap subsystem anyway
when a handful of frontswap hooks do the same thing (and more)?

> I'm afraid adding frontswap in this form will still get stuck us in
> the wrong model and most of it will have to be dropped and rewritten
> to do just the above 3 points I described to do proper swap
> compression.

This is a red herring.  I translate this as "your handful of hooks
might interfere with some major effort that I've barely begun to
design".  And even if you DO code that major effort... the
frontswap hooks are almost trivial and clearly separated from
most of the core swap code... how do you know those hooks will
interfere with your grand plan anyway?

Do I have to quote Linus's statement from the KS2011 minutes
again? :-)

> The final swap design must also include the pre-swapout from Avi by
> writing data to swapcache in advance and relaying on the dirty bit to
> rewrite it. And the pre-swapin as well (original idea from Con). The
> pre-swapout would need to stop before compressing. The pre-swapin
> should stop before decompressing.

IIUC, you're talking about improvements to host-swapping here.
That is (IMHO) putting lipstick on a pig.  And, in any case, you
are talking about significant swap subsystm changes that only help
a single user, KVM.  You seem to be already measuring non-existent
KVM patches by a different/easier standard than you are applying
to a simple frontswap patchset that's been public for nearly
three years.

> I mean I see an huge potential for improvement in the swap space, just
> I guess most are busy with more pressing issues, like James said most
> data centers don't use swap, desktop is irrelevant and android (as
> relevant as data center) don't use swap.

Yep.  I agree that it is unlikely to get done.  But James' data
centers are running cgroups, not Xen, not KVM. And there is
a solution proposed that exists today for Xen, and that
KVM can at least attempt if not heavily leverage.

> But your improvement to frontswap don't look the right direction if
> you really want to improve swap for the long term. It may be better
> than nothing but I don't see it going the way it should go and I
> prefer to remove the tmem dependency on zcache all together. Zcache
> alone would be way more interesting.

There is no tmem dependency on zcache.  Feel free to rewrite
zcache entirely.  It still needs the hooks in the frontswap
patch, or something at least very similar.

> And tmem_put must be fixed to take a page, that cast to char * of a
> page, to avoid crashing on highmem is not allowed.
>
> Of course I didn't have the time to read 100% of the code so please
> correct me again if I misunderstood something.

Then feel free to rewrite that code.. or wait until it gets
fixed.  I agree that it's unlikely that zcache will be promoted
out of staging with that hack.  That's all still unrelated to
merging frontswap.
>=20
> > This is the "fix highmem" bug fix from Seth Jennings.  The file
> > tmem.c in zcache is an attempt to separate out the core tmem
> > functionality and data structures so that it can (eventually)
> > be in the lib/ directory and be used by multiple backends.
> > (RAMster uses tmem.c unchanged.)  The code in tmem.c reflects
> > my "highmem-blindness" in that a single pointer is assumed to
> > be able to address the "PAMPD" (as opposed to a struct page *
> > and an offset, necessary for a 32-bit highmem system).  Seth
> > cleverly discovered this ugly two-line fix that (at least for now)
> > avoided major mods to tmem.c.
>=20
> Well you need to do the major mods, it's not ok to do that cast,
> passing pages is correct instead. Let's fix the tmem_put API before
> people can use it wrong. Maybe then I'll dislike passing through tmem
> less? Dunno.

Zcache doesn't need to pass through tmem.c.  RAMster is using tmem.c
but isn't even in staging yet.

> The whole logic deciding the size of the frontswap zcache is going to
> be messy.

It's not messy, and is entirely dynamic.  Finding the ideal
heuristics for the maximum size, and when and how much to
decompress pages back out of zcache back into the swap cache,
I agree, is messy and will take some time.

Still not sure how this is related to the proposed frontswap
patch now (which just provides some mechanism for the heuristics
to drive).

> But to do the real swapout you should not pull the memory
> out of frontswap zcache, you should write it to disk compacted and
> compressed compared to how it was inserted in frontswap... That would
> be the ideal.

Agreed, that would be cool... and very difficult to implement.

> > The selfballooning code in drivers/xen calls frontswap_shrink
> > to pull swap pages out of the Xen hypervisor when memory pressure
> > is reduced.  Frontswap_shrink is not yet called from zcache.
>=20
> So I wonder how zcache is dealing with the dynamic size. Or has it a
> fixed size? How do you pull pages out of zcache to max out the real
> RAM availability?

Dynamic.  Pulled out with frontswap_shrink, see above.

> > Note, however, that unlike swap-disks, compressed pages in
> > frontswap CAN be silently moved to another "device".  This is
> > the foundation of RAMster, which moves those compressed pages
> > to the RAM of another machine.  The device _could_ be some
> > special type of real-swap-disk, I suppose.
>=20
> Yeah you can do ramster with frontswap+zcache but not writing the
> zcache to disk into the swap device. Writing to disk doesn't require
> new allocations. Migrating to other node does. And you must deal with
> OOM conditions there. Or it'll deadlock. So the basic should be to
> write compressed data to disk (which at least can be done reliably for
> swapcache, unlike ramster which has the same issues of nfs swapping
> and nbd swapping and iscsi sapping) before wondering if to send it to
> another node.

I guess you are missing the key magic for RAMster, or really
for tmem.  Because everything in tmem is entirely dynamic (e.g.
any attempt to put a page can be rejected), the "remote" machine
has complete control over how many pages to accept from whom,
and can manage its own needs as higher priority.  Think of
a machine in RAMster as a KVM/Xen "host" for a bunch of
virtual-machines-that-are-really-physical-machines.  And it
is all peer-to-peer, so each machine can act as a host when
necessary.  None of this is possible through anything that
exists today in the swap subsystem or blkio subsystem.
And RAMster runs on the same cleancache and frontswap hooks
as Xen and zcache and, potentially, KVM.

Yeah, the heuristics may be even harder for RAMster.  But
the first response to this thread (from Christoph) said
that this stuff isn't sexy.  Personally I can't think of
anything sexier than the first CROSS-MACHINE memory management
subsystem in a mainstream OS.  Again... NO additional core
VM changes.

> > Yes, this is a good example of the most important feature of
> > tmem/frontswap:  Every frontswap_put can be rejected for whatever reaso=
n
> > the tmem backend chooses, entirely dynamically.  Not only is it true
> > that hardware can't handle this well, but the Linux block I/O subsystem
> > can't handle it either.  I've suggested in the frontswap documentation
> > that this is also a key to allowing "mixed RAM + phase-change RAM"
> > systems to be useful.
>=20
> Yes what is not clear is how the size of the zcache is choosen.

Is that answered clearly now?

> > Also I think this is also why many linux vm/vfs/fs/bio developers
> > "don't like it much" (where "it" is cleancache or frontswap).
> > They are not used to losing control of data to some other
> > non-kernel-controlled entity and not used to being told "NO"
> > when they are trying to move data somewhere.  IOW, they are
> > control freaks and tmem is out of their control so it must
> > be defeated ;-)
>=20
> Either tmem works on something that is a core MM structure and is
> compatible with all bios and operations we can want to do on memory,
> or I've an hard time to think it's a good thing in trying to make the
> memory it handles not-kernel-controlled.
>=20
> This non-kernel-controlled approach to me looks like exactly a
> requirement coming from Xen, not really something useful.

C'mon Andrea.  You're an extremely creative guy and you are
disappointing me.

Think RAMster.  Think a version of RAMster with a "memory server"
(where the RAM expandability is in one server in a rack).  Think
fast SSDs that can be attached to one machine and shared by other
machines.  Think phase-change (or other future limited-write-cycle)
RAM without a separate processor counting how many times a cell
has been written.  This WAS all about Xen a year or two ago.
I haven't written a line of Xen in over a year because I am
excited about the FULL value of tmem.

> There is no reason why a kernel abstraction should stay away from
> using kernel data structures like "struct page" just to cast it back
> from char * to struct page * when it needs to handle highmem in
> zcache. Something seriously wrong is going on there in API terms so
> you can start by fixing that bit.

Yep, let's fix that problem in zcache.  That is a stupid
coding error by me and irrelevant to frontswap and the bigger
transcendent memory picture.

> > I hope the earlier explanation about frontswap_shrink helps.
> > It's also good to note that the only other successful Linux
> > implementation of swap compression is zram, and zram's
> > creator fully supports frontswap (https://lkml.org/lkml/2011/10/28/8)
> >
> > So where are we now?  Are you now supportive of merging
> > frontswap?  If not, can you suggest any concrete steps
> > that will gain your support?
>=20
> My problem is this is like zram, like mentioned it only solves the
> compression. There is no way it can store the compressed data on
> disk. And this is way more complex than zram, and it only makes the
> pooling size not fixed at swapon time... so very very small gain and
> huge complexity added (again compared to zram). zram in fact required
> absolutely zero changes to the VM. So it's hard to see how this is
> overall better than zram. If we deal with that amount of complexity we
> should at least be a little better than zram at runtime, while this is
> same.

Zram required exactly ONE change to the VM, and Nitin placed it
there AFTER he looked at how frontswap worked.  Then he was forced
down the "gotta do it as a device" path which lost a lot of the
value.  Then, when he wanted to do compression on page cache, he
found that the cleancache interface was perfect for it.  Why
does everyone keep telling me to "do it like zram" when the author
of zram has seen the light?  Did I mention Nitin's support for
frontswap already?   https://lkml.org/lkml/2011/10/28/8=20

So, I repeat, where are we now?  Have I sufficiently answered
your concerns and questions?  Or are you going to go start
coding to prove me wrong with a swap subsystem rewrite? :-)

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
