Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B3C706B0596
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 22:24:38 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id p15so135440715pgs.7
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 19:24:38 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id e4si1485454pgn.444.2017.07.15.19.24.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 19:24:37 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH 03/10] percpu: expose pcpu_nr_empty_pop_pages in pcpu_stats
Date: Sat, 15 Jul 2017 22:23:08 -0400
Message-ID: <20170716022315.19892-4-dennisz@fb.com>
In-Reply-To: <20170716022315.19892-1-dennisz@fb.com>
References: <20170716022315.19892-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>
Cc: kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dennis Zhou <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

Percpu memory holds a minimum threshold of pages that are populated
in order to serve atomic percpu memory requests. This change makes it
easier to verify that there are a minimum number of populated pages
lying around.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 mm/percpu-internal.h | 1 +
 mm/percpu-stats.c    | 1 +
 mm/percpu.c          | 2 +-
 3 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/percpu-internal.h b/mm/percpu-internal.h
index cd2442e..c9158a4 100644
--- a/mm/percpu-internal.h
+++ b/mm/percpu-internal.h
@@ -36,6 +36,7 @@ extern spinlock_t pcpu_lock;
 
 extern struct list_head *pcpu_slot;
 extern int pcpu_nr_slots;
+extern int pcpu_nr_empty_pop_pages;
 
 extern struct pcpu_chunk *pcpu_first_chunk;
 extern struct pcpu_chunk *pcpu_reserved_chunk;
diff --git a/mm/percpu-stats.c b/mm/percpu-stats.c
index fa0f5de..44e561d 100644
--- a/mm/percpu-stats.c
+++ b/mm/percpu-stats.c
@@ -164,6 +164,7 @@ static int percpu_stats_show(struct seq_file *m, void *v)
 	PU(nr_max_chunks);
 	PU(min_alloc_size);
 	PU(max_alloc_size);
+	P("empty_pop_pages", pcpu_nr_empty_pop_pages);
 	seq_putc(m, '\n');
 
 #undef PU
diff --git a/mm/percpu.c b/mm/percpu.c
index bd4130a..9ec5fd4 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -160,7 +160,7 @@ static LIST_HEAD(pcpu_map_extend_chunks);
  * The number of empty populated pages, protected by pcpu_lock.  The
  * reserved chunk doesn't contribute to the count.
  */
-static int pcpu_nr_empty_pop_pages;
+int pcpu_nr_empty_pop_pages;
 
 /*
  * Balance work is used to populate or destroy chunks asynchronously.  We
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
