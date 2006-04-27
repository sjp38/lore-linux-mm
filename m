Message-ID: <44503BA2.7000405@yahoo.com.au>
Date: Thu, 27 Apr 2006 13:33:54 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: serialize OOM kill operations
References: <200604251701.31899.dsp@llnl.gov> <444EF2CF.1020100@yahoo.com.au> <200604261014.15008.dsp@llnl.gov>
In-Reply-To: <200604261014.15008.dsp@llnl.gov>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Peterson <dsp@llnl.gov>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@surriel.com, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

Dave Peterson wrote:

>On Tuesday 25 April 2006 21:10, Nick Piggin wrote:
>
>>Firstly why not use a semaphore and trylocks instead of your homebrew
>>lock?
>>
>
>Are you suggesting something like this?
>
>	spinlock_t oom_kill_lock = SPIN_LOCK_UNLOCKED;
>
>	static inline int oom_kill_start(void)
>	{
>		return !spin_trylock(&oom_kill_lock);
>	}
>
>	static inline void oom_kill_finish()
>	{
>		spin_unlock(&oom_kill_lock);
>	}
>
>If you prefer the above implementation, I can rework the patch as
>above.
>

I think you need a semaphore? Either way, drop the trivial wrappers.

>
>>Second, can you arrange it without using the extra field in mm_struct
>>and operation in the mmput fast path?
>>
>
>I'm open to suggestions on other ways of implementing this.  However I
>think the performance impact of the proposed implementation should be
>miniscule.  The code added to mmput() executes only when the referece
>count has reached 0; not on every decrement of the reference count.
>Once the reference count has reached 0, the common-case behavior is
>still only testing a boolean flag followed by a not-taken branch.  The
>use of unlikely() should help the compiler and CPU branch prediction
>hardware minimize overhead in the typical case where oom_kill_finish()
>is not called.
>

Mainly the cost of increasing cacheline footprint. I think someone
suggested using a flag bit somewhere... that'd be preferable.

--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
