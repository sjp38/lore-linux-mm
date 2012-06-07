Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 12A906B006E
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 16:47:57 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <dfc7087d-6826-4429-8063-d47d05cd2d26@default>
Date: Thu, 7 Jun 2012 13:47:40 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 2/2] zram: clean up handle
References: <1338881031-19662-1-git-send-email-minchan@kernel.org>
 <1338881031-19662-2-git-send-email-minchan@kernel.org>
 <4FCEE4E0.6030707@vflare.org> <4FD015FE.7070906@kernel.org>
In-Reply-To: <4FD015FE.7070906@kernel.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konrad Wilk <konrad.wilk@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>

> From: Minchan Kim [mailto:minchan@kernel.org]
> Subject: Re: [PATCH 2/2] zram: clean up handle
>=20
> On 06/06/2012 02:04 PM, Nitin Gupta wrote:
>=20
> > On 06/05/2012 12:23 AM, Minchan Kim wrote:
> >
> >> zram's handle variable can store handle of zsmalloc in case of
> >> compressing efficiently. Otherwise, it stores point of page descriptor=
.
> >> This patch clean up the mess by union struct.
> >>
> >> changelog
> >>   * from v1
> >> =09- none(new add in v2)
> >>
> >> Cc: Nitin Gupta <ngupta@vflare.org>
> >> Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> >> Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> >> Signed-off-by: Minchan Kim <minchan@kernel.org>
> >> ---
> >>  drivers/staging/zram/zram_drv.c |   77 ++++++++++++++++++++----------=
---------
> >>  drivers/staging/zram/zram_drv.h |    5 ++-
> >>  2 files changed, 44 insertions(+), 38 deletions(-)
> >
> > I think page vs handle distinction was added since xvmalloc could not
> > handle full page allocation. Now that zsmalloc allows full page
>=20
> I see. I didn't know that because I'm blind on xvmalloc.
>=20
> > allocation, we can just use it for both cases. This would also allow
> > removing the ZRAM_UNCOMPRESSED flag. The only downside will be slightly
> > slower code path for full page allocation but this event is anyways
> > supposed to be rare, so should be fine.
>=20
> Fair enough.
> It can remove many code of zram.
> Okay. Will look into that.

Nitin, can zsmalloc allow full page allocation by assigning
an actual physical pageframe (which is what zram does now)?
Or will it allocate PAGE_SIZE bytes which zsmalloc will allocate
crossing a page boundary which, presumably, will have much worse
impact on page allocator availability when these pages are
"reclaimed" via your swap notify callback.

Though this may be rare across all workloads, it may turn out
to be very common for certain workloads (e.g. if the workload
has many dirty anonymous pages that are already compressed
by userland).

It may not be worth cleaning up the code if it causes
performance issues with this case.

And anyway can zsmalloc handle and identify to the caller pages
that are both compressed and "native" (uncompressed)?  It
certainly has to handle both if you remove ZRAM_UNCOMPRESSED
as compressing some pages actually results in more than
PAGE_SIZE bytes.  So you need to record somewhere that
this "compressed page" is special and that must somehow
be communicated to the caller of your "get" routine.

(Just trying to save Minchan from removing all that code but
then needing to add it back again.)

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
