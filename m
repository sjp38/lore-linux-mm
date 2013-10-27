Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1DAA56B00E1
	for <linux-mm@kvack.org>; Sun, 27 Oct 2013 03:45:50 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so5839632pad.2
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 00:45:49 -0700 (PDT)
Received: from psmtp.com ([74.125.245.174])
        by mx.google.com with SMTP id ar5si8848669pbd.332.2013.10.27.00.45.48
        for <linux-mm@kvack.org>;
        Sun, 27 Oct 2013 00:45:49 -0700 (PDT)
Received: by mail-oa0-f74.google.com with SMTP id j10so503366oah.1
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 00:45:47 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH 3/3] memcg: use __this_cpu_sub to decrement stats
Date: Sun, 27 Oct 2013 00:44:36 -0700
Message-Id: <1382859876-28196-4-git-send-email-gthelen@google.com>
In-Reply-To: <1382859876-28196-1-git-send-email-gthelen@google.com>
References: <1382859876-28196-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, handai.szj@taobao.com, Andrew Morton <akpm@linux-foundation.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>

As of v3.11-9444-g3ea67d0 "memcg: add per cgroup writeback pages
accounting" memcg counter errors are possible when moving charged
memory to a different memcg.  Charge movement occurs when processing
writes to memory.force_empty, moving tasks to a memcg with
memcg.move_charge_at_immigrate=1, or memcg deletion.  An example
showing error after memory.force_empty:
  $ cd /sys/fs/cgroup/memory
  $ mkdir x
  $ rm /data/tmp/file
  $ (echo $BASHPID >> x/tasks && exec mmap_writer /data/tmp/file 1M) &
  [1] 13600
  $ grep ^mapped x/memory.stat
  mapped_file 1048576
  $ echo 13600 > tasks
  $ echo 1 > x/memory.force_empty
  $ grep ^mapped x/memory.stat
  mapped_file 4503599627370496

mapped_file should end with 0.
  4503599627370496 == 0x10,0000,0000,0000 == 0x100,0000,0000 pages
  1048576          == 0x10,0000           == 0x100 pages

This issue only affects the source memcg on 64 bit machines; the
destination memcg counters are correct.  So the rmdir case is not too
important because such counters are soon disappearing with the entire
memcg.  But the memcg.force_empty and
memory.move_charge_at_immigrate=1 cases are larger problems as the
bogus counters are visible for the (possibly long) remaining life of
the source memcg.

The problem is due to memcg use of __this_cpu_from(.., -nr_pages),
which is subtly wrong because it subtracts the unsigned int nr_pages
(either -1 or -512 for THP) from a signed long percpu counter.  When
nr_pages=-1, -nr_pages=0xffffffff.  On 64 bit machines
stat->count[idx] is signed 64 bit.  So memcg's attempt to simply
decrement a count (e.g. from 1 to 0) boils down to:
  long count = 1
  unsigned int nr_pages = 1
  count += -nr_pages  /* -nr_pages == 0xffff,ffff */
  count is now 0x1,0000,0000 instead of 0

The fix is to subtract the unsigned page count rather than adding its
negation.  This only works with the "percpu counter: cast
this_cpu_sub() adjustment" patch which fixes this_cpu_sub().

Signed-off-by: Greg Thelen <gthelen@google.com>
---
 mm/memcontrol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index aa8185c..b7ace0f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3773,7 +3773,7 @@ void mem_cgroup_move_account_page_stat(struct mem_cgroup *from,
 {
 	/* Update stat data for mem_cgroup */
 	preempt_disable();
-	__this_cpu_add(from->stat->count[idx], -nr_pages);
+	__this_cpu_sub(from->stat->count[idx], nr_pages);
 	__this_cpu_add(to->stat->count[idx], nr_pages);
 	preempt_enable();
 }
-- 
1.8.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
