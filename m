Date: Wed, 6 Feb 2008 13:00:53 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB: statistics improvements
In-Reply-To: <20080206001948.6f749aa8.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0802061259490.26108@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0802042217460.6801@schroedinger.engr.sgi.com>
 <20080206001948.6f749aa8.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

- Fix indentation in unfreeze_slab

- FREE_SLAB/ALLOC_SLAB counters were slightly misplaced and counted
  even if the slab was kept because we were below the mininum of
  partial slabs.

- Export per cpu statistics to user space (follow numa convention
  but change the n character to c (no slabinfo support for display yet)

F.e.

christoph@stapp:/sys/kernel/slab/kmalloc-8$ cat alloc_fastpath
9968 c0=4854 c1=1050 c2=468 c3=190 c4=116 c5=1779 c6=185 c7=1326


---
 mm/slub.c |   39 +++++++++++++++++++++++++++++++--------
 1 file changed, 31 insertions(+), 8 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2008-02-06 12:47:41.246444483 -0800
+++ linux-2.6/mm/slub.c	2008-02-06 12:50:42.253891850 -0800
@@ -1377,7 +1377,7 @@ static void unfreeze_slab(struct kmem_ca
 		} else {
 			stat(c, DEACTIVATE_FULL);
 			if (SlabDebug(page) && (s->flags & SLAB_STORE_USER))
-			add_full(n, page);
+				add_full(n, page);
 		}
 		slab_unlock(page);
 	} else {
@@ -1395,6 +1395,7 @@ static void unfreeze_slab(struct kmem_ca
 			slab_unlock(page);
 		} else {
 			slab_unlock(page);
+			stat(get_cpu_slab(s, raw_smp_processor_id()), FREE_SLAB);
 			discard_slab(s, page);
 		}
 	}
@@ -1567,9 +1568,9 @@ new_slab:
 
 	if (new) {
 		c = get_cpu_slab(s, smp_processor_id());
+		stat(c, ALLOC_SLAB);
 		if (c->page)
 			flush_slab(s, c);
-		stat(c, ALLOC_SLAB);
 		slab_lock(new);
 		SetSlabFrozen(new);
 		c->page = new;
@@ -4014,15 +4015,37 @@ SLAB_ATTR(remote_node_defrag_ratio);
 
 #ifdef CONFIG_SLUB_STATS
 
+static int show_stat(struct kmem_cache *s, char *buf, enum stat_item si)
+{
+	unsigned long sum  = 0;
+	int cpu;
+	int len;
+	int *data = kmalloc(nr_cpu_ids * sizeof(int), GFP_KERNEL);
+
+	if (!data)
+		return -ENOMEM;
+
+	for_each_online_cpu(cpu) {
+		int x = get_cpu_slab(s, cpu)->stat[si];
+
+		data[cpu] = x;
+		sum += x;
+	}
+
+	len = sprintf(buf, "%lu", sum);
+
+	for_each_online_cpu(cpu) {
+		if (data[cpu] && len < PAGE_SIZE - 20)
+			len += sprintf(buf + len, " c%d=%u", cpu, data[cpu]);
+	}
+	kfree(data);
+	return len + sprintf(buf + len, "\n");
+}
+
 #define STAT_ATTR(si, text) 					\
 static ssize_t text##_show(struct kmem_cache *s, char *buf)	\
 {								\
-	unsigned long sum  = 0;					\
-	int cpu;						\
-								\
-	for_each_online_cpu(cpu)				\
-		sum += get_cpu_slab(s, cpu)->stat[si];		\
-	return sprintf(buf, "%lu\n", sum);			\
+	return show_stat(s, buf, si);				\
 }								\
 SLAB_ATTR_RO(text);						\
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
