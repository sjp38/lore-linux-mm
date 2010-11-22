Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id EF1176B0071
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 17:15:25 -0500 (EST)
Date: Mon, 22 Nov 2010 14:14:49 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC 1/2] deactive invalidated pages
Message-Id: <20101122141449.9de58a2c.akpm@linux-foundation.org>
In-Reply-To: <bdd6628e81c06f6871983c971d91160fca3f8b5e.1290349672.git.minchan.kim@gmail.com>
References: <bdd6628e81c06f6871983c971d91160fca3f8b5e.1290349672.git.minchan.kim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Sun, 21 Nov 2010 23:30:23 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> Recently, there are reported problem about thrashing.
> (http://marc.info/?l=rsync&m=128885034930933&w=2)
> It happens by backup workloads(ex, nightly rsync).
> That's because the workload makes just use-once pages
> and touches pages twice. It promotes the page into
> active list so that it results in working set page eviction.
> 
> Some app developer want to support POSIX_FADV_NOREUSE.
> But other OSes don't support it, either.
> (http://marc.info/?l=linux-mm&m=128928979512086&w=2)
> 
> By Other approach, app developer uses POSIX_FADV_DONTNEED.
> But it has a problem. If kernel meets page is writing
> during invalidate_mapping_pages, it can't work.
> It is very hard for application programmer to use it.
> Because they always have to sync data before calling
> fadivse(..POSIX_FADV_DONTNEED) to make sure the pages could
> be discardable. At last, they can't use deferred write of kernel
> so that they could see performance loss.
> (http://insights.oetiker.ch/linux/fadvise.html)
> 
> In fact, invalidate is very big hint to reclaimer.
> It means we don't use the page any more. So let's move
> the writing page into inactive list's head.
> 
> If it is real working set, it could have a enough time to
> activate the page since we always try to keep many pages in
> inactive list.
> 
> I reuse lru_demote of Peter with some change.
> 
>
> ...
>
> +/*
> + * Function used to forecefully demote a page to the head of the inactive
> + * list.
> + */

This comment is wrong?  The page gets moved to the _tail_ of the
inactive list?

> +void lru_deactive_page(struct page *page)

Should be "deactivate" throughout the patch. IMO.

> +{
> +	if (likely(get_page_unless_zero(page))) {
> +		struct pagevec *pvec = &get_cpu_var(lru_deactive_pvecs);
> +
> +		if (!pagevec_add(pvec, page))
> +			__pagevec_lru_deactive(pvec);
> +		put_cpu_var(lru_deactive_pvecs);
> +	}
>  }
>  
> +
>  void lru_add_drain(void)
>  {
>  	drain_cpu_pagevecs(get_cpu());
> diff --git a/mm/truncate.c b/mm/truncate.c
> index cd94607..c73fb19 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -332,7 +332,8 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
>  {
>  	struct pagevec pvec;
>  	pgoff_t next = start;
> -	unsigned long ret = 0;
> +	unsigned long ret;
> +	unsigned long count = 0;
>  	int i;
>  
>  	pagevec_init(&pvec, 0);
> @@ -359,8 +360,10 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
>  			if (lock_failed)
>  				continue;
>  
> -			ret += invalidate_inode_page(page);
> -
> +			ret = invalidate_inode_page(page);
> +			if (!ret)
> +				lru_deactive_page(page);

This is the core part of the patch and it needs a code comment to
explain the reasons for doing this.

I wonder about the page_mapped() case.  We were unable to invalidate
the page because it was mapped into pagetables.  But was it really
appropriate to deactivate the page in that case?


> +			count += ret;
>  			unlock_page(page);
>  			if (next > end)
>  				break;

Suggested updates:


 include/linux/swap.h |    2 +-
 mm/swap.c            |   13 ++++++-------
 mm/truncate.c        |    7 ++++++-
 3 files changed, 13 insertions(+), 9 deletions(-)

diff -puN include/linux/swap.h~mm-deactivate-invalidated-pages-fix include/linux/swap.h
--- a/include/linux/swap.h~mm-deactivate-invalidated-pages-fix
+++ a/include/linux/swap.h
@@ -213,7 +213,7 @@ extern void mark_page_accessed(struct pa
 extern void lru_add_drain(void);
 extern int lru_add_drain_all(void);
 extern void rotate_reclaimable_page(struct page *page);
-extern void lru_deactive_page(struct page *page);
+extern void lru_deactivate_page(struct page *page);
 extern void swap_setup(void);
 
 extern void add_page_to_unevictable_list(struct page *page);
diff -puN mm/swap.c~mm-deactivate-invalidated-pages-fix mm/swap.c
--- a/mm/swap.c~mm-deactivate-invalidated-pages-fix
+++ a/mm/swap.c
@@ -39,7 +39,7 @@ int page_cluster;
 
 static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
 static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
-static DEFINE_PER_CPU(struct pagevec, lru_deactive_pvecs);
+static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
 
 
 /*
@@ -334,23 +334,22 @@ static void drain_cpu_pagevecs(int cpu)
 		local_irq_restore(flags);
 	}
 
-	pvec = &per_cpu(lru_deactive_pvecs, cpu);
+	pvec = &per_cpu(lru_deactivate_pvecs, cpu);
 	if (pagevec_count(pvec))
 		__pagevec_lru_deactive(pvec);
 }
 
 /*
- * Function used to forecefully demote a page to the head of the inactive
- * list.
+ * Forecfully demote a page to the tail of the inactive list.
  */
-void lru_deactive_page(struct page *page)
+void lru_deactivate_page(struct page *page)
 {
 	if (likely(get_page_unless_zero(page))) {
-		struct pagevec *pvec = &get_cpu_var(lru_deactive_pvecs);
+		struct pagevec *pvec = &get_cpu_var(lru_deactivate_pvecs);
 
 		if (!pagevec_add(pvec, page))
 			__pagevec_lru_deactive(pvec);
-		put_cpu_var(lru_deactive_pvecs);
+		put_cpu_var(lru_deactivate_pvecs);
 	}
 }
 
diff -puN mm/truncate.c~mm-deactivate-invalidated-pages-fix mm/truncate.c
--- a/mm/truncate.c~mm-deactivate-invalidated-pages-fix
+++ a/mm/truncate.c
@@ -361,8 +361,13 @@ unsigned long invalidate_mapping_pages(s
 				continue;
 
 			ret = invalidate_inode_page(page);
+			/*
+			 * If the page was dirty or under writeback we cannot
+			 * invalidate it now.  Move it to the tail of the
+			 * inactive LRU so that reclaim will free it promptly.
+			 */
 			if (!ret)
-				lru_deactive_page(page);
+				lru_deactivate_page(page);
 			count += ret;
 			unlock_page(page);
 			if (next > end)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
