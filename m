Message-ID: <479059E7.6080007@google.com>
Date: Thu, 17 Jan 2008 23:48:55 -0800
From: Mike Waychison <mikew@google.com>
MIME-Version: 1.0
Subject: Re: [patch] Converting writeback linked lists to a tree based data
 structure
References: <20080115080921.70E3810653@localhost>	<400562938.07583@ustc.edu.cn>	<532480950801171307q4b540ewa3acb6bfbea5dbc8@mail.gmail.com>	<400632190.14601@ustc.edu.cn> <p738x2nbsi2.fsf@bingen.suse.de>
In-Reply-To: <p738x2nbsi2.fsf@bingen.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Fengguang Wu <wfg@mail.ustc.edu.cn>, Michael Rubin <mrubin@google.com>, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

We have some code internally that does just this, though it slightly 
abuses struct page by tagging pages with the highest priority that 
dirties them.

I'm not sure what a better solution is, though there has been talk about 
rewritting it to use a per mapping radix tree to keep mem_map small.

The idea is to mark current->ioprio into each page as they are dirtied, 
higher priority overrides lower priority.  Buffer_heads are done in the 
same way.

Come IO submission, bio's get the highest IO priority associated with 
the submitted pages/buffer_heads and these are passed into the the 
struct request's into the scheduler.

Similar changes are underway for making sure all AIO get the right ioprios.

It will take some cleaning to get it ready for lkml submission, though 
I'm still a bit unsure of what we should do to avoid struct page growth.

Mike Waychison

Andi Kleen wrote:
> Fengguang Wu <wfg@mail.ustc.edu.cn> writes:
>> Suppose we want to grant longer expiration window for temp files,
>> adding a new list named s_dirty_tmpfile would be a handy solution.
> 
> How would the kernel know that a file is a tmp file?
> 
>> So the question is: should we need more than 3 QoS classes?
> 
> [just a random idea; i have not worked out all the implications]
> 
> Would it be possible to derive a writeback apriority from the ionice
> level of the process originating the IO? e.g. we have long standing
> problems that background jobs even when niced and can cause
> significant slow downs to foreground processes by starving IO 
> and pushing out pages. ionice was supposed to help with that
> but in practice it does not seem to have helped too much and I suspect
> it needs more prioritization higher up the VM food chain. Adding
> such priorities to writeback would seem like a step in the right
> direction, although it would of course not solve the problem
> completely.
> 
> -Andi
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
