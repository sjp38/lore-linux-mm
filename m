Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id BAF946B0005
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 17:43:53 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id c200so4377184wme.0
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 14:43:53 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id n123si1150280wmb.41.2016.02.09.14.43.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Feb 2016 14:43:52 -0800 (PST)
Date: Tue, 9 Feb 2016 17:42:56 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: Unhelpful caching decisions, possibly related to active/inactive
 sizing
Message-ID: <20160209224256.GA29872@cmpxchg.org>
References: <20160209165240.th5bx4adkyewnrf3@alap3.anarazel.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160209165240.th5bx4adkyewnrf3@alap3.anarazel.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Freund <andres@anarazel.de>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

Hi,

On Tue, Feb 09, 2016 at 05:52:40PM +0100, Andres Freund wrote:
> Hi,
> 
> I'm working on fixing long IO stalls with postgres. After some
> architectural changes fixing the worst issues, I noticed that indivdiual
> processes/backends/connections still spend more time waiting than I'd
> expect.
> 
> In an workload with the hot data set fitting into memory (2GB of
> mmap(HUGE|ANNON) shared memory for postgres buffer cache, ~6GB of
> dataset, 16GB total memory) I found that there's more reads hitting disk
> that I'd expect.  That's after I've led Vlastimil on IRC down a wrong
> rabbithole, sorry for that.
> 
> Some tinkering and question later, the issue appears to be postgres'
> journal/WAL. Which in the test-setup is write-only, and only touched
> again when individual segments of the WAL are reused. Which, in the
> configuration I'm using, only happens after ~20min and 30GB later or so.
> Drastically reducing the volume of WAL through some (unsafe)
> configuration options, or forcing the WAL to be written using O_DIRECT,
> changes the workload to be fully cached.
> 
> Rik asked me about active/inactive sizing in /proc/meminfo:
> Active:          7860556 kB
> Inactive:        5395644 kB
> Active(anon):    2874936 kB
> Inactive(anon):   432308 kB
> Active(file):    4985620 kB
> Inactive(file):  4963336 kB
> 
> and then said:
> 
> riel   | the workingset stuff does not appear to be taken into account for active/inactive list sizing, in vmscan.c
> riel   | I suspect we will want to expand the vmscan.c code, to take the workingset stats into account
> riel   | when we re-fault a page that was on the active list before, we want to grow the size of the active list (and
>        | shrink from inactive)
> riel   | when we re-fault a page that was never active, we need to grow the size of the inactive list (and shrink
>        | active)
> riel   | but I don't think we have any bits free in page flags for that, we may need to improvise something :)
>
> andres | Ok, at this point I'm kinda out of my depth here ;)
> 
> riel   | andres: basically active & inactive file LRUs are kept at the same size currently
> riel   | andres: which means anything that overflows half of memory will get flushed out of the cache by large write
>        | volumes (to the write-only log)
> riel   | andres: what we should do is dynamically size the active & inactive file lists, depending on which of the two
>        | needs more caching
> riel   | andres: if we never re-use the inactive pages that get flushed out, there's no sense in caching more of them
>        | (and we could dedicate more memory to the active list, instead)

Yes, a generous minimum size of the inactive list made sense when it
was the exclusive staging area to tell use-once pages from use-many
pages. Now that we have refault information to detect use-many with
arbitrary inactive list size, this minimum is no longer reasonable.

The new minimum should be smaller, but big enough for applications to
actually use the data in their pages between fault and eviction
(i.e. it needs to take the aggregate readahead window into account),
and big enough for active pages that are speculatively challenged
during workingset changes to get re-activated without incurring IO.

However, I don't think it makes sense to dynamically adjust the
balance between the active and the inactive cache during refaults.

I assume your thinking here is that when never-active pages are
refaulting during workingset transitions, it's an indication that
inactive cache need more slots, to detect use-many without incurring
IO. And hence we should give them some slots from the active cache.

However, deactivation doesn't give the inactive cache more slots to
use, it just reassigns already occupied cache slots. The only way to
actually increase the number of available inactive cache slots upon
refault would be to reclaim active cache slots.

And that is something we can't do, because we don't know how hot the
incumbent active pages actually are. They could be hotter than the
challenging refault page, they could be colder. So what we are doing
now is putting them next to each other - currently by activating the
refault page, but we could also deactivate the incumbent - and let the
aging machinery pick a winner.

[ We *could* do active list reclaim, but it would cause IO in the case
  where the incumbent workingset is challenged but not defeated.

  It's a trade-off. We just decide how strongly we want to protect the
  incumbent under challenge. ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
