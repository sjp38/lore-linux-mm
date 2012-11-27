Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 50C536B004D
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 15:58:40 -0500 (EST)
Received: by mail-we0-f169.google.com with SMTP id t49so4048143wey.14
        for <linux-mm@kvack.org>; Tue, 27 Nov 2012 12:58:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1354049315-12874-1-git-send-email-hannes@cmpxchg.org>
References: <1354049315-12874-1-git-send-email-hannes@cmpxchg.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 27 Nov 2012 12:58:18 -0800
Message-ID: <CA+55aFywygqWUBNWtZYa+vk8G0cpURZbFdC7+tOzyWk6tLi=WA@mail.gmail.com>
Subject: Re: kswapd craziness in 3.7
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, George Spelvin <linux@horizon.com>, Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>, Tomas Racek <tracek@redhat.com>, Jan Kara <jack@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Josh Boyer <jwboyer@gmail.com>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Jiri Slaby <jslaby@suse.cz>, Thorsten Leemhuis <fedora@leemhuis.info>, Zdenek Kabelac <zkabelac@redhat.com>, Bruno Wolff III <bruno@wolff.to>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Note that in the meantime, I've also applied (through Andrew) the
patch that reverts commit c654345924f7 (see commit 82b212f40059
'Revert "mm: remove __GFP_NO_KSWAPD"').

I wonder if that revert may be bogus, and a result of this same issue.
Maybe that revert should be reverted, and replaced with your patch?

Mel? Zdenek? What's the status here?

                 Linus

On Tue, Nov 27, 2012 at 12:48 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
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
> Another one was an accounting problem where a freed higher order page
> was underreported, and so kswapd had trouble restoring watermarks.
> This one was fixed in ef6c5be fix incorrect NR_FREE_PAGES accounting
> (appears like memory leak).
>
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
> The following patch should fix the third issue by making both reclaim
> and compaction code in kswapd use the same predicate to determine
> whether a zone is balanced or not.
>
> Hopefully, the sum of all three fixes should tame kswapd enough for
> 3.7.
>
> Johannes
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
