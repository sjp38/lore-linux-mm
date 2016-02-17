Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 0B1AC6B0009
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 16:17:50 -0500 (EST)
Received: by mail-qg0-f45.google.com with SMTP id b67so22454856qgb.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 13:17:50 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s63si3250451qhs.29.2016.02.17.13.17.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 13:17:49 -0800 (PST)
Date: Wed, 17 Feb 2016 16:17:44 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: Unhelpful caching decisions, possibly related to
 active/inactive sizing
Message-ID: <20160217161744.6ce0b1e5@annuminas.surriel.com>
In-Reply-To: <20160212193553.6pugckvamgtk4x5q@alap3.anarazel.de>
References: <20160209165240.th5bx4adkyewnrf3@alap3.anarazel.de>
	<20160209224256.GA29872@cmpxchg.org>
	<20160211153404.42055b27@cuia.usersys.redhat.com>
	<20160212124653.35zwmy3p2pat5trv@alap3.anarazel.de>
	<20160212193553.6pugckvamgtk4x5q@alap3.anarazel.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Freund <andres@anarazel.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

On Fri, 12 Feb 2016 20:35:53 +0100
Andres Freund <andres@anarazel.de> wrote:

> On 2016-02-12 13:46:53 +0100, Andres Freund wrote:
> > I'm wondering why pages that are repeatedly written to, in units above
> > the page size, are promoted to the active list? I mean if there never
> > are any reads or re-dirtying an already-dirty page, what's the benefit
> > of moving that page onto the active list?
> 
> We chatted about this on IRC and you proposed testing this by removing
> FGP_ACCESSED in grab_cache_page_write_begin.  I ran tests with that,
> after removing the aforementioned code to issue posix_fadvise(DONTNEED)
> in postgres.

That looks promising.

> Here the active/inactive lists didn't change as much as I hoped. A bit
> of reading made it apparent that the workingset logic in
> add_to_page_cache_lru() defated that attempt,

The patch below should help with that.

Does the GFP_ACCESSED change still help with the patch
below applied?

If so, we can add the partial write logic everywhere,
and use it here, too.

---8<---

Subject: mm,workingset: only do workingset activations on reads

When rewriting a page, the data in that page is replaced with new
data. This means that evicting something else from the active file
list, in order to cache data that will be replaced by something else,
is likely to be a waste of memory.

It is better to save the active list for frequently read pages, because
reads actually use the data that is in the page.

This patch ignores partial writes, because it is unclear whether the
complexity of identifying those is worth any potential performance
gain obtained from better caching pages that see repeated partial
writes at large enough intervals to not get caught by the use-twice
promotion code used for the inactive file list.

Signed-off-by: Rik van Riel <riel@redhat.com>
Reported-by: Andres Freund <andres@anarazel.de>
---
 mm/filemap.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index bc943867d68c..1235d27b2c97 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -703,8 +703,12 @@ int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 		 * The page might have been evicted from cache only
 		 * recently, in which case it should be activated like
 		 * any other repeatedly accessed page.
+		 * The exception is pages getting rewritten; evicting other
+		 * data from the working set, only to cache data that will
+		 * get overwritten with something else, is a waste of memory.
 		 */
-		if (shadow && workingset_refault(shadow)) {
+		if (shadow && !(gfp_mask & GFP_WRITE) &&
+					workingset_refault(shadow)) {
 			SetPageActive(page);
 			workingset_activation(page);
 		} else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
