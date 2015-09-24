Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 80E386B0268
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 17:14:44 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so83563899pad.1
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 14:14:44 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1bbn0107.outbound.protection.outlook.com. [157.56.111.107])
        by mx.google.com with ESMTPS id vm6si312656pbc.96.2015.09.24.14.14.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 24 Sep 2015 14:14:43 -0700 (PDT)
Subject: Re: numa balancing stuck in task_work_run
References: <5604665D.3030504@stratus.com>
From: Joe Lawrence <joe.lawrence@stratus.com>
Message-ID: <560467B8.6000101@stratus.com>
Date: Thu, 24 Sep 2015 17:14:32 -0400
MIME-Version: 1.0
In-Reply-To: <5604665D.3030504@stratus.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org

[ +cc for linux-mm mailinglist address ]

On 09/24/2015 05:08 PM, Joe Lawrence wrote:
> Hi Mel, Rik et al,
> 
> We've encountered interesting NUMA balancing behavior on RHEL7.1,
> reproduced with an upstream 4.2 kernel (of similar .config), that can
> leave a user process trapped in the kernel performing task_numa_work.
> 
> Our test group set up a server with 256GB memory running a program that
> allocates and dirties ~50% of that memory.  They reported the following
> condition when they attempted to kill the test process -- the signal was
> never handled, instead traces showed the task stuck here:
> 
>   PID: 36205  TASK: ffff887a692a8b60  CPU: 23  COMMAND: "memory_test_64"
>       [exception RIP: change_protection_range+0x4f8]
>       RIP: ffffffff8118a878  RSP: ffff887a777c3d68  RFLAGS: 00000282
>       RAX: ffff887f24065141  RBX: ffff887a38e8ee58  RCX: 00000000d37a9780
>       RDX: 80000034dea5e906  RSI: 00000006e9bcb000  RDI: 80000034dea5e906
>       RBP: ffff887a777c3e60   R8: ffff887ae51f6948   R9: 0000000000000001
>       R10: 0000000000000000  R11: ffff887f26f6d428  R12: 0000000000000000
>       R13: 00000006e9c00000  R14: 8000000000000025  R15: 00000006e9bcb000
>       CS: 0010  SS: 0018
>    #0 [ffff887a777c3e68] change_protection at ffffffff8118abf5
>    #1 [ffff887a777c3ea0] change_prot_numa at ffffffff811a106b
>    #2 [ffff887a777c3eb0] task_numa_work at ffffffff810adb23
>    #3 [ffff887a777c3f00] task_work_run at ffffffff81093b37
>    #4 [ffff887a777c3f30] do_notify_resume at ffffffff81013b0c
>    #5 [ffff887a777c3f50] retint_signal at ffffffff8160bafc
>       RIP: 00000000004025c4  RSP: 00007fff80aa5cf0  RFLAGS: 00000206
>       RAX: 0000000ddaa64a60  RBX: 00000000000fdd00  RCX: 00000000000afbc0
>       RDX: 00007fe45b6b6010  RSI: 000000000002dd50  RDI: 0000000ddaa36d10
>       RBP: 00007fff80aa5d40   R8: 0000000000000000   R9: 000000000000007d
>       R10: 00007fff80aa5a70  R11: 0000000000000246  R12: 00007fe45b6b6010
>       R13: 00007fff80aa5f30  R14: 0000000000000000  R15: 0000000000000000
>       ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
> 
> A quick sanity check of the kernel .config and sysctl values:
> 
>   % grep NUMA .config
>   CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
>   CONFIG_NUMA_BALANCING=y
>   CONFIG_NUMA_BALANCING_DEFAULT_ENABLED=y
>   # CONFIG_X86_NUMACHIP is not set
>   CONFIG_NUMA=y
>   CONFIG_AMD_NUMA=y
>   CONFIG_X86_64_ACPI_NUMA=y
>   # CONFIG_NUMA_EMU is not set
>   CONFIG_USE_PERCPU_NUMA_NODE_ID=y
>   CONFIG_ACPI_NUMA=y
> 
>   % sysctl -a | grep numa_balancing
>   kernel.numa_balancing = 1
>   kernel.numa_balancing_scan_delay_ms = 1000
>   kernel.numa_balancing_scan_period_max_ms = 60000
>   kernel.numa_balancing_scan_period_min_ms = 1000
>   kernel.numa_balancing_scan_size_mb = 256
> 
> A systemtap probe confirmed the task was indeed stuck in task_work_run,
> with new task_work_add occurring before the previous task_numa_work had a
> chance to return (prefix is current jiffies):
> 
>   4555133534: kernel.function("task_numa_work@kernel/sched/fair.c:1796")
>   4555133676: kernel.function("task_work_add@kernel/task_work.c:8")
>   4555134412: kernel.function("task_numa_work@kernel/sched/fair.c:1796").return
>   4555134412: kernel.function("task_numa_work@kernel/sched/fair.c:1796")
>   4555134554: kernel.function("task_work_add@kernel/task_work.c:8")
>   4555135291: kernel.function("task_numa_work@kernel/sched/fair.c:1796").return
>   4555135291: kernel.function("task_numa_work@kernel/sched/fair.c:1796")
>   4555135433: kernel.function("task_work_add@kernel/task_work.c:8")
>   4555136167: kernel.function("task_numa_work@kernel/sched/fair.c:1796").return
>   4555136167: kernel.function("task_numa_work@kernel/sched/fair.c:1796")
>   4555136309: kernel.function("task_work_add@kernel/task_work.c:8")
> 
> Looking at the implementation of task_work_run, it will continue to
> churn as long as task->task_works will feed it.
> 
> I did further systemtap investigation to watch the program find its way
> into this condition.  What I found was that the numa_scan_period_max was
> dropping < 200.  This was an effect of a ballooning MM_ANONPAGES value
> (by way of task_nr_scan_windows() and task_scan_max()):
> 
>   [ ... shortly after program start ... ]
> 
>   numa_scan_period_max = 1621     task_nr_scan_windows = 39       MM_ANONPAGES = 2548181
>   numa_scan_period_max = 1538     task_nr_scan_windows = 40       MM_ANONPAGES = 2574349
>   numa_scan_period_max = 1538     task_nr_scan_windows = 40       MM_ANONPAGES = 2599734 
> 
>   [ ... snip about 20 minutes of data... ]
> 
>   numa_scan_period_max = 119      task_nr_scan_windows = 503      MM_ANONPAGES = 32956990
>   numa_scan_period_max = 119      task_nr_scan_windows = 503      MM_ANONPAGES = 32958955
>   numa_scan_period_max = 119      task_nr_scan_windows = 503      MM_ANONPAGES = 32960104
>   numa_scan_period_max = 119      task_nr_scan_windows = 503      MM_ANONPAGES = 32960104
> 
> update_task_scan_period will assign the numa_scan_period to the minimum
> of numa_scan_period_max and numa_scan_period * 2.  As
> numa_scan_period_max decreases, it will be the smaller value and hence
> the numa_next_scan's get closer and closer.
> 
> Looking back through the changelog, commit 598f0ec0bc99 "sched/numa:
> Set the scan rate proportional to the memory usage of the task being
> scanned" changed numa_balancing_scan_period_max semantics to tune the
> length of time to complete a full scan.  This may introduce the
> possibility of falling into this condition, though I'm not 100% sure.
> 
> Let me know if there is any additional data that would be helpful to
> report.  In the meantime, I've run a few hours with the following
> workaround to hold off the task_numa_work grind.
> 
> Regards,
> 
> -- Joe
> 
> -->8-- -->8-- -->8-- -->8-- -->8-- -->8-- -->8-- -->8-- -->8-- -->8--
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 3d6baa7d4534..df34df492949 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -467,6 +467,11 @@ struct mm_struct {
>  	 */
>  	unsigned long numa_next_scan;
>  
> +	/* numa_last_work_time is the jiffy runtime of the previous
> +	 * task_numa_work invocation, providing hysteresis for numa_next_scan
> +	 * so it will be at least this many jiffies in the future. */
> +	unsigned long numa_last_work_time;
> +
>  	/* Restart point for scanning and setting pte_numa */
>  	unsigned long numa_scan_offset;
>  
> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> index 6e2e3483b1ec..16a96297e2a3 100644
> --- a/kernel/sched/fair.c
> +++ b/kernel/sched/fair.c
> @@ -1651,7 +1651,7 @@ static void update_task_scan_period(struct task_struct *p,
>  		p->numa_scan_period = min(p->numa_scan_period_max,
>  			p->numa_scan_period << 1);
>  
> -		p->mm->numa_next_scan = jiffies +
> +		p->mm->numa_next_scan = jiffies + p->mm->numa_last_work_time +
>  			msecs_to_jiffies(p->numa_scan_period);
>  
>  		return;
> @@ -2269,6 +2269,9 @@ out:
>  		mm->numa_scan_offset = start;
>  	else
>  		reset_ptenuma_scan(p);
> +
> +	mm->numa_last_work_time = jiffies - now;
> +
>  	up_read(&mm->mmap_sem);
>  }
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
