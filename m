Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8965E6B0072
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 07:01:54 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so7187880pad.14
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 04:01:54 -0700 (PDT)
Subject: =?utf-8?q?Re=3A_=5Bpatch_0=2F7=5D_improve_memcg_oom_killer_robustness_v2?=
Date: Mon, 07 Oct 2013 13:01:49 +0200
From: "azurIt" <azurit@pobox.sk>
References: <20130916152548.GF3674@dhcp22.suse.cz>, <20130916225246.A633145B@pobox.sk>, <20130917000244.GD3278@cmpxchg.org>, <20130917131535.94E0A843@pobox.sk>, <20130917141013.GA30838@dhcp22.suse.cz>, <20130918160304.6EDF2729@pobox.sk>, <20130918180455.GD856@cmpxchg.org>, <20130918181946.GE856@cmpxchg.org>, <20130918195504.GF856@cmpxchg.org>, <20130926185459.E5D2987F@pobox.sk> <20130926192743.GP856@cmpxchg.org>
In-Reply-To: <20130926192743.GP856@cmpxchg.org>
MIME-Version: 1.0
Message-Id: <20131007130149.5F5482D8@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Johannes_Weiner?= <hannes@cmpxchg.org>
Cc: =?utf-8?q?Michal_Hocko?= <mhocko@suse.cz>, =?utf-8?q?Andrew_Morton?= <akpm@linux-foundation.org>, =?utf-8?q?David_Rientjes?= <rientjes@google.com>, =?utf-8?q?KAMEZAWA_Hiroyuki?= <kamezawa.hiroyu@jp.fujitsu.com>, =?utf-8?q?KOSAKI_Motohiro?= <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

>On Thu, Sep 26, 2013 at 06:54:59PM +0200, azurIt wrote:
>> On Wed, Sep 18, 2013 at 02:19:46PM -0400, Johannes Weiner wrote:
>> >Here is an update.  Full replacement on top of 3.2 since we tried a
>> >dead end and it would be more painful to revert individual changes.
>> >
>> >The first bug you had was the same task entering OOM repeatedly and
>> >leaking the memcg reference, thus creating undeletable memcgs.  My
>> >fixup added a condition that if the task already set up an OOM context
>> >in that fault, another charge attempt would immediately return -ENOMEM
>> >without even trying reclaim anymore.  This dropped __getblk() into an
>> >endless loop of waking the flushers and performing global reclaim and
>> >memcg returning -ENOMEM regardless of free memory.
>> >
>> >The update now basically only changes this -ENOMEM to bypass, so that
>> >the memory is not accounted and the limit ignored.  OOM killed tasks
>> >are granted the same right, so that they can exit quickly and release
>> >memory.  Likewise, we want a task that hit the OOM condition also to
>> >finish the fault quickly so that it can invoke the OOM killer.
>> >
>> >Does the following work for you, azur?
>> 
>> 
>> Johannes,
>> 
>> bad news everyone! :(
>> 
>> Unfortunaely, two different problems appears today:
>> 
>> 1.) This looks like my very original problem - stucked processes inside one cgroup. I took stacks from all of them over time but server was very slow so i had to kill them soon:
>> http://watchdog.sk/lkmlmemcg-bug-9.tar.gz
>> 
>> 2.) This was just like my last problem where few processes were doing huge i/o. As sever was almost unoperable i barely killed them so no more info here, sorry.
>
>From one of the tasks:
>
>1380213238/11210/stack:[<ffffffff810528f1>] sys_sched_yield+0x41/0x70
>1380213238/11210/stack:[<ffffffff81148ef1>] free_more_memory+0x21/0x60
>1380213238/11210/stack:[<ffffffff8114957d>] __getblk+0x14d/0x2c0
>1380213238/11210/stack:[<ffffffff81198a2b>] ext3_getblk+0xeb/0x240
>1380213238/11210/stack:[<ffffffff8119d2df>] ext3_find_entry+0x13f/0x480
>1380213238/11210/stack:[<ffffffff8119dd6d>] ext3_lookup+0x4d/0x120
>1380213238/11210/stack:[<ffffffff81122a55>] d_alloc_and_lookup+0x45/0x90
>1380213238/11210/stack:[<ffffffff81122ff8>] do_lookup+0x278/0x390
>1380213238/11210/stack:[<ffffffff81124c40>] path_lookupat+0x120/0x800
>1380213238/11210/stack:[<ffffffff81125355>] do_path_lookup+0x35/0xd0
>1380213238/11210/stack:[<ffffffff811254d9>] user_path_at_empty+0x59/0xb0
>1380213238/11210/stack:[<ffffffff81125541>] user_path_at+0x11/0x20
>1380213238/11210/stack:[<ffffffff81115b70>] sys_faccessat+0xd0/0x200
>1380213238/11210/stack:[<ffffffff81115cb8>] sys_access+0x18/0x20
>1380213238/11210/stack:[<ffffffff815ccc26>] system_call_fastpath+0x18/0x1d
>
>Should have seen this coming... it's still in that braindead
>__getblk() loop, only from a syscall this time (no OOM path).  The
>group's memory.stat looks like this:
>
>cache 0
>rss 0
>mapped_file 0
>pgpgin 0
>pgpgout 0
>swap 0
>pgfault 0
>pgmajfault 0
>inactive_anon 0
>active_anon 0
>inactive_file 0
>active_file 0
>unevictable 0
>hierarchical_memory_limit 209715200
>hierarchical_memsw_limit 209715200
>total_cache 0
>total_rss 209715200
>total_mapped_file 0
>total_pgpgin 1028153297
>total_pgpgout 1028102097
>total_swap 0
>total_pgfault 1352903120
>total_pgmajfault 45342
>total_inactive_anon 0
>total_active_anon 209715200
>total_inactive_file 0
>total_active_file 0
>total_unevictable 0
>
>with anonymous pages to the limit and you probably don't have any swap
>space enabled to anything in the group.
>
>I guess there is no way around annotating that __getblk() loop.  The
>best solution right now is probably to use __GFP_NOFAIL.  For one, we
>can let the allocation bypass the memcg limit if reclaim can't make
>progress.  But also, the loop is then actually happening inside the
>page allocator, where it should happen, and not around ad-hoc direct
>reclaim in buffer.c.
>
>Can you try this on top of our ever-growing stack of patches?




Joahnnes,

looks like the problem is completely resolved :) Thank you, Michal Hocko and everyone involved for help and time.

One more thing:
I see that your patches are going into 3.12. Is there a chance to get them also into 3.2? Is Ben Hutchings (current maintainer of 3.2 branch) competent to decide this? Should i contact him directly? I can't upgrade to 3.12 because stable grsecurity is for 3.2 and i don't think this will change in near future.
 

azur

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
