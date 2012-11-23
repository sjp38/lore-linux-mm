Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 492A16B0087
	for <linux-mm@kvack.org>; Fri, 23 Nov 2012 05:04:44 -0500 (EST)
Received: by mail-vb0-f41.google.com with SMTP id v13so11399536vbk.14
        for <linux-mm@kvack.org>; Fri, 23 Nov 2012 02:04:43 -0800 (PST)
Date: Fri, 23 Nov 2012 11:04:38 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: memory-cgroup bug
Message-ID: <20121123100438.GF24698@dhcp22.suse.cz>
References: <20121121200207.01068046@pobox.sk>
 <20121122152441.GA9609@dhcp22.suse.cz>
 <20121122190526.390C7A28@pobox.sk>
 <20121122214249.GA20319@dhcp22.suse.cz>
 <20121122233434.3D5E35E6@pobox.sk>
 <20121123074023.GA24698@dhcp22.suse.cz>
 <20121123102137.10D6D653@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121123102137.10D6D653@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>

On Fri 23-11-12 10:21:37, azurIt wrote:
[...]
> It, luckily, happend again so i have more info.
> 
>  - there wasn't any logs in kernel from OOM for that cgroup
>  - there were 16 processes in cgroup
>  - processes in cgroup were taking togather 100% of CPU (it
>    was allowed to use only one core, so 100% of that core)
>  - memory.failcnt was groving fast
>  - oom_control:
> oom_kill_disable 0
> under_oom 0 (this was looping from 0 to 1)

So there was an OOM going on but no messages in the log? Really strange.
Kame already asked about oom_score_adj of the processes in the group but
it didn't look like all the processes would have oom disabled, right?

>  - limit_in_bytes was set to 157286400
>  - content of stat (as you can see, the whole memory limit was used):
> cache 0
> rss 0

This looks like a top-level group for your user.

> mapped_file 0
> pgpgin 0
> pgpgout 0
> swap 0
> pgfault 0
> pgmajfault 0
> inactive_anon 0
> active_anon 0
> inactive_file 0
> active_file 0
> unevictable 0
> hierarchical_memory_limit 157286400
> hierarchical_memsw_limit 157286400
> total_cache 0
> total_rss 157286400

OK, so all the memory is anonymous and you have no swap so the oom is
the only thing to do.

> total_mapped_file 0
> total_pgpgin 10326454
> total_pgpgout 10288054
> total_swap 0
> total_pgfault 12939677
> total_pgmajfault 4283
> total_inactive_anon 0
> total_active_anon 157286400
> total_inactive_file 0
> total_active_file 0
> total_unevictable 0
> 
> 
> i also grabber oom_adj, oom_score_adj and stack of all processes, here
> it is:
> http://www.watchdog.sk/lkml/memcg-bug.tar

Hmm, all processes waiting for oom are stuck at the very same place:
$ grep mem_cgroup_handle_oom -r [0-9]*
30858/stack:[<ffffffff8110a9c1>] mem_cgroup_handle_oom+0x241/0x3b0
30859/stack:[<ffffffff8110a9c1>] mem_cgroup_handle_oom+0x241/0x3b0
30860/stack:[<ffffffff8110a9c1>] mem_cgroup_handle_oom+0x241/0x3b0
30892/stack:[<ffffffff8110a9c1>] mem_cgroup_handle_oom+0x241/0x3b0
30898/stack:[<ffffffff8110a9c1>] mem_cgroup_handle_oom+0x241/0x3b0
31588/stack:[<ffffffff8110a9c1>] mem_cgroup_handle_oom+0x241/0x3b0
32044/stack:[<ffffffff8110a9c1>] mem_cgroup_handle_oom+0x241/0x3b0
32358/stack:[<ffffffff8110a9c1>] mem_cgroup_handle_oom+0x241/0x3b0
6031/stack:[<ffffffff8110a9c1>] mem_cgroup_handle_oom+0x241/0x3b0
6534/stack:[<ffffffff8110a9c1>] mem_cgroup_handle_oom+0x241/0x3b0
7020/stack:[<ffffffff8110a9c1>] mem_cgroup_handle_oom+0x241/0x3b0

We are taking memcg_oom_lock spinlock twice in that function + we can
schedule. As none of the tasks is scheduled this would suggest that you
are blocked at the first lock. But who got the lock then?
This is really strange.
Btw. is sysrq+t resp. sysrq+w showing the same traces as
/proc/<pid>/stat?
 
> Notice that stack is different for few processes.

Yes others are in VFS resp ext3. ext3_write_begin looks a bit dangerous
but it grabs the page before it really starts a transaction.

> Stack for all processes were NOT chaging and was still the same.

Could you take few snapshots over time?

> Btw, don't know if it matters but i was several cgroup subsystems
> mounted and i'm also using them (i was not activating freezer in this
> case, don't know if it can be active automatically by kernel or what,

No

> didn't checked if cgroup was freezed but i suppose it wasn't):
> none            /cgroups        cgroup  defaults,cpuacct,cpuset,memory,freezer,task,blkio 0 0

Do you see the same issue if only memory controller was mounted (resp.
cpuset which you seem to use as well from your description).

I know you said booting into a vanilla kernel would be problematic but
could you at least rule out te cgroup patches that you have mentioned?
If you need to move a task to a group based by an uid you can use
cgrules daemon (libcgroup1 package) for that as well.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
