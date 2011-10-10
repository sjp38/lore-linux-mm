Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DDED76B002C
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 19:50:02 -0400 (EDT)
Received: by ggdk5 with SMTP id k5so6747074ggd.14
        for <linux-mm@kvack.org>; Mon, 10 Oct 2011 16:50:01 -0700 (PDT)
Date: Mon, 10 Oct 2011 16:41:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: memory hotplug: Check if pages are correctly
 reserved on a per-section basis
Message-Id: <20111010164152.5485fbaf.akpm@linux-foundation.org>
In-Reply-To: <20111010233531.GA7234@kroah.com>
References: <20111010071119.GE6418@suse.de>
	<20111010150038.ac161977.akpm@linux-foundation.org>
	<20111010232403.GA30513@kroah.com>
	<20111010162813.7a470ae4.akpm@linux-foundation.org>
	<20111010233531.GA7234@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <greg@kroah.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, nfont@linux.vnet.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, 10 Oct 2011 16:35:31 -0700
Greg KH <greg@kroah.com> wrote:

> > > Ok, care to send me what exactly needs to be reverted and what needs to
> > > be added?
> > 
> > Drop
> > 
> > commit 54f23eb7ba7619de85d8edca6e5336bc33072dbd
> > Author: Nathan Fontenot <nfont@austin.ibm.com>
> > Date:   Mon Sep 26 10:22:33 2011 -0500
> > 
> >     memory hotplug: Correct page reservation checking
> > 
> > and replace it with start-of-this-thread.
> > 
> > That's assuming that Mel's update passes Nathan's review and testing :)
> 
> Ok, I'll wait for that review and testing, and then can someone send me
> the patch at the start-of-this-thread as I no longer seem to be able to
> find it :(

It sounds like your new email setup is working as well as mine :(


From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: memory hotplug: Check if pages are correctly reserved on

It is expected that memory being brought online is PageReserved
similar to what happens when the page allocator is being brought up.
Memory is onlined in "memory blocks" which consist of one or more
sections. Unfortunately, the code that verifies PageReserved is
currently assuming that the memmap backing all these pages is virtually
contiguous which is only the case when CONFIG_SPARSEMEM_VMEMMAP is set.
As a result, memory hot-add is failing on !VMEMMAP configurations
with the message;

kernel: section number XXX page number 256 not reserved, was it already online?

This patch updates the PageReserved check to lookup struct page once
per section to guarantee the correct struct page is being checked.

[original patch by: nfont@linux.vnet.ibm.com]
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 drivers/base/memory.c |   58 +++++++++++++++++++++++++++++++++---------------
 1 files changed, 40 insertions(+), 18 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 2840ed4..ffb69cd 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -224,13 +224,48 @@ int memory_isolate_notify(unsigned long val, void *v)
 }
 
 /*
+ * The probe routines leave the pages reserved, just as the bootmem code does.
+ * Make sure they're still that way.
+ */
+static bool pages_correctly_reserved(unsigned long start_pfn,
+					unsigned long nr_pages)
+{
+	int i, j;
+	struct page *page;
+	unsigned long pfn = start_pfn;
+
+	/*
+	 * memmap between sections is not contiguous except with
+	 * SPARSEMEM_VMEMMAP. We lookup the page once per section
+	 * and assume memmap is contiguous within each section
+	 */
+	for (i = 0; i < sections_per_block; i++, pfn += PAGES_PER_SECTION) {
+		if (WARN_ON_ONCE(!pfn_valid(pfn)))
+			return false;
+		page = pfn_to_page(pfn);
+
+		for (j = 0; j < PAGES_PER_SECTION; j++) {
+			if (PageReserved(page + i))
+				continue;
+
+			printk(KERN_WARNING "section number %ld page number %d "
+				"not reserved, was it already online?\n",
+				pfn_to_section_nr(pfn), j);
+
+			return false;
+		}
+	}
+
+	return true;
+}
+
+/*
  * MEMORY_HOTPLUG depends on SPARSEMEM in mm/Kconfig, so it is
  * OK to have direct references to sparsemem variables in here.
  */
 static int
 memory_block_action(unsigned long phys_index, unsigned long action)
 {
-	int i;
 	unsigned long start_pfn, start_paddr;
 	unsigned long nr_pages = PAGES_PER_SECTION * sections_per_block;
 	struct page *first_page;
@@ -238,26 +273,13 @@ memory_block_action(unsigned long phys_index, unsigned long action)
 
 	first_page = pfn_to_page(phys_index << PFN_SECTION_SHIFT);
 
-	/*
-	 * The probe routines leave the pages reserved, just
-	 * as the bootmem code does.  Make sure they're still
-	 * that way.
-	 */
-	if (action == MEM_ONLINE) {
-		for (i = 0; i < nr_pages; i++) {
-			if (PageReserved(first_page+i))
-				continue;
-
-			printk(KERN_WARNING "section number %ld page number %d "
-				"not reserved, was it already online?\n",
-				phys_index, i);
-			return -EBUSY;
-		}
-	}
-
 	switch (action) {
 		case MEM_ONLINE:
 			start_pfn = page_to_pfn(first_page);
+
+			if (!pages_correctly_reserved(start_pfn, nr_pages))
+				return -EBUSY;
+
 			ret = online_pages(start_pfn, nr_pages);
 			break;
 		case MEM_OFFLINE:


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
