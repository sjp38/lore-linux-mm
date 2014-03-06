Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id D5F2B6B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 17:15:20 -0500 (EST)
Received: by mail-qc0-f171.google.com with SMTP id x13so3768167qcv.2
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 14:15:19 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id l52si3915653qge.85.2014.03.06.14.15.18
        for <linux-mm@kvack.org>;
        Thu, 06 Mar 2014 14:15:19 -0800 (PST)
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s26MFHFv012474
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 6 Mar 2014 17:15:17 -0500
Date: Thu, 6 Mar 2014 17:15:16 -0500 (EST)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: [PATCH] mempool: add unlikely and likely hints
Message-ID: <alpine.LRH.2.02.1403061713300.928@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>
Cc: linux-mm@kvack.org

This patch adds unlikely and likely hints to the function mempool_free. It
lays out the code in such a way that the common path is executed
straighforward and saves a cache line.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 mm/mempool.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-3.13.5/mm/mempool.c
===================================================================
--- linux-3.13.5.orig/mm/mempool.c	2014-02-23 22:50:11.481071417 +0100
+++ linux-3.13.5/mm/mempool.c	2014-03-06 23:02:24.264538587 +0100
@@ -306,9 +306,9 @@ void mempool_free(void *element, mempool
 	 * ensures that there will be frees which return elements to the
 	 * pool waking up the waiters.
 	 */
-	if (pool->curr_nr < pool->min_nr) {
+	if (unlikely(pool->curr_nr < pool->min_nr)) {
 		spin_lock_irqsave(&pool->lock, flags);
-		if (pool->curr_nr < pool->min_nr) {
+		if (likely(pool->curr_nr < pool->min_nr)) {
 			add_element(pool, element);
 			spin_unlock_irqrestore(&pool->lock, flags);
 			wake_up(&pool->wait);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
