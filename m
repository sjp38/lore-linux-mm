Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 65B426B025E
	for <linux-mm@kvack.org>; Wed, 25 May 2016 11:45:28 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id d7so130047666qkf.3
        for <linux-mm@kvack.org>; Wed, 25 May 2016 08:45:28 -0700 (PDT)
Received: from mail-yw0-x231.google.com (mail-yw0-x231.google.com. [2607:f8b0:4002:c05::231])
        by mx.google.com with ESMTPS id w15si1200858ywa.69.2016.05.25.08.45.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 May 2016 08:45:27 -0700 (PDT)
Received: by mail-yw0-x231.google.com with SMTP id c127so51382905ywb.1
        for <linux-mm@kvack.org>; Wed, 25 May 2016 08:45:27 -0700 (PDT)
Date: Wed, 25 May 2016 11:45:25 -0400
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH percpu/for-4.7-fixes 2/2] percpu: fix synchronization between
 synchronous map extension and chunk destruction
Message-ID: <20160525154525.GF3354@mtj.duckdns.org>
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
Cc: Vlastimil Babka <vbabka@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, Alexei Starovoitov <ast@kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Linux-MM layout <linux-mm@kvack.org>, Marco Grassi <marco.gra@gmail.com>, kernel-team@fb.com

For non-atomic allocations, pcpu_alloc() can try to extend the area
map synchronously after dropping pcpu_lock; however, the extension
wasn't synchronized against chunk destruction and the chunk might get
freed while extension is in progress.

This patch fixes the bug by putting most of non-atomic allocations
under pcpu_alloc_mutex to synchronize against pcpu_balance_work which
is responsible for async chunk management including destruction.

Signed-off-by: Tejun Heo <tj@kernel.org>
Reported-and-tested-by: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Reported-by: Vlastimil Babka <vbabka@suse.cz>
Reported-by: Sasha Levin <sasha.levin@oracle.com>
Cc: stable@vger.kernel.org # v3.18+
Fixes: 1a4d76076cda ("percpu: implement asynchronous chunk population")
---
Hello,

I'll send both patches mainline in a couple days through the percpu
tree.

Thanks.

 mm/percpu.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -162,7 +162,7 @@ static struct pcpu_chunk *pcpu_reserved_
 static int pcpu_reserved_chunk_limit;
 
 static DEFINE_SPINLOCK(pcpu_lock);	/* all internal data structures */
-static DEFINE_MUTEX(pcpu_alloc_mutex);	/* chunk create/destroy, [de]pop */
+static DEFINE_MUTEX(pcpu_alloc_mutex);	/* chunk create/destroy, [de]pop, map ext */
 
 static struct list_head *pcpu_slot __read_mostly; /* chunk list slots */
 
@@ -444,6 +444,8 @@ static int pcpu_extend_area_map(struct p
 	size_t old_size = 0, new_size = new_alloc * sizeof(new[0]);
 	unsigned long flags;
 
+	lockdep_assert_held(&pcpu_alloc_mutex);
+
 	new = pcpu_mem_zalloc(new_size);
 	if (!new)
 		return -ENOMEM;
@@ -890,6 +892,9 @@ static void __percpu *pcpu_alloc(size_t
 		return NULL;
 	}
 
+	if (!is_atomic)
+		mutex_lock(&pcpu_alloc_mutex);
+
 	spin_lock_irqsave(&pcpu_lock, flags);
 
 	/* serve reserved allocations from the reserved chunk if available */
@@ -962,12 +967,9 @@ restart:
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
@@ -978,7 +980,6 @@ restart:
 		spin_lock_irqsave(&pcpu_lock, flags);
 	}
 
-	mutex_unlock(&pcpu_alloc_mutex);
 	goto restart;
 
 area_found:
@@ -988,8 +989,6 @@ area_found:
 	if (!is_atomic) {
 		int page_start, page_end, rs, re;
 
-		mutex_lock(&pcpu_alloc_mutex);
-
 		page_start = PFN_DOWN(off);
 		page_end = PFN_UP(off + size);
 
@@ -1000,7 +999,6 @@ area_found:
 
 			spin_lock_irqsave(&pcpu_lock, flags);
 			if (ret) {
-				mutex_unlock(&pcpu_alloc_mutex);
 				pcpu_free_area(chunk, off, &occ_pages);
 				err = "failed to populate";
 				goto fail_unlock;
@@ -1040,6 +1038,8 @@ fail:
 		/* see the flag handling in pcpu_blance_workfn() */
 		pcpu_atomic_alloc_failed = true;
 		pcpu_schedule_balance_work();
+	} else {
+		mutex_unlock(&pcpu_alloc_mutex);
 	}
 	return NULL;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
