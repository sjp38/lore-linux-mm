Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id D2E616B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 18:44:00 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so121258268pdb.1
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 15:44:00 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b1si11443650pat.205.2015.03.20.15.43.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Mar 2015 15:43:59 -0700 (PDT)
Date: Fri, 20 Mar 2015 15:43:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/4] mm: move lazy free pages to inactive list
Message-Id: <20150320154358.51bcf3cbceeb8fbbdb2b58e5@linux-foundation.org>
In-Reply-To: <1426036838-18154-3-git-send-email-minchan@kernel.org>
References: <1426036838-18154-1-git-send-email-minchan@kernel.org>
	<1426036838-18154-3-git-send-email-minchan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Yalin.Wang@sonymobile.com

On Wed, 11 Mar 2015 10:20:37 +0900 Minchan Kim <minchan@kernel.org> wrote:

> MADV_FREE is hint that it's okay to discard pages if there is
> memory pressure and we uses reclaimers(ie, kswapd and direct reclaim)
> to free them so there is no worth to remain them in active anonymous LRU
> so this patch moves them to inactive LRU list's head.
> 
> This means that MADV_FREE-ed pages which were living on the inactive list
> are reclaimed first because they are more likely to be cold rather than
> recently active pages.
> 
> A arguable issue for the approach would be whether we should put it to
> head or tail in inactive list. I selected *head* because kernel cannot
> make sure it's really cold or warm for every MADV_FREE usecase but
> at least we know it's not *hot* so landing of inactive head would be
> comprimise for various usecases.
> 
> This is fixing a suboptimal behavior of MADV_FREE when pages living on
> the active list will sit there for a long time even under memory
> pressure while the inactive list is reclaimed heavily. This basically
> breaks the whole purpose of using MADV_FREE to help the system to free
> memory which is might not be used.
> 
> @@ -789,6 +790,23 @@ static void lru_deactivate_file_fn(struct page *page, struct lruvec *lruvec,
>  	update_page_reclaim_stat(lruvec, file, 0);
>  }
>  
> +
> +static void lru_deactivate_fn(struct page *page, struct lruvec *lruvec,
> +			    void *arg)
>
> ...
>
> @@ -844,6 +866,18 @@ void deactivate_file_page(struct page *page)
>  	}
>  }
>  
> +void deactivate_page(struct page *page)
> +{

lru_deactivate_file_fn() and deactivate_file_page() are carefully
documented and lru_deactivate_fn() and deactivate_page() should
be as well.  In fact it becomes more important now that we have two
similar-looking things.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
