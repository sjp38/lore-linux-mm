Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D88F96B0085
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 21:00:07 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9J105vx012247
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 19 Oct 2010 10:00:05 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id CB8BC45DE5F
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 10:00:04 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 78D4245DE57
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 10:00:04 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 189D2E0800A
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 10:00:04 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E612E0800B
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 10:00:03 +0900 (JST)
Date: Tue, 19 Oct 2010 09:54:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 08/11] memcg: CPU hotplug lockdep warning fix
Message-Id: <20101019095436.648a8aba.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1287448784-25684-9-git-send-email-gthelen@google.com>
References: <1287448784-25684-1-git-send-email-gthelen@google.com>
	<1287448784-25684-9-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Mon, 18 Oct 2010 17:39:41 -0700
Greg Thelen <gthelen@google.com> wrote:

> From: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> memcg has lockdep warnings (sleep inside rcu lock)
> 
> From: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> Recent move to get_online_cpus() ends up calling get_online_cpus() from
> mem_cgroup_read_stat(). However mem_cgroup_read_stat() is called under rcu
> lock. get_online_cpus() can sleep. The dirty limit patches expose
> this BUG more readily due to their usage of mem_cgroup_page_stat()
> 
> This patch address this issue as identified by lockdep and moves the
> hotplug protection to a higher layer. This might increase the time
> required to hotplug, but not by much.
> 
> Warning messages
> 
> BUG: sleeping function called from invalid context at kernel/cpu.c:62
> in_atomic(): 0, irqs_disabled(): 0, pid: 6325, name: pagetest
> 2 locks held by pagetest/6325:
> do_page_fault+0x27d/0x4a0
> mem_cgroup_page_stat+0x0/0x23f
> Pid: 6325, comm: pagetest Not tainted 2.6.36-rc5-mm1+ #201
> Call Trace:
> [<ffffffff81041224>] __might_sleep+0x12d/0x131
> [<ffffffff8104f4af>] get_online_cpus+0x1c/0x51
> [<ffffffff8110eedb>] mem_cgroup_read_stat+0x27/0xa3
> [<ffffffff811125d2>] mem_cgroup_page_stat+0x131/0x23f
> [<ffffffff811124a1>] ? mem_cgroup_page_stat+0x0/0x23f
> [<ffffffff810d57c3>] global_dirty_limits+0x42/0xf8
> [<ffffffff810d58b3>] throttle_vm_writeout+0x3a/0xb4
> [<ffffffff810dc2f8>] shrink_zone+0x3e6/0x3f8
> [<ffffffff81074a35>] ? ktime_get_ts+0xb2/0xbf
> [<ffffffff810dd1aa>] do_try_to_free_pages+0x106/0x478
> [<ffffffff810dd601>] try_to_free_mem_cgroup_pages+0xe5/0x14c
> [<ffffffff8110f947>] mem_cgroup_hierarchical_reclaim+0x314/0x3a2
> [<ffffffff81111b31>] __mem_cgroup_try_charge+0x29b/0x593
> [<ffffffff8111194a>] ? __mem_cgroup_try_charge+0xb4/0x593
> [<ffffffff81071258>] ? local_clock+0x40/0x59
> [<ffffffff81009015>] ? sched_clock+0x9/0xd
> [<ffffffff810710d5>] ? sched_clock_local+0x1c/0x82
> [<ffffffff8111398a>] mem_cgroup_charge_common+0x4b/0x76
> [<ffffffff81141469>] ? bio_add_page+0x36/0x38
> [<ffffffff81113ba9>] mem_cgroup_cache_charge+0x1f4/0x214
> [<ffffffff810cd195>] add_to_page_cache_locked+0x4a/0x148
> ....
> 
> Acked-by: Greg Thelen <gthelen@google.com>
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
