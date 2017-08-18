Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 002FC6B04A7
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 16:29:55 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id b184so13855463oih.9
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 13:29:54 -0700 (PDT)
Received: from mail-oi0-x22a.google.com (mail-oi0-x22a.google.com. [2607:f8b0:4003:c06::22a])
        by mx.google.com with ESMTPS id a10si4914175oib.276.2017.08.18.13.29.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Aug 2017 13:29:54 -0700 (PDT)
Received: by mail-oi0-x22a.google.com with SMTP id x3so107666568oia.1
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 13:29:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170818200510.GQ28715@tassilo.jf.intel.com>
References: <CA+55aFznC1wqBSfYr8=92LGqz5-F6fHMzdXoqM4aOYx8sT1Dhg@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F07753786CE9@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFwzTMrZwh7TE_VeZt8gx5Syoop-kA=Xqs56=FkyakrM6g@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378761B@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy_RNx5TQ8esjPPOKuW-o+fXbZgWapau2MHyexcAZtqsw@mail.gmail.com>
 <20170818122339.24grcbzyhnzmr4qw@techsingularity.net> <37D7C6CF3E00A74B8858931C1DB2F077537879BB@SHSMSX103.ccr.corp.intel.com>
 <20170818144622.oabozle26hasg5yo@techsingularity.net> <37D7C6CF3E00A74B8858931C1DB2F07753787AE4@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFxZjjqUM4kPvNEeZahPovBHFATiwADj-iPTDN0-jnU67Q@mail.gmail.com> <20170818200510.GQ28715@tassilo.jf.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 18 Aug 2017 13:29:53 -0700
Message-ID: <CA+55aFwQrBa+fzsfmvo5LsNBtja18QCwrEqYtRirH-m4OSd_Uw@mail.gmail.com>
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: "Liang, Kan" <kan.liang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Aug 18, 2017 at 1:05 PM, Andi Kleen <ak@linux.intel.com> wrote:
>
> I think what's happening is that it allows more parallelism during wakeup:
>
> Normally it's like
>
> CPU 1                           CPU 2               CPU 3                    .....
>
> LOCK
> wake up tasks on other CPUs    woken up             woken up
> UNLOCK                         SPIN on waitq lock   SPIN on waitq lock

Hmm. The processes that are woken up shouldn't need to touch the waitq
lock after wakeup. The default "autoremove_wake_function()" does the
wait list removal, so if you just use the normal wait/wakeup, you're
all done an don't need to do anythig more.

That's very much by design.

In fact, it's why "finish_wait()" uses that "list_empty_careful()"
thing on the entry - exactly so that it only needs to take the wait
queue lock if it is still on the wait list (ie it was woken up by
something else).

Now, it *is* racy, in the sense that the autoremove_wake_function()
will remove the entry *after* having successfully woken up the
process, so with bad luck and a quick wakeup, the woken process may
not see the good list_empty_careful() case.

So we really *should* do the remove earlier inside the pi_lock region
in ttwu(). We don't have that kind of interface, though. If you
actually do see tasks getting stuck on the waitqueue lock after being
woken up, it might be worth looking at, though.

The other possibility is that you were looking at cases that didn't
use "autoremove_wake_function()" at all, of course. Maybe they are
worth fixing. The autoremval really does make a difference, exactly
because of the issue you point to.

                       Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
