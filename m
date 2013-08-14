Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id D800D6B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 14:28:09 -0400 (EDT)
Date: Wed, 14 Aug 2013 20:28:04 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [Bug] Reproducible data corruption on i5-3340M: Please revert
 53a59fc67!
Message-ID: <20130814182756.GD24033@dhcp22.suse.cz>
References: <52050382.9060802@gmail.com>
 <520BB225.8030807@gmail.com>
 <20130814174039.GA24033@dhcp22.suse.cz>
 <CA+55aFwAz7GdcB6nC0Th42y8eAM591sKO1=mYh5SWgyuDdHzcA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwAz7GdcB6nC0Th42y8eAM591sKO1=mYh5SWgyuDdHzcA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ben Tebulin <tebulin@googlemail.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>

On Wed 14-08-13 11:03:32, Linus Torvalds wrote:
> On Wed, Aug 14, 2013 at 10:40 AM, Michal Hocko <mhocko@suse.cz> wrote:
> >>
> >> After a _very long session of rebooting and bisecting_ the Linux kernel
> >> (fortunately I had a SSD and ccache!) I was able to pinpoint the cause
> >> to the following patch:
> >>
> >> *"mm: limit mmu_gather batching to fix soft lockups on !CONFIG_PREEMPT"*
> >>   787f7301074ccd07a3e82236ca41eefd245f4e07 linux stable    [1]
> >>   53a59fc67f97374758e63a9c785891ec62324c81 upstream commit [2]
> >
> > Thanks for bisecting this up!
> >
> > I will look into this but I find it really strange.
> 
> We had a TLB invalidation bug in the case when we ran out of page
> slots (and limiting the mmu_gather batching basically forcesd an early
> case of that).
> 
> It was fixed in commit e6c495a96ce02574e765d5140039a64c8d4e8c9e ("mm:
> fix the TLB range flushed when __tlb_remove_page() runs out of
> slots"),

OK that would suggest the issue has been introduced by 597e1c35:
(mm/mmu_gather: enable tlb flush range in generic mmu_gather) in 3.6
which is not 3.7 when Ben started seeing the issue but this definitely
smells like a bug that would be amplified by the bisected patch.

Thanks for pointing this out, Linus!

> and that doesn't seem to have been marked for stable
> (probably because the commit message makes everytbody reading it think
> it's limited to ARC).
> 
> Ben, can you try back-porting that commit from mainline and see if
> that fixes things?
> 
>                  Linus
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
