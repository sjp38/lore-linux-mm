Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id CE2496B0292
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 21:48:07 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id z19so12850594oia.13
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 18:48:07 -0700 (PDT)
Received: from mail-oi0-x231.google.com (mail-oi0-x231.google.com. [2607:f8b0:4003:c06::231])
        by mx.google.com with ESMTPS id e136si5868501oih.252.2017.08.14.18.48.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 18:48:06 -0700 (PDT)
Received: by mail-oi0-x231.google.com with SMTP id e124so100462279oig.2
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 18:48:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <84c7f26182b7f4723c0fe3b34ba912a9de92b8b7.1502758114.git.tim.c.chen@linux.intel.com>
References: <84c7f26182b7f4723c0fe3b34ba912a9de92b8b7.1502758114.git.tim.c.chen@linux.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 14 Aug 2017 18:48:06 -0700
Message-ID: <CA+55aFznC1wqBSfYr8=92LGqz5-F6fHMzdXoqM4aOYx8sT1Dhg@mail.gmail.com>
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Kan Liang <kan.liang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Aug 14, 2017 at 5:52 PM, Tim Chen <tim.c.chen@linux.intel.com> wrote:
> We encountered workloads that have very long wake up list on large
> systems. A waker takes a long time to traverse the entire wake list and
> execute all the wake functions.
>
> We saw page wait list that are up to 3700+ entries long in tests of large
> 4 and 8 socket systems.  It took 0.8 sec to traverse such list during
> wake up.  Any other CPU that contends for the list spin lock will spin
> for a long time.  As page wait list is shared by many pages so it could
> get very long on systems with large memory.

I really dislike this patch.

The patch seems a band-aid for really horrible kernel behavior, rather
than fixing the underlying problem itself.

Now, it may well be that we do end up needing this band-aid in the
end, so this isn't a NAK of the patch per se. But I'd *really* like to
see if we can fix the underlying cause for what you see somehow..

In particular, if this is about the page wait table, maybe we can just
make the wait table bigger. IOW, are people actually waiting on the
*same* page, or are they mainly waiting on totally different pages,
just hashing to the same wait queue?

Because right now that page wait table is a small fixed size, and the
only reason it's a small fixed size is that nobody reported any issues
with it - particularly since we now avoid the wait table entirely for
the common cases by having that "contention" bit.

But it really is a *small* table. We literally have

   #define PAGE_WAIT_TABLE_BITS 8

so it's just 256 entries. We could easily it much bigger, if we are
actually seeing a lot of collissions.

We *used* to have a very complex per-zone thing for bit-waitiqueues,
but that was because we got lots and lots of contention issues, and
everybody *always* touched the wait-queues whether they waited or not
(so being per-zone was a big deal)

We got rid of all that per-zone complexity when the normal case didn't
hit in the page wait queues at all, but we may have over-done the
simplification a bit since nobody showed any issue.

In particular, we used to size the per-zone thing by amount of memory.
We could easily re-introduce that for the new simpler page queues.

The page_waitiqueue() is a simple helper function inside mm/filemap.c,
and thanks to the per-page "do we have actual waiters" bit that we
have now, we can actually afford to make it bigger and more complex
now if we want to.

What happens to your load if you just make that table bigger? You can
literally test by just changing the constant from 8 to 16 or
something, making us use twice as many bits for hashing. A "real"
patch would size it by amount of memory, but just for testing the
contention on your load, you can do the hacky one-liner.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
