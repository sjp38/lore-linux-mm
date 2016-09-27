Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 93AC028024E
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 04:04:11 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id b71so10935176lfg.2
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 01:04:11 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 125si12513066wmz.124.2016.09.27.01.03.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Sep 2016 01:03:38 -0700 (PDT)
Date: Tue, 27 Sep 2016 10:03:31 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: page_waitqueue() considered harmful
Message-ID: <20160927080331.GD1139@quack2.suse.cz>
References: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

Hello,

On Mon 26-09-16 13:58:00, Linus Torvalds wrote:
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
>  (a) stupid code generation interacting really badly with microarchitecture
> 
>      We clear the bit in page->flags with a byte-sized "lock andb",
> and then page_waitqueue() looks up the zone by reading the full value
> of "page->flags" immediately afterwards, which causes bad bad behavior
> with the whole read-after-partial-write thing. Nasty.
> 
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
> Is there really any reason for that incredible indirection? Do we
> really want to make the page_waitqueue() be a per-zone thing at all?
> Especially since all those wait-queues won't even be *used* unless
> there is actual IO going on and people are really getting into
> contention on the page lock.. Why isn't the page_waitqueue() just one
> statically sized array?
> 
> Also, if those bitlock ops had a different bit that showed contention,
> we could actually skip *all* of this, and just see that "oh, nobody is
> waiting on this page anyway, so there's no point in looking up those
> wait queues". We don't have that many "__wait_on_bit()" users, maybe
> we could say that the bitlocks do have to haev *two* bits: one for the
> lock bit itself, and one for "there is contention".

So we were carrying patches in SUSE kernels for a long time that did
something like this (since 2011 it seems) since the unlock_page() was
pretty visible on some crazy SGI workload on their supercomputer. But they
were never accepted upstream and eventually we mostly dropped them (some
less intrusive optimizations got merged) when rebasing on 3.12 - Mel did
the evaluation at that time so he should be able to fill in details but at
one place he writes:

"These patches lack a compelling use case for pushing to mainline.  They
show a measurable gain in profiles but the gain is in the noise for the
whole workload. It is known to improve boot times on very large machines
and help an artifical test case but that is not a compelling reason to
consume a page flag and push it to mainline. The patches are held in
reserve until a compelling case for them is found."

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
