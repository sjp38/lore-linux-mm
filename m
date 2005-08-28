Date: Sat, 27 Aug 2005 21:25:19 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [RFC][PATCH 0/6] CART Implementation
Message-ID: <20050828002519.GA26764@dmt.cnet>
References: <20050827215756.726585000@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050827215756.726585000@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Peter,

On Sat, Aug 27, 2005 at 11:57:56PM +0200, a.p.zijlstra@chello.nl wrote:
> Hi All,
> 
> (now split as per request)
> 
> After another day of hard work I feel I have this CART implementation
> complete.
> 
> It survives a pounding and the stats seem pretty stable.
> 
> The things that need more work:
>  1) the hash function seems pretty lousy
>  2) __cart_remember() called from shrink_list() needs zone->lru_lock
> 
> The whole non-resident code is based on the idea that the hash function
> gives an even spread so that:
> 
>  B1_j     B1
> ------ ~ ---- 
>  B2_j     B2
> 
> However after a pounding the variance in (B1_j - B2_j) as given by the
> std. deviation: sqrt(<x^2> - <x>^2) is around 10. And this for a bucket
> with 57 slots.
> 
> The other issue is that __cart_remember() needs the zone->lru_lock. This
> function is called from shrink_list() where the lock is explicitly
> avoided, so this seems like an issue. Alternatives would be atomic_t for
> zone->nr_q or a per cpu counter delta. Suggestions? 
>
> Also I made quite some changes in swap.c and vmscan.c without being an
> expert on the code. Did I foul up too bad?
> 
> Then ofcourse I need to benchmark, suggestions?
> 
> Some of this code is shamelessly copied from Rik van Riel, other parts 
> are inspired by code from Rahul Iyer. 
> 
> Any comments appreciated.

+/* This function selects the candidate and returns the corresponding
+ * struct page * or returns NULL in case no page can be freed.
+ */
+struct page *__cart_replace(struct zone *zone)
+{
+	struct page *page;
+	int referenced;
+
+	while (!list_empty(list_T2)) {
+		page = list_entry(list_T2->next, struct page, lru);
+
+		if (!page_referenced(page, 0, 0))
+			break;
+
+		del_page_from_inactive_list(zone, page);
+		add_page_to_active_tail(zone, page);
+		SetPageActive(page);
+
+		cart_q_inc(zone);
+	}

If you find an unreferenced page in the T2 list you don't keep a reference 
to it performing a search on the T1 list below? That looks bogus.

Apart from that, both while (!list_empty(list_T2)) are problematic. If there
are tons of referenced pages you simply loop, unlimited? And what about 
the lru lock required for dealing with page->lru ?

Look at the original algorithm: it grabs SWAP_CLUSTER_MAX pages from the inactive
list, puts them into a CPU local list (on the stack), releases the lru lock, 
and works on the isolated pages. You want something similar.

As for testing, STP is really easy: 

http://www.osdl.org/lab_activities/kernel_testing/stp

+
+	while (!list_empty(list_T1)) {
+		page = list_entry(list_T1->next, struct page, lru);
+		referenced = page_referenced(page, 0, 0);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
