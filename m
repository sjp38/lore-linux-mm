Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B3B356B01EF
	for <linux-mm@kvack.org>; Sun, 18 Apr 2010 11:14:18 -0400 (EDT)
Received: by gyg4 with SMTP id 4so2191931gyg.14
        for <linux-mm@kvack.org>; Sun, 18 Apr 2010 08:14:16 -0700 (PDT)
Subject: Re: vmalloc performance
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <1271427056.7196.163.camel@localhost.localdomain>
References: <1271089672.7196.63.camel@localhost.localdomain>
	 <1271249354.7196.66.camel@localhost.localdomain>
	 <m2g28c262361004140813j5d70a80fy1882d01436d136a6@mail.gmail.com>
	 <1271262948.2233.14.camel@barrios-desktop>
	 <1271320388.2537.30.camel@localhost>
	 <1271350270.2013.29.camel@barrios-desktop>
	 <1271427056.7196.163.camel@localhost.localdomain>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 19 Apr 2010 00:14:09 +0900
Message-ID: <1271603649.2100.122.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Steven Whitehouse <swhiteho@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, 2010-04-16 at 15:10 +0100, Steven Whitehouse wrote:
> Hi,
> 
> On Fri, 2010-04-16 at 01:51 +0900, Minchan Kim wrote:
> [snip]
> > Thanks for the explanation. It seems to be real issue. 
> > 
> > I tested to see effect with flush during rb tree search.
> > 
> > Before I applied your patch, the time is 50300661 us. 
> > After your patch, 11569357 us. 
> > After my debug patch, 6104875 us.
> > 
> > I tested it as changing threshold value.
> > 
> > threshold	time
> > 1000		13892809
> > 500		9062110
> > 200		6714172
> > 100		6104875
> > 50		6758316
> > 
> My results show:
> 
> threshold        time
> 100000           139309948
> 1000             13555878
> 500              10069801
> 200              7813667
> 100              18523172
> 50               18546256
> 
> > And perf shows smp_call_function is very low percentage.
> > 
> > In my cases, 100 is best. 
> > 
> Looks like 200 for me.
> 
> I think you meant to use the non _minmax version of proc_dointvec too?

Yes. My fault :)

> Although it doesn't make any difference for this basic test.
> 
> The original reporter also has 8 cpu cores I've discovered. In his case
> divided by 4 cpus where as mine are divided by 2 cpus, but I think that
> makes no real difference in this case.
> 
> I'll try and get some further test results ready shortly. Many thanks
> for all your efforts in tracking this down,
> 
> Steve.

I voted "free area cache".
I tested below patch in my machine. 

The result is following as. 

1) vanilla
elapsed time			# search of rbtree
vmalloc took 49121724 us		5535
vmalloc took 50675245 us		5535
vmalloc took 48987711 us		5535
vmalloc took 54232479 us		5535
vmalloc took 50258117 us		5535
vmalloc took 49424859 us		5535

3) Steven's patch

elapsed time 			# search of rbtree
vmalloc took 11363341 us		62
vmalloc took 12798868 us		62
vmalloc took 13247942 us		62
vmalloc took 11434647 us		62
vmalloc took 13221733 us		62
vmalloc took 12134019 us		62

2) my patch(vmap cache)
elapsed time 			# search of rbtree
vmalloc took 5159893 us			8
vmalloc took 5124434 us			8
vmalloc took 5123291 us			8
vmalloc took 5145396 us			12
vmalloc took 5163605 us			8
vmalloc took 5945663 us			8

My version is faster than 9 times of vanilla.
Steve, Could you measure this patch with your test?
(Sorry, maybe you have to apply the patch by hands.
That's because patch is based on mmotm-2010-04-05-16-09)

Nick, What do you think about "free area cache" approach?

In this version, I don't consider last hole and backward cache movement which is 
like mmap's cached_hole_size
That's because I want to flush vmap_areas freed intentionally if we meet vend.
It makes flush frequent than old but it's trade-off. In addition, vmalloc isn't 
critical compared to mmap about performance. So I think that's enough. 

If you don't opposed, I will repost formal patch without code related to debug.

---
 kernel/sysctl.c |    9 +++++++++
 mm/vmalloc.c    |   55 +++++++++++++++++++++++++++++++++++++++++--------------
 2 files changed, 50 insertions(+), 14 deletions(-)

diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 8686b0f..20d7bfd 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -933,7 +933,16 @@ static struct ctl_table kern_table[] = {
 	{ }
 };
 
+extern unsigned long max_lookup_count;
+
 static struct ctl_table vm_table[] = {
+        {
+               .procname       = "max_lookup_count",
+               .data           = &max_lookup_count,
+               .maxlen         = sizeof(max_lookup_count),
+               .mode           = 0644,
+               .proc_handler   = proc_dointvec,
+        },
 	{
 		.procname	= "overcommit_memory",
 		.data		= &sysctl_overcommit_memory,
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index ae00746..dac3223 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -263,6 +263,7 @@ struct vmap_area {
 
 static DEFINE_SPINLOCK(vmap_area_lock);
 static struct rb_root vmap_area_root = RB_ROOT;
+static struct rb_node *free_vmap_cache;
 static LIST_HEAD(vmap_area_list);
 static unsigned long vmap_area_pcpu_hole;
 
@@ -319,6 +320,7 @@ static void __insert_vmap_area(struct vmap_area *va)
 
 static void purge_vmap_area_lazy(void);
 
+unsigned long max_lookup_count;
 /*
  * Allocate a region of KVA of the specified size and alignment, within the
  * vstart and vend.
@@ -332,6 +334,9 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	struct rb_node *n;
 	unsigned long addr;
 	int purged = 0;
+	int lookup_cache = 0;
+	struct vmap_area *first;
+	unsigned int nlookup = 0;
 
 	BUG_ON(!size);
 	BUG_ON(size & ~PAGE_MASK);
@@ -342,35 +347,50 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 		return ERR_PTR(-ENOMEM);
 
 retry:
+	first = NULL;
 	addr = ALIGN(vstart, align);
 
 	spin_lock(&vmap_area_lock);
 	if (addr + size - 1 < addr)
 		goto overflow;
 
-	/* XXX: could have a last_hole cache */
 	n = vmap_area_root.rb_node;
-	if (n) {
-		struct vmap_area *first = NULL;
+	if (free_vmap_cache && !purged) {
+		struct vmap_area *cache;
+		cache = rb_entry(free_vmap_cache, struct vmap_area, rb_node);
+		if (cache->va_start >= addr && cache->va_end < vend) {
+			lookup_cache = 1;
+			n = free_vmap_cache;
+		}
+	}
 
-		do {
-			struct vmap_area *tmp;
-			tmp = rb_entry(n, struct vmap_area, rb_node);
-			if (tmp->va_end >= addr) {
-				if (!first && tmp->va_start < addr + size)
+	if (n) {
+		if (!lookup_cache) {
+			do {
+				struct vmap_area *tmp;
+				tmp = rb_entry(n, struct vmap_area, rb_node);
+				if (tmp->va_end >= addr) {
+					if (!first && tmp->va_start < addr + size)
+						first = tmp;
+					n = n->rb_left;
+				} else {
 					first = tmp;
-				n = n->rb_left;
-			} else {
-				first = tmp;
-				n = n->rb_right;
-			}
-		} while (n);
+					n = n->rb_right;
+				}
+				nlookup++;
+			} while (n);
+		}
+		else {
+			first = rb_entry(n, struct vmap_area, rb_node);
+			addr = first->va_start;
+		}
 
 		if (!first)
 			goto found;
 
 		if (first->va_end < addr) {
 			n = rb_next(&first->rb_node);
+			nlookup++;
 			if (n)
 				first = rb_entry(n, struct vmap_area, rb_node);
 			else
@@ -383,6 +403,7 @@ retry:
 				goto overflow;
 
 			n = rb_next(&first->rb_node);
+			nlookup++;
 			if (n)
 				first = rb_entry(n, struct vmap_area, rb_node);
 			else
@@ -396,6 +417,7 @@ overflow:
 		if (!purged) {
 			purge_vmap_area_lazy();
 			purged = 1;
+			lookup_cache = 0;
 			goto retry;
 		}
 		if (printk_ratelimit())
@@ -412,6 +434,9 @@ overflow:
 	va->va_end = addr + size;
 	va->flags = 0;
 	__insert_vmap_area(va);
+	free_vmap_cache = &va->rb_node;
+	if (max_lookup_count < nlookup)
+		max_lookup_count = nlookup;
 	spin_unlock(&vmap_area_lock);
 
 	return va;
@@ -426,7 +451,9 @@ static void rcu_free_va(struct rcu_head *head)
 
 static void __free_vmap_area(struct vmap_area *va)
 {
+	struct rb_node *prev;
 	BUG_ON(RB_EMPTY_NODE(&va->rb_node));
+	free_vmap_cache = rb_prev(&va->rb_node);
 	rb_erase(&va->rb_node, &vmap_area_root);
 	RB_CLEAR_NODE(&va->rb_node);
 	list_del_rcu(&va->list);
-- 
1.7.0.5



-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
