Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f69.google.com (mail-qg0-f69.google.com [209.85.192.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1C3246B0005
	for <linux-mm@kvack.org>; Wed, 25 May 2016 11:44:23 -0400 (EDT)
Received: by mail-qg0-f69.google.com with SMTP id t106so71033764qgt.1
        for <linux-mm@kvack.org>; Wed, 25 May 2016 08:44:23 -0700 (PDT)
Received: from mail-yw0-x236.google.com (mail-yw0-x236.google.com. [2607:f8b0:4002:c05::236])
        by mx.google.com with ESMTPS id m131si5041354ybc.107.2016.05.25.08.44.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 May 2016 08:44:22 -0700 (PDT)
Received: by mail-yw0-x236.google.com with SMTP id o16so51304072ywd.2
        for <linux-mm@kvack.org>; Wed, 25 May 2016 08:44:21 -0700 (PDT)
Date: Wed, 25 May 2016 11:44:19 -0400
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH percpu/for-4.7-fixes 1/2] percpu: fix synchronization between
 chunk->map_extend_work and chunk destruction
Message-ID: <20160525154419.GE3354@mtj.duckdns.org>
References: <5713C0AD.3020102@oracle.com>
 <20160417172943.GA83672@ast-mbp.thefacebook.com>
 <5742F127.6080000@suse.cz>
 <5742F267.3000309@suse.cz>
 <20160523213501.GA5383@mtj.duckdns.org>
 <57441396.2050607@suse.cz>
 <20160524153029.GA3354@mtj.duckdns.org>
 <20160524190433.GC3354@mtj.duckdns.org>
 <CAADnVQ+GprFZJkvCKHVN1gmBMO6uORimsNZ4tE-jgPPOcZhCfA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAADnVQ+GprFZJkvCKHVN1gmBMO6uORimsNZ4tE-jgPPOcZhCfA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, Alexei Starovoitov <ast@kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Linux-MM layout <linux-mm@kvack.org>, Marco Grassi <marco.gra@gmail.com>

Atomic allocations can trigger async map extensions which is serviced
by chunk->map_extend_work.  pcpu_balance_work which is responsible for
destroying idle chunks wasn't synchronizing properly against
chunk->map_extend_work and may end up freeing the chunk while the work
item is still in flight.

This patch fixes the bug by rolling async map extension operations
into pcpu_balance_work.

Signed-off-by: Tejun Heo <tj@kernel.org>
Reported-and-tested-by: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Reported-by: Vlastimil Babka <vbabka@suse.cz>
Reported-by: Sasha Levin <sasha.levin@oracle.com>
Cc: stable@vger.kernel.org # v3.18+
Fixes: 9c824b6a172c ("percpu: make sure chunk->map array has available space")
---
 mm/percpu.c |   57 ++++++++++++++++++++++++++++++++++++---------------------
 1 file changed, 36 insertions(+), 21 deletions(-)

--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -112,7 +112,7 @@ struct pcpu_chunk {
 	int			map_used;	/* # of map entries used before the sentry */
 	int			map_alloc;	/* # of map entries allocated */
 	int			*map;		/* allocation map */
-	struct work_struct	map_extend_work;/* async ->map[] extension */
+	struct list_head	map_extend_list;/* on pcpu_map_extend_chunks */
 
 	void			*data;		/* chunk data */
 	int			first_free;	/* no free below this */
@@ -166,6 +166,9 @@ static DEFINE_MUTEX(pcpu_alloc_mutex);	/
 
 static struct list_head *pcpu_slot __read_mostly; /* chunk list slots */
 
+/* chunks which need their map areas extended, protected by pcpu_lock */
+static LIST_HEAD(pcpu_map_extend_chunks);
+
 /*
  * The number of empty populated pages, protected by pcpu_lock.  The
  * reserved chunk doesn't contribute to the count.
@@ -395,13 +398,19 @@ static int pcpu_need_to_extend(struct pc
 {
 	int margin, new_alloc;
 
+	lockdep_assert_held(&pcpu_lock);
+
 	if (is_atomic) {
 		margin = 3;
 
 		if (chunk->map_alloc <
-		    chunk->map_used + PCPU_ATOMIC_MAP_MARGIN_LOW &&
-		    pcpu_async_enabled)
-			schedule_work(&chunk->map_extend_work);
+		    chunk->map_used + PCPU_ATOMIC_MAP_MARGIN_LOW) {
+			if (list_empty(&chunk->map_extend_list)) {
+				list_add_tail(&chunk->map_extend_list,
+					      &pcpu_map_extend_chunks);
+				pcpu_schedule_balance_work();
+			}
+		}
 	} else {
 		margin = PCPU_ATOMIC_MAP_MARGIN_HIGH;
 	}
@@ -467,20 +476,6 @@ out_unlock:
 	return 0;
 }
 
-static void pcpu_map_extend_workfn(struct work_struct *work)
-{
-	struct pcpu_chunk *chunk = container_of(work, struct pcpu_chunk,
-						map_extend_work);
-	int new_alloc;
-
-	spin_lock_irq(&pcpu_lock);
-	new_alloc = pcpu_need_to_extend(chunk, false);
-	spin_unlock_irq(&pcpu_lock);
-
-	if (new_alloc)
-		pcpu_extend_area_map(chunk, new_alloc);
-}
-
 /**
  * pcpu_fit_in_area - try to fit the requested allocation in a candidate area
  * @chunk: chunk the candidate area belongs to
@@ -740,7 +735,7 @@ static struct pcpu_chunk *pcpu_alloc_chu
 	chunk->map_used = 1;
 
 	INIT_LIST_HEAD(&chunk->list);
-	INIT_WORK(&chunk->map_extend_work, pcpu_map_extend_workfn);
+	INIT_LIST_HEAD(&chunk->map_extend_list);
 	chunk->free_size = pcpu_unit_size;
 	chunk->contig_hint = pcpu_unit_size;
 
@@ -1129,6 +1124,7 @@ static void pcpu_balance_workfn(struct w
 		if (chunk == list_first_entry(free_head, struct pcpu_chunk, list))
 			continue;
 
+		list_del_init(&chunk->map_extend_list);
 		list_move(&chunk->list, &to_free);
 	}
 
@@ -1146,6 +1142,25 @@ static void pcpu_balance_workfn(struct w
 		pcpu_destroy_chunk(chunk);
 	}
 
+	/* service chunks which requested async area map extension */
+	do {
+		int new_alloc = 0;
+
+		spin_lock_irq(&pcpu_lock);
+
+		chunk = list_first_entry_or_null(&pcpu_map_extend_chunks,
+					struct pcpu_chunk, map_extend_list);
+		if (chunk) {
+			list_del_init(&chunk->map_extend_list);
+			new_alloc = pcpu_need_to_extend(chunk, false);
+		}
+
+		spin_unlock_irq(&pcpu_lock);
+
+		if (new_alloc)
+			pcpu_extend_area_map(chunk, new_alloc);
+	} while (chunk);
+
 	/*
 	 * Ensure there are certain number of free populated pages for
 	 * atomic allocs.  Fill up from the most packed so that atomic
@@ -1644,7 +1659,7 @@ int __init pcpu_setup_first_chunk(const
 	 */
 	schunk = memblock_virt_alloc(pcpu_chunk_struct_size, 0);
 	INIT_LIST_HEAD(&schunk->list);
-	INIT_WORK(&schunk->map_extend_work, pcpu_map_extend_workfn);
+	INIT_LIST_HEAD(&schunk->map_extend_list);
 	schunk->base_addr = base_addr;
 	schunk->map = smap;
 	schunk->map_alloc = ARRAY_SIZE(smap);
@@ -1673,7 +1688,7 @@ int __init pcpu_setup_first_chunk(const
 	if (dyn_size) {
 		dchunk = memblock_virt_alloc(pcpu_chunk_struct_size, 0);
 		INIT_LIST_HEAD(&dchunk->list);
-		INIT_WORK(&dchunk->map_extend_work, pcpu_map_extend_workfn);
+		INIT_LIST_HEAD(&dchunk->map_extend_list);
 		dchunk->base_addr = base_addr;
 		dchunk->map = dmap;
 		dchunk->map_alloc = ARRAY_SIZE(dmap);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
