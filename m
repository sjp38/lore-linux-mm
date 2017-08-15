Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5C1D66B0292
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 19:50:36 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id b184so2645787oih.9
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 16:50:36 -0700 (PDT)
Received: from mail-oi0-x241.google.com (mail-oi0-x241.google.com. [2607:f8b0:4003:c06::241])
        by mx.google.com with ESMTPS id w74si6675321oia.529.2017.08.15.16.50.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 16:50:35 -0700 (PDT)
Received: by mail-oi0-x241.google.com with SMTP id s21so2172186oie.5
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 16:50:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFw84Cu0VZdR_Rj6b03hMYBFgt9BCnSEx+OLXDsp4dDO=g@mail.gmail.com>
References: <84c7f26182b7f4723c0fe3b34ba912a9de92b8b7.1502758114.git.tim.c.chen@linux.intel.com>
 <CA+55aFznC1wqBSfYr8=92LGqz5-F6fHMzdXoqM4aOYx8sT1Dhg@mail.gmail.com>
 <20170815022743.GB28715@tassilo.jf.intel.com> <CA+55aFyHVV=eTtAocUrNLymQOCj55qkF58+N+Tjr2YS9TrqFow@mail.gmail.com>
 <20170815031524.GC28715@tassilo.jf.intel.com> <CA+55aFw1A1C8qUeKPUzACrsqn97UDxTP3M2SRs80aEztfU=Qbg@mail.gmail.com>
 <20170815224728.GA1373@linux-80c1.suse> <CA+55aFyMkd8EaozxvAZo9i3ArKh7m6HLjsUB34xnDBzXz4gowg@mail.gmail.com>
 <CA+55aFw84Cu0VZdR_Rj6b03hMYBFgt9BCnSEx+OLXDsp4dDO=g@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 15 Aug 2017 16:50:34 -0700
Message-ID: <CA+55aFxbo-4M8=3BZ_VbqvRTq6_Lbw6eUQz2tTh7ve5YhLdecw@mail.gmail.com>
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Kan Liang <kan.liang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Aug 15, 2017 at 3:57 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Oh, and the page wait-queue really needs that key argument too, which
> is another thing that swait queue code got rid of in the name of
> simplicity.

Actually, it gets worse.

Because the page wait queues are hashed, it's not an all-or-nothing
thing even for the non-exclusive cases, and it's not a "wake up first
entry" for the exclusive case. Both have to be conditional on the wait
entry actually matching the page and bit in question.

So no way to use swait, or any of the lockless queuing code in general
(so we can't do some clever private wait-list using llist.h either).

End result: it looks like you fairly fundamentally do need to use a
lock over the whole list traversal (like the standard wait-queues),
and then add a cursor entry like Tim's patch if dropping the lock in
the middle.

Anyway, looking at the old code, we *used* to limit the page wait hash
table to 4k entries, and we used to have one hash table per memory
zone.

The per-zone thing didn't work at all for the generic bit-waitqueues,
because of how people used them on virtual addresses on the stack.

But it *could* work for the page waitqueues, which are now a totally
separate entity, and is obviously always physically addressed (since
the indexing is by "struct page" pointer), and doesn't have that
issue.

So I guess we could re-introduce the notion of per-zone page waitqueue
hash tables. It was disgusting to allocate and free though (and hooked
into the memory hotplug code).

So I'd still hope that we can instead just have one larger hash table,
and that is sufficient for the problem.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
