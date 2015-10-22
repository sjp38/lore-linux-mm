Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id BBEE96B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 09:20:21 -0400 (EDT)
Received: by padhk11 with SMTP id hk11so87009230pad.1
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 06:20:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id la1si21066159pbc.208.2015.10.22.06.20.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 06:20:20 -0700 (PDT)
Date: Thu, 22 Oct 2015 15:20:15 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 14/23] userfaultfd: wake pending userfaults
Message-ID: <20151022132015.GF19147@redhat.com>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
 <1431624680-20153-15-git-send-email-aarcange@redhat.com>
 <20151022121056.GB7520@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151022121056.GB7520@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

On Thu, Oct 22, 2015 at 02:10:56PM +0200, Peter Zijlstra wrote:
> On Thu, May 14, 2015 at 07:31:11PM +0200, Andrea Arcangeli wrote:
> > @@ -255,21 +259,23 @@ int handle_userfault(struct vm_area_struct *vma, unsigned long address,
> >  	 * through poll/read().
> >  	 */
> >  	__add_wait_queue(&ctx->fault_wqh, &uwq.wq);
> > -	for (;;) {
> > -		set_current_state(TASK_KILLABLE);
> > -		if (!uwq.pending || ACCESS_ONCE(ctx->released) ||
> > -		    fatal_signal_pending(current))
> > -			break;
> > -		spin_unlock(&ctx->fault_wqh.lock);
> > +	set_current_state(TASK_KILLABLE);
> > +	spin_unlock(&ctx->fault_wqh.lock);
> >  
> > +	if (likely(!ACCESS_ONCE(ctx->released) &&
> > +		   !fatal_signal_pending(current))) {
> >  		wake_up_poll(&ctx->fd_wqh, POLLIN);
> >  		schedule();
> > +		ret |= VM_FAULT_MAJOR;
> > +	}
> 
> So what happens here if schedule() spontaneously wakes for no reason?
> 
> I'm not sure enough of userfaultfd semantics to say if that would be
> bad, but the code looks suspiciously like it relies on schedule() not to
> do that; which is wrong.

That would repeat the fault and trigger the DEBUG_VM printk above,
complaining that FAULT_FLAG_ALLOW_RETRY is not set. It is only a
problem for kernel faults (copy_user/get_user_pages*). Userland won't
error out in such a way because userland would return 0 and not
VM_FAULT_RETRY. So it's only required when the task schedule in
TASK_KILLABLE state.

If schedule spontaneously wakes up a task in TASK_KILLABLE state that
would be a bug in the scheduler in my view. Luckily there doesn't seem
to be such a bug, or at least we never experienced it.

Overall this dependency on the scheduler will be lifted soon, as it
must be lifted in order to track the write protect faults, so longer
term this is not a concern and this is not a design issue, but this
remains an implementation detail that avoided to change the arch code
and gup.

If you send a reproducer to show how the current scheduler can wake up
the task in TASK_KILLABLE despite not receiving a wakeup, that would
help too as we never experienced that.

The reason this dependency will be lifted soon is that the userfaultfd
write protect tracking may be armed at any time while the app is
running so we may already be in the middle of a page fault that
returned VM_FAULT_RETRY by the time we arm the write protect
tracking. So longer term the arch page fault and
__get_user_pages_locked must allow handle_userfault() to return
VM_FAULT_RETRY even if FAULT_FLAG_TRIED is set. Then we don't care if
the task is waken.

Waking a task in TASK_KILLABLE state it will still waste CPU so the
scheduler still shouldn't do that. All load balancing works better if
the task isn't running anyway so I can't imagine a good reason for
wanting to run a task in TASK_KILLABLE state before it gets the
wakeup.

Trying to predict that a wakeup is always happening in less time than
it takes to schedule the task out of the CPU, sounds a very CPU
intensive thing to measure and it's probably better to leave those
heuristics in the caller like by spinning on a lock for a while before
blocking.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
