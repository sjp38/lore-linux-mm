Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E08806B004F
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 19:57:02 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id CE38E82C547
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 20:15:07 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 68SOZe5Qu806 for <linux-mm@kvack.org>;
	Wed, 17 Jun 2009 20:15:01 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B90BA82C4B8
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 20:15:01 -0400 (EDT)
Message-Id: <20090617203444.350941614@gentwo.org>
References: <20090617203337.399182817@gentwo.org>
Date: Wed, 17 Jun 2009 16:33:45 -0400
From: cl@linux-foundation.org
Subject: [this_cpu_xx V2 08/19] this_cpu_ptr: xfs_icsb_modify_counters does not need "cpu" variable
Content-Disposition: inline; filename=this_cpu_ptr_xfs
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Olaf Weber <olaf@sgi.com>, Tejun Heo <tj@kernel.org>, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

The xfs_icsb_modify_counters() function no longer needs the cpu variable
if we use this_cpu_ptr() and we can get rid of get/put_cpu().

Reviewed-by: Christoph Hellwig <hch@lst.de>
Acked-by: Olaf Weber <olaf@sgi.com>
Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 fs/xfs/xfs_mount.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

Index: linux-2.6/fs/xfs/xfs_mount.c
===================================================================
--- linux-2.6.orig/fs/xfs/xfs_mount.c	2009-06-15 09:08:01.000000000 -0500
+++ linux-2.6/fs/xfs/xfs_mount.c	2009-06-15 14:20:11.000000000 -0500
@@ -2389,12 +2389,12 @@ xfs_icsb_modify_counters(
 {
 	xfs_icsb_cnts_t	*icsbp;
 	long long	lcounter;	/* long counter for 64 bit fields */
-	int		cpu, ret = 0;
+	int		ret = 0;
 
 	might_sleep();
 again:
-	cpu = get_cpu();
-	icsbp = (xfs_icsb_cnts_t *)per_cpu_ptr(mp->m_sb_cnts, cpu);
+	preempt_disable();
+	icsbp = this_cpu_ptr(mp->m_sb_cnts);
 
 	/*
 	 * if the counter is disabled, go to slow path
@@ -2438,11 +2438,11 @@ again:
 		break;
 	}
 	xfs_icsb_unlock_cntr(icsbp);
-	put_cpu();
+	preempt_enable();
 	return 0;
 
 slow_path:
-	put_cpu();
+	preempt_enable();
 
 	/*
 	 * serialise with a mutex so we don't burn lots of cpu on
@@ -2490,7 +2490,7 @@ slow_path:
 
 balance_counter:
 	xfs_icsb_unlock_cntr(icsbp);
-	put_cpu();
+	preempt_enable();
 
 	/*
 	 * We may have multiple threads here if multiple per-cpu

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
