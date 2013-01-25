Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 81CB06B0005
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 15:47:51 -0500 (EST)
MIME-Version: 1.0
Message-ID: <54da1c87-93f9-4643-8f71-597c1ff30e33@default>
Date: Fri, 25 Jan 2013 12:47:44 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 2/2] staging: zcache: optional support for zsmalloc as
 alternate allocator
References: <1358977591-24485-1-git-send-email-dan.magenheimer@oracle.com>
 <1358977591-24485-2-git-send-email-dan.magenheimer@oracle.com>
 <20130125192617.GA26634@kroah.com>
In-Reply-To: <20130125192617.GA26634@kroah.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, Konrad Wilk <konrad.wilk@oracle.com>, sjenning@linux.vnet.ibm.com, minchan@kernel.org

> From: Greg KH [mailto:gregkh@linuxfoundation.org]
> Subject: Re: [PATCH 2/2] staging: zcache: optional support for zsmalloc a=
s alternate allocator
>=20
> On Wed, Jan 23, 2013 at 01:46:31PM -0800, Dan Magenheimer wrote:
> > "New" zcache uses zbud for all sub-page allocation which is more flexib=
le but
> > results in lower density.  "Old" zcache supported zsmalloc for frontswa=
p
> > pages.  Add zsmalloc to "new" zcache as a compile-time and run-time opt=
ion
> > for backwards compatibility in case any users wants to use zcache with
> > highest possible density.
> >
> > Note that most of the zsmalloc stats in old zcache are not included her=
e
> > because old zcache used sysfs and new zcache has converted to debugfs.
> > These stats may be added later.
> >
> > Note also that ramster is incompatible with zsmalloc as the two use
> > the least significant bits in a pampd differently.
> >
> > Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> > ---
> >  drivers/staging/zcache/Kconfig       |   11 ++
> >  drivers/staging/zcache/zcache-main.c |  210 ++++++++++++++++++++++++++=
++++++--
> >  drivers/staging/zcache/zcache.h      |    3 +
> >  3 files changed, 215 insertions(+), 9 deletions(-)
> >
> > diff --git a/drivers/staging/zcache/Kconfig b/drivers/staging/zcache/Kc=
onfig
> > index c1dbd04..116f8d5 100644
> > --- a/drivers/staging/zcache/Kconfig
> > +++ b/drivers/staging/zcache/Kconfig
> > @@ -10,6 +10,17 @@ config ZCACHE
> >  =09  memory to store clean page cache pages and swap in RAM,
> >  =09  providing a noticeable reduction in disk I/O.
> >
> > +config ZCACHE_ZSMALLOC
> > +=09bool "Allow use of zsmalloc allocator for compression of swap pages=
"
> > +=09depends on ZSMALLOC=3Dy && !RAMSTER
> > +=09default n
> > +=09help
> > +=09  Zsmalloc is a much more efficient allocator for compresssed
> > +=09  pages but currently has some design deficiencies in that it
> > +=09  does not support reclaim nor compaction.  Select this if
> > +=09  you are certain your workload will fit or has mostly short
> > +=09  running processes.  Zsmalloc is incompatible with RAMster.
>=20
> How can anyone be "certain"?
>=20
>=20
> > --- a/drivers/staging/zcache/zcache-main.c
> > +++ b/drivers/staging/zcache/zcache-main.c
> > @@ -26,6 +26,12 @@
> >  #include <linux/cleancache.h>
> >  #include <linux/frontswap.h>
> >  #include "tmem.h"
> > +#ifdef CONFIG_ZCACHE_ZSMALLOC
> > +#include "../zsmalloc/zsmalloc.h"
>=20
> Don't #ifdef .h files in .c files.
>=20
> > +static int zsmalloc_enabled;
> > +#else
> > +#define zsmalloc_enabled 0
> > +#endif
>=20
> That should have been your only ifdef in this .c file, all of the ones
> you have after this should not be needed, so I can't take this patch,
> sorry.

Yep.  Sorry, I was just trying to refresh this from when
I posted the proof-of-concept last summer.  I should have
spent more time cleaning it up.  Will be away for
a few days so will try to repost in a week or two,
hopefully not too late for this cycle.

Sorry for the noise.
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
