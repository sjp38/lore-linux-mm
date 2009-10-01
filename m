Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C300C6B009E
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 15:17:41 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 3B11682C2D8
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 16:06:43 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id AtUHKCklbgQp for <linux-mm@kvack.org>;
	Thu,  1 Oct 2009 16:06:38 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 155C982C770
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 16:06:31 -0400 (EDT)
Message-Id: <20091001174120.350865990@gentwo.org>
References: <20091001174033.576397715@gentwo.org>
Date: Thu, 01 Oct 2009 13:40:37 -0400
From: cl@linux-foundation.org
Subject: [this_cpu_xx V3 04/19] Use this_cpu operations for NFS statistics
Content-Disposition: inline; filename=this_cpu_nfs
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

Simplify NFS statistics and allow the use of optimized
arch instructions.

Acked-by: Tejun Heo <tj@kernel.org>
CC: Trond Myklebust <trond.myklebust@fys.uio.no>
Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 fs/nfs/iostat.h |   24 +++---------------------
 1 file changed, 3 insertions(+), 21 deletions(-)

Index: linux-2.6/fs/nfs/iostat.h
===================================================================
--- linux-2.6.orig/fs/nfs/iostat.h	2009-09-29 11:57:01.000000000 -0500
+++ linux-2.6/fs/nfs/iostat.h	2009-09-29 12:26:42.000000000 -0500
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
@@ -44,13 +38,7 @@ static inline void nfs_add_server_stats(
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
+	this_cpu_add(server->io_stats->bytes[stat], addend);
 }
 
 static inline void nfs_add_stats(const struct inode *inode,
@@ -65,13 +53,7 @@ static inline void nfs_add_fscache_stats
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
