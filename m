Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 03FF66B0031
	for <linux-mm@kvack.org>; Wed,  4 Sep 2013 20:25:44 -0400 (EDT)
Message-ID: <5227CF48.5080700@asianux.com>
Date: Thu, 05 Sep 2013 08:24:40 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: [PATCH v2] mm/shmem.c: check the return value of mpol_to_str()
References: <5215639D.1080202@asianux.com>
In-Reply-To: <5215639D.1080202@asianux.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, riel@redhat.com, hughd@google.com, xemul@parallels.com, rientjes@google.com, Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

mpol_to_str() may fail, and not fill the buffer (e.g. -EINVAL), so need
check about it, or buffer may not be zero based, and next seq_printf()
will cause issue.

Also need let shmem_show_mpol() return value, since it may fail.

Signed-off-by: Chen Gang <gang.chen@asianux.com>
Reviewed-by: Cyrill Gorcunov <gorcunov@gmail.com>
---
 mm/shmem.c |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index f00c1c1..b4d44db 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -883,16 +883,20 @@ redirty:
 
 #ifdef CONFIG_NUMA
 #ifdef CONFIG_TMPFS
-static void shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
+static int shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
 {
 	char buffer[64];
+	int ret;
 
 	if (!mpol || mpol->mode == MPOL_DEFAULT)
-		return;		/* show nothing */
+		return 0;		/* show nothing */
 
-	mpol_to_str(buffer, sizeof(buffer), mpol);
+	ret = mpol_to_str(buffer, sizeof(buffer), mpol);
+	if (ret < 0)
+		return ret;
 
 	seq_printf(seq, ",mpol=%s", buffer);
+	return 0;
 }
 
 static struct mempolicy *shmem_get_sbmpol(struct shmem_sb_info *sbinfo)
@@ -951,8 +955,9 @@ static struct page *shmem_alloc_page(gfp_t gfp,
 }
 #else /* !CONFIG_NUMA */
 #ifdef CONFIG_TMPFS
-static inline void shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
+static inline int shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
 {
+	return 0;
 }
 #endif /* CONFIG_TMPFS */
 
@@ -2555,8 +2560,7 @@ static int shmem_show_options(struct seq_file *seq, struct dentry *root)
 	if (!gid_eq(sbinfo->gid, GLOBAL_ROOT_GID))
 		seq_printf(seq, ",gid=%u",
 				from_kgid_munged(&init_user_ns, sbinfo->gid));
-	shmem_show_mpol(seq, sbinfo->mpol);
-	return 0;
+	return shmem_show_mpol(seq, sbinfo->mpol);
 }
 #endif /* CONFIG_TMPFS */
 
-- 
1.7.7.6


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
