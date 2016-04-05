Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id C84366B027D
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 23:10:52 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id fe3so995022pab.1
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 20:10:52 -0700 (PDT)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id 67si45823630pfh.155.2016.04.04.20.10.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Apr 2016 20:10:51 -0700 (PDT)
Received: by mail-pf0-x22b.google.com with SMTP id c20so1014837pfc.1
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 20:10:51 -0700 (PDT)
Subject: Re: [PATCH v3 01/16] mm: use put_page to free page instead of
 putback_lru_page
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
 <1459321935-3655-2-git-send-email-minchan@kernel.org>
 <57020177.60006@gmail.com> <20160404060134.GA7555@bbox>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <57032CAE.10404@gmail.com>
Date: Tue, 5 Apr 2016 13:10:38 +1000
MIME-Version: 1.0
In-Reply-To: <20160404060134.GA7555@bbox>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>



On 04/04/16 16:01, Minchan Kim wrote:
> On Mon, Apr 04, 2016 at 03:53:59PM +1000, Balbir Singh wrote:
>>
>> On 30/03/16 18:12, Minchan Kim wrote:
>>> Procedure of page migration is as follows:
>>>
>>> First of all, it should isolate a page from LRU and try to
>>> migrate the page. If it is successful, it releases the page
>>> for freeing. Otherwise, it should put the page back to LRU
>>> list.
>>>
>>> For LRU pages, we have used putback_lru_page for both freeing
>>> and putback to LRU list. It's okay because put_page is aware of
>>> LRU list so if it releases last refcount of the page, it removes
>>> the page from LRU list. However, It makes unnecessary operations
>>> (e.g., lru_cache_add, pagevec and flags operations. It would be
>>> not significant but no worth to do) and harder to support new
>>> non-lru page migration because put_page isn't aware of non-lru
>>> page's data structure.
>>>
>>> To solve the problem, we can add new hook in put_page with
>>> PageMovable flags check but it can increase overhead in
>>> hot path and needs new locking scheme to stabilize the flag check
>>> with put_page.
>>>
>>> So, this patch cleans it up to divide two semantic(ie, put and putback).
>>> If migration is successful, use put_page instead of putback_lru_page and
>>> use putback_lru_page only on failure. That makes code more readable
>>> and doesn't add overhead in put_page.
>> So effectively when we return from unmap_and_move() the page is either
>> put_page or putback_lru_page() and the page is gone from under us.
> I didn't get your point.
> Could you elaborate it more what you want to say about this patch?

I was just adding to my understanding of this change based on your changelog.
My understanding is that we take the extra reference in isolate_lru_page()
but by the time we return from unmap_and_move() we drop the extra reference

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
