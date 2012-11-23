Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 14CCA6B005D
	for <linux-mm@kvack.org>; Fri, 23 Nov 2012 09:59:07 -0500 (EST)
Subject: =?utf-8?q?Re=3A_memory=2Dcgroup_bug?=
Date: Fri, 23 Nov 2012 15:59:04 +0100
From: "azurIt" <azurit@pobox.sk>
References: <20121121200207.01068046@pobox.sk>, <20121122152441.GA9609@dhcp22.suse.cz>, <20121122190526.390C7A28@pobox.sk>, <20121122214249.GA20319@dhcp22.suse.cz>, <20121122233434.3D5E35E6@pobox.sk>, <20121123074023.GA24698@dhcp22.suse.cz>, <20121123102137.10D6D653@pobox.sk> <20121123100438.GF24698@dhcp22.suse.cz>
In-Reply-To: <20121123100438.GF24698@dhcp22.suse.cz>
MIME-Version: 1.0
Message-Id: <20121123155904.490039C5@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Michal_Hocko?= <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, =?utf-8?q?cgroups_mailinglist?= <cgroups@vger.kernel.org>

>If you could instrument mem_cgroup_handle_oom with some printks (before
>we take the memcg_oom_lock, before we schedule and into
>mem_cgroup_out_of_memory)


If you send me patch i can do it. I'm, unfortunately, not able to code it.



>> It, luckily, happend again so i have more info.
>> 
>>  - there wasn't any logs in kernel from OOM for that cgroup
>>  - there were 16 processes in cgroup
>>  - processes in cgroup were taking togather 100% of CPU (it
>>    was allowed to use only one core, so 100% of that core)
>>  - memory.failcnt was groving fast
>>  - oom_control:
>> oom_kill_disable 0
>> under_oom 0 (this was looping from 0 to 1)
>
>So there was an OOM going on but no messages in the log? Really strange.
>Kame already asked about oom_score_adj of the processes in the group but
>it didn't look like all the processes would have oom disabled, right?


There were no messages telling that some processes were killed because of OOM.


>>  - limit_in_bytes was set to 157286400
>>  - content of stat (as you can see, the whole memory limit was used):
>> cache 0
>> rss 0
>
>This looks like a top-level group for your user.


Yes, it was from /cgroup/<user-id>/


>> mapped_file 0
>> pgpgin 0
>> pgpgout 0
>> swap 0
>> pgfault 0
>> pgmajfault 0
>> inactive_anon 0
>> active_anon 0
>> inactive_file 0
>> active_file 0
>> unevictable 0
>> hierarchical_memory_limit 157286400
>> hierarchical_memsw_limit 157286400
>> total_cache 0
>> total_rss 157286400
>
>OK, so all the memory is anonymous and you have no swap so the oom is
>the only thing to do.


What will happen if the same situation occurs globally? No swap, every bit of memory used. Will kernel be able to start OOM killer? Maybe the same thing is happening in cgroup - there's simply no space to run OOM killer. And maybe this is why it's happening rarely - usually there are still at least few KBs of memory left to start OOM killer.


>Hmm, all processes waiting for oom are stuck at the very same place:
>$ grep mem_cgroup_handle_oom -r [0-9]*
>30858/stack:[<ffffffff8110a9c1>] mem_cgroup_handle_oom+0x241/0x3b0
>30859/stack:[<ffffffff8110a9c1>] mem_cgroup_handle_oom+0x241/0x3b0
>30860/stack:[<ffffffff8110a9c1>] mem_cgroup_handle_oom+0x241/0x3b0
>30892/stack:[<ffffffff8110a9c1>] mem_cgroup_handle_oom+0x241/0x3b0
>30898/stack:[<ffffffff8110a9c1>] mem_cgroup_handle_oom+0x241/0x3b0
>31588/stack:[<ffffffff8110a9c1>] mem_cgroup_handle_oom+0x241/0x3b0
>32044/stack:[<ffffffff8110a9c1>] mem_cgroup_handle_oom+0x241/0x3b0
>32358/stack:[<ffffffff8110a9c1>] mem_cgroup_handle_oom+0x241/0x3b0
>6031/stack:[<ffffffff8110a9c1>] mem_cgroup_handle_oom+0x241/0x3b0
>6534/stack:[<ffffffff8110a9c1>] mem_cgroup_handle_oom+0x241/0x3b0
>7020/stack:[<ffffffff8110a9c1>] mem_cgroup_handle_oom+0x241/0x3b0
>
>We are taking memcg_oom_lock spinlock twice in that function + we can
>schedule. As none of the tasks is scheduled this would suggest that you
>are blocked at the first lock. But who got the lock then?
>This is really strange.
>Btw. is sysrq+t resp. sysrq+w showing the same traces as
>/proc/<pid>/stat?


Unfortunately i'm connecting remotely to the servers (SSH).


>> Notice that stack is different for few processes.
>
>Yes others are in VFS resp ext3. ext3_write_begin looks a bit dangerous
>but it grabs the page before it really starts a transaction.


Maybe these processes were throttled by cgroup-blkio at the same time and are still keeping the lock? So the problem occurs when there are low on memory and cgroup is doing IO out of it's limits. Only guessing and telling my thoughts.


>> Stack for all processes were NOT chaging and was still the same.
>
>Could you take few snapshots over time?


Will do next time but i can't keep services freezed for a long time or customers will be angry.


>> didn't checked if cgroup was freezed but i suppose it wasn't):
>> none            /cgroups        cgroup  defaults,cpuacct,cpuset,memory,freezer,task,blkio 0 0
>
>Do you see the same issue if only memory controller was mounted (resp.
>cpuset which you seem to use as well from your description).


Uh, we are using all mounted subsystems :( I will be able to umount only freezer and maybe blkio for some time. Will it help?


>I know you said booting into a vanilla kernel would be problematic but
>could you at least rule out te cgroup patches that you have mentioned?
>If you need to move a task to a group based by an uid you can use
>cgrules daemon (libcgroup1 package) for that as well.


We are using cgroup-uid cos it's MUCH MUCH MUCH more efective and better. For example, i don't believe that cgroup-task will work with that daemon. What will happen if cgrules won't be able to add process into cgroup because of task limit? Process will probably continue and will run outside of any cgroup which is wrong. With cgroup-task + cgroup-uid, such processes cannot be even started (and this is what we need).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
