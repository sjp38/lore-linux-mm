Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 222346B004D
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 10:02:04 -0400 (EDT)
Received: by bwz8 with SMTP id 8so192207bwz.38
        for <linux-mm@kvack.org>; Tue, 30 Jun 2009 07:01:58 -0700 (PDT)
Date: Tue, 30 Jun 2009 23:00:58 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: Found the commit that causes the OOMs
Message-Id: <20090630230058.87e530c6.minchan.kim@barrios-desktop>
In-Reply-To: <20090630092235.GA17561@csn.ul.ie>
References: <20090628142239.GA20986@localhost>
	<2f11576a0906280801w417d1b9fpe10585b7a641d41b@mail.gmail.com>
	<20090628151026.GB25076@localhost>
	<20090629091741.ab815ae7.minchan.kim@barrios-desktop>
	<17678.1246270219@redhat.com>
	<20090629125549.GA22932@localhost>
	<29432.1246285300@redhat.com>
	<28c262360906290800v37f91d7av3642b1ad8b5f0477@mail.gmail.com>
	<20090629160725.GF5065@csn.ul.ie>
	<20090630130741.c191d042.minchan.kim@barrios-desktop>
	<20090630092235.GA17561@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, David Howells <dhowells@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

Hi, David. 

On Tue, 30 Jun 2009 10:22:36 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> > > I think this system might be genuinely OOM. It can't reclaim memory and
> > > we are below the minimum watermarks.
> > > 
> > > Is it possible there are pages that are counted as active_anon that in
> > > fact are reclaimable because they are on the wrong LRU list? If that was
> > > the case, the lack of rotation to inactive list would prevent them
> > > getting discovered.
> > 
> > I agree. 
> > One of them is that "[BUGFIX][PATCH] fix lumpy reclaim lru handiling at
> > isolate_lru_pages v2" as Kosaki already said. 
> > 
> > Unfortunately, David said it's not. 
> > But I think your guessing make sense. 
> > 
> > David. Doesn't it happen OOM if you revert my patch, still?
> > 
> 
> In the event the OOM does not happen with the patch reverted, I suggest
> you put together a debugging patch that prints out details of all pages
> on the active_anon LRU list in the event of an OOM. The intention is to
> figure out what pages are on the active_anon list that shouldn't be.

Befor I go to the trip, I made debugging patch in a hurry. 
Mel and I suspect to put the wrong page in lru list.

This patch's goal is that print page's detail on active anon lru when it happen OOM.
Maybe you could expand your log buffer size. 

Could you show me the information with OOM, please ?

---
 include/linux/mm.h |    1 +
 lib/show_mem.c     |    2 +-
 mm/page_alloc.c    |   22 ++++++++++++++++++++++
 mm/vmstat.c        |   14 ++++++++++++++
 4 files changed, 38 insertions(+), 1 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ba3a7cb..cfd8111 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -713,6 +713,7 @@ extern void pagefault_out_of_memory(void);
 
 #define offset_in_page(p)	((unsigned long)(p) & ~PAGE_MASK)
 
+extern void show_active_anonpages(void);
 extern void show_free_areas(void);
 
 #ifdef CONFIG_SHMEM
diff --git a/lib/show_mem.c b/lib/show_mem.c
index 238e72a..32a3a32 100644
--- a/lib/show_mem.c
+++ b/lib/show_mem.c
@@ -17,7 +17,7 @@ void show_mem(void)
 
 	printk(KERN_INFO "Mem-Info:\n");
 	show_free_areas();
-
+	show_active_anonpages();
 	for_each_online_pgdat(pgdat) {
 		unsigned long i, flags;
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5d714f8..d666f9e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2090,6 +2090,28 @@ void si_meminfo_node(struct sysinfo *val, int nid)
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
 
+void show_active_anonpages(void)
+{
+	struct zone *zone;
+	struct list_head *list;
+	struct page *page;
+
+	for_each_populated_zone(zone) {
+		if (list_empty(&zone->lru[LRU_ACTIVE_ANON].list))
+			continue;
+
+		spin_lock_irq(&zone->lru_lock);
+		list = &zone->lru[LRU_ACTIVE_ANON].list;				
+		printk("==== %s ==== \n", zone->name);
+		list_for_each_entry(page, list, lru) {
+			printk(KERN_INFO "pfn:0x%08lx F:0x%08lx anon:%d C:%d M:%d\n",
+				page_to_pfn(page), page->flags, PageAnon(page), 
+				atomic_read(&page->_count), atomic_read(&page->_mapcount));
+		}
+		spin_unlock_irq(&zone->lru_lock);
+	}
+		
+}
 /*
  * Show free area list (used inside shift_scroll-lock stuff)
  * We also calculate the percentage fragmentation. We do this by counting the
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 138bed5..c23ecaa 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -575,6 +575,12 @@ static int fragmentation_open(struct inode *inode, struct file *file)
 	return seq_open(file, &fragmentation_op);
 }
 
+static int active_anon_open(struct inode *inode, struct file *file)
+{
+	show_active_anonpages();
+	return -ENOENT;
+}
+
 static const struct file_operations fragmentation_file_operations = {
 	.open		= fragmentation_open,
 	.read		= seq_read,
@@ -582,6 +588,13 @@ static const struct file_operations fragmentation_file_operations = {
 	.release	= seq_release,
 };
 
+static const struct file_operations active_anon_file_operations = {
+	.open		= active_anon_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
 static const struct seq_operations pagetypeinfo_op = {
 	.start	= frag_start,
 	.next	= frag_next,
@@ -938,6 +951,7 @@ static int __init setup_vmstat(void)
 #endif
 #ifdef CONFIG_PROC_FS
 	proc_create("buddyinfo", S_IRUGO, NULL, &fragmentation_file_operations);
+	proc_create("activelruinfo", S_IRUGO, NULL, &active_anon_file_operations);
 	proc_create("pagetypeinfo", S_IRUGO, NULL, &pagetypeinfo_file_ops);
 	proc_create("vmstat", S_IRUGO, NULL, &proc_vmstat_file_operations);
 	proc_create("zoneinfo", S_IRUGO, NULL, &proc_zoneinfo_file_operations);
-- 
1.5.4.3


-- 
Kinds Regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
