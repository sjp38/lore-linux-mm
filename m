Message-ID: <405699C1.7010906@cyberone.com.au>
Date: Tue, 16 Mar 2004 17:08:01 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] RSS limit enforcement for 2.6
References: <Pine.LNX.4.44.0403151816350.12895-100000@chimarrao.boston.redhat.com>
In-Reply-To: <Pine.LNX.4.44.0403151816350.12895-100000@chimarrao.boston.redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Pavel Machek <pavel@ucw.cz>
List-ID: <linux-mm.kvack.org>


Rik van Riel wrote:

>Hi,
>
>Hugh Dickins found a bug in the 2.4-rmap RSS limit enforcing
>code that may well explain why the previous port of the code
>to 2.6 resulted in bad performance.  The split active lists
>in 2.4-rmap probably masked the largest damages, but in 2.6
>it was very much visible.
>
>

Hi Rik,
What was the problem by the way?

>The patch below should work.  Pavel, Nick, still interested
>in testing the performance ? ;)
>

I could do that.

>@@ -593,6 +594,7 @@
> 	long mapped_ratio;
> 	long distress;
> 	long swap_tendency;
>+	int over_rsslimit;
> 
> 	lru_add_drain();
> 	pgmoved = 0;
>@@ -657,7 +659,7 @@
> 				continue;
> 			}
> 			pte_chain_lock(page);
>-			if (page_referenced(page)) {
>+			if (page_referenced(page, &over_rsslimit) && !over_rsslimit) {
> 				pte_chain_unlock(page);
> 				list_add(&page->lru, &l_active);
> 				continue;
>

This still has a problem that !reclaim_mapped scans will not
shrink a runaway process before putting a lot of pressure on
the rest of the pagecache.

You could do a page_gather_pte_info type thing that doesn't
actually clear all the referenced bits (would probably
SetPageReferenced). Unfortunately this has the downside that
you also need to walk the pte chains for all mapped pages even
in the !reclaim_mapped case.

But it is a good start. We advertise the functionality, so we
should be trying to do something with rss limits.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
