Date: Sat, 14 Apr 2007 04:24:07 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc] rename page_count for lockless pagecache
Message-ID: <20070414022407.GC14544@wotan.suse.de>
References: <20070412103151.5564.16127.sendpatchset@linux.site> <20070412103340.5564.23286.sendpatchset@linux.site> <Pine.LNX.4.64.0704131229510.19073@blonde.wat.veritas.com> <20070413121347.GC966@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070413121347.GC966@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 13, 2007 at 02:13:47PM +0200, Nick Piggin wrote:
> On Fri, Apr 13, 2007 at 12:53:05PM +0100, Hugh Dickins wrote:
> > Might it be more profitable for a DEBUG mode to inject random
> > variations into page_count?
> 
> I think that's a very fine idea, and much more suitable for an
> everyday kernel than my test threads. Doesn't help if they use the
> field somehow without the accessors, but we must discourage that.
> Thanks, I'll add such a debug mode.

Something like this boots and survives some stress testing here.

I guess it should be under something other than CONFIG_DEBUG_VM,
because it could harm performance and scalability significantly on
bigger boxes... or maybe it should use per-cpu counters? ;)

--
Add some debugging for lockless pagecache as suggested by Hugh.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -267,10 +267,29 @@ static inline int get_page_unless_zero(s
 	return atomic_inc_not_zero(&page->_count);
 }
 
+#ifdef CONFIG_DEBUG_VM
+extern int ll_counter;
+#endif
 static inline int page_count(struct page *page)
 {
 	if (unlikely(PageCompound(page)))
 		page = (struct page *)page_private(page);
+#ifdef CONFIG_DEBUG_VM
+	/*
+	 * debug testing for lockless pagecache. add a random value to
+	 * page_count every now and then, to simulate speculative references
+	 * to it.
+	 */
+	{
+		int count = atomic_read(&page->_count);
+		if (count) {
+			ll_counter++;
+			if (ll_counter % 5 == 0 || ll_counter % 7 == 0)
+				count += ll_counter % 11;
+		}
+		return count;
+	}
+#endif
 	return atomic_read(&page->_count);
 }
 
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -137,6 +137,8 @@ static unsigned long __initdata dma_rese
 #endif /* CONFIG_ARCH_POPULATES_NODE_MAP */
 
 #ifdef CONFIG_DEBUG_VM
+int ll_counter; /* used in include/linux/mm.h, for lockless pagecache */
+EXPORT_SYMBOL(ll_counter);
 static int page_outside_zone_boundaries(struct zone *zone, struct page *page)
 {
 	int ret = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
