Date: Tue, 18 Sep 2007 21:33:31 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [RFC/Patch](memory hotplug) fix null pointer access of kmem_cache_node after memory hotplug
Message-Id: <20070918211932.0FFD.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Cristoph-san.

I found panic occuring after memory hot-add on 2.6.23-rc6-mm1 yet.

Its cause was null pointer access to kmem_cache_node of SLUB at
discard_slab().
In my understanding, it should be created for all slubs after
memory-less-node(or new node) gets new memory. But, current -mm doen't it.
This patch fix for it.

In this patch, it is created after that new_slab is allocated from
new onlined memory.
If kmem_cache_node is created at online_pages() of memory hot-add,
it should be done before build_zonelist to avoid race condition.
But, it means kmem_cache_node must be allocated on other old nodes
due not to complete initialization.
I think this "delay creation" fix is better way than it.

I know that failure case of kmem_cache_alloc_node() must be written
and the prototype of init_kmem_cache_node() here is not good.
Just I would like to confirm that I don't overlook something about SLUB.

Bye.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

---
 mm/slub.c |   15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

Index: current/mm/slub.c
===================================================================
--- current.orig/mm/slub.c	2007-09-18 19:46:33.000000000 +0900
+++ current/mm/slub.c	2007-09-18 19:46:59.000000000 +0900
@@ -1081,6 +1081,7 @@ static void setup_object(struct kmem_cac
 		s->ctor(s, object);
 }
 
+static void init_kmem_cache_node(struct kmem_cache_node *n);
 static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
 {
 	struct page *page;
@@ -1089,6 +1090,7 @@ static struct page *new_slab(struct kmem
 	void *end;
 	void *last;
 	void *p;
+	int page_nid;
 
 	BUG_ON(flags & GFP_SLAB_BUG_MASK);
 
@@ -1097,9 +1099,20 @@ static struct page *new_slab(struct kmem
 	if (!page)
 		goto out;
 
-	n = get_node(s, page_to_nid(page));
+	page_nid = page_to_nid(page);
+	n = get_node(s, page_nid);
 	if (n)
 		atomic_long_inc(&n->nr_slabs);
+	else if (node_state(page_nid, N_HIGH_MEMORY) && s != kmalloc_caches) {
+		/*
+		 * If new memory is onlined on new(or memory less) node,
+		 * this will happen. (Second comparison is to avoid eternal
+		 * recursion.)
+		 */
+		n = kmem_cache_alloc_node(kmalloc_caches, GFP_KERNEL, page_nid);
+		init_kmem_cache_node(n);
+		s->node[page_nid] = n;
+	}
 	page->slab = s;
 	page->flags |= 1 << PG_slab;
 	if (s->flags & (SLAB_DEBUG_FREE | SLAB_RED_ZONE | SLAB_POISON |

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
