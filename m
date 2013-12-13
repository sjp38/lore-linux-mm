Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4478A6B0035
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 21:59:12 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id bz8so471843wib.17
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 18:59:11 -0800 (PST)
Received: from mail-wi0-x233.google.com (mail-wi0-x233.google.com [2a00:1450:400c:c05::233])
        by mx.google.com with ESMTPS id p3si451965wia.87.2013.12.12.18.59.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Dec 2013 18:59:11 -0800 (PST)
Received: by mail-wi0-f179.google.com with SMTP id z2so475587wiv.12
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 18:59:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAA_GA1ee1z6FKBj8TqEG64JoZNaPNTyVE918Kv8b1KY2k0CBEg@mail.gmail.com>
References: <1384976973-32722-1-git-send-email-ddstreet@ieee.org>
 <20131122172916.GB6477@cerebellum.variantweb.net> <20131125180030.GA23396@cerebellum.variantweb.net>
 <CALZtONCW1Gxa-aT25Yf7PP6R=sW_6KBu5XPKoU75pJgvmAknbg@mail.gmail.com> <CAA_GA1ee1z6FKBj8TqEG64JoZNaPNTyVE918Kv8b1KY2k0CBEg@mail.gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Thu, 12 Dec 2013 21:58:51 -0500
Message-ID: <CALZtONCnpo=2+SDp0_NhsEdN3A+vHNOTrpRo55WhC8V1p+pOig@mail.gmail.com>
Subject: Re: [PATCH v2] mm/zswap: change zswap to writethrough cache
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Seth Jennings <sjennings@variantweb.net>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>

On Wed, Dec 11, 2013 at 4:02 AM, Bob Liu <lliubbo@gmail.com> wrote:
> Hi Dan & Seth,
>
> On Wed, Nov 27, 2013 at 9:28 AM, Dan Streetman <ddstreet@ieee.org> wrote:
>> On Mon, Nov 25, 2013 at 1:00 PM, Seth Jennings <sjennings@variantweb.net> wrote:
>>> On Fri, Nov 22, 2013 at 11:29:16AM -0600, Seth Jennings wrote:
>>>> On Wed, Nov 20, 2013 at 02:49:33PM -0500, Dan Streetman wrote:
>>>> > Currently, zswap is writeback cache; stored pages are not sent
>>>> > to swap disk, and when zswap wants to evict old pages it must
>>>> > first write them back to swap cache/disk manually.  This avoids
>>>> > swap out disk I/O up front, but only moves that disk I/O to
>>>> > the writeback case (for pages that are evicted), and adds the
>>>> > overhead of having to uncompress the evicted pages, and adds the
>>>> > need for an additional free page (to store the uncompressed page)
>>>> > at a time of likely high memory pressure.  Additionally, being
>>>> > writeback adds complexity to zswap by having to perform the
>>>> > writeback on page eviction.
>>>> >
>>>> > This changes zswap to writethrough cache by enabling
>>>> > frontswap_writethrough() before registering, so that any
>>>> > successful page store will also be written to swap disk.  All the
>>>> > writeback code is removed since it is no longer needed, and the
>>>> > only operation during a page eviction is now to remove the entry
>>>> > from the tree and free it.
>>>>
>>>> I like it.  It gets rid of a lot of nasty writeback code in zswap.
>>>>
>>>> I'll have to test before I ack, hopefully by the end of the day.
>>>>
>>>> Yes, this will increase writes to the swap device over the delayed
>>>> writeback approach.  I think it is a good thing though.  I think it
>>>> makes the difference between zswap and zram, both in operation and in
>>>> application, more apparent. Zram is the better choice for embedded where
>>>> write wear is a concern, and zswap being better if you need more
>>>> flexibility to dynamically manage the compressed pool.
>>>
>>> One thing I realized while doing my testing was that making zswap
>>> writethrough also impacts synchronous reclaim.  Zswap, as it is now,
>>> makes the swapcache page clean during swap_writepage() which allows
>>> shrink_page_list() to immediately reclaim it.  Making zswap writethrough
>>> eliminates this advantage and swapcache pages must be scanned again
>>> before they can be reclaimed, as is the case with normal swapping.
>>
>> Yep, I thought about that as well, and it is true, but only while
>> zswap is not full.  With writeback, once zswap fills up, page stores
>> will frequently have to reclaim pages by writing compressed pages to
>> disk.  With writethrough, the zbud reclaim should be quick, as it only
>> has to evict the pages, not write them to disk.  So I think basically
>> writeback should speed up (compared to no-zswap case) swap_writepage()
>> while zswap is not full, but (theoretically) slow it down (compared to
>> no-zswap case) while zswap is full, while writethrough should slow
>> down swap_writepage() slightly (the time it takes to compress/store
>> the page) but consistently, almost the same amount before it's full vs
>> when it's full.  Theoretically :-)  Definitely something to think
>> about and test for.
>>
>
> Have you gotten any further benchmark result?

Yes, and sorry for the delay.

The initial numbers I got on a relatively low-end (laptop) system seem
to indicate that writethrough does reduce performance in the beginning
when zswap isn't full, but also improves performance once zswap fills
up.  I'm working on getting a higher-end server class system set up to
test as well, and getting a larger sample size of test runs (but
specjbb takes quite a long time each run).

At this point, I'm thinking that based on those results and Weijie's
suggestion to make it configurable, it probably is better to keep the
writeback code and allow selection of writeback or writethrough.  That
would allow *possibly* changing from writeback to writethrough based
on how full zswap is; but also at the least it would allow users to
select which to use.  I still think keeping both makes zswap more
complex, but moving completely to writethrough may not be best for all
situations.  I suspect that especially systems with relatively slow
disc I/O and fast processors would benefit from writeback, while
systems with relatively fast disc I/O (e.g. SSD swap) and slower
processors would benefit from writethrough.

So, any opinions on keeping both writeback and writethrough, with (for
now) a module param to select?  I'll send an updated patch if that
sounds agreeable to all...

The specific specjbb numbers (on a dual core 2.4GHz with 4G ram) I got were:

   writeback
heap in mb      bops
3000             38887
3500             39260
4000             38113
4500             15686
5000             10978
5500              1445
6000              1827

   writethrough
heap in mb      bops
3000             39021
3500             35998
4000             36223
4500              7222
5000              7717
5500              2304
6000              2455

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
