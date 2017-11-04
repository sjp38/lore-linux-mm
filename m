Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 467586B0253
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 23:35:22 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id w24so5588010pgm.7
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 20:35:22 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id j17si6332375pll.365.2017.11.03.20.35.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Nov 2017 20:35:21 -0700 (PDT)
Subject: Re: [PATCH v3] printk: Add console owner and waiter logic to load
 balance console writes
From: John Hubbard <jhubbard@nvidia.com>
References: <20171102134515.6eef16de@gandalf.local.home>
 <82a3df5e-c8ad-dc41-8739-247e5034de29@suse.cz>
 <9f3bbbab-ef58-a2a6-d4c5-89e62ade34f8@nvidia.com>
 <20171103072121.3c2fd5ab@vmware.local.home>
 <20171103075404.14f9058a@vmware.local.home>
 <a53b5ca3-507d-87f4-ce31-175e848259b6@nvidia.com>
Message-ID: <6b1cda44-126d-bf47-66cc-fc80bdb7eb7d@nvidia.com>
Date: Fri, 3 Nov 2017 20:34:58 -0700
MIME-Version: 1.0
In-Reply-To: <a53b5ca3-507d-87f4-ce31-175e848259b6@nvidia.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

On 11/03/2017 02:46 PM, John Hubbard wrote:
> On 11/03/2017 04:54 AM, Steven Rostedt wrote:
>> On Fri, 3 Nov 2017 07:21:21 -0400
>> Steven Rostedt <rostedt@goodmis.org> wrote:
[...]
>>
>> I'll condense the patch to show what I mean:
>>
>> To become a waiter, a task must do the following:
>>
>> +			printk_safe_enter_irqsave(flags);
>> +
>> +			raw_spin_lock(&console_owner_lock);
>> +			owner = READ_ONCE(console_owner);
>> +			waiter = READ_ONCE(console_waiter);
>> +			if (!waiter && owner && owner != current) {
>> +				WRITE_ONCE(console_waiter, true);
>> +				spin = true;
>> +			}
>> +			raw_spin_unlock(&console_owner_lock);
>>
>>
>> The new waiter gets set only if there isn't already a waiter *and*
>> there is an owner that is not current (and with the printk_safe_enter I
>> don't think that is even needed).
>>
>> +				while (!READ_ONCE(console_waiter))
>> +					cpu_relax();
>>
>> The spin is outside the spin lock. But only the owner can clear it.
>>
>> Now the owner is doing a loop of this (with interrupts disabled)
>>
>> +		raw_spin_lock(&console_owner_lock);
>> +		console_owner = current;
>> +		raw_spin_unlock(&console_owner_lock);
>>
>> Write to consoles.
>>
>> +		raw_spin_lock(&console_owner_lock);
>> +		waiter = READ_ONCE(console_waiter);
>> +		console_owner = NULL;
>> +		raw_spin_unlock(&console_owner_lock);
>>
>> +		if (waiter)
>> +			break;
>>
>> At this moment console_owner is NULL, and no new waiters can happen.
>> The next owner will be the waiter that is spinning.
>>
>> +	if (waiter) {
>> +		WRITE_ONCE(console_waiter, false);
>>
>> There is no possibility of another task sneaking in and becoming a
>> waiter at this moment. The console_owner was cleared under spin lock,
>> and a waiter is only set under the same spin lock if owner is set.
>> There will be no new owner sneaking in because to become the owner, you
>> must have the console lock. Since it is never released between the time
>> the owner clears console_waiter and the waiter takes the console lock,
>> there is no race.
> 
> Yes, you are right of course. That does close the window. Sorry about
> missing that point.
> 
> I'll try to quickly put together a small patch on top of this, that
> shows a simplification, to just use an atomic compare and swap between a
> global atomic value, and a local (on the stack) flag value, just in
> case that is of interest.
> 
> thanks
> john h

Just a follow-up: I was unable to simplify this; the atomic compare-and-swap
approach merely made it different, rather than smaller or simpler. 

So, after spending a fair amount of time with the patch, it looks good to me,
for whatever that's worth. :) Thanks again for explaining the locking details.

thanks
john h

> 
>>
>> -- Steve
>>

>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
