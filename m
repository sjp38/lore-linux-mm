Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4768C6B016A
	for <linux-mm@kvack.org>; Fri,  2 Sep 2011 01:09:57 -0400 (EDT)
Received: by iagv1 with SMTP id v1so3624980iag.14
        for <linux-mm@kvack.org>; Thu, 01 Sep 2011 22:09:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110901142027.GI14369@suse.de>
References: <cover.1321112552.git.minchan.kim@gmail.com>
	<282a4531f23c5e35cfddf089f93559130b4bb660.1321112552.git.minchan.kim@gmail.com>
	<20110901142027.GI14369@suse.de>
Date: Fri, 2 Sep 2011 14:09:55 +0900
Message-ID: <CAEwNFnCSgPj+KuZr0h9-0=mr29QDYnFDzvtwV5Vc1VBVtThqWA@mail.gmail.com>
Subject: Re: [PATCH 3/3] compaction accouting fix
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>

On Thu, Sep 1, 2011 at 11:20 PM, Mel Gorman <mgorman@suse.de> wrote:
> On Sun, Nov 13, 2011 at 01:37:43AM +0900, Minchan Kim wrote:
>> I saw the following accouting of compaction during test of the series.
>
> s/accouting/accounting/ both here and in the subject. A nicer name the
> patch would have been
>
> "mm: compaction: Only update compact_blocks_moved if compaction was successful"

Thanks, I will fix it at next version. :)

>
>>
>> compact_blocks_moved 251
>> compact_pages_moved 44
>>
>> It's very awkward to me although it's possbile because it means we try to compact 251 blocks
>> but it just migrated 44 pages. As further investigation, I found isolate_migratepages doesn't
>> isolate any pages but it returns ISOLATE_SUCCESS and then, it just increases compact_blocks_moved
>> but doesn't increased compact_pages_moved.
>>
>> This patch makes accouting of compaction works only in case of success of isolation.
>>
>
> compact_blocks_moved exists to indicate the rate compaction is
> scanning pageblocks. If compact_blocks_moved and compact_pages_moved
> are increasing at a similar rate for example, it could imply that
> compaction is doing a lot of scanning but is not necessarily useful
> work. It's not necessarily reflected by compact_fail because that
> counter is only updated for pages that were isolated from the LRU.

You seem to say "compact_pagemigrate_failed" not "compact_fail".

>
> I now recognise of course that "compact_blocks_moved" was an *awful*
> choice of name for this stat.

I hope changing stat names as follows unless it's too late(ie, it
doesn't break ABI with any tools)

compact_blocks_moved -> compact_blocks
compact_pages_moved -> compact_pgmigrated_success
compact_pagemigrate_failed -> compact_pgmigrated_fail
compact_stall -> compact_alloc_stall
compact_fail -> compact_alloc_fail
compact_success -> compact_alloc_success


>
> --
> Mel Gorman
> SUSE Labs
>



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
