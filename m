Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id CE4996B03A2
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 04:09:14 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id h186so6340756ith.10
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 01:09:14 -0700 (PDT)
Received: from mail-it0-x242.google.com (mail-it0-x242.google.com. [2607:f8b0:4001:c0b::242])
        by mx.google.com with ESMTPS id x3si2002403iof.149.2017.04.19.01.09.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 01:09:13 -0700 (PDT)
Received: by mail-it0-x242.google.com with SMTP id 193so1599797itm.1
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 01:09:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170419075712.GB29789@dhcp22.suse.cz>
References: <201704190541.v3J5fUE3054131@www262.sakura.ne.jp>
 <20170419071039.GB28263@dhcp22.suse.cz> <201704190726.v3J7QAiC076509@www262.sakura.ne.jp>
 <20170419075712.GB29789@dhcp22.suse.cz>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 19 Apr 2017 10:09:12 +0200
Message-ID: <CAMuHMdVmJrr6_sGeU4oxH5fn10BRdLC5nOEePN05p3kJ1x3YBQ@mail.gmail.com>
Subject: Re: Re: Re: "mm: move pcp and lru-pcp draining into single wq" broke
 resume from s2ram
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux PM list <linux-pm@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Linux-Renesas <linux-renesas-soc@vger.kernel.org>, Tejun Heo <tj@kernel.org>

Hi Michal, Tetsuo,

On Wed, Apr 19, 2017 at 9:57 AM, Michal Hocko <mhocko@kernel.org> wrote:
> From f3c6e287042259d6ae9916f1ff66392c46ce2a3c Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Wed, 19 Apr 2017 09:52:46 +0200
> Subject: [PATCH] mm: make mm_percpu_wq non freezable
>
> Geert has reported a freeze during PM resume and some additional
> debugging has shown that the device_resume worker cannot make a forward
> progress because it waits for an event which is stuck waiting in
> drain_all_pages:
> [  243.691979] INFO: task kworker/u4:0:5 blocked for more than 120 seconds.
> [  243.698684]       Not tainted 4.11.0-rc7-koelsch-00029-g005882e53d62f25d-dirty #3476
> [  243.706439] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [  243.714276] kworker/u4:0    D    0     5      2 0x00000000
> [  243.719780] Workqueue: events_unbound async_run_entry_fn
> [  243.725118] [<c0700c20>] (__schedule) from [<c0700f44>] (schedule+0xb0/0xcc)
> [  243.732181] [<c0700f44>] (schedule) from [<c0705108>] (schedule_timeout+0x18/0x1f4)
> [  243.739840] [<c0705108>] (schedule_timeout) from [<c07019c0>] (wait_for_common+0x100/0x19c)
> [  243.748207] [<c07019c0>] (wait_for_common) from [<c04d2008>] (dpm_wait_for_superior+0x14/0x5c)
> [  243.756836] [<c04d2008>] (dpm_wait_for_superior) from [<c04d2624>] (device_resume+0x40/0x1a0)
> [  243.765380] [<c04d2624>] (device_resume) from [<c04d279c>] (async_resume+0x18/0x44)
> [  243.773055] [<c04d279c>] (async_resume) from [<c023db24>] (async_run_entry_fn+0x44/0x114)
> [  243.781245] [<c023db24>] (async_run_entry_fn) from [<c0236534>] (process_one_work+0x1cc/0x31c)
> [  243.789876] [<c0236534>] (process_one_work) from [<c0236c90>] (worker_thread+0x2b8/0x3f0)
> [  243.798080] [<c0236c90>] (worker_thread) from [<c023b230>] (kthread+0x120/0x140)
> [  243.805500] [<c023b230>] (kthread) from [<c0206d68>] (ret_from_fork+0x14/0x2c)
> [...]
> [  249.441198] bash            D    0  1703   1694 0x00000000
> [  249.446702] [<c0700c20>] (__schedule) from [<c0700f44>] (schedule+0xb0/0xcc)
> [  249.453764] [<c0700f44>] (schedule) from [<c0705108>] (schedule_timeout+0x18/0x1f4)
> [  249.461427] [<c0705108>] (schedule_timeout) from [<c07019c0>] (wait_for_common+0x100/0x19c)
> [  249.469797] [<c07019c0>] (wait_for_common) from [<c0234e44>] (flush_work+0x128/0x158)
> [  249.477650] [<c0234e44>] (flush_work) from [<c02ab488>] (drain_all_pages+0x198/0x1f0)
> [  249.485503] [<c02ab488>] (drain_all_pages) from [<c02e1a1c>] (start_isolate_page_range+0xd8/0x1ac)
> [  249.494484] [<c02e1a1c>] (start_isolate_page_range) from [<c02ae464>] (alloc_contig_range+0xc4/0x304)
> [  249.503724] [<c02ae464>] (alloc_contig_range) from [<c02e1e78>] (cma_alloc+0x134/0x1bc)
> [  249.511739] [<c02e1e78>] (cma_alloc) from [<c021308c>] (__alloc_from_contiguous+0x30/0xa0)
> [  249.520023] [<c021308c>] (__alloc_from_contiguous) from [<c021313c>] (cma_allocator_alloc+0x40/0x48)
> [  249.529173] [<c021313c>] (cma_allocator_alloc) from [<c0213318>] (__dma_alloc+0x1d4/0x2e8)
> [  249.537455] [<c0213318>] (__dma_alloc) from [<c02134a8>] (arm_dma_alloc+0x40/0x4c)
> [  249.545047] [<c02134a8>] (arm_dma_alloc) from [<c0534548>] (sh_eth_ring_init+0xec/0x1b8)
> [  249.553160] [<c0534548>] (sh_eth_ring_init) from [<c0536df0>] (sh_eth_open+0x88/0x1e0)
> [  249.561086] [<c0536df0>] (sh_eth_open) from [<c0536fc4>] (sh_eth_resume+0x7c/0xc0)
> [  249.568678] [<c0536fc4>] (sh_eth_resume) from [<c04d2240>] (dpm_run_callback+0x48/0xc8)
> [  249.576702] [<c04d2240>] (dpm_run_callback) from [<c04d2740>] (device_resume+0x15c/0x1a0)
> [  249.584898] [<c04d2740>] (device_resume) from [<c04d3644>] (dpm_resume+0xe4/0x244)
> [  249.592485] [<c04d3644>] (dpm_resume) from [<c04d3968>] (dpm_resume_end+0xc/0x18)
> [  249.599977] [<c04d3968>] (dpm_resume_end) from [<c0261010>] (suspend_devices_and_enter+0x3c8/0x490)
> [  249.609042] [<c0261010>] (suspend_devices_and_enter) from [<c0261300>] (pm_suspend+0x228/0x280)
> [  249.617759] [<c0261300>] (pm_suspend) from [<c025fecc>] (state_store+0xac/0xcc)
> [  249.625089] [<c025fecc>] (state_store) from [<c0343b04>] (kernfs_fop_write+0x164/0x1a0)
> [  249.633116] [<c0343b04>] (kernfs_fop_write) from [<c02e5838>] (__vfs_write+0x20/0x108)
> [  249.641043] [<c02e5838>] (__vfs_write) from [<c02e6c08>] (vfs_write+0xb8/0x144)
> [  249.648373] [<c02e6c08>] (vfs_write) from [<c02e788c>] (SyS_write+0x40/0x80)
> [  249.655437] [<c02e788c>] (SyS_write) from [<c0206cc0>] (ret_fast_syscall+0x0/0x34)
> [...]
> [  254.753928] Showing busy workqueues and worker pools:
> [...]
> [  254.854225] workqueue mm_percpu_wq: flags=0xc
> [  254.858583]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=0/0
> [  254.864428]     delayed: drain_local_pages_wq, vmstat_update
> [  254.870111]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=0/0
> [  254.875957]     delayed: drain_local_pages_wq BAR(1703), vmstat_update
>
> Tetsuo has properly noted that mm_percpu_wq is created as WQ_FREEZABLE
> so it is frozen this early during resume so we are effectively deadlocked.
> Fix this by dropping WQ_FREEZABLE when creating mm_percpu_wq. We really want to
> have it operational all the time.
>
> Fixes: ce612879ddc7 ("mm: move pcp and lru-pcp draining into single wq")
> Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Debugged-by: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Tested-by: Geert Uytterhoeven <geert+renesas@glider.be>

Thanks a lot to both of you!

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
