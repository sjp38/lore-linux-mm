Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 846A86B0003
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 04:14:05 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id c6-v6so11698896pll.4
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 01:14:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q20-v6sor4904130pfh.150.2018.06.19.01.14.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Jun 2018 01:14:04 -0700 (PDT)
From: Minchan Kim <minchan.kernel@gmail.com>
Date: Tue, 19 Jun 2018 17:13:57 +0900
Subject: Re: [PATCH v2 6/7] mm, proc: add KReclaimable to /proc/meminfo
Message-ID: <20180619081357.GA95482@rodete-desktop-imager.corp.google.com>
References: <20180618091808.4419-1-vbabka@suse.cz>
 <20180618091808.4419-7-vbabka@suse.cz>
 <20180618143317.eb8f5d7b6c667784343ef902@linux-foundation.org>
 <650c3fab-3137-4fe6-272a-f4ec104855a7@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <650c3fab-3137-4fe6-272a-f4ec104855a7@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-api@vger.kernel.org, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>

On Tue, Jun 19, 2018 at 09:30:03AM +0200, Vlastimil Babka wrote:
> On 06/18/2018 11:33 PM, Andrew Morton wrote:
> > On Mon, 18 Jun 2018 11:18:07 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
> > 
> >> The vmstat NR_KERNEL_MISC_RECLAIMABLE counter is for kernel non-slab
> >> allocations that can be reclaimed via shrinker. In /proc/meminfo, we can show
> >> the sum of all reclaimable kernel allocations (including slab) as
> >> "KReclaimable". Add the same counter also to per-node meminfo under /sys
> > 
> > Why do you consider this useful enough to justify adding it to
> > /pro/meminfo?  How will people use it, what benefit will they see, etc?
> 
> Let's add this:
> 
> With this counter, users will have more complete information about
> kernel memory usage. Non-slab reclaimable pages (currently just the ION
> allocator) will not be missing from /proc/meminfo, making users wonder
> where part of their memory went. More precisely, they already appear in
> MemAvailable, but without the new counter, it's not obvious why the
> value in MemAvailable doesn't fully correspond with the sum of other
> counters participating in it.

Hmm, if we could get MemAvailable with sum of other counters participating
in it, MemAvailable wouldn't be meaninful. IMO, MemAvailable don't need to
be matched with other counters.

The benefit of ION KReclaimable in real field is there are some sluggish
problem bugreport under memory pressure and found ION page pool is too
much without shrinking. In that case, that meminfo would be useful to
know something was broken in the system.

In that point of view, a concern to me is if we put more KReclaimable
pages(e.g., binder is candidate), it ends up we couldn't identify what
caches are too much among them. That means we needs KReclaimableInfo(like
slabinfo) to show each type's KReclaimable pages in future.

Anyway, it's good for first step.

> 
> > Maybe you've undersold this whole patchset, but I'm struggling a bit to
> > see what the end-user benefits are.  What would be wrong with just
> > sticking with what we have now?
> 
> Fair enough, I will add more info in reply to the cover letter.
> 
