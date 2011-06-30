Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id AACA46B0092
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 22:31:47 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <f6415652-5925-4aad-b8be-900ce3afd902@default>
Date: Wed, 29 Jun 2011 19:31:23 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: frontswap/zcache: xvmalloc discussion
References: <4E023F61.8080904@linux.vnet.ibm.com>
 <0a3a5959-5d8f-4f62-a879-34266922c59f@default
 4E03B75A.9040203@linux.vnet.ibm.com
 89b9d94d-27d1-4f51-ab7e-b2210b6b0eb5@default>
In-Reply-To: <89b9d94d-27d1-4f51-ab7e-b2210b6b0eb5@default>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Brian King <brking@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@suse.de>, Dave Hansen <dave@sr71.net>

> > > One neat feature of frontswap (and the underlying Transcendent
> > > Memory definition) is that ANY PUT may be rejected**.  So zcache
> > > could keep track of the distribution of "zsize" and if the number
> > > of pages with zsize>PAGE_SIZE/2 greatly exceeds the number of pages
> > > with "complementary zsize", the frontswap code in zcache can reject
> > > the larger pages until balance/sanity is restored.
> > >
> > > Might that help?
> >
> > We could do that, but I imagine that would let a lot of pages through
> > on most workloads.  Ideally, I'd like to find a solution that would
> > capture and (efficiently) store pages that compressed to up to 80% of
> > their original size.
>=20
> After thinking about this a bit, I have to disagree.  For workloads
> where the vast majority of pages have zsize>PAGE_SIZE/2, this would
> let a lot of pages through.  So if you are correct that LZO
> is poor at compression and a large majority of pages are in
> this category, some page-crossing scheme is necessary.  However,
> that isn't what I've seen... the zsize of many swap pages is
> quite small.
>=20
> So before commencing on a major compression rewrite, it might
> be a good idea to measure distribution of zsize for swap pages
> on a large variety of workloads.  This could probably be done
> by adding a code snippet in the swap path of a normal (non-zcache)
> kernel.  And if the distribution is bad, replacing LZO with a
> higher-compression-but-slower algorithm might be the best answer,
> since zcache is replacing VERY slow swap-device reads/writes with
> reasonably fast compression/decompression.  I certainly think
> that an algorithm approaching an average 50% compression ratio
> should be the goal.

FWIW, I've measured the distribution of zsize (pages compressed
with frontswap) on my favorite workload (kernel "make -j2" on
mem=3D512M to force lots of swapping) and the mean is small, close
to 1K (PAGE_SIZE/4).  I've added some sysfs shows for both
the current and cumulative distribution (0-63 bytes, 64-127
bytes, ..., 4032-4095 bytes) for the next update.

I tried your program on the text of Moby Dick and the mean
was still under 1500 bytes ((3*PAGE_SIZE)/8) with a good
broad distribution for zsize.  I tried your program also on
gzip'ed Moby Dick and zcache correctly rejects most of the
pages as uncompressible and does fine on other swapped pages.

So I can't reproduce what you are seeing.  Somehow you
must create and swap a set of pages with a zsize distribution
almost entirely between PAGE_SIZE/2 and (PAGE_SIZE*7)/8.
How did you do that?

FYI, I also added a sysfs settable for zv_max_page_size...
if zsize exceeds it, the page is rejected.  It defaults to
(PAGE_SIZE*7)/8, which was the non-settable hardwired
value before.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
