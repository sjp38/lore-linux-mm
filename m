Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id ED0846B0032
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 17:32:23 -0400 (EDT)
Date: Thu, 27 Jun 2013 14:32:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 59901] New: OOM deadlock
Message-Id: <20130627143221.4d7bf7a6899f5258c6777d32@linux-foundation.org>
In-Reply-To: <bug-59901-27@https.bugzilla.kernel.org/>
References: <bug-59901-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: bugzilla-daemon@bugzilla.kernel.org, bvanassche@acm.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 19 Jun 2013 08:03:23 +0000 (UTC) bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=59901
> 
>            Summary: OOM deadlock
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: v3.10-rc6
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: akpm@linux-foundation.org
>         ReportedBy: bvanassche@acm.org
>         Regression: No
> 
> 
> Apparently with kernel v3.10-rc6 when triggering an OOM enough times the mm
> subsystem locks up (haven't tried any other kernel versions yet). Leaving the
> following script running for a few minutes is sufficient to trigger the lockup:
> 
> #!/bin/bash
> swapoff -a
> while true; do
>     free="$(free | sed -n
> 's|.*buffers/cache:[[:blank:]]*[^[:blank:]]*[[:blank:]]*||p')"
>     for ((i=free-15000;i<free;i+=1000)); do
>         echo "size $i KB ..."
>     dd if=/dev/zero of=/dev/null bs=${i}K count=1
>     done
> done
> 
> When the lockup occurs sometimes the following kernel messages are generated:
> 
> [  840.360097] INFO: task rtkit-daemon:1538 blocked for more than 120 seconds.  
> [  840.360117] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this 
> [  840.360122] rtkit-daemon    D ffffffffffffffff     0  1538      1 0x00000000 
> [  840.360129]  ffff880029d19dc0 0000000000000046 ffff880029d10000
> ffff880029d19
> [  840.360136]  ffff880029d19fd8 ffff880029d19fd8 ffff880036dc0000
> ffff880029d10
> [  840.360142]  ffff880029d10000 ffff88003bc347f0 ffff88003bc347f8
> ffff88003bc34
> [  840.360149] Call Trace:                                                      
> [  840.360158]  [<ffffffff8152b9e9>] schedule+0x29/0x70                         
> [  840.360162]  [<ffffffff8152c415>] rwsem_down_write_failed+0xe5/0x190         
> [  840.360167]  [<ffffffff8108046d>] ? sched_clock_local+0x1d/0x90              
> [  840.360173]  [<ffffffff81245d23>] call_rwsem_down_write_failed+0x13/0x20     
> [  840.360177]  [<ffffffff8152a1aa>] ? down_write+0x9a/0xc0                     
> [  840.360182]  [<ffffffff811330e4>] ? vm_mmap_pgoff+0x54/0xb0
> [  840.360186]  [<ffffffff811330e4>] vm_mmap_pgoff+0x54/0xb0
> [  840.360190]  [<ffffffff8114561b>] SyS_mmap_pgoff+0x5b/0x280
> [  840.360194]  [<ffffffff81245dbe>] ? trace_hardirqs_on_thunk+0x3a/0x3f
> [  840.360198]  [<ffffffff81006882>] SyS_mmap+0x22/0x30
> [  840.360208]  [<ffffffff815367d9>] system_call_fastpath+0x16/0x1b
> [  840.360211] 1 lock held by rtkit-daemon/1538:
> [  840.360213]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff811330e4>]
> vm_mmap_p
> 
> -- 
> Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
> ------- You are receiving this mail because: -------
> You are the assignee for the bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
