Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 944D16B0038
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 00:19:20 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id t25so7634336pfg.3
        for <linux-mm@kvack.org>; Mon, 10 Oct 2016 21:19:20 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id qz8si1458314pab.25.2016.10.10.21.19.19
        for <linux-mm@kvack.org>;
        Mon, 10 Oct 2016 21:19:19 -0700 (PDT)
Date: Tue, 11 Oct 2016 13:19:16 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/4] mm: adjust reserved highatomic count
Message-ID: <20161011041916.GA30973@bbox>
References: <1475819136-24358-1-git-send-email-minchan@kernel.org>
 <1475819136-24358-2-git-send-email-minchan@kernel.org>
 <7ac7c0d8-4b7b-e362-08e7-6d62ee20f4c3@suse.cz>
 <20161007142919.GA3060@bbox>
 <c0920ac2-fe63-567e-e24c-eb6d638143b0@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c0920ac2-fe63-567e-e24c-eb6d638143b0@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>

Hi Vlasimil,

On Mon, Oct 10, 2016 at 08:57:40AM +0200, Vlastimil Babka wrote:
> On 10/07/2016 04:29 PM, Minchan Kim wrote:
> >>>In that case, we should adjust nr_reserved_highatomic.
> >>>Otherwise, VM cannot reserve highorderatomic pageblocks any more
> >>>although it doesn't reach 1% limit. It means highorder atomic
> >>>allocation failure would be higher.
> >>>
> >>>So, this patch decreases the account as well as migratetype
> >>>if it was MIGRATE_HIGHATOMIC.
> >>>
> >>>Signed-off-by: Minchan Kim <minchan@kernel.org>
> >>
> >>Hm wouldn't it be simpler just to prevent the pageblock's migratetype to be
> >>changed if it's highatomic? Possibly also not do move_freepages_block() in
> >
> >It could be. Actually, I did it with modifying can_steal_fallback which returns
> >false it found the pageblock is highorderatomic but changed to this way again
> >because I don't have any justification to prevent changing pageblock.
> >If you give concrete justification so others isn't against on it, I am happy to
> >do what you suggested.
> 
> Well, MIGRATE_HIGHATOMIC is not listed in the fallbacks array at all, so we
> are not supposed to steal from it in the first place. Stealing will only
> happen due to races, which would be too costly to close, so we allow them
> and expect to be rare. But we shouldn't allow them to break the accounting.
> 

Fair enough.
How about this?
