Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id CD6556810D7
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 18:19:55 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t3so6364316pgt.8
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 15:19:55 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id g8si5405999pfc.427.2017.08.25.15.19.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 15:19:54 -0700 (PDT)
Subject: Re: [PATCH 2/2 v2] sched/wait: Introduce lock breaker in
 wake_up_page_bit
References: <83f675ad385d67760da4b99cd95ee912ca7c0b44.1503677178.git.tim.c.chen@linux.intel.com>
 <cd8ce7fbca9c126f7f928b8fa48d7a9197955b45.1503677178.git.tim.c.chen@linux.intel.com>
 <CA+55aFyErsNw8bqTOCzcrarDZBdj+Ev=1N3sV-gxtLTH03bBFQ@mail.gmail.com>
From: Tim Chen <tim.c.chen@linux.intel.com>
Message-ID: <f10f4c25-49c0-7ef5-55c2-769c8fd9bf90@linux.intel.com>
Date: Fri, 25 Aug 2017 15:19:53 -0700
MIME-Version: 1.0
In-Reply-To: <CA+55aFyErsNw8bqTOCzcrarDZBdj+Ev=1N3sV-gxtLTH03bBFQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Kan Liang <kan.liang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Christopher Lameter <cl@linux.com>, "Eric W . Biederman" <ebiederm@xmission.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 08/25/2017 12:58 PM, Linus Torvalds wrote:
> On Fri, Aug 25, 2017 at 9:13 AM, Tim Chen <tim.c.chen@linux.intel.com> wrote:
>> Now that we have added breaks in the wait queue scan and allow bookmark
>> on scan position, we put this logic in the wake_up_page_bit function.
> 
> Oh, _this_ is the other patch you were talking about. I thought it was
> the NUMA counter threashold that was discussed around the same time,
> and that's why I referred to Mel.
> 
> Gods, _this_ patch is ugly.  No, I'm not happy with it at all. It
> makes that wait_queue_head much bigger, for this disgusting one use.
> 
> So no, this is no good.
> 
> Now, maybe the page_wait_table[] itself could be changed to be
> something that is *not* just the wait-queue head.
> 
> But if we need to change the page_wait_table[] itself to have more
> information, then we should make it not be a wait-queue at all, we
> should make it be a list of much more specialized entries, indexed by
> the {page,bit} tuple.
> 
> And once we do that, we probably *could* use something like two
> specialized lists: one that is wake-all, and one that is wake-one.
> 
> So you'd have something like
> 
>     struct page_wait_struct {
>         struct list_node list;
>         struct page *page;
>         int bit;
>         struct llist_head all;
>         struct llist_head exclusive;
>     };
> 
> and then the "page_wait_table[]" would be just an array of
> 
>     struct page_wait_head {
>         spinlock_t lock;
>         struct hlist_head list;
>     };
> 
> and then the rule is:
> 
>  - each page/bit combination allocates one of these page_wait_struct
> entries when somebody starts waiting for it for the first time (and we
> use the spinlock in the page_wait_head to serialize that list).
> 
>  - an exclusive wait (ie somebody who waits to get the bit for
> locking) adds itself to the 'exclusive' llist
> 
>  - non-locking waiters add themselves to the 'all' list
> 
>  - we can use llist_del_all() to remove the 'all' list and then walk
> it and wake them up without any locks
> 
>  - we can use llist_del_first() to remove the first exclusive waiter
> and wait _it_ up without any locks.
> 
> Hmm? How does that sound? That means that we wouldn't use the normal
> wait-queues at all for the page hash waiting. We'd use this two-level
> list: one list to find the page/bit thing, and then two lists within
> that fdor the wait-queues for just *that* page/bit.
> 
> So no need for the 'key' stuff at all, because the page/bit data would
> be in the first data list, and the second list wouldn't have any of
> these traversal issues where you have to be careful and do it one
> entry at a time.

If I have the waker count and flags on the wait_page_queue structure
will that have been more acceptable?

Also I think patch 1 is still a good idea for a fail safe mechanism
in case there are other long wait list.

That said, I do think your suggested approach is cleaner.  However, it
is a much more substantial change.  Let me take a look and see if I
have any issues implementing it.

Tim



> 
>                  Linus
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
