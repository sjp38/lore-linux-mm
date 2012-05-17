Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 805B86B0082
	for <linux-mm@kvack.org>; Thu, 17 May 2012 08:10:53 -0400 (EDT)
Date: Thu, 17 May 2012 14:10:49 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: consider all swapped back pages in used-once logic
Message-ID: <20120517121049.GA11018@tiehlicka.suse.cz>
References: <1337246033-13719-1-git-send-email-mhocko@suse.cz>
 <20120517022412.9175f604.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120517022412.9175f604.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>

On Thu 17-05-12 02:24:12, Andrew Morton wrote:
> On Thu, 17 May 2012 11:13:53 +0200 Michal Hocko <mhocko@suse.cz> wrote:
> 
> > [64574746 vmscan: detect mapped file pages used only once] made mapped pages
> > have another round in inactive list because they might be just short
> > lived and so we could consider them again next time. This heuristic
> > helps to reduce pressure on the active list with a streaming IO
> > worklods.
> > This patch fixes a regression introduced by this commit for heavy shmem
> 
> A performance regression, specifically.
> 
> Are you able to quantify it?

The customer's workload is shmem backed database (80% of RAM) and
they are measuring transactions/s with an IO in the background (20%).
Transactions touch more or less random rows in the table.
The rate goes down drastically when we start swapping out memory.

Numbers are more descriptive (without the patch is 100%, with 5
representative runs)
Average rate	315.83%
Best rate	131.76%
Worst rate	641.25%

Standard deviation (calibrated to average) is ~4% while without the
patch we are at 62.82%. 
The big variance without the patch is caused by the excessive swapping
which doesn't occur with the patch applied.

* Worst run (100%) compared to a random run with the patch
pgpgin	pswpin	pswpout	pgmajfault
1.58%	0.00%	0.01%	0.22%

Average size of the LRU lists:
nr_inactive_anon nr_active_anon nr_inactive_file nr_active_file
52.91%           7234.72%       249.39%          126.64%

* Best run
pgpgin	pswpin	pswpout	pgmajfault
3.37%	0.00%	0.11%	0.39%

nr_inactive_anon nr_active_anon nr_inactive_file nr_active_file
49.85%           3868.74%       175.03%          121.27%

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
