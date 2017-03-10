Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1B0B8280901
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 09:07:22 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id y51so28949327wry.6
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 06:07:22 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f17si13021759wra.165.2017.03.10.06.07.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Mar 2017 06:07:20 -0800 (PST)
Date: Fri, 10 Mar 2017 14:07:16 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/6] Enable parallel page migration
Message-ID: <20170310140715.z6ostiatqx5oiu2i@suse.de>
References: <20170217112453.307-1-khandual@linux.vnet.ibm.com>
 <ef5efef8-a8c5-a4e7-ffc7-44176abec65c@linux.vnet.ibm.com>
 <20170309150904.pnk6ejeug4mktxjv@suse.de>
 <2a2827d0-53d0-175b-8ed4-262629e01984@nvidia.com>
 <20170309221522.hwk4wyaqx2jonru6@suse.de>
 <58C1E948.9020306@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <58C1E948.9020306@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: David Nellans <dnellans@nvidia.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Thu, Mar 09, 2017 at 05:46:16PM -0600, Zi Yan wrote:
> Hi Mel,
> 
> Thanks for pointing out the problems in this patchset.
> 
> It was my intern project done in NVIDIA last summer. I only used
> micro-benchmarks to demonstrate the big memory bandwidth utilization gap
> between base page migration and THP migration along with serialized page
> migration vs parallel page migration.
> 

The measurement itself is not a problem. It clearly shows why you were
doing it and indicates that it's possible.

> <SNIP>
> This big increase on BW utilization is the motivation of pushing this
> patchset.
> 

As before, I have no problem with the motivation, my problem is with the
approach and in particular that the serialised case was not optimised first.

> > 
> > So the key potential issue here in my mind is that THP migration is too slow
> > in some cases. What I object to is improving that using a high priority
> > workqueue that potentially starves other CPUs and pollutes their cache
> > which is generally very expensive.
> 
> I might not completely agree with this. Using a high priority workqueue
> can guarantee page migration work is done ASAP.

Yes, but at the cost of stalling other operations that are happening at
the same tiime. The series assumes that the migration is definitely the
most important operation going on at the moment.

> Otherwise, we completely
> lose the speedup brought by parallel page migration, if data copy
> threads have to wait.
> 

And conversely, if important threads were running on the other CPUs at
the time the migration started then they might be equally unhappy.

> I understand your concern on CPU utilization impact. I think checking
> CPU utilization and only using idle CPUs could potentially avoid this
> problem.
> 

That will be costly to detect actually. It would require poking into the
scheduler core and incurring a number of cache misses for a race-prone
operation that may not succeed. Even if you do it, it'll still be
brought up that the serialised case should be optimised first.

> > The function takes a huge page, splits it into PAGE_SIZE chunks, kmap_atomics
> > the source and destination for each PAGE_SIZE chunk and copies it. The
> > parallelised version does one kmap and copies it in chunks assuming the
> > THP is fully mapped and accessible. Fundamentally, this is broken in the
> > generic sense as the kmap is not guaranteed to make the whole page necessary
> > but it happens to work on !highmem systems.  What is more important to
> > note is that it's multiple preempt and pagefault enables and disables
> > on a per-page basis that happens 512 times (for THP on x86-64 at least),
> > all of which are expensive operations depending on the kernel config and
> > I suspect that the parallisation is actually masking that stupid overhead.
> 
> You are right on kmap, I think making this patchset depend on !HIGHMEM
> can avoid the problem. It might not make sense to kmap potentially 512
> base pages to migrate a THP in a system with highmem.
> 

One concern I have is that the series benefitted the most by simply batching
all those operations even if it was not intended.

> > At the very least, I would have expected an initial attempt of one patch that
> > optimised for !highmem systems to ignore kmap, simply disable preempt (if
> > that is even necessary, I didn't check) and copy a pinned physical->physical
> > page as a single copy without looping on a PAGE_SIZE basis and see how
> > much that gained. Do it initially for THP only and worry about gigantic
> > pages when or if that is a problem.
> 
> I can try this out to show how much improvement we can obtain from
> existing THP migration, which is shown in the data above.
> 

It would be important to do so. There would need to be absolute proof
that parallelisation is required and even then the concerns about
interfering with workloads on other CPUs is not going to be easy to
handle.

> > That would be patch 1 of a series.  Maybe that'll be enough, maybe not but
> > I feel it's important to optimise the serialised case as much as possible
> > before considering parallelisation to highlight and justify why it's
> > necessary[1]. If nothing else, what if two CPUs both parallelise a migration
> > at the same time and end up preempting each other? Between that and the
> > workqueue setup, it's potentially much slower than an optimised serial copy.
> > 
> > It would be tempting to experiment but the test case was not even included
> > with the series (maybe it's somewhere else)[2]. While it's obvious how
> > such a test case could be constructed, it feels unnecessary to construct
> > it when it should be in the changelog.
> 
> Do you mean performing multiple parallel page migrations at the same
> time and show all the page migration time?

I mean that the test case that was used to generate the bandwidth
utilisation figures should be included.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
