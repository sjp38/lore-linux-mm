Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id BEA176B0005
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 02:01:30 -0400 (EDT)
Received: by mail-ig0-f171.google.com with SMTP id ui10so64551229igc.1
        for <linux-mm@kvack.org>; Sun, 03 Apr 2016 23:01:30 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 26si23444442ioi.61.2016.04.03.23.01.29
        for <linux-mm@kvack.org>;
        Sun, 03 Apr 2016 23:01:30 -0700 (PDT)
Date: Mon, 4 Apr 2016 15:01:34 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 01/16] mm: use put_page to free page instead of
 putback_lru_page
Message-ID: <20160404060134.GA7555@bbox>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
 <1459321935-3655-2-git-send-email-minchan@kernel.org>
 <57020177.60006@gmail.com>
MIME-Version: 1.0
In-Reply-To: <57020177.60006@gmail.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Mon, Apr 04, 2016 at 03:53:59PM +1000, Balbir Singh wrote:
> 
> 
> On 30/03/16 18:12, Minchan Kim wrote:
> > Procedure of page migration is as follows:
> >
> > First of all, it should isolate a page from LRU and try to
> > migrate the page. If it is successful, it releases the page
> > for freeing. Otherwise, it should put the page back to LRU
> > list.
> >
> > For LRU pages, we have used putback_lru_page for both freeing
> > and putback to LRU list. It's okay because put_page is aware of
> > LRU list so if it releases last refcount of the page, it removes
> > the page from LRU list. However, It makes unnecessary operations
> > (e.g., lru_cache_add, pagevec and flags operations. It would be
> > not significant but no worth to do) and harder to support new
> > non-lru page migration because put_page isn't aware of non-lru
> > page's data structure.
> >
> > To solve the problem, we can add new hook in put_page with
> > PageMovable flags check but it can increase overhead in
> > hot path and needs new locking scheme to stabilize the flag check
> > with put_page.
> >
> > So, this patch cleans it up to divide two semantic(ie, put and putback).
> > If migration is successful, use put_page instead of putback_lru_page and
> > use putback_lru_page only on failure. That makes code more readable
> > and doesn't add overhead in put_page.
> So effectively when we return from unmap_and_move() the page is either
> put_page or putback_lru_page() and the page is gone from under us.

I didn't get your point.
Could you elaborate it more what you want to say about this patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
