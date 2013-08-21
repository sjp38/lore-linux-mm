Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id B75CE6B0032
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 22:25:04 -0400 (EDT)
Message-ID: <521424BE.8020309@asianux.com>
Date: Wed, 21 Aug 2013 10:23:58 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: [PATCH 2/3] mm/shmem.c: let shmem_show_mpol() return value.
References: <5212E8DF.5020209@asianux.com> <20130820053036.GB18673@moon> <52130194.4030903@asianux.com> <20130820064730.GD18673@moon> <52131F48.1030002@asianux.com> <52132011.60501@asianux.com> <52132432.3050308@asianux.com> <20130820082516.GE18673@moon> <52142422.9050209@asianux.com> <52142464.8060903@asianux.com>
In-Reply-To: <52142464.8060903@asianux.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, hughd@google.com, xemul@parallels.com, rientjes@google.com, Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Let shmem_show_mpol() return value, since it may fail.

Signed-off-by: Chen Gang <gang.chen@asianux.com>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>
---
 mm/shmem.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 75010ba..e59d332 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -883,16 +883,17 @@ redirty:
 
 #ifdef CONFIG_NUMA
 #ifdef CONFIG_TMPFS
-static void shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
+static int shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
 {
 	char buffer[64];
 
 	if (!mpol || mpol->mode == MPOL_DEFAULT)
-		return;		/* show nothing */
+		return 0;		/* show nothing */
 
 	mpol_to_str(buffer, sizeof(buffer), mpol);
 
 	seq_printf(seq, ",mpol=%s", buffer);
+	return 0;
 }
 
 static struct mempolicy *shmem_get_sbmpol(struct shmem_sb_info *sbinfo)
@@ -951,8 +952,9 @@ static struct page *shmem_alloc_page(gfp_t gfp,
 }
 #else /* !CONFIG_NUMA */
 #ifdef CONFIG_TMPFS
-static inline void shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
+static inline int shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
 {
+	return 0;
 }
 #endif /* CONFIG_TMPFS */
 
@@ -2578,8 +2580,7 @@ static int shmem_show_options(struct seq_file *seq, struct dentry *root)
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
