Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 44C3F620001
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 18:47:23 -0500 (EST)
MIME-Version: 1.0
Message-ID: <022609e4-9f30-4e8b-b26b-023cf58adf21@default>
Date: Mon, 21 Dec 2009 15:46:28 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: Tmem [PATCH 0/5] (Take 3): Transcendent memory
In-Reply-To: <4B2F7C41.9020106@vflare.org>
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: ngupta@vflare.org
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, dave.mccracken@oracle.com, Rusty@rcsinet15.oracle.com, sunil.mushran@oracle.com, Avi Kivity <avi@redhat.com>, Schwidefsky <schwidefsky@de.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, chris.mason@oracle.com, Pavel Machek <pavel@ucw.cz>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> From: Nitin Gupta [mailto:ngupta@vflare.org]

> Hi Dan,

Hi Nitin --

Thanks for your review!

> (I'm not sure if gmane.org interface sends mail to everyone=20
> in CC list, so
> sending again. Sorry if you are getting duplicate mail).

FWIW, I only got this one copy (at least so far)!
=20
> I really like the idea of allocating cache memory from=20
> hypervisor directly. This
> is much more flexible than assigning fixed size memory to guests.

Thanks!

> I think 'frontswap' part seriously overlaps the functionality=20
> provided by 'ramzswap'

Could be, but I suspect there's a subtle difference.
A key part of the tmem frontswap api is that any
"put" at any time can be rejected.  There's no way
for the kernel to know a priori whether the put
will be rejected or not, and the kernel must be able
to react by writing the page to a "true" swap device
and must keep track of which pages were put
to tmem frontswap and which were written to disk.
As a result, tmem frontswap cannot be configured or
used as a true swap "device".

This is critical to acheive the flexibility you
commented above that you like.  Only the hypervisor
knows if a free page is available "now" because
it is flexibly managing tmem requests from multiple
guest kernels.

If my understanding of ramzswap is incorrect or you
have some clever solution that I misunderstood,
please let me know.

>> Cleancache is
> > "ephemeral" so whether a page is kept in cleancache=20
> (between the "put" and
> > the "get") is dependent on a number of factors that are invisible to
> > the kernel.
>=20
> Just an idea: as an alternate approach, we can create an=20
> 'in-memory compressed
> storage' backend for FS-Cache. This way, all filesystems=20
> modified to use
> fs-cache can benefit from this backend. To make it=20
> virtualization friendly like
> tmem, we can again provide (per-cache?) option to allocate=20
> from hypervisor  i.e.
> tmem_{put,get}_page() or use [compress]+alloc natively.

I looked at FS-Cache and cachefiles and thought I understood
that it is not restricted to clean pages only, thus
not a good match for tmem cleancache.

Again, if I'm wrong (or if it is easy to tell FS-Cache that
pages may "disappear" underneath it), let me know.

BTW, pages put to tmem (both frontswap and cleancache) can
be optionally compressed.

> For guest<-->hypervisor interface, maybe we can use virtio so that all
> hypervisors can benefit? Not quite sure about this one.

I'm not very familiar with virtio, but the existence of "I/O"
in the name concerns me because tmem is entirely synchronous.

Also, tmem is well-layered so very little work needs to be
done on the Linux side for other hypervisors to benefit.
Of course these other hypervisors would need to implement
the hypervisor-side of tmem as well, but there is a well-defined
API to guide other hypervisor-side implementations... and the
opensource tmem code in Xen has a clear split between the
hypervisor-dependent and hypervisor-independent code, which
should simplify implementation for other opensource hypervisors.

I realize in "Take 3" I didn't provide the URL for more information:
http://oss.oracle.com/projects/tmem

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
