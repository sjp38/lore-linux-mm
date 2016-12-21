Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 956256B03D1
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 14:02:21 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 26so239629600pgy.6
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 11:02:21 -0800 (PST)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id q28si27718241pfl.44.2016.12.21.11.02.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Dec 2016 11:02:20 -0800 (PST)
Received: by mail-pg0-x243.google.com with SMTP id b1so17213583pgc.1
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 11:02:20 -0800 (PST)
Date: Thu, 22 Dec 2016 05:01:30 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [RFC][PATCH] make global bitlock waitqueues per-node
Message-ID: <20161222050130.49d93982@roar.ozlabs.ibm.com>
In-Reply-To: <20161222043331.31aab9cc@roar.ozlabs.ibm.com>
References: <20161219225826.F8CB356F@viggo.jf.intel.com>
	<CA+55aFwK6JdSy9v_BkNYWNdfK82sYA1h3qCSAJQ0T45cOxeXmQ@mail.gmail.com>
	<156a5b34-ad3b-d0aa-83c9-109b366c1bdf@linux.intel.com>
	<CA+55aFxVzes5Jt-hC9BLVSb99x6K-_WkLO-_JTvCjhf5wuK_4w@mail.gmail.com>
	<CA+55aFwy6+ya_E8N3DFbrq2XjbDs8LWe=W_qW8awimbxw26bJw@mail.gmail.com>
	<20161221080931.GQ3124@twins.programming.kicks-ass.net>
	<20161221083247.GW3174@twins.programming.kicks-ass.net>
	<CA+55aFx-YmpZ4NBU0oSw_iJV8jEMaL8qX-HCH=DrutQ65UYR5A@mail.gmail.com>
	<20161222043331.31aab9cc@roar.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Andreas Gruenbacher <agruenba@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>

On Thu, 22 Dec 2016 04:33:31 +1000
Nicholas Piggin <npiggin@gmail.com> wrote:

> On Wed, 21 Dec 2016 10:02:27 -0800
> Linus Torvalds <torvalds@linux-foundation.org> wrote:
> 

> > I do think your approach of just re-using the existing bit waiting
> > with just a page-specific waiting function is nicer than Nick's "let's
> > just roll new waiting functions" approach. It also avoids the extra
> > initcall.
> > 
> > Nick, comments?  
> 
> Well yes we should take my patch 1 and use the new bit for this
> purpose regardless of what way we go with patch 2. I'll reply to
> that in the other mail.

Actually when I hit send, I thought your next mail was addressing a
different subject. So back here.

Peter's patch is less code and in that regard a bit nicer. I tried
going that way once, but I just thought it was a bit too sloppy to
do nicely with wait bit APIs.

- The page can be added to waitqueue without PageWaiters being set.
  This is transient condition where the lock is retested, but it
  remains that PageWaiters is not quite the same as waitqueue_active
  to some degree.

- This set + retest means every time a page gets a waiter, the cost
  is 2 test-and-set for the lock bit plus 2 spin_lock+spin_unlock for
  the waitqueue.

- Setting PageWaiters is done outside the waitqueue lock, so you also
  have a new interleavings to think about versus clearing the bit.

- It fails to clear up the bit and return to fastpath when there are
  hash collisions. Yes I know this is a rare case and on average it
  probably does not matter. But jitter is important, but also we
  really *want* to keep the waitqueue table small and lean like you
  have made it if possible. None of this 100KB per zone crap -- I do
  want to keep it small and tolerating collisions better would help
  that.

Anyway that's about my 2c. Keep in mind Mel just said he might have
seen a lockup with Peter's patch, and mine has not been hugely tested
either, so let's wait for a bit more testing before merging either.

Although we could start pipelining the process by merging patch 1 if
Hugh acks it (cc'ed), then I'll resend with SOB and Ack.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
