Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 9D78D6B0005
	for <linux-mm@kvack.org>; Thu, 24 Mar 2016 01:10:16 -0400 (EDT)
Received: by mail-pf0-f177.google.com with SMTP id n5so48122849pfn.2
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 22:10:16 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id o68si9445940pfj.173.2016.03.23.22.10.15
        for <linux-mm@kvack.org>;
        Wed, 23 Mar 2016 22:10:15 -0700 (PDT)
Date: Thu, 24 Mar 2016 14:11:38 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Re: [PATCH v2 13/18] mm/compaction: support non-lru movable
 pagemigration
Message-ID: <20160324051138.GA14101@bbox>
References: <20160324052650.HM.e0000000006t8Yn@gurugio.wwl1662.hanmail.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160324052650.HM.e0000000006t8Yn@gurugio.wwl1662.hanmail.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gurugio@hanmail.net>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>, dri-devel@lists.freedesktop.org

On Thu, Mar 24, 2016 at 05:26:50AM +0900, Gioh Kim wrote:
>    Hmmm... But, in failure case, is it safe to call putback_lru_page() for
>    them?
>    And, PageIsolated() would be left. Is it okay? It's not symmetric that
>    isolated page can be freed by decreasing ref count without calling
>    putback function. This should be clarified and documented.
> 
>    I agree Joonsoo's idea.
> 
>    Freeing isolated page out of putback() could be confused.

If we makes such rule, subsystem cannot free the isolated pages until VM calls
putback. I don't think it's a good idea. With it, every users should make own
deferred page freeing logic which might be more error-prone and obstacle for
using this interface.

I want to make client free his pages whenever he want if possible.

> 
>    Every detail cannot be documented. And more documents mean less elegant
>    code.
> 
>    Is it possible to free isolated page in putback()?
> 
>    In move_to_new_page(), can we call a_ops->migratepage like following?
> 
>    move_to_new_page()
> 
>    {
> 
>    mapping = page_mapping(page)
> 
>    if (!mapping)
> 
>        rc = migrate_page
> 
>    else if (mapping->a_ops->migratepage && IsolatePage(page))
> 
>       rc = mapping->a_ops->migratepage
> 

It's not a problem. The problem is that a page failed migration
so VM will putback the page. But, between fail of migration and
putback of isolated page, user can free the page. In this case,
putback operation would be not called and pass the page in
putback_lru_page.


>    else
> 
>        rc = fallback_migrate_page
> 
>    ...
> 
>       return rc
> 
>    }
> 
>    I'm sorry that I couldn't review in detail because I forgot many
>    details.

You're a human being, not Alphago. :)

Thanks for the review, Gioh!

> 
>    [1][Kk8NwEH1.I.q95.FfPs-qw00]
>    [@from=gurugio&rcpt=minchan%40kernel%2Eorg&msgid=%3C20160324052650%2EHM
>    %2Ee0000000006t8Yn%40gurugio%2Ewwl1662%2Ehanmail%2Enet%3E]
> 
> References
> 
>    1. mailto:gurugio@hanmail.net

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
