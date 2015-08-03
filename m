Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2D6ED6B0253
	for <linux-mm@kvack.org>; Mon,  3 Aug 2015 19:03:00 -0400 (EDT)
Received: by pacgq8 with SMTP id gq8so34915766pac.3
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 16:02:59 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id dk10si28973112pdb.35.2015.08.03.16.02.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Aug 2015 16:02:59 -0700 (PDT)
Received: by pawu10 with SMTP id u10so22817227paw.1
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 16:02:58 -0700 (PDT)
Date: Tue, 4 Aug 2015 08:02:49 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] vmscan: reclaim_clean_pages_from_list() must count
 mlocked pages
Message-ID: <20150803230237.GA19415@blaptop>
References: <1438597107-18329-1-git-send-email-jaewon31.kim@samsung.com>
 <20150803122509.GA29929@bgram>
 <55BF80F2.2020602@samsung.com>
 <20150803153333.GA31987@blaptop>
 <55BF8CF1.4050309@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <55BF8CF1.4050309@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaewon Kim <jaewon31.kim@samsung.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com

Hello,

On Tue, Aug 04, 2015 at 12:46:57AM +0900, Jaewon Kim wrote:
> 
> 
> On 2015e?? 08i?? 04i? 1/4  00:33, Minchan Kim wrote:
> > On Mon, Aug 03, 2015 at 11:55:46PM +0900, Jaewon Kim wrote:
> >>
> >>
> >> On 2015e?? 08i?? 03i? 1/4  21:27, Minchan Kim wrote:
> >>> Hello,
> >>>
> >>> On Mon, Aug 03, 2015 at 07:18:27PM +0900, Jaewon Kim wrote:
> >>>> reclaim_clean_pages_from_list() decreases NR_ISOLATED_FILE by returned
> >>>> value from shrink_page_list(). But mlocked pages in the isolated
> >>>> clean_pages page list would be removed from the list but not counted as
> >>>> nr_reclaimed. Fix this miscounting by returning the number of mlocked
> >>>> pages and count it.
> >>>
> >>> If there are pages not able to reclaim, VM try to migrate it and
> >>> have to handle the stat in migrate_pages.
> >>> If migrate_pages fails again, putback-fiends should handle it.
> >>>
> >>> Is there anyting I am missing now?
> >>>
> >>> Thanks.
> >>>
> >> Hello
> >>
> >> Only pages in cc->migratepages will be handled by migrate_pages or
> >> putback_movable_pages, and NR_ISOLATED_FILE will be counted properly.
> >> However mlocked pages will not be put back into cc->migratepages,
> >> and also not be counted in NR_ISOLATED_FILE because putback_lru_page
> >> in shrink_page_list does not increase NR_ISOLATED_FILE.
> >> The current reclaim_clean_pages_from_list assumes that shrink_page_list
> >> returns number of pages removed from the candidate list.
> >>
> >> i.e)
> >> isolate_migratepages_range    : NR_ISOLATED_FILE += 10
> >> reclaim_clean_pages_from_list : NR_ISOLATED_FILE -= 5 (1 mlocked page)
> >> migrate_pages                 : NR_ISOLATED_FILE -=4
> >> => NR_ISOLATED_FILE increased by 1
> > 
> > Thanks for the clarity.
> > 
> > I think the problem is shrink_page_list is awkard. It put back to
> > unevictable pages instantly instead of passing it to caller while
> > it relies on caller for non-reclaimed-non-unevictable page's putback.
> > 
> > I think we can make it consistent so that shrink_page_list could
> > return non-reclaimed pages via page_list and caller can handle it.
> > As a bonus, it could try to migrate mlocked pages without retrial.
> > 
> >>
> >> Thank you.
> 
> To make clear do you mean changing shrink_page_list like this rather than
> previous my suggestion?
> 
> @@ -1157,7 +1157,7 @@ cull_mlocked:
>                 if (PageSwapCache(page))
>                         try_to_free_swap(page);
>                 unlock_page(page);
> -               putback_lru_page(page);
> +               list_add(&page->lru, &ret_pages);
>                 continue;

Yes. That's what I said.

Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
