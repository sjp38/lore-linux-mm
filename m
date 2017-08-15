Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3571A6B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 23:28:21 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id p62so13096648oih.12
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 20:28:21 -0700 (PDT)
Received: from mail-oi0-x241.google.com (mail-oi0-x241.google.com. [2607:f8b0:4003:c06::241])
        by mx.google.com with ESMTPS id d84si5635397oia.309.2017.08.14.20.28.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 20:28:20 -0700 (PDT)
Received: by mail-oi0-x241.google.com with SMTP id v11so11066647oif.1
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 20:28:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170815031524.GC28715@tassilo.jf.intel.com>
References: <84c7f26182b7f4723c0fe3b34ba912a9de92b8b7.1502758114.git.tim.c.chen@linux.intel.com>
 <CA+55aFznC1wqBSfYr8=92LGqz5-F6fHMzdXoqM4aOYx8sT1Dhg@mail.gmail.com>
 <20170815022743.GB28715@tassilo.jf.intel.com> <CA+55aFyHVV=eTtAocUrNLymQOCj55qkF58+N+Tjr2YS9TrqFow@mail.gmail.com>
 <20170815031524.GC28715@tassilo.jf.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 14 Aug 2017 20:28:19 -0700
Message-ID: <CA+55aFw1A1C8qUeKPUzACrsqn97UDxTP3M2SRs80aEztfU=Qbg@mail.gmail.com>
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Kan Liang <kan.liang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Aug 14, 2017 at 8:15 PM, Andi Kleen <ak@linux.intel.com> wrote:
> But what should we do when some other (non page) wait queue runs into the
> same problem?

Hopefully the same: root-cause it.

Once you have a test-case, it should generally be fairly simple to do
with profiles, just seeing who the caller is when ttwu() (or whatever
it is that ends up being the most noticeable part of the wakeup chain)
shows up very heavily.

And I think that ends up being true whether the "break up long chains"
patch goes in or not. Even if we end up allowing interrupts in the
middle, a long wait-queue is a problem.

I think the "break up long chains" thing may be the right thing
against actual malicious attacks, but not for any actual real
benchmark or load.

I don't think we normally have cases of long wait-queues, though. At
least not the kinds that cause problems. The real (and valid)
thundering herd cases should already be using exclusive waiters that
only wake up one process at a time.

The page bit-waiting is hopefully special. As mentioned, we used to
have some _really_ special code for it for other reasons, and I
suspect you see this problem with them because we over-simplified it
from being a per-zone dynamically sized one (where the per-zone thing
caused both performance problems and actual bugs) to being that
"static small array".

So I think/hope that just re-introducing some dynamic sizing will help
sufficiently, and that this really is an odd and unusual case.

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
