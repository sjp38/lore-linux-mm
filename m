Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 62CB0900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 12:38:46 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <0a3a5959-5d8f-4f62-a879-34266922c59f@default>
Date: Thu, 23 Jun 2011 09:38:29 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: frontswap/zcache: xvmalloc discussion
References: <4E023F61.8080904@linux.vnet.ibm.com>
In-Reply-To: <4E023F61.8080904@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Brian King <brking@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@suse.de>

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Cc: Dan Magenheimer; Nitin Gupta; Robert Jennings; Brian King; Greg Kroah=
-Hartman
> Subject: frontswap/zcache: xvmalloc discussion
>=20
> Dan, Nitin,

Hi Seth --

Thanks for your interest in frontswap and zcache!

> I have been experimenting with the frontswap v4 patches and the latest
> zcache in the mainline drivers/staging.  There is a particular issue I'm
> seeing when using pages of different compressibilities.
>=20
> When the pages compress to less than PAGE_SIZE/2, I get good compression
> and little external fragmentation in the xvmalloc pool.  However, when
> the pages have a compressed size greater than PAGE_SIZE/2, it is a very
> different story.  Basically, because xvmalloc allocations can't span
> multiple pool pages, grow_pool() is called on each allocation, reducing
> the effective compression (total_pages_in_frontswap /
> total_pages_in_xvmalloc_pool) to 0 and drastically increasing external
> fragmentation to up to 50%.
>=20
> The likelihood that the size of a compressed page is greater than
> PAGE_SIZE/2 is high, considering that lzo1x-1 sacrifices compressibility
> for speed.  In my experiments, pages of English text only compressed to
> 75% of their original size with 1zo1x-1.

Wow, I'm surprised to hear that.  I suppose it is very workload
dependent, but I agree that consistently poor compression can create
issues for frontswap.

> In order to calculate the effective compression of frontswap, you need
> the number of pages stored by frontswap, provided by frontswap's
> curr_pages sysfs attribute, and the number of pages in the xvmalloc
> pool.  There isn't a sysfs attribute for this, so I made a patch that
> creates a new zv_pool_pages_count attribute for zcache that provides
> this value (patch is in a follow-up message).  I have also included my
> simple test program at the end of this email.  It just allocates and
> stores random pages of from a text file (in my case, a text file of Moby
> Dick).
>=20
> The real problem here is compressing pages of size x and storing them in
> a pool that has "chunks", if you will, also of size x, where allocations
> can't span multiple chunks.  Ideally, I'd like to address this issue by
> expanding the size of the xvmalloc pool chunks from one page to four
> pages (I can explain why four is a good number, just didn't want to make
> this note too long).

Nitin is the expert on compression and xvmalloc... I mostly built on top
of his earlier work... so I will wait for him to comment on compression
and xvmalloc issues.

BUT... I'd be concerned with increasing the pool chunk, at least without
a fallback.  When memory is constrained, finding chunks in the kernel
of even two consecutive pages might be a challenge, let alone four.
Since frontswap only is invoked if swapping is occurring, memory
is definitely already constrained.

If it is possible to modify xvmalloc (or possibly the pool creation
calls from zcache) to juggle multiple pools, one with chunkorder=3D=3D2,
one with chunkorder=3D=3D1, and one with chunkorder=3D0, with a fallback
sequence if a higher chunkorder is not available, might that be
helpful?  Still I worry that the same problems might occur because
the higher chunkorders might never be available after some time
passes.

> After a little playing around, I've found this isn't entirely trivial to
> do because of the memory mapping implications; more specifically the use
> of kmap/kunamp in the xvmalloc and zcache layers.  I've looked into
> using vmap to map multiple pages into a linear address space, but it
> seems like there is a lot of memory overhead in doing that.
>=20
> Do you have any feedback on this issue or suggestion solution?

One neat feature of frontswap (and the underlying Transcendent
Memory definition) is that ANY PUT may be rejected**.  So zcache
could keep track of the distribution of "zsize" and if the number
of pages with zsize>PAGE_SIZE/2 greatly exceeds the number of pages
with "complementary zsize", the frontswap code in zcache can reject
the larger pages until balance/sanity is restored.

Might that help?  If so, maybe your new sysfs value could be
replaced with the ratio (zv_pool_pages_count/frontswap_curr_pages)
and this could be _writeable_ to allow the above policy target to
be modified at runtime.   Even better, the fraction could be
represented by number-of-bytes ("target_zsize"), which could default
to something like (3*PAGE_SIZE)/4... if the ratio above
exceeds target_zsize and the zsize of the page-being-put exceeds
target_zsize, then the put is rejected.

Thanks,
Dan

** The "put" shouldn't actually be rejected outright... it should
be converted to a "flush" so that, if a previous put was
performed for the matching handle, the space can be reclaimed.
(Let me know if you need more explanation of this.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
