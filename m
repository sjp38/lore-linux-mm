Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id EC14C6B0037
	for <linux-mm@kvack.org>; Fri,  1 Nov 2013 15:17:16 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id bj1so4411617pad.39
        for <linux-mm@kvack.org>; Fri, 01 Nov 2013 12:17:16 -0700 (PDT)
Received: from psmtp.com ([74.125.245.145])
        by mx.google.com with SMTP id vs7si5227490pbc.235.2013.11.01.12.17.15
        for <linux-mm@kvack.org>;
        Fri, 01 Nov 2013 12:17:15 -0700 (PDT)
Received: by mail-pd0-f170.google.com with SMTP id v10so4274399pde.29
        for <linux-mm@kvack.org>; Fri, 01 Nov 2013 12:17:14 -0700 (PDT)
Date: Fri, 1 Nov 2013 12:16:59 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] memcg: remove incorrect underflow check
Message-ID: <alpine.LNX.2.00.1311011207290.2904@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Flavio Leitner <fbl@redhat.com>, Sha Zhengju <handai.szj@taobao.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Greg Thelen <gthelen@google.com>

When a memcg is deleted mem_cgroup_reparent_charges() moves charged
memory to the parent memcg.  As of v3.11-9444-g3ea67d0 "memcg: add per
cgroup writeback pages accounting" there's bad pointer read.  The goal
was to check for counter underflow.  The counter is a per cpu counter
and there are two problems with the code:
(1) per cpu access function isn't used, instead a naked pointer is
    used which easily causes oops.
(2) the check doesn't sum all cpus

Test:
  $ cd /sys/fs/cgroup/memory
  $ mkdir x
  $ echo 3 > /proc/sys/vm/drop_caches
  $ (echo $BASHPID >> x/tasks && exec cat) &
  [1] 7154
  $ grep ^mapped x/memory.stat
  mapped_file 53248
  $ echo 7154 > tasks
  $ rmdir x
  <OOPS>

The fix is to remove the check.  It's currently dangerous and isn't
worth fixing it to use something expensive, such as
percpu_counter_sum(), for each reparented page.  __this_cpu_read()
isn't enough to fix this because there's no guarantees of the current
cpus count.  The only guarantees is that the sum of all per-cpu
counter is >= nr_pages.

Fixes: 3ea67d06e467 ("memcg: add per cgroup writeback pages accounting")
Reported-and-tested-by: Flavio Leitner <fbl@redhat.com>
Signed-off-by: Greg Thelen <gthelen@google.com>
Reviewed-by: Sha Zhengju <handai.szj@taobao.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Hugh Dickins <hughd@google.com>
---

This patch fixes an actual crash (which I hit too this morning), so is
more important than the accounting fix on the next line which went in on
Wednesday.  It looks like this one got forgotten amidst discussion of the
others: I've updated Greg's original to apply to the current tree.

 mm/memcontrol.c | 1 -
 1 file changed, 1 deletion(-)

--- 3.12-rc7+/mm/memcontrol.c
+++ linux/mm/memcontrol.c
@@ -3782,7 +3782,6 @@ void mem_cgroup_move_account_page_stat(struct mem_cgroup *from,
 {
 	/* Update stat data for mem_cgroup */
 	preempt_disable();
-	WARN_ON_ONCE(from->stat->count[idx] < nr_pages);
 	__this_cpu_sub(from->stat->count[idx], nr_pages);
 	__this_cpu_add(to->stat->count[idx], nr_pages);
 	preempt_enable();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
