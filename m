Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8FB2C8D0039
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 03:34:39 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id A00FC3EE0BD
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 17:34:36 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 85EC845DE5A
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 17:34:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B69B45DE53
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 17:34:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D9A9E38006
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 17:34:36 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 20011E08001
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 17:34:36 +0900 (JST)
Date: Fri, 4 Mar 2011 17:28:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Bugme-new] [Bug 30432] New: rmdir on cgroup can cause hang
 tasks
Message-Id: <20110304172815.9d9e3672.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110304000355.4f68bab1.akpm@linux-foundation.org>
References: <bug-30432-10286@https.bugzilla.kernel.org/>
	<20110304000355.4f68bab1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: containers@lists.osdl.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Daniel Poelzleithner <poelzi@poelzi.org>

On Fri, 4 Mar 2011 00:03:55 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> > [ 5066.149853] Call Trace:
> > [ 5066.149853]  [<ffffffff8158e4d5>] schedule_timeout+0x215/0x2f0
> > [ 5066.149853]  [<ffffffff8104e4fd>] ? task_rq_lock+0x5d/0xa0
> > [ 5066.149853]  [<ffffffff81059c93>] ? try_to_wake_up+0xc3/0x410
> > [ 5066.149853]  [<ffffffff8158e0cb>] wait_for_common+0xdb/0x180
> > [ 5066.149853]  [<ffffffff81059fe0>] ? default_wake_function+0x0/0x20
> > [ 5066.244366]  [<ffffffff8158e24d>] wait_for_completion+0x1d/0x20
> > [ 5066.244366]  [<ffffffff810d44f5>] synchronize_sched+0x55/0x60
> > [ 5066.244366]  [<ffffffff81080b00>] ? wakeme_after_rcu+0x0/0x20
> > [ 5066.244366]  [<ffffffff811526a3>] mem_cgroup_start_move+0x93/0xa0
> > [ 5066.244366]  [<ffffffff8115739b>] mem_cgroup_force_empty+0xdb/0x640
> > [ 5066.244366]  [<ffffffff81157914>] mem_cgroup_pre_destroy+0x14/0x20
> > [ 5066.244366]  [<ffffffff810ae681>] cgroup_rmdir+0xc1/0x560
> > [ 5066.244366]  [<ffffffff81083d70>] ? autoremove_wake_function+0x0/0x40
> > [ 5066.244366]  [<ffffffff81167cc4>] vfs_rmdir+0xb4/0x110
> > [ 5066.244366]  [<ffffffff81169d13>] do_rmdir+0x133/0x140
> > [ 5066.244366]  [<ffffffff810d3c85>] ? call_rcu_sched+0x15/0x20
> > [ 5066.244366]  [<ffffffff810bf6ff>] ? audit_syscall_entry+0x1df/0x280
> > [ 5066.244366]  [<ffffffff81169d76>] sys_rmdir+0x16/0x20
> > [ 5066.244366]  [<ffffffff8100c042>] system_call_fastpath+0x16/0x1b
> 

This seems....
==
static void mem_cgroup_start_move(struct mem_cgroup *mem)
{
.....
	put_online_cpus();

        synchronize_rcu();   <---------(*)
}
==

Waiting on above synchronize_rcu().

Hmm...
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
