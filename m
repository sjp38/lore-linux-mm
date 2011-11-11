Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 325CC6B002D
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 06:17:12 -0500 (EST)
Date: Fri, 11 Nov 2011 11:17:03 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: Do not stall in synchronous compaction for THP
 allocations
Message-ID: <20111111111703.GK3083@suse.de>
References: <20111110100616.GD3083@suse.de>
 <20111110142202.GE3083@suse.de>
 <CAEwNFnCRCxrru5rBk7FpypqeL8nD=SY5W3-TaA7Ap5o4CgDSbg@mail.gmail.com>
 <20111110161331.GG3083@suse.de>
 <20111110151211.523fa185.akpm@linux-foundation.org>
 <alpine.DEB.2.00.1111101536330.2194@chino.kir.corp.google.com>
 <20111111101414.GJ3083@suse.de>
 <alpine.DEB.2.00.1111110224500.7419@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1111110224500.7419@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Nov 11, 2011 at 02:39:10AM -0800, David Rientjes wrote:
> On Fri, 11 Nov 2011, Mel Gorman wrote:
> 
> > > Indeed.  It seems like the behavior would better be controlled with 
> > > /sys/kernel/mm/transparent_hugepage/defrag which is set aside specifically 
> > > to control defragmentation for transparent hugepages and for that 
> > > synchronous compaction should certainly apply.
> > 
> > With khugepaged in place, it's adding a tunable that is unnecessary and
> > will not be used. Even if such a tuneable was created, the default
> > behaviour should be "do not stall".
> > 
> 
> Not sure what you mean, the tunable already exists and defaults to always 
> if THP is turned on. 

Yes, but it does not distinguish between "always including synchronous
stalls" and "always but only if you can do it quickly". This patch
does change the behaviour of "always" but it's still using compaction
to defrag memory. A sysfs file exists, but I wanted to avoid changing
the meaning of its values if at all possible.

If a new value was to be added that would allow the user of
synchronous compaction, what should it be called? always-sync
exposes implementation details which is not great. always-force
is misleading because it wouldn't actually force anything.
always-really-really-mean-it is a bit unwieldly. always-stress might
suit but what is the meaning exactly? Using sync compaction would be
part of it but it could also mean be more agressive about reclaiming.
What level of control is required and how should it be expressed?

I don't object to the existence of this tunable as such but the
default should still be "no sync compaction for THP" because stalls due
to writing to a USB stick sucks.

> I've been able to effectively control the behavior 
> of synchronous compaction with it in combination with extfrag_threshold, 

extfrag_threshold controls whether compaction runs or not, it does not
control if synchronous compaction it used.

> i.e. always compact even if the fragmentation index is very small, for 
> workloads that really really really want hugepages at fault when such a 
> latency is permissable and then disable khugepaged entirely in the 
> background for cpu bound tasks.
> 
> The history of this boolean is somewhat disturbing: it's introduced in 
> 77f1fe6b back on January 13 to be true after the first attempt at 

It was first introduced because compaction was stalling. This was
unacceptable because the stalling cost more than hugepages saved and
was user visible. There were other patches related to reducing latency
due to compaction.

> compaction, then changed to be !(gfp_mask & __GFP_NO_KSWAPD) in 11bc82d6 

Because this was a safe option.

> on March 22, then changed to be true again in c6a140bf on May 24, then 

Because testing indicated that stalls due to sync migration were not
noticeable. For the most part, this is true but there should have
been better recognition that sync migration could also write pages
to slow storage which would be unacceptably slow.

> proposed to be changed right back to !(gfp_mask & __GFP_NO_KSWAPD) in this 
> patch again.  When are we going to understand that the admin needs to tell 
> the kernel when we'd really like to try to allocate a transparent hugepage 
> and when it's ok to fail?

I don't recall a point when this was about the administrator wanting to
control synchronous compaction. The objective was to maximise the number
of huge pages used while minimising user-visible stalls.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
