Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 9AA1382F99
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 08:30:51 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so31453214wic.1
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 05:30:51 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id fh7si8416331wib.101.2015.10.02.05.30.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Fri, 02 Oct 2015 05:30:50 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 4068C1DC032
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 12:30:49 +0000 (UTC)
Date: Fri, 2 Oct 2015 13:30:47 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 05/10] mm, page_alloc: Distinguish between being unable
 to sleep, unwilling to sleep and avoiding waking kswapd
Message-ID: <20151002123047.GR3068@techsingularity.net>
References: <1442832762-7247-1-git-send-email-mgorman@techsingularity.net>
 <1442832762-7247-6-git-send-email-mgorman@techsingularity.net>
 <20150924205509.GI3009@cmpxchg.org>
 <20150925125106.GG3068@techsingularity.net>
 <20150925190138.GA16359@cmpxchg.org>
 <20150929133547.GI3068@techsingularity.net>
 <560BD4F0.3080402@suse.cz>
 <B4928C43-609A-4BE8-90E1-6327352F9D46@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <B4928C43-609A-4BE8-90E1-6327352F9D46@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Drokin, Oleg" <oleg.drokin@intel.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "Dilger, Andreas" <andreas.dilger@intel.com>

On Thu, Oct 01, 2015 at 03:04:37AM +0000, Drokin, Oleg wrote:
> Hello!

Thanks Oleg for taking a look! Can you review the following please?

---8<---
mm: page_alloc: Remove GFP_IOFS

GFP_IOFS was intended to be shorthand for clearing two flags, not a set of
allocation flags. There is only one user of this flag combination now and
there appears to be no reason why Lustre had to be protected from reclaim
stalls. As none of the sites appear to be atomic, this patch simply deletes
GFP_IOFS and converts Lustre to using GFP_KERNEL, GFP_NOFS or GFP_NOIO
as appropriate.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 drivers/staging/lustre/lnet/lnet/router.c           | 2 +-
 drivers/staging/lustre/lnet/selftest/conrpc.c       | 2 +-
 drivers/staging/lustre/lnet/selftest/rpc.c          | 2 +-
 drivers/staging/lustre/lustre/libcfs/module.c       | 2 +-
 drivers/staging/lustre/lustre/libcfs/tracefile.c    | 2 +-
 drivers/staging/lustre/lustre/llite/remote_perm.c   | 2 +-
 drivers/staging/lustre/lustre/mgc/mgc_request.c     | 8 ++++----
 drivers/staging/lustre/lustre/obdecho/echo_client.c | 2 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c       | 2 +-
 include/linux/gfp.h                                 | 1 -
 10 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 4fbae5ef44a9..dad9816dfee7 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -1246,7 +1246,7 @@ lnet_new_rtrbuf(lnet_rtrbufpool_t *rbp, int cpt)
 	for (i = 0; i < npages; i++) {
 		page = alloc_pages_node(
 				cfs_cpt_spread_node(lnet_cpt_table(), cpt),
-				__GFP_ZERO | GFP_IOFS, 0);
+				GFP_KERNEL | __GFP_ZERO, 0);
 		if (page == NULL) {
 			while (--i >= 0)
 				__free_page(rb->rb_kiov[i].kiov_page);
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index a1a4e08f7391..3fc37de8d304 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -861,7 +861,7 @@ lstcon_testrpc_prep(lstcon_node_t *nd, int transop, unsigned feats,
 			bulk->bk_iovs[i].kiov_offset = 0;
 			bulk->bk_iovs[i].kiov_len    = len;
 			bulk->bk_iovs[i].kiov_page   =
-				alloc_page(GFP_IOFS);
+				alloc_page(GFP_KERNEL);
 
 			if (bulk->bk_iovs[i].kiov_page == NULL) {
 				lstcon_rpc_put(*crpc);
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index 6ae133138b17..aa0f88fbb221 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -146,7 +146,7 @@ srpc_alloc_bulk(int cpt, unsigned bulk_npg, unsigned bulk_len, int sink)
 		int nob;
 
 		pg = alloc_pages_node(cfs_cpt_spread_node(lnet_cpt_table(), cpt),
-				      GFP_IOFS, 0);
+				      GFP_KERNEL, 0);
 		if (pg == NULL) {
 			CERROR("Can't allocate page %d of %d\n", i, bulk_npg);
 			srpc_free_bulk(bk);
diff --git a/drivers/staging/lustre/lustre/libcfs/module.c b/drivers/staging/lustre/lustre/libcfs/module.c
index 806f9747a3a2..303143f28c06 100644
--- a/drivers/staging/lustre/lustre/libcfs/module.c
+++ b/drivers/staging/lustre/lustre/libcfs/module.c
@@ -321,7 +321,7 @@ static int libcfs_ioctl(struct cfs_psdev_file *pfile, unsigned long cmd, void *a
 	struct libcfs_ioctl_data *data;
 	int err = 0;
 
-	LIBCFS_ALLOC_GFP(buf, 1024, GFP_IOFS);
+	LIBCFS_ALLOC_GFP(buf, 1024, GFP_KERNEL);
 	if (buf == NULL)
 		return -ENOMEM;
 
diff --git a/drivers/staging/lustre/lustre/libcfs/tracefile.c b/drivers/staging/lustre/lustre/libcfs/tracefile.c
index effa2af58c13..a7d72f69c4eb 100644
--- a/drivers/staging/lustre/lustre/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lustre/libcfs/tracefile.c
@@ -810,7 +810,7 @@ int cfs_trace_allocate_string_buffer(char **str, int nob)
 	if (nob > 2 * PAGE_CACHE_SIZE)	    /* string must be "sensible" */
 		return -EINVAL;
 
-	*str = kmalloc(nob, GFP_IOFS | __GFP_ZERO);
+	*str = kmalloc(nob, GFP_KERNEL | __GFP_ZERO);
 	if (*str == NULL)
 		return -ENOMEM;
 
diff --git a/drivers/staging/lustre/lustre/llite/remote_perm.c b/drivers/staging/lustre/lustre/llite/remote_perm.c
index 39022ea88b5f..b2830035faba 100644
--- a/drivers/staging/lustre/lustre/llite/remote_perm.c
+++ b/drivers/staging/lustre/lustre/llite/remote_perm.c
@@ -84,7 +84,7 @@ static struct hlist_head *alloc_rmtperm_hash(void)
 
 	OBD_SLAB_ALLOC_GFP(hash, ll_rmtperm_hash_cachep,
 			   REMOTE_PERM_HASHSIZE * sizeof(*hash),
-			   GFP_IOFS);
+			   GFP_NOFS);
 	if (!hash)
 		return NULL;
 
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 019ee2f256aa..67ac6945a8b9 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -1127,7 +1127,7 @@ static int mgc_apply_recover_logs(struct obd_device *mgc,
 	LASSERT(cfg->cfg_instance != NULL);
 	LASSERT(cfg->cfg_sb == cfg->cfg_instance);
 
-	inst = kzalloc(PAGE_CACHE_SIZE, GFP_NOFS);
+	inst = kzalloc(PAGE_CACHE_SIZE, GFP_KERNEL);
 	if (!inst)
 		return -ENOMEM;
 
@@ -1334,14 +1334,14 @@ static int mgc_process_recover_log(struct obd_device *obd,
 	if (cfg->cfg_last_idx == 0) /* the first time */
 		nrpages = CONFIG_READ_NRPAGES_INIT;
 
-	pages = kcalloc(nrpages, sizeof(*pages), GFP_NOFS);
+	pages = kcalloc(nrpages, sizeof(*pages), GFP_KERNEL);
 	if (pages == NULL) {
 		rc = -ENOMEM;
 		goto out;
 	}
 
 	for (i = 0; i < nrpages; i++) {
-		pages[i] = alloc_page(GFP_IOFS);
+		pages[i] = alloc_page(GFP_KERNEL);
 		if (pages[i] == NULL) {
 			rc = -ENOMEM;
 			goto out;
@@ -1492,7 +1492,7 @@ static int mgc_process_cfg_log(struct obd_device *mgc,
 	if (cld->cld_cfg.cfg_sb)
 		lsi = s2lsi(cld->cld_cfg.cfg_sb);
 
-	env = kzalloc(sizeof(*env), GFP_NOFS);
+	env = kzalloc(sizeof(*env), GFP_KERNEL);
 	if (!env)
 		return -ENOMEM;
 
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 27bd170c3a28..7c8443644300 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -1561,7 +1561,7 @@ static int echo_client_kbrw(struct echo_device *ed, int rw, struct obdo *oa,
 		  (oa->o_valid & OBD_MD_FLFLAGS) != 0 &&
 		  (oa->o_flags & OBD_FL_DEBUG_CHECK) != 0);
 
-	gfp_mask = ((ostid_id(&oa->o_oi) & 2) == 0) ? GFP_IOFS : GFP_HIGHUSER;
+	gfp_mask = ((ostid_id(&oa->o_oi) & 2) == 0) ? GFP_KERNEL : GFP_HIGHUSER;
 
 	LASSERT(rw == OBD_BRW_WRITE || rw == OBD_BRW_READ);
 	LASSERT(lsm != NULL);
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index c72035e048aa..d05a4632f1fe 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -346,7 +346,7 @@ static struct osc_extent *osc_extent_alloc(struct osc_object *obj)
 {
 	struct osc_extent *ext;
 
-	OBD_SLAB_ALLOC_PTR_GFP(ext, osc_extent_kmem, GFP_IOFS);
+	OBD_SLAB_ALLOC_PTR_GFP(ext, osc_extent_kmem, GFP_NOIO);
 	if (ext == NULL)
 		return NULL;
 
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 666498d2f6a8..67654f08a28b 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -244,7 +244,6 @@ struct vm_area_struct;
 #define GFP_DMA32	__GFP_DMA32
 #define GFP_HIGHUSER	(GFP_USER | __GFP_HIGHMEM)
 #define GFP_HIGHUSER_MOVABLE	(GFP_HIGHUSER | __GFP_MOVABLE)
-#define GFP_IOFS	(__GFP_IO | __GFP_FS | __GFP_KSWAPD_RECLAIM)
 #define GFP_TRANSHUGE	((GFP_HIGHUSER_MOVABLE | __GFP_COMP | \
 			 __GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_NOWARN) & \
 			 ~__GFP_KSWAPD_RECLAIM)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
