Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5926E6B0085
	for <linux-mm@kvack.org>; Tue, 19 May 2009 03:52:46 -0400 (EDT)
Date: Tue, 19 May 2009 15:49:25 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/3] vmscan: make mapped executable pages the first
	class citizen
Message-ID: <20090519074925.GA690@localhost>
References: <20090519133422.4ECC.A69D9226@jp.fujitsu.com> <20090519071554.GA26646@localhost> <20090519161756.4EE4.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090519161756.4EE4.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue, May 19, 2009 at 03:20:19PM +0800, KOSAKI Motohiro wrote:
> > On Tue, May 19, 2009 at 12:41:38PM +0800, KOSAKI Motohiro wrote:
> > > Hi
> > > 
> > > Thanks for great works.
> > > 
> > > 
> > > > SUMMARY
> > > > =======
> > > > The patch decreases the number of major faults from 50 to 3 during 10% cache hot reads.
> > > > 
> > > > 
> > > > SCENARIO
> > > > ========
> > > > The test scenario is to do 100000 pread(size=110 pages, offset=(i*100) pages),
> > > > where 10% of the pages will be activated:
> > > > 
> > > >         for i in `seq 0 100 10000000`; do echo $i 110;  done > pattern-hot-10
> > > >         iotrace.rb --load pattern-hot-10 --play /b/sparse
> > > 
> > > 
> > > Which can I download iotrace.rb?
> > > 
> > > 
> > > > and monitor /proc/vmstat during the time. The test box has 2G memory.
> > > > 
> > > > 
> > > > ANALYZES
> > > > ========
> > > > 
> > > > I carried out two runs on fresh booted console mode 2.6.29 with the VM_EXEC
> > > > patch, and fetched the vmstat numbers on
> > > > 
> > > > (1) begin:   shortly after the big read IO starts;
> > > > (2) end:     just before the big read IO stops;
> > > > (3) restore: the big read IO stops and the zsh working set restored
> > > > 
> > > >         nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree
> > > > begin:       2481             2237             8694              630                0           574299
> > > > end:          275           231976           233914              633           776271         20933042
> > > > restore:      370           232154           234524              691           777183         20958453
> > > > 
> > > > begin:       2434             2237             8493              629                0           574195
> > > > end:          284           231970           233536              632           771918         20896129
> > > > restore:      399           232218           234789              690           774526         20957909
> > > > 
> > > > and another run on 2.6.30-rc4-mm with the VM_EXEC logic disabled:
> > > 
> > > I don't think it is proper comparision.
> > > you need either following comparision. otherwise we insert many guess into the analysis.
> > > 
> > >  - 2.6.29 with and without VM_EXEC patch
> > >  - 2.6.30-rc4-mm with and without VM_EXEC patch
> > > 
> > > 
> > > > 
> > > > begin:       2479             2344             9659              210                0           579643
> > > > end:          284           232010           234142              260           772776         20917184
> > > > restore:      379           232159           234371              301           774888         20967849
> > > > 
> > > > The numbers show that
> > > > 
> > > > - The startup pgmajfault of 2.6.30-rc4-mm is merely 1/3 that of 2.6.29.
> > > >   I'd attribute that improvement to the mmap readahead improvements :-)
> > > > 
> > > > - The pgmajfault increment during the file copy is 633-630=3 vs 260-210=50.
> > > >   That's a huge improvement - which means with the VM_EXEC protection logic,
> > > >   active mmap pages is pretty safe even under partially cache hot streaming IO.
> > > > 
> > > > - when active:inactive file lru size reaches 1:1, their scan rates is 1:20.8
> > > >   under 10% cache hot IO. (computed with formula Dpgdeactivate:Dpgfree)
> > > >   That roughly means the active mmap pages get 20.8 more chances to get
> > > >   re-referenced to stay in memory.
> > > > 
> > > > - The absolute nr_mapped drops considerably to 1/9 during the big IO, and the
> > > >   dropped pages are mostly inactive ones. The patch has almost no impact in
> > > >   this aspect, that means it won't unnecessarily increase memory pressure.
> > > >   (In contrast, your 20% mmap protection ratio will keep them all, and
> > > >   therefore eliminate the extra 41 major faults to restore working set
> > > >   of zsh etc.)
> > 
> > More results on X desktop, kernel 2.6.30-rc4-mm:
> > 
> >         nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree
> > 
> > VM_EXEC protection ON:
> > begin:       9740             8920            64075              561                0           678360
> > end:          768           218254           220029              565           798953         21057006
> > restore:      857           218543           220987              606           799462         21075710
> > restore X:   2414           218560           225344              797           799462         21080795
> > 
> > VM_EXEC protection OFF:
> > begin:       9368             5035            26389              554                0           633391
> > end:          770           218449           221230              661           646472         17832500
> > restore:     1113           218466           220978              710           649881         17905235
> > restore X:   2687           218650           225484              947           802700         21083584
> > 
> > The added "restore X" means after IO, switch back and forth between the urxvt
> > and firefox windows to restore their working set. I cannot explain why the
> > absolute nr_mapped grows larger at the end of VM_EXEC OFF case. Maybe it's
> > because urxvt is the foreground window during the first run, and firefox is the
> > foreground window during the second run?
> > 
> > Like the console mode, the absolute nr_mapped drops considerably - to 1/13 of
> > the original size - during the streaming IO.
> > 
> > The delta of pgmajfault is 3 vs 107 during IO, or 236 vs 393 during the whole
> > process.
> 
> hmmm.
> 
> about 100 page fault don't match Elladan's problem, I think.
> perhaps We missed any addional reproduce condition?

Elladan's case is not the point of this test.
Elladan's IO is use-once, so probably not a caching problem at all.

This test case is specifically devised to confirm whether this patch
works as expected. Conclusion: it is.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
