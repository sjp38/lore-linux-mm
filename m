Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id AA613828F3
	for <linux-mm@kvack.org>; Sun, 10 Jan 2016 23:00:27 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id 65so38211390pff.2
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 20:00:27 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id wl2si16023175pab.236.2016.01.10.20.00.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 10 Jan 2016 20:00:26 -0800 (PST)
Message-ID: <56932791.3080502@huawei.com>
Date: Mon, 11 Jan 2016 11:54:57 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm: add ratio in slabinfo print
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, iamjoonsoo.kim@lge.com, Andrew Morton <akpm@linux-foundation.org>, zhong jiang <zhongjiang@huawei.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Xishi Qiu <qiuxishi@huawei.com>

Add ratio(active_objs/num_objs) in /proc/slabinfo, it is used to show
the availability factor in each slab. Also adjustment format because
some slabs' name is too long.

before applied
...
ext4_inode_cache    1591   3008   1008   32    8 : tunables    0    0    0 : slabdata     94     94      0
ext4_free_data       640    640     64   64    1 : tunables    0    0    0 : slabdata     10     10      0
ext4_allocation_context    480    480    128   32    1 : tunables    0    0    0 : slabdata     15     15      0
ext4_io_end          616    616     72   56    1 : tunables    0    0    0 : slabdata     11     11      0
ext4_extent_status   3979   4794     40  102    1 : tunables    0    0    0 : slabdata     47     47      0
jbd2_journal_handle   1360   1360     48   85    1 : tunables    0    0    0 : slabdata     16     16      0
jbd2_journal_head    510    510    120   34    1 : tunables    0    0    0 : slabdata     15     15      0
jbd2_revoke_table_s    768    768     16  256    1 : tunables    0    0    0 : slabdata      3      3      0
jbd2_revoke_record_s    384    384     32  128    1 : tunables    0    0    0 : slabdata      3      3      0
scsi_data_buffer       0      0     24  170    1 : tunables    0    0    0 : slabdata      0      0      0
cfq_queue            560    560    232   35    2 : tunables    0    0    0 : slabdata     16     16      0
bsg_cmd                0      0    312   26    2 : tunables    0    0    0 : slabdata      0      0      0
mqueue_inode_cache     36     36    896   36    8 : tunables    0    0    0 : slabdata      1      1      0
isofs_inode_cache      0      0    600   27    4 : tunables    0    0    0 : slabdata      0      0      0
hugetlbfs_inode_cache     28     28    568   28    4 : tunables    0    0    0 : slabdata      1      1      0
dquot                448    448    256   32    2 : tunables    0    0    0 : slabdata     14     14      0

after applied
...
ext4_inode_cache            1287   2400     53%   1008   32    8 : tunables    0    0    0 : slabdata     75     75      0
ext4_free_data               640    640    100%     64   64    1 : tunables    0    0    0 : slabdata     10     10      0
ext4_allocation_context      512    512    100%    128   32    1 : tunables    0    0    0 : slabdata     16     16      0
ext4_io_end                  560    560    100%     72   56    1 : tunables    0    0    0 : slabdata     10     10      0
ext4_extent_status          3775   4692     80%     40  102    1 : tunables    0    0    0 : slabdata     46     46      0
jbd2_journal_handle         1360   1360    100%     48   85    1 : tunables    0    0    0 : slabdata     16     16      0
jbd2_journal_head            544    544    100%    120   34    1 : tunables    0    0    0 : slabdata     16     16      0
jbd2_revoke_table_s          768    768    100%     16  256    1 : tunables    0    0    0 : slabdata      3      3      0
jbd2_revoke_record_s         512    512    100%     32  128    1 : tunables    0    0    0 : slabdata      4      4      0
scsi_data_buffer               0      0      0%     24  170    1 : tunables    0    0    0 : slabdata      0      0      0
cfq_queue                    560    560    100%    232   35    2 : tunables    0    0    0 : slabdata     16     16      0
bsg_cmd                        0      0      0%    312   26    2 : tunables    0    0    0 : slabdata      0      0      0
mqueue_inode_cache            36     36    100%    896   36    8 : tunables    0    0    0 : slabdata      1      1      0
isofs_inode_cache              0      0      0%    600   27    4 : tunables    0    0    0 : slabdata      0      0      0
hugetlbfs_inode_cache         28     28    100%    568   28    4 : tunables    0    0    0 : slabdata      1      1      0
dquot                        448    448    100%    256   32    2 : tunables    0    0    0 : slabdata     14     14      0

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/slab_common.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 3c6a86b..6f1e130 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1041,8 +1041,8 @@ static void print_slabinfo_header(struct seq_file *m)
 #else
 	seq_puts(m, "slabinfo - version: 2.1\n");
 #endif
-	seq_puts(m, "# name            <active_objs> <num_objs> <objsize> "
-		 "<objperslab> <pagesperslab>");
+	seq_puts(m, "# name                   <active_objs> <num_objs> <ratio> "
+		 "<objsize> <objperslab> <pagesperslab>");
 	seq_puts(m, " : tunables <limit> <batchcount> <sharedfactor>");
 	seq_puts(m, " : slabdata <active_slabs> <num_slabs> <sharedavail>");
 #ifdef CONFIG_DEBUG_SLAB
@@ -1093,15 +1093,18 @@ memcg_accumulate_slabinfo(struct kmem_cache *s, struct slabinfo *info)
 static void cache_show(struct kmem_cache *s, struct seq_file *m)
 {
 	struct slabinfo sinfo;
+	unsigned long ratio;
 
 	memset(&sinfo, 0, sizeof(sinfo));
 	get_slabinfo(s, &sinfo);
 
 	memcg_accumulate_slabinfo(s, &sinfo);
+	ratio = sinfo.num_objs ? sinfo.active_objs * 100 / sinfo.num_objs : 0;
 
-	seq_printf(m, "%-17s %6lu %6lu %6u %4u %4d",
-		   cache_name(s), sinfo.active_objs, sinfo.num_objs, s->size,
-		   sinfo.objects_per_slab, (1 << sinfo.cache_order));
+	seq_printf(m, "%-25s %6lu %6lu %6lu%% %6u %4u %4d",
+		   cache_name(s), sinfo.active_objs, sinfo.num_objs,
+		   ratio, s->size, sinfo.objects_per_slab,
+		   (1 << sinfo.cache_order));
 
 	seq_printf(m, " : tunables %4u %4u %4u",
 		   sinfo.limit, sinfo.batchcount, sinfo.shared);
-- 
2.0.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
