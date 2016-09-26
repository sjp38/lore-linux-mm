Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6271B280274
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 16:58:04 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id i193so557051087oib.3
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 13:58:04 -0700 (PDT)
Received: from mail-oi0-x242.google.com (mail-oi0-x242.google.com. [2607:f8b0:4003:c06::242])
        by mx.google.com with ESMTPS id e205si6192071oif.220.2016.09.26.13.58.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 13:58:01 -0700 (PDT)
Received: by mail-oi0-x242.google.com with SMTP id a62so14354766oib.1
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 13:58:01 -0700 (PDT)
MIME-Version: 1.0
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 26 Sep 2016 13:58:00 -0700
Message-ID: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
Subject: page_waitqueue() considered harmful
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>

So I've been doing some profiling of the git "make test" load, which
is interesting because it's just a lot of small scripts, and it shows
our fork/execve/exit costs.

Some of the top offenders are pretty understandable: we have long had
unmap_page_range() show up at the top on these loads, because the
zap_pte_range() function ends up touching each page as it unmaps
things (it does it to check whether it's an anonymous page, but then
also for the page map count update etc), and that's a disaster from a
cache standpoint. That single function is something between 3-4% of
CPU time, and the one instruction that accesses "struct page" the
first time is a large portion of that. Yes, a single instruction is
blamed for about 1% of all CPU time on a fork/exec/exit workload.

Anyway, there really isn't a ton to be done about it. Same goes for
the reverse side of the coin: filemap_map_pages() (to map in the new
executable pages) is #2, and copy_page() (COW after fork()) is #3.
Those are all kind of inevitable for the load.

#4 on my list is "native_irq_return_iret", which is just a sign of
serializing instructions being really expensive, and this being a
workload with a lot of exceptions (most of which are the page faults).
So I guess there are *two* instructions in the kernel that are really
really hot. Maybe Intel will fix the cost of "iret" some day, at least
partially, but that day has not yet come to pass.

Anyway, things get kind of interesting once you get past the very top
offenders, and the profile starts to be less about "yeah, tough, can't
fix that" and instead hit things that make you go "ehh, really?"

#5 and #6 on my profile are user space (_int_malloc in glibc, and
do_lookup_x in the loader - I think user space should probably start
thinking more about doing static libraries for the really core basic
things, but whatever. Not a kernel issue.

#7 is in the kernel again. And that one struck me as really odd. It's
"unlock_page()", while #9 is __wake_up_bit(). WTF? There's no IO in
this load, it's all cached, why do we use 3% of the time (1.7% and
1.4% respectively) on unlocking a page. And why can't I see the
locking part?

It turns out that I *can* see the locking part, but it's pretty cheap.
It's inside of filemap_map_pages(), which does a trylock, and it shows
up as about 1/6th of the cost of that function. Still, it's much less
than the unlocking side. Why is unlocking so expensive?

Yeah, unlocking is expensive because of the nasty __wake_up_bit()
code. In fact, even inside "unlock_page()" itself, most of the costs
aren't even the atomic bit clearing (like you'd expect), it's the
inlined part of wake_up_bit(). Which does some really nasty crud.

Why is the page_waitqueue() handling so expensive? Let me count the ways:

 (a) stupid code generation interacting really badly with microarchitecture

     We clear the bit in page->flags with a byte-sized "lock andb",
and then page_waitqueue() looks up the zone by reading the full value
of "page->flags" immediately afterwards, which causes bad bad behavior
with the whole read-after-partial-write thing. Nasty.

 (b) It's cache miss heaven. It takes a cache miss on three different
things:looking up the zone 'wait_table', then looking up the hash
queue there, and finally (inside __wake_up_bit) looking up the wait
queue itself (which will effectively always be NULL).

Now, (a) could be fairly easy to fix several ways (the byte-size
operation on an "unsigned long" field have caused problems before, and
may just be a mistake), but (a) wouldn't even be a problem if we
didn't have the complexity of (b) and having to look up the zone and
everything. So realistically, it's actually (b) that is the primary
problem, and indirectly causes (a) to happen too.

Is there really any reason for that incredible indirection? Do we
really want to make the page_waitqueue() be a per-zone thing at all?
Especially since all those wait-queues won't even be *used* unless
there is actual IO going on and people are really getting into
contention on the page lock.. Why isn't the page_waitqueue() just one
statically sized array?

Also, if those bitlock ops had a different bit that showed contention,
we could actually skip *all* of this, and just see that "oh, nobody is
waiting on this page anyway, so there's no point in looking up those
wait queues". We don't have that many "__wait_on_bit()" users, maybe
we could say that the bitlocks do have to haev *two* bits: one for the
lock bit itself, and one for "there is contention".

Looking at the history of this code, most of it actually predates the
git history, it goes back to ~2004. Time to revisit that thing?

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
