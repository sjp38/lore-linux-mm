Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 9B93E6B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 10:18:37 -0400 (EDT)
Received: by ioll68 with SMTP id l68so93131290iol.3
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 07:18:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p17si25387863igi.92.2015.10.22.07.18.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 07:18:37 -0700 (PDT)
Date: Thu, 22 Oct 2015 16:18:31 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 14/23] userfaultfd: wake pending userfaults
Message-ID: <20151022141831.GA1331@redhat.com>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
 <1431624680-20153-15-git-send-email-aarcange@redhat.com>
 <20151022121056.GB7520@twins.programming.kicks-ass.net>
 <20151022132015.GF19147@redhat.com>
 <20151022133824.GR17308@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151022133824.GR17308@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

On Thu, Oct 22, 2015 at 03:38:24PM +0200, Peter Zijlstra wrote:
> On Thu, Oct 22, 2015 at 03:20:15PM +0200, Andrea Arcangeli wrote:
> 
> > If schedule spontaneously wakes up a task in TASK_KILLABLE state that
> > would be a bug in the scheduler in my view. Luckily there doesn't seem
> > to be such a bug, or at least we never experienced it.
> 
> Well, there will be a wakeup, just not the one you were hoping for.
> 
> We have code that does:
> 
> 	@cond = true;
> 	get_task_struct(p);
> 	queue(p)
> 
> 				/* random wait somewhere */
> 				for (;;) {
> 					prepare_to_wait();
> 					if (@cond)
> 					  break;
> 
> 				...
> 
> 				handle_userfault()
> 				  ...
> 				  schedule();
> 	...
> 
> 	dequeue(p)
> 	wake_up_process(p) ---> wakeup without userfault wakeup
> 
> 
> These races are (extremely) rare, but they do exist. Therefore one must
> never assume schedule() will not spuriously wake because of these
> things.
> 
> Also, see:
> 
> lkml.kernel.org/r/CA+55aFwHkOo+YGWKYROmce1-H_uG3KfEUmCkJUerTj=ojY2H6Q@mail.gmail.com

With one more spinlock taken in the fast path we could recheck if the
waitqueue is still queued and this is a false positive extremely rare
spurious wakeup, and in such case set the state back to TASK_KILLABLE
and schedule.

However in the long term such a spinlock should be removed because
it's faster to stick with the current lockless list_empty_careful and
not to recheck the auto-remove waitqueue, but then we must be able to
re-enter handle_userfault() even if FAULT_FLAG_TRIED was set
(currently we can't return VM_FAULT_RETRY if FAULT_FLAG_TRIED is set
and that's the problem). This change is planned for a long time as we
need it to arm the vma-less write protection while the app is running,
so I'm not sure if it's worth going for the short term fix if this is
extremely rare.

The risk of memory corruption is still zero no matter what happens
here, in the extremely rare case the app will get a SIGBUS or a
syscall will return -EFAULT. The kernel also cannot crash. So it's not
very severe concern if it happens extremely rarely (we never
reproduced it and stress testing run for months). Of course in the
longer term this would have been fixed regardless as said in previous
email.

I think going for the longer term fix that was already planned, is
better than doing a short term fix and the real question is how I
should proceed to change the arch code and gup to cope with
handle_userfault() being re-entered.

The simplest thing is to drop FAULT_FLAG_TRIED as a whole. Or I could
add a new VM_FAULT_USERFAULT flag specific to handle_userfault that
would be returned even if FAULT_FLAG_TRIED is set, so that only
userfaults will be allowed to be repeated indefinitely (and then
VM_FAULT_USERFAULT shouldn't trigger a transition to FAULT_FLAG_TRIED,
unlike VM_FAULT_RETRY does).

This is all about being allowed to drop the mmap_sem.

If we'd check the waitqueue with the spinlock (to be sure the wakeup
isn't happening from under us while we check if we got an userfault
wakeup or if this is a spurious schedule), we could also limit the
VM_FAULT_RETRY to 2 max events if I add a FAULT_FLAG_TRIED2 and I
still use VM_FAULT_RETRY (instead of VM_FAULT_USERFAULT).

Being able to return VM_FAULT_RETRY indefinitely is only needed if we
don't handle the extremely wakeup race condition in handle_userfault
by taking the spinlock once more time in the fast path (i.e. after the
schedule).

I'm not exactly sure why we allow VM_FAULT_RETRY only once currently
so I'm tempted to drop FAULT_FLAG_TRIED entirely.

I've no real preference on how to tweak the page fault code to be able
to return VM_FAULT_RETRY indefinitely and I would aim for the smallest
change possible, so if you've suggestions now it's good time.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
