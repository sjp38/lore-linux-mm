Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 04ECD6B0005
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 01:54:14 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id zm5so136897733pac.0
        for <linux-mm@kvack.org>; Sun, 03 Apr 2016 22:54:13 -0700 (PDT)
Received: from mail-pf0-x233.google.com (mail-pf0-x233.google.com. [2607:f8b0:400e:c00::233])
        by mx.google.com with ESMTPS id i71si21712648pfi.110.2016.04.03.22.54.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Apr 2016 22:54:13 -0700 (PDT)
Received: by mail-pf0-x233.google.com with SMTP id n1so31927799pfn.2
        for <linux-mm@kvack.org>; Sun, 03 Apr 2016 22:54:13 -0700 (PDT)
Subject: Re: [PATCH v3 01/16] mm: use put_page to free page instead of
 putback_lru_page
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
 <1459321935-3655-2-git-send-email-minchan@kernel.org>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <57020177.60006@gmail.com>
Date: Mon, 4 Apr 2016 15:53:59 +1000
MIME-Version: 1.0
In-Reply-To: <1459321935-3655-2-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>



On 30/03/16 18:12, Minchan Kim wrote:
> Procedure of page migration is as follows:
>
> First of all, it should isolate a page from LRU and try to
> migrate the page. If it is successful, it releases the page
> for freeing. Otherwise, it should put the page back to LRU
> list.
>
> For LRU pages, we have used putback_lru_page for both freeing
> and putback to LRU list. It's okay because put_page is aware of
> LRU list so if it releases last refcount of the page, it removes
> the page from LRU list. However, It makes unnecessary operations
> (e.g., lru_cache_add, pagevec and flags operations. It would be
> not significant but no worth to do) and harder to support new
> non-lru page migration because put_page isn't aware of non-lru
> page's data structure.
>
> To solve the problem, we can add new hook in put_page with
> PageMovable flags check but it can increase overhead in
> hot path and needs new locking scheme to stabilize the flag check
> with put_page.
>
> So, this patch cleans it up to divide two semantic(ie, put and putback).
> If migration is successful, use put_page instead of putback_lru_page and
> use putback_lru_page only on failure. That makes code more readable
> and doesn't add overhead in put_page.
So effectively when we return from unmap_and_move() the page is either
put_page or putback_lru_page() and the page is gone from under us.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
