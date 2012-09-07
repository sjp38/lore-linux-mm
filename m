Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 81EFB6B0062
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 04:15:39 -0400 (EDT)
Date: Fri, 7 Sep 2012 17:17:18 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/2] mm: support MIGRATE_DISCARD
Message-ID: <20120907081718.GA31784@bbox>
References: <1346832673-12512-1-git-send-email-minchan@kernel.org>
 <1346832673-12512-2-git-send-email-minchan@kernel.org>
 <20120905105611.GI11266@suse.de>
 <20120906053112.GA16231@bbox>
 <20120906082935.GN11266@suse.de>
 <20120906090325.GO11266@suse.de>
 <20120907022434.GG16231@bbox>
 <CAH9JG2VOoA30q+3sjC4UbNFNv2Vn9KnPNNXRb+kYMKWXKHbPew@mail.gmail.com>
 <CAH9JG2XozEBOah1BsaowbU=j3SE35wZVXkDjZhK7GLUzcTbfEA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAH9JG2XozEBOah1BsaowbU=j3SE35wZVXkDjZhK7GLUzcTbfEA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyungmin Park <kmpark@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Rik van Riel <riel@redhat.com>

Hi Kyungmin,

On Fri, Sep 07, 2012 at 04:31:17PM +0900, Kyungmin Park wrote:
> On 9/7/12, Kyungmin Park <kmpark@infradead.org> wrote:
> > Hi Minchan,
> >
> > I tested Mel patch again with ClearPageActive(page). but after some
> > testing, it's stall and can't return from
> > reclaim_clean_pages_from_list(&cc.migratepages).
> >
> > Maybe it's related with unmap feature from yours?
> > stall is not happened from your codes until now.
> >
> > I'll test it more and report any issue if happened.
> Updated. it's hang also. there are other issues.

It was silly mistake in my patch and I suspect it fixes your issue
because I guess you already tried below patch when you compiled and saw
warning message.
Anyway, if you see hang still after applying below patch,
please enable CONFIG_DEBUG_VM and retest, if you find something, report it.
I hope CONFIG_DEBUG_VM catch something.

Thanks.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6668115..51d3f66 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5705,7 +5705,7 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned
                        break;
                }
 
-               reclaim_clean_pages_from_list(&cc.migratepages, cc.zone);
+               reclaim_clean_pages_from_list(cc.zone, &cc.migratepages);
 
                ret = migrate_pages(&cc.migratepages,
                                    __alloc_contig_migrate_alloc,
(END)


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
