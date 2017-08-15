Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 615EB6B02B4
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 15:47:55 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id c80so2098375oig.7
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 12:47:55 -0700 (PDT)
Received: from mail-oi0-x242.google.com (mail-oi0-x242.google.com. [2607:f8b0:4003:c06::242])
        by mx.google.com with ESMTPS id r204si6405941oif.284.2017.08.15.12.47.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 12:47:54 -0700 (PDT)
Received: by mail-oi0-x242.google.com with SMTP id j194so1677990oib.4
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 12:47:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFymeC-s6rkGk4==3RjZu6nyyj2R9c5TBzpwTwJd4yjf2A@mail.gmail.com>
References: <84c7f26182b7f4723c0fe3b34ba912a9de92b8b7.1502758114.git.tim.c.chen@linux.intel.com>
 <CA+55aFznC1wqBSfYr8=92LGqz5-F6fHMzdXoqM4aOYx8sT1Dhg@mail.gmail.com>
 <20170815022743.GB28715@tassilo.jf.intel.com> <CA+55aFyHVV=eTtAocUrNLymQOCj55qkF58+N+Tjr2YS9TrqFow@mail.gmail.com>
 <20170815031524.GC28715@tassilo.jf.intel.com> <CA+55aFw1A1C8qUeKPUzACrsqn97UDxTP3M2SRs80aEztfU=Qbg@mail.gmail.com>
 <0b7b6132-a374-9636-53f9-c2e1dcec230f@linux.intel.com> <CA+55aFymeC-s6rkGk4==3RjZu6nyyj2R9c5TBzpwTwJd4yjf2A@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 15 Aug 2017 12:47:54 -0700
Message-ID: <CA+55aFymcZHH+MrFsum9JG89D5YZegNP19zYeF7v11PxuTsXnA@mail.gmail.com>
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Andi Kleen <ak@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Kan Liang <kan.liang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Aug 15, 2017 at 12:41 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> So if we have unnecessarily collisions because we have waiters looking
> at different bits of the same page, we could just hash in the bit
> number that we're waiting for too.

Oh, nope, we can't do that, because we only have one "PageWaters" bit
per page, and it is shared across all bits we're waiting for on that
page.

So collisions between different bits on the same page are inevitable,
and we just need to make sure the hash table is big enough that we
don't get unnecessary collisions between different pages.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
