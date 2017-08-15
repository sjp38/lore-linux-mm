Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0F3296B02B4
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 22:52:18 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id b130so13018438oii.4
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 19:52:18 -0700 (PDT)
Received: from mail-oi0-x236.google.com (mail-oi0-x236.google.com. [2607:f8b0:4003:c06::236])
        by mx.google.com with ESMTPS id l2si5503828oib.447.2017.08.14.19.52.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 19:52:16 -0700 (PDT)
Received: by mail-oi0-x236.google.com with SMTP id g131so100871148oic.3
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 19:52:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170815022743.GB28715@tassilo.jf.intel.com>
References: <84c7f26182b7f4723c0fe3b34ba912a9de92b8b7.1502758114.git.tim.c.chen@linux.intel.com>
 <CA+55aFznC1wqBSfYr8=92LGqz5-F6fHMzdXoqM4aOYx8sT1Dhg@mail.gmail.com> <20170815022743.GB28715@tassilo.jf.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 14 Aug 2017 19:52:16 -0700
Message-ID: <CA+55aFyHVV=eTtAocUrNLymQOCj55qkF58+N+Tjr2YS9TrqFow@mail.gmail.com>
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Kan Liang <kan.liang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Aug 14, 2017 at 7:27 PM, Andi Kleen <ak@linux.intel.com> wrote:
>
> We could try it and it may even help in this case and it may
> be a good idea in any case on such a system, but:
>
> - Even with a large hash table it might be that by chance all CPUs
> will be queued up on the same page
> - There are a lot of other wait queues in the kernel and they all
> could run into a similar problem
> - I suspect it's even possible to construct it from user space
> as a kind of DoS attack

Maybe. Which is why I didn't NAK the patch outright.

But I don't think it's the solution for the scalability issue you guys
found. It's just a workaround, and it's likely a bad one at that.

> Now in one case (on a smaller system) we debugged we had
>
> - 4S system with 208 logical threads
> - during the test the wait queue length was 3700 entries.
> - the last CPUs queued had to wait roughly 0.8s
>
> This gives a budget of roughly 1us per wake up.

I'm not at all convinced that follows.

When bad scaling happens, you often end up hitting quadratic (or
worse) behavior. So if you are able to fix the scaling by some fixed
amount, it's possible that almost _all_ the problems just go away.

The real issue is that "3700 entries" part. What was it that actually
triggered them? In particular, if it's just a hashing issue, and we
can trivially just make the hash table be bigger (256 entries is
*tiny*) then the whole thing goes away.

Which is why I really want to hear what happens if you just change
PAGE_WAIT_TABLE_BITS to 16. The right fix would be to just make it
scale by memory, but before we even do that, let's just look at what
happens when you increase the size the stupid way.

Maybe those 3700 entries will just shrink down to 14 entries because
the hash just works fine and 256 entries was just much much too small
when you have hundreds of thousands of threads or whatever

But it is *also* possible that it's actually all waiting on the exact
same page, and there's some way to do a thundering herd on the page
lock bit, for example. But then it would be really good to hear what
it is that triggers that.

The thing is, the reason we perform well on many loads in the kernel
is that I have *always* pushed back against bad workarounds.

We do *not* do lock back-off in our locks, for example, because I told
people that lock contention gets fixed by not contending, not by
trying to act better when things have already become bad.

This is the same issue. We don't "fix" things by papering over some
symptom. We try to fix the _actual_ underlying problem. Maybe there is
some caller that can simply be rewritten. Maybe we can do other tricks
than just make the wait tables bigger. But we should not say "3700
entries is ok, let's just make that sh*t be interruptible".

That is what the patch does now, and that is why I dislike the patch.

So I _am_ NAK'ing the patch if nobody is willing to even try alternatives.

Because a band-aid is ok for "some theoretical worst-case behavior".

But a band-aid is *not* ok for "we can't even be bothered to try to
figure out the right thing, so we're just adding this hack and leaving
it".

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
