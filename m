Date: Fri, 2 Nov 2007 13:44:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: start_isolate_page_range() question/offline_pages() bug ?
Message-Id: <20071102134420.435732c6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1193944769.26106.34.camel@dyn9047017100.beaverton.ibm.com>
References: <1193944769.26106.34.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi, Badari. Thank you for digging.

On Thu, 01 Nov 2007 11:19:28 -0800
Badari Pulavarty <pbadari@us.ibm.com> wrote:

> Hi KAME,
> 
> While testing hotplug memory remove on x86_64, found an issue.
> 
> offline_pages()
> {
> 
> 	...
> 	
> 	/* set above range as isolated */
>         ret = start_isolate_page_range(start_pfn, end_pfn);
> 	
> 
> 	... does all the work and successful ...
> 
>         /* reset pagetype flags */
>         start_isolate_page_range(start_pfn, end_pfn);
>         /* removal success */
> }
> 
> As you can see it calls, start_isolate_page_range() again at
> the end. Why ? I am assuming that, to clear MIGRATE_ISOLATE
> type for those pages we marked earlier. Isn't it ? But its
> wrong. The pages are already set MIGRATE_ISOLATE and it
> will end up clearing ONLY the first page in the pageblock.
> Shouldn't we clear MIGRATE_ISOLATE for all the pages ?
> 
Hmm.. Maybe I wanted to call undo_isolate_page_range()

> I see this issue on x86-64, because /sysfs memory block
> is 128MB, but pageblock_nr_pages = 512 (2MB).
> 
Hmm, do you have patches for x86_64 ?

> I can reproduce the problem easily.. by doing ..
> 
> echo offline > state
> echo online > state
> echo offline > state <--- this one will fail
> echo offline > state <-- fail
> echo offline > state <-- fail
> 
> Everytime we do "offline" it clears first page in 2MB
> section as part of undo :(
> 
Hmmmm.... could you share your x86_64 patch ?
I'll dig more. below is my patch at this point.

Index: devel-2.6.23-mm1/mm/memory_hotplug.c
===================================================================
--- devel-2.6.23-mm1.orig/mm/memory_hotplug.c
+++ devel-2.6.23-mm1/mm/memory_hotplug.c
@@ -536,8 +536,8 @@ repeat:
 	/* Ok, all of our target is islaoted.
 	   We cannot do rollback at this point. */
 	offline_isolated_pages(start_pfn, end_pfn);
-	/* reset pagetype flags */
-	start_isolate_page_range(start_pfn, end_pfn);
+	/* reset pagetype flags and makes migrate type to be MOVABLE */
+	undo_isolate_page_range(start_pfn, end_pfn);
 	/* removal success */
 	zone = page_zone(pfn_to_page(start_pfn));
 	zone->present_pages -= offlined_pages;
Index: devel-2.6.23-mm1/mm/page_isolation.c
===================================================================
--- devel-2.6.23-mm1.orig/mm/page_isolation.c
+++ devel-2.6.23-mm1/mm/page_isolation.c
@@ -55,7 +55,7 @@ start_isolate_page_range(unsigned long s
 	return 0;
 undo:
 	for (pfn = start_pfn;
-	     pfn <= undo_pfn;
+	     pfn < undo_pfn;
 	     pfn += pageblock_nr_pages)
 		unset_migratetype_isolate(pfn_to_page(pfn));
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
