Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id C0E846B0007
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 15:15:52 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id a125so16849724qkd.4
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 12:15:52 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id n68si2365054qke.240.2018.04.25.12.15.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Apr 2018 12:15:51 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH] mm: don't show nr_indirectly_reclaimable in /proc/vmstat
Date: Wed, 25 Apr 2018 20:14:22 +0100
Message-ID: <20180425191422.9159-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, kernel-team@fb.com, Roman Gushchin <guro@fb.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>

Don't show nr_indirectly_reclaimable in /proc/vmstat,
because there is no need in exporting this vm counter
to the userspace, and some changes are expected
in reclaimable object accounting, which can alter
this counter.

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmstat.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 536332e988b8..a2b9518980ce 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1161,7 +1161,7 @@ const char * const vmstat_text[] = {
 	"nr_vmscan_immediate_reclaim",
 	"nr_dirtied",
 	"nr_written",
-	"nr_indirectly_reclaimable",
+	"", /* nr_indirectly_reclaimable */
 
 	/* enum writeback_stat_item counters */
 	"nr_dirty_threshold",
@@ -1740,6 +1740,10 @@ static int vmstat_show(struct seq_file *m, void *arg)
 	unsigned long *l = arg;
 	unsigned long off = l - (unsigned long *)m->private;
 
+	/* Skip hidden vmstat items. */
+	if (*vmstat_text[off] == '\0')
+		return 0;
+
 	seq_puts(m, vmstat_text[off]);
 	seq_put_decimal_ull(m, " ", *l);
 	seq_putc(m, '\n');
-- 
2.14.3
