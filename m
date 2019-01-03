Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E8DDF8E00AE
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 17:57:15 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id x15so34467353edd.2
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 14:57:15 -0800 (PST)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id d8si139059edo.400.2019.01.03.14.57.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 14:57:14 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id EC22798A4E
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 22:57:13 +0000 (UTC)
Date: Thu, 3 Jan 2019 22:57:12 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH] mm, page_alloc: Do not wake kswapd with zone lock held
Message-ID: <20190103225712.GJ31517@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Qian Cai <cai@lca.pw>, Dmitry Vyukov <dvyukov@google.com>, Vlastimil Babka <vbabka@suse.cz>, syzbot <syzbot+93d94a001cfbce9e60e1@syzkaller.appspotmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux@dominikbrodowski.net, Michal Hocko <mhocko@suse.com>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>

syzbot reported the following regression in the latest merge window
and it was confirmed by Qian Cai that a similar bug was visible from a
different context.

======================================================
WARNING: possible circular locking dependency detected
4.20.0+ #297 Not tainted
------------------------------------------------------
syz-executor0/8529 is trying to acquire lock:
000000005e7fb829 (&pgdat->kswapd_wait){....}, at:
__wake_up_common_lock+0x19e/0x330 kernel/sched/wait.c:120

but task is already holding lock:
000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at: spin_lock
include/linux/spinlock.h:329 [inline]
000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at: rmqueue_bulk
mm/page_alloc.c:2548 [inline]
000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at: __rmqueue_pcplist
mm/page_alloc.c:3021 [inline]
000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at: rmqueue_pcplist
mm/page_alloc.c:3050 [inline]
000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at: rmqueue
mm/page_alloc.c:3072 [inline]
000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at:
get_page_from_freelist+0x1bae/0x52a0 mm/page_alloc.c:3491

It appears to be a false positive in that the only way the lock
ordering should be inverted is if kswapd is waking itself and the
wakeup allocates debugging objects which should already be allocated
if it's kswapd doing the waking. Nevertheless, the possibility exists
and so it's best to avoid the problem.

This patch flags a zone as needing a kswapd using the, surprisingly,
unused zone flag field. The flag is read without the lock held to
do the wakeup. It's possible that the flag setting context is not
the same as the flag clearing context or for small races to occur.
However, each race possibility is harmless and there is no visible
degredation in fragmentation treatment.

While zone->flag could have continued to be unused, there is potential
for moving some existing fields into the flags field instead. Particularly
read-mostly ones like zone->initialized and zone->contiguous.

Reported-by: syzbot+93d94a001cfbce9e60e1@syzkaller.appspotmail.com
Tested-by: Qian Cai <cai@lca.pw>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/mmzone.h | 6 ++++++
 mm/page_alloc.c        | 8 +++++++-
 2 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index cc4a507d7ca4..842f9189537b 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -520,6 +520,12 @@ enum pgdat_flags {
 	PGDAT_RECLAIM_LOCKED,		/* prevents concurrent reclaim */
 };
 
+enum zone_flags {
+	ZONE_BOOSTED_WATERMARK,		/* zone recently boosted watermarks.
+					 * Cleared when kswapd is woken.
+					 */
+};
+
 static inline unsigned long zone_managed_pages(struct zone *zone)
 {
 	return (unsigned long)atomic_long_read(&zone->managed_pages);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cde5dac6229a..d295c9bc01a8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2214,7 +2214,7 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 	 */
 	boost_watermark(zone);
 	if (alloc_flags & ALLOC_KSWAPD)
-		wakeup_kswapd(zone, 0, 0, zone_idx(zone));
+		set_bit(ZONE_BOOSTED_WATERMARK, &zone->flags);
 
 	/* We are not allowed to try stealing from the whole block */
 	if (!whole_block)
@@ -3102,6 +3102,12 @@ struct page *rmqueue(struct zone *preferred_zone,
 	local_irq_restore(flags);
 
 out:
+	/* Separate test+clear to avoid unnecessary atomics */
+	if (test_bit(ZONE_BOOSTED_WATERMARK, &zone->flags)) {
+		clear_bit(ZONE_BOOSTED_WATERMARK, &zone->flags);
+		wakeup_kswapd(zone, 0, 0, zone_idx(zone));
+	}
+
 	VM_BUG_ON_PAGE(page && bad_range(zone, page), page);
 	return page;
 
