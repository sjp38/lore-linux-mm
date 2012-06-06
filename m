Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id AEA4E8D0001
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 06:07:54 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (mailout2.samsung.com [203.254.224.25])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M5600MTZXGHB8I0@mailout2.samsung.com> for
 linux-mm@kvack.org; Wed, 06 Jun 2012 19:07:53 +0900 (KST)
Received: from bzolnier-desktop.localnet ([106.116.48.38])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M560055WXH3TR50@mmp2.samsung.com> for linux-mm@kvack.org;
 Wed, 06 Jun 2012 19:07:52 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [PATCH v9] mm: compaction: handle incorrect MIGRATE_UNMOVABLE type
 pageblocks
Date: Wed, 06 Jun 2012 12:06:12 +0200
References: <201206041543.56917.b.zolnierkie@samsung.com>
 <4FCD6806.7070609@kernel.org> <4FCD713D.3020100@kernel.org>
In-reply-to: <4FCD713D.3020100@kernel.org>
MIME-version: 1.0
Content-type: Text/Plain; charset=iso-8859-15
Content-transfer-encoding: 7bit
Message-id: <201206061206.12759.b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <amwang@redhat.com>, Markus Trippelsdorf <markus@trippelsdorf.de>

On Tuesday 05 June 2012 04:38:53 Minchan Kim wrote:
> On 06/05/2012 10:59 AM, Minchan Kim wrote:
> 
> > On 06/05/2012 05:22 AM, KOSAKI Motohiro wrote:
> > 
> >>> +/*
> >>> + * Returns true if MIGRATE_UNMOVABLE pageblock can be successfully
> >>> + * converted to MIGRATE_MOVABLE type, false otherwise.
> >>> + */
> >>> +static bool can_rescue_unmovable_pageblock(struct page *page, bool
> >>> locked)
> >>> +{
> >>> +    unsigned long pfn, start_pfn, end_pfn;
> >>> +    struct page *start_page, *end_page, *cursor_page;
> >>> +
> >>> +    pfn = page_to_pfn(page);
> >>> +    start_pfn = pfn&  ~(pageblock_nr_pages - 1);
> >>> +    end_pfn = start_pfn + pageblock_nr_pages - 1;
> >>> +
> >>> +    start_page = pfn_to_page(start_pfn);
> >>> +    end_page = pfn_to_page(end_pfn);
> >>> +
> >>> +    for (cursor_page = start_page, pfn = start_pfn; cursor_page<=
> >>> end_page;
> >>> +        pfn++, cursor_page++) {
> >>> +        struct zone *zone = page_zone(start_page);
> >>> +        unsigned long flags;
> >>> +
> >>> +        if (!pfn_valid_within(pfn))
> >>> +            continue;
> >>> +
> >>> +        /* Do not deal with pageblocks that overlap zones */
> >>> +        if (page_zone(cursor_page) != zone)
> >>> +            return false;
> >>> +
> >>> +        if (!locked)
> >>> +            spin_lock_irqsave(&zone->lock, flags);
> >>> +
> >>> +        if (PageBuddy(cursor_page)) {
> >>> +            int order = page_order(cursor_page);
> >>>
> >>> -/* Returns true if the page is within a block suitable for migration
> >>> to */
> >>> -static bool suitable_migration_target(struct page *page)
> >>> +            pfn += (1<<  order) - 1;
> >>> +            cursor_page += (1<<  order) - 1;
> >>> +
> >>> +            if (!locked)
> >>> +                spin_unlock_irqrestore(&zone->lock, flags);
> >>> +            continue;
> >>> +        } else if (page_count(cursor_page) == 0 ||
> >>> +               PageLRU(cursor_page)) {
> >>> +            if (!locked)
> >>> +                spin_unlock_irqrestore(&zone->lock, flags);
> >>> +            continue;
> >>> +        }
> >>> +
> >>> +        if (!locked)
> >>> +            spin_unlock_irqrestore(&zone->lock, flags);
> >>> +
> >>> +        return false;
> >>> +    }
> >>> +
> >>> +    return true;
> >>> +}
> >>
> >> Minchan, are you interest this patch? If yes, can you please rewrite it?
> > 
> > 
> > Can do it but I want to give credit to Bartlomiej.
> > Bartlomiej, if you like my patch, could you resend it as formal patch after you do broad testing?

Sure.

> >> This one are
> >> not fixed our pointed issue and can_rescue_unmovable_pageblock() still
> >> has plenty bugs.
> >> We can't ack it.
> >>
> > 
> > 
> > Frankly speaking, I don't want to merge it without any data which prove it's really good for real practice.
> > 
> > When the patch firstly was submitted, it wasn't complicated so I was okay at that time but it has been complicated
> > than my expectation. So if Andrew might pass the decision to me, I'm totally NACK if author doesn't provide
> > any real data or VOC of some client.

I found this issue by accident while testing compaction code so unfortunately
I don't have any real bugreport to back it up.  It is just a corner case which
is more likely to happen in situation where there is rather small number of
pageblocks and quite heavy kernel memory allocation/freeing activity in
kernel going on.  I would presume that the issue can happen on some embedded
configurations but they are not your typical machine and it is not likely
to see a real bugreport for it.

I'm also quite unhappy with the increasing complexity of what seemed as
a quite simple fix initially and I tend to agree that the patch may stay
out-of-tree until there is a more proven need for it (maybe with documenting
the issue in the code for the time being).  Still, I would like to have
all outstanding issues fixed so I can merge the patch locally (and to -mm
if Andrew agrees) and just wait to see if the patch is ever needed in
practice.

I've attached the code that I use to trigger the issue at the bottom of this
mail so people can reproduce the problem and see for themselves whether it
is worth to fix it or not.

> > 1) Any comment?
> > 
> > Anyway, I fixed some bugs and clean up something I found during review.

Thanks for doing this.

> > Minor thing.
> > 1. change smt_result naming - I never like such long non-consistent naming. How about this?
> > 2. fix can_rescue_unmovable_pageblock 
> >    2.1 pfn valid check for page_zone
> > 
> > Major thing.
> > 
> >    2.2 add lru_lock for stablizing PageLRU
> >        If we don't hold lru_lock, there is possibility that unmovable(non-LRU) page can put in movable pageblock.
> >        It can make compaction/CMA's regression. But there is a concern about deadlock between lru_lock and lock.
> >        As I look the code, I can't find allocation trial with holding lru_lock so it might be safe(but not sure,
> >        I didn't test it. It need more careful review/testing) but it makes new locking dependency(not sure, too.
> >        We already made such rule but I didn't know that until now ;-) ) Why I thought so is we can allocate
> >        GFP_ATOMIC with holding lru_lock, logically which might be crazy idea.
> > 
> >    2.3 remove zone->lock in first phase.
> >        We do rescue unmovable pageblock by 2-phase. In first-phase, we just peek pages so we don't need locking.
> >        If we see non-stablizing value, it would be caught by 2-phase with needed lock or 
> >        can_rescue_unmovable_pageblock can return out of loop by stale page_order(cursor_page).
> >        It couldn't make unmovable pageblock to movable but we can do it next time, again.
> >        It's not critical.
> > 
> > 2) Any comment?
> > 
> > Now I can't inline the code so sorry but attach patch.
> > It's not a formal patch/never tested.
> > 
> 
> 
> Attached patch has a BUG in can_rescue_unmovable_pageblock.
> Resend. I hope it is fixed.

@@ -399,10 +399,14 @@
 		} else if (page_count(cursor_page) == 0) {
 			continue;
 		} else if (PageLRU(cursor_page)) {
-			if (!lru_locked && need_lrulock) {
+			if (!need_lrulock)
+				continue;
+			else if (lru_locked)
+				continue;
+			else {
 				spin_lock(&zone->lru_lock);
 				lru_locked = true;
-				if (PageLRU(cursor_page))
+				if (PageLRU(page))
 					continue;
 			}
 		}

Could you please explain why do we need to check page and not cursor_page
here?

Best regards,
--
Bartlomiej Zolnierkiewicz
Samsung Poland R&D Center


My test case (on 512 MiB machine):
* insmod alloc_frag.ko
* run ./alloc_app and push it to background with Ctrl-Z
* rmmod alloc_frag.ko
* insmod alloc_test.ko

---
 alloc_app.c     |   22 ++++++++++++++++++++++
 mm/Kconfig      |    8 ++++++++
 mm/Makefile     |    3 +++
 mm/alloc_frag.c |   35 +++++++++++++++++++++++++++++++++++
 mm/alloc_test.c |   40 ++++++++++++++++++++++++++++++++++++++++
 5 files changed, 108 insertions(+)

Index: b/alloc_app.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ b/alloc_app.c	2012-04-06 11:49:23.789380700 +0200
@@ -0,0 +1,22 @@
+
+#include <stdlib.h>
+#include <string.h>
+#include <stdio.h>
+
+#define ALLOC_NR_PAGES 60000
+
+int main(void)
+{
+	void *alloc_app_pages[ALLOC_NR_PAGES];
+	int i;
+
+	for (i = 0; i < ALLOC_NR_PAGES; i++) {
+		alloc_app_pages[i] = malloc(4096);
+		if (alloc_app_pages[i])
+			memset(alloc_app_pages[i], 'z', 4096);
+	}
+
+	getchar();
+
+	return 0;
+}
Index: b/mm/Kconfig
===================================================================
--- a/mm/Kconfig	2012-04-05 18:40:36.000000000 +0200
+++ b/mm/Kconfig	2012-04-06 11:49:23.789380700 +0200
@@ -379,3 +379,11 @@
 	  in a negligible performance hit.
 
 	  If unsure, say Y to enable cleancache
+
+config ALLOC_FRAG
+	tristate "alloc frag"
+	help
+
+config ALLOC_TEST
+	tristate "alloc test"
+	help
Index: b/mm/Makefile
===================================================================
--- a/mm/Makefile	2012-04-05 18:40:36.000000000 +0200
+++ b/mm/Makefile	2012-04-06 11:49:23.789380700 +0200
@@ -16,6 +16,9 @@
 			   $(mmu-y)
 obj-y += init-mm.o
 
+obj-$(CONFIG_ALLOC_FRAG) += alloc_frag.o
+obj-$(CONFIG_ALLOC_TEST) += alloc_test.o
+
 ifdef CONFIG_NO_BOOTMEM
 	obj-y		+= nobootmem.o
 else
Index: b/mm/alloc_frag.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ b/mm/alloc_frag.c	2012-04-06 11:52:43.761439914 +0200
@@ -0,0 +1,35 @@
+
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+
+#define ALLOC_NR_PAGES 120000
+static struct page *alloc_frag_pages[ALLOC_NR_PAGES];
+
+static int __init alloc_frag_init(void)
+{
+	int i;
+
+	for (i = 0; i < ALLOC_NR_PAGES; i++)
+		alloc_frag_pages[i] = alloc_pages(GFP_KERNEL, 0);
+
+	for (i = 0; i < ALLOC_NR_PAGES; i += 2) {
+		if (alloc_frag_pages[i])
+			__free_pages(alloc_frag_pages[i], 0);
+	}
+
+	return 0;
+}
+module_init(alloc_frag_init);
+
+static void __exit alloc_frag_exit(void)
+{
+	int i;
+
+	for (i = 1; i < ALLOC_NR_PAGES; i += 2)
+		if (alloc_frag_pages[i])
+			__free_pages(alloc_frag_pages[i], 0);
+}
+module_exit(alloc_frag_exit);
+
+MODULE_LICENSE("GPL");
Index: b/mm/alloc_test.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ b/mm/alloc_test.c	2012-04-06 11:49:23.789380700 +0200
@@ -0,0 +1,40 @@
+
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+
+#define ALLOC_NR_PAGES 120000
+static struct page *alloc_test_pages[ALLOC_NR_PAGES];
+
+static int __init alloc_test_init(void)
+{
+	int i;
+
+	printk("trying order-9 allocs..\n");
+	for (i = 0; i < 100; i++) {
+		alloc_test_pages[i] = alloc_pages(GFP_KERNEL, 9);
+		if (alloc_test_pages[i])
+			printk("\ttry %d succes\n", i);
+		else {
+			printk("\ttry %d failure\n", i);
+			break;
+		}
+	}
+
+	return 0;
+}
+module_init(alloc_test_init);
+
+static void __exit alloc_test_exit(void)
+{
+	int i;
+
+	for (i = 0; i < 100; i++) {
+		if (alloc_test_pages[i])
+			__free_pages(alloc_test_pages[i], 9);
+	}
+
+}
+module_exit(alloc_test_exit);
+
+MODULE_LICENSE("GPL");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
