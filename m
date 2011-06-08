Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3F3746B00EF
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 05:33:15 -0400 (EDT)
Date: Wed, 8 Jun 2011 11:33:10 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/4] mm: compaction: Ensure that the compaction free
 scanner does not move to the next zone
Message-ID: <20110608093310.GC6742@tiehlicka.suse.cz>
References: <1307459225-4481-1-git-send-email-mgorman@suse.de>
 <1307459225-4481-2-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1307459225-4481-2-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Thomas Sattler <tsattler@gmx.de>, Ury Stankevich <urykhy@gmail.com>, Andi Kleen <andi@firstfloor.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Tue 07-06-11 16:07:02, Mel Gorman wrote:
> Compaction works with two scanners, a migration and a free
> scanner. When the scanners crossover, migration within the zone is
> complete. The location of the scanner is recorded on each cycle to
> avoid excesive scanning.
> 
> When a zone is small and mostly reserved, it's very easy for the
> migration scanner to be close to the end of the zone. Then the following
> situation can occurs
> 
>   o migration scanner isolates some pages near the end of the zone
>   o free scanner starts at the end of the zone but finds that the
>     migration scanner is already there
>   o free scanner gets reinitialised for the next cycle as
>     cc->migrate_pfn + pageblock_nr_pages
>     moving the free scanner into the next zone
>   o migration scanner moves into the next zone
> 
> When this happens, NR_ISOLATED accounting goes haywire because some
> of the accounting happens against the wrong zone. One zones counter
> remains positive while the other goes negative even though the overall
> global count is accurate. This was reported on X86-32 with !SMP because
> !SMP allows the negative counters to be visible. The fact that it is
> difficult to reproduce on X86-64 is probably just a co-incidence as
> the bug should theoritically be possible there.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
