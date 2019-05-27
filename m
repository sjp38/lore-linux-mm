Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02490C04AB3
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 10:06:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 663DB2146F
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 10:06:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="IQgEK7oQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 663DB2146F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 013F66B0271; Mon, 27 May 2019 06:06:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFFA66B0272; Mon, 27 May 2019 06:06:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA7656B0273; Mon, 27 May 2019 06:06:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6B4556B0271
	for <linux-mm@kvack.org>; Mon, 27 May 2019 06:06:02 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id 7so3086498ljr.23
        for <linux-mm@kvack.org>; Mon, 27 May 2019 03:06:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:user-agent:mime-version:content-transfer-encoding;
        bh=CQxEERr1BIi9CCcIXn6D3UIoYJZJlgFtBTDB1IkaSu8=;
        b=KFRZEn931ZMQlAVouHgjXZdG9DK+gnIFYsPB6uJIcWmGMzXyu4A83lAK6VKrOp/ECi
         CEVRKI3i2BCL4QN1TsBX1j9FVwOA3RDgrI0N41zjDOjcl7tegonB4rdahRl6HMTk0Trs
         sAg6h+6S0lm4wbMKXxxAcnNjZgSGhubEXIlydJRnwZMrBO41E2MYc6ERhX9d10nXykFi
         CkaW+RCbSvBczeM1LnO8sXJrlOm7A3QztczYyo15ZHL1QYOooqFwU4GpgARfiM64k8JE
         Vtq9LGjjIPjPwdBONQJ2tRf3TAj20XUtWV0kDLV2OUyOtg2OCTjdsw5chZFM9xf0rv+0
         KYzw==
X-Gm-Message-State: APjAAAXZ8i0/y8USncFKgjhhpKv2E/tkSvUVrg/mFqnGH2GVyifAs3/X
	9Bs+vVvGtGTcn7aAZdZpTAEeIY0VALjUoXiud9hsQgMstkASkuX0CT1SpYEPgv9M/6rr7VHcqIi
	ew/AuS/bN3dWjavQWq+hHu0t8bm8dxv3PNiKDbISOWD6e/lh4iy93WKwQrkMpakzEMg==
X-Received: by 2002:a2e:3a17:: with SMTP id h23mr4878061lja.155.1558951561836;
        Mon, 27 May 2019 03:06:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwlDq2HdFrIi8DW0PTfMIVuT1q7EWC2mjFZXcdSX7VyzkZBOIiFFqewHdYmD9gaw8DeyKey
X-Received: by 2002:a2e:3a17:: with SMTP id h23mr4878004lja.155.1558951560729;
        Mon, 27 May 2019 03:06:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558951560; cv=none;
        d=google.com; s=arc-20160816;
        b=Afg2HLDVwWQgxPcHsWNXPLZJ/uvkly8i+bGGK+B1opwEJcHn3CmthozokknkGAUSiS
         W9vDsJ7O1HFCnGLVXbqr8Ieilml3fsokzL2LXBhIcLGveraADGVtsCt7dH5oideTStwq
         V7M1bYtIASUS0D3VLRGvqQyEh8IJ6kcjLy0V0B92VTCbzTrYX1nzIzIEj5XKGOZWptZg
         fB5gbgFsn4i1kBdiN4x/V01d7MNGO8VtI288PuAj98nRVQZg08IH1rAiW4pQUGKg+zfs
         SwZ8cxdRT/9J0cFlVb3eRpYHnH9uGD7xrCAwrIa+PgQDQyMHLwNx0/L0mkyzS9rOnmeE
         wjtQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject:dkim-signature;
        bh=CQxEERr1BIi9CCcIXn6D3UIoYJZJlgFtBTDB1IkaSu8=;
        b=Y1afdWOlEF7SFhyF+n+IP0avGjGC2lAFRpVs8PaHCcbTBGOdFWNlpe7E5cW3zUv9vJ
         teEDEvmcmsLnk/QPJkJdnY3k/1c40va3fC/Alpi9Xb39akrbo6UuJ5Qm5sBJRemo7ytz
         gMttRnXY8qK70gH5fhXZee7YzB1IEOb2ycaRckRlfTzD/UeZzjhwP7t/EzeQ05huwZ2t
         aFhQko9/A1nXAwnMxMFIymeiyuAl8+lTOoM4F7bKnOmy6f7sKDuPn9cYj37m6TYpLrNy
         5SdRjwTLs4an4a9vG8OiyB3iCq4Bd2gjj/Jj49GvBBHUaHqFYkJAebm4AH9G8mgbecJQ
         EqKg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=IQgEK7oQ;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 95.108.205.193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1o.mail.yandex.net (forwardcorp1o.mail.yandex.net. [95.108.205.193])
        by mx.google.com with ESMTPS id t6si11351584ljh.135.2019.05.27.03.06.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 03:06:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 95.108.205.193 as permitted sender) client-ip=95.108.205.193;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=IQgEK7oQ;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 95.108.205.193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1j.mail.yandex.net (mxbackcorp1j.mail.yandex.net [IPv6:2a02:6b8:0:1619::162])
	by forwardcorp1o.mail.yandex.net (Yandex) with ESMTP id 1F30B2E0954;
	Mon, 27 May 2019 13:06:00 +0300 (MSK)
Received: from smtpcorp1o.mail.yandex.net (smtpcorp1o.mail.yandex.net [2a02:6b8:0:1a2d::30])
	by mxbackcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id OwJn8zAnJQ-5wpmSr5g;
	Mon, 27 May 2019 13:06:00 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1558951560; bh=CQxEERr1BIi9CCcIXn6D3UIoYJZJlgFtBTDB1IkaSu8=;
	h=Message-ID:Date:To:From:Subject:Cc;
	b=IQgEK7oQm8wis5bpbA8YwPhFP2T7VClcMSokHBBCYQ4qCjG0zBDL6cO3BImi/e7oq
	 G+ZRiGSYMArxMg2Fa78/w5wSBC2r2x/euqAecttbszz8EahWvJoUYxKpKLw5pUeXqS
	 FIh/N5j0jpBBAuuUhvz0lF5a/I6FSqU5HgmaeOdM=
Authentication-Results: mxbackcorp1j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:d877:17c:81de:6e43])
	by smtpcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id L1algiQOax-5wluW1QG;
	Mon, 27 May 2019 13:05:58 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: [PATCH RFC] mm/madvise: implement MADV_STOCKPILE (kswapd from user
 space)
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>,
 Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Mel Gorman <mgorman@techsingularity.net>, Roman Gushchin <guro@fb.com>
Date: Mon, 27 May 2019 13:05:58 +0300
Message-ID: <155895155861.2824.318013775811596173.stgit@buzz>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Memory cgroup has no background memory reclaimer. Reclaiming after passing
high-limit blocks task because works synchronously in task-work.

This implements manual kswapd-style memory reclaim initiated by userspace.
It reclaims both physical memory and cgroup pages. It works in context of
task who calls syscall madvise thus cpu time is accounted correctly.

Interface:

ret = madvise(ptr, size, MADV_STOCKPILE)

Returns:
  0         - ok, free memory >= size
  -EINVAL   - not supported
  -ENOMEM   - not enough memory/cgroup limit
  -EINTR    - interrupted by pending signal
  -EAGAIN   - cannot reclaim enough memory

Argument 'size' is interpreted size of required free memory.
Implementation triggers direct reclaim until amount of free memory is
lower than that size. Argument 'ptr' could points to vma for specifying
numa allocation policy, right now should be NULL.

Usage scenario: independent thread or standalone daemon estimates rate of
allocations and calls MADV_STOCKPILE in loop to prepare free pages.
Thus fast path avoids allocation latency induced by direct reclaim.

We are using this embedded into memory allocator based on MADV_FREE.


Demonstration in memory cgroup with limit 1G:

touch zero
truncate -s 5G zero

Without stockpile:

perf stat -e vmscan:* md5sum zero

 Performance counter stats for 'md5sum zero':

                 0      vmscan:mm_vmscan_kswapd_sleep
                 0      vmscan:mm_vmscan_kswapd_wake
                 0      vmscan:mm_vmscan_wakeup_kswapd
                 0      vmscan:mm_vmscan_direct_reclaim_begin
             10147      vmscan:mm_vmscan_memcg_reclaim_begin
                 0      vmscan:mm_vmscan_memcg_softlimit_reclaim_begin
                 0      vmscan:mm_vmscan_direct_reclaim_end
             10147      vmscan:mm_vmscan_memcg_reclaim_end
                 0      vmscan:mm_vmscan_memcg_softlimit_reclaim_end
             99910      vmscan:mm_shrink_slab_start
             99910      vmscan:mm_shrink_slab_end
             39654      vmscan:mm_vmscan_lru_isolate
                 0      vmscan:mm_vmscan_writepage
             39652      vmscan:mm_vmscan_lru_shrink_inactive
                 2      vmscan:mm_vmscan_lru_shrink_active
             19982      vmscan:mm_vmscan_inactive_list_is_low

      10.886832585 seconds time elapsed

       8.928366000 seconds user
       1.935212000 seconds sys

With stockpile:

stockpile 100 10 &   # up to 100M every 10ms
perf stat -e vmscan:* md5sum zero

 Performance counter stats for 'md5sum zero':

                 0      vmscan:mm_vmscan_kswapd_sleep
                 0      vmscan:mm_vmscan_kswapd_wake
                 0      vmscan:mm_vmscan_wakeup_kswapd
                 0      vmscan:mm_vmscan_direct_reclaim_begin
                 0      vmscan:mm_vmscan_memcg_reclaim_begin
                 0      vmscan:mm_vmscan_memcg_softlimit_reclaim_begin
                 0      vmscan:mm_vmscan_direct_reclaim_end
                 0      vmscan:mm_vmscan_memcg_reclaim_end
                 0      vmscan:mm_vmscan_memcg_softlimit_reclaim_end
                 0      vmscan:mm_shrink_slab_start
                 0      vmscan:mm_shrink_slab_end
                 0      vmscan:mm_vmscan_lru_isolate
                 0      vmscan:mm_vmscan_writepage
                 0      vmscan:mm_vmscan_lru_shrink_inactive
                 0      vmscan:mm_vmscan_lru_shrink_active
                 0      vmscan:mm_vmscan_inactive_list_is_low

      10.469776675 seconds time elapsed

       8.976261000 seconds user
       1.491378000 seconds sys

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 include/linux/memcontrol.h             |    6 +++++
 include/uapi/asm-generic/mman-common.h |    2 ++
 mm/madvise.c                           |   39 ++++++++++++++++++++++++++++++
 mm/memcontrol.c                        |   41 ++++++++++++++++++++++++++++++++
 tools/vm/Makefile                      |    2 +-
 tools/vm/stockpile.c                   |   30 +++++++++++++++++++++++
 6 files changed, 119 insertions(+), 1 deletion(-)
 create mode 100644 tools/vm/stockpile.c

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index bc74d6a4407c..25325f18ad55 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -517,6 +517,7 @@ unsigned long mem_cgroup_get_zone_lru_size(struct lruvec *lruvec,
 }
 
 void mem_cgroup_handle_over_high(void);
+int mem_cgroup_stockpile(unsigned long goal_pages);
 
 unsigned long mem_cgroup_get_max(struct mem_cgroup *memcg);
 
@@ -968,6 +969,11 @@ static inline void mem_cgroup_handle_over_high(void)
 {
 }
 
+static inline int mem_cgroup_stockpile(unsigned long goal_page)
+{
+	return 0;
+}
+
 static inline void mem_cgroup_enter_user_fault(void)
 {
 }
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index abd238d0f7a4..675145864fee 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -64,6 +64,8 @@
 #define MADV_WIPEONFORK 18		/* Zero memory on fork, child only */
 #define MADV_KEEPONFORK 19		/* Undo MADV_WIPEONFORK */
 
+#define MADV_STOCKPILE	20		/* stockpile free pages */
+
 /* compatibility flags */
 #define MAP_FILE	0
 
diff --git a/mm/madvise.c b/mm/madvise.c
index 628022e674a7..f908b08ecc9f 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -686,6 +686,41 @@ static int madvise_inject_error(int behavior,
 }
 #endif
 
+static long madvise_stockpile(unsigned long start, size_t len)
+{
+	unsigned long goal_pages, progress;
+	struct zonelist *zonelist;
+	int ret;
+
+	if (start)
+		return -EINVAL;
+
+	goal_pages = len >> PAGE_SHIFT;
+
+	if (goal_pages > totalram_pages() - totalreserve_pages)
+		return -ENOMEM;
+
+	ret = mem_cgroup_stockpile(goal_pages);
+	if (ret)
+		return ret;
+
+	/* TODO: use vma mempolicy */
+	zonelist = node_zonelist(numa_node_id(), GFP_HIGHUSER);
+
+	while (global_zone_page_state(NR_FREE_PAGES) <
+			goal_pages + totalreserve_pages) {
+
+		if (signal_pending(current))
+			return -EINTR;
+
+		progress = try_to_free_pages(zonelist, 0, GFP_HIGHUSER, NULL);
+		if (!progress)
+			return -EAGAIN;
+	}
+
+	return 0;
+}
+
 static long
 madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 		unsigned long start, unsigned long end, int behavior)
@@ -728,6 +763,7 @@ madvise_behavior_valid(int behavior)
 	case MADV_DODUMP:
 	case MADV_WIPEONFORK:
 	case MADV_KEEPONFORK:
+	case MADV_STOCKPILE:
 #ifdef CONFIG_MEMORY_FAILURE
 	case MADV_SOFT_OFFLINE:
 	case MADV_HWPOISON:
@@ -834,6 +870,9 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 		return madvise_inject_error(behavior, start, start + len_in);
 #endif
 
+	if (behavior == MADV_STOCKPILE)
+		return madvise_stockpile(start, len);
+
 	write = madvise_need_mmap_write(behavior);
 	if (write) {
 		if (down_write_killable(&current->mm->mmap_sem))
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e50a2db5b4ff..dc23dc6bbeb3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2276,6 +2276,47 @@ void mem_cgroup_handle_over_high(void)
 	current->memcg_nr_pages_over_high = 0;
 }
 
+int mem_cgroup_stockpile(unsigned long goal_pages)
+{
+	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
+	unsigned long limit, nr_free, progress;
+	struct mem_cgroup *memcg, *pos;
+	int ret = 0;
+
+	pos = memcg = get_mem_cgroup_from_mm(current->mm);
+
+retry:
+	if (signal_pending(current)) {
+		ret = -EINTR;
+		goto out;
+	}
+
+	limit = min(pos->memory.max, pos->high);
+	if (goal_pages > limit) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	nr_free = limit - page_counter_read(&pos->memory);
+	if ((long)nr_free < (long)goal_pages) {
+		progress = try_to_free_mem_cgroup_pages(pos,
+				goal_pages - nr_free, GFP_HIGHUSER, true);
+		if (progress || nr_retries--)
+			goto retry;
+		ret = -EAGAIN;
+		goto out;
+	}
+
+	nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
+	pos = parent_mem_cgroup(pos);
+	if (pos)
+		goto retry;
+
+out:
+	css_put(&memcg->css);
+	return ret;
+}
+
 static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 		      unsigned int nr_pages)
 {
diff --git a/tools/vm/Makefile b/tools/vm/Makefile
index 20f6cf04377f..e5b5bc0d9421 100644
--- a/tools/vm/Makefile
+++ b/tools/vm/Makefile
@@ -1,7 +1,7 @@
 # SPDX-License-Identifier: GPL-2.0
 # Makefile for vm tools
 #
-TARGETS=page-types slabinfo page_owner_sort
+TARGETS=page-types slabinfo page_owner_sort stockpile
 
 LIB_DIR = ../lib/api
 LIBS = $(LIB_DIR)/libapi.a
diff --git a/tools/vm/stockpile.c b/tools/vm/stockpile.c
new file mode 100644
index 000000000000..245e24f293ec
--- /dev/null
+++ b/tools/vm/stockpile.c
@@ -0,0 +1,30 @@
+// SPDX-License-Identifier: GPL-2.0
+#include <sys/mman.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <err.h>
+#include <errno.h>
+
+#ifndef MADV_STOCKPILE
+# define MADV_STOCKPILE	20
+#endif
+
+int main(int argc, char **argv)
+{
+	int interval;
+	size_t size;
+	int ret;
+
+	if (argc != 3)
+		errx(1, "usage: %s <size_mb> <interval_ms>", argv[0]);
+
+	size = atol(argv[1]) << 20;
+	interval = atoi(argv[2]) * 1000;
+
+	while (1) {
+		ret = madvise(NULL, size, MADV_STOCKPILE);
+		if (ret && errno != EAGAIN)
+			err(2, "madvise(NULL, %zu, MADV_STOCKPILE)", size);
+		usleep(interval);
+	}
+}

