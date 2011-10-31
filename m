Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 15D036B002D
	for <linux-mm@kvack.org>; Mon, 31 Oct 2011 19:36:22 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <1b2e4f74-7058-4712-85a7-84198723e3ee@default>
Date: Mon, 31 Oct 2011 16:36:04 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
 <75efb251-7a5e-4aca-91e2-f85627090363@default>
 <20111027215243.GA31644@infradead.org> <1319785956.3235.7.camel@lappy>
 <CAOzbF4fnD=CGR-nizZoBxmFSuAjFC3uAHf3wDj5RLneJvJhrOQ@mail.gmail.comCAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
 <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default20111031181651.GF3466@redhat.com>
 <60592afd-97aa-4eaf-b86b-f6695d31c7f1@default
 20111031223717.GI3466@redhat.com>
In-Reply-To: <20111031223717.GI3466@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

> From: Andrea Arcangeli [mailto:aarcange@redhat.com]
> Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
>=20
> On Mon, Oct 31, 2011 at 01:58:39PM -0700, Dan Magenheimer wrote:
> > Hmmm... not sure I understand this one.  It IS copy-based
> > so is not zerocopy; the page of data is actually moving out
>=20
> copy-based is my main problem, being synchronous is no big deal I
> agree.
>=20
> I mean, I don't see why you have to make one copy before you start
> compressing and then you write to disk the output of the compression
> algorithm. To me it looks like this API forces on zcache one more copy
> than necessary.
>=20
> I can't see why this copy is necessary and why zcache isn't working on
> "struct page" on core kernel structures instead of moving the memory
> off to a memory object invisible to the core VM.

Do you see code doing this?  I am pretty sure zcache is
NOT doing an extra copy, it is compressing from the source
page.  And I am pretty sure Xen tmem is not doing the
extra copy either.

Seth and I had discussed ADDING the extra copy in zcache
to make the synchronous/irq-disabled time shorter for puts
and doing the compression as a separate thread, but I
don't think I have seen any patch to implement that.

So if this is true (no extra copy), are you happy?

Maybe you are saying that the extra copy would be necessary
in a KVM implementation of tmem?  If so, I haven't thought
about a KVM+tmem design enough to comment on that.

> > TRUE.  Tell me again why a vmexit/vmenter per 4K page is
> > "impossible"?  Again you are assuming (1) the CPU had some
>=20
> It's sure not impossible, it's just impossible we want it as it'd be
> too slow.

You are clearly speculating here.  Wouldn't it be nice to
try it and find out?

> > real work to do instead and (2) that vmexit/vmenter is horribly
>=20
> Sure the CPU has another 1000 VM to schedule. This is like saying
> virtio-blk isn't needed on desktop virt becauase the desktop isn't
> doing much I/O. Absurd argument, there are another 1000 desktops doing
> I/O at the same time of course.

But this is truly different, I think at least for the most common
cases, because the guest is essentially out of physical memory if it
is swapping.  And the vmexit/vmenter (I assume, I don't really
know KVM) gives the KVM scheduler the opportunity to schedule
another of those 1000 VMs if it wishes.

Also I'll venture to guess (without any proof) that the path through
the blkio subsystem to deal with any swap page and set up the disk
I/O is not much shorter than the cost of a vmexit/vmenter on
modern systems ;-)

Now we are both speculating. :-)

> > slow.  Even if vmexit/vmenter is thousands of cycles, it is still
> > orders of magnitude faster than a disk access.  And vmexit/vmenter
>=20
> I fully agree tmem is faster for Xen than no tmem. That's not the
> point, we don't need such an articulate hack hiding pages from the
> guest OS in order to share pagecache, our hypervisor is just a bit
> more powerful and has a function called file_read_actor that does what
> your tmem copy does...

Well either then KVM doesn't need frontswap at all and need
not be interfering with a patch that works fine for the
other users, or Sasha and Neo will implement it and find
that frontswap does (sometimes?) provide some benefits.

In either case, I'm not sure why you would be objecting
to merging frontswap.
=20
> > is about the same order of magnitude as page copy, and much
> > faster than compression/decompression, both of which still
> > result in a nice win.
>=20
> Saying it's a small overhead, is not like saying it is _needed_. Why
> not add a udelay(1) in it too? Sure it won't be noticeable.

Actually the current implementation of RAMster over LAN adds
quite a bit more than udelay(1).  But that's all still experimental.
It might be interesting to try adding udelay(1) in zcache
to see if there is any noticeable effect.

> > You are also assuming that frontswap puts/gets are highly
> > frequent.  By definition they are not, because they are
> > replacing single-page disk reads/writes due to swapping.
>=20
> They'll be as frequent as the highmem bounce buffers...

I don't understand.  Sorry, I really am ignorant of
highmem systems as I grew up on PA-RISC and IA-64.

> > That said, the API/ABI is very extensible, so if it were
> > proven that batching was sufficiently valuable, it could
> > be added later... but I don't see it as a showstopper.
> > Really do you?
>=20
> That's fine with me... but like ->writepages it'll take ages for the
> fs to switch from writepage to writepages. Considering this is a new
> API I don't think it's unreasonable to ask at least it to handle
> immediately zerocopy behavior. So showing the userland mapping to the
> tmem layer so it can avoid the copy and read from the userland
> address. Xen will badly choke if ever tries to do that, but zcache
> should be ok with that.
>=20
> Now there may be algorithms where the page must be stable, but others
> will be perfectly fine even if the page is changing under the
> compression, and in that case the page won't be discarded and it'll be
> marked dirty again. So even if a wrong data goes on disk, we'll
> rewrite later. I see no reason why there has always to be a copy
> before starting any compression/encryption as long as the algorithm
> will not crash its input data isn't changing under it.
>=20
> The ideal API would be to send down page pointers (and handling
> compound pages too), not to copy. Maybe with a flag where you can also
> specify offsets so you can send down partial pages too down to a byte
> granularity. The "copy input data before anything else can happen"
> looks flawed to me. It is not flawed for Xen because Xen has no
> knowledge of the guest "struct page" but her I'm talking about the
> not-virt usages.

Again, I think you are assuming things work differently than
I think they do.  I don't think there is an extra copy before
the compression.  And Xen isn't choking, nor is zcache.
(Note that the Xen tmem implementation, as all of Xen will be
soon, is 64-bit only... Seth recently fixed a bug keeping
zcache from working in 32-bit highmem systems, so I know
32-bit works for zcache.)

So if this is true (no extra copy), are you happy?

> > So, please, all the other parts necessary for tmem are
> > already in-tree, why all the resistance about frontswap?
>=20
> Well my comments are generic not specific to frontswap.

OK, but cleancache is already in-tree and open to any improvement
ideas you may have.  Frontswap is only using the existing ABI/API
that cleancache already uses.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
