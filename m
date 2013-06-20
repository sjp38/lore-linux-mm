Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id CA6646B0033
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 07:49:47 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id d17so3887694eek.0
        for <linux-mm@kvack.org>; Thu, 20 Jun 2013 04:49:46 -0700 (PDT)
Date: Thu, 20 Jun 2013 13:49:43 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] mm: Revert pinned_vm braindamage
Message-ID: <20130620114943.GB12125@gmail.com>
References: <20130606124351.GZ27176@twins.programming.kicks-ass.net>
 <0000013f1ad00ec0-9574a936-3a75-4ccc-a84c-4a12a7ea106e-000000@email.amazonses.com>
 <20130607110344.GA27176@twins.programming.kicks-ass.net>
 <0000013f1f1f79d1-2cf8cb8c-7e63-4e83-9f2b-7acc0e0638a1-000000@email.amazonses.com>
 <20130617110832.GP3204@twins.programming.kicks-ass.net>
 <0000013f536c60ee-9a1ca9da-b798-416a-a32e-c896813d3bac-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000013f536c60ee-9a1ca9da-b798-416a-a32e-c896813d3bac-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Peter Zijlstra <peterz@infradead.org>, akpm@linux-foundation.org, torvalds@linux-foundation.org, roland@kernel.org, tglx@linutronix.de, kosaki.motohiro@gmail.com, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-rdma@vger.kernel.org


* Christoph Lameter <cl@gentwo.org> wrote:

> On Mon, 17 Jun 2013, Peter Zijlstra wrote:
> 
> > They did no such thing; being one of those who wrote such code. I
> > expressly used RLIMIT_MEMLOCK for its the one limit userspace has to
> > limit pages that are exempt from paging.
> 
> Dont remember reviewing that. Assumptions were wrong in that patch then.
> 
> > > Pinned pages are exempted by the kernel. A device driver or some other
> > > kernel process (reclaim, page migration, io etc) increase the page count.
> > > There is currently no consistent accounting for pinned pages. The
> > > vm_pinned counter was introduced to allow the largest pinners to track
> > > what they did.
> >
> > No, not the largest, user space controlled pinnners. The thing that
> > makes all the difference is the _USER_ control.
> 
> The pinning *cannot* be done from user space. Here it is the IB subsystem
> that is doing it.

Peter clearly pointed it out that in the perf case it's user-space that 
initiates the pinned memory mapping which is resource-controlled via 
RLIMIT_MEMLOCK - and this was implemented that way before your commit 
broke the code.

You seem to be hell bent on defining 'memory pinning' only as "the thing 
done via the mlock*() system calls", but that is a nonsensical distinction 
that actively and incorrectly ignores other system calls that can and do 
pin memory legitimately.

If some other system call results in mapping pinned memory that is at 
least as restrictively pinned as an mlock()-ed vma (the perf syscall is 
such) then it's entirely proper design to be resource controlled under 
RLIMIT_MEMLOCK as well. In fact this worked so before your commit broke 
it.

> > > mlockall does not require CAP_IPC_LOCK. Never had an issue.
> >
> > MCL_FUTURE does absolutely require CAP_IPC_LOCK, MCL_CURRENT requires 
> > a huge (as opposed to the default 64k) RLIMIT or CAP_IPC_LOCK.
> >
> > There's no argument there, look at the code.
> 
> I am sorry but we have been mlockall() for years now without the issues 
> that you are bringing up. AFAICT mlockall does not require MCL_FUTURE.

You only have to read the mlockall() code to see that Peter's claim is 
correct:

mm/mlock.c:

SYSCALL_DEFINE1(mlockall, int, flags)
{
        unsigned long lock_limit;
        int ret = -EINVAL;

        if (!flags || (flags & ~(MCL_CURRENT | MCL_FUTURE)))
                goto out;

        ret = -EPERM;
        if (!can_do_mlock())
                goto out;
...


int can_do_mlock(void)
{
        if (capable(CAP_IPC_LOCK))
                return 1;
        if (rlimit(RLIMIT_MEMLOCK) != 0)
                return 1;
        return 0;
}
EXPORT_SYMBOL(can_do_mlock);

Q.E.D.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
