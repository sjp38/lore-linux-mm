Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 41CF16B0038
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 14:26:26 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a7so33656292pfj.3
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 11:26:26 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l8sor2187005pln.81.2017.10.05.11.26.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Oct 2017 11:26:23 -0700 (PDT)
Subject: Re: [PATCH] block/laptop_mode: Convert timers to use timer_setup()
References: <20171005004924.GA23053@beast>
 <4d4ccf50-d0b6-a525-dc73-0d64d26da68a@kernel.dk>
 <CAGXu5jJA4jfZCnhjLrO6fePVJqoJw7Hj7VF1sGLimU2fFu4AgQ@mail.gmail.com>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <57ad0ef1-e147-8507-9922-aa72ad47350e@kernel.dk>
Date: Thu, 5 Oct 2017 12:26:18 -0600
MIME-Version: 1.0
In-Reply-To: <CAGXu5jJA4jfZCnhjLrO6fePVJqoJw7Hj7VF1sGLimU2fFu4AgQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Nicholas Piggin <npiggin@gmail.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Matthew Wilcox <mawilcox@microsoft.com>, Jeff Layton <jlayton@redhat.com>, linux-block@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>

On 10/05/2017 11:49 AM, Kees Cook wrote:
> On Thu, Oct 5, 2017 at 7:56 AM, Jens Axboe <axboe@kernel.dk> wrote:
>> On 10/04/2017 06:49 PM, Kees Cook wrote:
>>> In preparation for unconditionally passing the struct timer_list pointer to
>>> all timer callbacks, switch to using the new timer_setup() and from_timer()
>>> to pass the timer pointer explicitly.
>>>
>>> Cc: Jens Axboe <axboe@kernel.dk>
>>> Cc: Michal Hocko <mhocko@suse.com>
>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>> Cc: Jan Kara <jack@suse.cz>
>>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>>> Cc: Nicholas Piggin <npiggin@gmail.com>
>>> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
>>> Cc: Matthew Wilcox <mawilcox@microsoft.com>
>>> Cc: Jeff Layton <jlayton@redhat.com>
>>> Cc: linux-block@vger.kernel.org
>>> Cc: linux-mm@kvack.org
>>> Cc: Thomas Gleixner <tglx@linutronix.de>
>>> Signed-off-by: Kees Cook <keescook@chromium.org>
>>> ---
>>> This requires commit 686fef928bba ("timer: Prepare to change timer
>>> callback argument type") in v4.14-rc3, but should be otherwise
>>> stand-alone.
>>
>> My only complaint about this is the use of a from_timer() macro instead
>> of just using container_of() at the call sites to actually show that is
>> happening. I'm generally opposed to obfuscation like that. It just means
>> you have to look up what is going on, instead of it being readily
>> apparent to the reader/reviewer.
> 
> Yeah, this got discussed a bit with tglx and hch. Ultimately, this
> seems to be the least bad of several options. Specifically with regard
> to container_of(), it just gets to be huge, and makes things harder to
> read (almost always requires a line break, needlessly repeats the
> variable type definition, etc). Since there is precedent of both using
> wrappers on container_of() and for adding from_foo() helpers, I chose
> the resulting from_timer().

It might make for a longer line, but at least it's a readable line.
What does from_timer() do? Nobody knows, you have to find it and check.
So I'd still argue that it's a hell of a lot more readable than some
random function name.

>> I guess I do have a a second complaint as well - that it landed in -rc3,
>> which is rather late considering subsystem trees are usually forked
>> earlier than that. Had this been in -rc1, I would have had an easier
>> time applying the block bits for 4.15.
> 
> Yes, totally true. tglx and I ended up meeting face-to-face at the
> Kernel Recipes conference and we solved some outstanding design issues
> with the conversion. The timing meant the new API went into -rc3,
> which seemed better than missing an entire release cycle, or carrying
> deltas against maintainer trees that would drift. (This is actually my
> second massive refactoring of these changes...)

Honestly, I think the change should have waited for 4.15 in that case.
Why the rush? It wasn't ready for the merge window.

> If you don't want to deal with the -rc3 issue, would you want these
> changes to get carried in the timer tree instead?

I can carry them, not a problem. Just a bit grumpy as this seems poorly
handled.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
