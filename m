Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 78E436B0037
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 04:02:34 -0500 (EST)
Received: by mail-qa0-f54.google.com with SMTP id f11so380141qae.20
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 01:02:34 -0800 (PST)
Received: from mail-vb0-x22f.google.com (mail-vb0-x22f.google.com [2607:f8b0:400c:c02::22f])
        by mx.google.com with ESMTPS id b6si14905912qak.6.2013.12.11.01.02.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Dec 2013 01:02:32 -0800 (PST)
Received: by mail-vb0-f47.google.com with SMTP id q12so1417997vbe.34
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 01:02:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALZtONCW1Gxa-aT25Yf7PP6R=sW_6KBu5XPKoU75pJgvmAknbg@mail.gmail.com>
References: <1384976973-32722-1-git-send-email-ddstreet@ieee.org>
	<20131122172916.GB6477@cerebellum.variantweb.net>
	<20131125180030.GA23396@cerebellum.variantweb.net>
	<CALZtONCW1Gxa-aT25Yf7PP6R=sW_6KBu5XPKoU75pJgvmAknbg@mail.gmail.com>
Date: Wed, 11 Dec 2013 17:02:31 +0800
Message-ID: <CAA_GA1ee1z6FKBj8TqEG64JoZNaPNTyVE918Kv8b1KY2k0CBEg@mail.gmail.com>
Subject: Re: [PATCH v2] mm/zswap: change zswap to writethrough cache
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>

Hi Dan & Seth,

On Wed, Nov 27, 2013 at 9:28 AM, Dan Streetman <ddstreet@ieee.org> wrote:
> On Mon, Nov 25, 2013 at 1:00 PM, Seth Jennings <sjennings@variantweb.net> wrote:
>> On Fri, Nov 22, 2013 at 11:29:16AM -0600, Seth Jennings wrote:
>>> On Wed, Nov 20, 2013 at 02:49:33PM -0500, Dan Streetman wrote:
>>> > Currently, zswap is writeback cache; stored pages are not sent
>>> > to swap disk, and when zswap wants to evict old pages it must
>>> > first write them back to swap cache/disk manually.  This avoids
>>> > swap out disk I/O up front, but only moves that disk I/O to
>>> > the writeback case (for pages that are evicted), and adds the
>>> > overhead of having to uncompress the evicted pages, and adds the
>>> > need for an additional free page (to store the uncompressed page)
>>> > at a time of likely high memory pressure.  Additionally, being
>>> > writeback adds complexity to zswap by having to perform the
>>> > writeback on page eviction.
>>> >
>>> > This changes zswap to writethrough cache by enabling
>>> > frontswap_writethrough() before registering, so that any
>>> > successful page store will also be written to swap disk.  All the
>>> > writeback code is removed since it is no longer needed, and the
>>> > only operation during a page eviction is now to remove the entry
>>> > from the tree and free it.
>>>
>>> I like it.  It gets rid of a lot of nasty writeback code in zswap.
>>>
>>> I'll have to test before I ack, hopefully by the end of the day.
>>>
>>> Yes, this will increase writes to the swap device over the delayed
>>> writeback approach.  I think it is a good thing though.  I think it
>>> makes the difference between zswap and zram, both in operation and in
>>> application, more apparent. Zram is the better choice for embedded where
>>> write wear is a concern, and zswap being better if you need more
>>> flexibility to dynamically manage the compressed pool.
>>
>> One thing I realized while doing my testing was that making zswap
>> writethrough also impacts synchronous reclaim.  Zswap, as it is now,
>> makes the swapcache page clean during swap_writepage() which allows
>> shrink_page_list() to immediately reclaim it.  Making zswap writethrough
>> eliminates this advantage and swapcache pages must be scanned again
>> before they can be reclaimed, as is the case with normal swapping.
>
> Yep, I thought about that as well, and it is true, but only while
> zswap is not full.  With writeback, once zswap fills up, page stores
> will frequently have to reclaim pages by writing compressed pages to
> disk.  With writethrough, the zbud reclaim should be quick, as it only
> has to evict the pages, not write them to disk.  So I think basically
> writeback should speed up (compared to no-zswap case) swap_writepage()
> while zswap is not full, but (theoretically) slow it down (compared to
> no-zswap case) while zswap is full, while writethrough should slow
> down swap_writepage() slightly (the time it takes to compress/store
> the page) but consistently, almost the same amount before it's full vs
> when it's full.  Theoretically :-)  Definitely something to think
> about and test for.
>

Have you gotten any further benchmark result?

-- 
Thanks,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
