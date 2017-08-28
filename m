Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8927B6B025F
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 16:01:03 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id r62so2145710pfj.5
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 13:01:03 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id r9si893330pgs.257.2017.08.28.13.01.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Aug 2017 13:01:02 -0700 (PDT)
Subject: Re: [PATCH 2/2 v2] sched/wait: Introduce lock breaker in
 wake_up_page_bit
References: <83f675ad385d67760da4b99cd95ee912ca7c0b44.1503677178.git.tim.c.chen@linux.intel.com>
 <cd8ce7fbca9c126f7f928b8fa48d7a9197955b45.1503677178.git.tim.c.chen@linux.intel.com>
 <CA+55aFyErsNw8bqTOCzcrarDZBdj+Ev=1N3sV-gxtLTH03bBFQ@mail.gmail.com>
 <f10f4c25-49c0-7ef5-55c2-769c8fd9bf90@linux.intel.com>
 <CA+55aFzNikMsuPAaExxT1Z8MfOeU6EhSn6UPDkkz-MRqamcemg@mail.gmail.com>
 <CA+55aFx67j0u=GNRKoCWpsLRDcHdrjfVvWRS067wLUSfzstgoQ@mail.gmail.com>
 <CA+55aFzy981a8Ab+89APi6Qnb9U9xap=0A6XNc+wZsAWngWPzA@mail.gmail.com>
 <CA+55aFwyCSh1RbJ3d5AXURa4_r5OA_=ZZKQrFX0=Z1J3ZgVJ5g@mail.gmail.com>
 <CA+55aFy18WCqZGwkxH6dTZR9LD9M5nXWqEN8DBeZ4LvNo4Y0BQ@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F077537A07E9@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFzotfXc07UoVtxvDpQOP8tEt8pgxeYe+cGs=BDUC_A4pA@mail.gmail.com>
From: Tim Chen <tim.c.chen@linux.intel.com>
Message-ID: <42de956b-c504-5534-cc4f-5af1df21d49b@linux.intel.com>
Date: Mon, 28 Aug 2017 13:01:00 -0700
MIME-Version: 1.0
In-Reply-To: <CA+55aFzotfXc07UoVtxvDpQOP8tEt8pgxeYe+cGs=BDUC_A4pA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, "Liang, Kan" <kan.liang@intel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Christopher Lameter <cl@linux.com>, "Eric W . Biederman" <ebiederm@xmission.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 08/28/2017 09:48 AM, Linus Torvalds wrote:
> On Mon, Aug 28, 2017 at 7:51 AM, Liang, Kan <kan.liang@intel.com> wrote:
>>
>> I tried this patch and https://lkml.org/lkml/2017/8/27/222 together.
>> But they don't fix the issue. I can still get the similar call stack.
> 
> So the main issue was that I *really* hated Tim's patch #2, and the
> patch to clean up the page wait queue should now make his patch series
> much more palatable.
> 
> Attached is an ALMOST COMPLETELY UNTESTED forward-port of those two
> patches, now without that nasty WQ_FLAG_ARRIVALS logic, because we now
> always put the new entries at the end of the waitqueue.
> 
> The attached patches just apply directly on top of plain 4.13-rc7.
> 
> That makes patch #2 much more palatable, since it now doesn't need to
> play games and worry about new arrivals.
> 
> But note the lack of testing. I've actually booted this and am running
> these two patches right now, but honestly, you should consider them
> "untested" simply because I can't trigger the page waiters contention
> case to begin with.
> 
> But it's really just Tim's patches, modified for the page waitqueue
> cleanup which makes patch #2 become much simpler, and now it's
> palatable: it's just using the same bookmark thing that the normal
> wakeup uses, no extra hacks.
> 
> So Tim should look these over, and they should definitely be tested on
> that load-from-hell that you guys have, but if this set works, at
> least I'm ok with it now.
> 
> Tim - did I miss anything? I added a "cpu_relax()" in there between
> the release lock and irq and re-take it, I'm not convinced it makes
> any difference, but I wanted to mark that "take a breather" thing.
> 
> Oh, there's one more case I only realized after the patches: the
> stupid add_page_wait_queue() code still adds to the head of the list.
> So technically you need this too:
> 
>     diff --git a/mm/filemap.c b/mm/filemap.c
>     index 74123a298f53..598c3be57509 100644
>     --- a/mm/filemap.c
>     +++ b/mm/filemap.c
>     @@ -1061,7 +1061,7 @@ void add_page_wait_queue(struct page *page,
> wait_queue_entry_t *waiter)
>         unsigned long flags;
> 
>         spin_lock_irqsave(&q->lock, flags);
>     -   __add_wait_queue(q, waiter);
>     +   __add_wait_queue_entry_tail(q, waiter);

I've also found this part of the code odd that add to head, but
wasn't sure about the history behind it to have changed it.

Adding to tail makes things much cleaner.  I'm glad that
those ugly hacks that added flags and counter
to track new arrivals can be discarded.

The modified patchset looks fine to me.  So pending Kan's test
on the new code I think we are good.

Thanks.

Tim

>         SetPageWaiters(page);
>         spin_unlock_irqrestore(&q->lock, flags);
>      }
> 
> but that only matters if you actually use the cachefiles thing, which
> I hope/assume you don't.
> 
>        Linus
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
