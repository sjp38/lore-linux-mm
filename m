Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id DB43A6B0258
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 11:11:44 -0400 (EDT)
Received: by ykdr198 with SMTP id r198so180194799ykd.3
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 08:11:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 65si25237003qks.95.2015.07.07.08.11.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jul 2015 08:11:44 -0700 (PDT)
Date: Tue, 7 Jul 2015 11:11:42 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: [PATCH 5/7] dm-thin: use kvmalloc
In-Reply-To: <alpine.LRH.2.02.1507071058350.23387@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.LRH.2.02.1507071111190.23387@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1507071058350.23387@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Snitzer <msnitzer@redhat.com>
Cc: "Alasdair G. Kergon" <agk@redhat.com>, Edward Thornber <thornber@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Vivek Goyal <vgoyal@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dm-devel@redhat.com

Make dm-thin use kvmalloc instead of kmalloc because there was a reported
allocation failure - see
https://bugzilla.redhat.com/show_bug.cgi?id=1225370

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 drivers/md/dm-thin.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

Index: linux-4.2-rc1/drivers/md/dm-thin.c
===================================================================
--- linux-4.2-rc1.orig/drivers/md/dm-thin.c	2015-07-06 17:32:35.000000000 +0200
+++ linux-4.2-rc1/drivers/md/dm-thin.c	2015-07-06 17:36:28.000000000 +0200
@@ -2791,7 +2791,7 @@ static void __pool_destroy(struct pool *
 	mempool_destroy(pool->mapping_pool);
 	dm_deferred_set_destroy(pool->shared_read_ds);
 	dm_deferred_set_destroy(pool->all_io_ds);
-	kfree(pool);
+	kvfree(pool);
 }
 
 static struct kmem_cache *_new_mapping_cache;
@@ -2813,7 +2813,7 @@ static struct pool *pool_create(struct m
 		return (struct pool *)pmd;
 	}
 
-	pool = kmalloc(sizeof(*pool), GFP_KERNEL);
+	pool = kvmalloc(sizeof(*pool), GFP_KERNEL);
 	if (!pool) {
 		*error = "Error allocating memory for pool";
 		err_p = ERR_PTR(-ENOMEM);
@@ -2908,7 +2908,7 @@ bad_wq:
 bad_kcopyd_client:
 	dm_bio_prison_destroy(pool->prison);
 bad_prison:
-	kfree(pool);
+	kvfree(pool);
 bad_pool:
 	if (dm_pool_metadata_close(pmd))
 		DMWARN("%s: dm_pool_metadata_close() failed.", __func__);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
