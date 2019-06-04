Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4AD99C28CC3
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 21:05:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DDF282075B
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 21:05:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="aM3vRSpR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDF282075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 65B166B0271; Tue,  4 Jun 2019 17:05:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 60C6B6B0273; Tue,  4 Jun 2019 17:05:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 520EE6B0274; Tue,  4 Jun 2019 17:05:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 16EFE6B0271
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 17:05:17 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id l184so8165793pgd.18
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 14:05:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=iN0wSIUb/u/LwFM5hUxI2ZE7eNuxFIJhNcRWtLrQb08=;
        b=J1YZ1TtfZp/uLnzx2zyxJZoKYggxnlmxw6Vq+LjSpcTLI5MXqVyRYJCxuXJaGeP/lR
         epiyNbAM/Ldw/HIf9eAAnf+dXmOhAmjIj6FJDUJtTAZyQ6IVwdyoQEETsxh750pNwLQO
         a9d6y7QlS2xnxqfBCq0Q6p5nFQHTKrEF6w1YJMq8+xx4FCCZLjW8Y2ayFSwNLgqNItwg
         zOHroyTKhr/HaY3yJF0CjJsUyOa36WnzlrTfNI8aOgMVE3Ix2NLTMTIS6gZYwQHpTsIB
         VA1bf0TLuPPiRWVKZSZmcqMQzloKOplTpsyDuwLK7WrrI3dGIarJBbrYAvDACgKuPivq
         itwQ==
X-Gm-Message-State: APjAAAWbcCaS9irdzyU/30CX7XP7KWy6mUC/0SNaQJa6OyBmMf/Trjcp
	EGNG/vY5M+MhzMNzLJeQCXva23idNub15U6gKZW8jL/r/qp7nm4dYJzx1oZ9dOlJQHp5iCNNwGZ
	YHr7ycggldA12f+vNrSqlQvnJK6qpOm03Y76xtUT6t0X9H4km56E+swP9I07aGXpYdw==
X-Received: by 2002:a63:5a1f:: with SMTP id o31mr753036pgb.254.1559682316547;
        Tue, 04 Jun 2019 14:05:16 -0700 (PDT)
X-Received: by 2002:a63:5a1f:: with SMTP id o31mr752943pgb.254.1559682314920;
        Tue, 04 Jun 2019 14:05:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559682314; cv=none;
        d=google.com; s=arc-20160816;
        b=luFZ3SxSoXlbfkEWyAXKsNj9VhLUjoKfgAWxtvS8xHzJuloSNL9PuDU13KTiBf23mm
         5mII+1eG5l2l+GFNf4m5gslyfMiup7NEC0ovlGtUvLAm1XJ5+9pVjTLAb8b9hU3HL3C0
         Ks2JmVwHS9WejRmrJG2DMcPJF9WrMD5T7H00Hv0p9ZLMksdQcZ7QmR8EmarXU/JoBKiw
         4RH6DW1LsBnnYb7TfNLjYxTmtYCUxiBU+ygE9UUA7kQQ9RSZs1z4vaVJFLy5qlpC+z7n
         DLY5SGWsKyVpxrF8VtKDiqhphwhZLmDdAXLno4bo9UqZAIX/pPYxK71lLF0QzP71M0kv
         q/MQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=iN0wSIUb/u/LwFM5hUxI2ZE7eNuxFIJhNcRWtLrQb08=;
        b=bZIBsO0KE99XkuoAB1grkAfl1R2mAfXvhJhY0MQc4n5di45HTvkLM9avzghHyXBMRF
         bkbwfo9QhVFilkxH0G5ZNxRaHKagOyrtoCFLKfM8v5D4NshgsrZltP5MCrxX6ojOsmfi
         YwVCM/7xOwToJQKySboHqUzK0OOMuGyr5B0OzKHd3mpoBPxVDWTPyX7KeQ0LxJ8buGzf
         tQNMZL+ED9j+yzu0fgzqgh1lD7uqWyh62coxnTo3jZf4raSTC95OCkJYlt/AmjZa4AR9
         m4N+Yk0nLOMmiD2Q0Jspwo4Q5gnGk2MhwCzCUeH5bu0ZiOc3sqPdyHB0xVHhDhA9jHsZ
         ptUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=aM3vRSpR;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m5sor7006330pfh.55.2019.06.04.14.05.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 14:05:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=aM3vRSpR;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=iN0wSIUb/u/LwFM5hUxI2ZE7eNuxFIJhNcRWtLrQb08=;
        b=aM3vRSpRvUYoeZpLpVYtEg0+HHSblnxK1fvw5UKAozYEjZy/Wfkq9zdklnoaFQgnHc
         4z8sLCysvlRUvbDA5LDMcDvcQVHay5N0kVkPb9oOjNGV79LtqTpJdP2CdPvPqEJQ9HJX
         8RE/sF3X8w1OSman+zke60M9Qm3JR9m8BHtnB8Z/T5hIKm4rUaSdcdWtWKuj69D4HObr
         VpxN8VFFVrbktr+KD2J7lvfY2Dz1BKUXlDO19tUA0Z3LjU/B8AyUyBBFwkuSQSNJy/aN
         o+Ab0HrN4brclc/CDVL7M29e4WlOCZqK3gWox3UBwK1BrRn7zf0cYBLkftBQKK8OGzLz
         BKAQ==
X-Google-Smtp-Source: APXvYqyRImQsPQcKl4N8rh7qY3+59zaI7xKOVpxBussVMAYaxmbNTpknfNVpGcKQz5xfBw7M+1lR4A==
X-Received: by 2002:aa7:8b4d:: with SMTP id i13mr42068094pfd.233.1559682311686;
        Tue, 04 Jun 2019 14:05:11 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::3:8201])
        by smtp.gmail.com with ESMTPSA id c9sm8678629pfn.3.2019.06.04.14.05.10
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Jun 2019 14:05:10 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH] mm: memcontrol: dump memory.stat during cgroup OOM
Date: Tue,  4 Jun 2019 17:05:09 -0400
Message-Id: <20190604210509.9744-1-hannes@cmpxchg.org>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The current cgroup OOM memory info dump doesn't include all the memory
we are tracking, nor does it give insight into what the VM tried to do
leading up to the OOM. All that useful info is in memory.stat.

Furthermore, the recursive printing for every child cgroup can
generate absurd amounts of data on the console for larger cgroup
trees, and it's not like we provide a per-cgroup breakdown during
global OOM kills.

When an OOM kill is triggered, print one set of recursive memory.stat
items at the level whose limit triggered the OOM condition.

Example output:

stress invoked oom-killer: gfp_mask=0x100cca(GFP_HIGHUSER_MOVABLE), order=0, oom_score_adj=0
CPU: 2 PID: 210 Comm: stress Not tainted 5.2.0-rc2-mm1-00247-g47d49835983c #135
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.12.0-20181126_142135-anatol 04/01/2014
Call Trace:
 dump_stack+0x46/0x60
 dump_header+0x4c/0x2d0
 oom_kill_process.cold.10+0xb/0x10
 out_of_memory+0x200/0x270
 ? try_to_free_mem_cgroup_pages+0xdf/0x130
 mem_cgroup_out_of_memory+0xb7/0xc0
 try_charge+0x680/0x6f0
 mem_cgroup_try_charge+0xb5/0x160
 __add_to_page_cache_locked+0xc6/0x300
 ? list_lru_destroy+0x80/0x80
 add_to_page_cache_lru+0x45/0xc0
 pagecache_get_page+0x11b/0x290
 filemap_fault+0x458/0x6d0
 ext4_filemap_fault+0x27/0x36
 __do_fault+0x2f/0xb0
 __handle_mm_fault+0x9c5/0x1140
 ? apic_timer_interrupt+0xa/0x20
 handle_mm_fault+0xc5/0x180
 __do_page_fault+0x1ab/0x440
 ? page_fault+0x8/0x30
 page_fault+0x1e/0x30
RIP: 0033:0x55c32167fc10
Code: Bad RIP value.
RSP: 002b:00007fff1d031c50 EFLAGS: 00010206
RAX: 000000000dc00000 RBX: 00007fd2db000010 RCX: 00007fd2db000010
RDX: 0000000000000000 RSI: 0000000010001000 RDI: 0000000000000000
RBP: 000055c321680a54 R08: 00000000ffffffff R09: 0000000000000000
R10: 0000000000000022 R11: 0000000000000246 R12: ffffffffffffffff
R13: 0000000000000002 R14: 0000000000001000 R15: 0000000010000000
memory: usage 1024kB, limit 1024kB, failcnt 75131
swap: usage 0kB, limit 9007199254740988kB, failcnt 0
Memory cgroup stats for /foo:
anon 0
file 0
kernel_stack 36864
slab 274432
sock 0
shmem 0
file_mapped 0
file_dirty 0
file_writeback 0
anon_thp 0
inactive_anon 126976
active_anon 0
inactive_file 0
active_file 0
unevictable 0
slab_reclaimable 0
slab_unreclaimable 274432
pgfault 59466
pgmajfault 1617
workingset_refault 2145
workingset_activate 0
workingset_nodereclaim 0
pgrefill 98952
pgscan 200060
pgsteal 59340
pgactivate 40095
pgdeactivate 96787
pglazyfree 0
pglazyfreed 0
thp_fault_alloc 0
thp_collapse_alloc 0
Tasks state (memory values in pages):
[  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name
[    200]     0   200     1121      884    53248       29             0 bash
[    209]     0   209      905      246    45056       19             0 stress
[    210]     0   210    66442       56   499712    56349             0 stress
oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),oom_memcg=/foo,task_memcg=/foo,task=stress,pid=210,uid=0
Memory cgroup out of memory: Killed process 210 (stress) total-vm:265768kB, anon-rss:0kB, file-rss:224kB, shmem-rss:0kB
oom_reaper: reaped process 210 (stress), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 289 ++++++++++++++++++++++++++----------------------
 1 file changed, 157 insertions(+), 132 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6de8ca735ee2..0907a96ceddf 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -66,6 +66,7 @@
 #include <linux/lockdep.h>
 #include <linux/file.h>
 #include <linux/tracehook.h>
+#include <linux/seq_buf.h>
 #include "internal.h"
 #include <net/sock.h>
 #include <net/ip.h>
@@ -1365,27 +1366,114 @@ static bool mem_cgroup_wait_acct_move(struct mem_cgroup *memcg)
 	return false;
 }
 
-static const unsigned int memcg1_stats[] = {
-	MEMCG_CACHE,
-	MEMCG_RSS,
-	MEMCG_RSS_HUGE,
-	NR_SHMEM,
-	NR_FILE_MAPPED,
-	NR_FILE_DIRTY,
-	NR_WRITEBACK,
-	MEMCG_SWAP,
-};
+static char *memory_stat_format(struct mem_cgroup *memcg)
+{
+	struct seq_buf s;
+	int i;
 
-static const char *const memcg1_stat_names[] = {
-	"cache",
-	"rss",
-	"rss_huge",
-	"shmem",
-	"mapped_file",
-	"dirty",
-	"writeback",
-	"swap",
-};
+	seq_buf_init(&s, kvmalloc(PAGE_SIZE, GFP_KERNEL), PAGE_SIZE);
+	if (!s.buffer)
+		return NULL;
+
+	/*
+	 * Provide statistics on the state of the memory subsystem as
+	 * well as cumulative event counters that show past behavior.
+	 *
+	 * This list is ordered following a combination of these gradients:
+	 * 1) generic big picture -> specifics and details
+	 * 2) reflecting userspace activity -> reflecting kernel heuristics
+	 *
+	 * Current memory state:
+	 */
+
+	seq_buf_printf(&s, "anon %llu\n",
+		       (u64)memcg_page_state(memcg, MEMCG_RSS) *
+		       PAGE_SIZE);
+	seq_buf_printf(&s, "file %llu\n",
+		       (u64)memcg_page_state(memcg, MEMCG_CACHE) *
+		       PAGE_SIZE);
+	seq_buf_printf(&s, "kernel_stack %llu\n",
+		       (u64)memcg_page_state(memcg, MEMCG_KERNEL_STACK_KB) *
+		       1024);
+	seq_buf_printf(&s, "slab %llu\n",
+		       (u64)(memcg_page_state(memcg, NR_SLAB_RECLAIMABLE) +
+			     memcg_page_state(memcg, NR_SLAB_UNRECLAIMABLE)) *
+		       PAGE_SIZE);
+	seq_buf_printf(&s, "sock %llu\n",
+		       (u64)memcg_page_state(memcg, MEMCG_SOCK) *
+		       PAGE_SIZE);
+
+	seq_buf_printf(&s, "shmem %llu\n",
+		       (u64)memcg_page_state(memcg, NR_SHMEM) *
+		       PAGE_SIZE);
+	seq_buf_printf(&s, "file_mapped %llu\n",
+		       (u64)memcg_page_state(memcg, NR_FILE_MAPPED) *
+		       PAGE_SIZE);
+	seq_buf_printf(&s, "file_dirty %llu\n",
+		       (u64)memcg_page_state(memcg, NR_FILE_DIRTY) *
+		       PAGE_SIZE);
+	seq_buf_printf(&s, "file_writeback %llu\n",
+		       (u64)memcg_page_state(memcg, NR_WRITEBACK) *
+		       PAGE_SIZE);
+
+	/*
+	 * TODO: We should eventually replace our own MEMCG_RSS_HUGE counter
+	 * with the NR_ANON_THP vm counter, but right now it's a pain in the
+	 * arse because it requires migrating the work out of rmap to a place
+	 * where the page->mem_cgroup is set up and stable.
+	 */
+	seq_buf_printf(&s, "anon_thp %llu\n",
+		       (u64)memcg_page_state(memcg, MEMCG_RSS_HUGE) *
+		       PAGE_SIZE);
+
+	for (i = 0; i < NR_LRU_LISTS; i++)
+		seq_buf_printf(&s, "%s %llu\n", mem_cgroup_lru_names[i],
+			       (u64)memcg_page_state(memcg, NR_LRU_BASE + i) *
+			       PAGE_SIZE);
+
+	seq_buf_printf(&s, "slab_reclaimable %llu\n",
+		       (u64)memcg_page_state(memcg, NR_SLAB_RECLAIMABLE) *
+		       PAGE_SIZE);
+	seq_buf_printf(&s, "slab_unreclaimable %llu\n",
+		       (u64)memcg_page_state(memcg, NR_SLAB_UNRECLAIMABLE) *
+		       PAGE_SIZE);
+
+	/* Accumulated memory events */
+
+	seq_buf_printf(&s, "pgfault %lu\n", memcg_events(memcg, PGFAULT));
+	seq_buf_printf(&s, "pgmajfault %lu\n", memcg_events(memcg, PGMAJFAULT));
+
+	seq_buf_printf(&s, "workingset_refault %lu\n",
+		       memcg_page_state(memcg, WORKINGSET_REFAULT));
+	seq_buf_printf(&s, "workingset_activate %lu\n",
+		       memcg_page_state(memcg, WORKINGSET_ACTIVATE));
+	seq_buf_printf(&s, "workingset_nodereclaim %lu\n",
+		       memcg_page_state(memcg, WORKINGSET_NODERECLAIM));
+
+	seq_buf_printf(&s, "pgrefill %lu\n", memcg_events(memcg, PGREFILL));
+	seq_buf_printf(&s, "pgscan %lu\n",
+		       memcg_events(memcg, PGSCAN_KSWAPD) +
+		       memcg_events(memcg, PGSCAN_DIRECT));
+	seq_buf_printf(&s, "pgsteal %lu\n",
+		       memcg_events(memcg, PGSTEAL_KSWAPD) +
+		       memcg_events(memcg, PGSTEAL_DIRECT));
+	seq_buf_printf(&s, "pgactivate %lu\n", memcg_events(memcg, PGACTIVATE));
+	seq_buf_printf(&s, "pgdeactivate %lu\n", memcg_events(memcg, PGDEACTIVATE));
+	seq_buf_printf(&s, "pglazyfree %lu\n", memcg_events(memcg, PGLAZYFREE));
+	seq_buf_printf(&s, "pglazyfreed %lu\n", memcg_events(memcg, PGLAZYFREED));
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	seq_buf_printf(&s, "thp_fault_alloc %lu\n",
+		       memcg_events(memcg, THP_FAULT_ALLOC));
+	seq_buf_printf(&s, "thp_collapse_alloc %lu\n",
+		       memcg_events(memcg, THP_COLLAPSE_ALLOC));
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+
+	/* The above should easily fit into one page */
+	WARN_ON_ONCE(seq_buf_has_overflowed(&s));
+
+	return s.buffer;
+}
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
 /**
@@ -1420,39 +1508,32 @@ void mem_cgroup_print_oom_context(struct mem_cgroup *memcg, struct task_struct *
  */
 void mem_cgroup_print_oom_meminfo(struct mem_cgroup *memcg)
 {
-	struct mem_cgroup *iter;
-	unsigned int i;
+	char *buf;
 
 	pr_info("memory: usage %llukB, limit %llukB, failcnt %lu\n",
 		K((u64)page_counter_read(&memcg->memory)),
 		K((u64)memcg->memory.max), memcg->memory.failcnt);
-	pr_info("memory+swap: usage %llukB, limit %llukB, failcnt %lu\n",
-		K((u64)page_counter_read(&memcg->memsw)),
-		K((u64)memcg->memsw.max), memcg->memsw.failcnt);
-	pr_info("kmem: usage %llukB, limit %llukB, failcnt %lu\n",
-		K((u64)page_counter_read(&memcg->kmem)),
-		K((u64)memcg->kmem.max), memcg->kmem.failcnt);
-
-	for_each_mem_cgroup_tree(iter, memcg) {
-		pr_info("Memory cgroup stats for ");
-		pr_cont_cgroup_path(iter->css.cgroup);
-		pr_cont(":");
-
-		for (i = 0; i < ARRAY_SIZE(memcg1_stats); i++) {
-			if (memcg1_stats[i] == MEMCG_SWAP && !do_swap_account)
-				continue;
-			pr_cont(" %s:%luKB", memcg1_stat_names[i],
-				K(memcg_page_state_local(iter,
-							 memcg1_stats[i])));
-		}
-
-		for (i = 0; i < NR_LRU_LISTS; i++)
-			pr_cont(" %s:%luKB", mem_cgroup_lru_names[i],
-				K(memcg_page_state_local(iter,
-							 NR_LRU_BASE + i)));
-
-		pr_cont("\n");
+	if (cgroup_subsys_on_dfl(memory_cgrp_subsys))
+		pr_info("swap: usage %llukB, limit %llukB, failcnt %lu\n",
+			K((u64)page_counter_read(&memcg->swap)),
+			K((u64)memcg->swap.max), memcg->swap.failcnt);
+	else {
+		pr_info("memory+swap: usage %llukB, limit %llukB, failcnt %lu\n",
+			K((u64)page_counter_read(&memcg->memsw)),
+			K((u64)memcg->memsw.max), memcg->memsw.failcnt);
+		pr_info("kmem: usage %llukB, limit %llukB, failcnt %lu\n",
+			K((u64)page_counter_read(&memcg->kmem)),
+			K((u64)memcg->kmem.max), memcg->kmem.failcnt);
 	}
+
+	pr_info("Memory cgroup stats for ");
+	pr_cont_cgroup_path(memcg->css.cgroup);
+	pr_cont(":");
+	buf = memory_stat_format(memcg);
+	if (!buf)
+		return;
+	pr_info("%s", buf);
+	kvfree(buf);
 }
 
 /*
@@ -3484,6 +3565,28 @@ static int memcg_numa_stat_show(struct seq_file *m, void *v)
 }
 #endif /* CONFIG_NUMA */
 
+static const unsigned int memcg1_stats[] = {
+	MEMCG_CACHE,
+	MEMCG_RSS,
+	MEMCG_RSS_HUGE,
+	NR_SHMEM,
+	NR_FILE_MAPPED,
+	NR_FILE_DIRTY,
+	NR_WRITEBACK,
+	MEMCG_SWAP,
+};
+
+static const char *const memcg1_stat_names[] = {
+	"cache",
+	"rss",
+	"rss_huge",
+	"shmem",
+	"mapped_file",
+	"dirty",
+	"writeback",
+	"swap",
+};
+
 /* Universal VM events cgroup1 shows, original sort order */
 static const unsigned int memcg1_events[] = {
 	PGPGIN,
@@ -5666,91 +5769,13 @@ static int memory_events_local_show(struct seq_file *m, void *v)
 static int memory_stat_show(struct seq_file *m, void *v)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_seq(m);
-	int i;
-
-	/*
-	 * Provide statistics on the state of the memory subsystem as
-	 * well as cumulative event counters that show past behavior.
-	 *
-	 * This list is ordered following a combination of these gradients:
-	 * 1) generic big picture -> specifics and details
-	 * 2) reflecting userspace activity -> reflecting kernel heuristics
-	 *
-	 * Current memory state:
-	 */
-
-	seq_printf(m, "anon %llu\n",
-		   (u64)memcg_page_state(memcg, MEMCG_RSS) * PAGE_SIZE);
-	seq_printf(m, "file %llu\n",
-		   (u64)memcg_page_state(memcg, MEMCG_CACHE) * PAGE_SIZE);
-	seq_printf(m, "kernel_stack %llu\n",
-		   (u64)memcg_page_state(memcg, MEMCG_KERNEL_STACK_KB) * 1024);
-	seq_printf(m, "slab %llu\n",
-		   (u64)(memcg_page_state(memcg, NR_SLAB_RECLAIMABLE) +
-			 memcg_page_state(memcg, NR_SLAB_UNRECLAIMABLE)) *
-		   PAGE_SIZE);
-	seq_printf(m, "sock %llu\n",
-		   (u64)memcg_page_state(memcg, MEMCG_SOCK) * PAGE_SIZE);
-
-	seq_printf(m, "shmem %llu\n",
-		   (u64)memcg_page_state(memcg, NR_SHMEM) * PAGE_SIZE);
-	seq_printf(m, "file_mapped %llu\n",
-		   (u64)memcg_page_state(memcg, NR_FILE_MAPPED) * PAGE_SIZE);
-	seq_printf(m, "file_dirty %llu\n",
-		   (u64)memcg_page_state(memcg, NR_FILE_DIRTY) * PAGE_SIZE);
-	seq_printf(m, "file_writeback %llu\n",
-		   (u64)memcg_page_state(memcg, NR_WRITEBACK) * PAGE_SIZE);
-
-	/*
-	 * TODO: We should eventually replace our own MEMCG_RSS_HUGE counter
-	 * with the NR_ANON_THP vm counter, but right now it's a pain in the
-	 * arse because it requires migrating the work out of rmap to a place
-	 * where the page->mem_cgroup is set up and stable.
-	 */
-	seq_printf(m, "anon_thp %llu\n",
-		   (u64)memcg_page_state(memcg, MEMCG_RSS_HUGE) * PAGE_SIZE);
-
-	for (i = 0; i < NR_LRU_LISTS; i++)
-		seq_printf(m, "%s %llu\n", mem_cgroup_lru_names[i],
-			   (u64)memcg_page_state(memcg, NR_LRU_BASE + i) *
-			   PAGE_SIZE);
-
-	seq_printf(m, "slab_reclaimable %llu\n",
-		   (u64)memcg_page_state(memcg, NR_SLAB_RECLAIMABLE) *
-		   PAGE_SIZE);
-	seq_printf(m, "slab_unreclaimable %llu\n",
-		   (u64)memcg_page_state(memcg, NR_SLAB_UNRECLAIMABLE) *
-		   PAGE_SIZE);
-
-	/* Accumulated memory events */
-
-	seq_printf(m, "pgfault %lu\n", memcg_events(memcg, PGFAULT));
-	seq_printf(m, "pgmajfault %lu\n", memcg_events(memcg, PGMAJFAULT));
-
-	seq_printf(m, "workingset_refault %lu\n",
-		   memcg_page_state(memcg, WORKINGSET_REFAULT));
-	seq_printf(m, "workingset_activate %lu\n",
-		   memcg_page_state(memcg, WORKINGSET_ACTIVATE));
-	seq_printf(m, "workingset_nodereclaim %lu\n",
-		   memcg_page_state(memcg, WORKINGSET_NODERECLAIM));
-
-	seq_printf(m, "pgrefill %lu\n", memcg_events(memcg, PGREFILL));
-	seq_printf(m, "pgscan %lu\n", memcg_events(memcg, PGSCAN_KSWAPD) +
-		   memcg_events(memcg, PGSCAN_DIRECT));
-	seq_printf(m, "pgsteal %lu\n", memcg_events(memcg, PGSTEAL_KSWAPD) +
-		   memcg_events(memcg, PGSTEAL_DIRECT));
-	seq_printf(m, "pgactivate %lu\n", memcg_events(memcg, PGACTIVATE));
-	seq_printf(m, "pgdeactivate %lu\n", memcg_events(memcg, PGDEACTIVATE));
-	seq_printf(m, "pglazyfree %lu\n", memcg_events(memcg, PGLAZYFREE));
-	seq_printf(m, "pglazyfreed %lu\n", memcg_events(memcg, PGLAZYFREED));
-
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	seq_printf(m, "thp_fault_alloc %lu\n",
-		   memcg_events(memcg, THP_FAULT_ALLOC));
-	seq_printf(m, "thp_collapse_alloc %lu\n",
-		   memcg_events(memcg, THP_COLLAPSE_ALLOC));
-#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+	char *buf;
 
+	buf = memory_stat_format(memcg);
+	if (!buf)
+		return -ENOMEM;
+	seq_puts(m, buf);
+	kvfree(buf);
 	return 0;
 }
 
-- 
2.21.0

