Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 48DD86B005C
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 20:28:13 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 7E7D982C2FC
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 20:45:22 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id K3h84Ng7PguP for <linux-mm@kvack.org>;
	Wed, 17 Jun 2009 20:45:17 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 51E2582C316
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 20:45:17 -0400 (EDT)
Message-Id: <20090617203443.566183743@gentwo.org>
References: <20090617203337.399182817@gentwo.org>
Date: Wed, 17 Jun 2009 16:33:41 -0400
From: cl@linux-foundation.org
Subject: [this_cpu_xx V2 04/19] Use this_cpu operations for NFS statistics
Content-Disposition: inline; filename=this_cpu_nfs
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Trond Myklebust <trond.myklebust@fys.uio.no>, Tejun Heo <tj@kernel.org>, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

Simplify NFS statistics and allow the use of optimized
arch instructions.

CC: Trond Myklebust <trond.myklebust@fys.uio.no>
Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 fs/nfs/iostat.h |   30 +++++++++---------------------
 1 file changed, 9 insertions(+), 21 deletions(-)

Index: linux-2.6/fs/nfs/iostat.h
===================================================================
--- linux-2.6.orig/fs/nfs/iostat.h	2009-06-17 09:10:00.000000000 -0500
+++ linux-2.6/fs/nfs/iostat.h	2009-06-17 09:21:02.000000000 -0500
@@ -25,13 +25,7 @@ struct nfs_iostats {
 static inline void nfs_inc_server_stats(const struct nfs_server *server,
 					enum nfs_stat_eventcounters stat)
 {
-	struct nfs_iostats *iostats;
-	int cpu;
-
-	cpu = get_cpu();
-	iostats = per_cpu_ptr(server->io_stats, cpu);
-	iostats->events[stat]++;
-	put_cpu();
+	this_cpu_inc(server->io_stats->events[stat]);
 }
 
 static inline void nfs_inc_stats(const struct inode *inode,
@@ -44,13 +38,13 @@ static inline void nfs_add_server_stats(
 					enum nfs_stat_bytecounters stat,
 					unsigned long addend)
 {
-	struct nfs_iostats *iostats;
-	int cpu;
-
-	cpu = get_cpu();
-	iostats = per_cpu_ptr(server->io_stats, cpu);
-	iostats->bytes[stat] += addend;
-	put_cpu();
+	/*
+	 * bytes is larger than word size on 32 bit platforms.
+	 * Thus we cannot use this_cpu_add() here.
+	 */
+	preempt_disable();
+	*this_cpu_ptr(&server->io_stats->bytes[stat]) +=  addend;
+	preempt_enable_no_resched();
 }
 
 static inline void nfs_add_stats(const struct inode *inode,
@@ -65,13 +59,7 @@ static inline void nfs_add_fscache_stats
 					 enum nfs_stat_fscachecounters stat,
 					 unsigned long addend)
 {
-	struct nfs_iostats *iostats;
-	int cpu;
-
-	cpu = get_cpu();
-	iostats = per_cpu_ptr(NFS_SERVER(inode)->io_stats, cpu);
-	iostats->fscache[stat] += addend;
-	put_cpu();
+	this_cpu_add(NFS_SERVER(inode)->io_stats->fscache[stat], addend);
 }
 #endif
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
