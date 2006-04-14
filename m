From: Dave Peterson <dsp@llnl.gov>
Subject: Re: [PATCH 2/2] mm: fix mm_struct reference counting bugs in mm/oom_kill.c
Date: Thu, 13 Apr 2006 17:44:02 -0700
References: <200604131452.08292.dsp@llnl.gov> <20060413162432.41892d3a.akpm@osdl.org>
In-Reply-To: <20060413162432.41892d3a.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200604131744.02114.dsp@llnl.gov>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@surriel.com
List-ID: <linux-mm.kvack.org>

On Thursday 13 April 2006 16:24, Andrew Morton wrote:
> Dave Peterson <dsp@llnl.gov> wrote:
> > The patch below fixes some mm_struct reference counting bugs in
> > badness().
>
> hm, OK, afaict the code _is_ racy.
>
> But you're now calling mmput() inside read_lock(&tasklist_lock), and
> mmput() can sleep in exit_aio() or in exit_mmap()->unmap_vmas().  So
> sterner stuff will be needed.
>
> I'll put a might_sleep() into mmput - it's a bit unexpected.

Hmm... fixing this looks rather tricky.  If get_task_mm()/mmput() was
only being done on a single mm_struct then I suppose badness() could
do something a bit ugly like passing the reference back to its caller
and letting the caller do the mmput() once tasklist_lock is no longer
held.  However here we are iterating over a bunch of child tasks,
potentially doing a get_task_mm()/mmput() for a number of them.

I have a suggestion for a possible solution.  Currently mmput() is
implemented as follows:

    01 void mmput(struct mm_struct *mm)
    02 {
    03         if (atomic_dec_and_lock(&mm->mm_users, &mmlist_lock)) {
    04                 list_del(&mm->mmlist);
    05                 mmlist_nr--;
    06                 spin_unlock(&mmlist_lock);
    07                 exit_aio(mm);
    08                 exit_mmap(mm);
    09                 put_swap_token(mm);
    10                 mmdrop(mm);
    11         }
    12 }

Suppose we replace lines 07-10 with a little piece of code that adds
the mm_struct to a list.  Then a kernel thread empties the list
(perhaps via the work queue mechanism), doing the stuff in lines
07-10 for each mm_struct.  This would eliminate the possibility of
mmput() sleeping, potentially making things easier for other callers
of mmput() and causing fewer surprises.  Any comments?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
