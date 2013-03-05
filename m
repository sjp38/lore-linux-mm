Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id CB3B16B0002
	for <linux-mm@kvack.org>; Mon,  4 Mar 2013 20:51:23 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id dr13so4786986wgb.2
        for <linux-mm@kvack.org>; Mon, 04 Mar 2013 17:51:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20130304150937.GB23767@cmpxchg.org>
References: <CAFNq8R7tq9kvD9LyhZJ-Cj0kexQfDsPhB4iQYyZ9s9+8Jo82QA@mail.gmail.com>
	<20130304150937.GB23767@cmpxchg.org>
Date: Tue, 5 Mar 2013 09:51:21 +0800
Message-ID: <CAFNq8R4CimMgGry8P_NXM2zBcd3o_HpX4AWpq+Cxn8+=A2T86Q@mail.gmail.com>
Subject: Re: [PATCH] mm: Fixup the condition whether the page cache is free
From: Li Haifeng <omycle@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, open list <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org

Thanks very much for you explanation. :-)

2013/3/4 Johannes Weiner <hannes@cmpxchg.org>:
> On Mon, Mar 04, 2013 at 09:54:26AM +0800, Li Haifeng wrote:
>> When a page cache is to reclaim, we should to decide whether the page
>> cache is free.
>> IMO, the condition whether a page cache is free should be 3 in page
>> frame reclaiming. The reason lists as below.
>>
>> When page is allocated, the page->_count is 1(code fragment is code-1 ).
>> And when the page is allocated for reading files from extern disk, the
>> page->_count will increment 1 by page_cache_get() in
>> add_to_page_cache_locked()(code fragment is code-2). When the page is to
>> reclaim, the isolated LRU list also increase the page->_count(code
>> fragment is code-3).
>
> The page count is initialized to 1, but that does not stay with the
> object.  It's a reference that is passed to the allocating task, which
> drops it again when it's done with the page.  I.e. the pattern is like
> this:
>
> instantiation:
> page = page_cache_alloc()       /* instantiator reference -> 1 */
> add_to_page_cache(page, mapping, offset)
>   get_page(page)                /* page cache reference -> 2 */
> lru_cache_add(page)
>   get_page(page)                /* pagevec reference -> 3 */
> /* ...initiate read, write, associate buffers, ... */
> page_cache_release(page)        /* drop instantiator reference -> 2 + private */
>
> reclaim:
> lru_add_drain()
>   page_cache_release(page)      /* drop pagevec reference -> 1 + private */
> __isolate_lru_page(page)
>   page_cache_get(page)          /* reclaim reference -> 2 + private */
> is_page_cache_freeable(page)
> try_to_free_buffers()           /* drop buffer ref -> 2 */
> __remove_mapping()              /* drop page cache and isolator ref -> 0 */
> free_hot_cold_page()

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
