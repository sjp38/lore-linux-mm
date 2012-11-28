Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 81DBF6B004D
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 04:45:19 -0500 (EST)
Date: Wed, 28 Nov 2012 09:45:11 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: kswapd craziness in 3.7
Message-ID: <20121128094511.GS8218@suse.de>
References: <1354049315-12874-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1354049315-12874-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, George Spelvin <linux@horizon.com>, Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>, Thorsten Leemhuis <fedora@leemhuis.info>, Tomas Racek <tracek@redhat.com>, Jan Kara <jack@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Josh Boyer <jwboyer@gmail.com>, Valdis.Kletnieks@vt.edu, Jiri Slaby <jslaby@suse.cz>, Zdenek Kabelac <zkabelac@redhat.com>, Bruno Wolff III <bruno@wolff.to>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(Adding Thorsten to cc)

On Tue, Nov 27, 2012 at 03:48:34PM -0500, Johannes Weiner wrote:
> Hi everyone,
> 
> I hope I included everybody that participated in the various threads
> on kswapd getting stuck / exhibiting high CPU usage.  We were looking
> at at least three root causes as far as I can see, so it's not really
> clear who observed which problem.  Please correct me if the
> reported-by, tested-by, bisected-by tags are incomplete.
> 
> One problem was, as it seems, overly aggressive reclaim due to scaling
> up reclaim goals based on compaction failures.  This one was reverted
> in 9671009 mm: revert "mm: vmscan: scale number of pages reclaimed by
> reclaim/compaction based on failures".
> 

This particular one would have been made worse by the accounting bug and
if kswapd was staying awake longer than necessary. As scaling the amount
of reclaim only for direct reclaim helped this problem a lot, I strongly
suspect the accounting bug was a factor.

However the benefit for this is marginal -- it primarily affects how
many THP pages we can allocate under stress. There is already a graceful
fallback path and a system under heavy reclaim pressure is not going to
notice the performance benefit of THP.

> Another one was an accounting problem where a freed higher order page
> was underreported, and so kswapd had trouble restoring watermarks.
> This one was fixed in ef6c5be fix incorrect NR_FREE_PAGES accounting
> (appears like memory leak).
> 

This almost certainly also requires the follow-on fix at
https://lkml.org/lkml/2012/11/26/225 for reasons I explained in
https://lkml.org/lkml/2012/11/27/190 .

> The third one is a problem with small zones, like the DMA zone, where
> the high watermark is lower than the low watermark plus compaction gap
> (2 * allocation size).  The zonelist reclaim in kswapd would do
> nothing because all high watermarks are met, but the compaction logic
> would find its own requirements unmet and loop over the zones again.
> Indefinitely, until some third party would free enough memory to help
> meet the higher compaction watermark.  The problematic code has been
> there since the 3.4 merge window for non-THP higher order allocations
> but has been more prominent since the 3.7 merge window, where kswapd
> is also woken up for the much more common THP allocations.
> 

Yes. 

> The following patch should fix the third issue by making both reclaim
> and compaction code in kswapd use the same predicate to determine
> whether a zone is balanced or not.
> 
> Hopefully, the sum of all three fixes should tame kswapd enough for
> 3.7.
> 

Not exactly sure of that. With just those patches it is possible for
allocations for THP entering the slow path to keep kswapd continually awake
doing busy work. This was an alternative to the revert that covered that
https://lkml.org/lkml/2012/11/12/151 but it was not enough because kswapd
would stay awake due to the bug you identified and fixed.

I went with the __GFP_NO_KSWAPD patch in this cycle because 3.6 was/is
very poor in how it handles THP after the removal of lumpy reclaim. 3.7
was shaping up to be even worse with multiple root causes too close to the
release date.  Taking kswapd out of the equation covered some of the
problems (yes, by hiding them) so it could be revisited but Johannes may
have finally squashed it.

However, if we revert the revert then I strongly recommend that it be
replaced with "Avoid waking kswapd for THP allocations when compaction is
deferred or contended".

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
