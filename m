Date: Tue, 10 Apr 2007 16:38:25 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [SLUB 3/5] Validation of slabs (metadata and guard zones)
In-Reply-To: <20070410133137.e366a16b.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0704101636230.2100@schroedinger.engr.sgi.com>
References: <20070410191910.8011.76133.sendpatchset@schroedinger.engr.sgi.com>
 <20070410191921.8011.16929.sendpatchset@schroedinger.engr.sgi.com>
 <20070410133137.e366a16b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Apr 2007, Andrew Morton wrote:

> There are a bunch of functions which need to be called with local irqs
> disabled for locking reasons.  Documenting this (perhaps with
> VM_BUG_ON(!irqs_disabled()?) would be good.

SLUB: Add checks for interrupts disabled

This only adds interrupt disabled checks to code paths taken if
debugging is on. I want to avoid constant checks in hot paths (like in 
SLAB). VM_BUG_ON may be enabled by distributors who want to play it safe.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc6/mm/slub.c
===================================================================
--- linux-2.6.21-rc6.orig/mm/slub.c	2007-04-10 16:18:13.000000000 -0700
+++ linux-2.6.21-rc6/mm/slub.c	2007-04-10 16:25:33.000000000 -0700
@@ -531,6 +531,8 @@ static int check_object(struct kmem_cach
 
 static int check_slab(struct kmem_cache *s, struct page *page)
 {
+	VM_BUG_ON(!irqs_disabled());
+
 	if (!PageSlab(page)) {
 		printk(KERN_ERR "SLUB: %s Not a valid slab page @0x%p "
 			"flags=%lx mapping=0x%p count=%d \n",
@@ -612,6 +614,8 @@ static void add_full(struct kmem_cache *
 {
 	struct kmem_cache_node *n;
 
+	VM_BUG_ON(!irqs_disabled());
+
 	if (!(s->flags & SLAB_STORE_USER))
 		return;
 
@@ -625,6 +629,8 @@ static void remove_full(struct kmem_cach
 {
 	struct kmem_cache_node *n;
 
+	VM_BUG_ON(!irqs_disabled());
+
 	if (!(s->flags & SLAB_STORE_USER))
 		return;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
