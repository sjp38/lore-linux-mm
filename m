Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id 37E6B6B0037
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 19:58:39 -0500 (EST)
Received: by mail-ee0-f50.google.com with SMTP id d17so3948066eek.37
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 16:58:38 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id k3si38625226eep.183.2014.02.03.16.58.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Feb 2014 16:58:38 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 01/10] mm: vmstat: fix UP zone state accounting
Date: Mon,  3 Feb 2014 19:53:33 -0500
Message-Id: <1391475222-1169-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1391475222-1169-1-git-send-email-hannes@cmpxchg.org>
References: <1391475222-1169-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Bob Liu <bob.liu@oracle.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Fengguang Wu's build testing spotted problems with inc_zone_state()
and dec_zone_state() on UP configurations in out-of-tree patches.

inc_zone_state() is declared but not defined, dec_zone_state() is
missing entirely.

Just like with *_zone_page_state(), they can be defined like their
preemption-unsafe counterparts on UP.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/vmstat.h | 29 +++++++++++++++--------------
 1 file changed, 15 insertions(+), 14 deletions(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index a67b38415768..a32dbd2c2155 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -179,8 +179,6 @@ extern void zone_statistics(struct zone *, struct zone *, gfp_t gfp);
 #define add_zone_page_state(__z, __i, __d) mod_zone_page_state(__z, __i, __d)
 #define sub_zone_page_state(__z, __i, __d) mod_zone_page_state(__z, __i, -(__d))
 
-extern void inc_zone_state(struct zone *, enum zone_stat_item);
-
 #ifdef CONFIG_SMP
 void __mod_zone_page_state(struct zone *, enum zone_stat_item item, int);
 void __inc_zone_page_state(struct page *, enum zone_stat_item);
@@ -216,24 +214,12 @@ static inline void __mod_zone_page_state(struct zone *zone,
 	zone_page_state_add(delta, zone, item);
 }
 
-static inline void __inc_zone_state(struct zone *zone, enum zone_stat_item item)
-{
-	atomic_long_inc(&zone->vm_stat[item]);
-	atomic_long_inc(&vm_stat[item]);
-}
-
 static inline void __inc_zone_page_state(struct page *page,
 			enum zone_stat_item item)
 {
 	__inc_zone_state(page_zone(page), item);
 }
 
-static inline void __dec_zone_state(struct zone *zone, enum zone_stat_item item)
-{
-	atomic_long_dec(&zone->vm_stat[item]);
-	atomic_long_dec(&vm_stat[item]);
-}
-
 static inline void __dec_zone_page_state(struct page *page,
 			enum zone_stat_item item)
 {
@@ -248,6 +234,21 @@ static inline void __dec_zone_page_state(struct page *page,
 #define dec_zone_page_state __dec_zone_page_state
 #define mod_zone_page_state __mod_zone_page_state
 
+static inline void __inc_zone_state(struct zone *zone, enum zone_stat_item item)
+{
+	atomic_long_inc(&zone->vm_stat[item]);
+	atomic_long_inc(&vm_stat[item]);
+}
+
+static inline void __dec_zone_state(struct zone *zone, enum zone_stat_item item)
+{
+	atomic_long_dec(&zone->vm_stat[item]);
+	atomic_long_dec(&vm_stat[item]);
+}
+
+#define inc_zone_state __inc_zone_state
+#define dec_zone_state __dec_zone_state
+
 #define set_pgdat_percpu_threshold(pgdat, callback) { }
 
 static inline void refresh_cpu_vm_stats(int cpu) { }
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
