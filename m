Message-ID: <45D50B79.5080002@mbligh.org>
Date: Thu, 15 Feb 2007 17:40:09 -0800
From: Martin Bligh <mbligh@mbligh.org>
MIME-Version: 1.0
Subject: Re: [RFC] Remove unswappable anonymous pages off the LRU
References: <Pine.LNX.4.64.0702151300500.31366@schroedinger.engr.sgi.com> <20070215171355.67c7e8b4.akpm@linux-foundation.org>
In-Reply-To: <20070215171355.67c7e8b4.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Thu, 15 Feb 2007 13:05:47 -0800 (PST)
> Christoph Lameter <clameter@sgi.com> wrote:
> 
>> If we do not have any swap or we have run out of swap then anonymous pages
>> can no longer be removed from memory. In that case we simply treat them
>> like mlocked pages. For a kernel compiled CONFIG_SWAP off this means
>> that all anonymous pages are marked mlocked when they are allocated.
> 
> It's nice and simple, but I think I'd prefer to wait for the existing mlock
> changes to crash a bit less before we do this.
> 
> Is it true that PageMlocked() pages are never on the LRU?  If so, perhaps
> we could overload the lru.next/prev on these pages to flag an mlocked page.
> 
> #define PageMlocked(page)	(page->lru.next == some_address_which_isnt_used_for_anwything_else)

Mine just created a locked list. If you stick them there, there's no
need for a page flag ... and we don't abuse the lru pointers AGAIN! ;-)

Suspect most of the rest of my patch is crap, but that might be useful?

M.


--- linux-2.6.17/include/linux/mm_inline.h      2006-06-17 
18:49:35.000000000 -0
700
+++ linux-2.6.17-mlock_lru/include/linux/mm_inline.h    2006-07-28 
15:53:15.0000
00000 -0700

@@ -28,6 +27,20 @@ del_page_from_inactive_list(struct zone
  }

  static inline void
+add_page_to_mlocked_list(struct zone *zone, struct page *page)
+{
+       list_add(&page->lru, &zone->mlocked_list);
+       zone->nr_mlocked--;
+}
+
+static inline void
+del_page_from_mlocked_list(struct zone *zone, struct page *page)
+{
+       list_del(&page->lru);
+       zone->nr_mlocked--;
+}
+
+static inline void
  del_page_from_lru(struct zone *zone, struct page *page)
  {
         list_del(&page->lru);
diff -aurpN -X /home/mbligh/.diff.exclude 
linux-2.6.17/include/linux/mmzone.h li
nux-2.6.17-mlock_lru/include/linux/mmzone.h
--- linux-2.6.17/include/linux/mmzone.h 2006-06-17 18:49:35.000000000 -0700
+++ linux-2.6.17-mlock_lru/include/linux/mmzone.h       2006-07-28 
15:49:05.0000
00000 -0700
@@ -156,10 +156,12 @@ struct zone {
         spinlock_t              lru_lock;
         struct list_head        active_list;
         struct list_head        inactive_list;
+       struct list_head        mlocked_list;
         unsigned long           nr_scan_active;
         unsigned long           nr_scan_inactive;
         unsigned long           nr_active;
         unsigned long           nr_inactive;
+       unsigned long           nr_mlocked;
         unsigned long           pages_scanned;     /* since last reclaim */
         int                     all_unreclaimable; /* All pages pinned */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
