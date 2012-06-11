Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 2F3A46B006C
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 20:23:36 -0400 (EDT)
Received: by dakp5 with SMTP id p5so5684269dak.14
        for <linux-mm@kvack.org>; Sun, 10 Jun 2012 17:23:35 -0700 (PDT)
Date: Mon, 11 Jun 2012 08:23:26 +0800
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: Re: [PATCH] mm: do not use page_count without a page pin
Message-ID: <20120611002325.GA2384@kernel>
Reply-To: Wanpeng Li <liwp.linux@gmail.com>
References: <1339373872-31969-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1339373872-31969-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, MelGorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, Jun 11, 2012 at 09:17:51AM +0900, Minchan Kim wrote:
>d179e84ba fixed the problem[1] in vmscan.c but same problem is here.
>Let's fix it.
>
>[1] http://comments.gmane.org/gmane.linux.kernel.mm/65844
>
>I copy and paste d179e84ba's contents for description.
>
>"It is unsafe to run page_count during the physical pfn scan because
>compound_head could trip on a dangling pointer when reading
>page->first_page if the compound page is being freed by another CPU."
>
>Cc: Andrea Arcangeli <aarcange@redhat.com>
>Cc: Mel Gorman <mgorman@suse.de>
>Cc: Michal Hocko <mhocko@suse.cz>
>Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>Signed-off-by: Minchan Kim <minchan@kernel.org>
>---
> mm/page_alloc.c |    6 +++++-
> 1 file changed, 5 insertions(+), 1 deletion(-)
>
>diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>index 266f267..019c4fe 100644
>--- a/mm/page_alloc.c
>+++ b/mm/page_alloc.c
>@@ -5496,7 +5496,11 @@ __count_immobile_pages(struct zone *zone, struct page *page, int count)
> 			continue;
> 
> 		page = pfn_to_page(check);
>-		if (!page_count(page)) {
>+		/*
>+		 * We can't use page_count withou pin a page
                                        ^
										without
>+		 * because another CPU can free compound page.
>+		 */
>+		if (!atomic_read(&page->_count)) {
> 			if (PageBuddy(page))
> 				iter += (1 << page_order(page)) - 1;
> 			continue;
>-- 
>1.7.9.5
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
