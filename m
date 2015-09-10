Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0CDA56B0258
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 12:45:10 -0400 (EDT)
Received: by qgev79 with SMTP id v79so40229528qge.0
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 09:45:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g197si13966528qhc.129.2015.09.10.09.45.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Sep 2015 09:45:09 -0700 (PDT)
Date: Thu, 10 Sep 2015 18:45:06 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: Can we disable transparent hugepages for lack of a legitimate
 use case please?
Message-ID: <20150910164506.GK10639@redhat.com>
References: <BLUPR02MB1698DD8F0D1550366489DF8CCD620@BLUPR02MB1698.namprd02.prod.outlook.com>
 <20150824201952.5931089.66204.70511@amd.com>
 <BLUPR02MB1698B29C7908833FA1364C8ACD620@BLUPR02MB1698.namprd02.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BLUPR02MB1698B29C7908833FA1364C8ACD620@BLUPR02MB1698.namprd02.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Hartshorn <jhartshorn@connexity.com>
Cc: "Bridgman, John" <John.Bridgman@amd.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Aug 24, 2015 at 08:46:11PM +0000, James Hartshorn wrote:
> As a general purpose sysadmin I've mostly struggled with its default
> being always, if it were never (or possibly madvise?) then I think
> all the very real performance problems would go away.  Those who
> know they need it could turn it on.  I have begun looking into
> asking the distros to change this (is it a distro choice?) but am

My suggestion would be to: 1) identify exactly if it's a THP issue or
a compaction issue, 2) if it's really a THP issue report it to the
application developers to use the MADV_NOHUGEPAGE or the prctl to
disable THP only for the app or the library. If it's a compaction
issue disabling THP sounds wrong to me and it should be simply
reported here as a bug.

> not getting that far.  Just to be clear the default of always causes
> noticeable pauses of operation on almost all databases, analogous to
> having a stop the world gc.  As for THP in APU type applications
> have you run into any JEMalloc defrag performance issues?  My
> research into THP issues indicates this is part of the performance
> problem that manifests for databases.  Some more links to discussion
> about THP: Postgresql https://lwn.net/Articles/591723/ Postgresql
> http://www.postgresql.org/message-id/20120821131254.1415a545@jekyl.davidgould.org

"and my interpretation was that it was trying to create hugepages from
scattered fragments"

This is a very old email, but I'm just taking it as an example because
this has to be a compaction issue. If you run into very visible hangs
that goes away by disabling THP, it can't be THP to blame. THP can
increase the latency jitter during page faults (real time sensitive
application could notice a 2MB clear_page vs a 4KB clear_page), but
not in a way that hangs a system and becomes visible to the user.

It's just very early compaction code was too aggressive and it got
fixed in the meanwhile.

Worst of all is that disabling THP can't solve compaction issues
because compaction still runs even after you disable THP (drivers and
slab can still use high order pages), so it'll just hide the problem.

To disable compaction in THP just run:

echo madvise >/sys/kernel/mm/transparent_hugepage/defrag

If you got a compaction problem, this will make it go away, but you'd
still have THP on.

Considering the amount of work that went in compaction (primarily to
make it less aggressive) and how old the email is, I doubt that
problem reported in the email could still happen with current kernels.

There's current work on linux-mm (primarily from Vlastimil and David)
to make compaction asynchronous. I don't like too much the initial
proposal of offloading compaction purely to khugepaged and
disconnected to the page faults. But it would be possible to make the
page fault wakeup a kernel daemon that compact hugepages in parallel
to the page fault requests. So then the pagefault latency would become
identical to when the defrag sysfs control is set to "madvise". I
think apps that use MADV_HUGEPAGE (like qemu) should still run
compaction synchronously though. For qemu losing several hugepages
because of async behavior of compaction, would be a major loss. It's
perfectly fine if it's slower at starting up as long as it gets as
many hugepages as it can. I've seen other proposal floating around,
there's definitely work in this area to optimize compaction further.

Compaction is already much better now than in the very first version
that landed upstream so again those emails are not relevant anymore.

> Mysql (tokudb)
> https://dzone.com/articles/why-tokudb-hates-transparent

This seems a THP issue: unless the alternate malloc allocator starts
using MADV_NOHUGEPAGE, its memory loss would become extreme with the
split_huge_page pending changes from Kirill. There's little the kernel
can do about this, in fact Kirill's latest changes goes in the very
opposite direction of what's needed to reduce the memory footprint for
this MADV_DONTNEED 4kb case.

With current code however the best you can do is:

echo 0 >/sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none

That will guarantee that khugepaged never increases the memory
footprint after a MADV_DONTNEED done by the alternate malloc
allocator. Just that will definitely stop to help with the
split_huge_page pending changes. You could consider testing that but
if the split_huge_page pending changes are merged, this tuning shall
disappear.

> Redis
> http://redis.io/topics/latency http://antirez.com/news/84 Oracle

I already covered redis in detail in previous email in this
thread. This is a legitimate THP issue and for now MADV_NOHUGEPAGE
will take care of that.

If redis in the future could stop using fork() and use
clone()+userfaultfd for the snapshotting, then THP should be fine
enabled as it can control in userland the size of the wrprotect
faults.

> https://blogs.oracle.com/linux/entry/performance_issues_with_transparent_huge

At least this one document doesn't have the random reboots and
instability allegations that earlier of their documents talked about
(that I never seen here and I never had a report about... which made
me wonder why they were getting those reboots or instabilities and
which kernel they were actually using).

The very latest recent data (including a document on oracle.com) shows
a worst case 5-10% performance regression and like postgresql, they
should also consider trying again with:

echo madvise >/sys/kernel/mm/transparent_hugepage/defrag

To see if that 5-10% worst case performance regression magically
disappears while keeping THP enabled.

It'd at least help to know if this is a THP issue or a compaction
issue.

On a side note worth mentioning: Oracle has been very helpful to fix a
performance regression in O_DIRECT that materialized after THP was
merged, but that's fixed upstream for a while. Kirill's
split_huge_page pending changes will give O_DIRECT a further
boost. What's left to optimize is only barely measurable now with 2
fusion-IO and massive I/O bandwidth and orasim, not the real Oracle
database. We actually couldn't measure any difference even from that
optimization in a real Oracle load that isn't 100% I/O bound, despite
using the hardware setup with massive I/O bandwidth required to
reproduce it.

Note also that O_DIRECT currently performs identical with THP on or
off. Only Kirill's split_huge_page pending changes can give a further
small boost, disabling THP can't improve O_DIRECT performance.

I believe before disabling THP it should be identified where the
problem comes from... so if it's not a design issue like redis, we can
optimize it, like we did for the O_DIRECT case with Oracle's
helpful and appreciated contribution.

> MongoDB
> http://docs.mongodb.org/master/tutorial/transparent-huge-pages/

There's not much explanation here.

> Couchbase http://blog.couchbase.com/often-overlooked-linux-os-tweaks

"Couchbase Server can be negatively impacted by severe page allocation
delays when THP is enabled"

Like mentioned above, severe delays in page faults can only be
explained by compaction issues, trying with defrag = madvise is best.

> Riak
> http://underthehood.meltwater.com/blog/2015/04/14/riak-elasticsearch-and-numad-walk-into-a-red-hat/

This has not enough data to tell what the problem could be.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
