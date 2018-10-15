Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 003F16B0266
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 14:38:47 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id m67-v6so18173926ita.8
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 11:38:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k14-v6sor5177950iog.54.2018.10.15.11.38.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Oct 2018 11:38:47 -0700 (PDT)
From: Yu Zhao <yuzhao@google.com>
Subject: [PATCH] mm: detect numbers of vmstat keys/values mismatch
Date: Mon, 15 Oct 2018 12:38:41 -0600
Message-Id: <20181015183841.114341-1-yuzhao@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>
Cc: Jan Kara <jack@suse.cz>, David Rientjes <rientjes@google.com>, Kemi Wang <kemi.wang@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Steven Rostedt <rostedt@goodmis.org>, Roman Gushchin <guro@fb.com>, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Yu Zhao <yuzhao@google.com>

There were mismatches between number of vmstat keys and number of
vmstat values. They were fixed recently by:
  commit 58bc4c34d249 ("mm/vmstat.c: skip NR_TLB_REMOTE_FLUSH* properly")
  commit 28e2c4bb99aa ("mm/vmstat.c: fix outdated vmstat_text")

Add a BUILD_BUG_ON to detect such mismatch and hopefully prevent
it from happening again.

Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 include/linux/vmstat.h |  4 ++++
 mm/vmstat.c            | 18 ++++++++----------
 2 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index f25cef84b41d..33fdd37124cb 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -78,6 +78,10 @@ extern void vm_events_fold_cpu(int cpu);
 
 #else
 
+struct vm_event_state {
+	unsigned long event[0];
+};
+
 /* Disable counters */
 static inline void count_vm_event(enum vm_event_item item)
 {
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 7878da76abf2..7ebf871b4cc9 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1647,23 +1647,21 @@ enum writeback_stat_item {
 	NR_VM_WRITEBACK_STAT_ITEMS,
 };
 
+#define NR_VM_STAT_ITEMS (NR_VM_ZONE_STAT_ITEMS + NR_VM_NUMA_STAT_ITEMS + \
+			  NR_VM_NODE_STAT_ITEMS + NR_VM_WRITEBACK_STAT_ITEMS + \
+			  ARRAY_SIZE(((struct vm_event_state *)0)->event))
+
 static void *vmstat_start(struct seq_file *m, loff_t *pos)
 {
+	int i;
 	unsigned long *v;
-	int i, stat_items_size;
+
+	BUILD_BUG_ON(ARRAY_SIZE(vmstat_text) != NR_VM_STAT_ITEMS);
 
 	if (*pos >= ARRAY_SIZE(vmstat_text))
 		return NULL;
-	stat_items_size = NR_VM_ZONE_STAT_ITEMS * sizeof(unsigned long) +
-			  NR_VM_NUMA_STAT_ITEMS * sizeof(unsigned long) +
-			  NR_VM_NODE_STAT_ITEMS * sizeof(unsigned long) +
-			  NR_VM_WRITEBACK_STAT_ITEMS * sizeof(unsigned long);
-
-#ifdef CONFIG_VM_EVENT_COUNTERS
-	stat_items_size += sizeof(struct vm_event_state);
-#endif
 
-	v = kmalloc(stat_items_size, GFP_KERNEL);
+	v = kmalloc_array(NR_VM_STAT_ITEMS, sizeof(unsigned long), GFP_KERNEL);
 	m->private = v;
 	if (!v)
 		return ERR_PTR(-ENOMEM);
-- 
2.19.1.331.ge82ca0e54c-goog
