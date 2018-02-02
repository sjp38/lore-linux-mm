Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id CC1D86B0005
	for <linux-mm@kvack.org>; Fri,  2 Feb 2018 12:47:25 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id j13so4033698wmh.3
        for <linux-mm@kvack.org>; Fri, 02 Feb 2018 09:47:25 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 1si574382wrt.506.2018.02.02.09.47.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 02 Feb 2018 09:47:24 -0800 (PST)
Date: Fri, 2 Feb 2018 17:47:21 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [Resend] Possible bug in __fragmentation_index()
Message-ID: <20180202174721.f63gume3klxevkbj@suse.de>
References: <83AECC32-77A4-427D-9043-DE6FC48AD3FC@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <83AECC32-77A4-427D-9043-DE6FC48AD3FC@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert Harris <robert.m.harris@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Kemi Wang <kemi.wang@intel.com>, ying.huang@intel.com, David Rientjes <rientjes@google.com>, Vinayak Menon <vinmenon@codeaurora.org>

On Fri, Feb 02, 2018 at 02:16:39PM +0000, Robert Harris wrote:
> I was planning to annotate the opaque calculation in
> __fragmentation_index() but on closer inspection I think there may be a
> bug.  I could use some feedback.
> 
> Firstly, for the case of fragmentation and ignoring the scaling,
> __fragmentation_index() purports to return a value in the range 0 to 1.
> Generally, however, the lower bound is actually 0.5.  Here's an
> illustration using a zone that I fragmented with selective calls to
> __alloc_pages() and __free_pages --- the fragmentation for order-1 could
> not be minimised further yet is reported as 0.5:
> 
> # head -1 /proc/buddyinfo
> Node 0, zone      DMA   1983      0      0      0      0      0      0      0      0      0      0 
> # head -1 /sys/kernel/debug/extfrag/extfrag_index 
> Node 0, zone      DMA -1.000 0.500 0.750 0.875 0.937 0.969 0.984 0.992 0.996 0.998 0.999 
> #
> 
> This is significant because 0.5 is the default value of
> sysctl_extfrag_threshold, meaning that compaction will not be suppressed
> for larger blocks when memory is scarce rather than fragmented.  Of
> course, sysctl_extfrag_threshold is a tuneable so the first question is:
> does this even matter?
> 

It's now 8 years since it was written so my memory is rusty. While the bounds
could be adjusted, it's not without risk. The bounds were left as-is and
the sysctl to avoid possibilties of excessive reclaim -- something early
implementations suffered badly. At the time of implementation, it was used
as a rough estimate for monitoring purposes but on an allocation failure,
it was always page reclaim that was used to try the allocation again.

At a later time, compaction was introduced to avoid excessive reclaim
but the cutoff was set to only happen for extreme memory shortage (and
the bounds should have been corrected at the time but were not).  It was
a long time before all the excessive reclaim bugs in kswapd were ironed
out but bugs of runaway kswapd at 100% CPU usage were common for a while.
There were also severeal problems with compaction overhead that were
adjusted in other matters. It may have reached the point where revisiting
the sysctl is potentially safe given that reclaim is considerably better
than it used to be.

> meaning that a very severe shortage of free memory *could* tip the
> balance in favour of "low fragmentation".  Although this seems highly
> unlikely to occur outside testing, it does reflect the directive in the
> comment above the function, i.e. favour page reclaim when fragmentation
> is low.  My second question: is the current implementation of F is
> intentional and, if not, what is the actual intent?
> 

It's intentional but could be fixed to give a real bound of 0 to 1 instead
of half the range as it currently give. The sysctl_extfrag_threshold should
also be adjusted at that time. After that, the real work is determining
if it's safe to strike a balance between reclaim/compaction that avoids
unnecessary compaction while not being too aggressive about reclaim or
having kswapd enter a runaway loop with a reintroduction of the "kswapd
stuck at 100% CPU time" problems.

Alternative, delete references to it entirely as the cutoff is not really
being used and the monitoring information is too specialised to be of
general use.

> The comments in compaction_suitable() suggest that the compaction/page
> reclaim decision is one of cost but, as compaction is linear, this isn't
> what __fragmentation_index() is calculating. 

The index was not intended as an estimate of the cost of compaction. It
was originally intended to act as an estimator of whether it's ebtter to
spend time reclaiming or compacting. Compacting was favoured on the
grounds that high order allocations were meant to be able to fail where
as reclaiming potentially useful data could have other consequences.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
