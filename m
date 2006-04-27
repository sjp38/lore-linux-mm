Date: Thu, 27 Apr 2006 15:56:13 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 1/2 (repost)] mm: serialize OOM kill operations
Message-Id: <20060427155613.15d565b1.akpm@osdl.org>
In-Reply-To: <200604271308.10080.dsp@llnl.gov>
References: <200604271308.10080.dsp@llnl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Peterson <dsp@llnl.gov>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@surriel.com, nickpiggin@yahoo.com.au, ak@suse.de
List-ID: <linux-mm.kvack.org>

Dave Peterson <dsp@llnl.gov> wrote:
>
> The patch below modifies the behavior of the OOM killer so that only
> one OOM kill operation can be in progress at a time.  When running a
> test program that eats lots of memory, I was observing behavior where
> the OOM killer gets impatient and shoots one or more system daemons
> in addition to the program that is eating lots of memory.  This fixes
> the problematic behavior.
> 
> ...
>
> @@ -379,6 +380,15 @@ void mmput(struct mm_struct *mm)
>  			spin_unlock(&mmlist_lock);
>  		}
>  		put_swap_token(mm);
> +
> +		if (unlikely(test_bit(MM_FLAG_OOM_NOTIFY, &mm->flags)))
> +			/* Terminate a pending OOM kill operation.  No tasks
> +			 * actually spin on the lock.  Tasks only do
> +			 * spin_trylock() (and abort OOM kill operation if
> +			 * lock is already taken).
> +			 */
> +			spin_unlock(&oom_kill_lock);
> +

Gad.  I guess if we're going to do this then a better implementation would
be to use test_and_set_bit(some_unsigned_long).  And perhaps call some
oom_kill.c interface function here rather than directly accessing
oom-killer data structures (could be an inlined function).

But the broader question is "what do we want to do here".

If we've picked a task and we've signalled it then the right thing to do
would appear to be just to block all tasks as they enter the oom-killer. 
Send them to sleep until the killed task actually exits.  But

a) memory can become free (or reclaimable) for other reasons, so those
   now-sleeping tasks shouldn't be sleeping any more (this is a minor
   problem).

b) one of the sleeping tasks may be holding a lock which prevents the
   killed task from reaching do_exit().  This is a showstopper.

But I think b) stops your show as well:

- task A enters the oom-killer, decides to kill task Z.

- task A holds a lock which is preventing task Z from exitting

- but oom_kill_lock is now held.  task A just keeps on trying to reclaim
  memory and trying (and failing) to kill tasks.

- user hits reset button.


IOW: we just have to keep killing more tasks until something happens.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
