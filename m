Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 96B0B6B0032
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 02:47:34 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id eo20so20592lab.20
        for <linux-mm@kvack.org>; Mon, 19 Aug 2013 23:47:32 -0700 (PDT)
Date: Tue, 20 Aug 2013 10:47:30 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 0/3] mm: mempolicy: the failure processing about
 mpol_to_str()
Message-ID: <20130820064730.GD18673@moon>
References: <5212E8DF.5020209@asianux.com>
 <20130820053036.GB18673@moon>
 <52130194.4030903@asianux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52130194.4030903@asianux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>
Cc: Mel Gorman <mgorman@suse.de>, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, hughd@google.com, xemul@parallels.com, rientjes@google.com, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Aug 20, 2013 at 01:41:40PM +0800, Chen Gang wrote:
> 
> need "if (ret < 0)" instead of.  ;-)

sure, it's details

> 
> > sure you'll have to change shmem_show_mpol statement to return int code.
> > Won't this be more short and convenient?
> > 
> > 
> 
> Hmm... if return -ENOSPC, in common processing, it still need continue
> (but need let outside know about the string truncation).
> 
> So I still suggest to give more check for it.

I still don't like adding additional code like

+	ret = mpol_to_str(buffer, sizeof(buffer), mpol);
+	if (ret < 0)
+               switch (ret) {
+               case -ENOSPC:
+                       printk(KERN_WARNING
+                               "in %s: string is truncated in mpol_to_str().\n",
+                               __func__);
+               default:
+                       printk(KERN_ERR
+                               "in %s: call mpol_to_str() fail, errcode: %d. buffer: %p, size: %zu, pol: %p\n",
+                               __func__, ret, buffer, sizeof(buffer), mpol);
+                       return;
+               }

this code is pretty neat for debugging purpose I think but in most case (if
only I've not missed something obvious) it simply won't be the case.

Won't somthing like below do the same but with smaller code change?
Note I've not even compiled it but it shows the idea.
---
 fs/proc/task_mmu.c |    4 +++-
 mm/shmem.c         |   17 +++++++++--------
 2 files changed, 12 insertions(+), 9 deletions(-)

Index: linux-2.6.git/fs/proc/task_mmu.c
===================================================================
--- linux-2.6.git.orig/fs/proc/task_mmu.c
+++ linux-2.6.git/fs/proc/task_mmu.c
@@ -1402,8 +1402,10 @@ static int show_numa_map(struct seq_file
 	walk.mm = mm;
 
 	pol = get_vma_policy(task, vma, vma->vm_start);
-	mpol_to_str(buffer, sizeof(buffer), pol);
+	n = mpol_to_str(buffer, sizeof(buffer), pol);
 	mpol_cond_put(pol);
+	if (n < 0)
+		return n;
 
 	seq_printf(m, "%08lx %s", vma->vm_start, buffer);
 
Index: linux-2.6.git/mm/shmem.c
===================================================================
--- linux-2.6.git.orig/mm/shmem.c
+++ linux-2.6.git/mm/shmem.c
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
+		return 0;	/* show nothing */
 
-	mpol_to_str(buffer, sizeof(buffer), mpol);
+	ret = mpol_to_str(buffer, sizeof(buffer), mpol);
+	if (ret < 0)
+		return ret;
 
 	seq_printf(seq, ",mpol=%s", buffer);
+	return 0;
 }
 
 static struct mempolicy *shmem_get_sbmpol(struct shmem_sb_info *sbinfo)
@@ -951,9 +955,7 @@ static struct page *shmem_alloc_page(gfp
 }
 #else /* !CONFIG_NUMA */
 #ifdef CONFIG_TMPFS
-static inline void shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
-{
-}
+static inline int shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol) { return 0; }
 #endif /* CONFIG_TMPFS */
 
 static inline struct page *shmem_swapin(swp_entry_t swap, gfp_t gfp,
@@ -2577,8 +2579,7 @@ static int shmem_show_options(struct seq
 	if (!gid_eq(sbinfo->gid, GLOBAL_ROOT_GID))
 		seq_printf(seq, ",gid=%u",
 				from_kgid_munged(&init_user_ns, sbinfo->gid));
-	shmem_show_mpol(seq, sbinfo->mpol);
-	return 0;
+	return shmem_show_mpol(seq, sbinfo->mpol);
 }
 #endif /* CONFIG_TMPFS */
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
