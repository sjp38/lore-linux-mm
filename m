Date: Mon, 28 May 2001 14:29:28 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [PATCH] modified memory_pressure calculation
In-Reply-To: <3B10F351.6DDEC59@colorfullife.com>
Message-ID: <Pine.LNX.4.21.0105281425450.1204-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Sun, 27 May 2001, Manfred Spraul wrote:

> I think the current memory_pressure calculation is broken - at least
> memory_pressure does not contain the number of pages necessary in the
> inactive_clean_list to handle 1 second of allocations.
> 
> * if reclaim_page() finds a page that is Referenced, Dirty or Locked
> then it must increase memory_pressure.
> * I don't understand the purpose of the second ++ in alloc_pages().
> 
> What about the attached patch [vs. 2.4.5]? It's just an idea, untested.
> 
> If the behaviour is worse then we must figure out what memory_pressure
> actually is under the various workloads. AFAICS it has nothing to do
> with the number of memory allocations per second.

Pasting a part of your patch: 

@@ -363,6 +364,7 @@
                                (!page->buffers && page_count(page) >
1)) {
                        del_page_from_inactive_clean_list(page);
                        add_page_to_active_list(page);
+                       memory_pressure++;
                        continue;
                }
 
@@ -370,6 +372,7 @@
                if (page->buffers || PageDirty(page) || TryLockPage(page)) {
                        del_page_from_inactive_clean_list(page);
                        add_page_to_inactive_dirty_list(page);
+                       memory_pressure++;
                        continue;
                }
 


I disagree with the second hunk. 

memory_pressure is used to calculate the size of _both_ the inactive dirty
and clean lists. 

Since you're adding the page back to the inactive dirty list, you should
not increase memory_pressure.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
