Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 57F348D0039
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 03:04:59 -0500 (EST)
Date: Fri, 4 Mar 2011 00:03:55 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 30432] New: rmdir on cgroup can cause hang
 tasks
Message-Id: <20110304000355.4f68bab1.akpm@linux-foundation.org>
In-Reply-To: <bug-30432-10286@https.bugzilla.kernel.org/>
References: <bug-30432-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: containers@lists.osdl.org
Cc: bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Menage <menage@google.com>, Daniel Poelzleithner <poelzi@poelzi.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 4 Mar 2011 04:27:26 GMT bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=30432
> 
>            Summary: rmdir on cgroup can cause hang tasks
>            Product: Process Management
>            Version: 2.5
>     Kernel Version: 2.6.37
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Other
>         AssignedTo: process_other@kernel-bugs.osdl.org
>         ReportedBy: bugzilla.kernel.org@poelzi.org
>         Regression: No
> 
> 
> I just got following hang when removing an empty cgroup. I had still a shell in
> the cgroup that got emptied and removed. The shell as well as the release_agent
> and the program managing the cgroup hangs.
> 
> The directory structure looks like:
> /sys/fs/cgroup/memory/usr_1000/psn_3234
> 
> ls on /sys/fs/cgroup/memory but ls on /sys/fs/cgroup/memory/usr_1000 hangs.
> 
> 
> [ 5065.280666] SysRq : Changing Loglevel
> [ 5065.282574] Loglevel set to 5
> [ 5066.139879] SysRq : Show Blocked State
> [ 5066.141848]   task                        PC stack   pid father
> [ 5066.141925] zsh           D ffff880071520398     0  8719   3589 0x00000084
> [ 5066.141937]  ffff880002059bd8 0000000000000086 ffff880002059bb8
> ffffffff00000000
> [ 5066.143971]  00000000000139c0 ffff880071520000 ffff880071520398
> ffff880002059fd8
> [ 5066.146049]  ffff8800715203a0 00000000000139c0 ffff880002058010
> 00000000000139c0
> [ 5066.148183] Call Trace:
> [ 5066.149853]  [<ffffffff8158ec97>] __mutex_lock_slowpath+0xf7/0x180
> [ 5066.149853]  [<ffffffff812d74a6>] ? vsnprintf+0x416/0x5a0
> [ 5066.149853]  [<ffffffff8158eb7b>] mutex_lock+0x2b/0x50
> [ 5066.149853]  [<ffffffff81168252>] do_lookup+0x102/0x180
> [ 5066.149853]  [<ffffffff81168dfd>] link_path_walk+0x4dd/0x9e0
> [ 5066.149853]  [<ffffffff81169417>] path_walk+0x67/0xe0
> [ 5066.149853]  [<ffffffff811695eb>] do_path_lookup+0x5b/0xa0
> [ 5066.149853]  [<ffffffff8116a2f7>] user_path_at+0x57/0xa0
> [ 5066.149853]  [<ffffffff815940e0>] ? do_page_fault+0x1f0/0x4f0
> [ 5066.149853]  [<ffffffff81075e6c>] ? kill_pid_info+0x2c/0x60
> [ 5066.149853]  [<ffffffff811604fc>] vfs_fstatat+0x3c/0x80
> [ 5066.149853]  [<ffffffff8116061b>] vfs_stat+0x1b/0x20
> [ 5066.149853]  [<ffffffff81160644>] sys_newstat+0x24/0x50
> [ 5066.149853]  [<ffffffff810bf6ff>] ? audit_syscall_entry+0x1df/0x280
> [ 5066.149853]  [<ffffffff8100c042>] system_call_fastpath+0x16/0x1b
> [ 5066.149853] ulatencyd     D ffff88007a0bc7d8     0  9004   4809 0x00000084
> [ 5066.149853]  ffff880070b55cd8 0000000000000082 0000000000000082
> ffff88002c9d16c0
> [ 5066.149853]  00000000000139c0 ffff88007a0bc440 ffff88007a0bc7d8
> ffff880070b55fd8
> [ 5066.149853]  ffff88007a0bc7e0 00000000000139c0 ffff880070b54010
> 00000000000139c0
> [ 5066.149853] Call Trace:
> [ 5066.149853]  [<ffffffff8158ec97>] __mutex_lock_slowpath+0xf7/0x180
> [ 5066.149853]  [<ffffffff81166124>] ? exec_permission+0x44/0x90
> [ 5066.149853]  [<ffffffff8158eb7b>] mutex_lock+0x2b/0x50
> [ 5066.149853]  [<ffffffff81168418>] do_last+0x148/0x650
> [ 5066.149853]  [<ffffffff8116a6d5>] do_filp_open+0x205/0x5f0
> [ 5066.149853]  [<ffffffff81167281>] ? path_put+0x31/0x40
> [ 5066.149853]  [<ffffffff8117593a>] ? alloc_fd+0x10a/0x150
> [ 5066.149853]  [<ffffffff81159bb9>] do_sys_open+0x69/0x110
> [ 5066.149853]  [<ffffffff81159ca0>] sys_open+0x20/0x30
> [ 5066.149853]  [<ffffffff8100c042>] system_call_fastpath+0x16/0x1b
> [ 5066.149853] lua           D ffff88002c91b118     0  9487      1 0x00000080
> [ 5066.149853]  ffff880078f6db08 0000000000000086 ffff88002c91b118
> ffff880000000000
> [ 5066.149853]  00000000000139c0 ffff88002c91ad80 ffff88002c91b118
> ffff880078f6dfd8
> [ 5066.149853]  ffff88002c91b120 00000000000139c0 ffff880078f6c010
> 00000000000139c0
> [ 5066.149853] Call Trace:
> [ 5066.149853]  [<ffffffff8158e4d5>] schedule_timeout+0x215/0x2f0
> [ 5066.149853]  [<ffffffff8104e4fd>] ? task_rq_lock+0x5d/0xa0
> [ 5066.149853]  [<ffffffff81059c93>] ? try_to_wake_up+0xc3/0x410
> [ 5066.149853]  [<ffffffff8158e0cb>] wait_for_common+0xdb/0x180
> [ 5066.149853]  [<ffffffff81059fe0>] ? default_wake_function+0x0/0x20
> [ 5066.244366]  [<ffffffff8158e24d>] wait_for_completion+0x1d/0x20
> [ 5066.244366]  [<ffffffff810d44f5>] synchronize_sched+0x55/0x60
> [ 5066.244366]  [<ffffffff81080b00>] ? wakeme_after_rcu+0x0/0x20
> [ 5066.244366]  [<ffffffff811526a3>] mem_cgroup_start_move+0x93/0xa0
> [ 5066.244366]  [<ffffffff8115739b>] mem_cgroup_force_empty+0xdb/0x640
> [ 5066.244366]  [<ffffffff81157914>] mem_cgroup_pre_destroy+0x14/0x20
> [ 5066.244366]  [<ffffffff810ae681>] cgroup_rmdir+0xc1/0x560
> [ 5066.244366]  [<ffffffff81083d70>] ? autoremove_wake_function+0x0/0x40
> [ 5066.244366]  [<ffffffff81167cc4>] vfs_rmdir+0xb4/0x110
> [ 5066.244366]  [<ffffffff81169d13>] do_rmdir+0x133/0x140
> [ 5066.244366]  [<ffffffff810d3c85>] ? call_rcu_sched+0x15/0x20
> [ 5066.244366]  [<ffffffff810bf6ff>] ? audit_syscall_entry+0x1df/0x280
> [ 5066.244366]  [<ffffffff81169d76>] sys_rmdir+0x16/0x20
> [ 5066.244366]  [<ffffffff8100c042>] system_call_fastpath+0x16/0x1b

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
