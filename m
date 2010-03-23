Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id F0C5C6B01AF
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 13:24:17 -0400 (EDT)
Date: Tue, 23 Mar 2010 10:22:08 -0400
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 15618] New: 2.6.18->2.6.32->2.6.33 huge
 regression in performance
Message-Id: <20100323102208.512c16cc.akpm@linux-foundation.org>
In-Reply-To: <bug-15618-10286@https.bugzilla.kernel.org/>
References: <bug-15618-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, ant.starikov@gmail.com, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 23 Mar 2010 16:13:25 GMT bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=15618
> 
>            Summary: 2.6.18->2.6.32->2.6.33 huge regression in performance
>            Product: Process Management
>            Version: 2.5
>     Kernel Version: 2.6.32
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Other
>         AssignedTo: process_other@kernel-bugs.osdl.org
>         ReportedBy: ant.starikov@gmail.com
>         Regression: No
> 
> 
> We have benchmarked some multithreaded code here on 16-core/4-way opteron 8356
> host on number of kernels (see below) and found strange results.
> Up to 8 threads we didn't see any noticeable differences in performance, but
> starting from 9 threads performance diverges substantially. I provide here
> results for 14 threads

lolz.  Catastrophic meltdown.  Thanks for doing all that work - at a
guess I'd say it's mmap_sem.  Perhaps with some assist from the CPU
scheduler.

If you change the config to set CONFIG_RWSEM_GENERIC_SPINLOCK=n,
CONFIG_RWSEM_XCHGADD_ALGORITHM=y does it help?

Anyway, there's a testcase in bugzilla and it looks like we got us some
work to do.


> 2.6.18-164.11.1.el5 (centos)
> 
> user time: ~60 sec
> sys time: ~12 sec
> 
> 2.6.32.9-70.fc12.x86_64 (fedora-12)
> 
> user time: ~60 sec
> sys time: ~75 sec
> 
> 2.6.33-0.46.rc8.git1.fc13.x86_64 (fedora-12 + rawhide kernel)
> 
> user time: ~60 sec
> sys time: ~300 sec
> 
> In all three cases real time regress corresponding to giving numbers.
> 
> Binary used for all three cases is exactly the same (compiled on centos).
> Setups for all three cases so identical as possible (last two - the same
> fedora-12 setup booted with different kernels).
> 
> What can be reason of this regress in performance? Is it possible to tune
> something to recover performance on 2.6.18 kernel? 
> 
> I perf'ed on 2.6.32.9-70.fc12.x86_64 kernel
> 
> report (top part only):
> 
> 43.64% dve22lts-mc [kernel] [k] _spin_lock_irqsave 
> 32.93% dve22lts-mc ./dve22lts-mc [.] DBSLLlookup_ret 
> 5.37% dve22lts-mc ./dve22lts-mc [.] SuperFastHash 
> 3.76% dve22lts-mc /lib64/libc-2.11.1.so [.] __GI_memcpy 
> 2.60% dve22lts-mc [kernel] [k] clear_page_c 
> 1.60% dve22lts-mc ./dve22lts-mc [.] index_next_dfs
> 
> stat: 
> 129875.554435 task-clock-msecs # 10.210 CPUs 
> 1883 context-switches # 0.000 M/sec 
> 17 CPU-migrations # 0.000 M/sec 
> 2695310 page-faults # 0.021 M/sec 
> 298370338040 cycles # 2297.356 M/sec 
> 130581778178 instructions # 0.438 IPC 
> 42517143751 cache-references # 327.368 M/sec 
> 101906904 cache-misses # 0.785 M/sec 
> 
> callgraph(top part only):
> 
> 53.09%      dve22lts-mc  [kernel]                                         [k]
> _spin_lock_irqsave
>                |          
>                |--49.90%-- __down_read_trylock
>                |          down_read_trylock
>                |          do_page_fault
>                |          page_fault
>                |          |          
>                |          |--99.99%-- __GI_memcpy
>                |          |          |          
>                |          |          |--84.28%-- (nil)
>                |          |          |          
>                |          |          |--9.78%-- 0x100000000
>                |          |          |          
>                |          |           --5.94%-- 0x1
>                |           --0.01%-- 
> [...]
> 
>                |          
>                |--49.39%-- __up_read
>                |          up_read
>                |          |          
>                |          |--100.00%-- do_page_fault
>                |          |          page_fault
>                |          |          |          
>                |          |          |--99.99%-- __GI_memcpy
>                |          |          |          |          
>                |          |          |          |--84.18%-- (nil)
>                |          |          |          |          
>                |          |          |          |--10.13%-- 0x100000000
>                |          |          |          |          
>                |          |          |           --5.69%-- 0x1
>                |          |           --0.01%-- 
> [...]
> 
>                |           --0.00%-- 
> [...]
> 
>                 --0.72%-- 
> [...]
> 
> 
> 
> On 2.6.33 I see similar picture with spin-lock plus addition of a lot of time
> spent in cgroup related kernel calls.
> 
> If it is necessary, I can attach binary for tests.
> 
> -- 
> Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
