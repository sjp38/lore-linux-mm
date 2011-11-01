Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 0698C6B006C
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 14:07:16 -0400 (EDT)
Date: Tue, 1 Nov 2011 19:07:02 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
Message-ID: <20111101180702.GL3466@redhat.com>
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
 <75efb251-7a5e-4aca-91e2-f85627090363@default>
 <20111027215243.GA31644@infradead.org>
 <1319785956.3235.7.camel@lappy>
 <CAOzbF4fnD=CGR-nizZoBxmFSuAjFC3uAHf3wDj5RLneJvJhrOQ@mail.gmail.comCAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
 <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default20111031181651.GF3466@redhat.com>
 <60592afd-97aa-4eaf-b86b-f6695d31c7f1@default20111031223717.GI3466@redhat.com>
 <1b2e4f74-7058-4712-85a7-84198723e3ee@default20111101012017.GJ3466@redhat.com>
 <6a9db6d9-6f13-4855-b026-ba668c29ddfa@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6a9db6d9-6f13-4855-b026-ba668c29ddfa@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

On Tue, Nov 01, 2011 at 09:41:38AM -0700, Dan Magenheimer wrote:
> I suppose this documentation (note, it is in drivers/staging/zcache,
> not in the proposed frontswap patchset) could be misleading.  It is

Yep I gotten the comment from tmem.c in staging, and the lwn link I
read before reading the tmem_put comment also only mentioned about
tmem_put doing a copy. So I erroneously assumed that all memory
passing through tmem was being copied and you lost reference of the
"struct page" when it entered zcache.

But instead there is this obscure cast of a "struct page *" to a "char
*", that is casted back to a struct page * from a char * in zcache
code, and kmap() runs on the page, to avoid the unnecessary copy.

So far so good, now the question is why do you have that cast at all?

I mean it's hard to be convinced on the sanity of on a API that
requires the caller to cast a "struct page *" to a "char *" to run
zerocopy. And well that is the very core tmem_put API I'm talking
about.

I assume the explanation of the cast is: before it was passing
page_address(page) to tmem, but that breaks with highmem because
highmem requires kmap(page). So then you casted the page.

This basically proofs the API must be fixed. In the kernel we work
with _pages_ not char *, exactly for this reason, and tmem_put must be
fixed to take a page structure. (in fact better would be an array of
pages and ranges start/end for each entry in the array but hey at
least a page+len would be sane). A char * is flawed and the cast of
the page to char * and back to struct page, kind of proofs it. So I
think that must be fixed in tmem_put. Unfortunately it's already
merged with this cast back and forth in the upstream kernel.

About the rest of zcache I think it's interesting but because it works
inside tmem I'm unsure how we're going to write it to disk.

The local_irq_save would be nice to understand why it's needed for
frontswap but not for pagecache. All that VM code never runs from
irqs, so it's hard to see how the irq disabling is relevant. A bit fat
comment on why local_irq_save is needed in zcache code (in staging
already) would be helpful. Maybe it's tmem that can run from irq?  The
only thing running from irqs is the tlb flush and I/O completion
handlers, everything else in the VM isn't irq/softirq driven so we
never have to clear irqs.

My feeling is this zcache should be based on a memory pool abstraction
that we can write to disk with a bio and working with "pages".

I'm also not sure how you balance the pressure in the tmem pool, when
you fail the allocation and swap to disk, or when you keep moving to
compressed swap.

> This is a known problem: zcache is currently not very
> good for high-response RT environments because it currently
> compresses a page of data with interrupts disabled, which
> takes (IIRC) about 20000 cycles.  (I suspect though, without proof,
> that this is not the worst irq-disabled path in the kernel.)

That's certainly more than the irq latency so it's probably something
the rt folks don't want and yes they should keep it in mind not to use
frontswap+zcache in embedded RT environments.

Besides there was no benchmark comparing zram performance to zcache
performance so latency aside we miss a lot of info.

> As noted earlier, this is fixable at the cost of the extra copy
> which could be implemented as an option later if needed.
> Or, as always, the RT folks can just not enable zcache.
> Or maybe smarter developers than me will find a solution
> that will work even better.

And what is the exact reason of the local_irq_save for doing it
zerocopy?

> Yeah, remember zcache was merged before either cleancache or
> frontswap, so this ugliness was necessary to get around the
> chicken-and-egg problem.  Zcache will definitely need some
> work before it is ready to move out of staging, and your
> feedback here is useful for that, but I don't see that as
> condemning frontswap, do you?

Would I'd like is a mechanism where you:

1) add swapcache to zcache (with fallback to swap immediately if zcache
   allocation fails)

2) when some threshold is hit or zcache allocation fails, we write the
   compressed data in a compact way to swap (freeing zcache memory),
   or swapcache directly to swap if no zcache is present

3) newly added swapcache is added to zcache (old zcache was written to
   swap device compressed and freed)

Once we already did the compression it's silly to write to disk the
uncompressed data. Ok initially it's ok because compacting the stuff
on disk is super tricky but we want a design that will allow writing
the zcache to disk and add new swapcache to zcache, instead of the
current way of swapping the new swapcache to disk uncompressed and not
being able to writeout the compressed zcache.

If nobody called zcache_get and uncompressed it, it means it's
probably less likely to be used than the newly added swapcache that
wants to be compressed.

I'm afraid adding frontswap in this form will still get stuck us in
the wrong model and most of it will have to be dropped and rewritten
to do just the above 3 points I described to do proper swap
compression.

Also I'm skeptical we need to pass through tmem at all to do that. I
mean done right the swap compression could be a feature to enable
across the board without needing tmem at all. Then if you want to add
ramster just add a frontswap on the already compressed
swapcache... before it goes to the hard swap device.

The final swap design must also include the pre-swapout from Avi by
writing data to swapcache in advance and relaying on the dirty bit to
rewrite it. And the pre-swapin as well (original idea from Con). The
pre-swapout would need to stop before compressing. The pre-swapin
should stop before decompressing.

I mean I see an huge potential for improvement in the swap space, just
I guess most are busy with more pressing issues, like James said most
data centers don't use swap, desktop is irrelevant and android (as
relevant as data center) don't use swap.

But your improvement to frontswap don't look the right direction if
you really want to improve swap for the long term. It may be better
than nothing but I don't see it going the way it should go and I
prefer to remove the tmem dependency on zcache all together. Zcache
alone would be way more interesting.

And tmem_put must be fixed to take a page, that cast to char * of a
page, to avoid crashing on highmem is not allowed.

Of course I didn't have the time to read 100% of the code so please
correct me again if I misunderstood something.

> This is the "fix highmem" bug fix from Seth Jennings.  The file
> tmem.c in zcache is an attempt to separate out the core tmem
> functionality and data structures so that it can (eventually)
> be in the lib/ directory and be used by multiple backends.
> (RAMster uses tmem.c unchanged.)  The code in tmem.c reflects
> my "highmem-blindness" in that a single pointer is assumed to
> be able to address the "PAMPD" (as opposed to a struct page *
> and an offset, necessary for a 32-bit highmem system).  Seth
> cleverly discovered this ugly two-line fix that (at least for now)
> avoided major mods to tmem.c.

Well you need to do the major mods, it's not ok to do that cast,
passing pages is correct instead. Let's fix the tmem_put API before
people can use it wrong. Maybe then I'll dislike passing through tmem
less? Dunno.

int tmem_put(struct tmem_pool *pool, struct tmem_oid *oidp, uint32_t index,
-		char *data, size_t size, bool raw, bool ephemeral)
+		struct page *page, size_t size, bool raw, bool ephemeral)


> First ignoring frontswap, there is currently no way to move a
> page of swap data from one swap device to another swap device
> except by moving it first into RAM (in the swap cache), right?

Yes.

> Frontswap doesn't solve that problem either, though it would
> be cool if it could.  The "partial swapoff" functionality
> in the patch, added so that it can be called from frontswap_shrink,
> enables pages to be pulled out of frontswap into swap cache
> so that they can be moved if desired/necessary onto a real
> swap device.

The whole logic deciding the size of the frontswap zcache is going to
be messy. But to do the real swapout you should not pull the memory
out of frontswap zcache, you should write it to disk compacted and
compressed compared to how it was inserted in frontswap... That would
be the ideal.

> The selfballooning code in drivers/xen calls frontswap_shrink
> to pull swap pages out of the Xen hypervisor when memory pressure
> is reduced.  Frontswap_shrink is not yet called from zcache.

So I wonder how zcache is dealing with the dynamic size. Or has it a
fixed size? How do you pull pages out of zcache to max out the real
RAM availability? 

> Note, however, that unlike swap-disks, compressed pages in
> frontswap CAN be silently moved to another "device".  This is
> the foundation of RAMster, which moves those compressed pages
> to the RAM of another machine.  The device _could_ be some
> special type of real-swap-disk, I suppose.

Yeah you can do ramster with frontswap+zcache but not writing the
zcache to disk into the swap device. Writing to disk doesn't require
new allocations. Migrating to other node does. And you must deal with
OOM conditions there. Or it'll deadlock. So the basic should be to
write compressed data to disk (which at least can be done reliably for
swapcache, unlike ramster which has the same issues of nfs swapping
and nbd swapping and iscsi sapping) before wondering if to send it to
another node.

> Yes, this is a good example of the most important feature of
> tmem/frontswap:  Every frontswap_put can be rejected for whatever reason
> the tmem backend chooses, entirely dynamically.  Not only is it true
> that hardware can't handle this well, but the Linux block I/O subsystem
> can't handle it either.  I've suggested in the frontswap documentation
> that this is also a key to allowing "mixed RAM + phase-change RAM"
> systems to be useful.

Yes what is not clear is how the size of the zcache is choosen.

> Also I think this is also why many linux vm/vfs/fs/bio developers
> "don't like it much" (where "it" is cleancache or frontswap).
> They are not used to losing control of data to some other
> non-kernel-controlled entity and not used to being told "NO"
> when they are trying to move data somewhere.  IOW, they are
> control freaks and tmem is out of their control so it must
> be defeated ;-)

Either tmem works on something that is a core MM structure and is
compatible with all bios and operations we can want to do on memory,
or I've an hard time to think it's a good thing in trying to make the
memory it handles not-kernel-controlled.

This non-kernel-controlled approach to me looks like exactly a
requirement coming from Xen, not really something useful.

There is no reason why a kernel abstraction should stay away from
using kernel data structures like "struct page" just to cast it back
from char * to struct page * when it needs to handle highmem in
zcache. Something seriously wrong is going on there in API terms so
you can start by fixing that bit.

> I hope the earlier explanation about frontswap_shrink helps.
> It's also good to note that the only other successful Linux
> implementation of swap compression is zram, and zram's
> creator fully supports frontswap (https://lkml.org/lkml/2011/10/28/8)
>
> So where are we now?  Are you now supportive of merging
> frontswap?  If not, can you suggest any concrete steps
> that will gain your support?

My problem is this is like zram, like mentioned it only solves the
compression. There is no way it can store the compressed data on
disk. And this is way more complex than zram, and it only makes the
pooling size not fixed at swapon time... so very very small gain and
huge complexity added (again compared to zram). zram in fact required
absolutely zero changes to the VM. So it's hard to see how this is
overall better than zram. If we deal with that amount of complexity we
should at least be a little better than zram at runtime, while this is
same.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
