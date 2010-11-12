Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6D2978D0001
	for <linux-mm@kvack.org>; Fri, 12 Nov 2010 06:28:33 -0500 (EST)
Subject: [PATCH/RFC] MM slub: add a sysfs entry to show the calculated
 number of fallback slabs
From: Richard Kennedy <richard@rsk.demon.co.uk>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 12 Nov 2010 11:28:29 +0000
Message-ID: <1289561309.1972.30.camel@castor.rsk>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Add a slub sysfs entry to show the calculated number of fallback slabs.

Using the information already available it is straightforward to
calculate the number of fallback & full size slabs. We can then track
which slabs are particularly effected by memory fragmentation and how
long they take to recover. 

There is no change to the mainline code, the calculation is only
performed on request, and the value is available without having to
enable CONFIG_SLUB_STATS.  

Note that this could give the wrong value if the user changes the slab
order via the sysfs interface.

Signed-off-by: Richard Kennedy <richard@rsk.demon.co.uk>
---


As we have the information needed to do this calculation is seem useful
to expose it and provide another way to understand what is happening
inside the memory manager.

On my desktop workloads (kernel compile etc) I'm seeing surprisingly
little slab fragmentation. Do you have any suggestions for test cases
that will fragment the memory?

I copied the code to count the total objects from the slabinfo s_show
function, but as I don't need the partial count I didn't extract it into
a helper function.

regards
Richard
 

diff --git a/mm/slub.c b/mm/slub.c
index 8fd5401..8c79eaa 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4043,6 +4043,46 @@ static ssize_t destroy_by_rcu_show(struct kmem_cache *s, char *buf)
 }
 SLAB_ATTR_RO(destroy_by_rcu);
 
+/* The number of fallback slabs can be calculated to give an
+ * indication of how fragmented this slab is.
+ * This is a snapshot of the current makeup of this cache.
+ *
+ *  Given
+ *
+ *  total_objects = (nr_fallback_slabs * objects_per_fallback_slab) +
+ *     ( nr_normal_slabs * objects_per_slab)
+ *  and
+ *  nr_slabs = nr_normal_slabs + nr_fallback_slabs
+ *
+ * then we can easily calculate nr_fallback_slabs.
+ *
+ * Note that this can give the wrong answer if the user has changed the
+ * order of this slab via sysfs.
+ */
+
+static ssize_t fallback_show(struct kmem_cache *s, char *buf)
+{
+	unsigned long nr_objects = 0;
+	unsigned long nr_slabs = 0;
+	unsigned long nr_fallback = 0;
+	unsigned long acc;
+	int node;
+
+	if (oo_order(s->oo) != oo_order(s->min)) {
+		for_each_online_node(node) {
+			struct kmem_cache_node *n = get_node(s, node);
+			nr_slabs += atomic_long_read(&n->nr_slabs);
+			nr_objects += atomic_long_read(&n->total_objects);
+		}
+		acc = nr_objects - nr_slabs * oo_objects(s->min);
+		acc /= (oo_objects(s->oo) - oo_objects(s->min));
+		nr_fallback = nr_slabs - acc;
+	}
+	return sprintf(buf, "%lu\n", nr_fallback);
+}
+SLAB_ATTR_RO(fallback);
+
+
 #ifdef CONFIG_SLUB_DEBUG
 static ssize_t slabs_show(struct kmem_cache *s, char *buf)
 {
@@ -4329,6 +4369,7 @@ static struct attribute *slab_attrs[] = {
 	&reclaim_account_attr.attr,
 	&destroy_by_rcu_attr.attr,
 	&shrink_attr.attr,
+	&fallback_attr.attr,
 #ifdef CONFIG_SLUB_DEBUG
 	&total_objects_attr.attr,
 	&slabs_attr.attr,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
