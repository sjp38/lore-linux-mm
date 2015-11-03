Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6C8236B0256
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 20:10:34 -0500 (EST)
Received: by pacfv9 with SMTP id fv9so2126163pac.3
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 17:10:34 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id nc3si39013886pbc.24.2015.11.02.17.10.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Nov 2015 17:10:33 -0800 (PST)
Date: Tue, 3 Nov 2015 10:10:30 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 6/8] mm: lru_deactivate_fn should clear PG_referenced
Message-ID: <20151103011030.GF17906@bbox>
References: <1446188504-28023-1-git-send-email-minchan@kernel.org>
 <1446188504-28023-7-git-send-email-minchan@kernel.org>
 <20151030124711.GB23627@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151030124711.GB23627@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, zhangyanfei@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, yalin.wang2010@gmail.com, Shaohua Li <shli@kernel.org>

On Fri, Oct 30, 2015 at 01:47:11PM +0100, Michal Hocko wrote:
> On Fri 30-10-15 16:01:42, Minchan Kim wrote:
> > deactivate_page aims for accelerate for reclaiming through
> > moving pages from active list to inactive list so we should
> > clear PG_referenced for the goal.
> 
> I might be missing something but aren't we using PG_referenced only for
> pagecache (and shmem) pages?

You don't miss anything. For pages which are candidate of MADV_FREEing(
ie, normal anonymous page, not shmem, tmpfs), they shouldn't have any
PG_referenced. Although normal anonymous pages have it, VM doesn't respect
it. One thing I suspect is GUP with FOLL_TOUCH which calls mark_page_accesssed
on anonymous page and will mark PG_referenced.
Technically, it's not a problem but just want to notice in this time.

Primary reason was I want to make deactivate_page *general* so it could
be used for file page as well as anon pages in future.
But at the moment, user of deactivate_page is only MADV_FREE so it might
be better to merge the logic for anon page deactivation into
deactivate_file_page and rename it as general "deactivate_page"
if you're thinking it's better.

> 
> > 
> > Acked-by: Hugh Dickins <hughd@google.com>
> > Suggested-by: Andrew Morton <akpm@linux-foundation.org>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  mm/swap.c | 1 +
> >  1 file changed, 1 insertion(+)
> > 
> > diff --git a/mm/swap.c b/mm/swap.c
> > index d0eacc5f62a3..4a6aec976ab1 100644
> > --- a/mm/swap.c
> > +++ b/mm/swap.c
> > @@ -810,6 +810,7 @@ static void lru_deactivate_fn(struct page *page, struct lruvec *lruvec,
> >  
> >  		del_page_from_lru_list(page, lruvec, lru + LRU_ACTIVE);
> >  		ClearPageActive(page);
> > +		ClearPageReferenced(page);
> >  		add_page_to_lru_list(page, lruvec, lru);
> >  
> >  		__count_vm_event(PGDEACTIVATE);
> > -- 
> > 1.9.1
> 
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
