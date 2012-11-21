Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 1E8AA6B0095
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 20:54:20 -0500 (EST)
Received: from /spool/local
	by e4.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <habanero@linux.vnet.ibm.com>;
	Tue, 20 Nov 2012 20:54:19 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id C5DE6C90044
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 20:54:16 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qAL1sGSn313150
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 20:54:16 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qAL1sFNi010294
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 23:54:16 -0200
Subject: Re: numa/core regressions fixed - more testers wanted
From: Andrew Theurer <habanero@linux.vnet.ibm.com>
Reply-To: habanero@linux.vnet.ibm.com
In-Reply-To: <20121120175647.GA23532@gmail.com>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
	 <20121119162909.GL8218@suse.de> <20121119191339.GA11701@gmail.com>
	 <20121119211804.GM8218@suse.de> <20121119223604.GA13470@gmail.com>
	 <CA+55aFzQYH4qW_Cw3aHPT0bxsiC_Q_ggy4YtfvapiMG7bR=FsA@mail.gmail.com>
	 <20121120071704.GA14199@gmail.com> <20121120152933.GA17996@gmail.com>
	 <20121120175647.GA23532@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 20 Nov 2012 19:54:13 -0600
Message-ID: <1353462853.31820.93.camel@oc6622382223.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Tue, 2012-11-20 at 18:56 +0100, Ingo Molnar wrote:
> * Ingo Molnar <mingo@kernel.org> wrote:
> 
> > ( The 4x JVM regression is still an open bug I think - I'll
> >   re-check and fix that one next, no need to re-report it,
> >   I'm on it. )
> 
> So I tested this on !THP too and the combined numbers are now:
> 
>                                           |
>   [ SPECjbb multi-4x8 ]                   |
>   [ tx/sec            ]  v3.7             |  numa/core-v16
>   [ higher is better  ] -----             |  -------------
>                                           |
>               +THP:      639k             |       655k            +2.5%
>               -THP:      510k             |       517k            +1.3%
> 
> So it's not a regression anymore, regardless of whether THP is 
> enabled or disabled.
> 
> The current updated table of performance results is:
> 
> -------------------------------------------------------------------------
>   [ seconds         ]    v3.7  AutoNUMA   |  numa/core-v16    [ vs. v3.7]
>   [ lower is better ]   -----  --------   |  -------------    -----------
>                                           |
>   numa01                340.3    192.3    |      139.4          +144.1%
>   numa01_THREAD_ALLOC   425.1    135.1    |	 121.1          +251.0%
>   numa02                 56.1     25.3    |       17.5          +220.5%
>                                           |
>   [ SPECjbb transactions/sec ]            |
>   [ higher is better         ]            |
>                                           |
>   SPECjbb 1x32 +THP      524k     507k    |	  638k           +21.7%
>   SPECjbb 1x32 !THP      395k             |       512k           +29.6%
>                                           |
> -----------------------------------------------------------------------
>                                           |
>   [ SPECjbb multi-4x8 ]                   |
>   [ tx/sec            ]  v3.7             |  numa/core-v16
>   [ higher is better  ] -----             |  -------------
>                                           |
>               +THP:      639k             |       655k            +2.5%
>               -THP:      510k             |       517k            +1.3%
> 
> So I think I've addressed all regressions reported so far - if 
> anyone can still see something odd, please let me know so I can 
> reproduce and fix it ASAP.

I can confirm single JVM JBB is working well for me.  I see a 30%
improvement over autoNUMA.  What I can't make sense of is some perf
stats (taken at 80 warehouses on 4 x WST-EX, 512GB memory):

tips numa/core:

     5,429,632,865 node-loads    
     3,806,419,082 node-load-misses(70.1%)        
     2,486,756,884 node-stores            
     2,042,557,277 node-store-misses(82.1%)     
     2,878,655,372 node-prefetches       
     2,201,441,900 node-prefetch-misses    

autoNUMA:

     4,538,975,144 node-loads    
     2,666,374,830 node-load-misses(58.7%)   
     2,148,950,354 node-stores  
     1,682,942,931 node-store-misses(78.3%)  
     2,191,139,475 node-prefetches  
     1,633,752,109 node-prefetch-misses 

The percentage of misses is higher for numa/core.  I would have expected
the performance increase be due to lower "node-misses", but perhaps I am
misinterpreting the perf data.

One other thing I noticed was both tests are not even using all CPU
(75-80%), so I suspect there's a JVM scalability issue with this
workload at this number of cpu threads (80).  This is a IBM JVM, so
there may be some differences.  I am curious if any of the others
testing JBB are getting 100% cpu utilization at their warehouse peak.

So, while the performance results are encouraging, I would like to
correlate it with some kind of perf data that confirms why we think it's
better.

> 
> Next I'll work on making multi-JVM more of an improvement, and 
> I'll also address any incoming regression reports.

I have issues with multiple KVM VMs running either JBB or
dbench-in-tmpfs, and I suspect whatever I am seeing is similar to
whatever multi-jvm in baremetal is.  What I typically see is no real
convergence of a single node for resource usage for any of the VMs.  For
example, when running 8 VMs, 10 vCPUs each, a VM may have the following
resource usage:

host cpu usage from cpuacct cgroup:
/cgroup/cpuacct/libvirt/qemu/at-vm01

node00             node01              node02              node03
199056918180|005%  752455339099|020%  1811704146176|049%  888803723722|024%

And VM memory placement in host(in pages):
node00		   node01	       node02              node03
107566|023%        115245|025%        117807|025%         119414|025%

Conversely, autoNUMA usually has 98+% for cpu and memory in one of the
host nodes for each of these VMs.  AutoNUMA is about 30% better in these
tests.

That is data for the entire run time, and "not converged" could possibly
mean, "converged but moved around", but I doubt that's what happening.

Here's perf data for the dbench VMs:

numa/core:

       468,634,508 node-loads
       210,598,643 node-load-misses(44.9%) 
       172,735,053 node-stores
       107,535,553 node-store-misses(51.1%) 
       208,064,103 node-prefetches 
       160,858,933 node-prefetch-misses 

autoNUMA:

       666,498,425 node-loads 
       222,643,141 node-load-misses(33.4%)
       219,003,566 node-stores 
        99,243,370 node-store-misses(45.3%) 
       315,439,315 node-prefetches 
       254,888,403 node-prefetch-misses 

These seems to make a little more sense to me, but the percentages for
autoNUMA still seem a little high (but at least lower then numa/core).
I need to take a manually pinned measurement to compare.

> Those of you who would like to test all the latest patches are 
> welcome to pick up latest bits at tip:master:
> 
>    git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git master

I've been running on numa/core, but I'll switch to master and try these
again.

Thanks,

-Andrew Theurer


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
