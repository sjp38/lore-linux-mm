Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 207BA620002
	for <linux-mm@kvack.org>; Wed, 23 Dec 2009 12:26:17 -0500 (EST)
MIME-Version: 1.0
Message-ID: <ff435130-98a2-417c-8109-9dd029022a91@default>
Date: Wed, 23 Dec 2009 09:15:27 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: Tmem [PATCH 0/5] (Take 3): Transcendent memory
In-Reply-To: <d760cf2d0912222228y3284e455r16cdb2bfd2ecaa0e@mail.gmail.com>
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, dave.mccracken@oracle.com, sunil.mushran@oracle.com, Avi Kivity <avi@redhat.com>, Schwidefsky <schwidefsky@de.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, chris.mason@oracle.com, Pavel Machek <pavel@ucw.cz>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> As I mentioned, I really like the idea behind tmem. All I am proposing
> is that we should probably explore some alternatives to achive this using
> some existing infrastructure in kernel.

Hi Nitin --

Sorry if I sounded overly negative... too busy around the holidays.

I'm definitely OK with exploring alternatives.  I just think that
existing kernel mechanisms are very firmly rooted in the notion
that either the kernel owns the memory/cache or an asynchronous
device owns it.  Tmem falls somewhere in between and is very
carefully designed to maximize memory flexibility *outside* of
the kernel -- across all guests in a virtualized environment --
with minimal impact to the kernel, while still providing the
kernel with the ability to use -- but not own, directly address,
or control -- additional memory when conditions allow.  And
these conditions are not only completely invisible to the kernel,
but change frequently and asynchronously from the kernel,
unlike most external devices for which the kernel can "reserve"
space and use it asynchronously later.

Maybe ramzswap and FS-cache could be augmented to have similar
advantages in a virtualized environment, but I suspect they'd
end up with something very similar to tmem.  Since the objective
of both is to optimize memory that IS owned (used, directly
addressable, and controlled) by the kernel, they are entirely
complementary with tmem.

> Is synchronous working a *requirement* for tmem to work correctly?

Yes.  Asynchronous behavior would introduce lots of race
conditions between the hypervisor and kernel which would
greatly increase complexity and reduce performance.  And
tmem then essentially becomes an I/O device, which defeats
its purpose, especially compared to a fast SSD.

> Swapping to hypervisor is mainly useful to overcome
> 'static partitioning' problem you mentioned in article:
> http://oss.oracle.com/projects/tmem/
> ...such 'para-swap' can shrink/expand outside of VM constraints.

Frontswap is very different than "hypervisor swapping" as what's
done by VMware as a side-effect of transparent page-sharing.  With
frontswap, the kernel still decides which pages are swapped out.
If frontswap says there is space, the swap goes "fast" to tmem;
if not, the kernel writes it to its own swapdisk.  So there's
no "double paging" or random page selection/swapping.  On
the downside, kernels must have real swap configured and,
to avoid DoS issues, frontswap is limited by the same constraint
as ballooning (ie. can NOT expand outside of VM constraints).

Thanks,
Dan

P.S.  If you want to look at implementing FS-cache or ramzswap
on top of tmem, I'd be happy to help, but I'll bet your concern:

> we might later encounter some hidder/dangerous problems :)

will prove to be correct.

> -----Original Message-----
> From: Nitin Gupta [mailto:ngupta@vflare.org]
> Sent: Tuesday, December 22, 2009 11:28 PM
> To: Dan Magenheimer
> Cc: Nick Piggin; Andrew Morton; jeremy@goop.org;
> xen-devel@lists.xensource.com; tmem-devel@oss.oracle.com;=20
> Rusty Russell;
> Rik van Riel; Dave Mccracken; Sunil Mushran; Avi Kivity; Schwidefsky;
> Balbir Singh; Marcelo Tosatti; Alan Cox; Chris Mason; Pavel Machek;
> linux-mm; linux-kernel
> Subject: Re: Tmem [PATCH 0/5] (Take 3): Transcendent memory
>=20
>=20
> Hi Dan,
>=20
> (mail to Rusty [at] rcsinet15.oracle.com was failing, so I removed
> this address from CC list).
>=20
> On Tue, Dec 22, 2009 at 5:16 AM, Dan Magenheimer
> <dan.magenheimer@oracle.com> wrote:
> >> From: Nitin Gupta [mailto:ngupta@vflare.org]
>=20
> >
> >> I think 'frontswap' part seriously overlaps the functionality
> >> provided by 'ramzswap'
> >
> > Could be, but I suspect there's a subtle difference.
> > A key part of the tmem frontswap api is that any
> > "put" at any time can be rejected.  There's no way
> > for the kernel to know a priori whether the put
> > will be rejected or not, and the kernel must be able
> > to react by writing the page to a "true" swap device
> > and must keep track of which pages were put
> > to tmem frontswap and which were written to disk.
> > As a result, tmem frontswap cannot be configured or
> > used as a true swap "device".
> >
> > This is critical to acheive the flexibility you
> > commented above that you like.  Only the hypervisor
> > knows if a free page is available "now" because
> > it is flexibly managing tmem requests from multiple
> > guest kernels.
> >
>=20
> ramzswap devices can easily track which pages it sent
> to hypervisor, which pages are in backing swap (physical) disk
> and which are in (compressed) memory. Its simply a matter
> of adding some more flags. Latter two are already done in this
> driver.
>=20
> So, to gain flexibility of frontswap, we can have hypervisor
> send the driver a callback whenever it wants to discard swap
> pages under its domain. If you want to avoid even this callback,
> then kernel will have to keep a copy within guest, which I think
> defeats the whole purpose of swapping to hypervisor. Such
> "ephemeral" pools should be used only for clean fs cache and
> not for swap.
>=20
> Swapping to hypervisor is mainly useful to overcome
> 'static partitioning' problem you mentioned in article:
> http://oss.oracle.com/projects/tmem/
> ...such 'para-swap' can shrink/expand outside of VM constraints.
>=20
>=20
> >
> >>> Cleancache is
> >> > "ephemeral" so whether a page is kept in cleancache
> >> (between the "put" and
> >> > the "get") is dependent on a number of factors that are=20
> invisible to
> >> > the kernel.
> >>
> >> Just an idea: as an alternate approach, we can create an
> >> 'in-memory compressed
> >> storage' backend for FS-Cache. This way, all filesystems
> >> modified to use
> >> fs-cache can benefit from this backend. To make it
> >> virtualization friendly like
> >> tmem, we can again provide (per-cache?) option to allocate
> >> from hypervisor  i.e.
> >> tmem_{put,get}_page() or use [compress]+alloc natively.
> >
> > I looked at FS-Cache and cachefiles and thought I understood
> > that it is not restricted to clean pages only, thus
> > not a good match for tmem cleancache.
> >
> > Again, if I'm wrong (or if it is easy to tell FS-Cache that
> > pages may "disappear" underneath it), let me know.
> >
>=20
> fs-cache backend can keep 'dirty' pages within guest and forward
> clean pages to hypervisor. These clean pages can be added to
> ephemeral pools which can be reclaimed at any time by hypervisor.
> BTW, I have not yet started work on any such fs-cache backend, so
> we might later encounter some hidder/dangerous problems :)
>=20
>=20
> > BTW, pages put to tmem (both frontswap and cleancache) can
> > be optionally compressed.
> >
>=20
> If ramzswap is extended for this virtualization case, then enforcing
> compression might not be good. We can then throw out pages to hvisor
> even before compression stage.   All such changes to ramzswap are IMHO
> pretty straight forward to do.
>=20
>=20
> >> For guest<-->hypervisor interface, maybe we can use virtio=20
> so that all
> >> hypervisors can benefit? Not quite sure about this one.
> >
> > I'm not very familiar with virtio, but the existence of "I/O"
> > in the name concerns me because tmem is entirely synchronous.
> >
>=20
> Is synchronous working a *requirement* for tmem to work correctly?
>=20
>=20
> > Also, tmem is well-layered so very little work needs to be
> > done on the Linux side for other hypervisors to benefit.
> > Of course these other hypervisors would need to implement
> > the hypervisor-side of tmem as well, but there is a well-defined
> > API to guide other hypervisor-side implementations... and the
> > opensource tmem code in Xen has a clear split between the
> > hypervisor-dependent and hypervisor-independent code, which
> > should simplify implementation for other opensource hypervisors.
> >
>=20
> As I mentioned, I really like the idea behind tmem. All I am proposing
> is that we should probably explore some alternatives to=20
> achive this using
> some existing infrastructure in kernel. I also don't have=20
> experience working
> on virtio[1] or virtual-bus[2] but I have the feeling that once guest
> to hvisor channels are created, both ramzswap extension and=20
> fs-cache backend
> can share the same code.
>=20
> [1] virtio: http://portal.acm.org/citation.cfm?id=3D1400097.1400108
> [2] virtual-bus:=20
http://developer.novell.com/wiki/index.php/Virtual-bus


Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
