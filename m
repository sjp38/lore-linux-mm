Date: Tue, 23 Jan 2007 11:10:11 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bug 7870] New: mlock() function does not comply with Posix
 Standard
Message-Id: <20070123111011.ee4c292b.akpm@osdl.org>
In-Reply-To: <200701231831.l0NIVLJ0012393@fire-2.osdl.org>
References: <200701231831.l0NIVLJ0012393@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: gents@erols.com
Cc: "bugme-daemon@kernel-bugs.osdl.org" <bugme-daemon@bugzilla.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Jan 2007 10:31:21 -0800
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=7870
> 
>            Summary: mlock() function does not comply with Posix Standard
>     Kernel Version: 2.6.16.10 and above
>             Status: NEW
>           Severity: normal
>              Owner: akpm@osdl.org
>          Submitter: gents@erols.com
> 
> 
> Most recent kernel where this bug did *NOT* occur:
> 2.6.16.9
> Distribution:
> SuSE SLES10, SuSE 10, 10.1, 10.2, 
> Hardware Environment:
> Any - verified in Sun Galaxy G4 4 x AMD 64 Rev E Processors
> Software Environment:
> SuSE SLES10
> Problem Description:
> The implementation of mlock() does not conform to the POSIX standard:
> 
> The C/C++ run-time library function mlock() overcommits memory.
> This leads to swapping, consumption of swap space, and the
> killing of processes which had previously, successfully
> executed a call to mlock(). Because processes are killed,
> log files do not accurately reflect events.
> 
> The man pages state
> 
> The mlock() function shall cause those whole pages contain-
> ing any part of the address space of the process star-
> ting at address $addr and continuing for $len bytes to be
> memory-resident until unlocked or until the process exits
> or execs another process image. The implementation may
> require that addr be a multiple of {PAGESIZE}.
> 
> The appropriate privilege is required to lock process
> memory with mlock().
> 
> The current version of mlock() does NOT comply with either
> of these statements. Privileges are required in order to
> lock part of a process' memory into physical memory.
> 
> Kernels after 2.6.9 incorrectly requires no privilege.
> Once an address range has been locked into physi-
> cal memory, it is supposed to remain memory-resident
> until the process unlocks it or exits. Kernels after
> 2.6.9 overcommits physical memory and then kills processes
> to reclaim it.
> 
> mlock() is supposed to be able to return the following
> errors:
> 
> The mlock() function may fail if:
> 
> ENOMEM Locking the pages mapped by the specified range
> would exceed an implementation-defined limit on the
> amount of memory that the process may lock.
> 
> EPERM The calling process does not have the appropriate
> privilege to perform the requested operation.
> 
> Kernels after 2.6.9 no longer signal EPERM because the implementation is
> non-compliant. It also no longer
> indicates ENOMEM appropriately for a privileged process
> for the same reason.
> 
> The code is
> 
> 128 int error = -ENOMEM; // init error # to an error
> 
> 144 if ((locked <= lock_limit) || capable(CAP_IPC_LOCK))
> 145 error = do_mlock(start, len, 1);
> 146 up_write(&current->mm->mmap_sem);
> 147 return error;
> 
> Where, if locked > lock_limit and capable returns "TRUE", sys_mlock() will call
> do_mlock(). do_mlock() will not
> return an error unless the starting address or length is
> illegal. So the system will apply
> physical locks to pages beyond the lock limit.
> 
> It is suggested that the above code should be something
> like this:
> 
> 144' if ( (locked <= lock_limit) && capable(CAP_IPC_LOCK) )
> 145' error = do_mlock(start, len, 1) ;
> 
> Inspected the mlock() code on 2.6.17.10 and 2.6.18.3 and code has not changed.
> Steps to reproduce:
> Test code available on request.
> 
> 
> ** Thanks for your time, this is causing problems in a HPTC environment, **
> ted

I don't understand this.  We permit unprivileged applications to mlock up to
eight pages, which is unlikely to cause out-of-memory problems.

Have you increased rlimit[RLIMIT_MEMLOCK]?

Is it possible for you to provide a simple testcase?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
