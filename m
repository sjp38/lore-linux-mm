Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 3F68C6B006C
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 14:56:52 -0400 (EDT)
Received: by wgqq4 with SMTP id q4so70307470wgq.1
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 11:56:51 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r18si10196103wiv.5.2015.06.25.11.56.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Jun 2015 11:56:50 -0700 (PDT)
Message-ID: <558C4EF0.2010603@suse.cz>
Date: Thu, 25 Jun 2015 20:56:48 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 00/10] redesign compaction algorithm
References: <1435193121-25880-1-git-send-email-iamjoonsoo.kim@lge.com>	<20150625110314.GJ11809@suse.de>	<CAAmzW4OnE7A6sxEDFRcp9jbuxkYkJvJw_PH1TBFtS0nZOmrVGg@mail.gmail.com>	<20150625172550.GA26927@suse.de> <CAAmzW4PMWOaAa0bd7xVr5Jz=xVgqMw8G=UFOwhUGuyLL9EFbHA@mail.gmail.com>
In-Reply-To: <CAAmzW4PMWOaAa0bd7xVr5Jz=xVgqMw8G=UFOwhUGuyLL9EFbHA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Mel Gorman <mgorman@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>

On 25.6.2015 20:14, Joonsoo Kim wrote:
>> The long-term success rate of fragmentation avoidance depends on
>> > minimsing the number of UNMOVABLE allocation requests that use a
>> > pageblock belonging to another migratetype. Once such a fallback occurs,
>> > that pageblock potentially can never be used for a THP allocation again.
>> >
>> > Lets say there is an unmovable pageblock with 500 free pages in it. If
>> > the freepage scanner uses that pageblock and allocates all 500 free
>> > pages then the next unmovable allocation request needs a new pageblock.
>> > If one is not completely free then it will fallback to using a
>> > RECLAIMABLE or MOVABLE pageblock forever contaminating it.
> Yes, I can imagine that situation. But, as I said above, we already use
> non-movable pageblock for migration scanner. While unmovable
> pageblock with 500 free pages fills, some other unmovable pageblock
> with some movable pages will be emptied. Number of freepage
> on non-movable would be maintained so fallback doesn't happen.

There's nothing that guarantees that the migration scanner will be emptying
unmovable pageblock, or am I missing something? Worse, those pageblocks would be
marked to skip by the free scanner if it isolated free pages from them, so
migration scanner would skip them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
