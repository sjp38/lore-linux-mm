From: Dave Peterson <dsp@llnl.gov>
Subject: Re: [PATCH 2/2] mm: fix mm_struct reference counting bugs in mm/oom_kill.c
Date: Fri, 14 Apr 2006 12:14:35 -0700
References: <200604131452.08292.dsp@llnl.gov> <200604131744.02114.dsp@llnl.gov> <20060414002654.76d1a6bc.akpm@osdl.org>
In-Reply-To: <20060414002654.76d1a6bc.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200604141214.35806.dsp@llnl.gov>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@surriel.com
List-ID: <linux-mm.kvack.org>

On Friday 14 April 2006 00:26, Andrew Morton wrote:
> task_lock() can be used to pin a task's ->mm.  To use task_lock() in
> badness() we'd need to either
>
> a) nest task_lock()s.  I don't know if we're doing that anywhere else,
>    but the parent->child ordering is a natural one.  or
>
> b) take a ref on the parent's mm_struct, drop the parent's task_lock()
>    while we walk the children, then do mmput() on the parent's mm outside
>    tasklist_lock.  This is probably better.

Looking a bit more closely at the code, I see that
select_bad_process() iterates over all tasks, repeatedly calling
badness().  This would complicate option 'b' since the iteration is
done while holding tasklist_lock.  An alternative to option 'a' that
avoids nesting task_lock()s would be to define a couple of new
functions that might look something like this:

    void mmput_atomic(struct mm_struct *mm)
    {
            if (atomic_dec_and_test(&mm->mm_users)) {
                    add mm to a global list of expired mm_structs
            }
    }

    void mmput_atomic_cleanup(void)
    {
            empty the global list of expired mm_structs and do
            cleanup stuff for each one
    }

Then you could call mmput_atomic() an arbitrary # of times in places
where sleeping is not permitted, as long as mmput_atomic_cleanup() is
later called in a place where sleeping is permissible.  In the case
of the OOM killer code, a call to mmput_atomic_cleanup() could be
added to out_of_memory() in a place where we no longer hold
tasklist_lock.  Let me know if you have a preference for either of
these options, or if you have other suggestions.

Thanks,
Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
