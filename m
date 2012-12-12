Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id BE57E6B002B
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 18:46:41 -0500 (EST)
MIME-Version: 1.0
Message-ID: <dece5896-0c47-4f5e-8b41-b93e8794e6f9@default>
Date: Wed, 12 Dec 2012 15:46:27 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 0/8] zswap: compressed swap caching
References: <1355262966-15281-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <CAA25o9SYYmbq9oJaEKxuBoXSXaeku4=L7qK-1wXABTAsKCjrtQ@mail.gmail.com>
In-Reply-To: <CAA25o9SYYmbq9oJaEKxuBoXSXaeku4=L7qK-1wXABTAsKCjrtQ@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

> From: Luigi Semenzato [mailto:semenzato@google.com]
> Subject: Re: [PATCH 0/8] zswap: compressed swap caching

Hi Luigi --

> Just a couple of questions and comments as a user.  I apologize if
> this is the wrong time to make them, feel free to ignore them.

IMHO now is a great time to address this as IMHO it doesn't
make much sense for MM developers to do detailed code-review
on any of these until the broader objectives of in-kernel
compression and the advantages/disadvantages of each are
thoroughly understood.  There may be room for more than one
solution, or may not be.

But... for me this is not so great a time... it's a rather
inconvenient time as some personal constraints over the
next few weeks will result in sporadic ability for me
to regularly participate in an email discussion.

Ultimately, this may be a great major topic for the next
MM Summit, though hopefully progress can be made before then.

And rather than hijack Seth's thread, it might be better
to start a new thread. :-)

> 1. It's becoming difficult to understand how zcache, zcache2, zram,
> and now zswap, interact and/or overlap with each other.  For instance,
> I am examining the possibility of using zcache2 and zram in parallel.
> Should I also/instead consider zswap, using a plain RAM disk as the
> swap device?

Yes, it seems to be a thousand flowers blooming!

I know Minchan earlier this year had talked about working
on a good comparison of the in-kernel compression options.
It might be good for Minchan or you or some other neutral
party to attempt that, with input from the developers of
the various options.

> 2. Zswap looks like a two-stage swap device, with one stage being
> compressed memory.  I don't know if and where the abstraction breaks,
> and what the implementation issues would be, but I would find it
> easier to view and configure this as a two-stage swap, where one stage
> is chosen as zcache (but could be something else).

Zcache does (attempts to do) this also.  After very preliminary review,
zswap's two-stage solution may be one step further/better, though its
not clear to me if there are new races possible.

> 3. As far as I can tell, none of these compressors has a good way of
> balancing the amount of memory dedicated to compression against the
> pressure on the rest of the memory.  On both zram and zswap, we set a
> max size for the compressed data.  That size determines how much RAM
> is left for the working set, which should remain uncompressed.  But
> the size of the working set can vary significantly with the load.  If
> we choose the size based on a worst-case working set, we'll be
> underutilizing RAM on average.  If we choose it smaller than that, the
> worst-case working set will cause excessive CPU use and thrashing.

Zcache attempts to take a bigger picture, dynamically balancing both
compressed pagecache pages and compressed swap pages against other
system memory pressure (and, with ramster, across multiple machines,
and with Xen tmem, across multiple Xen guests).

Zram (for swap) and zswap are much more focused on compressing swap
pages in isolation with only a fixed upper size bound.  Thus they
have the advantage of simplicity.

But let's leave the gory detail for the new thread.

> Thanks!
>=20
> P.S. For us, the situation in case 3 is improved from having
> centralized control over all (relevant) processes.  If we can detect
> thrashing, we can activate the tab discarder and decrease the load.

Yes, your use model is a bit different than most Linux systems...
because of your tab discarder, the equivalent of OOMs are OK as
long as you can predict them, whereas OOms are anathema on most systems.
It's not clear to me whether your use model and the more generic
Linux model will require different in-kernel compression
solutions or whether the same solutions will serve both use models.

> On Tue, Dec 11, 2012 at 1:55 PM, Seth Jennings
> <sjenning@linux.vnet.ibm.com> wrote:
> > Zswap Overview:
> >
> > Zswap is a lightweight compressed cache for swap pages. It takes
> > pages that are in the process of being swapped out and attempts to
> > compress them into a dynamically allocated RAM-based memory pool.
> > If this process is successful, the writeback to the swap device is
> > deferred and, in many cases, avoided completely.  This results in
> > a significant I/O reduction and performance gains for systems that
> > are swapping. The results of a kernel building benchmark indicate a
> > runtime reduction of 53% and an I/O reduction 76% with zswap vs normal
> > swapping with a kernel build under heavy memory pressure (see
> > Performance section for more).
> >
> > Patchset Structure:
> > 1-4: improvements/changes to zsmalloc
> > 5:   add atomic_t get/set to debugfs
> > 6:   promote zsmalloc to /lib
> > 7-8: add zswap and documentation
> >
> > Targeting this for linux-next.
> >
> > Rationale:
> >
> > Zswap provides compressed swap caching that basically trades CPU cycles
> > for reduced swap I/O.  This trade-off can result in a significant
> > performance improvement as reads to/writes from to the compressed
> > cache almost always faster that reading from a swap device
> > which incurs the latency of an asynchronous block I/O read.
> >
> > Some potential benefits:
> > * Desktop/laptop users with limited RAM capacities can mitigate the
> >     performance impact of swapping.
> > * Overcommitted guests that share a common I/O resource can
> >     dramatically reduce their swap I/O pressure, avoiding heavy
> >     handed I/O throttling by the hypervisor.  This allows more work
> >     to get done with less impact to the guest workload and guests
> >     sharing the I/O subsystem
> > * Users with SSDs as swap devices can extend the life of the device by
> >     drastically reducing life-shortening writes.
> >
> > Zswap evicts pages from compressed cache on an LRU basis to the backing
> > swap device when the compress pool reaches it size limit or the pool is
> > unable to obtain additional pages from the buddy allocator.  This
> > requirement had been identified in prior community discussions.
> >
> > Compressed swap is also provided in zcache, along with page cache
> > compression and RAM clustering through RAMSter. Zswap seeks to deliver
> > the benefit of swap  compression to users in a discrete function.
> > This design decision is akin to Unix design philosophy of doing one
> > thing well, it leaves file cache compression and other features
> > for separate code.
> >
> > Design:
> >
> > Zswap receives pages for compression through the Frontswap API and
> > is able to evict pages from its own compressed pool on an LRU basis
> > and write them back to the backing swap device in the case that the
> > compressed pool is full or unable to secure additional pages from
> > the buddy allocator.
> >
> > Zswap makes use of zsmalloc for the managing the compressed memory
> > pool.  This is because zsmalloc is specifically designed to minimize
> > fragmentation on large (> PAGE_SIZE/2) allocation sizes.  Each
> > allocation in zsmalloc is not directly accessible by address.
> > Rather, a handle is return by the allocation routine and that handle
> > must be mapped before being accessed.  The compressed memory pool grows
> > on demand and shrinks as compressed pages are freed.  The pool is
> > not preallocated.
> >
> > When a swap page is passed from frontswap to zswap, zswap maintains
> > a mapping of the swap entry, a combination of the swap type and swap
> > offset, to the zsmalloc handle that references that compressed swap
> > page.  This mapping is achieved with a red-black tree per swap type.
> > The swap offset is the search key for the tree nodes.
> >
> > Zswap seeks to be simple in its policies.  Sysfs attributes allow for
> > two user controlled policies:
> > * max_compression_ratio - Maximum compression ratio, as as percentage,
> >     for an acceptable compressed page. Any page that does not compress
> >     by at least this ratio will be rejected.
> > * max_pool_percent - The maximum percentage of memory that the compress=
ed
> >     pool can occupy.
> >
> > To enabled zswap, the "enabled" attribute must be set to 1 at boot time=
.
> >
> > Zswap allows the compressor to be selected at kernel boot time by
> > setting the "compressor" attribute.  The default compressor is lzo.
> >
> > A debugfs interface is provided for various statistic about pool size,
> > number of pages stored, and various counters for the reasons pages
> > are rejected.
> >
> > Performance, Kernel Building:
> >
> > Setup
> > =3D=3D=3D=3D=3D=3D=3D=3D
> > Gentoo w/ kernel v3.7-rc7
> > Quad-core i5-2500 @ 3.3GHz
> > 512MB DDR3 1600MHz (limited with mem=3D512m on boot)
> > Filesystem and swap on 80GB HDD (about 58MB/s with hdparm -t)
> > majflt are major page faults reported by the time command
> > pswpin/out is the delta of pswpin/out from /proc/vmstat before and afte=
r
> > the make -jN
> >
> > Summary
> > =3D=3D=3D=3D=3D=3D=3D=3D
> > * Zswap reduces I/O and improves performance at all swap pressure level=
s.
> >
> > * Under heavy swaping at 24 threads, zswap reduced I/O by 76%, saving
> >   over 1.5GB of I/O, and cut runtime in half.
> >
> > Details
> > =3D=3D=3D=3D=3D=3D=3D=3D
> > I/O (in pages)
> >         base                            zswap                          =
 change  change
> > N       pswpin  pswpout majflt  I/O sum pswpin  pswpout majflt  I/O sum=
 %I/O    MB
> > 8       1       335     291     627     0       0       249     249    =
 -60%    1
> > 12      3688    14315   5290    23293   123     860     5954    6937   =
 -70%    64
> > 16      12711   46179   16803   75693   2936    7390    46092   56418  =
 -25%    75
> > 20      42178   133781  49898   225857  9460    28382   92951   130793 =
 -42%    371
> > 24      96079   357280  105242  558601  7719    18484   109309  135512 =
 -76%    1653
> >
> > Runtime (in seconds)
> > N       base    zswap   %change
> > 8       107     107     0%
> > 12      128     110     -14%
> > 16      191     179     -6%
> > 20      371     240     -35%
> > 24      570     267     -53%
> >
> > %CPU utilization (out of 400% on 4 cpus)
> > N       base    zswap   %change
> > 8       317     319     1%
> > 12      267     311     16%
> > 16      179     191     7%
> > 20      94      143     52%
> > 24      60      128     113%
> >
> > Patchset is based on next-20121210
> >
> > Seth Jennings (8):
> >   staging: zsmalloc: add gfp flags to zs_create_pool
> >   staging: zsmalloc: remove unsed pool name
> >   staging: zsmalloc: add page alloc/free callbacks
> >   staging: zsmalloc: make CLASS_DELTA relative to PAGE_SIZE
> >   debugfs: add get/set for atomic types
> >   zsmalloc: promote to lib/
> >   zswap: add to mm/
> >   zswap: add documentation
> >
> >  Documentation/vm/zswap.txt               |   74 ++
> >  drivers/staging/Kconfig                  |    2 -
> >  drivers/staging/Makefile                 |    1 -
> >  drivers/staging/zcache/zcache-main.c     |    7 +-
> >  drivers/staging/zram/zram_drv.c          |    4 +-
> >  drivers/staging/zram/zram_drv.h          |    3 +-
> >  drivers/staging/zsmalloc/Kconfig         |   10 -
> >  drivers/staging/zsmalloc/Makefile        |    3 -
> >  drivers/staging/zsmalloc/zsmalloc-main.c | 1064 ----------------------=
-------
> >  drivers/staging/zsmalloc/zsmalloc.h      |   43 --
> >  fs/debugfs/file.c                        |   42 ++
> >  include/linux/debugfs.h                  |    2 +
> >  include/linux/swap.h                     |    4 +
> >  include/linux/zsmalloc.h                 |   49 ++
> >  lib/Kconfig                              |   18 +
> >  lib/Makefile                             |    1 +
> >  lib/zsmalloc.c                           | 1076 ++++++++++++++++++++++=
+++++++
> >  mm/Kconfig                               |   15 +
> >  mm/Makefile                              |    1 +
> >  mm/page_io.c                             |   22 +-
> >  mm/swap_state.c                          |    2 +-
> >  mm/zswap.c                               | 1077 ++++++++++++++++++++++=
++++++++
> >  22 files changed, 2383 insertions(+), 1137 deletions(-)
> >  create mode 100644 Documentation/vm/zswap.txt
> >  delete mode 100644 drivers/staging/zsmalloc/Kconfig
> >  delete mode 100644 drivers/staging/zsmalloc/Makefile
> >  delete mode 100644 drivers/staging/zsmalloc/zsmalloc-main.c
> >  delete mode 100644 drivers/staging/zsmalloc/zsmalloc.h
> >  create mode 100644 include/linux/zsmalloc.h
> >  create mode 100644 lib/zsmalloc.c
> >  create mode 100644 mm/zswap.c
> >
> > --
> > 1.7.9.5
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
