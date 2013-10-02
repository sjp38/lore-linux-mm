Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id E06756B0044
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 15:37:43 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so1355068pdj.22
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 12:37:43 -0700 (PDT)
Message-ID: <524C75F6.1080701@hp.com>
Date: Wed, 02 Oct 2013 15:37:26 -0400
From: Waiman Long <waiman.long@hp.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 5/6] MCS Lock: Restructure the MCS lock defines and
 locking code into its own file
References: <cover.1380144003.git.tim.c.chen@linux.intel.com> <1380147049.3467.67.camel@schen9-DESK> <CAGQ1y=7Ehkr+ot3tDZtHv6FR6RQ9fXBVY0=LOyWjmGH_UjH7xA@mail.gmail.com> <1380226007.2170.2.camel@buesod1.americas.hpqcorp.net> <1380226997.2602.11.camel@j-VirtualBox> <1380228059.2170.10.camel@buesod1.americas.hpqcorp.net> <1380229794.2602.36.camel@j-VirtualBox> <1380231702.3467.85.camel@schen9-DESK> <1380235333.3229.39.camel@j-VirtualBox> <524C71C1.9060408@hp.com> <CAGQ1y=7mU0cJfFN3DhuTkukjxm3MXm0PrUxdxFXfo7GT_umUkA@mail.gmail.com>
In-Reply-To: <CAGQ1y=7mU0cJfFN3DhuTkukjxm3MXm0PrUxdxFXfo7GT_umUkA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Low <jason.low2@hp.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Davidlohr Bueso <davidlohr@hp.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On 10/02/2013 03:30 PM, Jason Low wrote:
> On Wed, Oct 2, 2013 at 12:19 PM, Waiman Long<waiman.long@hp.com>  wrote:
>> On 09/26/2013 06:42 PM, Jason Low wrote:
>>> On Thu, 2013-09-26 at 14:41 -0700, Tim Chen wrote:
>>>> Okay, that would makes sense for consistency because we always
>>>> first set node->lock = 0 at the top of the function.
>>>>
>>>> If we prefer to optimize this a bit though, perhaps we can
>>>> first move the node->lock = 0 so that it gets executed after the
>>>> "if (likely(prev == NULL)) {}" code block and then delete
>>>> "node->lock = 1" inside the code block.
>>>>
>>>> static noinline
>>>> void mcs_spin_lock(struct mcs_spin_node **lock, struct mcs_spin_node
>>>> *node)
>>>> {
>>>>          struct mcs_spin_node *prev;
>>>>
>>>>          /* Init node */
>>>>          node->next   = NULL;
>>>>
>>>>          prev = xchg(lock, node);
>>>>          if (likely(prev == NULL)) {
>>>>                  /* Lock acquired */
>>>>                  return;
>>>>          }
>>>>          node->locked = 0;
>>
>> You can remove the locked flag setting statement inside if (prev == NULL),
>> but you can't clear the locked flag after xchg(). In the interval between
>> xchg() and locked=0, the previous lock owner may come in and set the flag.
>> Now if your clear it, the thread will loop forever. You have to clear it
>> before xchg().
> Yes, in my most recent version, I left locked = 0 in its original
> place so that the xchg() can act as a barrier for it.
>
> The other option would have been to put another barrier after locked =
> 0. I went with leaving locked = 0 in its original place so that we
> don't need that extra barrier.

I don't think putting another barrier after locked=0 will work. 
Chronologically, the flag must be cleared before the node address is 
saved in the lock field. There is no way to guarantee that except by 
putting the locked=0 before xchg().

-Longman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
