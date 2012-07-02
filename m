Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id D414B6B0069
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 16:26:38 -0400 (EDT)
Date: Mon, 2 Jul 2012 15:26:36 -0500
From: Nathan Zimmer <nzimmer@sgi.com>
Subject: [PATCH 0/2 v4][rfc] tmpfs not interleaving properly
Message-ID: <20120702202635.GA20284@gulag1.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Christoph Lameter <cl@linux.com>, Nick Piggin <npiggin@gmail.com>, Hugh Dickins <hughd@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>

When tmpfs has the memory policy interleaved it always starts allocating at each
file at node 0.  When there are many small files the lower nodes fill up
disproportionately.
This patch spreads out node usage by starting files at nodes other then 0.
The tmpfs superblock grants an offset for each inode as they are created. Each
then uses that offset to proved a prefered first node for its interleave in
the shmem_interleave.

v2: passed preferred node via addr
v3: using current->cpuset_mem_spread_rotor instead of random_node
v4: Switching the rotor and attempting to provide an interleave function
Also splitting the patch into two sections.

Cc: Christoph Lameter <cl@linux.com>
Cc: Nick Piggin <npiggin@gmail.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Nathan T Zimmer <nzimmer@sgi.com>
---

 include/linux/mm.h       |    6 ++++++
 include/linux/shmem_fs.h |    2 ++
 mm/mempolicy.c           |    4 ++++
 mm/shmem.c               |   33 ++++++++++++++++++++++++++++++---
 4 files changed, 42 insertions(+), 3 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
