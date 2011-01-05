Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id F02FB6B0087
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 17:11:11 -0500 (EST)
Date: Wed, 5 Jan 2011 14:10:06 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 2/2]mm: batch activate_page() to reduce lock
 contention
Message-Id: <20110105141006.22a2e9e9.akpm@linux-foundation.org>
In-Reply-To: <1294214409.1949.573.camel@sli10-conroe>
References: <1294214409.1949.573.camel@sli10-conroe>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 05 Jan 2011 16:00:09 +0800
Shaohua Li <shaohua.li@intel.com> wrote:

> The zone->lru_lock is heavily contented in workload where activate_page()
> is frequently used. We could do batch activate_page() to reduce the lock
> contention. The batched pages will be added into zone list when the pool
> is full or page reclaim is trying to drain them.
> 
> For example, in a 4 socket 64 CPU system, create a sparse file and 64 processes,
> processes shared map to the file. Each process read access the whole file and
> then exit. The process exit will do unmap_vmas() and cause a lot of
> activate_page() call. In such workload, we saw about 58% total time reduction
> with below patch. Other workloads with a lot of activate_page also benefits a
> lot too.

There still isn't much info about the performance benefit here.  Which
is a bit of a problem when the patch's sole purpose is to provide
performance benefit!

So, much more complete performance testing results would help here. 
And it's not just the "it sped up an obscure corner-case workload by
N%".  How much impact (postive or negative) does the patch have on
other workloads?

And while you're doing the performance testing, please test this
version too:

--- a/mm/swap.c~a
+++ a/mm/swap.c
@@ -261,6 +261,10 @@ void activate_page(struct page *page)
 {
 	struct zone *zone = page_zone(page);
 
+	/* Quick, racy check to avoid taking the lock */
+	if (PageActive(page) || !PageLRU(page) || PageUnevictable(page))
+		return;
+
 	spin_lock_irq(&zone->lru_lock);
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
 		int file = page_is_file_cache(page);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
