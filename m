Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id EBF076B025F
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 15:41:03 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id f11so2081569oic.3
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 12:41:03 -0700 (PDT)
Received: from mail-oi0-x243.google.com (mail-oi0-x243.google.com. [2607:f8b0:4003:c06::243])
        by mx.google.com with ESMTPS id 127si6519168oid.192.2017.08.15.12.41.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 12:41:02 -0700 (PDT)
Received: by mail-oi0-x243.google.com with SMTP id s21so1658809oie.5
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 12:41:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0b7b6132-a374-9636-53f9-c2e1dcec230f@linux.intel.com>
References: <84c7f26182b7f4723c0fe3b34ba912a9de92b8b7.1502758114.git.tim.c.chen@linux.intel.com>
 <CA+55aFznC1wqBSfYr8=92LGqz5-F6fHMzdXoqM4aOYx8sT1Dhg@mail.gmail.com>
 <20170815022743.GB28715@tassilo.jf.intel.com> <CA+55aFyHVV=eTtAocUrNLymQOCj55qkF58+N+Tjr2YS9TrqFow@mail.gmail.com>
 <20170815031524.GC28715@tassilo.jf.intel.com> <CA+55aFw1A1C8qUeKPUzACrsqn97UDxTP3M2SRs80aEztfU=Qbg@mail.gmail.com>
 <0b7b6132-a374-9636-53f9-c2e1dcec230f@linux.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 15 Aug 2017 12:41:01 -0700
Message-ID: <CA+55aFymeC-s6rkGk4==3RjZu6nyyj2R9c5TBzpwTwJd4yjf2A@mail.gmail.com>
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Andi Kleen <ak@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Kan Liang <kan.liang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Aug 15, 2017 at 12:05 PM, Tim Chen <tim.c.chen@linux.intel.com> wrote:
>
> We have a test case but it is a customer workload.  We'll try to get
> a bit more info.

Ok. Being a customer workload is lovely in the sense that it is
actually a real load, not just a microbecnhmark.

But yeah, it makes it harder to describe and show what's going on.

But you do have access to that workload internally at Intel, and can
at least test things out that way, I assume?

> I agree that dynamic sizing makes a lot of sense.  We'll check to
> see if additional size to the hash table helps, assuming that the
> waiters are distributed among different pages for our test case.

One more thing: it turns out that there are two very different kinds
of users of the page waitqueue.

There's the "wait_on_page_bit*()" users - people waiting for a page to
unlock or stop being under writeback etc.

Those *should* generally be limited to just one wait-queue per waiting
thread, I think.

Then there is the "cachefiles" use, which ends up adding a lot of
waitqueues to a lot of paghes to monitor their state.

Honestly, I think that second use a horrible hack. It basically adds a
waitqueue to each page in order to get a callback when it is ready,
and then copies it.

And it does this for things like cachefiles_read_backing_file(), so
you might have a huge list of pages for copying a large file, and it
adds a callback for every single one of those all at once.

The fix for the cachefiles behavior might be very different from the
fix to the "normal" operations. But making the wait queue hash tables
bigger _should_ help both cases.

We might also want to hash based on the actual bit we're waiting for.
Right now we just do a

        wait_queue_head_t *q = page_waitqueue(page);

but I think the actual bit is always explicit (well, the cachefiles
interface doesn't have that, but looking at the callback for that, it
really only cares about PG_locked, so it *should* make the bit it is
waiting for explicit).

So if we have unnecessarily collisions because we have waiters looking
at different bits of the same page, we could just hash in the bit
number that we're waiting for too.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
