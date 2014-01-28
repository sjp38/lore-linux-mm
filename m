Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 0E4DC6B0031
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 18:17:57 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id w10so958074pde.20
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 15:17:57 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id tq3si173908pab.299.2014.01.28.15.17.51
        for <linux-mm@kvack.org>;
        Tue, 28 Jan 2014 15:17:52 -0800 (PST)
Subject: [PATCH] mm: slub: fix page->_count corruption (again)
From: Dave Hansen <dave@sr71.net>
Date: Tue, 28 Jan 2014 15:17:22 -0800
Message-Id: <20140128231722.E7387E6B@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Dave Hansen <dave@sr71.net>, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, akpm@linux-foundation.org, pshelar@nicira.com


From: Dave Hansen <dave.hansen@linux.intel.com>

Commit abca7c496 notes that we can not _set_ a page->counters
directly, except when using a real double-cmpxchg.  Doing so can
lose updates to ->_count.

That an absolute rule:

        You may not *set* page->counters except via a cmpxchg.

Commit abca7c496 fixed this for the folks who have the slub
cmpxchg_double code turned off at compile time, but it left the
bad alone.  It can still be reached, and the same bug triggered
in two cases:
1. Turning on slub debugging at runtime, which is available on
   the distro kernels that I looked at.
2. On 64-bit CPUs with no CMPXCHG16B (some early AMD x86-64
   cpus, evidently)

There are at least 3 ways we could fix this:

1. Take all of the exising calls to cmpxchg_double_slab() and
   __cmpxchg_double_slab() and convert them to take an old, new
   and target 'struct page'.
2. Do (1), but with the newly-introduced 'slub_data'.
3. Do some magic inside the two cmpxchg...slab() functions to
   pull the counters out of new_counters and only set those
   fields in page->{inuse,frozen,objects}.

I've done (2) as well, but it's a bunch more code.  This patch
is an attempt at (3).  This was the most straightforward and
foolproof way that I could think to do this.

This would also technically allow us to get rid of the ugly

#if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
       defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)

in 'struct page', but leaving it alone has the added benefit that
'counters' stays 'unsigned' instead of 'unsigned long', so all
the copies that the slub code does stay a bit smaller.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Matt Mackall <mpm@selenic.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Pravin B Shelar <pshelar@nicira.com>

---

 b/mm/slub.c |   19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff -puN mm/slub.c~slub-never-set-counters-except-via-cmpxchg mm/slub.c
--- a/mm/slub.c~slub-never-set-counters-except-via-cmpxchg	2014-01-28 14:48:26.420339269 -0800
+++ b/mm/slub.c	2014-01-28 15:09:37.410864843 -0800
@@ -355,6 +355,21 @@ static __always_inline void slab_unlock(
 	__bit_spin_unlock(PG_locked, &page->flags);
 }
 
+static inline void set_page_slub_counters(struct page *page, unsigned long counters_new)
+{
+	struct page tmp;
+	tmp.counters = counters_new;
+	/*
+	 * page->counters can cover frozen/inuse/objects as well
+	 * as page->_count.  If we assign to ->counters directly
+	 * we run the risk of losing updates to page->_count, so
+	 * be careful and only assign to the fields we need.
+	 */
+	page->frozen  = tmp.frozen;
+	page->inuse   = tmp.inuse;
+	page->objects = tmp.objects;
+}
+
 /* Interrupts must be disabled (for the fallback code to work right) */
 static inline bool __cmpxchg_double_slab(struct kmem_cache *s, struct page *page,
 		void *freelist_old, unsigned long counters_old,
@@ -376,7 +391,7 @@ static inline bool __cmpxchg_double_slab
 		if (page->freelist == freelist_old &&
 					page->counters == counters_old) {
 			page->freelist = freelist_new;
-			page->counters = counters_new;
+			set_page_slub_counters(page, counters_new);
 			slab_unlock(page);
 			return 1;
 		}
@@ -415,7 +430,7 @@ static inline bool cmpxchg_double_slab(s
 		if (page->freelist == freelist_old &&
 					page->counters == counters_old) {
 			page->freelist = freelist_new;
-			page->counters = counters_new;
+			set_page_slub_counters(page, counters_new);
 			slab_unlock(page);
 			local_irq_restore(flags);
 			return 1;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
