Date: Fri, 2 Mar 2007 10:38:33 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
In-Reply-To: <20070302015235.GG10643@holomorphy.com>
Message-ID: <Pine.LNX.4.64.0703021018070.32022@skynet.skynet.ie>
References: <20070301101249.GA29351@skynet.ie> <20070302015235.GG10643@holomorphy.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bill Irwin <bill.irwin@oracle.com>
Cc: akpm@linux-foundation.org, npiggin@suse.de, clameter@engr.sgi.com, mingo@elte.hu, Joel Schopp <jschopp@austin.ibm.com>, arjan@infradead.org, torvalds@osdl.org, mbligh@mbligh.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 1 Mar 2007, Bill Irwin wrote:

> On Thu, Mar 01, 2007 at 10:12:50AM +0000, Mel Gorman wrote:
>> These are figures based on kernels patches with Andy Whitcrofts reclaim
>> patches. You will see that the zone-based kernel is getting success rates
>> closer to 40% as one would expect although there is still something amiss.
>
> Yes, combining the two should do at least as well as either in
> isolation. Are there videos of each of the two in isolation?

Yes. Towards the end of the mail, I give links to all of the images like 
this for example;

elm3b14-vanilla       http://www.skynet.ie/~mel/anti-frag/2007-02-28/elm3b14-vanilla.avi
elm3b14-list-based    http://www.skynet.ie/~mel/anti-frag/2007-02-28/elm3b14-listbased.avi
elm3b14-zone-based    http://www.skynet.ie/~mel/anti-frag/2007-02-28/elm3b14-zonebased.avi
elm3b14-combined      http://www.skynet.ie/~mel/anti-frag/2007-02-28/elm3b14-combined.avi

In the zone-based figures, there are pages there that could be reclaimed, 
but are ignored by page reclaim because watermarks are satisified.

> Maybe that
> would give someone insight into what's happening.
>
>
> On Thu, Mar 01, 2007 at 10:12:50AM +0000, Mel Gorman wrote:
>> Kernbench Total CPU Time
>
> Oh dear. How do the other benchmarks look?
>

What other figures would you like to see and I'll generate them. Often 
kernbench is all people look for for this type of thing.

"Oh dear" implies you think the figures are bad. But on ppc64 and x86_64 
at least, the total CPU times are slightly lower with both 
anti-fragmentation patches - that's not bad. On NUMA-Q (which no one uses 
any more or is even sold), it's very marginally slower.

These are the AIM9 figures I have

AIM9 Results
                                       Vanilla Kernel   List-base Kernel  Zone-base Kernel  Combined Kernel
Machine       Arch      Test              Seconds           Seconds           Seconds          Seconds
-------     ---------  ------         --------------   ----------------  ----------------  ---------------
elm3b14     x86-numaq   page_test      115108.30           112955.68             109773.37            108073.65 
elm3b14     x86-numaq   brk_test       520593.14           494251.92             496801.07            488141.24 
elm3b14     x86-numaq   fork_test      2007.99             2005.66               2011.00              1986.35 
elm3b14     x86-numaq   exec_test      57.11               57.15                 57.27                57.01 
elm3b245    x86_64      page_test      220490.00           218166.67             224371.67            224164.31 
elm3b245    x86_64      brk_test       2178186.97          2337110.48            3025495.75           2445733.33 
elm3b245    x86_64      fork_test      4854.19             4957.51               4900.03              5001.67 
elm3b245    x86_64      exec_test      194.55              196.30                195.55               195.90 
gekko-lp1   ppc64       page_test      300368.27           310651.56             300673.33            308720.00 
gekko-lp1   ppc64       brk_test       1328895.18          1403448.85            1431489.50           1408263.91 
gekko-lp1   ppc64       fork_test      3374.42             3395.00               3367.77              3396.64 
gekko-lp1   ppc64       exec_test      152.87              153.12                151.92               153.39 
gekko-lp4   ppc64       page_test      291643.06           306906.67             294872.52            303796.03 
gekko-lp4   ppc64       brk_test       1322946.18          1366572.24            1378470.25           1403116.15 
gekko-lp4   ppc64       fork_test      3326.11             3335.00               3315.56              3333.33 
gekko-lp4   ppc64       exec_test      149.01              149.90                149.48               149.87

Many of these are showing performance improvements as well, not 
regressions.

>
> On Thu, Mar 01, 2007 at 10:12:50AM +0000, Mel Gorman wrote:
>> The patches go a long way to making sure that high-order allocations work
>> and particularly that the hugepage pool can be resized once the system has
>> been running. With the clustering of high-order atomic allocations, I have
>> some confidence that allocating contiguous jumbo frames will work even with
>> loads performing lots of IO. I think the videos show how the patches actually
>> work in the clearest possible manner.
>> I am of the opinion that both approaches have their advantages and
>> disadvantages. Given a choice between the two, I prefer list-based
>> because of it's flexibility and it should also help high-order kernel
>> allocations. However, by applying both, the disadvantages of list-based are
>> covered and there still appears to be no performance loss as a result. Hence,
>> I'd like to see both merged.  Any opinion on merging these patches into -mm
>> for wider testing?
>
> Exhibiting a workload where the list patch breaks down and the zone
> patch rescues it might help if it's felt that the combination isn't as
> good as lists in isolation. I'm sure one can be dredged up somewhere.

I can't think of a workload that totally makes a mess out of list-based. 
However, list-based makes no guarantees on availability. If a system 
administrator knows they need between 10,000 and 100,000 huge pages and 
doesn't want to waste memory pinning too many huge pages at boot-time, the 
zone-based mechanism would be what he wanted.

> Either that or someone will eventually spot why the combination doesn't
> get as many available maximally contiguous regions as the list patch.
> By and large I'm happy to see anything go in that inches hugetlbfs
> closer to a backward compatibility wrapper over ramfs.
>

Good to hear

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
