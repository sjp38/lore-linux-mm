Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 49B576B0005
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 04:48:39 -0400 (EDT)
Received: by mail-wm0-f41.google.com with SMTP id n186so96589818wmn.1
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 01:48:39 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y4si17287379wme.87.2016.03.14.01.48.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 14 Mar 2016 01:48:38 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH v1 01/19] mm: use put_page to free page instead of
 putback_lru_page
References: <1457681423-26664-1-git-send-email-minchan@kernel.org>
 <1457681423-26664-2-git-send-email-minchan@kernel.org>
Message-ID: <56E67AE1.60700@suse.cz>
Date: Mon, 14 Mar 2016 09:48:33 +0100
MIME-Version: 1.0
In-Reply-To: <1457681423-26664-2-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, jlayton@poochiereds.net, bfields@fieldses.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, rknize@motorola.com, Rik van Riel <riel@redhat.com>, Gioh Kim <gurugio@hanmail.net>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On 03/11/2016 08:30 AM, Minchan Kim wrote:
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
> (e.g., lru_cache_add, pagevec and flags operations.

Yeah, and compaction (perhaps also other migration users) has to drain 
the lru pvec... Getting rid of this stuff is worth even by itself.

> It would be
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

I had an idea of checking for count==1 in putback_lru_page() which would 
take the put_page() shortcut from there. But maybe it can't be done 
nicely without races.

> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Note in -next/after 4.6-rc1 this will need some rebasing though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
