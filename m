Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 0A33E6B0062
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 03:37:08 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so1844092pad.14
        for <linux-mm@kvack.org>; Mon, 22 Oct 2012 00:37:08 -0700 (PDT)
Date: Mon, 22 Oct 2012 15:36:54 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [PATCH RFC] mm/swap: automatic tuning for swapin readahead
Message-ID: <20121022073654.GA7821@kernel.org>
References: <50460CED.6060006@redhat.com>
 <20120906110836.22423.17638.stgit@zurg>
 <alpine.LSU.2.00.1210011418270.2940@eggly.anvils>
 <506AACAC.2010609@openvz.org>
 <alpine.LSU.2.00.1210031337320.1415@eggly.anvils>
 <506DB816.9090107@openvz.org>
 <alpine.LSU.2.00.1210081451410.1384@eggly.anvils>
 <20121016005049.GA1467@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121016005049.GA1467@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Oct 16, 2012 at 08:50:49AM +0800, Shaohua Li wrote:
> On Mon, Oct 08, 2012 at 03:09:58PM -0700, Hugh Dickins wrote:
> > On Thu, 4 Oct 2012, Konstantin Khlebnikov wrote:
> > 
> > > Here results of my test. Workload isn't very realistic, but at least it
> > > threaded: compiling linux-3.6 with defconfig in 16 threads on tmpfs,
> > > 512mb ram, dualcore cpu, ordinary hard disk. (test script in attachment)
> > > 
> > > average results for ten runs:
> > > 
> > > 		RA=3	RA=0	RA=1	RA=2	RA=4	Hugh	Shaohua
> > > real time	500	542	528	519	500	523	522
> > > user time	738	737	735	737	739	737	739
> > > sys time	93	93	91	92	96	92	93
> > > pgmajfault	62918	110533	92454	78221	54342	86601	77229
> > > pgpgin	2070372	795228	1034046	1471010	3177192	1154532	1599388
> > > pgpgout	2597278	2022037	2110020	2350380	2802670	2286671	2526570
> > > pswpin	462747	138873	202148	310969	739431	232710	341320
> > > pswpout	646363	502599	524613	584731	697797	568784	628677
> > > 
> > > So, last two columns shows mostly equal results: +4.6% and +4.4% in
> > > comparison to vanilla kernel with RA=3, but your version shows more stable
> > > results (std-error 2.7% against 4.8%) (all this numbers in huge table in
> > > attachment)
> > 
> > Thanks for doing this, Konstantin, but I'm stuck for anything much to say!
> > Shaohua and I are both about 4.5% bad for this particular test, but I'm
> > more consistently bad - hurrah!
> > 
> > I suspect (not a convincing argument) that if the test were just slightly
> > different (a little more or a little less memory, SSD instead of hard
> > disk, diskcache instead of tmpfs), then it would come out differently.
> > 
> > Did you draw any conclusions from the numbers you found?
> > 
> > I haven't done any more on this in the last few days, except to verify
> > that once an anon_vma is judged random with Shaohua's, then it appears
> > to be condemned to no-readahead ever after.
> > 
> > That's probably something that a hack like I had in mine would fix,
> > but that addition might change its balance further (and increase vma
> > or anon_vma size) - not tried yet.
> > 
> > All I want to do right now, is suggest to Andrew that he hold Shaohua's
> > patch back from 3.7 for the moment: I'll send a response to Sep 7th's
> > mm-commits mail to suggest that - but no great disaster if he ignores me.
> 
> Ok, I tested Hugh's patch. My test is a multithread random write workload.
> With Hugh's patch, 49:28.06elapsed
> With mine, 43:23.39elapsed
> There is 12% more time used with Hugh's patch.
> 
> In the stable state of this workload, SI:SO ratio should be roughly 1:1. With
> Hugh's patch, it's around 1.6:1, there is still unnecessary swapin.
> 
> I also tried a workload with seqential/random write mixed, Hugh's patch is 10%
> bad too.

With below change, the si/so ratio is back to around 1:1 in my workload. Guess
the run time of my test will be reduced too, though I didn't test yet.
-	used = atomic_xchg(&swapra_hits, 0) + 1;
+	used = atomic_xchg(&swapra_hits, 0);

I'm wondering how could a global counter based method detect readahead
correctly. For example, if there are a sequential access thread and a random
access thread, doesn't this method always make wrong decision?

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
