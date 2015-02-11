Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 3E92D6B0032
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 09:22:48 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id eu11so4263713pac.7
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 06:22:48 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id y4si1142026par.93.2015.02.11.06.22.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 11 Feb 2015 06:22:46 -0800 (PST)
Subject: Re: How to handle TIF_MEMDIE stalls?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20141230112158.GA15546@dhcp22.suse.cz>
	<201502092044.JDG39081.LVFOOtFHQFOMSJ@I-love.SAKURA.ne.jp>
	<201502102258.IFE09888.OVQFJOMSFtOLFH@I-love.SAKURA.ne.jp>
	<20150210151934.GA11212@phnom.home.cmpxchg.org>
	<201502111123.ICD65197.FMLOHSQJFVOtFO@I-love.SAKURA.ne.jp>
In-Reply-To: <201502111123.ICD65197.FMLOHSQJFVOtFO@I-love.SAKURA.ne.jp>
Message-Id: <201502112237.CDD87547.tJOFFVHLOOQSMF@I-love.SAKURA.ne.jp>
Date: Wed, 11 Feb 2015 22:37:42 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: oleg@redhat.com, mhocko@suse.cz
Cc: hannes@cmpxchg.org, david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org

(Asking Oleg this time.)

Tetsuo Handa wrote:
> Though, more serious behavior with this reproducer is (B) where the system
> stalls forever without kernel messages being saved to /var/log/messages .
> out_of_memory() does not select victims until the coredump to pipe can make
> progress whereas the coredump to pipe can't make progress until memory
> allocation succeeds or fails.

This behavior is related to commit d003f371b2701635 ("oom: don't assume
that a coredumping thread will exit soon"). That commit tried to take
SIGNAL_GROUP_COREDUMP into account, but actually it is failing to do so.

I tested with debug printk() and got the result shown below.

----------
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index d503e9c..1f684df 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -268,8 +268,12 @@ enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
        if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
                if (unlikely(frozen(task)))
                        __thaw_task(task);
-               if (!force_kill)
+               if (!force_kill) {
+                       printk_ratelimited(KERN_INFO "OOM: Waiting for %s(%u) "
+                                          ": TIF_MEMDIE\n", task->comm,
+                                          task->pid);
                        return OOM_SCAN_ABORT;
+               }
        }
        if (!task->mm)
                return OOM_SCAN_CONTINUE;
@@ -281,8 +285,12 @@ enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
        if (oom_task_origin(task))
                return OOM_SCAN_SELECT;

-       if (task_will_free_mem(task) && !force_kill)
+       if (task_will_free_mem(task) && !force_kill) {
+               printk_ratelimited(KERN_INFO "OOM: Waiting for %s(%u) "
+                                  ": will_free_mem\n", task->comm,
+                                  task->pid);
                return OOM_SCAN_ABORT;
+       }

        return OOM_SCAN_OK;
 }
@@ -439,6 +447,8 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
         * its children or threads, just set TIF_MEMDIE so it can die quickly
         */
        if (task_will_free_mem(p)) {
+               printk(KERN_INFO "OOM: Waiting for %s(%u) : WILL_FREE_MEM\n",
+                      p->comm, p->pid);
                set_tsk_thread_flag(p, TIF_MEMDIE);
                put_task_struct(p);
                return;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8e20f9c..4a2b19b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2381,9 +2381,6 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
                /* The OOM killer does not needlessly kill tasks for lowmem */
                if (high_zoneidx < ZONE_NORMAL)
                        goto out;
-               /* The OOM killer does not compensate for light reclaim */
-               if (!(gfp_mask & __GFP_FS))
-                       goto out;
                /*
                 * GFP_THISNODE contains __GFP_NORETRY and we never hit this.
                 * Sanity check for bare calls of __GFP_THISNODE, not real OOM.
----------

----------
[   66.374198] a.out[9918]: segfault at 2591768 ip 000000000040091e sp 0000000002591770 error 6[   66.374220] a.out[9919]: segfault at 2592778 ip 000000000040091e sp 0000000002592780 error 6 in a.out[400000+1000]

[   66.378705]  in a.out[400000+1000]
[   67.997279] OOM: Waiting for a.out(9917) : will_free_mem
(...snipped...)
[   90.952640] a.out           D 0000000000000002     0  9916   7303 0x00000080
[   90.954478]  ffff88007a4ca240 0000000000012f80 ffff88007bcc7fd8 0000000000012f80
[   90.956468]  ffff88007a4ca240 ffff88007fffc000 ffffffff8111a945 0000000000000000
[   90.958475]  0000000000000000 000088007bcc7908 ffff88007a4ca240 ffffffff81015df5
[   90.960471] Call Trace:
[   90.961420]  [<ffffffff8111a945>] ? shrink_zone+0x105/0x2a0
[   90.962939]  [<ffffffff81015df5>] ? read_tsc+0x5/0x10
[   90.964364]  [<ffffffff810c0270>] ? ktime_get+0x30/0x90
[   90.965816]  [<ffffffff810f73b9>] ? delayacct_end+0x39/0x70
[   90.967322]  [<ffffffff8111b0e5>] ? do_try_to_free_pages+0x3e5/0x480
[   90.969115]  [<ffffffff815f23f3>] ? schedule_timeout+0x113/0x1b0
[   90.970796]  [<ffffffff810b9800>] ? migrate_timer_list+0x60/0x60
[   90.972380]  [<ffffffff81110c9e>] ? __alloc_pages_nodemask+0x7ae/0xa60
[   90.974090]  [<ffffffff81151eb2>] ? alloc_pages_vma+0x92/0x1a0
[   90.975643]  [<ffffffff81134037>] ? handle_mm_fault+0xd37/0x10e0
[   90.977212]  [<ffffffff8105194e>] ? __do_page_fault+0x17e/0x540
[   90.978753]  [<ffffffff81092fac>] ? update_curr+0xac/0x100
[   90.980228]  [<ffffffff810946cb>] ? put_prev_entity+0x5b/0x2c0
[   90.981763]  [<ffffffff8108ef1d>] ? pick_next_entity+0x9d/0x170
[   90.983305]  [<ffffffff8109157e>] ? set_next_entity+0x4e/0x60
[   90.984824]  [<ffffffff81097953>] ? pick_next_task_fair+0x453/0x520
[   90.986446]  [<ffffffff8100c6e0>] ? __switch_to+0x240/0x570
[   90.987943]  [<ffffffff81051d40>] ? do_page_fault+0x30/0x70
[   90.989453]  [<ffffffff815f5138>] ? page_fault+0x28/0x30
[   90.990987]  [<ffffffff812ed0bc>] ? __clear_user+0x1c/0x40
[   90.992481]  [<ffffffff8112cb16>] ? iov_iter_zero+0x66/0x2d0
[   90.993991]  [<ffffffff813c09d7>] ? read_iter_zero+0x37/0xa0
[   90.995515]  [<ffffffff81173470>] ? new_sync_read+0x80/0xd0
[   90.997027]  [<ffffffff81174678>] ? vfs_read+0x78/0x130
[   90.998492]  [<ffffffff8117477d>] ? SyS_read+0x4d/0xc0
[   90.999913]  [<ffffffff815f3729>] ? system_call_fastpath+0x12/0x17
[   91.001616] a.out           D ffff88007fc52f80     0  9917   9916 0x00000080
[   91.003485]  ffff880020b10000 0000000000012f80 ffff8800786d7fd8 0000000000012f80
[   91.005443]  ffff880020b10000 000000000000000a 0000000000000400 0000000100000001
[   91.007427]  0000000100000000 0000000000000000 0000000000000000 ffff8800786d7cc8
[   91.009348] Call Trace:
[   91.010281]  [<ffffffff8108d98d>] ? task_cputime+0x3d/0x80
[   91.011759]  [<ffffffff81066d8c>] ? do_exit+0x1dc/0xb40
[   91.013176]  [<ffffffff8106776a>] ? do_group_exit+0x3a/0x100
[   91.014661]  [<ffffffff810717fb>] ? get_signal+0x19b/0x770
[   91.016128]  [<ffffffff8100d451>] ? do_signal+0x31/0x6d0
[   91.017551]  [<ffffffff815ef532>] ? __schedule+0x272/0x760
[   91.019007]  [<ffffffff81087408>] ? check_preempt_curr+0x78/0xa0
[   91.020569]  [<ffffffff81089c98>] ? wake_up_new_task+0xf8/0x140
[   91.022094]  [<ffffffff81063bd8>] ? do_fork+0x138/0x340
[   91.023526]  [<ffffffff810ede7c>] ? __audit_syscall_entry+0xac/0xf0
[   91.025171]  [<ffffffff8100db5c>] ? do_notify_resume+0x6c/0x90
[   91.026700]  [<ffffffff815f39c7>] ? int_signal+0x12/0x17
[   91.028136] a.out           D ffff88007c6a66c0     0  9918   9917 0x00000084
[   91.029945]  ffff88007c6a66c0 0000000000012f80 ffff88007c6cbfd8 0000000000012f80
[   91.031886]  ffff88007c6a66c0 0000000000000003 ffff88007c6a759a 0000000000000046
[   91.033830]  0000000000000046 ffff88007c6a6f50 ffffffff81089a55 ffff88007c6cbcc8
[   91.035913] Call Trace:
[   91.036848]  [<ffffffff81089a55>] ? try_to_wake_up+0x1b5/0x2b0
[   91.038382]  [<ffffffff8109c7ef>] ? __wake_up_common+0x4f/0x80
[   91.039944]  [<ffffffff81066d8c>] ? do_exit+0x1dc/0xb40
[   91.041420]  [<ffffffff8106776a>] ? do_group_exit+0x3a/0x100
[   91.042931]  [<ffffffff810717fb>] ? get_signal+0x19b/0x770
[   91.044416]  [<ffffffff8109157e>] ? set_next_entity+0x4e/0x60
[   91.045941]  [<ffffffff8100d451>] ? do_signal+0x31/0x6d0
[   91.047376]  [<ffffffff815ef532>] ? __schedule+0x272/0x760
[   91.048836]  [<ffffffff81067282>] ? do_exit+0x6d2/0xb40
[   91.050251]  [<ffffffff8100db5c>] ? do_notify_resume+0x6c/0x90
[   91.051786]  [<ffffffff815f4422>] ? retint_signal+0x48/0x86
[   91.053256] a.out           S ffff88007fcd2f80     0  9919   9917 0x00000080
[   91.055081]  ffff88007c6a6f50 0000000000012f80 ffff88007c04bfd8 0000000000012f80
[   91.057026]  ffff88007c6a6f50 ffff88007c6a6f50 000200d27fffc6c0 0000000000000001
[   91.059006]  ffff88007c6a6f50 ffff88007c6a6f50 0000014100000001 0000000000000000
[   91.060952] Call Trace:
[   91.061893]  [<ffffffff8112b1ee>] ? copy_from_iter+0x10e/0x2d0
[   91.063456]  [<ffffffff8112b1ee>] ? copy_from_iter+0x10e/0x2d0
[   91.065025]  [<ffffffff8117bcb7>] ? pipe_wait+0x67/0xb0
[   91.066491]  [<ffffffff8109ced0>] ? wait_woken+0x90/0x90
[   91.068160]  [<ffffffff8117bde8>] ? pipe_write+0x88/0x450
[   91.069787]  [<ffffffff81173543>] ? new_sync_write+0x83/0xd0
[   91.071302]  [<ffffffff811736b7>] ? __kernel_write+0x57/0x140
[   91.072813]  [<ffffffff811c63fe>] ? dump_emit+0x8e/0xd0
[   91.074293]  [<ffffffff811c02cf>] ? elf_core_dump+0x146f/0x15d0
[   91.075848]  [<ffffffff811c6ca9>] ? do_coredump+0x769/0xe80
[   91.077308]  [<ffffffff8101634d>] ? native_sched_clock+0x2d/0x80
[   91.078861]  [<ffffffff8106fd2b>] ? __send_signal+0x16b/0x3a0
[   91.080384]  [<ffffffff810717f2>] ? get_signal+0x192/0x770
[   91.081831]  [<ffffffff8100d451>] ? do_signal+0x31/0x6d0
[   91.083234]  [<ffffffff8100db5c>] ? do_notify_resume+0x6c/0x90
[   91.084747]  [<ffffffff815f4422>] ? retint_signal+0x48/0x86
[   91.086210] a.out           D ffff88007c6a0000     0  9920   9917 0x00000080
[   91.088001]  ffff88007c6a0000 0000000000012f80 ffff88007b7affd8 0000000000012f80
[   91.089996]  ffff88007c6a0000 ffffea0001df9780 ffffffff81a5ba00 0000000000000200
[   91.091953]  ffff880036d8c480 0000000000000000 0000000000000000 ffff88007b7afcc8
[   91.093899] Call Trace:
[   91.094823]  [<ffffffff8108d98d>] ? task_cputime+0x3d/0x80
[   91.096310]  [<ffffffff81066d8c>] ? do_exit+0x1dc/0xb40
[   91.097785]  [<ffffffff8106776a>] ? do_group_exit+0x3a/0x100
[   91.099291]  [<ffffffff810717fb>] ? get_signal+0x19b/0x770
[   91.100773]  [<ffffffff8100d451>] ? do_signal+0x31/0x6d0
[   91.102311]  [<ffffffff810faf95>] ? task_function_call+0x55/0x80
[   91.103978]  [<ffffffff81067282>] ? do_exit+0x6d2/0xb40
[   91.105413]  [<ffffffff810ede7c>] ? __audit_syscall_entry+0xac/0xf0
[   91.107047]  [<ffffffff8100db5c>] ? do_notify_resume+0x6c/0x90
[   91.108568]  [<ffffffff815f39c7>] ? int_signal+0x12/0x17
[   91.110069] a.out           D ffff88007c6a2240     0  9921   9917 0x00000080
[   91.111869]  ffff88007c6a2240 0000000000012f80 ffff88007b883fd8 0000000000012f80
[   91.113795]  ffff88007c6a2240 0000000000000001 ffffffff81a5ba00 0000000000000200
[   91.115708]  ffff880036d8d5a0 0000000000000000 0000000000000000 ffff88007b883cc8
[   91.117627] Call Trace:
[   91.118546]  [<ffffffff8108d98d>] ? task_cputime+0x3d/0x80
[   91.120012]  [<ffffffff81066d8c>] ? do_exit+0x1dc/0xb40
[   91.121432]  [<ffffffff8106776a>] ? do_group_exit+0x3a/0x100
[   91.122928]  [<ffffffff810717fb>] ? get_signal+0x19b/0x770
[   91.124469]  [<ffffffff8100d451>] ? do_signal+0x31/0x6d0
[   91.125915]  [<ffffffff810faf95>] ? task_function_call+0x55/0x80
[   91.127487]  [<ffffffff81067282>] ? do_exit+0x6d2/0xb40
[   91.128906]  [<ffffffff810ede7c>] ? __audit_syscall_entry+0xac/0xf0
[   91.130518]  [<ffffffff8100db5c>] ? do_notify_resume+0x6c/0x90
[   91.132053]  [<ffffffff815f39c7>] ? int_signal+0x12/0x17
[   91.133505] a.out           D ffff88007c6a3360     0  9922   9917 0x00000080
[   91.135450]  ffff88007c6a3360 0000000000012f80 ffff88007861bfd8 0000000000012f80
[   91.137395]  ffff88007c6a3360 0000000000000001 ffffffff81a5ba00 0000000000000200
[   91.139332]  ffff88007a4cbbf0 0000000000000000 0000000000000000 ffff88007861bcc8
[   91.141356] Call Trace:
[   91.142290]  [<ffffffff8108d98d>] ? task_cputime+0x3d/0x80
[   91.143781]  [<ffffffff81066d8c>] ? do_exit+0x1dc/0xb40
[   91.145212]  [<ffffffff8106776a>] ? do_group_exit+0x3a/0x100
[   91.146724]  [<ffffffff810717fb>] ? get_signal+0x19b/0x770
[   91.148204]  [<ffffffff8100d451>] ? do_signal+0x31/0x6d0
[   91.149657]  [<ffffffff810faf95>] ? task_function_call+0x55/0x80
[   91.151242]  [<ffffffff81067282>] ? do_exit+0x6d2/0xb40
[   91.152682]  [<ffffffff810ede7c>] ? __audit_syscall_entry+0xac/0xf0
[   91.154309]  [<ffffffff8100db5c>] ? do_notify_resume+0x6c/0x90
[   91.155855]  [<ffffffff815f39c7>] ? int_signal+0x12/0x17
[   91.157334] a.out           D ffff88007c6a0890     0  9923   9917 0x00000080
[   91.159214]  ffff88007c6a0890 0000000000012f80 ffff88007c62bfd8 0000000000012f80
[   91.161219]  ffff88007c6a0890 0000000000000400 ffffffff810969d2 0000000000000200
[   91.163193]  ffff88007f804a80 ffff88007fc12f80 0000000000000000 ffff88007c62bcc8
[   91.165161] Call Trace:
[   91.166115]  [<ffffffff810969d2>] ? load_balance+0x1d2/0x8a0
[   91.167678]  [<ffffffff8108d98d>] ? task_cputime+0x3d/0x80
[   91.169293]  [<ffffffff81066d8c>] ? do_exit+0x1dc/0xb40
[   91.170755]  [<ffffffff810163a5>] ? sched_clock+0x5/0x10
[   91.172208]  [<ffffffff8106776a>] ? do_group_exit+0x3a/0x100
[   91.173798]  [<ffffffff810717fb>] ? get_signal+0x19b/0x770
[   91.175282]  [<ffffffff8100d451>] ? do_signal+0x31/0x6d0
[   91.176736]  [<ffffffff81067282>] ? do_exit+0x6d2/0xb40
[   91.178167]  [<ffffffff810ede7c>] ? __audit_syscall_entry+0xac/0xf0
[   91.179789]  [<ffffffff8100db5c>] ? do_notify_resume+0x6c/0x90
[   91.181319]  [<ffffffff815f39c7>] ? int_signal+0x12/0x17
[   91.182769] a.out           D ffff88007c6a19b0     0  9924   9917 0x00000080
[   91.184597]  ffff88007c6a19b0 0000000000012f80 ffff88007bf27fd8 0000000000012f80
[   91.186552]  ffff88007c6a19b0 0000000000000001 ffffffff81a5ba00 0000000000000200
[   91.188483]  ffff880020b11120 0000000000000000 0000000000000000 ffff88007bf27cc8
[   91.190517] Call Trace:
[   91.191462]  [<ffffffff8108d98d>] ? task_cputime+0x3d/0x80
[   91.192961]  [<ffffffff81066d8c>] ? do_exit+0x1dc/0xb40
[   91.194409]  [<ffffffff8106776a>] ? do_group_exit+0x3a/0x100
[   91.195926]  [<ffffffff810717fb>] ? get_signal+0x19b/0x770
[   91.197418]  [<ffffffff8100d451>] ? do_signal+0x31/0x6d0
[   91.198884]  [<ffffffff810faf95>] ? task_function_call+0x55/0x80
[   91.200504]  [<ffffffff81067282>] ? do_exit+0x6d2/0xb40
[   91.202034]  [<ffffffff810ede7c>] ? __audit_syscall_entry+0xac/0xf0
[   91.203757]  [<ffffffff8100db5c>] ? do_notify_resume+0x6c/0x90
[   91.205293]  [<ffffffff815f39c7>] ? int_signal+0x12/0x17
[   91.206774] a.out           D ffff88007c6a2ad0     0  9925   9917 0x00000080
[   91.208641]  ffff88007c6a2ad0 0000000000012f80 ffff88007cb8bfd8 0000000000012f80
[   91.210592]  ffff88007c6a2ad0 0000000000000400 ffffffff810969d2 0000000000000200
[   91.212538]  ffff88007f804a80 ffff88007fc12f80 0000000000000000 ffff88007cb8bcc8
[   91.214486] Call Trace:
[   91.215428]  [<ffffffff810969d2>] ? load_balance+0x1d2/0x8a0
[   91.216949]  [<ffffffff8108d98d>] ? task_cputime+0x3d/0x80
[   91.218437]  [<ffffffff81066d8c>] ? do_exit+0x1dc/0xb40
[   91.219861]  [<ffffffff810163a5>] ? sched_clock+0x5/0x10
[   91.221301]  [<ffffffff8106776a>] ? do_group_exit+0x3a/0x100
[   91.222833]  [<ffffffff810717fb>] ? get_signal+0x19b/0x770
[   91.224362]  [<ffffffff8100d451>] ? do_signal+0x31/0x6d0
[   91.225860]  [<ffffffff810faf95>] ? task_function_call+0x55/0x80
[   91.227442]  [<ffffffff81067282>] ? do_exit+0x6d2/0xb40
[   91.228891]  [<ffffffff810ede7c>] ? __audit_syscall_entry+0xac/0xf0
[   91.230543]  [<ffffffff8100db5c>] ? do_notify_resume+0x6c/0x90
[   91.232107]  [<ffffffff815f39c7>] ? int_signal+0x12/0x17
[   91.233565] a.out           D ffff88007c6a4d10     0  9926   9917 0x00000080
[   91.235432]  ffff88007c6a4d10 0000000000012f80 ffff88007860bfd8 0000000000012f80
[   91.237477]  ffff88007c6a4d10 0000000000000001 ffffffff81a5ba00 0000000000000200
[   91.239430]  ffff880020b12240 0000000000000000 0000000000000000 ffff88007860bcc8
[   91.241388] Call Trace:
[   91.242322]  [<ffffffff8108d98d>] ? task_cputime+0x3d/0x80
[   91.243815]  [<ffffffff81066d8c>] ? do_exit+0x1dc/0xb40
[   91.245241]  [<ffffffff8106776a>] ? do_group_exit+0x3a/0x100
[   91.246753]  [<ffffffff810717fb>] ? get_signal+0x19b/0x770
[   91.248232]  [<ffffffff8100d451>] ? do_signal+0x31/0x6d0
[   91.249687]  [<ffffffff810faf95>] ? task_function_call+0x55/0x80
[   91.251271]  [<ffffffff81067282>] ? do_exit+0x6d2/0xb40
[   91.252709]  [<ffffffff810ede7c>] ? __audit_syscall_entry+0xac/0xf0
[   91.254334]  [<ffffffff8100db5c>] ? do_notify_resume+0x6c/0x90
[   91.255910]  [<ffffffff815f39c7>] ? int_signal+0x12/0x17
[   91.257441] a.out           D ffff88007fcd2f80     0  9927   9917 0x00000080
[   91.259308]  ffff88007c6a4480 0000000000012f80 ffff88007c67bfd8 0000000000012f80
[   91.261306]  ffff88007c6a4480 ffff88007c67bd40 ffff88007d119440 ffff88007c67bd18
[   91.263283]  000000001fe3d887 ffff88007c67bd18 ffffffff811fa4f4 ffff88007c67bcc8
[   91.265259] Call Trace:
[   91.266206]  [<ffffffff811fa4f4>] ? xfs_bmap_search_multi_extents+0x94/0x130
[   91.268011]  [<ffffffff8108d98d>] ? task_cputime+0x3d/0x80
[   91.269636]  [<ffffffff81066d8c>] ? do_exit+0x1dc/0xb40
[   91.271113]  [<ffffffff8106776a>] ? do_group_exit+0x3a/0x100
[   91.272636]  [<ffffffff810717fb>] ? get_signal+0x19b/0x770
[   91.274184]  [<ffffffff8100d451>] ? do_signal+0x31/0x6d0
[   91.275659]  [<ffffffff810faf95>] ? task_function_call+0x55/0x80
[   91.277250]  [<ffffffff81067282>] ? do_exit+0x6d2/0xb40
[   91.278699]  [<ffffffff810ede7c>] ? __audit_syscall_entry+0xac/0xf0
[   91.280342]  [<ffffffff8100db5c>] ? do_notify_resume+0x6c/0x90
[   91.281901]  [<ffffffff815f39c7>] ? int_signal+0x12/0x17
[   91.283368] abrt-hook-ccpp  D 0000000000000002     0  9928    345 0x00000080
[   91.285222]  ffff880020b10890 0000000000012f80 ffff88007c68bfd8 0000000000012f80
[   91.287200]  ffff880020b10890 ffff88007fffc000 ffffffff8111a945 0000000000000000
[   91.289187]  0000000000000000 000088007c68b9e8 ffff880020b10890 ffffffff81015df5
[   91.291215] Call Trace:
[   91.292155]  [<ffffffff8111a945>] ? shrink_zone+0x105/0x2a0
[   91.293682]  [<ffffffff81015df5>] ? read_tsc+0x5/0x10
[   91.295117]  [<ffffffff810c0270>] ? ktime_get+0x30/0x90
[   91.296574]  [<ffffffff810f73b9>] ? delayacct_end+0x39/0x70
[   91.298096]  [<ffffffff8111b0e5>] ? do_try_to_free_pages+0x3e5/0x480
[   91.299768]  [<ffffffff815f23f3>] ? schedule_timeout+0x113/0x1b0
[   91.301384]  [<ffffffff810b9800>] ? migrate_timer_list+0x60/0x60
[   91.303092]  [<ffffffff81110c9e>] ? __alloc_pages_nodemask+0x7ae/0xa60
[   91.304858]  [<ffffffff81150477>] ? alloc_pages_current+0x87/0x100
[   91.306497]  [<ffffffff8110a240>] ? filemap_fault+0x1c0/0x400
[   91.308054]  [<ffffffff8112ea66>] ? __do_fault+0x46/0xd0
[   91.309531]  [<ffffffff811313c8>] ? do_read_fault.isra.62+0x228/0x310
[   91.311204]  [<ffffffff81133aae>] ? handle_mm_fault+0x7ae/0x10e0
[   91.312800]  [<ffffffff81182762>] ? path_openat+0xa2/0x660
[   91.314298]  [<ffffffff8105194e>] ? __do_page_fault+0x17e/0x540
[   91.315884]  [<ffffffff81183c9e>] ? do_filp_open+0x3e/0xa0
[   91.317367]  [<ffffffff81051d40>] ? do_page_fault+0x30/0x70
[   91.318879]  [<ffffffff815f5138>] ? page_fault+0x28/0x30
(...snipped...)
[   93.038908] oom_scan_process_thread: 244092 callbacks suppressed
[   93.040655] OOM: Waiting for a.out(9917) : will_free_mem
----------

PID 9916 is the parent process doing read() from /dev/zero .
PID 9917 is the child process waiting at pause(). PIDs from 9918 to 9927
are the child thread of PID 9917 sharing the MM. PID 9919 is the thread
doing coredump to pipe and PID 9928 is the process doing read from pipe.

Since will_free_mem() for PID 9917 is true, oom_scan_process_thread()
does not choose a victim. PID 9917 is waiting for PID 9919 to complete
the coredump. PID 9919 is waiting for PID 9928 to read from pipe.
PID 9928 is waiting for PID 9917 to release memory.

----------
static void exit_mm(struct task_struct *tsk)
{
(...snipped...)
        if (core_state) {
                struct core_thread self;

                up_read(&mm->mmap_sem);

                self.task = tsk;
                self.next = xchg(&core_state->dumper.next, &self);
                /*
                 * Implies mb(), the result of xchg() must be visible
                 * to core_state->dumper.
                 */
                if (atomic_dec_and_test(&core_state->nr_threads))
                        complete(&core_state->startup);

                for (;;) {
                        set_task_state(tsk, TASK_UNINTERRUPTIBLE);
                        if (!self.task) /* see coredump_finish() */
                                break;
                        freezable_schedule(); /* <ffffffff81066d8c> is here. */
                }
                __set_task_state(tsk, TASK_RUNNING);
                down_read(&mm->mmap_sem);
        }
(...snipped...)
}
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
