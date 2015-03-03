Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 6CA0D6B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 16:33:58 -0500 (EST)
Received: by pdno5 with SMTP id o5so5060400pdn.12
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 13:33:58 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id y10si2462397pdm.136.2015.03.03.13.33.56
        for <linux-mm@kvack.org>;
        Tue, 03 Mar 2015 13:33:57 -0800 (PST)
Date: Wed, 4 Mar 2015 08:33:53 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [regression v4.0-rc1] mm: IPIs from TLB flushes causing
 significant performance degradation.
Message-ID: <20150303213353.GS4251@dastard>
References: <20150302010413.GP4251@dastard>
 <CA+55aFzGFvVGD_8Y=jTkYwgmYgZnW0p0Fjf7OHFPRcL6Mz4HOw@mail.gmail.com>
 <20150303014733.GL18360@dastard>
 <CA+55aFw+7V9DfxBA2_DhMNrEQOkvdwjFFga5Y67-a6yVeAz+NQ@mail.gmail.com>
 <CA+55aFw+fb=Fh4M2wA4dVskgqN7PhZRGZS6JTMx4Rb1Qn++oaA@mail.gmail.com>
 <20150303052004.GM18360@dastard>
 <CA+55aFyczb5asoTwhzaJr1JdRi1epg1A6cFJgnzMMZj6U0gFWA@mail.gmail.com>
 <20150303113437.GR4251@dastard>
 <20150303134346.GO3087@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150303134346.GO3087@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Matt B <jackdachef@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, xfs@oss.sgi.com

On Tue, Mar 03, 2015 at 01:43:46PM +0000, Mel Gorman wrote:
> On Tue, Mar 03, 2015 at 10:34:37PM +1100, Dave Chinner wrote:
> > On Mon, Mar 02, 2015 at 10:56:14PM -0800, Linus Torvalds wrote:
> > > On Mon, Mar 2, 2015 at 9:20 PM, Dave Chinner <david@fromorbit.com> wrote:
> > > >>
> > > >> But are those migrate-page calls really common enough to make these
> > > >> things happen often enough on the same pages for this all to matter?
> > > >
> > > > It's looking like that's a possibility.
> > > 
> > > Hmm. Looking closer, commit 10c1045f28e8 already should have
> > > re-introduced the "pte was already NUMA" case.
> > > 
> > > So that's not it either, afaik. Plus your numbers seem to say that
> > > it's really "migrate_pages()" that is done more. So it feels like the
> > > numa balancing isn't working right.
> > 
> > So that should show up in the vmstats, right? Oh, and there's a
> > tracepoint in migrate_pages, too. Same 6x10s samples in phase 3:
> > 
> 
> The stats indicate both more updates and more faults. Can you try this
> please? It's against 4.0-rc1.
> 
> ---8<---
> mm: numa: Reduce amount of IPI traffic due to automatic NUMA balancing

Makes no noticable difference to behaviour or performance. Stats:

359,857      migrate:mm_migrate_pages ( +-  5.54% )

numa_hit 36026802
numa_miss 14287
numa_foreign 14287
numa_interleave 18408
numa_local 36006052
numa_other 35037
numa_pte_updates 81803359
numa_huge_pte_updates 0
numa_hint_faults 79810798
numa_hint_faults_local 21227730
numa_pages_migrated 32037516
pgmigrate_success 32037516
pgmigrate_fail 0

-Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
