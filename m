Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id CA13C28024E
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 04:31:53 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id n4so11870956lfb.3
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 01:31:53 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id j6si1215073wjv.96.2016.09.27.01.31.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Sep 2016 01:31:07 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 8F10698DDD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 08:31:06 +0000 (UTC)
Date: Tue, 27 Sep 2016 09:31:04 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: page_waitqueue() considered harmful
Message-ID: <20160927083104.GC2838@techsingularity.net>
References: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>


Hi Linus,

On Mon, Sep 26, 2016 at 01:58:00PM -0700, Linus Torvalds wrote:
> So I've been doing some profiling of the git "make test" load, which
> is interesting because it's just a lot of small scripts, and it shows
> our fork/execve/exit costs.
> 
> Some of the top offenders are pretty understandable: we have long had
> unmap_page_range() show up at the top on these loads, because the
> zap_pte_range() function ends up touching each page as it unmaps
> things (it does it to check whether it's an anonymous page, but then
> also for the page map count update etc), and that's a disaster from a
> cache standpoint. That single function is something between 3-4% of
> CPU time, and the one instruction that accesses "struct page" the
> first time is a large portion of that. Yes, a single instruction is
> blamed for about 1% of all CPU time on a fork/exec/exit workload.
> 

It was found at one point that the fault-around made these costs worse as
there were simply more pages to tear down. However, this only applied to
fork/exit microbenchmarks.  Matt Fleming prototyped an unreleased patch
that tried to be clever about this but the cost was never worthwhile. A
plain revert helped a microbenchmark but hurt workloads like the git
testsuite which was shell intensive.

It got filed under "we're not fixing a fork/exit microbenchmark at the
expense of "real" workloads like git checkout and git testsuite".

> <SNIP>
>
> #5 and #6 on my profile are user space (_int_malloc in glibc, and
> do_lookup_x in the loader - I think user space should probably start
> thinking more about doing static libraries for the really core basic
> things, but whatever. Not a kernel issue.
> 

Recent problems have been fixed with _int_malloc in glibc, particularly as it
applies to threads but no fix springs to mind that might impact "make test".

> #7 is in the kernel again. And that one struck me as really odd. It's
> "unlock_page()", while #9 is __wake_up_bit(). WTF? There's no IO in
> this load, it's all cached, why do we use 3% of the time (1.7% and
> 1.4% respectively) on unlocking a page. And why can't I see the
> locking part?
> 
> It turns out that I *can* see the locking part, but it's pretty cheap.
> It's inside of filemap_map_pages(), which does a trylock, and it shows
> up as about 1/6th of the cost of that function. Still, it's much less
> than the unlocking side. Why is unlocking so expensive?
> 
> Yeah, unlocking is expensive because of the nasty __wake_up_bit()
> code. In fact, even inside "unlock_page()" itself, most of the costs
> aren't even the atomic bit clearing (like you'd expect), it's the
> inlined part of wake_up_bit(). Which does some really nasty crud.
> 
> Why is the page_waitqueue() handling so expensive? Let me count the ways:
> 

page_waitqueue() has been a hazard for years. I think the last attempt to
fix it was back in 2014 http://www.spinics.net/lists/linux-mm/msg73207.html

The patch is heavily derived from work by Nick Piggin who noticed the years
before that. I think that was the last version I posted and the changelog
includes profile data. I don't have an exact reference why it was rejected
but a consistent piece of feedback was that it was very complex for the
level of impact it had.

>  (a) stupid code generation interacting really badly with microarchitecture
> 
>      We clear the bit in page->flags with a byte-sized "lock andb",
> and then page_waitqueue() looks up the zone by reading the full value
> of "page->flags" immediately afterwards, which causes bad bad behavior
> with the whole read-after-partial-write thing. Nasty.
> 

Other than some code churn, it should be possible to lookup the waitqueue
before clearing the bit if the patch that side-steps the lookup entirely
is still distasteful.

>  (b) It's cache miss heaven. It takes a cache miss on three different
> things:looking up the zone 'wait_table', then looking up the hash
> queue there, and finally (inside __wake_up_bit) looking up the wait
> queue itself (which will effectively always be NULL).
> 
> Now, (a) could be fairly easy to fix several ways (the byte-size
> operation on an "unsigned long" field have caused problems before, and
> may just be a mistake), but (a) wouldn't even be a problem if we
> didn't have the complexity of (b) and having to look up the zone and
> everything. So realistically, it's actually (b) that is the primary
> problem, and indirectly causes (a) to happen too.
> 

The patch in question side-steps the (b) part.

> Is there really any reason for that incredible indirection? Do we
> really want to make the page_waitqueue() be a per-zone thing at all?
> Especially since all those wait-queues won't even be *used* unless
> there is actual IO going on and people are really getting into
> contention on the page lock.. Why isn't the page_waitqueue() just one
> statically sized array?
> 

About all I can think of is NUMA locality. Doing it per-zone at the time
would be convenient. It could be per-node but that's no better from a
complexity point of view. If it was a static array, the key could be related
to the node the page is on but that's still looking into the page flags.

> Also, if those bitlock ops had a different bit that showed contention,
> we could actually skip *all* of this, and just see that "oh, nobody is
> waiting on this page anyway, so there's no point in looking up those
> wait queues".

That's very close to what the 2014 patch does. However, it's 64-bit only
due to the use of page flags. Even though it's out of date, can you take
a look? If it doesn't trigger hate, I can forward port it unless you do
that yourself for the purposes of testing.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
