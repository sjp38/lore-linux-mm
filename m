Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 412256B02C3
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 12:43:15 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z81so1998778wrc.2
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 09:43:15 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id b27si335057wra.164.2017.07.06.09.43.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 06 Jul 2017 09:43:13 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 42DE1985D2
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 16:43:13 +0000 (UTC)
Date: Thu, 6 Jul 2017 17:43:12 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: make allocation counters per-order
Message-ID: <20170706164312.4nnjsrpzv5vbtbkm@techsingularity.net>
References: <1499346271-15653-1-git-send-email-guro@fb.com>
 <20170706131941.omod4zl4cyuscmjo@techsingularity.net>
 <CAATkVEyuqQhiL1G=UyOqwABbUGJn2XNvnYpiOp-F3Zb659uOdQ@mail.gmail.com>
 <20170706155123.cyyjpvraifu5ptmr@techsingularity.net>
 <CAATkVEzuFq5UWasE87Eo_F4aQxkuYWqSGJh5bBnieC=686NyqA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAATkVEzuFq5UWasE87Eo_F4aQxkuYWqSGJh5bBnieC=686NyqA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Debabrata Banerjee <dbavatar@gmail.com>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Rik van Riel <riel@redhat.com>, kernel-team@fb.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Jul 06, 2017 at 12:12:47PM -0400, Debabrata Banerjee wrote:
> On Thu, Jul 6, 2017 at 11:51 AM, Mel Gorman <mgorman@techsingularity.net> wrote:
> >
> > These counters do not actually help you solve that particular problem.
> > Knowing how many allocations happened since the system booted doesn't tell
> > you much about how many failed or why they failed. You don't even know
> > what frequency they occured at unless you monitor it constantly so you're
> > back to square one whether this information is available from proc or not.
> > There even is a tracepoint that can be used to track information related
> > to events that degrade fragmentation (trace_mm_page_alloc_extfrag) although
> > the primary thing it tells you is that "the probability that an allocation
> > will fail due to fragmentation in the future is potentially higher".
> 
> I agree these counters don't have enough information, but there a
> start to a first order approximation of the current state of memory.

That incurs a universal cost on the off-chance of debugging and ultimately
the debugging is only useful in combination with developing kernel patches
in which case it could be behind a kconfig option.

> buddyinfo and pagetypeinfo basically show no information now, because

They can be used to calculate a fragmentation index at a given point in
time. Admittedly, building a bigger picture requires a full scan of memory
(and that's what was required when fragmentation avoidance was first
being implemented).

> they only involve the small amount of free memory under the watermark
> and all our machines are in this state. As second order approximation,
> it would be nice to be able to get answers like: "There are
> reclaimable high order allocations of at least this order" and "None
> of this order allocation can become available due to unmovable and
> unreclaimable allocations"

Which this patch doesn't provide as what you are looking for requires
a full scan of memory to determine. I've done it in the past using a
severe abuse of systemtap to load a module that scans all of memory with
a variation of PAGE_OWNER to identify stack traces of pages that "don't
belonw" within a pageblock.

Even *with* that information, your options for tuning an unmodified kernel
are basically limited to increasing min_free_kbytes, altering THP's level
of aggression when compacting or brute forcing with either drop_caches,
compact_node or both. All other options after that require kernel patches
-- altering annotations, altering fallback mechanisms, altering compaction,
improving support for pages that can be migrated etc.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
