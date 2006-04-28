Message-ID: <4451A163.5020304@yahoo.com.au>
Date: Fri, 28 Apr 2006 15:00:19 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: serialize OOM kill operations
References: <200604251701.31899.dsp@llnl.gov> <200604261014.15008.dsp@llnl.gov> <44503BA2.7000405@yahoo.com.au> <200604270956.15658.dsp@llnl.gov>
In-Reply-To: <200604270956.15658.dsp@llnl.gov>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Peterson <dsp@llnl.gov>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@surriel.com, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

Dave Peterson wrote:
> On Wednesday 26 April 2006 20:33, Nick Piggin wrote:
> 
>>Dave Peterson wrote:
>>
>>>If you prefer the above implementation, I can rework the patch as
>>>above.
>>
>>I think you need a semaphore?
> 
> 
> In this particular case, I think a semaphore is unnecessary because
> we just want out_of_memory() to return to its caller if an OOM kill
> is already in progress (as opposed to waiting in out_of_memory() and
> then starting a new OOM kill operation).  What I want to avoid is the

When you are holding the spinlock, you can't schedule and the lock
really should be released by the same process that took it. Are you
OK with that?

>>
>>Mainly the cost of increasing cacheline footprint. I think someone
>>suggested using a flag bit somewhere... that'd be preferable.
> 
> 
> Ok, I'll add a ->flags member to mm_struct and just use one bit for
> the oom_notify value.  Then if other users of mm_struct need flag
> bits for other things in the future they can all share ->flags.  I'll
> rework my patches and repost shortly...

mm_struct already has what you want -- dumpable:2 -- if you just put
your bit in an adjacent bitfield, you'll be right.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
