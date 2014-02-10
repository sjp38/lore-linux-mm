Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 76F8B6B0031
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 08:52:15 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id cc10so2820616wib.16
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 05:52:14 -0800 (PST)
Received: from mail-wi0-x229.google.com (mail-wi0-x229.google.com [2a00:1450:400c:c05::229])
        by mx.google.com with ESMTPS id hx3si7675976wjb.6.2014.02.10.05.52.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 10 Feb 2014 05:52:14 -0800 (PST)
Received: by mail-wi0-f169.google.com with SMTP id e4so2732628wiv.4
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 05:52:13 -0800 (PST)
Date: Mon, 10 Feb 2014 14:52:11 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: mm: memcg: A infinite loop in __handle_mm_fault()
Message-ID: <20140210135211.GF7117@dhcp22.suse.cz>
References: <52F81C5D.6010601@jp.fujitsu.com>
 <20140210111928.GA7117@dhcp22.suse.cz>
 <20140210125655.4AB48E0090@blue.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140210125655.4AB48E0090@blue.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "Mizuma, Masayoshi" <m.mizuma@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Mon 10-02-14 14:56:55, Kirill A. Shutemov wrote:
[...]
> BTW, Michal, I've triggered sleep-in-atomic bug in
> mem_cgroup_print_oom_info():

Ouch, I am wondering why I haven't triggered that while testing the
patch.

# CONFIG_DEBUG_ATOMIC_SLEEP is not set
explains why might_sleep didn't warn.

Anyway, fix posted in a separate mail. Thanks for reporting.
 
> [    2.386563] Task in /test killed as a result of limit of /test
> [    2.387326] memory: usage 10240kB, limit 10240kB, failcnt 51
> [    2.388098] memory+swap: usage 10240kB, limit 10240kB, failcnt 0
> [    2.388861] kmem: usage 0kB, limit 18014398509481983kB, failcnt 0
> [    2.389640] Memory cgroup stats for /test:
> [    2.390178] BUG: sleeping function called from invalid context at /home/space/kas/git/public/linux/kernel/cpu.c:68
> [    2.391516] in_atomic(): 1, irqs_disabled(): 0, pid: 66, name: memcg_test
> [    2.392416] 2 locks held by memcg_test/66:
> [    2.392945]  #0:  (memcg_oom_lock#2){+.+...}, at: [<ffffffff81131014>] pagefault_out_of_memory+0x14/0x90
> [    2.394233]  #1:  (oom_info_lock){+.+...}, at: [<ffffffff81197b2a>] mem_cgroup_print_oom_info+0x2a/0x390
> [    2.395496] CPU: 2 PID: 66 Comm: memcg_test Not tainted 3.14.0-rc1-dirty #745
> [    2.396536] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS Bochs 01/01/2011
> [    2.397540]  ffffffff81a3cc90 ffff88081d26dba0 ffffffff81776ea3 0000000000000000
> [    2.398541]  ffff88081d26dbc8 ffffffff8108418a 0000000000000000 ffff88081d15c000
> [    2.399533]  0000000000000000 ffff88081d26dbd8 ffffffff8104f6bc ffff88081d26dc10
> [    2.400588] Call Trace:
> [    2.400908]  [<ffffffff81776ea3>] dump_stack+0x4d/0x66
> [    2.401578]  [<ffffffff8108418a>] __might_sleep+0x16a/0x210
> [    2.402295]  [<ffffffff8104f6bc>] get_online_cpus+0x1c/0x60
> [    2.403005]  [<ffffffff8118fb67>] mem_cgroup_read_stat+0x27/0xb0
> [    2.403769]  [<ffffffff81197d60>] mem_cgroup_print_oom_info+0x260/0x390
> [    2.404653]  [<ffffffff8177314e>] dump_header+0x88/0x251
> [    2.405342]  [<ffffffff810a3bfd>] ? trace_hardirqs_on+0xd/0x10
> [    2.406098]  [<ffffffff81130618>] oom_kill_process+0x258/0x3d0
> [    2.406833]  [<ffffffff81198746>] mem_cgroup_oom_synchronize+0x656/0x6c0
> [    2.407674]  [<ffffffff811973a0>] ? mem_cgroup_charge_common+0xd0/0xd0
> [    2.408553]  [<ffffffff81131014>] pagefault_out_of_memory+0x14/0x90
> [    2.409354]  [<ffffffff817712f7>] mm_fault_error+0x91/0x189
> [    2.410069]  [<ffffffff81783eae>] __do_page_fault+0x48e/0x580
> [    2.410791]  [<ffffffff8108f656>] ? local_clock+0x16/0x30
> [    2.411467]  [<ffffffff810a3bfd>] ? trace_hardirqs_on+0xd/0x10
> [    2.412248]  [<ffffffff8177f6fc>] ? _raw_spin_unlock_irq+0x2c/0x40
> [    2.413039]  [<ffffffff8108312b>] ? finish_task_switch+0x7b/0x100
> [    2.413821]  [<ffffffff813b954a>] ? trace_hardirqs_off_thunk+0x3a/0x3c
> [    2.414652]  [<ffffffff81783fae>] do_page_fault+0xe/0x10
> [    2.415330]  [<ffffffff81780552>] page_fault+0x22/0x30
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
