Subject: Re: [RFC] Remove unswappable anonymous pages off the LRU
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <45D50B79.5080002@mbligh.org>
References: <Pine.LNX.4.64.0702151300500.31366@schroedinger.engr.sgi.com>
	 <20070215171355.67c7e8b4.akpm@linux-foundation.org>
	 <45D50B79.5080002@mbligh.org>
Content-Type: text/plain
Date: Fri, 16 Feb 2007 09:10:27 +0100
Message-Id: <1171613427.24923.50.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Bligh <mbligh@mbligh.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-02-15 at 17:40 -0800, Martin Bligh wrote:

> Mine just created a locked list. If you stick them there, there's no
> need for a page flag ... and we don't abuse the lru pointers AGAIN! ;-)

> --- linux-2.6.17/include/linux/mm_inline.h      2006-06-17 
> 18:49:35.000000000 -0
> 700
> +++ linux-2.6.17-mlock_lru/include/linux/mm_inline.h    2006-07-28 
> 15:53:15.0000
> 00000 -0700
> 
> @@ -28,6 +27,20 @@ del_page_from_inactive_list(struct zone
>   }
> 
>   static inline void
> +add_page_to_mlocked_list(struct zone *zone, struct page *page)
> +{
> +       list_add(&page->lru, &zone->mlocked_list);
> +       zone->nr_mlocked--;
> +}
> +
> +static inline void
> +del_page_from_mlocked_list(struct zone *zone, struct page *page)
> +{
> +       list_del(&page->lru);
> +       zone->nr_mlocked--;
> +}
> +
> +static inline void
>   del_page_from_lru(struct zone *zone, struct page *page)
>   {
>          list_del(&page->lru);
> diff -aurpN -X /home/mbligh/.diff.exclude 
> linux-2.6.17/include/linux/mmzone.h li
> nux-2.6.17-mlock_lru/include/linux/mmzone.h
> --- linux-2.6.17/include/linux/mmzone.h 2006-06-17 18:49:35.000000000 -0700
> +++ linux-2.6.17-mlock_lru/include/linux/mmzone.h       2006-07-28 
> 15:49:05.0000
> 00000 -0700
> @@ -156,10 +156,12 @@ struct zone {
>          spinlock_t              lru_lock;
>          struct list_head        active_list;
>          struct list_head        inactive_list;
> +       struct list_head        mlocked_list;
>          unsigned long           nr_scan_active;
>          unsigned long           nr_scan_inactive;
>          unsigned long           nr_active;
>          unsigned long           nr_inactive;
> +       unsigned long           nr_mlocked;
>          unsigned long           pages_scanned;     /* since last reclaim */
>          int                     all_unreclaimable; /* All pages pinned */
> 

The problem with such an approach would be that it takes O(n) time to
find that a given pages is part of the mlocked_list; so you'd still need
some marker to optimise that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
