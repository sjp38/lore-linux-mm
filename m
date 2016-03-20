Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7E574828DF
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:42:10 -0400 (EDT)
Received: by mail-pf0-f182.google.com with SMTP id u190so238221734pfb.3
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:42:10 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id tr4si13932449pac.222.2016.03.20.11.41.46
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:46 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 16/71] lustre: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:23 +0300
Message-Id: <1458499278-1516-17-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>

PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} macros were introduced *long* time ago
with promise that one day it will be possible to implement page cache with
bigger chunks than PAGE_SIZE.

This promise never materialized. And unlikely will.

We have many places where PAGE_CACHE_SIZE assumed to be equal to
PAGE_SIZE. And it's constant source of confusion on whether PAGE_CACHE_*
or PAGE_* constant should be used in a particular case, especially on the
border between fs and mm.

Global switching to PAGE_CACHE_SIZE != PAGE_SIZE would cause to much
breakage to be doable.

Let's stop pretending that pages in page cache are special. They are not.

The changes are pretty straight-forward:

 - <foo> << (PAGE_CACHE_SHIFT - PAGE_SHIFT) -> <foo>;

 - PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} -> PAGE_{SIZE,SHIFT,MASK,ALIGN};

 - page_cache_get() -> get_page();

 - page_cache_release() -> put_page();

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>
Cc: Andreas Dilger <andreas.dilger@intel.com>
---
 .../lustre/include/linux/libcfs/libcfs_private.h   |  2 +-
 .../lustre/include/linux/libcfs/linux/linux-mem.h  |  4 +-
 drivers/staging/lustre/include/linux/lnet/types.h  |  2 +-
 .../lustre/lnet/klnds/socklnd/socklnd_lib.c        |  2 +-
 drivers/staging/lustre/lnet/libcfs/debug.c         |  2 +-
 drivers/staging/lustre/lnet/libcfs/tracefile.c     | 16 ++++----
 drivers/staging/lustre/lnet/libcfs/tracefile.h     |  6 +--
 drivers/staging/lustre/lnet/lnet/lib-md.c          |  2 +-
 drivers/staging/lustre/lnet/lnet/lib-move.c        |  6 +--
 drivers/staging/lustre/lnet/lnet/lib-socket.c      |  4 +-
 drivers/staging/lustre/lnet/lnet/router.c          |  6 +--
 drivers/staging/lustre/lnet/selftest/brw_test.c    | 20 +++++-----
 drivers/staging/lustre/lnet/selftest/conctl.c      |  4 +-
 drivers/staging/lustre/lnet/selftest/conrpc.c      | 10 ++---
 drivers/staging/lustre/lnet/selftest/framework.c   |  2 +-
 drivers/staging/lustre/lnet/selftest/rpc.c         |  2 +-
 drivers/staging/lustre/lnet/selftest/selftest.h    |  4 +-
 .../lustre/include/linux/lustre_patchless_compat.h |  2 +-
 drivers/staging/lustre/lustre/include/lu_object.h  |  2 +-
 .../lustre/lustre/include/lustre/lustre_idl.h      |  6 +--
 drivers/staging/lustre/lustre/include/lustre_mdc.h |  4 +-
 drivers/staging/lustre/lustre/include/lustre_net.h | 10 ++---
 drivers/staging/lustre/lustre/include/obd.h        |  4 +-
 .../staging/lustre/lustre/include/obd_support.h    |  2 +-
 drivers/staging/lustre/lustre/lclient/lcommon_cl.c |  4 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      | 12 +++---
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |  2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |  2 +-
 drivers/staging/lustre/lustre/llite/dir.c          | 20 +++++-----
 .../staging/lustre/lustre/llite/llite_internal.h   |  8 ++--
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  8 ++--
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |  8 ++--
 drivers/staging/lustre/lustre/llite/lloop.c        | 12 +++---
 drivers/staging/lustre/lustre/llite/lproc_llite.c  | 18 ++++-----
 drivers/staging/lustre/lustre/llite/rw.c           | 24 ++++++------
 drivers/staging/lustre/lustre/llite/rw26.c         | 28 +++++++-------
 drivers/staging/lustre/lustre/llite/vvp_io.c       | 11 ++----
 drivers/staging/lustre/lustre/llite/vvp_page.c     |  8 ++--
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        | 12 +++---
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |  6 +--
 drivers/staging/lustre/lustre/mgc/mgc_request.c    | 22 +++++------
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |  6 +--
 drivers/staging/lustre/lustre/obdclass/class_obd.c |  6 +--
 .../lustre/lustre/obdclass/linux/linux-obdo.c      |  5 +--
 .../lustre/lustre/obdclass/linux/linux-sysctl.c    |  6 +--
 drivers/staging/lustre/lustre/obdclass/lu_object.c |  6 +--
 .../staging/lustre/lustre/obdecho/echo_client.c    | 30 +++++++--------
 drivers/staging/lustre/lustre/osc/lproc_osc.c      | 16 ++++----
 drivers/staging/lustre/lustre/osc/osc_cache.c      | 44 +++++++++++-----------
 drivers/staging/lustre/lustre/osc/osc_page.c       |  6 +--
 drivers/staging/lustre/lustre/osc/osc_request.c    | 26 ++++++-------
 drivers/staging/lustre/lustre/ptlrpc/client.c      |  6 +--
 drivers/staging/lustre/lustre/ptlrpc/import.c      |  2 +-
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    |  4 +-
 drivers/staging/lustre/lustre/ptlrpc/recover.c     |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |  2 +-
 56 files changed, 246 insertions(+), 250 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
index dab486261154..13335437c69c 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
@@ -88,7 +88,7 @@ do {								    \
 } while (0)
 
 #ifndef LIBCFS_VMALLOC_SIZE
-#define LIBCFS_VMALLOC_SIZE	(2 << PAGE_CACHE_SHIFT) /* 2 pages */
+#define LIBCFS_VMALLOC_SIZE	(2 << PAGE_SHIFT) /* 2 pages */
 #endif
 
 #define LIBCFS_ALLOC_PRE(size, mask)					    \
diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/linux-mem.h b/drivers/staging/lustre/include/linux/libcfs/linux/linux-mem.h
index 0f2fd79e5ec8..837eb22749c3 100644
--- a/drivers/staging/lustre/include/linux/libcfs/linux/linux-mem.h
+++ b/drivers/staging/lustre/include/linux/libcfs/linux/linux-mem.h
@@ -57,7 +57,7 @@
 #include "../libcfs_cpu.h"
 #endif
 
-#define CFS_PAGE_MASK		   (~((__u64)PAGE_CACHE_SIZE-1))
+#define CFS_PAGE_MASK		   (~((__u64)PAGE_SIZE-1))
 #define page_index(p)       ((p)->index)
 
 #define memory_pressure_get() (current->flags & PF_MEMALLOC)
@@ -67,7 +67,7 @@
 #if BITS_PER_LONG == 32
 /* limit to lowmem on 32-bit systems */
 #define NUM_CACHEPAGES \
-	min(totalram_pages, 1UL << (30 - PAGE_CACHE_SHIFT) * 3 / 4)
+	min(totalram_pages, 1UL << (30 - PAGE_SHIFT) * 3 / 4)
 #else
 #define NUM_CACHEPAGES totalram_pages
 #endif
diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
index 08f193c341c5..1c679cb72785 100644
--- a/drivers/staging/lustre/include/linux/lnet/types.h
+++ b/drivers/staging/lustre/include/linux/lnet/types.h
@@ -514,7 +514,7 @@ typedef struct {
 	/**
 	 * Starting offset of the fragment within the page. Note that the
 	 * end of the fragment must not pass the end of the page; i.e.,
-	 * kiov_len + kiov_offset <= PAGE_CACHE_SIZE.
+	 * kiov_len + kiov_offset <= PAGE_SIZE.
 	 */
 	unsigned int	 kiov_offset;
 } lnet_kiov_t;
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
index 3e1f24e77f64..d4ce06d0aeeb 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
@@ -291,7 +291,7 @@ ksocknal_lib_kiov_vmap(lnet_kiov_t *kiov, int niov,
 
 	for (nob = i = 0; i < niov; i++) {
 		if ((kiov[i].kiov_offset && i > 0) ||
-		    (kiov[i].kiov_offset + kiov[i].kiov_len != PAGE_CACHE_SIZE && i < niov - 1))
+		    (kiov[i].kiov_offset + kiov[i].kiov_len != PAGE_SIZE && i < niov - 1))
 			return NULL;
 
 		pages[i] = kiov[i].kiov_page;
diff --git a/drivers/staging/lustre/lnet/libcfs/debug.c b/drivers/staging/lustre/lnet/libcfs/debug.c
index c90e5102fe06..c3d628bac5b8 100644
--- a/drivers/staging/lustre/lnet/libcfs/debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/debug.c
@@ -517,7 +517,7 @@ int libcfs_debug_init(unsigned long bufsize)
 		max = TCD_MAX_PAGES;
 	} else {
 		max = max / num_possible_cpus();
-		max <<= (20 - PAGE_CACHE_SHIFT);
+		max <<= (20 - PAGE_SHIFT);
 	}
 	rc = cfs_tracefile_init(max);
 
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
index ec3bc04bd89f..244eb89eef68 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -182,7 +182,7 @@ cfs_trace_get_tage_try(struct cfs_trace_cpu_data *tcd, unsigned long len)
 	if (tcd->tcd_cur_pages > 0) {
 		__LASSERT(!list_empty(&tcd->tcd_pages));
 		tage = cfs_tage_from_list(tcd->tcd_pages.prev);
-		if (tage->used + len <= PAGE_CACHE_SIZE)
+		if (tage->used + len <= PAGE_SIZE)
 			return tage;
 	}
 
@@ -260,7 +260,7 @@ static struct cfs_trace_page *cfs_trace_get_tage(struct cfs_trace_cpu_data *tcd,
 	 * from here: this will lead to infinite recursion.
 	 */
 
-	if (len > PAGE_CACHE_SIZE) {
+	if (len > PAGE_SIZE) {
 		pr_err("cowardly refusing to write %lu bytes in a page\n", len);
 		return NULL;
 	}
@@ -349,7 +349,7 @@ int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
 	for (i = 0; i < 2; i++) {
 		tage = cfs_trace_get_tage(tcd, needed + known_size + 1);
 		if (!tage) {
-			if (needed + known_size > PAGE_CACHE_SIZE)
+			if (needed + known_size > PAGE_SIZE)
 				mask |= D_ERROR;
 
 			cfs_trace_put_tcd(tcd);
@@ -360,7 +360,7 @@ int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
 		string_buf = (char *)page_address(tage->page) +
 					tage->used + known_size;
 
-		max_nob = PAGE_CACHE_SIZE - tage->used - known_size;
+		max_nob = PAGE_SIZE - tage->used - known_size;
 		if (max_nob <= 0) {
 			printk(KERN_EMERG "negative max_nob: %d\n",
 			       max_nob);
@@ -424,7 +424,7 @@ int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
 	__LASSERT(debug_buf == string_buf);
 
 	tage->used += needed;
-	__LASSERT(tage->used <= PAGE_CACHE_SIZE);
+	__LASSERT(tage->used <= PAGE_SIZE);
 
 console:
 	if ((mask & libcfs_printk) == 0) {
@@ -835,7 +835,7 @@ EXPORT_SYMBOL(cfs_trace_copyout_string);
 
 int cfs_trace_allocate_string_buffer(char **str, int nob)
 {
-	if (nob > 2 * PAGE_CACHE_SIZE)	    /* string must be "sensible" */
+	if (nob > 2 * PAGE_SIZE)	    /* string must be "sensible" */
 		return -EINVAL;
 
 	*str = kmalloc(nob, GFP_KERNEL | __GFP_ZERO);
@@ -951,7 +951,7 @@ int cfs_trace_set_debug_mb(int mb)
 	}
 
 	mb /= num_possible_cpus();
-	pages = mb << (20 - PAGE_CACHE_SHIFT);
+	pages = mb << (20 - PAGE_SHIFT);
 
 	cfs_tracefile_write_lock();
 
@@ -977,7 +977,7 @@ int cfs_trace_get_debug_mb(void)
 
 	cfs_tracefile_read_unlock();
 
-	return (total_pages >> (20 - PAGE_CACHE_SHIFT)) + 1;
+	return (total_pages >> (20 - PAGE_SHIFT)) + 1;
 }
 
 static int tracefiled(void *arg)
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.h b/drivers/staging/lustre/lnet/libcfs/tracefile.h
index 4c77f9044dd3..ac84e7f4c859 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.h
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.h
@@ -87,7 +87,7 @@ void libcfs_unregister_panic_notifier(void);
 extern int  libcfs_panic_in_progress;
 int cfs_trace_max_debug_mb(void);
 
-#define TCD_MAX_PAGES (5 << (20 - PAGE_CACHE_SHIFT))
+#define TCD_MAX_PAGES (5 << (20 - PAGE_SHIFT))
 #define TCD_STOCK_PAGES (TCD_MAX_PAGES)
 #define CFS_TRACEFILE_SIZE (500 << 20)
 
@@ -96,7 +96,7 @@ int cfs_trace_max_debug_mb(void);
 /*
  * Private declare for tracefile
  */
-#define TCD_MAX_PAGES (5 << (20 - PAGE_CACHE_SHIFT))
+#define TCD_MAX_PAGES (5 << (20 - PAGE_SHIFT))
 #define TCD_STOCK_PAGES (TCD_MAX_PAGES)
 
 #define CFS_TRACEFILE_SIZE (500 << 20)
@@ -257,7 +257,7 @@ do {								    \
 do {								    \
 	__LASSERT(tage);					\
 	__LASSERT(tage->page);				  \
-	__LASSERT(tage->used <= PAGE_CACHE_SIZE);			 \
+	__LASSERT(tage->used <= PAGE_SIZE);			 \
 	__LASSERT(page_count(tage->page) > 0);		      \
 } while (0)
 
diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
index c74514f99f90..75d31217bf92 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-md.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-md.c
@@ -139,7 +139,7 @@ lnet_md_build(lnet_libmd_t *lmd, lnet_md_t *umd, int unlink)
 		for (i = 0; i < (int)niov; i++) {
 			/* We take the page pointer on trust */
 			if (lmd->md_iov.kiov[i].kiov_offset +
-			    lmd->md_iov.kiov[i].kiov_len > PAGE_CACHE_SIZE)
+			    lmd->md_iov.kiov[i].kiov_len > PAGE_SIZE)
 				return -EINVAL; /* invalid length */
 
 			total_length += lmd->md_iov.kiov[i].kiov_len;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 0009a8de77d5..f19aa9320e34 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -549,12 +549,12 @@ lnet_extract_kiov(int dst_niov, lnet_kiov_t *dst,
 		if (len <= frag_len) {
 			dst->kiov_len = len;
 			LASSERT(dst->kiov_offset + dst->kiov_len
-					<= PAGE_CACHE_SIZE);
+					<= PAGE_SIZE);
 			return niov;
 		}
 
 		dst->kiov_len = frag_len;
-		LASSERT(dst->kiov_offset + dst->kiov_len <= PAGE_CACHE_SIZE);
+		LASSERT(dst->kiov_offset + dst->kiov_len <= PAGE_SIZE);
 
 		len -= frag_len;
 		dst++;
@@ -887,7 +887,7 @@ lnet_msg2bufpool(lnet_msg_t *msg)
 	rbp = &the_lnet.ln_rtrpools[cpt][0];
 
 	LASSERT(msg->msg_len <= LNET_MTU);
-	while (msg->msg_len > (unsigned int)rbp->rbp_npages * PAGE_CACHE_SIZE) {
+	while (msg->msg_len > (unsigned int)rbp->rbp_npages * PAGE_SIZE) {
 		rbp++;
 		LASSERT(rbp < &the_lnet.ln_rtrpools[cpt][LNET_NRBPOOLS]);
 	}
diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index cc0c2753dd63..891fd59401d7 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -166,9 +166,9 @@ lnet_ipif_enumerate(char ***namesp)
 	nalloc = 16;	/* first guess at max interfaces */
 	toobig = 0;
 	for (;;) {
-		if (nalloc * sizeof(*ifr) > PAGE_CACHE_SIZE) {
+		if (nalloc * sizeof(*ifr) > PAGE_SIZE) {
 			toobig = 1;
-			nalloc = PAGE_CACHE_SIZE / sizeof(*ifr);
+			nalloc = PAGE_SIZE / sizeof(*ifr);
 			CWARN("Too many interfaces: only enumerating first %d\n",
 			      nalloc);
 		}
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 61459cf9d58f..b01dc424c514 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -27,8 +27,8 @@
 #define LNET_NRB_SMALL_PAGES	1
 #define LNET_NRB_LARGE_MIN	256	/* min value for each CPT */
 #define LNET_NRB_LARGE		(LNET_NRB_LARGE_MIN * 4)
-#define LNET_NRB_LARGE_PAGES   ((LNET_MTU + PAGE_CACHE_SIZE - 1) >> \
-				 PAGE_CACHE_SHIFT)
+#define LNET_NRB_LARGE_PAGES   ((LNET_MTU + PAGE_SIZE - 1) >> \
+				 PAGE_SHIFT)
 
 static char *forwarding = "";
 module_param(forwarding, charp, 0444);
@@ -1338,7 +1338,7 @@ lnet_new_rtrbuf(lnet_rtrbufpool_t *rbp, int cpt)
 			return NULL;
 		}
 
-		rb->rb_kiov[i].kiov_len = PAGE_CACHE_SIZE;
+		rb->rb_kiov[i].kiov_len = PAGE_SIZE;
 		rb->rb_kiov[i].kiov_offset = 0;
 		rb->rb_kiov[i].kiov_page = page;
 	}
diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index eebc92412061..dcb6e506f592 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -90,7 +90,7 @@ brw_client_init(sfw_test_instance_t *tsi)
 		 * NB: this is not going to work for variable page size,
 		 * but we have to keep it for compatibility
 		 */
-		len = npg * PAGE_CACHE_SIZE;
+		len = npg * PAGE_SIZE;
 
 	} else {
 		test_bulk_req_v1_t *breq = &tsi->tsi_u.bulk_v1;
@@ -104,7 +104,7 @@ brw_client_init(sfw_test_instance_t *tsi)
 		opc = breq->blk_opc;
 		flags = breq->blk_flags;
 		len = breq->blk_len;
-		npg = (len + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+		npg = (len + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	}
 
 	if (npg > LNET_MAX_IOV || npg <= 0)
@@ -167,13 +167,13 @@ brw_fill_page(struct page *pg, int pattern, __u64 magic)
 
 	if (pattern == LST_BRW_CHECK_SIMPLE) {
 		memcpy(addr, &magic, BRW_MSIZE);
-		addr += PAGE_CACHE_SIZE - BRW_MSIZE;
+		addr += PAGE_SIZE - BRW_MSIZE;
 		memcpy(addr, &magic, BRW_MSIZE);
 		return;
 	}
 
 	if (pattern == LST_BRW_CHECK_FULL) {
-		for (i = 0; i < PAGE_CACHE_SIZE / BRW_MSIZE; i++)
+		for (i = 0; i < PAGE_SIZE / BRW_MSIZE; i++)
 			memcpy(addr + i * BRW_MSIZE, &magic, BRW_MSIZE);
 		return;
 	}
@@ -198,7 +198,7 @@ brw_check_page(struct page *pg, int pattern, __u64 magic)
 		if (data != magic)
 			goto bad_data;
 
-		addr += PAGE_CACHE_SIZE - BRW_MSIZE;
+		addr += PAGE_SIZE - BRW_MSIZE;
 		data = *((__u64 *)addr);
 		if (data != magic)
 			goto bad_data;
@@ -207,7 +207,7 @@ brw_check_page(struct page *pg, int pattern, __u64 magic)
 	}
 
 	if (pattern == LST_BRW_CHECK_FULL) {
-		for (i = 0; i < PAGE_CACHE_SIZE / BRW_MSIZE; i++) {
+		for (i = 0; i < PAGE_SIZE / BRW_MSIZE; i++) {
 			data = *(((__u64 *)addr) + i);
 			if (data != magic)
 				goto bad_data;
@@ -278,7 +278,7 @@ brw_client_prep_rpc(sfw_test_unit_t *tsu,
 		opc = breq->blk_opc;
 		flags = breq->blk_flags;
 		npg = breq->blk_npg;
-		len = npg * PAGE_CACHE_SIZE;
+		len = npg * PAGE_SIZE;
 
 	} else {
 		test_bulk_req_v1_t *breq = &tsi->tsi_u.bulk_v1;
@@ -292,7 +292,7 @@ brw_client_prep_rpc(sfw_test_unit_t *tsu,
 		opc = breq->blk_opc;
 		flags = breq->blk_flags;
 		len = breq->blk_len;
-		npg = (len + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+		npg = (len + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	}
 
 	rc = sfw_create_test_rpc(tsu, dest, sn->sn_features, npg, len, &rpc);
@@ -463,10 +463,10 @@ brw_server_handle(struct srpc_server_rpc *rpc)
 			reply->brw_status = EINVAL;
 			return 0;
 		}
-		npg = reqst->brw_len >> PAGE_CACHE_SHIFT;
+		npg = reqst->brw_len >> PAGE_SHIFT;
 
 	} else {
-		npg = (reqst->brw_len + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+		npg = (reqst->brw_len + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	}
 
 	replymsg->msg_ses_feats = reqstmsg->msg_ses_feats;
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index 5c7cb72eac9a..79ee6c0bf7c1 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -743,7 +743,7 @@ static int lst_test_add_ioctl(lstio_test_args_t *args)
 	if (args->lstio_tes_param &&
 	    (args->lstio_tes_param_len <= 0 ||
 	     args->lstio_tes_param_len >
-	     PAGE_CACHE_SIZE - sizeof(lstcon_test_t)))
+	     PAGE_SIZE - sizeof(lstcon_test_t)))
 		return -EINVAL;
 
 	LIBCFS_ALLOC(batch_name, args->lstio_tes_bat_nmlen + 1);
@@ -819,7 +819,7 @@ lstcon_ioctl_entry(unsigned int cmd, struct libcfs_ioctl_hdr *hdr)
 
 	opc = data->ioc_u32[0];
 
-	if (data->ioc_plen1 > PAGE_CACHE_SIZE)
+	if (data->ioc_plen1 > PAGE_SIZE)
 		return -EINVAL;
 
 	LIBCFS_ALLOC(buf, data->ioc_plen1);
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index bcd78888f9cc..35a227d0c657 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -786,8 +786,8 @@ lstcon_bulkrpc_v0_prep(lst_test_bulk_param_t *param, srpc_test_reqst_t *req)
 	test_bulk_req_t *brq = &req->tsr_u.bulk_v0;
 
 	brq->blk_opc = param->blk_opc;
-	brq->blk_npg = (param->blk_size + PAGE_CACHE_SIZE - 1) /
-			PAGE_CACHE_SIZE;
+	brq->blk_npg = (param->blk_size + PAGE_SIZE - 1) /
+			PAGE_SIZE;
 	brq->blk_flags = param->blk_flags;
 
 	return 0;
@@ -822,7 +822,7 @@ lstcon_testrpc_prep(lstcon_node_t *nd, int transop, unsigned feats,
 	if (transop == LST_TRANS_TSBCLIADD) {
 		npg = sfw_id_pages(test->tes_span);
 		nob = !(feats & LST_FEAT_BULK_LEN) ?
-		      npg * PAGE_CACHE_SIZE :
+		      npg * PAGE_SIZE :
 		      sizeof(lnet_process_id_packed_t) * test->tes_span;
 	}
 
@@ -851,8 +851,8 @@ lstcon_testrpc_prep(lstcon_node_t *nd, int transop, unsigned feats,
 			LASSERT(nob > 0);
 
 			len = !(feats & LST_FEAT_BULK_LEN) ?
-			      PAGE_CACHE_SIZE :
-			      min_t(int, nob, PAGE_CACHE_SIZE);
+			      PAGE_SIZE :
+			      min_t(int, nob, PAGE_SIZE);
 			nob -= len;
 
 			bulk->bk_iovs[i].kiov_offset = 0;
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 926c3970c498..e2c532399366 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -1161,7 +1161,7 @@ sfw_add_test(struct srpc_server_rpc *rpc)
 		int len;
 
 		if (!(sn->sn_features & LST_FEAT_BULK_LEN)) {
-			len = npg * PAGE_CACHE_SIZE;
+			len = npg * PAGE_SIZE;
 
 		} else {
 			len = sizeof(lnet_process_id_packed_t) *
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index 69be7d6f48fa..7d7748d96332 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -90,7 +90,7 @@ void srpc_set_counters(const srpc_counters_t *cnt)
 static int
 srpc_add_bulk_page(srpc_bulk_t *bk, struct page *pg, int i, int nob)
 {
-	nob = min_t(int, nob, PAGE_CACHE_SIZE);
+	nob = min_t(int, nob, PAGE_SIZE);
 
 	LASSERT(nob > 0);
 	LASSERT(i >= 0 && i < bk->bk_niov);
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 288522d4d7b9..c85b52e2da13 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -390,10 +390,10 @@ typedef struct sfw_test_instance {
 	} tsi_u;
 } sfw_test_instance_t;
 
-/* XXX: trailing (PAGE_CACHE_SIZE % sizeof(lnet_process_id_t)) bytes at
+/* XXX: trailing (PAGE_SIZE % sizeof(lnet_process_id_t)) bytes at
  * the end of pages are not used */
 #define SFW_MAX_CONCUR	   LST_MAX_CONCUR
-#define SFW_ID_PER_PAGE    (PAGE_CACHE_SIZE / sizeof(lnet_process_id_packed_t))
+#define SFW_ID_PER_PAGE    (PAGE_SIZE / sizeof(lnet_process_id_packed_t))
 #define SFW_MAX_NDESTS	   (LNET_MAX_IOV * SFW_ID_PER_PAGE)
 #define sfw_id_pages(n)    (((n) + SFW_ID_PER_PAGE - 1) / SFW_ID_PER_PAGE)
 
diff --git a/drivers/staging/lustre/lustre/include/linux/lustre_patchless_compat.h b/drivers/staging/lustre/lustre/include/linux/lustre_patchless_compat.h
index 33e0b99e1fb4..c6c7f54637fb 100644
--- a/drivers/staging/lustre/lustre/include/linux/lustre_patchless_compat.h
+++ b/drivers/staging/lustre/lustre/include/linux/lustre_patchless_compat.h
@@ -52,7 +52,7 @@ truncate_complete_page(struct address_space *mapping, struct page *page)
 		return;
 
 	if (PagePrivate(page))
-		page->mapping->a_ops->invalidatepage(page, 0, PAGE_CACHE_SIZE);
+		page->mapping->a_ops->invalidatepage(page, 0, PAGE_SIZE);
 
 	cancel_dirty_page(page);
 	ClearPageMappedToDisk(page);
diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index b5088b13a305..242bb1ef6245 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -1118,7 +1118,7 @@ struct lu_context_key {
 	{							 \
 		type *value;				      \
 								  \
-		CLASSERT(PAGE_CACHE_SIZE >= sizeof (*value));       \
+		CLASSERT(PAGE_SIZE >= sizeof (*value));       \
 								  \
 		value = kzalloc(sizeof(*value), GFP_NOFS);	\
 		if (!value)				\
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index da8bc6eadd13..5aae1d06a5fa 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1022,16 +1022,16 @@ static inline int lu_dirent_size(struct lu_dirent *ent)
  * MDS_READPAGE page size
  *
  * This is the directory page size packed in MDS_READPAGE RPC.
- * It's different than PAGE_CACHE_SIZE because the client needs to
+ * It's different than PAGE_SIZE because the client needs to
  * access the struct lu_dirpage header packed at the beginning of
  * the "page" and without this there isn't any way to know find the
- * lu_dirpage header is if client and server PAGE_CACHE_SIZE differ.
+ * lu_dirpage header is if client and server PAGE_SIZE differ.
  */
 #define LU_PAGE_SHIFT 12
 #define LU_PAGE_SIZE  (1UL << LU_PAGE_SHIFT)
 #define LU_PAGE_MASK  (~(LU_PAGE_SIZE - 1))
 
-#define LU_PAGE_COUNT (1 << (PAGE_CACHE_SHIFT - LU_PAGE_SHIFT))
+#define LU_PAGE_COUNT (1 << (PAGE_SHIFT - LU_PAGE_SHIFT))
 
 /** @} lu_dir */
 
diff --git a/drivers/staging/lustre/lustre/include/lustre_mdc.h b/drivers/staging/lustre/lustre/include/lustre_mdc.h
index df94f9f3bef2..af77eb359c43 100644
--- a/drivers/staging/lustre/lustre/include/lustre_mdc.h
+++ b/drivers/staging/lustre/lustre/include/lustre_mdc.h
@@ -155,12 +155,12 @@ static inline void mdc_update_max_ea_from_body(struct obd_export *exp,
 		if (cli->cl_max_mds_easize < body->max_mdsize) {
 			cli->cl_max_mds_easize = body->max_mdsize;
 			cli->cl_default_mds_easize =
-			    min_t(__u32, body->max_mdsize, PAGE_CACHE_SIZE);
+			    min_t(__u32, body->max_mdsize, PAGE_SIZE);
 		}
 		if (cli->cl_max_mds_cookiesize < body->max_cookiesize) {
 			cli->cl_max_mds_cookiesize = body->max_cookiesize;
 			cli->cl_default_mds_cookiesize =
-			    min_t(__u32, body->max_cookiesize, PAGE_CACHE_SIZE);
+			    min_t(__u32, body->max_cookiesize, PAGE_SIZE);
 		}
 	}
 }
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 4fa1a18b7d15..69586a522eb7 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -99,21 +99,21 @@
  */
 #define PTLRPC_MAX_BRW_BITS	(LNET_MTU_BITS + PTLRPC_BULK_OPS_BITS)
 #define PTLRPC_MAX_BRW_SIZE	(1 << PTLRPC_MAX_BRW_BITS)
-#define PTLRPC_MAX_BRW_PAGES	(PTLRPC_MAX_BRW_SIZE >> PAGE_CACHE_SHIFT)
+#define PTLRPC_MAX_BRW_PAGES	(PTLRPC_MAX_BRW_SIZE >> PAGE_SHIFT)
 
 #define ONE_MB_BRW_SIZE		(1 << LNET_MTU_BITS)
 #define MD_MAX_BRW_SIZE		(1 << LNET_MTU_BITS)
-#define MD_MAX_BRW_PAGES	(MD_MAX_BRW_SIZE >> PAGE_CACHE_SHIFT)
+#define MD_MAX_BRW_PAGES	(MD_MAX_BRW_SIZE >> PAGE_SHIFT)
 #define DT_MAX_BRW_SIZE		PTLRPC_MAX_BRW_SIZE
-#define DT_MAX_BRW_PAGES	(DT_MAX_BRW_SIZE >> PAGE_CACHE_SHIFT)
+#define DT_MAX_BRW_PAGES	(DT_MAX_BRW_SIZE >> PAGE_SHIFT)
 #define OFD_MAX_BRW_SIZE	(1 << LNET_MTU_BITS)
 
 /* When PAGE_SIZE is a constant, we can check our arithmetic here with cpp! */
 # if ((PTLRPC_MAX_BRW_PAGES & (PTLRPC_MAX_BRW_PAGES - 1)) != 0)
 #  error "PTLRPC_MAX_BRW_PAGES isn't a power of two"
 # endif
-# if (PTLRPC_MAX_BRW_SIZE != (PTLRPC_MAX_BRW_PAGES * PAGE_CACHE_SIZE))
-#  error "PTLRPC_MAX_BRW_SIZE isn't PTLRPC_MAX_BRW_PAGES * PAGE_CACHE_SIZE"
+# if (PTLRPC_MAX_BRW_SIZE != (PTLRPC_MAX_BRW_PAGES * PAGE_SIZE))
+#  error "PTLRPC_MAX_BRW_SIZE isn't PTLRPC_MAX_BRW_PAGES * PAGE_SIZE"
 # endif
 # if (PTLRPC_MAX_BRW_SIZE > LNET_MTU * PTLRPC_BULK_OPS_COUNT)
 #  error "PTLRPC_MAX_BRW_SIZE too big"
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 4a0f2e8b19f6..4264d97650ec 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -272,7 +272,7 @@ struct client_obd {
 	int		 cl_grant_shrink_interval; /* seconds */
 
 	/* A chunk is an optimal size used by osc_extent to determine
-	 * the extent size. A chunk is max(PAGE_CACHE_SIZE, OST block size)
+	 * the extent size. A chunk is max(PAGE_SIZE, OST block size)
 	 */
 	int		  cl_chunkbits;
 	int		  cl_chunk;
@@ -1318,7 +1318,7 @@ bad_format:
 
 static inline int cli_brw_size(struct obd_device *obd)
 {
-	return obd->u.cli.cl_max_pages_per_rpc << PAGE_CACHE_SHIFT;
+	return obd->u.cli.cl_max_pages_per_rpc << PAGE_SHIFT;
 }
 
 #endif /* __OBD_H */
diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index 225262fa67b6..f8ee3a3254ba 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -500,7 +500,7 @@ extern char obd_jobid_var[];
 
 #ifdef POISON_BULK
 #define POISON_PAGE(page, val) do {		  \
-	memset(kmap(page), val, PAGE_CACHE_SIZE); \
+	memset(kmap(page), val, PAGE_SIZE); \
 	kunmap(page);				  \
 } while (0)
 #else
diff --git a/drivers/staging/lustre/lustre/lclient/lcommon_cl.c b/drivers/staging/lustre/lustre/lclient/lcommon_cl.c
index aced41ab93a1..96141d17d07f 100644
--- a/drivers/staging/lustre/lustre/lclient/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/lclient/lcommon_cl.c
@@ -758,9 +758,9 @@ int ccc_prep_size(const struct lu_env *env, struct cl_object *obj,
 				 * --bug 17336
 				 */
 				loff_t size = cl_isize_read(inode);
-				loff_t cur_index = start >> PAGE_CACHE_SHIFT;
+				loff_t cur_index = start >> PAGE_SHIFT;
 				loff_t size_index = (size - 1) >>
-						    PAGE_CACHE_SHIFT;
+						    PAGE_SHIFT;
 
 				if ((size == 0 && cur_index != 0) ||
 				    size_index < cur_index)
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index b586d5a88d00..7dd7df59aa1f 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -307,8 +307,8 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 	cli->cl_avail_grant = 0;
 	/* FIXME: Should limit this for the sum of all cl_dirty_max. */
 	cli->cl_dirty_max = OSC_MAX_DIRTY_DEFAULT * 1024 * 1024;
-	if (cli->cl_dirty_max >> PAGE_CACHE_SHIFT > totalram_pages / 8)
-		cli->cl_dirty_max = totalram_pages << (PAGE_CACHE_SHIFT - 3);
+	if (cli->cl_dirty_max >> PAGE_SHIFT > totalram_pages / 8)
+		cli->cl_dirty_max = totalram_pages << (PAGE_SHIFT - 3);
 	INIT_LIST_HEAD(&cli->cl_cache_waiters);
 	INIT_LIST_HEAD(&cli->cl_loi_ready_list);
 	INIT_LIST_HEAD(&cli->cl_loi_hp_ready_list);
@@ -353,15 +353,15 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 	 * In the future this should likely be increased. LU-1431
 	 */
 	cli->cl_max_pages_per_rpc = min_t(int, PTLRPC_MAX_BRW_PAGES,
-					  LNET_MTU >> PAGE_CACHE_SHIFT);
+					  LNET_MTU >> PAGE_SHIFT);
 
 	if (!strcmp(name, LUSTRE_MDC_NAME)) {
 		cli->cl_max_rpcs_in_flight = MDC_MAX_RIF_DEFAULT;
-	} else if (totalram_pages >> (20 - PAGE_CACHE_SHIFT) <= 128 /* MB */) {
+	} else if (totalram_pages >> (20 - PAGE_SHIFT) <= 128 /* MB */) {
 		cli->cl_max_rpcs_in_flight = 2;
-	} else if (totalram_pages >> (20 - PAGE_CACHE_SHIFT) <= 256 /* MB */) {
+	} else if (totalram_pages >> (20 - PAGE_SHIFT) <= 256 /* MB */) {
 		cli->cl_max_rpcs_in_flight = 3;
-	} else if (totalram_pages >> (20 - PAGE_CACHE_SHIFT) <= 512 /* MB */) {
+	} else if (totalram_pages >> (20 - PAGE_SHIFT) <= 512 /* MB */) {
 		cli->cl_max_rpcs_in_flight = 4;
 	} else {
 		cli->cl_max_rpcs_in_flight = OSC_MAX_RIF_DEFAULT;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
index 3e937b050203..b913ba9cf97c 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
@@ -107,7 +107,7 @@
 /*
  * 50 ldlm locks for 1MB of RAM.
  */
-#define LDLM_POOL_HOST_L ((NUM_CACHEPAGES >> (20 - PAGE_CACHE_SHIFT)) * 50)
+#define LDLM_POOL_HOST_L ((NUM_CACHEPAGES >> (20 - PAGE_SHIFT)) * 50)
 
 /*
  * Maximal possible grant step plan in %.
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index c7904a96f9af..74e193e52cd6 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -546,7 +546,7 @@ static inline int ldlm_req_handles_avail(int req_size, int off)
 {
 	int avail;
 
-	avail = min_t(int, LDLM_MAXREQSIZE, PAGE_CACHE_SIZE - 512) - req_size;
+	avail = min_t(int, LDLM_MAXREQSIZE, PAGE_SIZE - 512) - req_size;
 	if (likely(avail >= 0))
 		avail /= (int)sizeof(struct lustre_handle);
 	else
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 4e0a3e583330..ed66b844aa5d 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -134,7 +134,7 @@
  * a header lu_dirpage which describes the start/end hash, and whether this
  * page is empty (contains no dir entry) or hash collide with next page.
  * After client receives reply, several pages will be integrated into dir page
- * in PAGE_CACHE_SIZE (if PAGE_CACHE_SIZE greater than LU_PAGE_SIZE), and the
+ * in PAGE_SIZE (if PAGE_SIZE greater than LU_PAGE_SIZE), and the
  * lu_dirpage for this integrated page will be adjusted. See
  * lmv_adjust_dirpages().
  *
@@ -153,7 +153,7 @@ static int ll_dir_filler(void *_hash, struct page *page0)
 	struct page **page_pool;
 	struct page *page;
 	struct lu_dirpage *dp;
-	int max_pages = ll_i2sbi(inode)->ll_md_brw_size >> PAGE_CACHE_SHIFT;
+	int max_pages = ll_i2sbi(inode)->ll_md_brw_size >> PAGE_SHIFT;
 	int nrdpgs = 0; /* number of pages read actually */
 	int npages;
 	int i;
@@ -193,8 +193,8 @@ static int ll_dir_filler(void *_hash, struct page *page0)
 		if (body->valid & OBD_MD_FLSIZE)
 			cl_isize_write(inode, body->size);
 
-		nrdpgs = (request->rq_bulk->bd_nob_transferred+PAGE_CACHE_SIZE-1)
-			 >> PAGE_CACHE_SHIFT;
+		nrdpgs = (request->rq_bulk->bd_nob_transferred+PAGE_SIZE-1)
+			 >> PAGE_SHIFT;
 		SetPageUptodate(page0);
 	}
 	unlock_page(page0);
@@ -209,7 +209,7 @@ static int ll_dir_filler(void *_hash, struct page *page0)
 		page = page_pool[i];
 
 		if (rc < 0 || i >= nrdpgs) {
-			page_cache_release(page);
+			put_page(page);
 			continue;
 		}
 
@@ -230,7 +230,7 @@ static int ll_dir_filler(void *_hash, struct page *page0)
 			CDEBUG(D_VFSTRACE, "page %lu add to page cache failed: %d\n",
 			       offset, ret);
 		}
-		page_cache_release(page);
+		put_page(page);
 	}
 
 	if (page_pool != &page0)
@@ -247,7 +247,7 @@ void ll_release_page(struct page *page, int remove)
 			truncate_complete_page(page->mapping, page);
 		unlock_page(page);
 	}
-	page_cache_release(page);
+	put_page(page);
 }
 
 /*
@@ -273,7 +273,7 @@ static struct page *ll_dir_page_locate(struct inode *dir, __u64 *hash,
 	if (found > 0 && !radix_tree_exceptional_entry(page)) {
 		struct lu_dirpage *dp;
 
-		page_cache_get(page);
+		get_page(page);
 		spin_unlock_irq(&mapping->tree_lock);
 		/*
 		 * In contrast to find_lock_page() we are sure that directory
@@ -313,7 +313,7 @@ static struct page *ll_dir_page_locate(struct inode *dir, __u64 *hash,
 				page = NULL;
 			}
 		} else {
-			page_cache_release(page);
+			put_page(page);
 			page = ERR_PTR(-EIO);
 		}
 
@@ -1507,7 +1507,7 @@ skip_lmm:
 			st.st_gid     = body->gid;
 			st.st_rdev    = body->rdev;
 			st.st_size    = body->size;
-			st.st_blksize = PAGE_CACHE_SIZE;
+			st.st_blksize = PAGE_SIZE;
 			st.st_blocks  = body->blocks;
 			st.st_atime   = body->atime;
 			st.st_mtime   = body->mtime;
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 973f5cdec192..5394365cc595 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -310,10 +310,10 @@ static inline struct ll_inode_info *ll_i2info(struct inode *inode)
 /* default to about 40meg of readahead on a given system.  That much tied
  * up in 512k readahead requests serviced at 40ms each is about 1GB/s.
  */
-#define SBI_DEFAULT_READAHEAD_MAX (40UL << (20 - PAGE_CACHE_SHIFT))
+#define SBI_DEFAULT_READAHEAD_MAX (40UL << (20 - PAGE_SHIFT))
 
 /* default to read-ahead full files smaller than 2MB on the second read */
-#define SBI_DEFAULT_READAHEAD_WHOLE_MAX (2UL << (20 - PAGE_CACHE_SHIFT))
+#define SBI_DEFAULT_READAHEAD_WHOLE_MAX (2UL << (20 - PAGE_SHIFT))
 
 enum ra_stat {
 	RA_STAT_HIT = 0,
@@ -975,13 +975,13 @@ struct vm_area_struct *our_vma(struct mm_struct *mm, unsigned long addr,
 static inline void ll_invalidate_page(struct page *vmpage)
 {
 	struct address_space *mapping = vmpage->mapping;
-	loff_t offset = vmpage->index << PAGE_CACHE_SHIFT;
+	loff_t offset = vmpage->index << PAGE_SHIFT;
 
 	LASSERT(PageLocked(vmpage));
 	if (!mapping)
 		return;
 
-	ll_teardown_mmaps(mapping, offset, offset + PAGE_CACHE_SIZE);
+	ll_teardown_mmaps(mapping, offset, offset + PAGE_SIZE);
 	truncate_complete_page(mapping, vmpage);
 }
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 6d6bb33e3655..b57a992688a8 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -85,7 +85,7 @@ static struct ll_sb_info *ll_init_sbi(struct super_block *sb)
 
 	si_meminfo(&si);
 	pages = si.totalram - si.totalhigh;
-	if (pages >> (20 - PAGE_CACHE_SHIFT) < 512)
+	if (pages >> (20 - PAGE_SHIFT) < 512)
 		lru_page_max = pages / 2;
 	else
 		lru_page_max = (pages / 4) * 3;
@@ -272,12 +272,12 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 	    valid != CLIENT_CONNECT_MDT_REQD) {
 		char *buf;
 
-		buf = kzalloc(PAGE_CACHE_SIZE, GFP_KERNEL);
+		buf = kzalloc(PAGE_SIZE, GFP_KERNEL);
 		if (!buf) {
 			err = -ENOMEM;
 			goto out_md_fid;
 		}
-		obd_connect_flags2str(buf, PAGE_CACHE_SIZE,
+		obd_connect_flags2str(buf, PAGE_SIZE,
 				      valid ^ CLIENT_CONNECT_MDT_REQD, ",");
 		LCONSOLE_ERROR_MSG(0x170, "Server %s does not support feature(s) needed for correct operation of this client (%s). Please upgrade server or downgrade client.\n",
 				   sbi->ll_md_exp->exp_obd->obd_name, buf);
@@ -335,7 +335,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 	if (data->ocd_connect_flags & OBD_CONNECT_BRW_SIZE)
 		sbi->ll_md_brw_size = data->ocd_brw_size;
 	else
-		sbi->ll_md_brw_size = PAGE_CACHE_SIZE;
+		sbi->ll_md_brw_size = PAGE_SIZE;
 
 	if (data->ocd_connect_flags & OBD_CONNECT_LAYOUTLOCK) {
 		LCONSOLE_INFO("Layout lock feature supported.\n");
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index 69445a9f2011..5b484e62ffd0 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -58,7 +58,7 @@ void policy_from_vma(ldlm_policy_data_t *policy,
 		     size_t count)
 {
 	policy->l_extent.start = ((addr - vma->vm_start) & CFS_PAGE_MASK) +
-				 (vma->vm_pgoff << PAGE_CACHE_SHIFT);
+				 (vma->vm_pgoff << PAGE_SHIFT);
 	policy->l_extent.end = (policy->l_extent.start + count - 1) |
 			       ~CFS_PAGE_MASK;
 }
@@ -321,7 +321,7 @@ static int ll_fault0(struct vm_area_struct *vma, struct vm_fault *vmf)
 
 		vmpage = vio->u.fault.ft_vmpage;
 		if (result != 0 && vmpage) {
-			page_cache_release(vmpage);
+			put_page(vmpage);
 			vmf->page = NULL;
 		}
 	}
@@ -360,7 +360,7 @@ restart:
 		lock_page(vmpage);
 		if (unlikely(!vmpage->mapping)) { /* unlucky */
 			unlock_page(vmpage);
-			page_cache_release(vmpage);
+			put_page(vmpage);
 			vmf->page = NULL;
 
 			if (!printed && ++count > 16) {
@@ -457,7 +457,7 @@ int ll_teardown_mmaps(struct address_space *mapping, __u64 first, __u64 last)
 	LASSERTF(last > first, "last %llu first %llu\n", last, first);
 	if (mapping_mapped(mapping)) {
 		rc = 0;
-		unmap_mapping_range(mapping, first + PAGE_CACHE_SIZE - 1,
+		unmap_mapping_range(mapping, first + PAGE_SIZE - 1,
 				    last - first + 1, 0);
 	}
 
diff --git a/drivers/staging/lustre/lustre/llite/lloop.c b/drivers/staging/lustre/lustre/llite/lloop.c
index b725fc16cf49..f169c0db63b4 100644
--- a/drivers/staging/lustre/lustre/llite/lloop.c
+++ b/drivers/staging/lustre/lustre/llite/lloop.c
@@ -218,7 +218,7 @@ static int do_bio_lustrebacked(struct lloop_device *lo, struct bio *head)
 		offset = (pgoff_t)(bio->bi_iter.bi_sector << 9) + lo->lo_offset;
 		bio_for_each_segment(bvec, bio, iter) {
 			BUG_ON(bvec.bv_offset != 0);
-			BUG_ON(bvec.bv_len != PAGE_CACHE_SIZE);
+			BUG_ON(bvec.bv_len != PAGE_SIZE);
 
 			pages[page_count] = bvec.bv_page;
 			offsets[page_count] = offset;
@@ -232,7 +232,7 @@ static int do_bio_lustrebacked(struct lloop_device *lo, struct bio *head)
 			(rw == WRITE) ? LPROC_LL_BRW_WRITE : LPROC_LL_BRW_READ,
 			page_count);
 
-	pvec->ldp_size = page_count << PAGE_CACHE_SHIFT;
+	pvec->ldp_size = page_count << PAGE_SHIFT;
 	pvec->ldp_nr = page_count;
 
 	/* FIXME: in ll_direct_rw_pages, it has to allocate many cl_page{}s to
@@ -507,7 +507,7 @@ static int loop_set_fd(struct lloop_device *lo, struct file *unused,
 
 	set_device_ro(bdev, (lo_flags & LO_FLAGS_READ_ONLY) != 0);
 
-	lo->lo_blocksize = PAGE_CACHE_SIZE;
+	lo->lo_blocksize = PAGE_SIZE;
 	lo->lo_device = bdev;
 	lo->lo_flags = lo_flags;
 	lo->lo_backing_file = file;
@@ -525,11 +525,11 @@ static int loop_set_fd(struct lloop_device *lo, struct file *unused,
 	lo->lo_queue->queuedata = lo;
 
 	/* queue parameters */
-	CLASSERT(PAGE_CACHE_SIZE < (1 << (sizeof(unsigned short) * 8)));
+	CLASSERT(PAGE_SIZE < (1 << (sizeof(unsigned short) * 8)));
 	blk_queue_logical_block_size(lo->lo_queue,
-				     (unsigned short)PAGE_CACHE_SIZE);
+				     (unsigned short)PAGE_SIZE);
 	blk_queue_max_hw_sectors(lo->lo_queue,
-				 LLOOP_MAX_SEGMENTS << (PAGE_CACHE_SHIFT - 9));
+				 LLOOP_MAX_SEGMENTS << (PAGE_SHIFT - 9));
 	blk_queue_max_segments(lo->lo_queue, LLOOP_MAX_SEGMENTS);
 
 	set_capacity(disks[lo->lo_number], size);
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 45941a6600fe..27ab1261400e 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -233,7 +233,7 @@ static ssize_t max_read_ahead_mb_show(struct kobject *kobj,
 	pages_number = sbi->ll_ra_info.ra_max_pages;
 	spin_unlock(&sbi->ll_lock);
 
-	mult = 1 << (20 - PAGE_CACHE_SHIFT);
+	mult = 1 << (20 - PAGE_SHIFT);
 	return lprocfs_read_frac_helper(buf, PAGE_SIZE, pages_number, mult);
 }
 
@@ -251,12 +251,12 @@ static ssize_t max_read_ahead_mb_store(struct kobject *kobj,
 	if (rc)
 		return rc;
 
-	pages_number *= 1 << (20 - PAGE_CACHE_SHIFT); /* MB -> pages */
+	pages_number *= 1 << (20 - PAGE_SHIFT); /* MB -> pages */
 
 	if (pages_number > totalram_pages / 2) {
 
 		CERROR("can't set file readahead more than %lu MB\n",
-		       totalram_pages >> (20 - PAGE_CACHE_SHIFT + 1)); /*1/2 of RAM*/
+		       totalram_pages >> (20 - PAGE_SHIFT + 1)); /*1/2 of RAM*/
 		return -ERANGE;
 	}
 
@@ -281,7 +281,7 @@ static ssize_t max_read_ahead_per_file_mb_show(struct kobject *kobj,
 	pages_number = sbi->ll_ra_info.ra_max_pages_per_file;
 	spin_unlock(&sbi->ll_lock);
 
-	mult = 1 << (20 - PAGE_CACHE_SHIFT);
+	mult = 1 << (20 - PAGE_SHIFT);
 	return lprocfs_read_frac_helper(buf, PAGE_SIZE, pages_number, mult);
 }
 
@@ -326,7 +326,7 @@ static ssize_t max_read_ahead_whole_mb_show(struct kobject *kobj,
 	pages_number = sbi->ll_ra_info.ra_max_read_ahead_whole_pages;
 	spin_unlock(&sbi->ll_lock);
 
-	mult = 1 << (20 - PAGE_CACHE_SHIFT);
+	mult = 1 << (20 - PAGE_SHIFT);
 	return lprocfs_read_frac_helper(buf, PAGE_SIZE, pages_number, mult);
 }
 
@@ -349,7 +349,7 @@ static ssize_t max_read_ahead_whole_mb_store(struct kobject *kobj,
 	 */
 	if (pages_number > sbi->ll_ra_info.ra_max_pages_per_file) {
 		CERROR("can't set max_read_ahead_whole_mb more than max_read_ahead_per_file_mb: %lu\n",
-		       sbi->ll_ra_info.ra_max_pages_per_file >> (20 - PAGE_CACHE_SHIFT));
+		       sbi->ll_ra_info.ra_max_pages_per_file >> (20 - PAGE_SHIFT));
 		return -ERANGE;
 	}
 
@@ -366,7 +366,7 @@ static int ll_max_cached_mb_seq_show(struct seq_file *m, void *v)
 	struct super_block     *sb    = m->private;
 	struct ll_sb_info      *sbi   = ll_s2sbi(sb);
 	struct cl_client_cache *cache = &sbi->ll_cache;
-	int shift = 20 - PAGE_CACHE_SHIFT;
+	int shift = 20 - PAGE_SHIFT;
 	int max_cached_mb;
 	int unused_mb;
 
@@ -405,7 +405,7 @@ static ssize_t ll_max_cached_mb_seq_write(struct file *file,
 		return -EFAULT;
 	kernbuf[count] = 0;
 
-	mult = 1 << (20 - PAGE_CACHE_SHIFT);
+	mult = 1 << (20 - PAGE_SHIFT);
 	buffer += lprocfs_find_named_value(kernbuf, "max_cached_mb:", &count) -
 		  kernbuf;
 	rc = lprocfs_write_frac_helper(buffer, count, &pages_number, mult);
@@ -415,7 +415,7 @@ static ssize_t ll_max_cached_mb_seq_write(struct file *file,
 	if (pages_number < 0 || pages_number > totalram_pages) {
 		CERROR("%s: can't set max cache more than %lu MB\n",
 		       ll_get_fsname(sb, NULL, 0),
-		       totalram_pages >> (20 - PAGE_CACHE_SHIFT));
+		       totalram_pages >> (20 - PAGE_SHIFT));
 		return -ERANGE;
 	}
 
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index 34614acf3f8e..edab6c5b7e50 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -146,10 +146,10 @@ static struct ll_cl_context *ll_cl_init(struct file *file,
 		 */
 		io->ci_lockreq = CILR_NEVER;
 
-		pos = vmpage->index << PAGE_CACHE_SHIFT;
+		pos = vmpage->index << PAGE_SHIFT;
 
 		/* Create a temp IO to serve write. */
-		result = cl_io_rw_init(env, io, CIT_WRITE, pos, PAGE_CACHE_SIZE);
+		result = cl_io_rw_init(env, io, CIT_WRITE, pos, PAGE_SIZE);
 		if (result == 0) {
 			cio->cui_fd = LUSTRE_FPRIVATE(file);
 			cio->cui_iter = NULL;
@@ -498,7 +498,7 @@ static int ll_read_ahead_page(const struct lu_env *env, struct cl_io *io,
 		}
 		if (rc != 1)
 			unlock_page(vmpage);
-		page_cache_release(vmpage);
+		put_page(vmpage);
 	} else {
 		which = RA_STAT_FAILED_GRAB_PAGE;
 		msg   = "g_c_p_n failed";
@@ -521,13 +521,13 @@ static int ll_read_ahead_page(const struct lu_env *env, struct cl_io *io,
  * striped over, rather than having a constant value for all files here.
  */
 
-/* RAS_INCREASE_STEP should be (1UL << (inode->i_blkbits - PAGE_CACHE_SHIFT)).
+/* RAS_INCREASE_STEP should be (1UL << (inode->i_blkbits - PAGE_SHIFT)).
  * Temporarily set RAS_INCREASE_STEP to 1MB. After 4MB RPC is enabled
  * by default, this should be adjusted corresponding with max_read_ahead_mb
  * and max_read_ahead_per_file_mb otherwise the readahead budget can be used
  * up quickly which will affect read performance significantly. See LU-2816
  */
-#define RAS_INCREASE_STEP(inode) (ONE_MB_BRW_SIZE >> PAGE_CACHE_SHIFT)
+#define RAS_INCREASE_STEP(inode) (ONE_MB_BRW_SIZE >> PAGE_SHIFT)
 
 static inline int stride_io_mode(struct ll_readahead_state *ras)
 {
@@ -739,7 +739,7 @@ int ll_readahead(const struct lu_env *env, struct cl_io *io,
 			end = rpc_boundary;
 
 		/* Truncate RA window to end of file */
-		end = min(end, (unsigned long)((kms - 1) >> PAGE_CACHE_SHIFT));
+		end = min(end, (unsigned long)((kms - 1) >> PAGE_SHIFT));
 
 		ras->ras_next_readahead = max(end, end + 1);
 		RAS_CDEBUG(ras);
@@ -776,7 +776,7 @@ int ll_readahead(const struct lu_env *env, struct cl_io *io,
 	if (reserved != 0)
 		ll_ra_count_put(ll_i2sbi(inode), reserved);
 
-	if (ra_end == end + 1 && ra_end == (kms >> PAGE_CACHE_SHIFT))
+	if (ra_end == end + 1 && ra_end == (kms >> PAGE_SHIFT))
 		ll_ra_stats_inc(mapping, RA_STAT_EOF);
 
 	/* if we didn't get to the end of the region we reserved from
@@ -985,8 +985,8 @@ void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 	if (ras->ras_requests == 2 && !ras->ras_request_index) {
 		__u64 kms_pages;
 
-		kms_pages = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >>
-			    PAGE_CACHE_SHIFT;
+		kms_pages = (i_size_read(inode) + PAGE_SIZE - 1) >>
+			    PAGE_SHIFT;
 
 		CDEBUG(D_READA, "kmsp %llu mwp %lu mp %lu\n", kms_pages,
 		       ra->ra_max_read_ahead_whole_pages, ra->ra_max_pages_per_file);
@@ -1173,7 +1173,7 @@ int ll_writepage(struct page *vmpage, struct writeback_control *wbc)
 		 * PageWriteback or clean the page.
 		 */
 		result = cl_sync_file_range(inode, offset,
-					    offset + PAGE_CACHE_SIZE - 1,
+					    offset + PAGE_SIZE - 1,
 					    CL_FSYNC_LOCAL, 1);
 		if (result > 0) {
 			/* actually we may have written more than one page.
@@ -1211,7 +1211,7 @@ int ll_writepages(struct address_space *mapping, struct writeback_control *wbc)
 	int ignore_layout = 0;
 
 	if (wbc->range_cyclic) {
-		start = mapping->writeback_index << PAGE_CACHE_SHIFT;
+		start = mapping->writeback_index << PAGE_SHIFT;
 		end = OBD_OBJECT_EOF;
 	} else {
 		start = wbc->range_start;
@@ -1241,7 +1241,7 @@ int ll_writepages(struct address_space *mapping, struct writeback_control *wbc)
 	if (wbc->range_cyclic || (range_whole && wbc->nr_to_write > 0)) {
 		if (end == OBD_OBJECT_EOF)
 			end = i_size_read(inode);
-		mapping->writeback_index = (end >> PAGE_CACHE_SHIFT) + 1;
+		mapping->writeback_index = (end >> PAGE_SHIFT) + 1;
 	}
 	return result;
 }
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index 7a5db67bc680..69aa15e8e3ef 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -87,7 +87,7 @@ static void ll_invalidatepage(struct page *vmpage, unsigned int offset,
 	 * below because they are run with page locked and all our io is
 	 * happening with locked page too
 	 */
-	if (offset == 0 && length == PAGE_CACHE_SIZE) {
+	if (offset == 0 && length == PAGE_SIZE) {
 		env = cl_env_get(&refcheck);
 		if (!IS_ERR(env)) {
 			inode = vmpage->mapping->host;
@@ -193,8 +193,8 @@ static inline int ll_get_user_pages(int rw, unsigned long user_addr,
 		return -EFBIG;
 	}
 
-	*max_pages = (user_addr + size + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-	*max_pages -= user_addr >> PAGE_CACHE_SHIFT;
+	*max_pages = (user_addr + size + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	*max_pages -= user_addr >> PAGE_SHIFT;
 
 	*pages = libcfs_kvzalloc(*max_pages * sizeof(**pages), GFP_NOFS);
 	if (*pages) {
@@ -217,7 +217,7 @@ static void ll_free_user_pages(struct page **pages, int npages, int do_dirty)
 	for (i = 0; i < npages; i++) {
 		if (do_dirty)
 			set_page_dirty_lock(pages[i]);
-		page_cache_release(pages[i]);
+		put_page(pages[i]);
 	}
 	kvfree(pages);
 }
@@ -357,7 +357,7 @@ static ssize_t ll_direct_IO_26_seg(const struct lu_env *env, struct cl_io *io,
  * up to 22MB for 128kB kmalloc and up to 682MB for 4MB kmalloc.
  */
 #define MAX_DIO_SIZE ((KMALLOC_MAX_SIZE / sizeof(struct brw_page) *	  \
-		       PAGE_CACHE_SIZE) & ~(DT_MAX_BRW_SIZE - 1))
+		       PAGE_SIZE) & ~(DT_MAX_BRW_SIZE - 1))
 static ssize_t ll_direct_IO_26(struct kiocb *iocb, struct iov_iter *iter,
 			       loff_t file_offset)
 {
@@ -382,8 +382,8 @@ static ssize_t ll_direct_IO_26(struct kiocb *iocb, struct iov_iter *iter,
 	CDEBUG(D_VFSTRACE,
 	       "VFS Op:inode=%lu/%u(%p), size=%zd (max %lu), offset=%lld=%llx, pages %zd (max %lu)\n",
 	       inode->i_ino, inode->i_generation, inode, count, MAX_DIO_SIZE,
-	       file_offset, file_offset, count >> PAGE_CACHE_SHIFT,
-	       MAX_DIO_SIZE >> PAGE_CACHE_SHIFT);
+	       file_offset, file_offset, count >> PAGE_SHIFT,
+	       MAX_DIO_SIZE >> PAGE_SHIFT);
 
 	/* Check that all user buffers are aligned as well */
 	if (iov_iter_alignment(iter) & ~CFS_PAGE_MASK)
@@ -432,8 +432,8 @@ static ssize_t ll_direct_IO_26(struct kiocb *iocb, struct iov_iter *iter,
 			 * page worth of page pointers = 4MB on i386.
 			 */
 			if (result == -ENOMEM &&
-			    size > (PAGE_CACHE_SIZE / sizeof(*pages)) *
-				   PAGE_CACHE_SIZE) {
+			    size > (PAGE_SIZE / sizeof(*pages)) *
+			    PAGE_SIZE) {
 				size = ((((size / 2) - 1) |
 					 ~CFS_PAGE_MASK) + 1) &
 					CFS_PAGE_MASK;
@@ -474,10 +474,10 @@ static int ll_write_begin(struct file *file, struct address_space *mapping,
 			  loff_t pos, unsigned len, unsigned flags,
 			  struct page **pagep, void **fsdata)
 {
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
+	pgoff_t index = pos >> PAGE_SHIFT;
 	struct page *page;
 	int rc;
-	unsigned from = pos & (PAGE_CACHE_SIZE - 1);
+	unsigned from = pos & (PAGE_SIZE - 1);
 
 	page = grab_cache_page_write_begin(mapping, index, flags);
 	if (!page)
@@ -488,7 +488,7 @@ static int ll_write_begin(struct file *file, struct address_space *mapping,
 	rc = ll_prepare_write(file, page, from, from + len);
 	if (rc) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	return rc;
 }
@@ -497,12 +497,12 @@ static int ll_write_end(struct file *file, struct address_space *mapping,
 			loff_t pos, unsigned len, unsigned copied,
 			struct page *page, void *fsdata)
 {
-	unsigned from = pos & (PAGE_CACHE_SIZE - 1);
+	unsigned from = pos & (PAGE_SIZE - 1);
 	int rc;
 
 	rc = ll_commit_write(file, page, from, from + copied);
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	return rc ?: copied;
 }
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index fb0c26ee7ff3..0eb905e4fe40 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -511,10 +511,7 @@ static int vvp_io_read_start(const struct lu_env *env,
 	if (!vio->cui_ra_window_set) {
 		vio->cui_ra_window_set = 1;
 		bead->lrr_start = cl_index(obj, pos);
-		/*
-		 * XXX: explicit PAGE_CACHE_SIZE
-		 */
-		bead->lrr_count = cl_index(obj, tot + PAGE_CACHE_SIZE - 1);
+		bead->lrr_count = cl_index(obj, tot + PAGE_SIZE - 1);
 		ll_ra_read_in(file, bead);
 	}
 
@@ -959,7 +956,7 @@ static int vvp_io_prepare_write(const struct lu_env *env,
 		 * We're completely overwriting an existing page, so _don't_
 		 * set it up to date until commit_write
 		 */
-		if (from == 0 && to == PAGE_CACHE_SIZE) {
+		if (from == 0 && to == PAGE_SIZE) {
 			CL_PAGE_HEADER(D_PAGE, env, pg, "full page write\n");
 			POISON_PAGE(page, 0x11);
 		} else
@@ -1022,7 +1019,7 @@ static int vvp_io_commit_write(const struct lu_env *env,
 			set_page_dirty(vmpage);
 			vvp_write_pending(cl2ccc(obj), cp);
 		} else if (result == -EDQUOT) {
-			pgoff_t last_index = i_size_read(inode) >> PAGE_CACHE_SHIFT;
+			pgoff_t last_index = i_size_read(inode) >> PAGE_SHIFT;
 			bool need_clip = true;
 
 			/*
@@ -1040,7 +1037,7 @@ static int vvp_io_commit_write(const struct lu_env *env,
 			 * being.
 			 */
 			if (last_index > pg->cp_index) {
-				to = PAGE_CACHE_SIZE;
+				to = PAGE_SIZE;
 				need_clip = false;
 			} else if (last_index == pg->cp_index) {
 				int size_to = i_size_read(inode) & ~CFS_PAGE_MASK;
diff --git a/drivers/staging/lustre/lustre/llite/vvp_page.c b/drivers/staging/lustre/lustre/llite/vvp_page.c
index 850bae734075..33ca3eb34965 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_page.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_page.c
@@ -57,7 +57,7 @@ static void vvp_page_fini_common(struct ccc_page *cp)
 	struct page *vmpage = cp->cpg_page;
 
 	LASSERT(vmpage);
-	page_cache_release(vmpage);
+	put_page(vmpage);
 }
 
 static void vvp_page_fini(const struct lu_env *env,
@@ -164,12 +164,12 @@ static int vvp_page_unmap(const struct lu_env *env,
 	LASSERT(vmpage);
 	LASSERT(PageLocked(vmpage));
 
-	offset = vmpage->index << PAGE_CACHE_SHIFT;
+	offset = vmpage->index << PAGE_SHIFT;
 
 	/*
 	 * XXX is it safe to call this with the page lock held?
 	 */
-	ll_teardown_mmaps(vmpage->mapping, offset, offset + PAGE_CACHE_SIZE);
+	ll_teardown_mmaps(vmpage->mapping, offset, offset + PAGE_SIZE);
 	return 0;
 }
 
@@ -537,7 +537,7 @@ int vvp_page_init(const struct lu_env *env, struct cl_object *obj,
 	CLOBINVRNT(env, obj, ccc_object_invariant(obj));
 
 	cpg->cpg_page = vmpage;
-	page_cache_get(vmpage);
+	get_page(vmpage);
 
 	INIT_LIST_HEAD(&cpg->cpg_pending_linkage);
 	if (page->cp_type == CPT_CACHEABLE) {
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 0f776cf8a5aa..9abb7c2b9231 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -2017,7 +2017,7 @@ static int lmv_sync(struct obd_export *exp, const struct lu_fid *fid,
  * |s|e|f|p|ent| 0 | ... | 0 |
  * '-----------------   -----'
  *
- * However, on hosts where the native VM page size (PAGE_CACHE_SIZE) is
+ * However, on hosts where the native VM page size (PAGE_SIZE) is
  * larger than LU_PAGE_SIZE, a single host page may contain multiple
  * lu_dirpages. After reading the lu_dirpages from the MDS, the
  * ldp_hash_end of the first lu_dirpage refers to the one immediately
@@ -2048,7 +2048,7 @@ static int lmv_sync(struct obd_export *exp, const struct lu_fid *fid,
  * - Adjust the lde_reclen of the ending entry of each lu_dirpage to span
  *   to the first entry of the next lu_dirpage.
  */
-#if PAGE_CACHE_SIZE > LU_PAGE_SIZE
+#if PAGE_SIZE > LU_PAGE_SIZE
 static void lmv_adjust_dirpages(struct page **pages, int ncfspgs, int nlupgs)
 {
 	int i;
@@ -2101,7 +2101,7 @@ static void lmv_adjust_dirpages(struct page **pages, int ncfspgs, int nlupgs)
 }
 #else
 #define lmv_adjust_dirpages(pages, ncfspgs, nlupgs) do {} while (0)
-#endif	/* PAGE_CACHE_SIZE > LU_PAGE_SIZE */
+#endif	/* PAGE_SIZE > LU_PAGE_SIZE */
 
 static int lmv_readpage(struct obd_export *exp, struct md_op_data *op_data,
 			struct page **pages, struct ptlrpc_request **request)
@@ -2110,7 +2110,7 @@ static int lmv_readpage(struct obd_export *exp, struct md_op_data *op_data,
 	struct lmv_obd		*lmv = &obd->u.lmv;
 	__u64			offset = op_data->op_offset;
 	int			rc;
-	int			ncfspgs; /* pages read in PAGE_CACHE_SIZE */
+	int			ncfspgs; /* pages read in PAGE_SIZE */
 	int			nlupgs; /* pages read in LU_PAGE_SIZE */
 	struct lmv_tgt_desc	*tgt;
 
@@ -2129,8 +2129,8 @@ static int lmv_readpage(struct obd_export *exp, struct md_op_data *op_data,
 	if (rc != 0)
 		return rc;
 
-	ncfspgs = ((*request)->rq_bulk->bd_nob_transferred + PAGE_CACHE_SIZE - 1)
-		 >> PAGE_CACHE_SHIFT;
+	ncfspgs = ((*request)->rq_bulk->bd_nob_transferred + PAGE_SIZE - 1)
+		 >> PAGE_SHIFT;
 	nlupgs = (*request)->rq_bulk->bd_nob_transferred >> LU_PAGE_SHIFT;
 	LASSERT(!((*request)->rq_bulk->bd_nob_transferred & ~LU_PAGE_MASK));
 	LASSERT(ncfspgs > 0 && ncfspgs <= op_data->op_npages);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 55dd8ef9525b..b91d3ff18b02 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -1002,10 +1002,10 @@ restart_bulk:
 
 	/* NB req now owns desc and will free it when it gets freed */
 	for (i = 0; i < op_data->op_npages; i++)
-		ptlrpc_prep_bulk_page_pin(desc, pages[i], 0, PAGE_CACHE_SIZE);
+		ptlrpc_prep_bulk_page_pin(desc, pages[i], 0, PAGE_SIZE);
 
 	mdc_readdir_pack(req, op_data->op_offset,
-			 PAGE_CACHE_SIZE * op_data->op_npages,
+			 PAGE_SIZE * op_data->op_npages,
 			 &op_data->op_fid1);
 
 	ptlrpc_request_set_replen(req);
@@ -1037,7 +1037,7 @@ restart_bulk:
 	if (req->rq_bulk->bd_nob_transferred & ~LU_PAGE_MASK) {
 		CERROR("Unexpected # bytes transferred: %d (%ld expected)\n",
 		       req->rq_bulk->bd_nob_transferred,
-		       PAGE_CACHE_SIZE * op_data->op_npages);
+		       PAGE_SIZE * op_data->op_npages);
 		ptlrpc_req_finished(req);
 		return -EPROTO;
 	}
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 65caffe8c42e..830ca10507d4 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -1113,7 +1113,7 @@ static int mgc_import_event(struct obd_device *obd,
 }
 
 enum {
-	CONFIG_READ_NRPAGES_INIT = 1 << (20 - PAGE_CACHE_SHIFT),
+	CONFIG_READ_NRPAGES_INIT = 1 << (20 - PAGE_SHIFT),
 	CONFIG_READ_NRPAGES      = 4
 };
 
@@ -1137,19 +1137,19 @@ static int mgc_apply_recover_logs(struct obd_device *mgc,
 	LASSERT(cfg->cfg_instance);
 	LASSERT(cfg->cfg_sb == cfg->cfg_instance);
 
-	inst = kzalloc(PAGE_CACHE_SIZE, GFP_KERNEL);
+	inst = kzalloc(PAGE_SIZE, GFP_KERNEL);
 	if (!inst)
 		return -ENOMEM;
 
-	pos = snprintf(inst, PAGE_CACHE_SIZE, "%p", cfg->cfg_instance);
-	if (pos >= PAGE_CACHE_SIZE) {
+	pos = snprintf(inst, PAGE_SIZE, "%p", cfg->cfg_instance);
+	if (pos >= PAGE_SIZE) {
 		kfree(inst);
 		return -E2BIG;
 	}
 
 	++pos;
 	buf   = inst + pos;
-	bufsz = PAGE_CACHE_SIZE - pos;
+	bufsz = PAGE_SIZE - pos;
 
 	while (datalen > 0) {
 		int   entry_len = sizeof(*entry);
@@ -1181,7 +1181,7 @@ static int mgc_apply_recover_logs(struct obd_device *mgc,
 		/* Keep this swab for normal mixed endian handling. LU-1644 */
 		if (mne_swab)
 			lustre_swab_mgs_nidtbl_entry(entry);
-		if (entry->mne_length > PAGE_CACHE_SIZE) {
+		if (entry->mne_length > PAGE_SIZE) {
 			CERROR("MNE too large (%u)\n", entry->mne_length);
 			break;
 		}
@@ -1371,7 +1371,7 @@ again:
 	}
 	body->mcb_offset = cfg->cfg_last_idx + 1;
 	body->mcb_type   = cld->cld_type;
-	body->mcb_bits   = PAGE_CACHE_SHIFT;
+	body->mcb_bits   = PAGE_SHIFT;
 	body->mcb_units  = nrpages;
 
 	/* allocate bulk transfer descriptor */
@@ -1383,7 +1383,7 @@ again:
 	}
 
 	for (i = 0; i < nrpages; i++)
-		ptlrpc_prep_bulk_page_pin(desc, pages[i], 0, PAGE_CACHE_SIZE);
+		ptlrpc_prep_bulk_page_pin(desc, pages[i], 0, PAGE_SIZE);
 
 	ptlrpc_request_set_replen(req);
 	rc = ptlrpc_queue_wait(req);
@@ -1411,7 +1411,7 @@ again:
 		goto out;
 	}
 
-	if (ealen > nrpages << PAGE_CACHE_SHIFT) {
+	if (ealen > nrpages << PAGE_SHIFT) {
 		rc = -EINVAL;
 		goto out;
 	}
@@ -1439,7 +1439,7 @@ again:
 
 		ptr = kmap(pages[i]);
 		rc2 = mgc_apply_recover_logs(obd, cld, res->mcr_offset, ptr,
-					     min_t(int, ealen, PAGE_CACHE_SIZE),
+					     min_t(int, ealen, PAGE_SIZE),
 					     mne_swab);
 		kunmap(pages[i]);
 		if (rc2 < 0) {
@@ -1448,7 +1448,7 @@ again:
 			break;
 		}
 
-		ealen -= PAGE_CACHE_SIZE;
+		ealen -= PAGE_SIZE;
 	}
 
 out:
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index 231a2f26c693..394580016638 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -1477,7 +1477,7 @@ loff_t cl_offset(const struct cl_object *obj, pgoff_t idx)
 	/*
 	 * XXX for now.
 	 */
-	return (loff_t)idx << PAGE_CACHE_SHIFT;
+	return (loff_t)idx << PAGE_SHIFT;
 }
 EXPORT_SYMBOL(cl_offset);
 
@@ -1489,13 +1489,13 @@ pgoff_t cl_index(const struct cl_object *obj, loff_t offset)
 	/*
 	 * XXX for now.
 	 */
-	return offset >> PAGE_CACHE_SHIFT;
+	return offset >> PAGE_SHIFT;
 }
 EXPORT_SYMBOL(cl_index);
 
 int cl_page_size(const struct cl_object *obj)
 {
-	return 1 << PAGE_CACHE_SHIFT;
+	return 1 << PAGE_SHIFT;
 }
 EXPORT_SYMBOL(cl_page_size);
 
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 1a938e1376f9..c2cf015962dd 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -461,9 +461,9 @@ static int obd_init_checks(void)
 		CWARN("LPD64 wrong length! strlen(%s)=%d != 2\n", buf, len);
 		ret = -EINVAL;
 	}
-	if ((u64val & ~CFS_PAGE_MASK) >= PAGE_CACHE_SIZE) {
+	if ((u64val & ~CFS_PAGE_MASK) >= PAGE_SIZE) {
 		CWARN("mask failed: u64val %llu >= %llu\n", u64val,
-		      (__u64)PAGE_CACHE_SIZE);
+		      (__u64)PAGE_SIZE);
 		ret = -EINVAL;
 	}
 
@@ -509,7 +509,7 @@ static int __init obdclass_init(void)
 	 * For clients with less memory, a larger fraction is needed
 	 * for other purposes (mostly for BGL).
 	 */
-	if (totalram_pages <= 512 << (20 - PAGE_CACHE_SHIFT))
+	if (totalram_pages <= 512 << (20 - PAGE_SHIFT))
 		obd_max_dirty_pages = totalram_pages / 4;
 	else
 		obd_max_dirty_pages = totalram_pages / 2;
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c
index 9496c09b2b69..b41b65e2f021 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c
@@ -47,7 +47,6 @@
 #include "../../include/lustre/lustre_idl.h"
 
 #include <linux/fs.h>
-#include <linux/pagemap.h> /* for PAGE_CACHE_SIZE */
 
 void obdo_refresh_inode(struct inode *dst, struct obdo *src, u32 valid)
 {
@@ -71,8 +70,8 @@ void obdo_refresh_inode(struct inode *dst, struct obdo *src, u32 valid)
 	if (valid & OBD_MD_FLBLKSZ && src->o_blksize > (1 << dst->i_blkbits))
 		dst->i_blkbits = ffs(src->o_blksize) - 1;
 
-	if (dst->i_blkbits < PAGE_CACHE_SHIFT)
-		dst->i_blkbits = PAGE_CACHE_SHIFT;
+	if (dst->i_blkbits < PAGE_SHIFT)
+		dst->i_blkbits = PAGE_SHIFT;
 
 	/* allocation of space */
 	if (valid & OBD_MD_FLBLOCKS && src->o_blocks > dst->i_blocks)
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
index fd333b9e968c..e6bf414a4444 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
@@ -100,7 +100,7 @@ static ssize_t max_dirty_mb_show(struct kobject *kobj, struct attribute *attr,
 				 char *buf)
 {
 	return sprintf(buf, "%ul\n",
-			obd_max_dirty_pages / (1 << (20 - PAGE_CACHE_SHIFT)));
+			obd_max_dirty_pages / (1 << (20 - PAGE_SHIFT)));
 }
 
 static ssize_t max_dirty_mb_store(struct kobject *kobj, struct attribute *attr,
@@ -113,14 +113,14 @@ static ssize_t max_dirty_mb_store(struct kobject *kobj, struct attribute *attr,
 	if (rc)
 		return rc;
 
-	val *= 1 << (20 - PAGE_CACHE_SHIFT); /* convert to pages */
+	val *= 1 << (20 - PAGE_SHIFT); /* convert to pages */
 
 	if (val > ((totalram_pages / 10) * 9)) {
 		/* Somebody wants to assign too much memory to dirty pages */
 		return -EINVAL;
 	}
 
-	if (val < 4 << (20 - PAGE_CACHE_SHIFT)) {
+	if (val < 4 << (20 - PAGE_SHIFT)) {
 		/* Less than 4 Mb for dirty cache is also bad */
 		return -EINVAL;
 	}
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 65a4746c89ca..978568ada8e9 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -840,8 +840,8 @@ static int lu_htable_order(void)
 
 #if BITS_PER_LONG == 32
 	/* limit hashtable size for lowmem systems to low RAM */
-	if (cache_size > 1 << (30 - PAGE_CACHE_SHIFT))
-		cache_size = 1 << (30 - PAGE_CACHE_SHIFT) * 3 / 4;
+	if (cache_size > 1 << (30 - PAGE_SHIFT))
+		cache_size = 1 << (30 - PAGE_SHIFT) * 3 / 4;
 #endif
 
 	/* clear off unreasonable cache setting. */
@@ -853,7 +853,7 @@ static int lu_htable_order(void)
 		lu_cache_percent = LU_CACHE_PERCENT_DEFAULT;
 	}
 	cache_size = cache_size / 100 * lu_cache_percent *
-		(PAGE_CACHE_SIZE / 1024);
+		(PAGE_SIZE / 1024);
 
 	for (bits = 1; (1 << bits) < cache_size; ++bits) {
 		;
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 64ffe243f870..1e83669c204d 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -278,7 +278,7 @@ static void echo_page_fini(const struct lu_env *env,
 	struct page *vmpage      = ep->ep_vmpage;
 
 	atomic_dec(&eco->eo_npages);
-	page_cache_release(vmpage);
+	put_page(vmpage);
 }
 
 static int echo_page_prep(const struct lu_env *env,
@@ -373,7 +373,7 @@ static int echo_page_init(const struct lu_env *env, struct cl_object *obj,
 	struct echo_object *eco = cl2echo_obj(obj);
 
 	ep->ep_vmpage = vmpage;
-	page_cache_get(vmpage);
+	get_page(vmpage);
 	mutex_init(&ep->ep_lock);
 	cl_page_slice_add(page, &ep->ep_cl, obj, &echo_page_ops);
 	atomic_inc(&eco->eo_npages);
@@ -1138,7 +1138,7 @@ static int cl_echo_object_brw(struct echo_object *eco, int rw, u64 offset,
 	LASSERT(rc == 0);
 
 	rc = cl_echo_enqueue0(env, eco, offset,
-			      offset + npages * PAGE_CACHE_SIZE - 1,
+			      offset + npages * PAGE_SIZE - 1,
 			      rw == READ ? LCK_PR : LCK_PW, &lh.cookie,
 			      CEF_NEVER);
 	if (rc < 0)
@@ -1311,11 +1311,11 @@ echo_client_page_debug_setup(struct page *page, int rw, u64 id,
 	int      delta;
 
 	/* no partial pages on the client */
-	LASSERT(count == PAGE_CACHE_SIZE);
+	LASSERT(count == PAGE_SIZE);
 
 	addr = kmap(page);
 
-	for (delta = 0; delta < PAGE_CACHE_SIZE; delta += OBD_ECHO_BLOCK_SIZE) {
+	for (delta = 0; delta < PAGE_SIZE; delta += OBD_ECHO_BLOCK_SIZE) {
 		if (rw == OBD_BRW_WRITE) {
 			stripe_off = offset + delta;
 			stripe_id = id;
@@ -1341,11 +1341,11 @@ static int echo_client_page_debug_check(struct page *page, u64 id,
 	int     rc2;
 
 	/* no partial pages on the client */
-	LASSERT(count == PAGE_CACHE_SIZE);
+	LASSERT(count == PAGE_SIZE);
 
 	addr = kmap(page);
 
-	for (rc = delta = 0; delta < PAGE_CACHE_SIZE; delta += OBD_ECHO_BLOCK_SIZE) {
+	for (rc = delta = 0; delta < PAGE_SIZE; delta += OBD_ECHO_BLOCK_SIZE) {
 		stripe_off = offset + delta;
 		stripe_id = id;
 
@@ -1391,7 +1391,7 @@ static int echo_client_kbrw(struct echo_device *ed, int rw, struct obdo *oa,
 		return -EINVAL;
 
 	/* XXX think again with misaligned I/O */
-	npages = count >> PAGE_CACHE_SHIFT;
+	npages = count >> PAGE_SHIFT;
 
 	if (rw == OBD_BRW_WRITE)
 		brw_flags = OBD_BRW_ASYNC;
@@ -1408,7 +1408,7 @@ static int echo_client_kbrw(struct echo_device *ed, int rw, struct obdo *oa,
 
 	for (i = 0, pgp = pga, off = offset;
 	     i < npages;
-	     i++, pgp++, off += PAGE_CACHE_SIZE) {
+	     i++, pgp++, off += PAGE_SIZE) {
 
 		LASSERT(!pgp->pg);      /* for cleanup */
 
@@ -1418,7 +1418,7 @@ static int echo_client_kbrw(struct echo_device *ed, int rw, struct obdo *oa,
 			goto out;
 
 		pages[i] = pgp->pg;
-		pgp->count = PAGE_CACHE_SIZE;
+		pgp->count = PAGE_SIZE;
 		pgp->off = off;
 		pgp->flag = brw_flags;
 
@@ -1473,8 +1473,8 @@ static int echo_client_prep_commit(const struct lu_env *env,
 	if (count <= 0 || (count & (~CFS_PAGE_MASK)) != 0)
 		return -EINVAL;
 
-	npages = batch >> PAGE_CACHE_SHIFT;
-	tot_pages = count >> PAGE_CACHE_SHIFT;
+	npages = batch >> PAGE_SHIFT;
+	tot_pages = count >> PAGE_SHIFT;
 
 	lnb = kcalloc(npages, sizeof(struct niobuf_local), GFP_NOFS);
 	rnb = kcalloc(npages, sizeof(struct niobuf_remote), GFP_NOFS);
@@ -1497,9 +1497,9 @@ static int echo_client_prep_commit(const struct lu_env *env,
 		if (tot_pages < npages)
 			npages = tot_pages;
 
-		for (i = 0; i < npages; i++, off += PAGE_CACHE_SIZE) {
+		for (i = 0; i < npages; i++, off += PAGE_SIZE) {
 			rnb[i].offset = off;
-			rnb[i].len = PAGE_CACHE_SIZE;
+			rnb[i].len = PAGE_SIZE;
 			rnb[i].flags = brw_flags;
 		}
 
@@ -1878,7 +1878,7 @@ static int __init obdecho_init(void)
 {
 	LCONSOLE_INFO("Echo OBD driver; http://www.lustre.org/\n");
 
-	LASSERT(PAGE_CACHE_SIZE % OBD_ECHO_BLOCK_SIZE == 0);
+	LASSERT(PAGE_SIZE % OBD_ECHO_BLOCK_SIZE == 0);
 
 	return echo_client_init();
 }
diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index 57c43c506ef2..a3358c39b2f1 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -162,15 +162,15 @@ static ssize_t max_dirty_mb_store(struct kobject *kobj,
 	if (rc)
 		return rc;
 
-	pages_number *= 1 << (20 - PAGE_CACHE_SHIFT); /* MB -> pages */
+	pages_number *= 1 << (20 - PAGE_SHIFT); /* MB -> pages */
 
 	if (pages_number <= 0 ||
-	    pages_number > OSC_MAX_DIRTY_MB_MAX << (20 - PAGE_CACHE_SHIFT) ||
+	    pages_number > OSC_MAX_DIRTY_MB_MAX << (20 - PAGE_SHIFT) ||
 	    pages_number > totalram_pages / 4) /* 1/4 of RAM */
 		return -ERANGE;
 
 	client_obd_list_lock(&cli->cl_loi_list_lock);
-	cli->cl_dirty_max = (u32)(pages_number << PAGE_CACHE_SHIFT);
+	cli->cl_dirty_max = (u32)(pages_number << PAGE_SHIFT);
 	osc_wake_cache_waiters(cli);
 	client_obd_list_unlock(&cli->cl_loi_list_lock);
 
@@ -182,7 +182,7 @@ static int osc_cached_mb_seq_show(struct seq_file *m, void *v)
 {
 	struct obd_device *dev = m->private;
 	struct client_obd *cli = &dev->u.cli;
-	int shift = 20 - PAGE_CACHE_SHIFT;
+	int shift = 20 - PAGE_SHIFT;
 
 	seq_printf(m,
 		   "used_mb: %d\n"
@@ -211,7 +211,7 @@ static ssize_t osc_cached_mb_seq_write(struct file *file,
 		return -EFAULT;
 	kernbuf[count] = 0;
 
-	mult = 1 << (20 - PAGE_CACHE_SHIFT);
+	mult = 1 << (20 - PAGE_SHIFT);
 	buffer += lprocfs_find_named_value(kernbuf, "used_mb:", &count) -
 		  kernbuf;
 	rc = lprocfs_write_frac_helper(buffer, count, &pages_number, mult);
@@ -569,12 +569,12 @@ static ssize_t max_pages_per_rpc_store(struct kobject *kobj,
 
 	/* if the max_pages is specified in bytes, convert to pages */
 	if (val >= ONE_MB_BRW_SIZE)
-		val >>= PAGE_CACHE_SHIFT;
+		val >>= PAGE_SHIFT;
 
-	chunk_mask = ~((1 << (cli->cl_chunkbits - PAGE_CACHE_SHIFT)) - 1);
+	chunk_mask = ~((1 << (cli->cl_chunkbits - PAGE_SHIFT)) - 1);
 	/* max_pages_per_rpc must be chunk aligned */
 	val = (val + ~chunk_mask) & chunk_mask;
-	if (val == 0 || val > ocd->ocd_brw_size >> PAGE_CACHE_SHIFT) {
+	if (val == 0 || val > ocd->ocd_brw_size >> PAGE_SHIFT) {
 		return -ERANGE;
 	}
 	client_obd_list_lock(&cli->cl_loi_list_lock);
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 63363111380c..5f25bf83dcfc 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -544,7 +544,7 @@ static int osc_extent_merge(const struct lu_env *env, struct osc_extent *cur,
 		return -ERANGE;
 
 	LASSERT(cur->oe_osclock == victim->oe_osclock);
-	ppc_bits = osc_cli(obj)->cl_chunkbits - PAGE_CACHE_SHIFT;
+	ppc_bits = osc_cli(obj)->cl_chunkbits - PAGE_SHIFT;
 	chunk_start = cur->oe_start >> ppc_bits;
 	chunk_end = cur->oe_end >> ppc_bits;
 	if (chunk_start != (victim->oe_end >> ppc_bits) + 1 &&
@@ -647,8 +647,8 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
 	lock = cl_lock_at_pgoff(env, osc2cl(obj), index, NULL, 1, 0);
 	LASSERT(lock->cll_descr.cld_mode >= CLM_WRITE);
 
-	LASSERT(cli->cl_chunkbits >= PAGE_CACHE_SHIFT);
-	ppc_bits = cli->cl_chunkbits - PAGE_CACHE_SHIFT;
+	LASSERT(cli->cl_chunkbits >= PAGE_SHIFT);
+	ppc_bits = cli->cl_chunkbits - PAGE_SHIFT;
 	chunk_mask = ~((1 << ppc_bits) - 1);
 	chunksize = 1 << cli->cl_chunkbits;
 	chunk = index >> ppc_bits;
@@ -871,8 +871,8 @@ int osc_extent_finish(const struct lu_env *env, struct osc_extent *ext,
 
 	if (!sent) {
 		lost_grant = ext->oe_grants;
-	} else if (blocksize < PAGE_CACHE_SIZE &&
-		   last_count != PAGE_CACHE_SIZE) {
+	} else if (blocksize < PAGE_SIZE &&
+		   last_count != PAGE_SIZE) {
 		/* For short writes we shouldn't count parts of pages that
 		 * span a whole chunk on the OST side, or our accounting goes
 		 * wrong.  Should match the code in filter_grant_check.
@@ -884,7 +884,7 @@ int osc_extent_finish(const struct lu_env *env, struct osc_extent *ext,
 		if (end)
 			count += blocksize - end;
 
-		lost_grant = PAGE_CACHE_SIZE - count;
+		lost_grant = PAGE_SIZE - count;
 	}
 	if (ext->oe_grants > 0)
 		osc_free_grant(cli, nr_pages, lost_grant);
@@ -967,7 +967,7 @@ static int osc_extent_truncate(struct osc_extent *ext, pgoff_t trunc_index,
 	struct osc_async_page *oap;
 	struct osc_async_page *tmp;
 	int pages_in_chunk = 0;
-	int ppc_bits = cli->cl_chunkbits - PAGE_CACHE_SHIFT;
+	int ppc_bits = cli->cl_chunkbits - PAGE_SHIFT;
 	__u64 trunc_chunk = trunc_index >> ppc_bits;
 	int grants = 0;
 	int nr_pages = 0;
@@ -1125,7 +1125,7 @@ static int osc_extent_make_ready(const struct lu_env *env,
 	if (!(last->oap_async_flags & ASYNC_COUNT_STABLE)) {
 		last->oap_count = osc_refresh_count(env, last, OBD_BRW_WRITE);
 		LASSERT(last->oap_count > 0);
-		LASSERT(last->oap_page_off + last->oap_count <= PAGE_CACHE_SIZE);
+		LASSERT(last->oap_page_off + last->oap_count <= PAGE_SIZE);
 		last->oap_async_flags |= ASYNC_COUNT_STABLE;
 	}
 
@@ -1134,7 +1134,7 @@ static int osc_extent_make_ready(const struct lu_env *env,
 	 */
 	list_for_each_entry(oap, &ext->oe_pages, oap_pending_item) {
 		if (!(oap->oap_async_flags & ASYNC_COUNT_STABLE)) {
-			oap->oap_count = PAGE_CACHE_SIZE - oap->oap_page_off;
+			oap->oap_count = PAGE_SIZE - oap->oap_page_off;
 			oap->oap_async_flags |= ASYNC_COUNT_STABLE;
 		}
 	}
@@ -1158,7 +1158,7 @@ static int osc_extent_expand(struct osc_extent *ext, pgoff_t index, int *grants)
 	struct osc_object *obj = ext->oe_obj;
 	struct client_obd *cli = osc_cli(obj);
 	struct osc_extent *next;
-	int ppc_bits = cli->cl_chunkbits - PAGE_CACHE_SHIFT;
+	int ppc_bits = cli->cl_chunkbits - PAGE_SHIFT;
 	pgoff_t chunk = index >> ppc_bits;
 	pgoff_t end_chunk;
 	pgoff_t end_index;
@@ -1293,9 +1293,9 @@ static int osc_refresh_count(const struct lu_env *env,
 		return 0;
 	else if (cl_offset(obj, page->cp_index + 1) > kms)
 		/* catch sub-page write at end of file */
-		return kms % PAGE_CACHE_SIZE;
+		return kms % PAGE_SIZE;
 	else
-		return PAGE_CACHE_SIZE;
+		return PAGE_SIZE;
 }
 
 static int osc_completion(const struct lu_env *env, struct osc_async_page *oap,
@@ -1376,10 +1376,10 @@ static void osc_consume_write_grant(struct client_obd *cli,
 	assert_spin_locked(&cli->cl_loi_list_lock.lock);
 	LASSERT(!(pga->flag & OBD_BRW_FROM_GRANT));
 	atomic_inc(&obd_dirty_pages);
-	cli->cl_dirty += PAGE_CACHE_SIZE;
+	cli->cl_dirty += PAGE_SIZE;
 	pga->flag |= OBD_BRW_FROM_GRANT;
 	CDEBUG(D_CACHE, "using %lu grant credits for brw %p page %p\n",
-	       PAGE_CACHE_SIZE, pga, pga->pg);
+	       PAGE_SIZE, pga, pga->pg);
 	osc_update_next_shrink(cli);
 }
 
@@ -1396,11 +1396,11 @@ static void osc_release_write_grant(struct client_obd *cli,
 
 	pga->flag &= ~OBD_BRW_FROM_GRANT;
 	atomic_dec(&obd_dirty_pages);
-	cli->cl_dirty -= PAGE_CACHE_SIZE;
+	cli->cl_dirty -= PAGE_SIZE;
 	if (pga->flag & OBD_BRW_NOCACHE) {
 		pga->flag &= ~OBD_BRW_NOCACHE;
 		atomic_dec(&obd_dirty_transit_pages);
-		cli->cl_dirty_transit -= PAGE_CACHE_SIZE;
+		cli->cl_dirty_transit -= PAGE_SIZE;
 	}
 }
 
@@ -1456,7 +1456,7 @@ static void osc_unreserve_grant(struct client_obd *cli,
  * used, we should return these grants to OST. There're two cases where grants
  * can be lost:
  * 1. truncate;
- * 2. blocksize at OST is less than PAGE_CACHE_SIZE and a partial page was
+ * 2. blocksize at OST is less than PAGE_SIZE and a partial page was
  *    written. In this case OST may use less chunks to serve this partial
  *    write. OSTs don't actually know the page size on the client side. so
  *    clients have to calculate lost grant by the blocksize on the OST.
@@ -1469,7 +1469,7 @@ static void osc_free_grant(struct client_obd *cli, unsigned int nr_pages,
 
 	client_obd_list_lock(&cli->cl_loi_list_lock);
 	atomic_sub(nr_pages, &obd_dirty_pages);
-	cli->cl_dirty -= nr_pages << PAGE_CACHE_SHIFT;
+	cli->cl_dirty -= nr_pages << PAGE_SHIFT;
 	cli->cl_lost_grant += lost_grant;
 	if (cli->cl_avail_grant < grant && cli->cl_lost_grant >= grant) {
 		/* borrow some grant from truncate to avoid the case that
@@ -1512,11 +1512,11 @@ static int osc_enter_cache_try(struct client_obd *cli,
 	if (rc < 0)
 		return 0;
 
-	if (cli->cl_dirty + PAGE_CACHE_SIZE <= cli->cl_dirty_max &&
+	if (cli->cl_dirty + PAGE_SIZE <= cli->cl_dirty_max &&
 	    atomic_read(&obd_dirty_pages) + 1 <= obd_max_dirty_pages) {
 		osc_consume_write_grant(cli, &oap->oap_brw_page);
 		if (transient) {
-			cli->cl_dirty_transit += PAGE_CACHE_SIZE;
+			cli->cl_dirty_transit += PAGE_SIZE;
 			atomic_inc(&obd_dirty_transit_pages);
 			oap->oap_brw_flags |= OBD_BRW_NOCACHE;
 		}
@@ -1562,7 +1562,7 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
 	 * of queued writes and create a discontiguous rpc stream
 	 */
 	if (OBD_FAIL_CHECK(OBD_FAIL_OSC_NO_GRANT) ||
-	    cli->cl_dirty_max < PAGE_CACHE_SIZE     ||
+	    cli->cl_dirty_max < PAGE_SIZE     ||
 	    cli->cl_ar.ar_force_sync || loi->loi_ar.ar_force_sync) {
 		rc = -EDQUOT;
 		goto out;
@@ -1632,7 +1632,7 @@ void osc_wake_cache_waiters(struct client_obd *cli)
 
 		ocw->ocw_rc = -EDQUOT;
 		/* we can't dirty more */
-		if ((cli->cl_dirty + PAGE_CACHE_SIZE > cli->cl_dirty_max) ||
+		if ((cli->cl_dirty + PAGE_SIZE > cli->cl_dirty_max) ||
 		    (atomic_read(&obd_dirty_pages) + 1 >
 		     obd_max_dirty_pages)) {
 			CDEBUG(D_CACHE, "no dirty room: dirty: %ld osc max %ld, sys max %d\n",
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index d720b1a1c18c..ce9ddd515f64 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -410,7 +410,7 @@ int osc_page_init(const struct lu_env *env, struct cl_object *obj,
 	int result;
 
 	opg->ops_from = 0;
-	opg->ops_to = PAGE_CACHE_SIZE;
+	opg->ops_to = PAGE_SIZE;
 
 	result = osc_prep_async_page(osc, opg, vmpage,
 				     cl_offset(obj, page->cp_index));
@@ -487,9 +487,9 @@ static atomic_t osc_lru_waiters = ATOMIC_INIT(0);
 /* LRU pages are freed in batch mode. OSC should at least free this
  * number of pages to avoid running out of LRU budget, and..
  */
-static const int lru_shrink_min = 2 << (20 - PAGE_CACHE_SHIFT);  /* 2M */
+static const int lru_shrink_min = 2 << (20 - PAGE_SHIFT);  /* 2M */
 /* free this number at most otherwise it will take too long time to finish. */
-static const int lru_shrink_max = 32 << (20 - PAGE_CACHE_SHIFT); /* 32M */
+static const int lru_shrink_max = 32 << (20 - PAGE_SHIFT); /* 32M */
 
 /* Check if we can free LRU slots from this OSC. If there exists LRU waiters,
  * we should free slots aggressively. In this way, slots are freed in a steady
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 74805f1ae888..30526ebcad04 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -826,7 +826,7 @@ static void osc_announce_cached(struct client_obd *cli, struct obdo *oa,
 		oa->o_undirty = 0;
 	} else {
 		long max_in_flight = (cli->cl_max_pages_per_rpc <<
-				      PAGE_CACHE_SHIFT)*
+				      PAGE_SHIFT)*
 				     (cli->cl_max_rpcs_in_flight + 1);
 		oa->o_undirty = max(cli->cl_dirty_max, max_in_flight);
 	}
@@ -909,11 +909,11 @@ static void osc_shrink_grant_local(struct client_obd *cli, struct obdo *oa)
 static int osc_shrink_grant(struct client_obd *cli)
 {
 	__u64 target_bytes = (cli->cl_max_rpcs_in_flight + 1) *
-			     (cli->cl_max_pages_per_rpc << PAGE_CACHE_SHIFT);
+			     (cli->cl_max_pages_per_rpc << PAGE_SHIFT);
 
 	client_obd_list_lock(&cli->cl_loi_list_lock);
 	if (cli->cl_avail_grant <= target_bytes)
-		target_bytes = cli->cl_max_pages_per_rpc << PAGE_CACHE_SHIFT;
+		target_bytes = cli->cl_max_pages_per_rpc << PAGE_SHIFT;
 	client_obd_list_unlock(&cli->cl_loi_list_lock);
 
 	return osc_shrink_grant_to_target(cli, target_bytes);
@@ -929,8 +929,8 @@ int osc_shrink_grant_to_target(struct client_obd *cli, __u64 target_bytes)
 	 * We don't want to shrink below a single RPC, as that will negatively
 	 * impact block allocation and long-term performance.
 	 */
-	if (target_bytes < cli->cl_max_pages_per_rpc << PAGE_CACHE_SHIFT)
-		target_bytes = cli->cl_max_pages_per_rpc << PAGE_CACHE_SHIFT;
+	if (target_bytes < cli->cl_max_pages_per_rpc << PAGE_SHIFT)
+		target_bytes = cli->cl_max_pages_per_rpc << PAGE_SHIFT;
 
 	if (target_bytes >= cli->cl_avail_grant) {
 		client_obd_list_unlock(&cli->cl_loi_list_lock);
@@ -978,7 +978,7 @@ static int osc_should_shrink_grant(struct client_obd *client)
 		 * cli_brw_size(obd->u.cli.cl_import->imp_obd->obd_self_export)
 		 * Keep comment here so that it can be found by searching.
 		 */
-		int brw_size = client->cl_max_pages_per_rpc << PAGE_CACHE_SHIFT;
+		int brw_size = client->cl_max_pages_per_rpc << PAGE_SHIFT;
 
 		if (client->cl_import->imp_state == LUSTRE_IMP_FULL &&
 		    client->cl_avail_grant > brw_size)
@@ -1052,7 +1052,7 @@ static void osc_init_grant(struct client_obd *cli, struct obd_connect_data *ocd)
 	}
 
 	/* determine the appropriate chunk size used by osc_extent. */
-	cli->cl_chunkbits = max_t(int, PAGE_CACHE_SHIFT, ocd->ocd_blocksize);
+	cli->cl_chunkbits = max_t(int, PAGE_SHIFT, ocd->ocd_blocksize);
 	client_obd_list_unlock(&cli->cl_loi_list_lock);
 
 	CDEBUG(D_CACHE, "%s, setting cl_avail_grant: %ld cl_lost_grant: %ld chunk bits: %d\n",
@@ -1317,9 +1317,9 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 		LASSERT(pg->count > 0);
 		/* make sure there is no gap in the middle of page array */
 		LASSERTF(page_count == 1 ||
-			 (ergo(i == 0, poff + pg->count == PAGE_CACHE_SIZE) &&
+			 (ergo(i == 0, poff + pg->count == PAGE_SIZE) &&
 			  ergo(i > 0 && i < page_count - 1,
-			       poff == 0 && pg->count == PAGE_CACHE_SIZE)   &&
+			       poff == 0 && pg->count == PAGE_SIZE)   &&
 			  ergo(i == page_count - 1, poff == 0)),
 			 "i: %d/%d pg: %p off: %llu, count: %u\n",
 			 i, page_count, pg, pg->off, pg->count);
@@ -1877,7 +1877,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 						oap->oap_count;
 			else
 				LASSERT(oap->oap_page_off + oap->oap_count ==
-					PAGE_CACHE_SIZE);
+					PAGE_SIZE);
 		}
 	}
 
@@ -1993,7 +1993,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 		tmp->oap_request = ptlrpc_request_addref(req);
 
 	client_obd_list_lock(&cli->cl_loi_list_lock);
-	starting_offset >>= PAGE_CACHE_SHIFT;
+	starting_offset >>= PAGE_SHIFT;
 	if (cmd == OBD_BRW_READ) {
 		cli->cl_r_in_flight++;
 		lprocfs_oh_tally_log2(&cli->cl_read_page_hist, page_count);
@@ -2790,12 +2790,12 @@ out:
 						CFS_PAGE_MASK;
 
 		if (OBD_OBJECT_EOF - fm_key->fiemap.fm_length <=
-		    fm_key->fiemap.fm_start + PAGE_CACHE_SIZE - 1)
+		    fm_key->fiemap.fm_start + PAGE_SIZE - 1)
 			policy.l_extent.end = OBD_OBJECT_EOF;
 		else
 			policy.l_extent.end = (fm_key->fiemap.fm_start +
 				fm_key->fiemap.fm_length +
-				PAGE_CACHE_SIZE - 1) & CFS_PAGE_MASK;
+				PAGE_SIZE - 1) & CFS_PAGE_MASK;
 
 		ostid_build_res_name(&fm_key->oa.o_oi, &res_id);
 		mode = ldlm_lock_match(exp->exp_obd->obd_namespace,
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 1b7673eec4d7..cf3ac8eee9ee 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -174,12 +174,12 @@ void __ptlrpc_prep_bulk_page(struct ptlrpc_bulk_desc *desc,
 	LASSERT(page);
 	LASSERT(pageoffset >= 0);
 	LASSERT(len > 0);
-	LASSERT(pageoffset + len <= PAGE_CACHE_SIZE);
+	LASSERT(pageoffset + len <= PAGE_SIZE);
 
 	desc->bd_nob += len;
 
 	if (pin)
-		page_cache_get(page);
+		get_page(page);
 
 	ptlrpc_add_bulk_page(desc, page, pageoffset, len);
 }
@@ -206,7 +206,7 @@ void __ptlrpc_free_bulk(struct ptlrpc_bulk_desc *desc, int unpin)
 
 	if (unpin) {
 		for (i = 0; i < desc->bd_iov_count; i++)
-			page_cache_release(desc->bd_iov[i].kiov_page);
+			put_page(desc->bd_iov[i].kiov_page);
 	}
 
 	kfree(desc);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index b4eddf291269..cd94fed0ffdf 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -1092,7 +1092,7 @@ finish:
 
 		if (ocd->ocd_connect_flags & OBD_CONNECT_BRW_SIZE)
 			cli->cl_max_pages_per_rpc =
-				min(ocd->ocd_brw_size >> PAGE_CACHE_SHIFT,
+				min(ocd->ocd_brw_size >> PAGE_SHIFT,
 				    cli->cl_max_pages_per_rpc);
 		else if (imp->imp_connect_op == MDS_CONNECT ||
 			 imp->imp_connect_op == MGS_CONNECT)
diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index cee04efb6fb5..c95a91ce26c9 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -308,7 +308,7 @@ ptlrpc_lprocfs_req_history_max_seq_write(struct file *file,
 	 * hose a kernel by allowing the request history to grow too
 	 * far.
 	 */
-	bufpages = (svc->srv_buf_size + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	bufpages = (svc->srv_buf_size + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	if (val > totalram_pages / (2 * bufpages))
 		return -ERANGE;
 
@@ -1226,7 +1226,7 @@ int lprocfs_wr_import(struct file *file, const char __user *buffer,
 	const char prefix[] = "connection=";
 	const int prefix_len = sizeof(prefix) - 1;
 
-	if (count > PAGE_CACHE_SIZE - 1 || count <= prefix_len)
+	if (count > PAGE_SIZE - 1 || count <= prefix_len)
 		return -EINVAL;
 
 	kbuf = kzalloc(count + 1, GFP_NOFS);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/recover.c b/drivers/staging/lustre/lustre/ptlrpc/recover.c
index 5f27d9c2e4ef..30d9a164e52d 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/recover.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/recover.c
@@ -195,7 +195,7 @@ int ptlrpc_resend(struct obd_import *imp)
 	}
 
 	list_for_each_entry_safe(req, next, &imp->imp_sending_list, rq_list) {
-		LASSERTF((long)req > PAGE_CACHE_SIZE && req != LP_POISON,
+		LASSERTF((long)req > PAGE_SIZE && req != LP_POISON,
 			 "req %p bad\n", req);
 		LASSERTF(req->rq_type != LI_POISON, "req %p freed\n", req);
 		if (!ptlrpc_no_resend(req))
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
index 72d5b9bf5b29..d3872b8c9a6e 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
@@ -58,7 +58,7 @@
  * bulk encryption page pools	   *
  ****************************************/
 
-#define POINTERS_PER_PAGE	(PAGE_CACHE_SIZE / sizeof(void *))
+#define POINTERS_PER_PAGE	(PAGE_SIZE / sizeof(void *))
 #define PAGES_PER_POOL		(POINTERS_PER_PAGE)
 
 #define IDLE_IDX_MAX	 (100)
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
