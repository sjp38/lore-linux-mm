Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 878436B0253
	for <linux-mm@kvack.org>; Tue, 24 May 2016 15:04:36 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id y6so58593091ywe.0
        for <linux-mm@kvack.org>; Tue, 24 May 2016 12:04:36 -0700 (PDT)
Received: from mail-yw0-x233.google.com (mail-yw0-x233.google.com. [2607:f8b0:4002:c05::233])
        by mx.google.com with ESMTPS id x84si19136808ywc.335.2016.05.24.12.04.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 May 2016 12:04:35 -0700 (PDT)
Received: by mail-yw0-x233.google.com with SMTP id o16so25566317ywd.2
        for <linux-mm@kvack.org>; Tue, 24 May 2016 12:04:35 -0700 (PDT)
Date: Tue, 24 May 2016 15:04:33 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: bpf: use-after-free in array_map_alloc
Message-ID: <20160524190433.GC3354@mtj.duckdns.org>
References: <5713C0AD.3020102@oracle.com>
 <20160417172943.GA83672@ast-mbp.thefacebook.com>
 <5742F127.6080000@suse.cz>
 <5742F267.3000309@suse.cz>
 <20160523213501.GA5383@mtj.duckdns.org>
 <57441396.2050607@suse.cz>
 <20160524153029.GA3354@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160524153029.GA3354@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, ast@kernel.org, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Linux-MM layout <linux-mm@kvack.org>, marco.gra@gmail.com

Hello,

Alexei, can you please verify this patch?  Map extension got rolled
into balance work so that there's no sync issues between the two async
operations.

Thanks.

Index: work/mm/percpu.c
===================================================================
--- work.orig/mm/percpu.c
+++ work/mm/percpu.c
@@ -112,7 +112,7 @@ struct pcpu_chunk {
 	int			map_used;	/* # of map entries used before the sentry */
 	int			map_alloc;	/* # of map entries allocated */
 	int			*map;		/* allocation map */
-	struct work_struct	map_extend_work;/* async ->map[] extension */
+	struct list_head	map_extend_list;/* on pcpu_map_extend_chunks */
 
 	void			*data;		/* chunk data */
 	int			first_free;	/* no free below this */
@@ -162,10 +162,13 @@ static struct pcpu_chunk *pcpu_reserved_
 static int pcpu_reserved_chunk_limit;
 
 static DEFINE_SPINLOCK(pcpu_lock);	/* all internal data structures */
-static DEFINE_MUTEX(pcpu_alloc_mutex);	/* chunk create/destroy, [de]pop */
+static DEFINE_MUTEX(pcpu_alloc_mutex);	/* chunk create/destroy, [de]pop, map ext */
 
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
@@ -435,6 +444,8 @@ static int pcpu_extend_area_map(struct p
 	size_t old_size = 0, new_size = new_alloc * sizeof(new[0]);
 	unsigned long flags;
 
+	lockdep_assert_held(&pcpu_alloc_mutex);
+
 	new = pcpu_mem_zalloc(new_size);
 	if (!new)
 		return -ENOMEM;
@@ -467,20 +478,6 @@ out_unlock:
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
@@ -740,7 +737,7 @@ static struct pcpu_chunk *pcpu_alloc_chu
 	chunk->map_used = 1;
 
 	INIT_LIST_HEAD(&chunk->list);
-	INIT_WORK(&chunk->map_extend_work, pcpu_map_extend_workfn);
+	INIT_LIST_HEAD(&chunk->map_extend_list);
 	chunk->free_size = pcpu_unit_size;
 	chunk->contig_hint = pcpu_unit_size;
 
@@ -895,6 +892,9 @@ static void __percpu *pcpu_alloc(size_t
 		return NULL;
 	}
 
+	if (!is_atomic)
+		mutex_lock(&pcpu_alloc_mutex);
+
 	spin_lock_irqsave(&pcpu_lock, flags);
 
 	/* serve reserved allocations from the reserved chunk if available */
@@ -967,12 +967,9 @@ restart:
 	if (is_atomic)
 		goto fail;
 
-	mutex_lock(&pcpu_alloc_mutex);
-
 	if (list_empty(&pcpu_slot[pcpu_nr_slots - 1])) {
 		chunk = pcpu_create_chunk();
 		if (!chunk) {
-			mutex_unlock(&pcpu_alloc_mutex);
 			err = "failed to allocate new chunk";
 			goto fail;
 		}
@@ -983,7 +980,6 @@ restart:
 		spin_lock_irqsave(&pcpu_lock, flags);
 	}
 
-	mutex_unlock(&pcpu_alloc_mutex);
 	goto restart;
 
 area_found:
@@ -993,8 +989,6 @@ area_found:
 	if (!is_atomic) {
 		int page_start, page_end, rs, re;
 
-		mutex_lock(&pcpu_alloc_mutex);
-
 		page_start = PFN_DOWN(off);
 		page_end = PFN_UP(off + size);
 
@@ -1005,7 +999,6 @@ area_found:
 
 			spin_lock_irqsave(&pcpu_lock, flags);
 			if (ret) {
-				mutex_unlock(&pcpu_alloc_mutex);
 				pcpu_free_area(chunk, off, &occ_pages);
 				err = "failed to populate";
 				goto fail_unlock;
@@ -1045,6 +1038,8 @@ fail:
 		/* see the flag handling in pcpu_blance_workfn() */
 		pcpu_atomic_alloc_failed = true;
 		pcpu_schedule_balance_work();
+	} else {
+		mutex_unlock(&pcpu_alloc_mutex);
 	}
 	return NULL;
 }
@@ -1129,6 +1124,7 @@ static void pcpu_balance_workfn(struct w
 		if (chunk == list_first_entry(free_head, struct pcpu_chunk, list))
 			continue;
 
+		list_del_init(&chunk->map_extend_list);
 		list_move(&chunk->list, &to_free);
 	}
 
@@ -1146,6 +1142,24 @@ static void pcpu_balance_workfn(struct w
 		pcpu_destroy_chunk(chunk);
 	}
 
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
@@ -1644,7 +1658,7 @@ int __init pcpu_setup_first_chunk(const
 	 */
 	schunk = memblock_virt_alloc(pcpu_chunk_struct_size, 0);
 	INIT_LIST_HEAD(&schunk->list);
-	INIT_WORK(&schunk->map_extend_work, pcpu_map_extend_workfn);
+	INIT_LIST_HEAD(&schunk->map_extend_list);
 	schunk->base_addr = base_addr;
 	schunk->map = smap;
 	schunk->map_alloc = ARRAY_SIZE(smap);
@@ -1673,7 +1687,7 @@ int __init pcpu_setup_first_chunk(const
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
