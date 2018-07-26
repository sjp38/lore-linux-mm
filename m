Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id AA22E6B0006
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 09:30:27 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l1-v6so808792edi.11
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 06:30:27 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e29-v6si941705eda.181.2018.07.26.06.30.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 06:30:26 -0700 (PDT)
Subject: Re: freepage accounting bug with CMA/migrate isolation
References: <86bea4f7-229a-7cbb-1e8a-7e6d96f0f087@oracle.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <2845930a-9a71-22cd-a56b-6616c9889486@suse.cz>
Date: Thu, 26 Jul 2018 15:30:24 +0200
MIME-Version: 1.0
In-Reply-To: <86bea4f7-229a-7cbb-1e8a-7e6d96f0f087@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: 'Joonsoo Kim' <iamjoonsoo.kim@lge.com>, Laura Abbott <labbott@redhat.com>

On 07/24/2018 06:24 AM, Mike Kravetz wrote:
> With v4.17, I can see an issue like those addressed in commits 3c605096d315
> ("mm/page_alloc: restrict max order of merging on isolated pageblock")
> and d9dddbf55667 ("mm/page_alloc: prevent merging between isolated and
> other pageblocks").  After running a CMA stress test for a while, I see:
>   MemTotal:        8168384 kB
>   MemFree:         8457232 kB
>   MemAvailable:    9204844 kB
> If I let the test run, MemFree and MemAvailable will continue to grow.
> 
> I am certain the issue is with pageblocks of migratetype ISOLATED.  If
> I disable all special 'is_migrate_isolate' checks in freepage accounting,
> the issue goes away.  Further, I am pretty sure the issue has to do with
> pageblock merging and or page orders spanning pageblocks.  If I make
> pageblock_order equal MAX_ORDER-1, the issue also goes away.
> 
> Just looking for suggesting in where/how to debug.  I've been hacking on
> this without much success.

Maybe I'm wrong or it's something else, but I think that
unset_migratetype_isolate() is wrong and can lead to overcounting freepages.

Scenario is (with pageblock_order = MAX_ORDER - 2):
- MAX_ORDER-1 block is already free when isolated, thus there is no
merging that could be limited to pageblock_order, and the free page
remains > pageblock_order
- unset_migratetype_isolate() is called on first pageblock of the pair,
goes via the "if (PageBuddy(page))" path, isolates the page to free it,
thus adding MAX_ORDER - 1 pages to freepage counter.
- zone lock is dropped, somebody else allocates and splits the
MAX_ORDER-1 free page. Since the first pageblock is already marked
!ISOLATE, the free pages left after splitting are put on !ISOLATE
freelists, that includes pages from the second pageblock (perhaps a
whole pageblock_order page).
- unset_migratetype_isolate() is called on second pageblock of the pair
and increments the freepage counter again for all free pages in the
second block (move_freepages_block() doesn't check if it's really moving
them from ISOLATED freelists) so they get accounted twice.

Not sure if your stress test can trigger this so frequently, but it's
possible? A fix would have to 1) force split to <= pageblock_order in
start_isolate_page_range() or 2) unset_migratetype_isolate() make sure
that it converts all pageblocks at once if it finds a > pageblock_order
free page. Maybe there's more pieces subtly broken with free page >
pageblock_order, so it would have to be 1) though.
