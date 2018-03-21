Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 91FAC6B0022
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 19:24:50 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p9so3447391pfk.5
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 16:24:50 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y19si3423193pgv.139.2018.03.21.16.24.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 16:24:49 -0700 (PDT)
Date: Wed, 21 Mar 2018 16:24:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/vmstat.c: Fix vmstat_update() preemption BUG.
Message-Id: <20180321162447.ad8990ecb547f0e016d7cd12@linux-foundation.org>
In-Reply-To: <1520881552-25659-1-git-send-email-steven.hill@cavium.com>
References: <1520881552-25659-1-git-send-email-steven.hill@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Steven J. Hill" <steven.hill@cavium.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>

On Mon, 12 Mar 2018 14:05:52 -0500 "Steven J. Hill" <steven.hill@cavium.com> wrote:

> Attempting to hotplug CPUs with CONFIG_VM_EVENT_COUNTERS enabled
> can cause vmstat_update() to report a BUG due to preemption not
> being disabled around smp_processor_id(). Discovered on Ubiquiti
> EdgeRouter Pro with Cavium Octeon II processor.
> 
> BUG: using smp_processor_id() in preemptible [00000000] code:
> kworker/1:1/269
> caller is vmstat_update+0x50/0xa0
> CPU: 0 PID: 269 Comm: kworker/1:1 Not tainted
> 4.16.0-rc4-Cavium-Octeon-00009-gf83bbd5-dirty #1
> Workqueue: mm_percpu_wq vmstat_update
> Stack : 0000002600000026 0000000010009ce0 0000000000000000 0000000000000001
>         0000000000000000 0000000000000000 0000000000000005 8001180000000800
>         00000000000000bf 0000000000000000 00000000000000bf 766d737461745f75
>         ffffffff83ad0000 0000000000000007 0000000000000000 0000000008000000
>         0000000000000000 ffffffff818d0000 0000000000000001 ffffffff81818a70
>         0000000000000000 0000000000000000 ffffffff8115bbb0 ffffffff818a0000
>         0000000000000005 ffffffff8144dc50 0000000000000000 0000000000000000
>         8000000088980000 8000000088983b30 0000000000000088 ffffffff813d3054
>         0000000000000000 ffffffff83ace622 00000000000000be 0000000000000000
>         00000000000000be ffffffff81121fb4 0000000000000000 0000000000000000
>         ...
> Call Trace:
> [<ffffffff81121fb4>] show_stack+0x94/0x128
> [<ffffffff813d3054>] dump_stack+0xa4/0xe0
> [<ffffffff813fcfb8>] check_preemption_disabled+0x118/0x120
> [<ffffffff811eafd8>] vmstat_update+0x50/0xa0
> [<ffffffff8115b954>] process_one_work+0x144/0x348
> [<ffffffff8115bd00>] worker_thread+0x150/0x4b8
> [<ffffffff811622a0>] kthread+0x110/0x140
> [<ffffffff8111c304>] ret_from_kernel_thread+0x14/0x1c
> 
> ...
>
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1839,9 +1839,11 @@ static void vmstat_update(struct work_struct *w)
>  		 * to occur in the future. Keep on running the
>  		 * update worker thread.
>  		 */
> +		preempt_disable();
>  		queue_delayed_work_on(smp_processor_id(), mm_percpu_wq,
>  				this_cpu_ptr(&vmstat_work),
>  				round_jiffies_relative(sysctl_stat_interval));
> +		preempt_enable();
>  	}
>  }

hm, I suspect this warning is a false-positive.  vmstat_update() is
called from a workqueue and so vmstat_update()'s execution is pinned to
a particular CPU, so smp_processor_id()'s return will not be
invalidated by a preemption-induced CPU switch.  Unless the workqueue
code changed more than I think it did ;)

The patch is OK and will work, but I wonder if a better fix is to use
raw_smp_processor_id() and to add a little comment explaining why it's
needed and is safe.
