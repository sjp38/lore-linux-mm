From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070410032912.18967.67076.sendpatchset@schroedinger.engr.sgi.com>
Subject: [SLUB 1/5] Minor fixes
Date: Mon,  9 Apr 2007 20:29:12 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

1. Correct spelling

2. Partial pages should go to the front of the partial list since they are
   cache hot.

3. Remove stray printk.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc6-mm1/mm/slub.c
===================================================================
--- linux-2.6.21-rc6-mm1.orig/mm/slub.c	2007-04-09 15:29:14.000000000 -0700
+++ linux-2.6.21-rc6-mm1/mm/slub.c	2007-04-09 18:19:56.000000000 -0700
@@ -277,7 +277,7 @@ static void print_track(const char *s, s
 	} else
 #endif
 		printk(KERN_ERR "%s: 0x%p", s, t->addr);
-	printk(" jiffies since=%lu cpu=%u pid=%d\n", jiffies - t->when, t->cpu, t->pid);
+	printk(" jiffies_ago=%lu cpu=%u pid=%d\n", jiffies - t->when, t->cpu, t->pid);
 }
 
 static void print_trailer(struct kmem_cache *s, u8 *p)
@@ -579,7 +579,7 @@ static int alloc_object_checks(struct km
 		goto bad;
 
 	if (object && !on_freelist(s, page, object)) {
-		printk(KERN_ERR "SLAB: %s Object 0x%p@0x%p "
+		printk(KERN_ERR "SLUB: %s Object 0x%p@0x%p "
 			"already allocated.\n",
 			s->name, object, page);
 		goto dump;
@@ -862,7 +862,7 @@ static void add_partial(struct kmem_cach
 
 	spin_lock(&n->list_lock);
 	n->nr_partial++;
-	list_add_tail(&page->lru, &n->partial);
+	list_add(&page->lru, &n->partial);
 	spin_unlock(&n->list_lock);
 }
 
@@ -2507,7 +2507,6 @@ static ssize_t trace_store(struct kmem_c
 							size_t length)
 {
 	s->flags &= ~SLAB_TRACE;
-	printk("_trace_store = %s\n", buf);
 	if (buf[0] == '1')
 		s->flags |= SLAB_TRACE;
 	return length;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
