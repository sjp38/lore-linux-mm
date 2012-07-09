Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 2E4A16B006C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 17:00:42 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so23976331pbb.14
        for <linux-mm@kvack.org>; Mon, 09 Jul 2012 14:00:41 -0700 (PDT)
Date: Mon, 9 Jul 2012 14:00:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2] mm, slub: ensure irqs are enabled for kmemcheck
In-Reply-To: <1341841593.14828.9.camel@gandalf.stny.rr.com>
Message-ID: <alpine.DEB.2.00.1207091400090.23926@chino.kir.corp.google.com>
References: <20120708040009.GA8363@localhost> <CAAmzW4OD2_ODyeY7c1VMPajwzovOms5M8Vnw=XP=uGUyPogiJQ@mail.gmail.com> <alpine.DEB.2.00.1207081558540.18461@chino.kir.corp.google.com> <alpine.LFD.2.02.1207091209220.3050@tux.localdomain>
 <alpine.DEB.2.00.1207090333560.8224@chino.kir.corp.google.com> <1341841593.14828.9.camel@gandalf.stny.rr.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, JoonSoo Kim <js1304@gmail.com>, Fengguang Wu <fengguang.wu@intel.com>, Vegard Nossum <vegard.nossum@gmail.com>, Christoph Lameter <cl@linux.com>, Rus <rus@sfinxsoft.com>, Ben Hutchings <ben@decadent.org.uk>, stable@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

kmemcheck_alloc_shadow() requires irqs to be enabled, so wait to disable
them until after its called for __GFP_WAIT allocations.

This fixes a warning for such allocations:

	WARNING: at kernel/lockdep.c:2739 lockdep_trace_alloc+0x14e/0x1c0()

Acked-by: Fengguang Wu <fengguang.wu@intel.com>
Acked-by: Steven Rostedt <rostedt@goodmis.org>
Tested-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/slub.c |   13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1314,13 +1314,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 			stat(s, ORDER_FALLBACK);
 	}
 
-	if (flags & __GFP_WAIT)
-		local_irq_disable();
-
-	if (!page)
-		return NULL;
-
-	if (kmemcheck_enabled
+	if (kmemcheck_enabled && page
 		&& !(s->flags & (SLAB_NOTRACK | DEBUG_DEFAULT_FLAGS))) {
 		int pages = 1 << oo_order(oo);
 
@@ -1336,6 +1330,11 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 			kmemcheck_mark_unallocated_pages(page, pages);
 	}
 
+	if (flags & __GFP_WAIT)
+		local_irq_disable();
+	if (!page)
+		return NULL;
+
 	page->objects = oo_objects(oo);
 	mod_zone_page_state(page_zone(page),
 		(s->flags & SLAB_RECLAIM_ACCOUNT) ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
