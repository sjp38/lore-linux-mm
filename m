Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 7B4036B006C
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 16:45:06 -0400 (EDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH V2 0/3] staging: ramster: move to new zcache2 code base
Date: Wed,  5 Sep 2012 13:44:58 -0700
Message-Id: <1346877901-12543-1-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, minchan@kernel.org, dan.magenheimer@oracle.com

[V2: rebased to apply to 20120905 staging-next, no other changes]

Hi Greg --

Please apply for staging-next for the 3.7 window to move ramster forward.
Since AFAICT there have been no patches or contributions from others to
drivers/staging/ramster since it was merged, this totally new version
of ramster should not run afoul and the patches should apply to
your staging-next tree as of 20120905.

Thanks,
Dan

Patchset overview:

When ramster was merged into staging at 3.4, it used a "temporarily" forked
version of zcache.  Code was proposed to merge zcache and ramster into
a new common redesigned codebase which both resolves various serious design
flaws and eliminates all code duplication between zcache and ramster, with
the result to replace "zcache".  Sadly, that proposal was blocked, so the
zcache (and tmem) code in drivers/staging/zcache and the zcache (and tmem)
code in drivers/staging/ramster continue to be different.

This patchset moves ramster to the new redesigned codebase and calls that
new codebase "zcache2".  Most, if not all, of the redesign will eventually
need to be merged with "zcache1" before zcache functionality should be
promoted out of staging.

An overview of the zcache2 rewrite is provided in a git commit comment
later in this series.

A significant item of debate in the new codebase is the removal of zsmalloc.
This removal may be temporary if zsmalloc is enhanced with necessary
features to meet the needs of the new zcache codebase.  Justification
for the change can be found at http://lkml.org/lkml/2012/8/15/292
Such zsmalloc enhancments will almost certainly necessitate a major
rework, not a small patch.

While this zcache2 codebase is far from perfect (and thus remains in staging),
the foundation is now cleaner, more stable, more maintainable, and much
better commented.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

---
Diffstat:

 drivers/staging/Kconfig                            |    4 +-
 drivers/staging/Makefile                           |    2 +-
 drivers/staging/ramster/Kconfig                    |   25 +-
 drivers/staging/ramster/Makefile                   |    7 +-
 drivers/staging/ramster/TODO                       |   13 -
 drivers/staging/ramster/cluster/Makefile           |    3 -
 drivers/staging/ramster/cluster/heartbeat.c        |  464 ---
 drivers/staging/ramster/cluster/heartbeat.h        |   87 -
 drivers/staging/ramster/cluster/masklog.c          |  155 -
 drivers/staging/ramster/cluster/masklog.h          |  220 --
 drivers/staging/ramster/cluster/nodemanager.c      |  992 ------
 drivers/staging/ramster/cluster/nodemanager.h      |   88 -
 .../staging/ramster/cluster/ramster_nodemanager.h  |   39 -
 drivers/staging/ramster/cluster/tcp.c              | 2256 -------------
 drivers/staging/ramster/cluster/tcp.h              |  159 -
 drivers/staging/ramster/cluster/tcp_internal.h     |  248 --
 drivers/staging/ramster/r2net.c                    |  401 ---
 drivers/staging/ramster/ramster.h                  |  113 +-
 drivers/staging/ramster/ramster/heartbeat.c        |  462 +++
 drivers/staging/ramster/ramster/heartbeat.h        |   87 +
 drivers/staging/ramster/ramster/masklog.c          |  155 +
 drivers/staging/ramster/ramster/masklog.h          |  220 ++
 drivers/staging/ramster/ramster/nodemanager.c      |  995 ++++++
 drivers/staging/ramster/ramster/nodemanager.h      |   88 +
 drivers/staging/ramster/ramster/r2net.c            |  414 +++
 drivers/staging/ramster/ramster/ramster.c          |  985 ++++++
 drivers/staging/ramster/ramster/ramster.h          |  161 +
 .../staging/ramster/ramster/ramster_nodemanager.h  |   39 +
 drivers/staging/ramster/ramster/tcp.c              | 2253 +++++++++++++
 drivers/staging/ramster/ramster/tcp.h              |  159 +
 drivers/staging/ramster/ramster/tcp_internal.h     |  248 ++
 drivers/staging/ramster/tmem.c                     |  313 +-
 drivers/staging/ramster/tmem.h                     |  109 +-
 drivers/staging/ramster/xvmalloc.c                 |  509 ---
 drivers/staging/ramster/xvmalloc.h                 |   30 -
 drivers/staging/ramster/xvmalloc_int.h             |   95 -
 drivers/staging/ramster/zbud.c                     | 1060 ++++++
 drivers/staging/ramster/zbud.h                     |   33 +
 drivers/staging/ramster/zcache-main.c              | 3532 ++++++--------------
 drivers/staging/ramster/zcache.h                   |   55 +-
 40 files changed, 8711 insertions(+), 8567 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
