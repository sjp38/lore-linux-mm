Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 5CD856B000D
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 12:26:52 -0500 (EST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH 2/5] staging: zcache: rename ramster to zcache
Date: Thu, 17 Jan 2013 09:26:34 -0800
Message-Id: <1358443597-9845-3-git-send-email-dan.magenheimer@oracle.com>
In-Reply-To: <1358443597-9845-1-git-send-email-dan.magenheimer@oracle.com>
References: <1358443597-9845-1-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, minchan@kernel.org, dan.magenheimer@oracle.com

In staging, rename ramster to zcache

The original zcache in staging was a "demo" version, and this new zcache
is a significant rewrite.  While certain disagreements were being resolved,
both "old zcache" and "new zcache" needed to reside in the staging tree
simultaneously.  In order to minimize code change and churn, the newer
version of zcache was temporarily merged into the "ramster" staging driver
which, prior to that, had at one time heavily leveraged the older version
of zcache.  So, recently, "new zcache" resided in the ramster directory.

Got that? No? Sorry, temporary political compromises are rarely pretty.

The older version of zcache is no longer being maintained and has now
been removed from the staging tree.  So now the newer version of zcache
can rightfully reclaim sole possession of the name "zcache".

This patch is simply a manual:

  # git mv drivers/staging/ramster drivers/staging/zcache

so the actual patch diff has been left out.

Because a git mv loses history, part of the original description of
the changes between "old zcache" and "new zcache" is repeated below:

Some of the highlights of this rewritten codebase for zcache:
(Note: If you are not familiar with the tmem terminology, you can review
it here: http://lwn.net/Articles/454795/ )
 1. Merge of "demo" zcache and the v1.1 version of zcache in ramster.  Zcache
    and ramster had a great deal of duplicate code which is now merged.
    In essence, zcache now *is* ramster but with no remote machine available,
    but !CONFIG_RAMSTER will avoid compiling lots of ramster-specific code.
 2. Allocator.  Previously, persistent pools used zsmalloc and ephemeral pools
    used zbud.  Now a completely rewritten zbud is used for both.  Notably
    this zbud maintains all persistent (frontswap) and ephemeral (cleancache)
    pageframes in separate queues in LRU order.
 3. Interaction with page allocator.  Zbud does no page allocation/freeing,
    it is done entirely in zcache where it can be tracked more effectively.
 4. Better pre-allocation.  Previously, on put, if a new pageframe could not be
    pre-allocated, the put would fail, even if the allocator had plenty of
    partial pages where the data could be stored; this is now fixed.
 5. Ouroboros ("eating its own tail") allocation.  If no pageframe can be
    allocated AND no partial pages are available, the least-recently-used
    ephemeral pageframe is reclaimed immediately (including flushing tmem
    pointers to it) and re-used.  This ensures that most-recently-used
    cleancache pages are more likely to be retained than LRU pages and also
    that, as in the core mm subsystem, anonymous pages have a higher priority
    than clean page cache pages.
 6. Zcache and zbud now use debugfs instead of sysfs.  Ramster uses debugfs
    where possible and sysfs where necessary.  (Some ramster configuration
    is done from userspace so some sysfs is necessary.)
 7. Modularization.  As some have observed, the monolithic zcache-main.c code
    included zbud code, which has now been separated into its own code module.
    Much ramster-specific code in the old ramster zcache-main.c has also been
    moved into ramster.c so that it does not get compiled with !CONFIG_RAMSTER.
 8. Rebased to 3.5.

This new codebase also provides hooks for several future new features:
 A. WasActive patch, requires some mm/frontswap changes previously posted.
    A new version of this patch will be provided separately.
    See ifdef __PG_WAS_ACTIVE
 B. Exclusive gets.  It seems tmem _can_ support exclusive gets with a
    minor change to both zcache and a small backwards-compatible change
    to frontswap.c.  Explanation and frontswap patch will be provided
    separately.  See ifdef FRONTSWAP_HAS_EXCLUSIVE_GETS
 C. Ouroboros writeback.  Since persistent (frontswap) pages may now also be
    reclaimed in LRU order, the foundation is in place to properly writeback
    these pages back into the swap cache and then the swap disk.  This is still
    under development and requires some other mm changes which are prototyped.
    See ifdef FRONTSWAP_HAS_UNUSE.

A new feature that desperately needs attention (if someone is looking for
a way to contribute) is kernel module support.  A preliminary version of
a patch was posted by Erlangen University and needs to be integrated and
tested for zcache and brought up to kernel standards.

If anybody is interested on helping out with any of these, let me know!

Original zcache rewrite was:
Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

This "git mv" patch which changes only file locations in staging is:

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
---
 drivers/staging/ramster/Kconfig                    |   31 -
 drivers/staging/ramster/Makefile                   |    6 -
 drivers/staging/ramster/ramster.h                  |   59 -
 drivers/staging/ramster/ramster/heartbeat.c        |  462 ----
 drivers/staging/ramster/ramster/heartbeat.h        |   87 -
 drivers/staging/ramster/ramster/masklog.c          |  155 --
 drivers/staging/ramster/ramster/masklog.h          |  220 --
 drivers/staging/ramster/ramster/nodemanager.c      |  995 ---------
 drivers/staging/ramster/ramster/nodemanager.h      |   88 -
 drivers/staging/ramster/ramster/r2net.c            |  414 ----
 drivers/staging/ramster/ramster/ramster.c          |  985 ---------
 drivers/staging/ramster/ramster/ramster.h          |  161 --
 .../staging/ramster/ramster/ramster_nodemanager.h  |   39 -
 drivers/staging/ramster/ramster/tcp.c              | 2253 --------------------
 drivers/staging/ramster/ramster/tcp.h              |  159 --
 drivers/staging/ramster/ramster/tcp_internal.h     |  248 ---
 drivers/staging/ramster/tmem.c                     |  894 --------
 drivers/staging/ramster/tmem.h                     |  259 ---
 drivers/staging/ramster/zbud.c                     | 1060 ---------
 drivers/staging/ramster/zbud.h                     |   33 -
 drivers/staging/ramster/zcache-main.c              | 1820 ----------------
 drivers/staging/ramster/zcache.h                   |   53 -
 drivers/staging/zcache/Kconfig                     |   31 +
 drivers/staging/zcache/Makefile                    |    6 +
 drivers/staging/zcache/ramster.h                   |   59 +
 drivers/staging/zcache/ramster/heartbeat.c         |  462 ++++
 drivers/staging/zcache/ramster/heartbeat.h         |   87 +
 drivers/staging/zcache/ramster/masklog.c           |  155 ++
 drivers/staging/zcache/ramster/masklog.h           |  220 ++
 drivers/staging/zcache/ramster/nodemanager.c       |  995 +++++++++
 drivers/staging/zcache/ramster/nodemanager.h       |   88 +
 drivers/staging/zcache/ramster/r2net.c             |  414 ++++
 drivers/staging/zcache/ramster/ramster.c           |  985 +++++++++
 drivers/staging/zcache/ramster/ramster.h           |  161 ++
 .../staging/zcache/ramster/ramster_nodemanager.h   |   39 +
 drivers/staging/zcache/ramster/tcp.c               | 2253 ++++++++++++++++++++
 drivers/staging/zcache/ramster/tcp.h               |  159 ++
 drivers/staging/zcache/ramster/tcp_internal.h      |  248 +++
 drivers/staging/zcache/tmem.c                      |  894 ++++++++
 drivers/staging/zcache/tmem.h                      |  259 +++
 drivers/staging/zcache/zbud.c                      | 1060 +++++++++
 drivers/staging/zcache/zbud.h                      |   33 +
 drivers/staging/zcache/zcache-main.c               | 1820 ++++++++++++++++
 drivers/staging/zcache/zcache.h                    |   53 +
 44 files changed, 10481 insertions(+), 10481 deletions(-)
 delete mode 100644 drivers/staging/ramster/Kconfig
 delete mode 100644 drivers/staging/ramster/Makefile
 delete mode 100644 drivers/staging/ramster/ramster.h
 delete mode 100644 drivers/staging/ramster/ramster/heartbeat.c
 delete mode 100644 drivers/staging/ramster/ramster/heartbeat.h
 delete mode 100644 drivers/staging/ramster/ramster/masklog.c
 delete mode 100644 drivers/staging/ramster/ramster/masklog.h
 delete mode 100644 drivers/staging/ramster/ramster/nodemanager.c
 delete mode 100644 drivers/staging/ramster/ramster/nodemanager.h
 delete mode 100644 drivers/staging/ramster/ramster/r2net.c
 delete mode 100644 drivers/staging/ramster/ramster/ramster.c
 delete mode 100644 drivers/staging/ramster/ramster/ramster.h
 delete mode 100644 drivers/staging/ramster/ramster/ramster_nodemanager.h
 delete mode 100644 drivers/staging/ramster/ramster/tcp.c
 delete mode 100644 drivers/staging/ramster/ramster/tcp.h
 delete mode 100644 drivers/staging/ramster/ramster/tcp_internal.h
 delete mode 100644 drivers/staging/ramster/tmem.c
 delete mode 100644 drivers/staging/ramster/tmem.h
 delete mode 100644 drivers/staging/ramster/zbud.c
 delete mode 100644 drivers/staging/ramster/zbud.h
 delete mode 100644 drivers/staging/ramster/zcache-main.c
 delete mode 100644 drivers/staging/ramster/zcache.h
 create mode 100644 drivers/staging/zcache/Kconfig
 create mode 100644 drivers/staging/zcache/Makefile
 create mode 100644 drivers/staging/zcache/ramster.h
 create mode 100644 drivers/staging/zcache/ramster/heartbeat.c
 create mode 100644 drivers/staging/zcache/ramster/heartbeat.h
 create mode 100644 drivers/staging/zcache/ramster/masklog.c
 create mode 100644 drivers/staging/zcache/ramster/masklog.h
 create mode 100644 drivers/staging/zcache/ramster/nodemanager.c
 create mode 100644 drivers/staging/zcache/ramster/nodemanager.h
 create mode 100644 drivers/staging/zcache/ramster/r2net.c
 create mode 100644 drivers/staging/zcache/ramster/ramster.c
 create mode 100644 drivers/staging/zcache/ramster/ramster.h
 create mode 100644 drivers/staging/zcache/ramster/ramster_nodemanager.h
 create mode 100644 drivers/staging/zcache/ramster/tcp.c
 create mode 100644 drivers/staging/zcache/ramster/tcp.h
 create mode 100644 drivers/staging/zcache/ramster/tcp_internal.h
 create mode 100644 drivers/staging/zcache/tmem.c
 create mode 100644 drivers/staging/zcache/tmem.h
 create mode 100644 drivers/staging/zcache/zbud.c
 create mode 100644 drivers/staging/zcache/zbud.h
 create mode 100644 drivers/staging/zcache/zcache-main.c
 create mode 100644 drivers/staging/zcache/zcache.h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
