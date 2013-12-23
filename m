Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id E425F6B0035
	for <linux-mm@kvack.org>; Sun, 22 Dec 2013 19:44:25 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id rr13so4670822pbb.23
        for <linux-mm@kvack.org>; Sun, 22 Dec 2013 16:44:25 -0800 (PST)
Received: from LGEMRELSE6Q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id sw1si11040251pab.141.2013.12.22.16.44.23
        for <linux-mm@kvack.org>;
        Sun, 22 Dec 2013 16:44:24 -0800 (PST)
Date: Mon, 23 Dec 2013 09:44:38 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 13/14] mm, hugetlb: retry if failed to allocate and
 there is concurrent user
Message-ID: <20131223004438.GA19388@lge.com>
References: <1387349640-8071-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1387349640-8071-14-git-send-email-iamjoonsoo.kim@lge.com>
 <20131219170202.0df2d82a2adefa3ab616bdaa@linux-foundation.org>
 <20131220140153.GC11295@suse.de>
 <1387608497.3119.17.camel@buesod1.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1387608497.3119.17.camel@buesod1.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, aswin@hp.com

On Fri, Dec 20, 2013 at 10:48:17PM -0800, Davidlohr Bueso wrote:
> On Fri, 2013-12-20 at 14:01 +0000, Mel Gorman wrote:
> > On Thu, Dec 19, 2013 at 05:02:02PM -0800, Andrew Morton wrote:
> > > On Wed, 18 Dec 2013 15:53:59 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> > > 
> > > > If parallel fault occur, we can fail to allocate a hugepage,
> > > > because many threads dequeue a hugepage to handle a fault of same address.
> > > > This makes reserved pool shortage just for a little while and this cause
> > > > faulting thread who can get hugepages to get a SIGBUS signal.
> > > > 
> > > > To solve this problem, we already have a nice solution, that is,
> > > > a hugetlb_instantiation_mutex. This blocks other threads to dive into
> > > > a fault handler. This solve the problem clearly, but it introduce
> > > > performance degradation, because it serialize all fault handling.
> > > > 
> > > > Now, I try to remove a hugetlb_instantiation_mutex to get rid of
> > > > performance degradation.
> > > 
> > > So the whole point of the patch is to improve performance, but the
> > > changelog doesn't include any performance measurements!
> > > 
> > 
> > I don't really deal with hugetlbfs any more and I have not examined this
> > series but I remember why I never really cared about this mutex. It wrecks
> > fault scalability but AFAIK fault scalability almost never mattered for
> > workloads using hugetlbfs.  The most common user of hugetlbfs by far is
> > sysv shared memory. The memory is faulted early in the lifetime of the
> > workload and after that it does not matter. At worst, it hurts application
> > startup time but that is still poor motivation for putting a lot of work
> > into removing the mutex.
> 
> Yep, important hugepage workloads initially pound heavily on this lock,
> then it naturally decreases.
> 
> > Microbenchmarks will be able to trigger problems in this area but it'd
> > be important to check if any workload that matters is actually hitting
> > that problem.
> 
> I was thinking of writing one to actually get some numbers for this
> patchset -- I don't know of any benchmark that might stress this lock. 
> 
> However I first measured the amount of cycles it costs to start an
> Oracle DB and things went south with these changes. A simple 'startup
> immediate' calls hugetlb_fault() ~5000 times. For a vanilla kernel, this
> costs ~7.5 billion cycles and with this patchset it goes up to ~27.1
> billion. While there is naturally a fair amount of variation, these
> changes do seem to do more harm than good, at least in real world
> scenarios.

Hello,

I think that number of cycles is not proper to measure this patchset,
because cycles would be wasted by fault handling failure. Instead, it
targeted improved elapsed time. Could you tell me how long it
takes to fault all of it's hugepages?

Anyway, this order of magnitude still seems a problem. :/

I guess that cycles are wasted by zeroing hugepage in fault-path like as
Andrew pointed out.

I will send another patches to fix this problem.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
