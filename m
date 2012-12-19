Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 175246B0078
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 18:27:38 -0500 (EST)
Date: Wed, 19 Dec 2012 15:27:36 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] CMA: call to putback_lru_pages
Message-Id: <20121219152736.1daa3d58.akpm@linux-foundation.org>
In-Reply-To: <xa1tlicwiagh.fsf@mina86.com>
References: <1355779504-30798-1-git-send-email-srinivas.pandruvada@linux.intel.com>
	<xa1tlicwiagh.fsf@mina86.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Srinivas Pandruvada <srinivas.pandruvada@linux.intel.com>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org

On Mon, 17 Dec 2012 23:24:14 +0100
Michal Nazarewicz <mina86@mina86.com> wrote:

> [+marek]
> 
> On Mon, Dec 17 2012, Srinivas Pandruvada wrote:
> > As per documentation and other places calling putback_lru_pages,
> > on error only, except for CMA. I am not sure this is a problem
> > for CMA or not.
> 
> If ret >= 0 than the list is empty anyway so the effect of this patch is
> to save a function call.  It's also true that other callers call it only
> on error so __alloc_contig_migrate_range() is an odd man out here.  As
> such:
> 
> Acked-by: Michal Nazarewicz <mina86@mina86.com>

__alloc_contig_migrate_range() is a bit twisty.  How does this look?

From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm/page_alloc.c:__alloc_contig_migrate_range(): cleanup

- `ret' is always zero in the we-timed-out case

- remove a test-n-branch in the wrapup code

Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/page_alloc.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff -puN mm/page_alloc.c~mm-page_allocc-__alloc_contig_migrate_range-cleanup mm/page_alloc.c
--- a/mm/page_alloc.c~mm-page_allocc-__alloc_contig_migrate_range-cleanup
+++ a/mm/page_alloc.c
@@ -5804,7 +5804,6 @@ static int __alloc_contig_migrate_range(
 			}
 			tries = 0;
 		} else if (++tries == 5) {
-			ret = ret < 0 ? ret : -EBUSY;
 			break;
 		}
 
@@ -5817,9 +5816,11 @@ static int __alloc_contig_migrate_range(
 				    0, false, MIGRATE_SYNC,
 				    MR_CMA);
 	}
-	if (ret < 0)
+	if (ret < 0) {
 		putback_movable_pages(&cc->migratepages);
-	return ret > 0 ? 0 : ret;
+		return ret;
+	}
+	return 0;
 }
 
 /**
_


Also, what's happening here?

			pfn = isolate_migratepages_range(cc->zone, cc,
							 pfn, end, true);
			if (!pfn) {
				ret = -EINTR;
				break;
			}

The isolate_migratepages_range() return value is undocumented and
appears to make no sense.  It returns zero if fatal_signal_pending()
and if too_many_isolated&&!cc->sync.  Returning -EINTR in the latter
case is daft.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
