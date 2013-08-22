Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id EE84D6B0032
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 21:05:37 -0400 (EDT)
Message-ID: <5215639D.1080202@asianux.com>
Date: Thu, 22 Aug 2013 09:04:29 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: [PATCH] mm/shmem.c: check the return value of mpol_to_str()
References: <5212E8DF.5020209@asianux.com> <20130820053036.GB18673@moon> <52130194.4030903@asianux.com> <20130820064730.GD18673@moon> <52131F48.1030002@asianux.com> <52132011.60501@asianux.com> <52132432.3050308@asianux.com> <20130820082516.GE18673@moon> <52142422.9050209@asianux.com> <52142464.8060903@asianux.com> <521424BE.8020309@asianux.com> <20130821150337.bad5f71869cec813e2ded90c@linux-foundation.org> <521560BB.30006@asianux.com>
In-Reply-To: <521560BB.30006@asianux.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, hughd@google.com, xemul@parallels.com, rientjes@google.com, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

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
