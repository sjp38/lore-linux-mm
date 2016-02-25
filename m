Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 993EF6B0009
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 18:02:24 -0500 (EST)
Received: by mail-qg0-f45.google.com with SMTP id b67so52728931qgb.1
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 15:02:24 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z136si10234306qhd.112.2016.02.25.15.02.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 15:02:23 -0800 (PST)
Date: Fri, 26 Feb 2016 00:02:19 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/1] mm: thp: Redefine default THP defrag behaviour
 disable it by default
Message-ID: <20160225230219.GF1180@redhat.com>
References: <1456420339-29709-1-git-send-email-mgorman@techsingularity.net>
 <20160225190144.GE1180@redhat.com>
 <20160225195613.GZ2854@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160225195613.GZ2854@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Feb 25, 2016 at 07:56:13PM +0000, Mel Gorman wrote:
> Which is a specialised case that does not apply to all users. Remember
> that the data showed that a basic streaming write of an anon mapping on
> a freshly booted NUMA system was enough to stall the process for long
> periods of time.
> 
> Even in the specialised case, a single VM reaching its peak performance
> may rely on getting THP but if that's at the cost of reclaiming other
> pages that may be hot to a second VM then it's an overall loss.

You're mixing the concern of that THP will use more memory with the
cost of defragmentation. If you've memory issues and you are ok to
sacrifice performance for swapping less you should disable THP, set it
to never, and that's it.

The issues we're discussing here are about a system that isn't nearly
in swap but with all memory fragmented or in dirty pagecache (which
isn't too far from swapping from an I/O/writeback standpoint, but it's
different than being low on memory: using more memory in anonymous THP
memory because of THP won't move the needle in terms of the trouble
dirty page causes to the VM unless you're in the corner case where
that extra memory actually makes a difference, but if there's a
streaming writer THP on or off won't make any significant difference).

In general VM (as in virtual machine) is a case where THP will not use
any additional memory.

> Finally, for the specialised case, if it really is that critical then
> pages could be freed preemptively from userspace before the VM starts.
> For example, allocate and free X hugetlbfs pages before the migration.

Good userland should just use MADV_HUGEPAGE, it should not be required
to get root privilege to do such things by hand and try to defrag the
system by hand. It'd be also overkill to do that, perhaps the app
won't know exactly how many pages it really needs until the
computation runs.

> Right now, there are numerous tuning guides out there that are suggest
> disabling THP entirely due to the stalls. On my own desktop, I occasionally
> see a new process halt the system for a few seconds and it was possible
> to see that THP allocations were happening at the time.

Here I'm not insisting to call compaction for all cases, I'd be ok
with me if the default just relies on khugepaged, my problem is for
those apps using MADV_HUGEPAGE that needs the THP immediately. You
must live a way for the application to tell the kernel it is ok to
take time to allocate the THP as long as it gets it and that's a fine
semantic for MADV_HUGEPAGE.

khugepaged can take way more than a dozen minutes to pass over the
address space, it's simply not ok if certain workloads would run half
a slow despite they used MADV_HUGEPAGE and in turn they are telling
the kernel "this is definitely a long lived allocation for a
computation that needs THP, do everything you can to map THP here".

A "echo 3 >drop_caches; echo >compact_memory" is reasonably quick and
if the allocations are contiguous and there's not much else churning
the buddy over the NUMA zones where the app is running on, the total
cost of direct compaction won't be very different from the above two
commands. Slowing down a computation that used MADV_HUGEPAGE 50% to
save the "echo 3 >drop_caches; echo >compact_memory" total runtime
doesn't sound ok with me. It's also not ok with me that root is
required if the app tries to fixup by hand and use hugetlbfs or
/proc/sys/vm tricks to fix the layout of the buddy before starting.

> If it's critical that the performance is identical then I would suggest
> a pre-migration step of alloc/free of hugetlbfs pages to force the
> defragmentation. Alternatively trigger compaction from proc and if
> necessary use memhog to allocate/free the required memory followed by a
> proc compaction. It's a little less tidy but it solves the corner case
> while leaving the common case free of stalls.

It's not just qemu though, this is a tradeoff between short lived
allocation or long lived allocation where the apps knows it's going to
compute a lot. If the allocation is short lived there is a risk in
doing direct compaction. if the allocation is long lived and the app
notified the kernel with MADV_HUGEPAGE that it is going to run slow
without THP, there is a risk in not doing direct compaction.

Let's first agree if direct compaction is going to hurt also for the
MADV_HUGEPAGE case. I say MADV_HUGEPAGE benefits from direct
compaction and is not hurt by not doing direct compaction. If you
agree with this concept, I'd ask to change your patch, because your
patch in turn is hurting MADV_HUGEPAGE users.

Providing a really lightweight compaction that won't stall, so it can
be used always by direct reclaim can be done later anyway, that's a
secondary concern, the primary concern is not to break MADV_HUEGPAGE.

In fact after this change I think you could make MADV_HUEGPAGE call
compaction more aggressively as then we know we're not in the
once-only short lived usage case were we risk only wasting CPU. I
agree it's very hard to manage compaction for the average case were we
have no clue if compaction is going to payoff or not, but for
MADV_HUGEPAGE we know.

> Unfortunately, it'll never be perfect. We went through a cycle of having
> really high success rates of allocations in 3.0 days and the cost in
> reclaim and disruption was way too high.

compaction done in the background only really can work with a
reservation above the high watermark that can only be accessed by
emergency allocations or THP allocations, i.e. you need to spend more
RAM to make it work, like we spend RAM in the high-low wmark ranges to
make kswapd work with hysteresis. If you leave the compacted pages in
the buddy there's no way it can pay off as they'd be fragmented by
background churn before the THP fault can get an hold on them. You
should try again with a reservation.

> I think that's important but I'm not seeing right now how it's related
> to preventing processes stalling for long periods of time in direct
> reclaim and compaction.

If an app cares and forks and wants low TLB overhead it'd be nice if
it could still be guarantee to get it with MADV_HUGEPAGE as that is a
case khugepaged can't fix.

I'm still very skeptical about this patch, and the reason isn't
desktop load but MADV_HUGEPAGE apps, for those I don't think this
patch is ok.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
