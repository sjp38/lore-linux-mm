Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id AC3706B0082
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 10:54:27 -0500 (EST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH V5r1 0/6] staging: ramster: multi-machine memory capacity management
Date: Wed, 15 Feb 2012 07:54:14 -0800
Message-Id: <1329321260-15222-1-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, linux-mm@kvack.org, dan.magenheimer@oracle.com

[Note: identical to V5 but rebased to staging-next and patchset threaded,
 due to gregkh request... sorry for the noise and thanks for your patience!]

HIGH LEVEL OVERVIEW

RAMster implements peer-to-peer transcendent memory, allowing a "cluster" of
kernels to dynamically pool their RAM so that a RAM-hungry workload on one
machine can temporarily and transparently utilize RAM on another machine which
is presumably idle or running a non-RAM-hungry workload.  Other than the
already-merged cleancache patchset and the not-yet-merged frontswap patchset,
no core kernel changes are currently required.

(Note that, unlike previous public descriptions of RAMster, this implementation
does NOT require synchronous "gets" or core networking changes. As of V5,
it also co-exists with ocfs2.)

RAMster combines a clustering and messaging foundation based on the ocfs2
cluster layer with the in-kernel compression implementation of zcache, and
adds code to glue them together.  When a page is "put" to RAMster, it is
compressed and stored locally.  Periodically, a thread will "remotify" these
pages by sending them via messages to a remote machine.  When the page is
later needed as indicated by a page fault, a "get" is issued.  If the data
is local, it is uncompressed and the fault is resolved.  If the data is
remote, a message is sent to fetch the data and the faulting thread sleeps;
when the data arrives, the thread awakens, the data is decompressed and
the fault is resolved.

As of V5, clusters up to eight nodes are supported; each node can remotify
pages to one specified node, so clusters can be configured as clients to
a "memory server".  Some simple policy is in place that will need to be
refined over time.  Larger clusters and fault-resistant protocols can also
be added over time.

A git branch containing these patches built on linux-3.2 can be found at:
git://oss.oracle.com/git/djm/tmem.git #ramster-v5
Note that that tree also includes frontswap-v11 and "WasActive" patches

A HOW-TO is available at:
http://oss.oracle.com/projects/tmem/dist/files/RAMster/HOWTO-v5-120214

v4->v5: support multi-node clusters (up to 8 nodes)
v4->v5: add settable to choose remotify target node for memory server config
v4->v5: incorporate ocfs2 cluster layer directly to allow co-exist with ocfs2
v4->v5: incorporate xvmalloc directly to avoid upstream zsmalloc conflicts
v4->v5: support ramster-tools (instead of ocfs2-tools) in userland
v3->v4: rebase to 3.2 (including updates in zcache)
v3->v4: fix a couple of bad memory leaks to get cleancache fully working
v3->v4: fix preemption calls to remove dependency on CONFIG_PREEMPT_NONE
v3->v4: various cleanup
v2->v3: documentation and commit message changes required [gregkh]

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>


---

Diffstat:

 drivers/staging/Kconfig                            |    2 +
 drivers/staging/Makefile                           |    1 +
 drivers/staging/ramster/Kconfig                    |   13 +
 drivers/staging/ramster/Makefile                   |    1 +
 drivers/staging/ramster/TODO                       |   13 +
 drivers/staging/ramster/cluster/Makefile           |    3 +
 drivers/staging/ramster/cluster/heartbeat.c        |  464 +++
 drivers/staging/ramster/cluster/heartbeat.h        |   87 +
 drivers/staging/ramster/cluster/masklog.c          |  155 +
 drivers/staging/ramster/cluster/masklog.h          |  220 ++
 drivers/staging/ramster/cluster/nodemanager.c      |  992 ++++++
 drivers/staging/ramster/cluster/nodemanager.h      |   88 +
 .../staging/ramster/cluster/ramster_nodemanager.h  |   39 +
 drivers/staging/ramster/cluster/tcp.c              | 2256 +++++++++++++
 drivers/staging/ramster/cluster/tcp.h              |  159 +
 drivers/staging/ramster/cluster/tcp_internal.h     |  248 ++
 drivers/staging/ramster/r2net.c                    |  401 +++
 drivers/staging/ramster/ramster.h                  |  118 +
 drivers/staging/ramster/tmem.c                     |  851 +++++
 drivers/staging/ramster/tmem.h                     |  244 ++
 drivers/staging/ramster/xvmalloc.c                 |  510 +++
 drivers/staging/ramster/xvmalloc.h                 |   30 +
 drivers/staging/ramster/xvmalloc_int.h             |   95 +
 drivers/staging/ramster/zcache-main.c              | 3320 ++++++++++++++++++++
 drivers/staging/ramster/zcache.h                   |   22 +
 25 files changed, 10332 insertions(+), 0 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
