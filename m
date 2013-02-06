Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id A81436B000C
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 00:25:56 -0500 (EST)
Message-ID: <5111E7A5.4050803@cn.fujitsu.com>
Date: Wed, 06 Feb 2013 13:18:29 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 4/7] fs/nfsd: change type of max_delegations, nfsd_drc_max_mem
 and nfsd_drc_mem_used
References: <5111E612.4010907@cn.fujitsu.com>
In-Reply-To: <5111E612.4010907@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, mgorman@suse.de, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, bfields@fieldses.org
Cc: Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

The three variables are calculated from nr_free_buffer_pages so
change their types to unsigned long in case of overflow.

Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 fs/nfsd/nfs4state.c |    6 +++---
 fs/nfsd/nfsd.h      |    6 +++---
 fs/nfsd/nfssvc.c    |    6 +++---
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ac8ed96..499e957 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -151,7 +151,7 @@ get_nfs4_file(struct nfs4_file *fi)
 }
 
 static int num_delegations;
-unsigned int max_delegations;
+unsigned long max_delegations;
 
 /*
  * Open owner state (share locks)
@@ -700,8 +700,8 @@ static int nfsd4_get_drc_mem(int slotsize, u32 num)
 	num = min_t(u32, num, NFSD_MAX_SLOTS_PER_SESSION);
 
 	spin_lock(&nfsd_drc_lock);
-	avail = min_t(int, NFSD_MAX_MEM_PER_SESSION,
-			nfsd_drc_max_mem - nfsd_drc_mem_used);
+	avail = min((unsigned long)NFSD_MAX_MEM_PER_SESSION,
+		    nfsd_drc_max_mem - nfsd_drc_mem_used);
 	num = min_t(int, num, avail / slotsize);
 	nfsd_drc_mem_used += num * slotsize;
 	spin_unlock(&nfsd_drc_lock);
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index de23db2..07a473f 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -56,8 +56,8 @@ extern struct svc_version	nfsd_version2, nfsd_version3,
 extern u32			nfsd_supported_minorversion;
 extern struct mutex		nfsd_mutex;
 extern spinlock_t		nfsd_drc_lock;
-extern unsigned int		nfsd_drc_max_mem;
-extern unsigned int		nfsd_drc_mem_used;
+extern unsigned long		nfsd_drc_max_mem;
+extern unsigned long		nfsd_drc_mem_used;
 
 extern const struct seq_operations nfs_exports_op;
 
@@ -106,7 +106,7 @@ static inline int nfsd_v4client(struct svc_rqst *rq)
  * NFSv4 State
  */
 #ifdef CONFIG_NFSD_V4
-extern unsigned int max_delegations;
+extern unsigned long max_delegations;
 void nfs4_state_init(void);
 int nfsd4_init_slabs(void);
 void nfsd4_free_slabs(void);
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index cee62ab..be7af50 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -59,8 +59,8 @@ DEFINE_MUTEX(nfsd_mutex);
  * nfsd_drc_pages_used tracks the current version 4.1 DRC memory usage.
  */
 spinlock_t	nfsd_drc_lock;
-unsigned int	nfsd_drc_max_mem;
-unsigned int	nfsd_drc_mem_used;
+unsigned long	nfsd_drc_max_mem;
+unsigned long	nfsd_drc_mem_used;
 
 #if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
 static struct svc_stat	nfsd_acl_svcstats;
@@ -342,7 +342,7 @@ static void set_max_drc(void)
 					>> NFSD_DRC_SIZE_SHIFT) * PAGE_SIZE;
 	nfsd_drc_mem_used = 0;
 	spin_lock_init(&nfsd_drc_lock);
-	dprintk("%s nfsd_drc_max_mem %u \n", __func__, nfsd_drc_max_mem);
+	dprintk("%s nfsd_drc_max_mem %lu \n", __func__, nfsd_drc_max_mem);
 }
 
 static int nfsd_get_default_max_blksize(void)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
