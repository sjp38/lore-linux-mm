Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9355D8D0039
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 09:26:23 -0500 (EST)
Received: by pzk33 with SMTP id 33so479733pzk.14
        for <linux-mm@kvack.org>; Tue, 22 Feb 2011 06:26:21 -0800 (PST)
Date: Tue, 22 Feb 2011 23:26:10 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH v6 0/4] fadvise(DONTNEED) support
Message-ID: <20110222142610.GA6093@barrios-desktop>
References: <cover.1298212517.git.minchan.kim@gmail.com>
 <20110221190713.GM13092@random.random>
 <AANLkTimOhgK953rmOw4PqnoFq_e7y6j1m+NBDYJehkds@mail.gmail.com>
 <20110222132804.GQ13092@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110222132804.GQ13092@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Steven Barrett <damentz@liquorix.net>, Ben Gamari <bgamari.foss@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Tue, Feb 22, 2011 at 02:28:04PM +0100, Andrea Arcangeli wrote:
> Hi Minchan,
> 
> On Tue, Feb 22, 2011 at 07:59:51AM +0900, Minchan Kim wrote:
> > I don't have a reproducible experiment.
> > I started the series with Ben's complain.
> > http://marc.info/?l=rsync&m=128885034930933&w=2
> 
> Yes I've noticed.
> 
> > I don't know Ben could test it with older kernel since recently he got silent.
> 
> That's my point, we should check if the "thrashing horribly" is really
> a "recently" or if it has always happened before with 2.6.18 and previous.
> 
> > I am not sure older kernel worked well such as workload.
> > That's because Rik had been pointed out rsync's two touch
> > problem(http://linux-mm.org/PageReplacementRequirements) and solved
> > part of the problem with remaining half of the active file pages(look
> > at inactive_file_is_low) on 2.6.28's big change reclaim.
> > So I think the problem about such workload have been in there.
> 
> It's possible it's an old problem, but frankly I doubt that any
> swapping would have ever happened before, no matter how much rsync you
> would run in a loop. As said I also got PM from users asking what they
> can do to limit the pagecache because their systems are swapping
> overnight because of backup loads, that's definitely not ok. Or at
> least there must be a tweak to tell the VM "stop doing the swapping
> thing with backup". I didn't yet try to reproduce or debug this as I'm
> busy with other compaction/THP related bits.
> 
> > And this patch's benefit is not only for preventing working set.
> > Before this patch, application should sync the data before fadvise to
> > take a effect but it's very inefficient by slow sync operation. If the
> > invalidation meet dirty page, it can skip the page. But after this
> > patch, application could fdavise without sync because we could move
> > the page of head/or tail of inactive list.
> 
> I agree, the objective of the patch definitely looks good. Before the
> fadvise would be ignored without a fdatasync before it as the pages
> were dirty and couldn't be discarded.
> 
> > So I think the patch is valuable enough to merge?
> 
> The objective looks good, I didn't have time to review all details of
> the patches but I'll try to review it later.
> 
> > And as I said, I need Ben's help but I am not sure he can.
> > Thanks for the review, Andrea.
> 
> Thanks for the effort in improving fadvise.
> 
> I'd like to try to find the time to check if we've a regression
> without fadvise too. It's perfectly ok to use fadvise in rsync but my
> point is that the kernel should not lead to trashing of running apps
> regardless of fadvise or not, and I think that is higher priority to
> fix than the fadvise improvement. But still the fadvise improvement is
> very valuable to increase overall performance and hopefully to avoid
> wasting most of filesystem cache because of backups (but wasting cache
> shouldn't lead to trashing horribly, just more I/O from apps after the
> backup run, like after starting the app the first time, trashing
> usually means we swapped out or discarded mapped pages too and that's
> wrong).

I agree your opinion but I hope the patch is going on 2.6.38 or 39.
That's because if we find regression's root cause, how could this series be changed?
I think it's no difference before and after.
Of course, if rsync like applicatoin start to use fadvise agressively, the problem
could be buried on toe but we still have a older kernel and older rsync so we can
reproduce it then we can find the root cause.
What's the problem if the series is merged?
If it is reasonable, it's no problem to pend the series.

I _totally_ agree your opinion and I want to find root cause of the regression, too.
But unfortunatly, I don't have any time and enviroment to reproduce it. ;(
I hope clever people like you would have a time to find it and report it to linux-mm
in future.

Ben. Could you test your workload on older 2.6.18 kernel if you see the thread?
It could help us very much.
Thanks.

> 
> Thanks,
> Andrea

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
