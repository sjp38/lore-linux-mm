Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id AE0426B0095
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 16:18:24 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <c31aaed4-9d50-4cdf-b794-367fc5850483@default>
Date: Tue, 31 Jul 2012 13:18:03 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [RFC/PATCH] zcache/ramster rewrite and promotion
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Here finally is the long promised rewrite of zcache (and ramster).

I know that we are concentrating on moving zcache from staging,
and not ramster. However the amount of duplicate code that ramster
used from zcache is astonishing so when I did the rewrite I thought
why not kill two birds with one stone - since both are in the
staging directory.

Of notable interest to the broader mm community, I am proposing, when revie=
w
is complete, to place zcache in a new subdirectory of mm, called "tmem"
(short for transcendent memory).  Zcache is truly memory management,
not a hardware driver, and it interfaces with mm/swap/vfs through mm/cleanc=
ache.c
and mm/frontswap.c (which possibly should move to the new tmem directory
in the future as well).

This is a major rewrite for zcache, not a sequence of small patches.
So those who are interested in understanding, reviewing, and commenting
in detail on the design and the functioning of the code can find it at:
=20
 git://oss.oracle.com/git/djm/tmem.git #zcache-120731

For those who prefer to review and comment line-by-line, it's not clear
yet how best to post the ~10K lines of code to ensure reviewer productivity=
.
Konrad suggested an IRC talk on Monday to talk about this so we can figure
out what is the proper option.

(If you are not familiar with the tmem terminology, you can review
it here: http://lwn.net/Articles/454795/ )
=20
Some of the highlights of this git branch:
 1. Merge of zcache and ramster.  Zcache and ramster had a great deal of
    duplicate code which is now merged.  In essence, zcache *is* ramster
    but with no remote machine available, but !CONFIG_RAMSTER will avoid
    compiling lots of ramster-specific code.
 2. Allocator.  Previously, persistent pools used zsmalloc and ephemeral po=
ols
    used zbud.  Now a completely rewritten zbud is used for both.  Notably
    this zbud maintains all persistent (frontswap) and ephemeral (cleancach=
e)
    pageframes in separate queues in LRU order.
 3. Interaction with page allocator.  Zbud does no page allocation/freeing,
    it is done entirely in zcache where it can be tracked more effectively.
 4. Better pre-allocation.  Previously, on put, if a new pageframe could no=
t be
    pre-allocated, the put would fail, even if the allocator had plenty of
    partial pages where the data could be stored; this is now fixed.
 5. Ouroboros ("eating its own tail") allocation.  If no pageframe can be a=
llocated
    AND no partial pages are available, the least-recently-used ephemeral p=
ageframe
    is reclaimed immediately (including flushing tmem pointers to it) and r=
e-used.
    This ensures that most-recently-used cleancache pages are more likely t=
o
    be retained than LRU pages and also that, as in the core mm subsystem,
    anonymous pages have a higher priority than clean page cache pages.
 6. Zcache and zbud now use debugfs instead of sysfs.  Ramster uses debugfs
    where possible and sysfs where necessary.  (Some ramster configuration
    is done from userspace so some sysfs is necessary.)
 7. Modularization.  As some have observed, the monolithic zcache-main.c co=
de
    included zbud code, which has now been separated into its own code modu=
le.
    Much ramster-specific code in the old ramster zcache-main.c has also be=
en
    moved into ramster.c so that it does not get compiled with !CONFIG_RAMS=
TER.
 8. Rebased to 3.5.

Konrad has been suggesting to prepare to "lift" the 2) "Allocator" out as a
separate patch so that it could be used in the zcache1 as part of its promo=
tion
out of staging - if we think that zcache1 needs that. The problem with that=
 is that
the code has been tested with all the other code together. It is unclear
whether by itself - without the rest of the harness - it would work properl=
y.

And if the time spent finding those bugs (of the lifted code) will be great=
er
than just dropping in zcache2 as zcache1 and concentrate on promoting that.

The nice-to-have-features that I had in the back of my mind (so after
zcache and ramster have left staging) were:

 A. Ouroboros writeback.  Since persistent (frontswap) pages may now also b=
e
    reclaimed in LRU order, the foundation is in place to properly writebac=
k
    these pages back into the swap cache and then the swap disk.  This is s=
till
    under development and requires some other mm changes which are prototyp=
ed
    but not yet included with this patch.
 B. WasActive patch, requires some mm/frontswap changes previously posted
    (but still has a known problem or two).
 C. Module capability, see patch posted by Erlangen University.  Needs
    to be brought up to kernel standards.

If anybody is interested on helping out with these, let me know!

P.S. I've just started tracking down a memory leak, so I don't recommend
benchmarking this zcache-120731 version yet.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

diffstat vs 3.5:
 drivers/staging/ramster/Kconfig       |    2=20
 drivers/staging/ramster/Makefile      |    2=20
 drivers/staging/zcache/Kconfig        |    2=20
 drivers/staging/zcache/Makefile       |    2=20
 mm/Kconfig                            |    2=20
 mm/Makefile                           |    4=20
 mm/tmem/Kconfig                       |   33=20
 mm/tmem/Makefile                      |    5=20
 mm/tmem/tmem.c                        |  894 +++++++++++++
 mm/tmem/tmem.h                        |  259 +++
 mm/tmem/zbud.c                        | 1060 +++++++++++++++
 mm/tmem/zbud.h                        |   33=20
 mm/tmem/zcache-main.c                 | 1686 +++++++++++++++++++++++++
 mm/tmem/zcache.h                      |   53
 mm/tmem/ramster.h                     |   59
 mm/tmem/ramster/heartbeat.c           |  462 ++++++
 mm/tmem/ramster/heartbeat.h           |   87 +
 mm/tmem/ramster/masklog.c             |  155 ++
 mm/tmem/ramster/masklog.h             |  220 +++
 mm/tmem/ramster/nodemanager.c         |  995 +++++++++++++++
 mm/tmem/ramster/nodemanager.h         |   88 +
 mm/tmem/ramster/r2net.c               |  414 ++++++
 mm/tmem/ramster/ramster.c             |  985 ++++++++++++++
 mm/tmem/ramster/ramster.h             |  161 ++
 mm/tmem/ramster/ramster_nodemanager.h |   39=20
 mm/tmem/ramster/tcp.c                 | 2253 +++++++++++++++++++++++++++++=
+++++
 mm/tmem/ramster/tcp.h                 |  159 ++
 mm/tmem/ramster/tcp_internal.h        |  248 +++
28 files changed, 10358 insertions(+), 4 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
