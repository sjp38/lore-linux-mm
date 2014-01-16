Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f49.google.com (mail-bk0-f49.google.com [209.85.214.49])
	by kanga.kvack.org (Postfix) with ESMTP id 24AD56B0031
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 16:18:54 -0500 (EST)
Received: by mail-bk0-f49.google.com with SMTP id 6so1370638bkj.22
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 13:18:53 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id pd9si6028926bkb.176.2014.01.16.13.18.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 16 Jan 2014 13:18:52 -0800 (PST)
Date: Thu, 16 Jan 2014 16:17:58 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 7/9] mm: thrash detection-based file cache sizing
Message-ID: <20140116211758.GN6963@cmpxchg.org>
References: <1389377443-11755-1-git-send-email-hannes@cmpxchg.org>
 <1389377443-11755-8-git-send-email-hannes@cmpxchg.org>
 <52D48C55.3020200@oracle.com>
 <20140114191619.GI6963@cmpxchg.org>
 <52D5F911.1090507@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52D5F911.1090507@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Jan 15, 2014 at 10:57:21AM +0800, Bob Liu wrote:
> On 01/15/2014 03:16 AM, Johannes Weiner wrote:
> > On Tue, Jan 14, 2014 at 09:01:09AM +0800, Bob Liu wrote:
> >> Good job! This patch looks good to me and with nice descriptions.
> >> But it seems that this patch only fix the issue "working set changes
> >> bigger than half of cache memory go undetected and thrash indefinitely".
> >> My concern is could it be extended easily to address all other issues
> >> based on this patch set?
> >>
> >> The other possible way is something like Peter has implemented the CART
> >> and Clock-Pro which I think may be better because of using advanced
> >> algorithms and consider the problem as a whole from the beginning.(Sorry
> >> I haven't get enough time to read the source code, so I'm not 100% sure.)
> >> http://linux-mm.org/PeterZClockPro2
> > 
> > My patches are moving the VM towards something that is comparable to
> > how Peter implemented Clock-Pro.  However, the current VM has evolved
> > over time in small increments based on real life performance
> > observations.  Rewriting everything in one go would be incredibly
> > disruptive and I doubt very much we would merge any such proposal in
> > the first place.  So it's not like I don't see the big picture, it's
> > just divide and conquer:
> > 
> > Peter's Clock-Pro implementation was basically a double clock with an
> > intricate system to classify hotness, augmented by eviction
> > information to work with reuse distances independent of memory size.
> > 
> > What we have right now is a double clock with a very rudimentary
> > system to classify whether a page is hot: it has been accessed twice
> > while on the inactive clock.  My patches now add eviction information
> > to this, and improve the classification so that it can work with reuse
> > distances up to memory size and is no longer dependent on the inactive
> > clock size.
> > 
> > This is the smallest imaginable step that is still useful, and even
> > then we had a lot of discussions about scalability of the data
> > structures and confusion about how the new data point should be
> > interpreted.  It also took a long time until somebody read the series
> > and went, "Ok, this actually makes sense to me."  Now, maybe I suck at
> > documenting, but maybe this is just complicated stuff.  Either way, we
> > have to get there collectively, so that the code is maintainable in
> > the long term.
> > 
> > Once we have these new concepts established, we can further improve
> > the hotness detector so that it can classify and order pages with
> > reuse distances beyond memory size.  But this will come with its own
> > set of problems.  For example, some time ago we stopped regularly
> > scanning and rotating active pages because of scalability issues, but
> > we'll most likely need an uptodate estimate of the reuse distances on
> > the active list in order to classify refaults properly.
> > 
> 
> Thank you for your kindly explanation. It make sense to me please feel
> free to add my review.

Thank you!

> >>> + * Approximating inactive page access frequency - Observations:
> >>> + *
> >>> + * 1. When a page is accessed for the first time, it is added to the
> >>> + *    head of the inactive list, slides every existing inactive page
> >>> + *    towards the tail by one slot, and pushes the current tail page
> >>> + *    out of memory.
> >>> + *
> >>> + * 2. When a page is accessed for the second time, it is promoted to
> >>> + *    the active list, shrinking the inactive list by one slot.  This
> >>> + *    also slides all inactive pages that were faulted into the cache
> >>> + *    more recently than the activated page towards the tail of the
> >>> + *    inactive list.
> >>> + *
> >>
> >> Nitpick, how about the reference bit?
> > 
> > What do you mean?
> > 
> 
> Sorry, I mean the PG_referenced flag. I thought when a page is accessed
> for the second time only PG_referenced flag  will be set instead of be
> promoted to active list.

It's cleared during rotation or not set on pages that came in through
readahead, but the first access sets the bit and the second access
activates it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
