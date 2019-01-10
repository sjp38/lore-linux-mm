Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 02C2B8E0002
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 16:29:41 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id r24so5088640otk.7
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 13:29:40 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 42sor37072559oti.51.2019.01.10.13.29.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 13:29:39 -0800 (PST)
MIME-Version: 1.0
References: <154690326478.676627.103843791978176914.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154690327057.676627.18166704439241470885.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190110105638.GJ28934@suse.de>
In-Reply-To: <20190110105638.GJ28934@suse.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 10 Jan 2019 13:29:27 -0800
Message-ID: <CAPcyv4gkSBW5Te0RZLrkxzufyVq56-7pHu__YfffBiWhoqg7Yw@mail.gmail.com>
Subject: Re: [PATCH v7 1/3] mm: Shuffle initial free memory to improve
 memory-side-cache utilization
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@linux.intel.com>, Mike Rapoport <rppt@linux.ibm.com>, Keith Busch <keith.busch@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Jan 10, 2019 at 2:57 AM Mel Gorman <mgorman@suse.de> wrote:
>
> On Mon, Jan 07, 2019 at 03:21:10PM -0800, Dan Williams wrote:
> > Randomization of the page allocator improves the average utilization of
> > a direct-mapped memory-side-cache. Memory side caching is a platform
> > capability that Linux has been previously exposed to in HPC
> > (high-performance computing) environments on specialty platforms. In
> > that instance it was a smaller pool of high-bandwidth-memory relative to
> > higher-capacity / lower-bandwidth DRAM. Now, this capability is going to
> > be found on general purpose server platforms where DRAM is a cache in
> > front of higher latency persistent memory [1].
> >
>
> So I glanced through the series and while I won't nak it, I'm not a
> major fan either so I won't ack it either.

Thanks for taking a look, some more comments / advocacy below...
because I'm not sure what Andrew will do with a "meh" response
compared to an ack.

> While there are merits to
> randomisation in terms of cache coloring, it may not be robust. IIRC, the
> main strength of randomisation vs being smart was "it's simple and usually
> doesn't fall apart completely". In particular I'd worry that compaction
> will undo all the randomisation work by moving related pages into the same
> direct-mapped lines. Furthermore, the runtime list management of "randomly
> place and head or tail of list" will have variable and non-deterministic
> outcomes and may also be undone by either high-order merging or compaction.

It's a fair point. To date we have not been able to measure the
average performance degrading over time (pages becoming more ordered)
but that said I think it would take more resources and time than I
have available for that trend to present. If it did present that would
only speak to a need to be more aggressive on the runtime
re-randomization. I think there's a case to be made to start simple
and only get more aggressive with evidence.

Note that higher order merging is not a current concern since the
implementation is already randomizing on MAX_ORDER sized pages. Since
memory side caches are so large there's no worry about a 4MB
randomization boundary.

However, for the (unproven) security use case where folks want to
experiment with randomizing on smaller granularity, they should be
wary of this (/me nudges Kees).

> As bad as it is, an ideal world would have a proper cache-coloring
> allocation algorithm but they previously failed as the runtime overhead
> exceeded the actual benefit, particularly as fully associative caches
> became more popular and there was no universal "one solution fits all". One
> hatchet job around it may be to have per-task free-lists that put free
> pages into buckets with the obvious caveat that those lists would need
> draining and secondary locking. A caveat of that is that there may need
> to be arch and/or driver hooks to detect how the colors are managed which
> could also turn into a mess.

We (Dave, I and others that took a look at this) started here, and the
"mess" looked daunting compared to randomization. Also a mess without
much more incremental benefit.

We also settled on a numa_emulation based approach for the cases where
an administrator knows they have a workload that can fit in the
cache... more on that below:

> The big plus of the series is that it's relatively simple and appears to
> be isolated enough that it only has an impact when the necessary hardware
> in place. It will deal with some cases but I'm not sure it'll survive
> long-term, particularly if HPC continues to report in the field that
> reboots are necessary to reshufffle the lists (taken from your linked
> documents). That workaround of running STREAM before a job starts and
> rebooting the machine if the performance SLAs are not met is horrid.

That workaround is horrid, and we have a separate solution for it
merged in commit cc9aec03e58f "x86/numa_emulation: Introduce uniform
split capability". When an administrator knows in advance that a
workload will fit in cache they can use this capability to run the
workload in a numa node that is guaranteed to not have cache conflicts
with itself.

Whereas randomization benefits the general cache-overcommit case. The
uniform numa split case addresses those niche users that can manually
time schedule jobs with different working set sizes... without needing
to reboot.
