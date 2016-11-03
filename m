Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id A99046B02BD
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 23:47:02 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ro13so17123628pac.7
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 20:47:02 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id u83si6941350pfk.205.2016.11.02.20.47.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 20:47:01 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id y68so3483179pfb.1
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 20:47:01 -0700 (PDT)
Date: Thu, 3 Nov 2016 14:46:50 +1100
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 2/2] mm: add PageWaiters bit to indicate waitqueue
 should be checked
Message-ID: <20161103144650.70c46063@roar.ozlabs.ibm.com>
In-Reply-To: <CA+55aFxhxfevU1uKwHmPheoU7co4zxxcri+AiTpKz=1_Nd0_ig@mail.gmail.com>
References: <20161102070346.12489-1-npiggin@gmail.com>
	<20161102070346.12489-3-npiggin@gmail.com>
	<CA+55aFxhxfevU1uKwHmPheoU7co4zxxcri+AiTpKz=1_Nd0_ig@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Wed, 2 Nov 2016 09:18:37 -0600
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Wed, Nov 2, 2016 at 1:03 AM, Nicholas Piggin <npiggin@gmail.com> wrote:
> > +       __wake_up_locked_key(q, TASK_NORMAL, &key);
> > +       if (!waitqueue_active(q) || !key.page_match) {
> > +               ClearPageWaiters(page);  
> 
> Is that "page_match" optimization really worth it? I'd rather see
> numbers for that particular optimization. I'd rather see the
> contention bit being explicitly not precise.

If you don't have that, then a long-waiting waiter for some
unrelated page can prevent other pages from getting back to
the fastpath.

Contention bit is already explicitly not precise with this patch
(false positive possible), but in general the next wakeup will
clean it up. Without page_match, that's not always possible.

It would be difficult to get numbers that aren't contrived --
blatting a lot of slow IO and waiters in there to cause collisions.
And averages probably won't show it up. But the idea is we don't
want the workload to randomly slow down.


> Also, it would be lovely to get numbers against the plain 4.8
> situation with the per-zone waitqueues. Maybe that used to help your
> workload, so the 2.2% improvement might be partly due to me breaking
> performance on your machine.

Oh yeah that'll hurt a bit. The hash will get spread over non-local
nodes now. I think it was only a 2 socket system, but remote memory
still takes a latency hit. Hmm, I think keeping the zone waitqueue
just for pages would be reasonable, because they're a special case?

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
