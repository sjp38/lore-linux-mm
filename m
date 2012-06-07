Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 75E0D6B006E
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 17:20:55 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <06bd08dd-b8b4-4c7d-b8f3-f74f6270e51b@default>
Date: Thu, 7 Jun 2012 14:20:40 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 2/2] zram: clean up handle
References: <1338881031-19662-1-git-send-email-minchan@kernel.org>
 <1338881031-19662-2-git-send-email-minchan@kernel.org>
 <4FCEE4E0.6030707@vflare.org> <4FD015FE.7070906@kernel.org>
 <dfc7087d-6826-4429-8063-d47d05cd2d26@default> <4FD11A3C.801@vflare.org>
In-Reply-To: <4FD11A3C.801@vflare.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>
Cc: Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konrad Wilk <konrad.wilk@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>

> From: Nitin Gupta [mailto:ngupta@vflare.org]
> > Nitin, can zsmalloc allow full page allocation by assigning
> > an actual physical pageframe (which is what zram does now)?
> > Or will it allocate PAGE_SIZE bytes which zsmalloc will allocate
> > crossing a page boundary which, presumably, will have much worse
> > impact on page allocator availability when these pages are
> > "reclaimed" via your swap notify callback.
>=20
> zsmalloc does not add any object headers, so when allocating PAGE_SIZE
> you get a separate page from as if you did alloc_page(). So, it does not
> span page boundaries.
>=20
> > Though this may be rare across all workloads, it may turn out
> > to be very common for certain workloads (e.g. if the workload
> > has many dirty anonymous pages that are already compressed
> > by userland).
> >
> > It may not be worth cleaning up the code if it causes
> > performance issues with this case.
> >
> > And anyway can zsmalloc handle and identify to the caller pages
> > that are both compressed and "native" (uncompressed)?  It
> > certainly has to handle both if you remove ZRAM_UNCOMPRESSED
> > as compressing some pages actually results in more than
> > PAGE_SIZE bytes.  So you need to record somewhere that
> > this "compressed page" is special and that must somehow
> > be communicated to the caller of your "get" routine.
> >
> > (Just trying to save Minchan from removing all that code but
> > then needing to add it back again.)
>=20
> zsmalloc cannot identify compressed vs uncompressed pages. However, in
> zram, we can tell if the page is uncompressed using table[i]->size which
> is set to PAGE_SIZE for uncompressed pages.   Pages that compress to
> more than PAGE_SIZE (i.e. expand on compression) are stored
> as-is/uncompressed and thus will have size field set to PAGE_SIZE.
>=20
> Thus, we do not require ZRAM_UNCOMPRESSED flag when using zsmalloc for
> both compressed and uncompressed pages.

Good to know.  Nice work in zsmalloc and zram!

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
