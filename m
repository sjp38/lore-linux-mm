Message-ID: <493D82A6.9070104@redhat.com>
Date: Mon, 08 Dec 2008 15:25:10 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: skip freeing memory from zones with lots free
References: <20081129195357.813D.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081208205842.53F8.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081208220016.53FB.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20081208220016.53FB.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:

> +	for (o = order; o < MAX_ORDER; o++) {
> +		if (z->free_area[o].nr_free)
> +			return 1;

Since page breakup and coalescing always manipulates .nr_free,
I wonder if it would make sense to pack the nr_free variables
in their own cache line(s), so we have fewer cache misses when
going through zone_watermark_ok() ?

That would end up looking something like this:

(whitespace mangled because it doesn't make sense to apply
just this thing, anyway)

Index: linux-2.6.28-rc7/include/linux/mmzone.h
===================================================================
--- linux-2.6.28-rc7.orig/include/linux/mmzone.h        2008-12-02 
15:04:33.000000000 -0500
+++ linux-2.6.28-rc7/include/linux/mmzone.h     2008-12-08 
15:24:25.000000000 -0500
@@ -58,7 +58,6 @@ static inline int get_pageblock_migratet

  struct free_area {
         struct list_head        free_list[MIGRATE_TYPES];
-       unsigned long           nr_free;
  };

  struct pglist_data;
@@ -296,6 +295,7 @@ struct zone {
         seqlock_t               span_seqlock;
  #endif
         struct free_area        free_area[MAX_ORDER];
+       struct nr_free          [MAX_ORDER];

  #ifndef CONFIG_SPARSEMEM
         /*


-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
