Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f69.google.com (mail-qg0-f69.google.com [209.85.192.69])
	by kanga.kvack.org (Postfix) with ESMTP id 68DA06B0005
	for <linux-mm@kvack.org>; Mon, 23 May 2016 17:35:04 -0400 (EDT)
Received: by mail-qg0-f69.google.com with SMTP id e93so50949170qgf.3
        for <linux-mm@kvack.org>; Mon, 23 May 2016 14:35:04 -0700 (PDT)
Received: from mail-yw0-x242.google.com (mail-yw0-x242.google.com. [2607:f8b0:4002:c05::242])
        by mx.google.com with ESMTPS id t7si16745027ywb.112.2016.05.23.14.35.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 14:35:03 -0700 (PDT)
Received: by mail-yw0-x242.google.com with SMTP id y6so25262452ywe.0
        for <linux-mm@kvack.org>; Mon, 23 May 2016 14:35:03 -0700 (PDT)
Date: Mon, 23 May 2016 17:35:01 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: bpf: use-after-free in array_map_alloc
Message-ID: <20160523213501.GA5383@mtj.duckdns.org>
References: <5713C0AD.3020102@oracle.com>
 <20160417172943.GA83672@ast-mbp.thefacebook.com>
 <5742F127.6080000@suse.cz>
 <5742F267.3000309@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5742F267.3000309@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, ast@kernel.org, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Linux-MM layout <linux-mm@kvack.org>

Hello,

Can you please test whether this patch resolves the issue?  While
adding support for atomic allocations, I reduced alloc_mutex covered
region too much.

Thanks.

diff --git a/mm/percpu.c b/mm/percpu.c
index 0c59684..bd2df70 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -162,7 +162,7 @@ static struct pcpu_chunk *pcpu_reserved_chunk;
 static int pcpu_reserved_chunk_limit;
 
 static DEFINE_SPINLOCK(pcpu_lock);	/* all internal data structures */
-static DEFINE_MUTEX(pcpu_alloc_mutex);	/* chunk create/destroy, [de]pop */
+static DEFINE_MUTEX(pcpu_alloc_mutex);	/* chunk create/destroy, [de]pop, map extension */
 
 static struct list_head *pcpu_slot __read_mostly; /* chunk list slots */
 
@@ -435,6 +435,8 @@ static int pcpu_extend_area_map(struct pcpu_chunk *chunk, int new_alloc)
 	size_t old_size = 0, new_size = new_alloc * sizeof(new[0]);
 	unsigned long flags;
 
+	lockdep_assert_held(&pcpu_alloc_mutex);
+
 	new = pcpu_mem_zalloc(new_size);
 	if (!new)
 		return -ENOMEM;
@@ -895,6 +897,9 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 		return NULL;
 	}
 
+	if (!is_atomic)
+		mutex_lock(&pcpu_alloc_mutex);
+
 	spin_lock_irqsave(&pcpu_lock, flags);
 
 	/* serve reserved allocations from the reserved chunk if available */
@@ -967,12 +972,11 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 	if (is_atomic)
 		goto fail;
 
-	mutex_lock(&pcpu_alloc_mutex);
+	lockdep_assert_held(&pcpu_alloc_mutex);
 
 	if (list_empty(&pcpu_slot[pcpu_nr_slots - 1])) {
 		chunk = pcpu_create_chunk();
 		if (!chunk) {
-			mutex_unlock(&pcpu_alloc_mutex);
 			err = "failed to allocate new chunk";
 			goto fail;
 		}
@@ -983,7 +987,6 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 		spin_lock_irqsave(&pcpu_lock, flags);
 	}
 
-	mutex_unlock(&pcpu_alloc_mutex);
 	goto restart;
 
 area_found:
@@ -993,8 +996,6 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 	if (!is_atomic) {
 		int page_start, page_end, rs, re;
 
-		mutex_lock(&pcpu_alloc_mutex);
-
 		page_start = PFN_DOWN(off);
 		page_end = PFN_UP(off + size);
 
@@ -1005,7 +1006,6 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 
 			spin_lock_irqsave(&pcpu_lock, flags);
 			if (ret) {
-				mutex_unlock(&pcpu_alloc_mutex);
 				pcpu_free_area(chunk, off, &occ_pages);
 				err = "failed to populate";
 				goto fail_unlock;
@@ -1045,6 +1045,8 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 		/* see the flag handling in pcpu_blance_workfn() */
 		pcpu_atomic_alloc_failed = true;
 		pcpu_schedule_balance_work();
+	} else {
+		mutex_unlock(&pcpu_alloc_mutex);
 	}
 	return NULL;
 }
@@ -1137,6 +1139,8 @@ static void pcpu_balance_workfn(struct work_struct *work)
 	list_for_each_entry_safe(chunk, next, &to_free, list) {
 		int rs, re;
 
+		cancel_work_sync(&chunk->map_extend_work);
+
 		pcpu_for_each_pop_region(chunk, rs, re, 0, pcpu_unit_pages) {
 			pcpu_depopulate_chunk(chunk, rs, re);
 			spin_lock_irq(&pcpu_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
