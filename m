Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id 1AF4A90008B
	for <linux-mm@kvack.org>; Thu, 30 Oct 2014 10:25:22 -0400 (EDT)
Received: by mail-yk0-f180.google.com with SMTP id 9so2344833ykp.11
        for <linux-mm@kvack.org>; Thu, 30 Oct 2014 07:25:21 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 52si7319392yhu.139.2014.10.30.07.25.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 30 Oct 2014 07:25:21 -0700 (PDT)
Message-ID: <54524A2F.5050907@oracle.com>
Date: Thu, 30 Oct 2014 10:24:47 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: initialize variable for mem_cgroup_end_page_stat
References: <1414633464-19419-1-git-send-email-sasha.levin@oracle.com> <20141030082712.GB4664@dhcp22.suse.cz> <54523DDE.9000904@oracle.com> <20141030141401.GA24520@phnom.home.cmpxchg.org>
In-Reply-To: <20141030141401.GA24520@phnom.home.cmpxchg.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, riel@redhat.com, peterz@infradead.org, linux-mm@kvack.org

On 10/30/2014 10:14 AM, Johannes Weiner wrote:
>> The problem is that you are attempting to read 'locked' when you call
>> > mem_cgroup_end_page_stat(), so it gets used even before you enter the
>> > function - and using uninitialized variables is undefined.
> We are not using that value anywhere if !memcg.  What path are you
> referring to?

You're using that value as soon as you are passing it to a function, it
doesn't matter what happens inside that function.

>> > Yes, it's a compiler warning.
> Could you provide that please, including arch, and gcc version?

On x86,

$ gcc --version
gcc (GCC) 5.0.0 20141029 (experimental)

[   26.868116] ================================================================================
[   26.870376] UBSan: Undefined behaviour in mm/rmap.c:1084:2
[   26.871792] load of value 255 is not a valid value for type '_Bool'
[   26.873256] CPU: 4 PID: 8304 Comm: rngd Not tainted 3.18.0-rc2-next-20141029-sasha-00039-g77ed13d-dirty #1427
[   26.875636]  ffff8800cac17ff0 0000000000000000 0000000000000000 ffff880069ffbb28
[   26.877611]  ffffffffaf010c16 0000000000000037 ffffffffb1c0d050 ffff880069ffbb38
[   26.879140]  ffffffffa6e97899 ffff880069ffbbb8 ffffffffa6e97cc7 ffff880069ffbbb8
[   26.880765] Call Trace:
[   26.881185] dump_stack (lib/dump_stack.c:52)
[   26.882755] ubsan_epilogue (lib/ubsan.c:159)
[   26.883555] __ubsan_handle_load_invalid_value (lib/ubsan.c:482)
[   26.884492] ? mem_cgroup_begin_page_stat (mm/memcontrol.c:1962)
[   26.885441] ? unmap_page_range (./arch/x86/include/asm/paravirt.h:694 mm/memory.c:1091 mm/memory.c:1258 mm/memory.c:1279 mm/memory.c:1303)
[   26.886242] page_remove_rmap (mm/rmap.c:1084 mm/rmap.c:1096)
[   26.886922] unmap_page_range (./arch/x86/include/asm/atomic.h:27 include/linux/mm.h:463 mm/memory.c:1146 mm/memory.c:1258 mm/memory.c:1279 mm/memory.c:1303)
[   26.887824] unmap_single_vma (mm/memory.c:1348)
[   26.888582] unmap_vmas (mm/memory.c:1377 (discriminator 3))
[   26.889430] exit_mmap (mm/mmap.c:2837)
[   26.890060] mmput (kernel/fork.c:659)
[   26.890656] do_exit (./arch/x86/include/asm/thread_info.h:168 kernel/exit.c:462 kernel/exit.c:747)
[   26.891359] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[   26.892287] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2559 kernel/locking/lockdep.c:2601)
[   26.893107] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1598 (discriminator 2))
[   26.893974] do_group_exit (include/linux/sched.h:775 kernel/exit.c:873)
[   26.894695] SyS_exit_group (kernel/exit.c:901)
[   26.895433] tracesys_phase2 (arch/x86/kernel/entry_64.S:529)
[   26.896134] ================================================================================


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
