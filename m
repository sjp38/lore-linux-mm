Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 640536B0055
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 19:57:07 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 7E84E82C4B8
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 20:15:12 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id dZDBlTG-XKkv for <linux-mm@kvack.org>;
	Wed, 17 Jun 2009 20:15:07 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 52D2E82C527
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 20:15:02 -0400 (EDT)
Message-Id: <20090617203444.541329806@gentwo.org>
References: <20090617203337.399182817@gentwo.org>
Date: Wed, 17 Jun 2009 16:33:46 -0400
From: cl@linux-foundation.org
Subject: [this_cpu_xx V2 09/19] Use this_cpu_ptr in crypto subsystem
Content-Disposition: inline; filename=this_cpu_ptr_crypto
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Huang Ying <ying.huang@intel.com>, Tejun Heo <tj@kernel.org>, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

Just a slight optimization that removes one array lookup.
The processor number is needed for other things as well so the
get/put_cpu cannot be removed.

Cc: Huang Ying <ying.huang@intel.com>
Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 crypto/cryptd.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/crypto/cryptd.c
===================================================================
--- linux-2.6.orig/crypto/cryptd.c	2009-05-27 11:55:20.000000000 -0500
+++ linux-2.6/crypto/cryptd.c	2009-05-27 11:56:55.000000000 -0500
@@ -93,7 +93,7 @@ static int cryptd_enqueue_request(struct
 	struct cryptd_cpu_queue *cpu_queue;
 
 	cpu = get_cpu();
-	cpu_queue = per_cpu_ptr(queue->cpu_queue, cpu);
+	cpu_queue = this_cpu_ptr(queue->cpu_queue);
 	err = crypto_enqueue_request(&cpu_queue->queue, request);
 	queue_work_on(cpu, kcrypto_wq, &cpu_queue->work);
 	put_cpu();

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
