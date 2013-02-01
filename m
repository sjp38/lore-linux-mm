Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id BFA806B0007
	for <linux-mm@kvack.org>; Fri,  1 Feb 2013 15:23:20 -0500 (EST)
Received: by mail-vb0-f47.google.com with SMTP id e21so2695017vbm.34
        for <linux-mm@kvack.org>; Fri, 01 Feb 2013 12:23:19 -0800 (PST)
From: Konrad Rzeszutek Wilk <konrad@kernel.org>
Subject: [PATCH v2] Make frontswap+cleancache and its friend be modularized.
Date: Fri,  1 Feb 2013 15:22:49 -0500
Message-Id: <1359750184-23408-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.magenheimer@oracle.com, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, ngupta@vflare.org, rcj@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

Parts of this patch have been posted in the post (way back in November), but
this patchset expanded it a bit. The goal of the patches is to make the
different frontswap/cleancache API backends be modules - and load way way after
the swap system (or filesystem) has been initialized. Naturally one can still
build the frontswap+cleancache backend devices in the kernel. The next goal
(after these patches) is to also be able to unload the backend drivers - but
that places some interesting requirements to "reload" the swap device with
swap pages (don't need to worry that much about cleancache as it is a "secondary"
cache and can be dumped). Seth had posted some patches for that in the zswap
backend - and they could be more generally repurporsed.

Anyhow, I did not want to lose the authorship of some of the patches so I
didn't squash the ones that were made by Dan and mine. I can do it for review
if it would make it easier, but from my recollection on how Linus likes things
run he would prefer to keep the history (even the kludge parts).

The general flow prior to these patches was [I am concentrating on the
frontswap here, but the cleancache is similar, just s/swapon/mount/]:

 1) kernel inits frontswap_init
 2) kernel inits zcache (or some other backend)
 3) user does swapon /dev/XX and the writes to the swap disk end up in
    frontswap and then in the backend.

With the module loading, the 1) is still part of the bootup, but the
2) or 3) can be run at anytime. This means one could load the backend
_after_ the swap disk has been initialized and running along. Or
_before_ the swap disk has been setup - but that is similar to the
existing case so not that exciting.

To deal with that scenario the frontswap keeps an queue (actually an atomic
bitmap of the swap disks that have been init) and when the backend registers -
frontswap runs the backend init on the queued up swap disks.

The interesting thing is that we can be to certain degree racy when the
swap system starts steering pages to frontswap. Meaning after the backend
has registered it is OK if the pages are still hitting the disk instead of
the backend. Naturally this is unacceptable if one were to unload the
backend (not yet supported) - as we need to be quite atomic at that stage
and need to stop processing the pages the moment the backend is being
unloaded. To support this, the frontswap is using the struct static_key
which are incredibly light when they are in usage. They are incredibly heavy
when the value switches (on/off), but that is OK. The next part of unloading is
also taking the pages that are in the backend and feed them in the swap
storage (and Seth's patches do some of this).

Also attached is one patch from Minchan that fixes the condition where the
backend was constricted in allocating memory at init - b/c we were holding
a spin-lock. His patch fixes that and we are just holding the swapon_mutex
instead. It has been rebased on top of my patches.

This patchset is based on Greg KH's staging tree (since the zcache2 has
now been renamed to zcache). To be exact, it is based on
085494ac2039433a5df9fdd6fb653579e18b8c71

Dan Magenheimer (4):
      mm: cleancache: lazy initialization to allow tmem backends to build/run as modules
      mm: frontswap: lazy initialization to allow tmem backends to build/run as modules
      staging: zcache: enable ramster to be built/loaded as a module
      xen: tmem: enable Xen tmem shim to be built/loaded as a module

Konrad Rzeszutek Wilk (10):
      frontswap: Make frontswap_init use a pointer for the ops.
      cleancache: Make cleancache_init use a pointer for the ops
      staging: zcache: enable zcache to be built/loaded as a module
      xen/tmem: Remove the subsys call.
      frontswap: Remove the check for frontswap_enabled.
      frontswap: Use static_key instead of frontswap_enabled and frontswap_ops
      cleancache: Remove the check for cleancache_enabled.
      cleancache: Use static_key instead of cleancache_ops and cleancache_enabled.
      zcache/tmem: Better error checking on frontswap_register_ops return     value.
      xen/tmem: Add missing %s in the printk statement.

Minchan Kim (1):
      frontswap: Get rid of swap_lock dependency


 drivers/staging/zcache/Kconfig                     |   6 +-
 drivers/staging/zcache/Makefile                    |  11 +-
 drivers/staging/zcache/ramster.h                   |   6 +-
 drivers/staging/zcache/ramster/nodemanager.c       |   9 +-
 drivers/staging/zcache/ramster/ramster.c           |  29 ++-
 drivers/staging/zcache/ramster/ramster.h           |   2 +-
 .../staging/zcache/ramster/ramster_nodemanager.h   |   2 +
 drivers/staging/zcache/tmem.c                      |   6 +-
 drivers/staging/zcache/tmem.h                      |   8 +-
 drivers/staging/zcache/zcache-main.c               |  64 +++++-
 drivers/staging/zcache/zcache.h                    |   2 +-
 drivers/xen/Kconfig                                |   4 +-
 drivers/xen/tmem.c                                 |  55 +++--
 drivers/xen/xen-selfballoon.c                      |  13 +-
 include/linux/cleancache.h                         |  27 ++-
 include/linux/frontswap.h                          |  31 +--
 include/xen/tmem.h                                 |   8 +
 mm/cleancache.c                                    | 241 ++++++++++++++++++---
 mm/frontswap.c                                     | 121 ++++++++---
 mm/swapfile.c                                      |   7 +-
 20 files changed, 505 insertions(+), 147 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
