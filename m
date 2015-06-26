Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 9AD066B0038
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 22:14:52 -0400 (EDT)
Received: by obbkm3 with SMTP id km3so58785956obb.1
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 19:14:52 -0700 (PDT)
Received: from mail-ob0-x22c.google.com (mail-ob0-x22c.google.com. [2607:f8b0:4003:c01::22c])
        by mx.google.com with ESMTPS id fy16si21075540oeb.33.2015.06.25.19.14.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jun 2015 19:14:52 -0700 (PDT)
Received: by obpn3 with SMTP id n3so58719118obp.0
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 19:14:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <558C4EF0.2010603@suse.cz>
References: <1435193121-25880-1-git-send-email-iamjoonsoo.kim@lge.com>
	<20150625110314.GJ11809@suse.de>
	<CAAmzW4OnE7A6sxEDFRcp9jbuxkYkJvJw_PH1TBFtS0nZOmrVGg@mail.gmail.com>
	<20150625172550.GA26927@suse.de>
	<CAAmzW4PMWOaAa0bd7xVr5Jz=xVgqMw8G=UFOwhUGuyLL9EFbHA@mail.gmail.com>
	<558C4EF0.2010603@suse.cz>
Date: Fri, 26 Jun 2015 11:14:51 +0900
Message-ID: <CAAmzW4P0H2dxVa9zMBkKEyX-R3at-xo-pBLMS07j=svQzYwvBQ@mail.gmail.com>
Subject: Re: [RFC PATCH 00/10] redesign compaction algorithm
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>

2015-06-26 3:56 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
> On 25.6.2015 20:14, Joonsoo Kim wrote:
>>> The long-term success rate of fragmentation avoidance depends on
>>> > minimsing the number of UNMOVABLE allocation requests that use a
>>> > pageblock belonging to another migratetype. Once such a fallback occurs,
>>> > that pageblock potentially can never be used for a THP allocation again.
>>> >
>>> > Lets say there is an unmovable pageblock with 500 free pages in it. If
>>> > the freepage scanner uses that pageblock and allocates all 500 free
>>> > pages then the next unmovable allocation request needs a new pageblock.
>>> > If one is not completely free then it will fallback to using a
>>> > RECLAIMABLE or MOVABLE pageblock forever contaminating it.
>> Yes, I can imagine that situation. But, as I said above, we already use
>> non-movable pageblock for migration scanner. While unmovable
>> pageblock with 500 free pages fills, some other unmovable pageblock
>> with some movable pages will be emptied. Number of freepage
>> on non-movable would be maintained so fallback doesn't happen.
>
> There's nothing that guarantees that the migration scanner will be emptying
> unmovable pageblock, or am I missing something?

As replied to Mel's comment, as number of unmovable pageblocks, which is
filled by movable pages due to this compaction change increases,
possible candidate reclaimable/migratable pages from them also increase.
So, at some time, amount of used page by free scanner and amount of
migrated page by migration scanner would be balanced.

> Worse, those pageblocks would be
> marked to skip by the free scanner if it isolated free pages from them, so
> migration scanner would skip them.

Yes, but, next iteration will move out movable pages from that pageblock
and freed pages will be used for further unmovable allocation.
So, in the long term, this doesn't make much more fragmentation.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
