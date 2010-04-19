Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E9CA96B01EF
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 15:38:51 -0400 (EDT)
Date: Mon, 19 Apr 2010 20:39:19 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: error at compaction  (Re: mmotm 2010-04-15-14-42 uploaded
Message-ID: <20100419193919.GB19264@csn.ul.ie>
References: <201004152210.o3FMA7KV001909@imap1.linux-foundation.org> <20100419190133.50a13021.kamezawa.hiroyu@jp.fujitsu.com> <20100419181442.GA19264@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100419181442.GA19264@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 19, 2010 at 07:14:42PM +0100, Mel Gorman wrote:
> On Mon, Apr 19, 2010 at 07:01:33PM +0900, KAMEZAWA Hiroyuki wrote:
> > 
> > mmotm 2010-04-15-14-42 
> > 
> > When I tried 
> >  # echo 0 > /proc/sys/vm/compaction
> > 
> > I see following.
> > 
> > My enviroment was 
> >   2.6.34-rc4-mm1+ (2010-04-15-14-42) (x86-64) CPUx8
> >   allocating tons of hugepages and reduce free memory.
> > 
> > What I did was:
> >   # echo 0 > /proc/sys/vm/compact_memory
> > 
> > Hmm, I see this kind of error at migation for the 1st time..
> > my.config is attached. Hmm... ?
> > 
> > (I'm sorry I'll be offline soon.)
> 
> That's ok, thanks you for the report. I'm afraid I made little progress
> as I spent most of the day on other bugs but I do have something for
> you.
> 
> First, I reproduced the problem using your .config. However, the problem does
> not manifest with the .config I normally use which is derived from the distro
> kernel configuration (Debian Lenny). So, there is something in your .config
> that triggers the problem. I very strongly suspect this is an interaction
> between migration, compaction and page allocation debug.

I unexpecedly had the time to dig into this. Does the following patch fix
your problem? It Worked For Me.

==== CUT HERE ====
mm,compaction: Map free pages in the address space after they get split for compaction

split_free_page() is a helper function which takes a free page from the
buddy lists and splits it into order-0 pages. It is used by memory
compaction to build a list of destination pages. If
CONFIG_DEBUG_PAGEALLOC is set, a kernel paging request bug is triggered
because split_free_page() did not call the arch-allocation hooks or map
the page into the kernel address space.

This patch does not update split_free_page() as it is called with
interrupts held. Instead it documents that callers of split_free_page()
are responsible for calling the arch hooks and to map the page and fixes
compaction.

This is a fix to the patch mm-compaction-memory-compaction-core.patch.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/compaction.c |    6 ++++++
 mm/page_alloc.c |    3 +++
 2 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 8f4c518..6218e03 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -184,6 +184,12 @@ static void isolate_freepages(struct zone *zone,
 	}
 	spin_unlock_irqrestore(&zone->lock, flags);
 
+	/* split_free_page does not map the pages */
+	list_for_each_entry(page, freelist, lru) {
+		arch_alloc_page(page, 0);
+		kernel_map_pages(page, 1, 1);
+	}
+
 	cc->free_pfn = high_pfn;
 	cc->nr_freepages = nr_freepages;
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 53442fd..b2af4d9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1211,6 +1211,9 @@ void split_page(struct page *page, unsigned int order)
 /*
  * Similar to split_page except the page is already free. As this is only
  * being used for migration, the migratetype of the block also changes.
+ * As this is called with interrupts disabled, the caller is responsible
+ * for calling arch_alloc_page() and kernel_map_page() after interrupts
+ * are enabled.
  */
 int split_free_page(struct page *page)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
