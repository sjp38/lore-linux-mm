Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 81D9C6B005A
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 04:36:20 -0500 (EST)
Subject: =?utf-8?q?Re=3A_memory=2Dcgroup_bug?=
Date: Thu, 22 Nov 2012 10:36:18 +0100
From: "azurIt" <azurit@pobox.sk>
References: <20121121200207.01068046@pobox.sk> <50AD713F.9030909@jp.fujitsu.com>
In-Reply-To: <50AD713F.9030909@jp.fujitsu.com>
MIME-Version: 1.0
Message-Id: <20121122103618.79F03818@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Kamezawa_Hiroyuki?= <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

______________________________________________________________
> Od: "Kamezawa Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
> Komu: azurIt <azurit@pobox.sk>
> DA!tum: 22.11.2012 01:27
> Predmet: Re: memory-cgroup bug
>
> CC: linux-kernel@vger.kernel.org, "linux-mm" <linux-mm@kvack.org>
>(2012/11/22 4:02), azurIt wrote:
>> Hi,
>>
>> i'm using memory cgroup for limiting our users and having a really strange problem when a cgroup gets out of its memory limit. It's very strange because it happens only sometimes (about once per week on random user), out of memory is usually handled ok. This happens when problem occures:
>>   - no new processes can be started for this cgroup
>>   - current processes are freezed and taking 100% of CPU
>>   - when i try to 'strace' any of current processes, the whole strace freezes until process is killed (strace cannot be terminated by CTRL-c)
>>   - problem can be resolved by raising memory limit for cgroup or killing of few processes inside cgroup so some memory is freed
>>
>> I also garbbed the content of /proc/<pid>/stack of freezed process:
>> [<ffffffff8110a9c1>] mem_cgroup_handle_oom+0x241/0x3b0
>> [<ffffffff8110b5ab>] T.1146+0x5ab/0x5c0
>> [<ffffffff8110ba56>] mem_cgroup_charge_common+0x56/0xa0
>> [<ffffffff8110bae5>] mem_cgroup_newpage_charge+0x45/0x50
>> [<ffffffff810ec54e>] do_wp_page+0x14e/0x800
>> [<ffffffff810eda34>] handle_pte_fault+0x264/0x940
>> [<ffffffff810ee248>] handle_mm_fault+0x138/0x260
>> [<ffffffff810270ed>] do_page_fault+0x13d/0x460
>> [<ffffffff815b53ff>] page_fault+0x1f/0x30
>> [<ffffffffffffffff>] 0xffffffffffffffff
>>
>> I'm currently using kernel 3.2.34 but i'm having this problem since 2.6.32.
>>
>> Any ideas? Thnx.
>>
>
>Under OOM in memcg, only one process is allowed to work. Because processes tends to use up
>CPU at memory shortage. other processes are freezed.
>
>
>Then, the problem here is the one process which uses CPU. IIUC, 'freezed' threads are
>in sleep and never use CPU. It's expected oom-killer or memory-reclaim can solve the probelm.
>
>What is your memcg's memory.oom_control value ?



oom_kill_disable 0



>and process's oom_adj values ? (/proc/<pid>/oom_adj, /proc/<pid>/oom_score_adj)


when i look to a random user PID (Apache web server):
oom_adj = 0
oom_score_adj = 0

I can look also to the data of 'freezed' proces if you need it but i will have to wait until problem occurs again.

The main problem is that when this problem happens, it's NOT resolved automatically by kernel/OOM and user of cgroup, where it happend, has non-working services until i kill his processes by hand. I'm sure that all 'freezed' processes are taking very much CPU because also server load goes really high - next time i will make a screenshot of htop. I really wonder why OOM is __sometimes__ not resolving this (it's usually is, only sometimes not).


Thank you!

azur

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
