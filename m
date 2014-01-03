Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f42.google.com (mail-oa0-f42.google.com [209.85.219.42])
	by kanga.kvack.org (Postfix) with ESMTP id CC56E6B0031
	for <linux-mm@kvack.org>; Fri,  3 Jan 2014 14:55:54 -0500 (EST)
Received: by mail-oa0-f42.google.com with SMTP id i4so16618271oah.1
        for <linux-mm@kvack.org>; Fri, 03 Jan 2014 11:55:54 -0800 (PST)
Received: from g5t0009.atlanta.hp.com (g5t0009.atlanta.hp.com. [15.192.0.46])
        by mx.google.com with ESMTPS id v5si48430897oep.124.2014.01.03.11.55.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 03 Jan 2014 11:55:53 -0800 (PST)
Message-ID: <1388778945.2956.20.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH v3 13/14] mm, hugetlb: retry if failed to allocate and
 there is concurrent user
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Fri, 03 Jan 2014 11:55:45 -0800
In-Reply-To: <20131223021118.GA2487@lge.com>
References: <1387349640-8071-1-git-send-email-iamjoonsoo.kim@lge.com>
	 <1387349640-8071-14-git-send-email-iamjoonsoo.kim@lge.com>
	 <20131219170202.0df2d82a2adefa3ab616bdaa@linux-foundation.org>
	 <20131220140153.GC11295@suse.de>
	 <1387608497.3119.17.camel@buesod1.americas.hpqcorp.net>
	 <20131223004438.GA19388@lge.com> <20131223021118.GA2487@lge.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh
 Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, aswin@hp.com

Hi Joonsoo,

Sorry about the delay...

On Mon, 2013-12-23 at 11:11 +0900, Joonsoo Kim wrote:
> On Mon, Dec 23, 2013 at 09:44:38AM +0900, Joonsoo Kim wrote:
> > On Fri, Dec 20, 2013 at 10:48:17PM -0800, Davidlohr Bueso wrote:
> > > On Fri, 2013-12-20 at 14:01 +0000, Mel Gorman wrote:
> > > > On Thu, Dec 19, 2013 at 05:02:02PM -0800, Andrew Morton wrote:
> > > > > On Wed, 18 Dec 2013 15:53:59 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> > > > > 
> > > > > > If parallel fault occur, we can fail to allocate a hugepage,
> > > > > > because many threads dequeue a hugepage to handle a fault of same address.
> > > > > > This makes reserved pool shortage just for a little while and this cause
> > > > > > faulting thread who can get hugepages to get a SIGBUS signal.
> > > > > > 
> > > > > > To solve this problem, we already have a nice solution, that is,
> > > > > > a hugetlb_instantiation_mutex. This blocks other threads to dive into
> > > > > > a fault handler. This solve the problem clearly, but it introduce
> > > > > > performance degradation, because it serialize all fault handling.
> > > > > > 
> > > > > > Now, I try to remove a hugetlb_instantiation_mutex to get rid of
> > > > > > performance degradation.
> > > > > 
> > > > > So the whole point of the patch is to improve performance, but the
> > > > > changelog doesn't include any performance measurements!
> > > > > 
> > > > 
> > > > I don't really deal with hugetlbfs any more and I have not examined this
> > > > series but I remember why I never really cared about this mutex. It wrecks
> > > > fault scalability but AFAIK fault scalability almost never mattered for
> > > > workloads using hugetlbfs.  The most common user of hugetlbfs by far is
> > > > sysv shared memory. The memory is faulted early in the lifetime of the
> > > > workload and after that it does not matter. At worst, it hurts application
> > > > startup time but that is still poor motivation for putting a lot of work
> > > > into removing the mutex.
> > > 
> > > Yep, important hugepage workloads initially pound heavily on this lock,
> > > then it naturally decreases.
> > > 
> > > > Microbenchmarks will be able to trigger problems in this area but it'd
> > > > be important to check if any workload that matters is actually hitting
> > > > that problem.
> > > 
> > > I was thinking of writing one to actually get some numbers for this
> > > patchset -- I don't know of any benchmark that might stress this lock. 
> > > 
> > > However I first measured the amount of cycles it costs to start an
> > > Oracle DB and things went south with these changes. A simple 'startup
> > > immediate' calls hugetlb_fault() ~5000 times. For a vanilla kernel, this
> > > costs ~7.5 billion cycles and with this patchset it goes up to ~27.1
> > > billion. While there is naturally a fair amount of variation, these
> > > changes do seem to do more harm than good, at least in real world
> > > scenarios.
> > 
> > Hello,
> > 
> > I think that number of cycles is not proper to measure this patchset,
> > because cycles would be wasted by fault handling failure. Instead, it
> > targeted improved elapsed time. 

Fair enough, however the fact of the matter is this approach does en up
hurting performance. Regarding total startup time, I didn't see hardly
any differences, with both vanilla and this patchset it takes close to
33.5 seconds.

> Could you tell me how long it
> > takes to fault all of it's hugepages?
> > 
> > Anyway, this order of magnitude still seems a problem. :/
> > 
> > I guess that cycles are wasted by zeroing hugepage in fault-path like as
> > Andrew pointed out.
> > 
> > I will send another patches to fix this problem.
> 
> Hello, Davidlohr.
> 
> Here goes the fix on top of this series.

... and with this patch we go from 27 down to 11 billion cycles, so this
approach still costs more than what we currently have. A perf stat shows
that an entire 1Gb huge page aware DB startup costs around ~30 billion
cycles on a vanilla kernel, so the impact of hugetlb_fault() is
definitely non trivial and IMO worth considering.

Now, I took my old patchset (https://lkml.org/lkml/2013/7/26/299) for a
ride and things do look quite better, which is basically what Andrew was
suggesting previously anyway. With the hash table approach the startup
time did go down to ~25.1 seconds, which is a nice -24.7% time
reduction, with hugetlb_fault() consuming roughly 5.3 billion cycles.
This hash table was on a 80 core system, so since we do the power of two
round up we end up with 256 entries -- I think we can do better if we
enlarger further, maybe something like statically 1024, or probably
better, 8-ish * nr cpus.

Thoughts? Is there any reason why we cannot go with this instead? Yes,
we still keep the mutex, but the approach is (1) proven better for
performance on real world workloads and (2) far less invasive. 

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
