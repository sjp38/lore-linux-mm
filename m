Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C9DD56B004A
	for <linux-mm@kvack.org>; Fri,  3 Jun 2011 11:46:07 -0400 (EDT)
Date: Fri, 3 Jun 2011 17:45:54 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: compaction: Abort compaction if too many pages are
 isolated and caller is asynchronous
Message-ID: <20110603154554.GK2802@random.random>
References: <20110601175809.GB7306@suse.de>
 <20110601191529.GY19505@random.random>
 <20110601214018.GC7306@suse.de>
 <20110601233036.GZ19505@random.random>
 <20110602010352.GD7306@suse.de>
 <20110602132954.GC19505@random.random>
 <20110602145019.GG7306@suse.de>
 <20110602153754.GF19505@random.random>
 <20110603020920.GA26753@suse.de>
 <20110603144941.GI7306@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110603144941.GI7306@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan.kim@gmail.com>, akpm@linux-foundation.org, Ury Stankevich <urykhy@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org

On Fri, Jun 03, 2011 at 03:49:41PM +0100, Mel Gorman wrote:
> Right idea of the wrong zone being accounted for but wrong place. I
> think the following patch should fix the problem;

Looks good thanks.

I also found this bug during my debugging that made NR_SHMEM underflow.

===
Subject: migrate: don't account swapcache as shmem

From: Andrea Arcangeli <aarcange@redhat.com>

swapcache will reach the below code path in migrate_page_move_mapping,
and swapcache is accounted as NR_FILE_PAGES but it's not accounted as
NR_SHMEM.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/migrate.c b/mm/migrate.c
index e4a5c91..2597a27 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -288,7 +288,7 @@ static int migrate_page_move_mapping(struct address_space *mapping,
 	 */
 	__dec_zone_page_state(page, NR_FILE_PAGES);
 	__inc_zone_page_state(newpage, NR_FILE_PAGES);
-	if (PageSwapBacked(page)) {
+	if (mapping != &swapper_space && PageSwapBacked(page)) {
 		__dec_zone_page_state(page, NR_SHMEM);
 		__inc_zone_page_state(newpage, NR_SHMEM);
 	}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
