Message-ID: <48031090.5050002@cn.fujitsu.com>
Date: Mon, 14 Apr 2008 16:06:40 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: kernel warning: tried to kill an mm-less task!
References: <4803030D.3070906@cn.fujitsu.com> <48030F69.7040801@linux.vnet.ibm.com>
In-Reply-To: <48030F69.7040801@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelianov <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> Li Zefan wrote:
>> When I ran the same test program I described in a previous patch,
>> I got the following warning:
>>
>> WARNING: at mm/oom_kill.c:320 __oom_kill_task+0x6d/0x101()
>> Modules linked in: 
>>
>> Pid: 3856, comm: a.out Not tainted 2.6.25-rc8-mm2 #37
>>  [<ffffffff80243941>] warn_on_slowpath+0x64/0xa2
>>  [<ffffffff80244e16>] printk+0x5e/0x7b
>>  [<ffffffff8022b096>] page_count+0x25/0x49
>>  [<ffffffff8022b2cd>] show_mem+0x125/0x15a
>>  [<ffffffff8028f00f>] __oom_kill_task+0x6d/0x101
>>  [<ffffffff8028f319>] oom_kill_process+0x16c/0x22e
>>  [<ffffffff8028f72c>] select_bad_process+0xb0/0x122
>>  [<ffffffff8028f8d3>] mem_cgroup_out_of_memory+0x65/0x8a
>>  [<ffffffff802bee84>] mem_cgroup_charge_common+0xf8/0x215
>>  [<ffffffff802a14ac>] handle_mm_fault+0x216/0x6c8
>>  [<ffffffff8029ebca>] follow_page+0x191/0x27d
>>  [<ffffffff80234155>] need_resched+0x31/0x4f
>>  [<ffffffff802a1c53>] get_user_pages+0x2f5/0x3eb
>>  [<ffffffff802a1f64>] make_pages_present+0x9e/0xca
>>  [<ffffffff802a51fc>] mmap_region+0x38c/0x452
>>  [<ffffffff802119c4>] arch_get_unmapped_area_topdown+0x1bf/0x2a7
>>  [<ffffffff802a5971>] do_mmap_pgoff+0x321/0x39b
>>  [<ffffffff805037ee>] _cond_resched+0x1c/0x5f
>>  [<ffffffff80211715>] sys_mmap+0xf5/0x138
>>  [<ffffffff8020c6d2>] tracesys+0xd5/0xda
>> ---[ end trace fe959fb2f0473e7c ]---
>> tried to kill an mm-less task!
>>
>> This showed up several times in some seconds, but then didn't appear
>> any more. And it's reproducable in a x86_64 box, but doesn't happen
>> in a x86_32 one.
>>
>> And this happens both with and without the oops fixing.
>>
> 
> Could we get some more details on which task was chosen to be killed? It will be
> nice to see the task flags as well to see if PF_EXITING is set.
> 
> oom_kill_task() has a big WARNING in the comment
> 
>         /* WARNING: mm may not be dereferenced since we did not obtain its
>          * value from get_task_mm(p).  This is OK since all we need to do is
>          * compare mm to q->mm below.
> 
> 
> I want to see the flags to see if
> 
> PF_BORROWED_MM or PF_EXIT* is set.
> 
> 

OK, I'll try.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
