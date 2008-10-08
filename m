From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: vmscan-give-referenced-active-and-unmapped-pages-a-second-trip-around-the-lru.patch
Date: Wed, 8 Oct 2008 16:55:06 +1100
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200810081655.06698.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Morton, Andrew" <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch, like I said when it was first merged, has the problem that
it can cause large stalls when reclaiming pages.

I actually myself tried a similar thing a long time ago. The problem is
that after a long period of no reclaiming, your file pages can all end
up being active and referenced. When the first guy wants to reclaim a
page, it might have to scan through gigabytes of file pages before being
able to reclaim a single one.

While it would be really nice to be able to just lazily set PageReferenced
and nothing else in mark_page_accessed, and then do file page aging based
on the referenced bit, the fact is that we virtually have O(1) reclaim
for file pages now, and this can make it much more like O(n) (in worst case,
especially).

I don't think it is right to say "we broke aging and this patch fixes it".
It's all a big crazy heuristic. Who's to say that the previous behaviour
wasn't better and this patch breaks it? :)

Anyway, I don't think it is exactly productive to keep patches like this in
the tree (that doesn't seem ever intended to be merged) while there are
other big changes to reclaim there.

Same for vm-dont-run-touch_buffer-during-buffercache-lookups.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
