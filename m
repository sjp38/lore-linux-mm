Date: Mon, 30 Aug 2004 19:17:28 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: Kernel 2.6.8.1: swap storm of death - nr_requests > 1024 on swap partition
Message-ID: <20040830221727.GE2955@logos.cnet>
References: <20040829033031.01c5f78c.akpm@osdl.org> <20040829141526.GC10955@suse.de> <20040829141718.GD10955@suse.de> <20040829131824.1b39f2e8.akpm@osdl.org> <20040829203011.GA11878@suse.de> <20040829135917.3e8ffed8.akpm@osdl.org> <20040830152025.GA2901@logos.cnet> <41336B6F.6050806@pandora.be> <20040830203339.GA2955@logos.cnet> <20040830153730.18e431c2.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040830153730.18e431c2.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: karl.vogel@pandora.be, axboe@suse.de, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 30, 2004 at 03:37:30PM -0700, Andrew Morton wrote:
> Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
> >
> >  static int may_write_to_queue(struct backing_dev_info *bdi)
> >  {
> > +	int nr_writeback = read_page_state(nr_writeback);
> > +
> > +	if (nr_writeback > (totalram_pages * 25 / 100)) { 
> > +		blk_congestion_wait(WRITE, HZ/5);
> > +		return 0;
> > +	}
> 
> That's probably a good way of special-casing this special-place problem.
> 
> For a final patch I'd be inclined to take into account /proc/sys/vm/dirty_ratio
> and to avoid running the expensive read_page_state() once per writepage.

What you think of this, which tries to address your comments

We might want to make shrink_caches() bailoff when the limit is reached


--- include/linux/writeback.h.orig	2004-08-30 20:18:06.291153336 -0300
+++ include/linux/writeback.h	2004-08-30 20:17:47.284042856 -0300
@@ -86,6 +86,7 @@
 int wakeup_bdflush(long nr_pages);
 void laptop_io_completion(void);
 void laptop_sync_completion(void);
+int vm_eviction_limits(int);
 
 /* These are exported to sysctl. */
 extern int dirty_background_ratio;
--- mm/page-writeback.c.orig	2004-08-30 20:10:50.508402384 -0300
+++ m//page-writeback.c	2004-08-30 20:16:26.583311232 -0300
@@ -279,6 +279,21 @@
 EXPORT_SYMBOL(balance_dirty_pages_ratelimited);
 
 /*
+ * This function calculates the maximum pinned-for-IO memory 
+ * the page eviction threads can generate. 
+ *
+ * Returns true if we cant writeout.
+ */
+int vm_eviction_limits(int inflight) 
+{
+	if (inflight > (totalram_pages * vm_dirty_ratio) / 100)  {
+                blk_congestion_wait(WRITE, HZ/10);
+		return 1;
+	} 
+	return 0;
+}
+
+/*
  * writeback at least _min_pages, and keep writing until the amount of dirty
  * memory is less than the background threshold, or until we're all clean.
  */
--- vmscan.c.orig	2004-08-30 20:19:05.501152048 -0300
+++ vmscan.c	2004-08-30 20:16:38.552491640 -0300
@@ -245,8 +245,11 @@
 	return page_count(page) - !!PagePrivate(page) == 2;
 }
 
-static int may_write_to_queue(struct backing_dev_info *bdi)
+static int may_write_to_queue(struct backing_dev_info *bdi, int inflight)
 {
+	if (vm_eviction_limits(inflight)) /* Check VM writeout limit */
+		return 0;
+
 	if (current_is_kswapd())
 		return 1;
 	if (current_is_pdflush())	/* This is unlikely, but why not... */
@@ -286,7 +289,8 @@
 /*
  * pageout is called by shrink_list() for each dirty page. Calls ->writepage().
  */
-static pageout_t pageout(struct page *page, struct address_space *mapping)
+static pageout_t pageout(struct page *page, struct address_space *mapping, int
+inflight)
 {
 	/*
 	 * If the page is dirty, only perform writeback if that write
@@ -311,7 +315,7 @@
 		return PAGE_KEEP;
 	if (mapping->a_ops->writepage == NULL)
 		return PAGE_ACTIVATE;
-	if (!may_write_to_queue(mapping->backing_dev_info))
+	if (!may_write_to_queue(mapping->backing_dev_info, inflight))
 		return PAGE_KEEP;
 
 	if (clear_page_dirty_for_io(page)) {
@@ -351,6 +355,7 @@
 	struct pagevec freed_pvec;
 	int pgactivate = 0;
 	int reclaimed = 0;
+	int inflight = read_page_state(nr_writeback);
 
 	cond_resched();
 
@@ -421,7 +426,7 @@
 				goto keep_locked;
 
 			/* Page is dirty, try to write it out here */
-			switch(pageout(page, mapping)) {
+			switch(pageout(page, mapping, inflight)) {
 			case PAGE_KEEP:
 				goto keep_locked;
 			case PAGE_ACTIVATE:
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
