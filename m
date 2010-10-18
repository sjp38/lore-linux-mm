Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 420805F0047
	for <linux-mm@kvack.org>; Sun, 17 Oct 2010 20:57:41 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9I0vcAj029160
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 18 Oct 2010 09:57:38 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 744AB45DE60
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 09:57:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C9EB45DE6F
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 09:57:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E29DEF8008
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 09:57:38 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AEB881DB803A
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 09:57:37 +0900 (JST)
Date: Mon, 18 Oct 2010 09:52:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v2 08/11] memcg: CPU hotplug lockdep warning fix
Message-Id: <20101018095214.967d431b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1287177279-30876-9-git-send-email-gthelen@google.com>
References: <1287177279-30876-1-git-send-email-gthelen@google.com>
	<1287177279-30876-9-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, 15 Oct 2010 14:14:36 -0700
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
