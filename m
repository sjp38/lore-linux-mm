Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6F8FD6B024D
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 10:28:51 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <9e4cae1f-c102-43ea-9ba0-611c8ad68c9b@default>
Date: Tue, 20 Jul 2010 07:28:04 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 0/8] zcache: page cache compression support
References: <1279283870-18549-1-git-send-email-ngupta@vflare.org>
 <4f986c65-c17e-47d8-9c30-60cd17809cbb@default 4C45A9BA.1090903@vflare.org>
In-Reply-To: <4C45A9BA.1090903@vflare.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: ngupta@vflare.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Christoph Hellwig <hch@infradead.org>, Minchan Kim <minchan.kim@gmail.com>, Konrad Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> On 07/20/2010 01:27 AM, Dan Magenheimer wrote:
> >> We only keep pages that compress to PAGE_SIZE/2 or less. Compressed
> >> chunks are
> >> stored using xvmalloc memory allocator which is already being used
> by
> >> zram
> >> driver for the same purpose. Zero-filled pages are checked and no
> >> memory is
> >> allocated for them.
> >
> > I'm curious about this policy choice.  I can see why one
> > would want to ensure that the average page is compressed
> > to less than PAGE_SIZE/2, and preferably PAGE_SIZE/2
> > minus the overhead of the data structures necessary to
> > track the page.  And I see that this makes no difference
> > when the reclamation algorithm is random (as it is for
> > now).  But once there is some better reclamation logic,
> > I'd hope that this compression factor restriction would
> > be lifted and replaced with something much higher.  IIRC,
> > compression is much more expensive than decompression
> > so there's no CPU-overhead argument here either,
> > correct?
>=20
> Its true that we waste CPU cycles for every incompressible page
> encountered but still we can't keep such pages in RAM since this
> is what host wanted to reclaim and we can't help since compression
> failed. Compressed caching makes sense only when we keep highly
> compressible pages in RAM, regardless of reclaim scheme.
>=20
> Keeping (nearly) incompressible pages in RAM probably makes sense
> for Xen's case where cleancache provider runs *inside* a VM, sending
> pages to host. So, if VM is limited to say 512M and host has 64G RAM,
> caching guest pages, with or without compression, will help.

I agree that the use model is a bit different, but PAGE_SIZE/2
still seems like an unnecessarily strict threshold.  For
example, saving 3000 clean pages in 2000*PAGE_SIZE of RAM
still seems like a considerable space savings.  And as
long as the _average_ is less than some threshold, saving
a few slightly-less-than-ideally-compressible pages doesn't
seem like it would be a problem.  For example, IMHO, saving two
pages when one compresses to 2047 bytes and the other compresses
to 2049 bytes seems just as reasonable as saving two pages that
both compress to 2048 bytes.

Maybe the best solution is to make the threshold a sysfs
settable?  Or maybe BOTH the single-page threshold and
the average threshold as two different sysfs settables?
E.g. throw away a put page if either it compresses poorly
or adding it to the pool would push the average over.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
