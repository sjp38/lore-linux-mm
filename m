Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f44.google.com (mail-qa0-f44.google.com [209.85.216.44])
	by kanga.kvack.org (Postfix) with ESMTP id 885C26B0092
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 13:37:39 -0500 (EST)
Received: by mail-qa0-f44.google.com with SMTP id i13so825239qae.17
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 10:37:39 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id x7si3549663qat.121.2013.12.06.10.37.35
        for <linux-mm@kvack.org>;
        Fri, 06 Dec 2013 10:37:37 -0800 (PST)
Date: Fri, 06 Dec 2013 13:37:26 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1386355046-jja39cg0-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <52A1E248.1000204@suse.cz>
References: <1386319310-28016-1-git-send-email-iamjoonsoo.kim@lge.com>
 <52A1E248.1000204@suse.cz>
Subject: Re: [PATCH 1/4] mm/migrate: correct return value of migrate_pages()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Dec 06, 2013 at 03:42:16PM +0100, Vlastimil Babka wrote:
> On 12/06/2013 09:41 AM, Joonsoo Kim wrote:
> >migrate_pages() should return number of pages not migrated or error code.
> >When unmap_and_move return -EAGAIN, outer loop is re-execution without
> >initialising nr_failed. This makes nr_failed over-counted.
> >
> >So this patch correct it by initialising nr_failed in outer loop.
> >
> >Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >
> >diff --git a/mm/migrate.c b/mm/migrate.c
> >index 3747fcd..1f59ccc 100644
> >--- a/mm/migrate.c
> >+++ b/mm/migrate.c
> >@@ -1102,6 +1102,7 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
> >
> >  	for(pass = 0; pass < 10 && retry; pass++) {
> >  		retry = 0;
> >+		nr_failed = 0;
> >
> >  		list_for_each_entry_safe(page, page2, from, lru) {
> >  			cond_resched();
> >
> 
> If I'm reading the code correctly, unmap_and_move() (and
> unmap_and_move_huge_page() as well) deletes all pages from the
> 'from' list, unless it fails with -EAGAIN. So the only pages you see
> in subsequent passes are those that failed with -EAGAIN and those
> are not counted as nr_failed. So there shouldn't be over-count, but
> your patch could result in under-count.
> 
> Perhaps a comment somewhere would clarify this.

I agree and suggest the one below.
Joonsoo, feel free to append it to your series:)

Thanks,
Naoya Horiguchi
---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date: Fri, 6 Dec 2013 13:08:15 -0500
Subject: [PATCH] migrate: add comment about permanent failure path

Let's add a comment about where the failed page goes to, which makes
code more readable.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/migrate.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 661ff5f66591..c01caafa0a6f 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1118,7 +1118,12 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 				nr_succeeded++;
 				break;
 			default:
-				/* Permanent failure */
+				/*
+				 * Permanent failure (-EBUSY, -ENOSYS, etc.):
+				 * unlike -EAGAIN case, the failed page is
+				 * removed from migration page list and not
+				 * retried in the next outer loop.
+				 */
 				nr_failed++;
 				break;
 			}
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
