Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9ABFA6B01E3
	for <linux-mm@kvack.org>; Sat, 15 May 2010 18:36:00 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v2] mm: Consider the entire user address space during node migration
Date: Sat, 15 May 2010 15:35:13 -0700
Message-Id: <1273962913-8950-1-git-send-email-gthelen@google.com>
In-Reply-To: <AANLkTil4zgqBtBAp--P8VdynpbohxVosQ-qFiQQ_c5Bb@mail.gmail.com>
References: <AANLkTil4zgqBtBAp--P8VdynpbohxVosQ-qFiQQ_c5Bb@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>
List-ID: <linux-mm.kvack.org>

This patch uses mm->task_size instead of TASK_SIZE to ensure that the entire
user address space is migrated.  mm->task_size is independent of the calling
task context.  TASK SIZE may be dependant on the address space size of the
calling process.  Usage of TASK_SIZE can lead to partial address space migration
if the calling process was 32 bit and the migrating process was 64 bit.

Here is the test script used on 64 system with a 32 bit echo process:
  mount -t cgroup none /cgroup -o cpuset
  cd /cgroup

  mkdir 0
  echo 1 > 0/cpuset.cpus
  echo 0 > 0/cpuset.mems
  echo 1 > 0/cpuset.memory_migrate

  mkdir 1
  echo 1 > 1/cpuset.cpus
  echo 1 > 1/cpuset.mems
  echo 1 > 1/cpuset.memory_migrate

  echo $$ > 0/tasks
  64_bit_process &
  pid=$!

  echo $pid > 1/tasks   # This does not migrate all process pages without
                        # this patch.  If 64 bit echo is used or this patch is
                        # applied, then the full address space of $pid is
                        # migrated.

To check memory migration, I watched:
  grep MemUsed /sys/devices/system/node/node*/meminfo

Changes since v1:
- Use mm->task_size rather than TASK_SIZE_MAX to support all platforms.

Signed-off-by: Greg Thelen <gthelen@google.com>
---
 mm/mempolicy.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 9f11728..2fd17e7 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -928,7 +928,7 @@ static int migrate_to_node(struct mm_struct *mm, int source, int dest,
 	nodes_clear(nmask);
 	node_set(source, nmask);
 
-	check_range(mm, mm->mmap->vm_start, TASK_SIZE, &nmask,
+	check_range(mm, mm->mmap->vm_start, mm->task_size, &nmask,
 			flags | MPOL_MF_DISCONTIG_OK, &pagelist);
 
 	if (!list_empty(&pagelist))
-- 
1.7.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
