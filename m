From: Dave Peterson <dsp@llnl.gov>
Subject: Re: [PATCH 1/2] mm: serialize OOM kill operations
Date: Thu, 27 Apr 2006 09:56:15 -0700
References: <200604251701.31899.dsp@llnl.gov> <200604261014.15008.dsp@llnl.gov> <44503BA2.7000405@yahoo.com.au>
In-Reply-To: <44503BA2.7000405@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200604270956.15658.dsp@llnl.gov>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@surriel.com, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Wednesday 26 April 2006 20:33, Nick Piggin wrote:
> Dave Peterson wrote:
> >If you prefer the above implementation, I can rework the patch as
> >above.
>
> I think you need a semaphore?

In this particular case, I think a semaphore is unnecessary because
we just want out_of_memory() to return to its caller if an OOM kill
is already in progress (as opposed to waiting in out_of_memory() and
then starting a new OOM kill operation).  What I want to avoid is the
the following type of behavior:

    1.  Two processes (A and B) call out_of_memory() at roughly the
        same time and race for oom_kill_lock.  Let's say A wins and B
        is delayed.

    2.  Process A shoots some process and releases oom_kill_lock.

    3.  Process B now acquires oom_kill_lock and shoots another
        process.  However this isn't really what we want to do if
        the OOM kill done by A above freed enough memory to resolve
        the OOM condition.

> Either way, drop the trivial wrappers.

Ok, I'll drop the wrappers.

> >>Second, can you arrange it without using the extra field in mm_struct
> >>and operation in the mmput fast path?
> >
> >I'm open to suggestions on other ways of implementing this.  However I
> >think the performance impact of the proposed implementation should be
> >miniscule.  The code added to mmput() executes only when the referece
> >count has reached 0; not on every decrement of the reference count.
> >Once the reference count has reached 0, the common-case behavior is
> >still only testing a boolean flag followed by a not-taken branch.  The
> >use of unlikely() should help the compiler and CPU branch prediction
> >hardware minimize overhead in the typical case where oom_kill_finish()
> >is not called.
>
> Mainly the cost of increasing cacheline footprint. I think someone
> suggested using a flag bit somewhere... that'd be preferable.

Ok, I'll add a ->flags member to mm_struct and just use one bit for
the oom_notify value.  Then if other users of mm_struct need flag
bits for other things in the future they can all share ->flags.  I'll
rework my patches and repost shortly...

Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
