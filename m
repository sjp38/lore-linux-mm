Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id B4A786B005D
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 13:05:28 -0500 (EST)
Subject: =?utf-8?q?Re=3A_memory=2Dcgroup_bug?=
Date: Thu, 22 Nov 2012 19:05:26 +0100
From: "azurIt" <azurit@pobox.sk>
References: <20121121200207.01068046@pobox.sk> <20121122152441.GA9609@dhcp22.suse.cz>
In-Reply-To: <20121122152441.GA9609@dhcp22.suse.cz>
MIME-Version: 1.0
Message-Id: <20121122190526.390C7A28@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Michal_Hocko?= <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, =?utf-8?q?cgroups_mailinglist?= <cgroups@vger.kernel.org>

>> i'm using memory cgroup for limiting our users and having a really
>> strange problem when a cgroup gets out of its memory limit. It's very
>> strange because it happens only sometimes (about once per week on
>> random user), out of memory is usually handled ok.
>
>What is your memcg configuration? Do you use deeper hierarchies, is
>use_hierarchy enabled? Is the memcg oom (aka memory.oom_control)
>enabled? Do you use soft limit for those groups? Is memcg swap
>accounting enabled and memsw limits in place?
>Is the machine under global memory pressure as well?
>Could you post sysrq+t or sysrq+w?


My cgroups hierarchy:
/cgroups/<user_id>/uid/

where '<user_id>' is system user id and 'uid' is just word 'uid'.

Memory limits are set in /cgroups/<user_id>/ and hierarchy is enabled. Processes are inside /cgroups/<user_id>/uid/ . I'm using hard limits for memory and swap BUT system has no swap at all (it has 'only' 16 GB of real RAM). memory.oom_control is set to 'oom_kill_disable 0'. Server has enough of free memory when problem occurs.




>> This happens when problem occures:
>>  - no new processes can be started for this cgroup
>>  - current processes are freezed and taking 100% of CPU
>>  - when i try to 'strace' any of current processes, the whole strace
>>    freezes until process is killed (strace cannot be terminated by
>>    CTRL-c)
>>  - problem can be resolved by raising memory limit for cgroup or
>>    killing of few processes inside cgroup so some memory is freed
>> 
>> I also garbbed the content of /proc/<pid>/stack of freezed process:
>> [<ffffffff8110a9c1>] mem_cgroup_handle_oom+0x241/0x3b0
>> [<ffffffff8110b5ab>] T.1146+0x5ab/0x5c0
>
>Hmm what is this?


Really doesn't know, i will get stack of all freezed processes next time so we can compare it.



>> [<ffffffff8110ba56>] mem_cgroup_charge_common+0x56/0xa0
>> [<ffffffff8110bae5>] mem_cgroup_newpage_charge+0x45/0x50
>> [<ffffffff810ec54e>] do_wp_page+0x14e/0x800
>> [<ffffffff810eda34>] handle_pte_fault+0x264/0x940
>> [<ffffffff810ee248>] handle_mm_fault+0x138/0x260
>> [<ffffffff810270ed>] do_page_fault+0x13d/0x460
>> [<ffffffff815b53ff>] page_fault+0x1f/0x30
>> [<ffffffffffffffff>] 0xffffffffffffffff
>>
>
>How many tasks are hung in mem_cgroup_handle_oom? If there were many
>of them then it'd smell like an issue fixed by 79dfdaccd1d5 (memcg:
>make oom_lock 0 and 1 based rather than counter) and its follow up fix
>23751be00940 (memcg: fix hierarchical oom locking) but you are saying
>that you can reproduce with 3.2 and those went in for 3.1. 2.6.32 would
>make more sense.


Usually maximum of several 10s of processes but i will check it next time. I was having much worse problems in 2.6.32 - when freezing happens, the whole server was affected (i wasn't able to do anything and needs to wait until my scripts takes case of it and killed apache, so i don't have any detailed info). In 3.2 only target cgroup is affected.




>> I'm currently using kernel 3.2.34 but i'm having this problem since 2.6.32.
>
>I guess this is a clean vanilla (stable) kernel, right? Are you able to
>reproduce with the latest Linus tree?


Well, no. I'm using, for example, newest stable grsecurity patch. I'm also using few of Andrea Righi's cgroup subsystems but i don't believe these are doing problems:
 - cgroup-uid which is moving processes into cgroups based on UID
 - cgroup-task which can limit number of tasks in cgroup (i already tried to disable this one, it didn't help)
http://www.develer.com/~arighi/linux/patches/

Unfortunately i cannot just install new and untested kernel version cos i'm not able to reproduce this problem anytime (it's happening randomly in production environment).

Could it be that OOM cannot start and kill processes because there's no free memory in cgroup?



Thank you!

azur

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
