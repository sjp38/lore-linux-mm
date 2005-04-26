Date: Mon, 25 Apr 2005 21:29:11 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH]: VM 8/8 shrink_list(): set PG_reclaimed
Message-Id: <20050425212911.31cf6b43.akpm@osdl.org>
In-Reply-To: <16994.40728.397980.431164@gargle.gargle.HOWL>
References: <16994.40728.397980.431164@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nikita Danilov <nikita@clusterfs.com> wrote:
>
> 
> set PG_reclaimed bit on pages that are under writeback when shrink_list()
> looks at them: these pages are at end of the inactive list, and it only makes
> sense to reclaim them as soon as possible when writeout finishes.
> 

Makes sense, I guess.  It would be nice to know how many pages actually get
this treatment, and under what situations.

To address the race which Nick identified I think we can do it this way?

--- 25/mm/vmscan.c~mm-shrink_list-set-pg_reclaimed	2005-04-25 21:26:28.853691816 -0700
+++ 25-akpm/mm/vmscan.c	2005-04-25 21:27:28.180672744 -0700
@@ -401,8 +401,18 @@ static int shrink_list(struct list_head 
 		if (page_mapped(page) || PageSwapCache(page))
 			sc->nr_scanned++;
 
-		if (PageWriteback(page))
+		if (PageWriteback(page)) {
+			if (!PageReclaim(page)) {
+				SetPageReclaim(page);
+				if (!PageWriteback(page)) {
+					/*
+					 * oops, the writeout just completed.
+					 */
+					ClearPageReclaim(page);
+				}
+			}
 			goto keep_locked;
+		}
 
 		referenced = page_referenced(page, 1, sc->priority <= 0);
 		/* In active use or really unfreeable?  Activate it. */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
