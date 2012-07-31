Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 511266B0070
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 17:14:00 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <b9bee363-321e-409a-bc8e-65ffed8a1dc5@default>
Date: Tue, 31 Jul 2012 14:13:40 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC/PATCH] zcache/ramster rewrite and promotion
References: <c31aaed4-9d50-4cdf-b794-367fc5850483@default>
 <CAOJsxLEhW=b3En737d5751xufW2BLehPc2ZGGG1NEtRVSo3=jg@mail.gmail.com>
In-Reply-To: <CAOJsxLEhW=b3En737d5751xufW2BLehPc2ZGGG1NEtRVSo3=jg@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> From: Pekka Enberg [mailto:penberg@kernel.org]
> Sent: Tuesday, July 31, 2012 2:54 PM
>=20
> On Tue, Jul 31, 2012 at 11:18 PM, Dan Magenheimer
> <dan.magenheimer@oracle.com> wrote:
> > diffstat vs 3.5:
> >  drivers/staging/ramster/Kconfig       |    2
> >  drivers/staging/ramster/Makefile      |    2
> >  drivers/staging/zcache/Kconfig        |    2
> >  drivers/staging/zcache/Makefile       |    2
> >  mm/Kconfig                            |    2
> >  mm/Makefile                           |    4
> >  mm/tmem/Kconfig                       |   33
> >  mm/tmem/Makefile                      |    5
> >  mm/tmem/tmem.c                        |  894 +++++++++++++
> >  mm/tmem/tmem.h                        |  259 +++
> >  mm/tmem/zbud.c                        | 1060 +++++++++++++++
> >  mm/tmem/zbud.h                        |   33
> >  mm/tmem/zcache-main.c                 | 1686 +++++++++++++++++++++++++
> >  mm/tmem/zcache.h                      |   53
> >  mm/tmem/ramster.h                     |   59
> >  mm/tmem/ramster/heartbeat.c           |  462 ++++++
> >  mm/tmem/ramster/heartbeat.h           |   87 +
> >  mm/tmem/ramster/masklog.c             |  155 ++
> >  mm/tmem/ramster/masklog.h             |  220 +++
> >  mm/tmem/ramster/nodemanager.c         |  995 +++++++++++++++
> >  mm/tmem/ramster/nodemanager.h         |   88 +
> >  mm/tmem/ramster/r2net.c               |  414 ++++++
> >  mm/tmem/ramster/ramster.c             |  985 ++++++++++++++
> >  mm/tmem/ramster/ramster.h             |  161 ++
> >  mm/tmem/ramster/ramster_nodemanager.h |   39
> >  mm/tmem/ramster/tcp.c                 | 2253 +++++++++++++++++++++++++=
+++++++++
> >  mm/tmem/ramster/tcp.h                 |  159 ++
> >  mm/tmem/ramster/tcp_internal.h        |  248 +++
> > 28 files changed, 10358 insertions(+), 4 deletions(-)
>=20
> So it's basically this commit, right?
>=20
> https://oss.oracle.com/git/djm/tmem.git/?p=3Ddjm/tmem.git;a=3Dcommitdiff;=
h=3D22844fe3f52d912247212408294be33
> 0a867937c
>=20
> Why on earth would you want to move that under the mm directory?

Hi Pekka --

Thanks for your reply and question.

MM means "memory management" and zcache manages physical memory
to allow more pages of data to be stored in RAM.  So it seems a
logical place.  It's not a block driver, or a network driver,
or a device driver, or a filesystem... do you have a different
location in the kernel in mind?

Zcache does it a bit differently than all the other parts of mm
because it needs to; because all the other parts of mm try to
maximize the amount of physical memory that is directly addressable
by threads but one can't directly address pages that have been compressed.
So zcache uses the transcendent memory approach (via cleancache
and frontswap) to compress/decompress clean pagecache pages and
swap pages "on demand".  The tmem design also nicely handles
both the fact that the degree of compression is unpredictable and
the fact that the fraction of fixed total RAM used for compressed
pages vs "normal uncompressed mm" pages needs to be very dynamic.

Ramster does the same thing but manages it peer-to-peer across
multiple systems using kernel sockets.  One could argue that
the dependency on sockets makes it more of a driver than "mm"
but ramster is "memory management" too, just a bit more exotic.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
