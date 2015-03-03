Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3B3666B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 06:34:43 -0500 (EST)
Received: by padfb1 with SMTP id fb1so14131255pad.7
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 03:34:43 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id f4si641519pas.112.2015.03.03.03.34.41
        for <linux-mm@kvack.org>;
        Tue, 03 Mar 2015 03:34:42 -0800 (PST)
Date: Tue, 3 Mar 2015 22:34:37 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [regression v4.0-rc1] mm: IPIs from TLB flushes causing
 significant performance degradation.
Message-ID: <20150303113437.GR4251@dastard>
References: <20150302010413.GP4251@dastard>
 <CA+55aFzGFvVGD_8Y=jTkYwgmYgZnW0p0Fjf7OHFPRcL6Mz4HOw@mail.gmail.com>
 <20150303014733.GL18360@dastard>
 <CA+55aFw+7V9DfxBA2_DhMNrEQOkvdwjFFga5Y67-a6yVeAz+NQ@mail.gmail.com>
 <CA+55aFw+fb=Fh4M2wA4dVskgqN7PhZRGZS6JTMx4Rb1Qn++oaA@mail.gmail.com>
 <20150303052004.GM18360@dastard>
 <CA+55aFyczb5asoTwhzaJr1JdRi1epg1A6cFJgnzMMZj6U0gFWA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyczb5asoTwhzaJr1JdRi1epg1A6cFJgnzMMZj6U0gFWA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Matt B <jackdachef@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, xfs@oss.sgi.com

On Mon, Mar 02, 2015 at 10:56:14PM -0800, Linus Torvalds wrote:
> On Mon, Mar 2, 2015 at 9:20 PM, Dave Chinner <david@fromorbit.com> wrote:
> >>
> >> But are those migrate-page calls really common enough to make these
> >> things happen often enough on the same pages for this all to matter?
> >
> > It's looking like that's a possibility.
> 
> Hmm. Looking closer, commit 10c1045f28e8 already should have
> re-introduced the "pte was already NUMA" case.
> 
> So that's not it either, afaik. Plus your numbers seem to say that
> it's really "migrate_pages()" that is done more. So it feels like the
> numa balancing isn't working right.

So that should show up in the vmstats, right? Oh, and there's a
tracepoint in migrate_pages, too. Same 6x10s samples in phase 3:

3.19:

	55,898      migrate:mm_migrate_pages

And a sample of the events shows 99.99% of these are:

mm_migrate_pages:     nr_succeeded=1 nr_failed=0 mode=MIGRATE_ASYNC reason=

4.0-rc1:

	364,442      migrate:mm_migrate_pages

They are also single page MIGRATE_ASYNC events like for 3.19.

And 'grep "numa\|migrate" /proc/vmstat' output for the entire
xfs_repair run:

3.19:

numa_hit 5163221
numa_miss 121274
numa_foreign 121274
numa_interleave 12116
numa_local 5153127
numa_other 131368
numa_pte_updates 36482466
numa_huge_pte_updates 0
numa_hint_faults 34816515
numa_hint_faults_local 9197961
numa_pages_migrated 1228114
pgmigrate_success 1228114
pgmigrate_fail 0

4.0-rc1:

numa_hit 36952043
numa_miss 92471
numa_foreign 92471
numa_interleave 10964
numa_local 36927384
numa_other 117130
numa_pte_updates 84010995
numa_huge_pte_updates 0
numa_hint_faults 81697505
numa_hint_faults_local 21765799
numa_pages_migrated 32916316
pgmigrate_success 32916316
pgmigrate_fail 0

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
