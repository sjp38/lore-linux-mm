Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id E5E5A28071E
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 15:15:23 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id j144so8675434oib.5
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 12:15:23 -0700 (PDT)
Received: from mail-oi0-x241.google.com (mail-oi0-x241.google.com. [2607:f8b0:4003:c06::241])
        by mx.google.com with ESMTPS id a131si12429192oih.301.2017.08.22.12.15.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Aug 2017 12:15:22 -0700 (PDT)
Received: by mail-oi0-x241.google.com with SMTP id k77so5811586oib.4
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 12:15:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170822185624.GN32112@worktop.programming.kicks-ass.net>
References: <37D7C6CF3E00A74B8858931C1DB2F077537879BB@SHSMSX103.ccr.corp.intel.com>
 <20170818144622.oabozle26hasg5yo@techsingularity.net> <37D7C6CF3E00A74B8858931C1DB2F07753787AE4@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFxZjjqUM4kPvNEeZahPovBHFATiwADj-iPTDN0-jnU67Q@mail.gmail.com>
 <20170818185455.qol3st2nynfa47yc@techsingularity.net> <CA+55aFwX0yrUPULrDxTWVCg5c6DKh-yCG84NXVxaptXNQ4O_kA@mail.gmail.com>
 <20170821183234.kzennaaw2zt2rbwz@techsingularity.net> <37D7C6CF3E00A74B8858931C1DB2F07753788B58@SHSMSX103.ccr.corp.intel.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378A24A@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy=4y0fq9nL2WR1x8vwzJrDOdv++r036LXpR=6Jx8jpzg@mail.gmail.com> <20170822185624.GN32112@worktop.programming.kicks-ass.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 22 Aug 2017 12:15:20 -0700
Message-ID: <CA+55aFwjSZ_Q4xS21z60THsKr99A2nU4VKTkav47DzJj0+Ewnw@mail.gmail.com>
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Liang, Kan" <kan.liang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Aug 22, 2017 at 11:56 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>
> Won't we now prematurely terminate the wait when we get a spurious
> wakeup?

I think there's two answers to that:

 (a) do we even care?

 (b) what spurious wakeup?

The "do we even care" quesiton is because wait_on_page_bit by
definition isn't really serializing. And I'm not even talking about
memory ordering, altough that is true too - I'm talking just
fundamentally, that by definition when we're not locking, by the time
wait_on_page_bit() returns to the caller, it could obviously have
changed again.

So I think wait_on_page_bit() is by definition not really guaranteeing
that the bit really is clear. And I don't think we have really have
cases that matter.

But if we do - say, 'fsync()' waiting for a page to wait for
writeback, where would you get spurious wakeups from? They normally
happen either  when we have nested waiting (eg a page fault happens
while we have other wait queues active), and I'm not seeing that being
an issue here.

That said, I do think we might want to perhaps make a "careful" vs
"just wait a bit" version of this if the patch works out.

The patch is primarily for testing this particular case. I actually
think it's probably ok in general, but maybe there really is some
special case that could have multiple wakeup sources and it needs to
see *this* particular one.

(We could perhaps handle that case by checking "is the wait-queue
empty now" instead, and just get rid of the re-arming, not break out
of the loop immediately after the io_schedule()).

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
