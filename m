Date: Mon, 2 Apr 2007 23:01:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [xfs-masters] Re: [PATCH] Cleanup and kernelify shrinker
 registration (rc5-mm2)
Message-Id: <20070402230158.4fcdd455.akpm@linux-foundation.org>
In-Reply-To: <20070403054419.GV32597093@melbourne.sgi.com>
References: <1175571885.12230.473.camel@localhost.localdomain>
	<20070402205825.12190e52.akpm@linux-foundation.org>
	<1175575503.12230.484.camel@localhost.localdomain>
	<20070402215702.6e3782a9.akpm@linux-foundation.org>
	<20070403054419.GV32597093@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: xfs-masters@oss.sgi.com, Rusty Russell <rusty@rustcorp.com.au>, lkml - Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, reiserfs-dev@namesys.com
List-ID: <linux-mm.kvack.org>

On Tue, 3 Apr 2007 15:44:19 +1000 David Chinner <dgc@sgi.com> wrote:

> In XFS, one of the shrinkers cwthat gets registered calls causes all
> the xfsbufd's in the system to run and write back delayed write
> metadata - this can't be freed up until it is clean, and this is the
> only hook we have that can be used to trigger writeback on memory
> pressure. We need this because we can potentially have hundreds of
> megabytes of dirty metadata per XFS filesystem.
> 

<looks>

Gad, someone went mad in there.  Can we do this (please)?



From: Andrew Morton <akpm@linux-foundation.org>

Strip away lots of needless wrapping and type obfuscation in XFS's handling of
cache shrinker registration.

Cc: David Chinner <dgc@sgi.com>
Cc: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/xfs/linux-2.6/kmem.h    |   19 -------------------
 fs/xfs/linux-2.6/xfs_buf.c |    6 +++---
 fs/xfs/quota/xfs_qm.c      |    6 +++---
 3 files changed, 6 insertions(+), 25 deletions(-)

diff -puN fs/xfs/linux-2.6/kmem.h~xfs-clean-up-shrinker-games fs/xfs/linux-2.6/kmem.h
--- a/fs/xfs/linux-2.6/kmem.h~xfs-clean-up-shrinker-games
+++ a/fs/xfs/linux-2.6/kmem.h
@@ -100,25 +100,6 @@ kmem_zone_destroy(kmem_zone_t *zone)
 extern void *kmem_zone_alloc(kmem_zone_t *, unsigned int __nocast);
 extern void *kmem_zone_zalloc(kmem_zone_t *, unsigned int __nocast);
 
-/*
- * Low memory cache shrinkers
- */
-
-typedef struct shrinker *kmem_shaker_t;
-typedef int (*kmem_shake_func_t)(int, gfp_t);
-
-static inline kmem_shaker_t
-kmem_shake_register(kmem_shake_func_t sfunc)
-{
-	return set_shrinker(DEFAULT_SEEKS, sfunc);
-}
-
-static inline void
-kmem_shake_deregister(kmem_shaker_t shrinker)
-{
-	remove_shrinker(shrinker);
-}
-
 static inline int
 kmem_shake_allow(gfp_t gfp_mask)
 {
diff -puN fs/xfs/linux-2.6/xfs_buf.c~xfs-clean-up-shrinker-games fs/xfs/linux-2.6/xfs_buf.c
--- a/fs/xfs/linux-2.6/xfs_buf.c~xfs-clean-up-shrinker-games
+++ a/fs/xfs/linux-2.6/xfs_buf.c
@@ -35,7 +35,7 @@
 #include <linux/freezer.h>
 
 static kmem_zone_t *xfs_buf_zone;
-static kmem_shaker_t xfs_buf_shake;
+static struct shrinker *xfs_buf_shake;
 STATIC int xfsbufd(void *);
 STATIC int xfsbufd_wakeup(int, gfp_t);
 STATIC void xfs_buf_delwri_queue(xfs_buf_t *, int);
@@ -1837,7 +1837,7 @@ xfs_buf_init(void)
 	if (!xfsdatad_workqueue)
 		goto out_destroy_xfslogd_workqueue;
 
-	xfs_buf_shake = kmem_shake_register(xfsbufd_wakeup);
+	xfs_buf_shake = set_shrinker(DEFAULT_SEEKS, xfsbufd_wakeup);
 	if (!xfs_buf_shake)
 		goto out_destroy_xfsdatad_workqueue;
 
@@ -1859,7 +1859,7 @@ xfs_buf_init(void)
 void
 xfs_buf_terminate(void)
 {
-	kmem_shake_deregister(xfs_buf_shake);
+	remove_shrinker(xfs_buf_shake);
 	destroy_workqueue(xfsdatad_workqueue);
 	destroy_workqueue(xfslogd_workqueue);
 	kmem_zone_destroy(xfs_buf_zone);
diff -puN fs/xfs/quota/xfs_qm.c~xfs-clean-up-shrinker-games fs/xfs/quota/xfs_qm.c
--- a/fs/xfs/quota/xfs_qm.c~xfs-clean-up-shrinker-games
+++ a/fs/xfs/quota/xfs_qm.c
@@ -62,7 +62,7 @@ uint		ndquot;
 
 kmem_zone_t	*qm_dqzone;
 kmem_zone_t	*qm_dqtrxzone;
-static kmem_shaker_t	xfs_qm_shaker;
+static struct shrinker *xfs_qm_shaker;
 
 static cred_t	xfs_zerocr;
 static xfs_inode_t	xfs_zeroino;
@@ -150,7 +150,7 @@ xfs_Gqm_init(void)
 	} else
 		xqm->qm_dqzone = qm_dqzone;
 
-	xfs_qm_shaker = kmem_shake_register(xfs_qm_shake);
+	xfs_qm_shaker = set_shrinker(DEFAULT_SEEKS, xfs_qm_shake);
 
 	/*
 	 * The t_dqinfo portion of transactions.
@@ -182,7 +182,7 @@ xfs_qm_destroy(
 
 	ASSERT(xqm != NULL);
 	ASSERT(xqm->qm_nrefs == 0);
-	kmem_shake_deregister(xfs_qm_shaker);
+	remove_shrinker(xfs_qm_shaker);
 	hsize = xqm->qm_dqhashmask + 1;
 	for (i = 0; i < hsize; i++) {
 		xfs_qm_list_destroy(&(xqm->qm_usr_dqhtable[i]));
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
