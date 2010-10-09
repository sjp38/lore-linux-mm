Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1B97C6B006A
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 22:18:34 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id o992IS3R001248
	for <linux-mm@kvack.org>; Fri, 8 Oct 2010 19:18:28 -0700
Received: from qyk34 (qyk34.prod.google.com [10.241.83.162])
	by hpaq13.eem.corp.google.com with ESMTP id o992IQ0Y025492
	for <linux-mm@kvack.org>; Fri, 8 Oct 2010 19:18:26 -0700
Received: by qyk34 with SMTP id 34so866055qyk.1
        for <linux-mm@kvack.org>; Fri, 08 Oct 2010 19:18:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101009011520.GJ5327@balbir.in.ibm.com>
References: <20101008174958.GI5327@balbir.in.ibm.com> <20101008114123.ff0592b7.akpm@linux-foundation.org>
 <20101009011520.GJ5327@balbir.in.ibm.com>
From: Greg Thelen <gthelen@google.com>
Date: Fri, 8 Oct 2010 19:18:05 -0700
Message-ID: <AANLkTik-+WzhaqJ2KD56MkXGuqFgwejnX8OPbPF1=oqD@mail.gmail.com>
Subject: Re: [BUGFIX] memcg CPU hotplug lockdep warning fix
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 8, 2010 at 6:15 PM, Balbir Singh <balbir@linux.vnet.ibm.com> wr=
ote:
> * Andrew Morton <akpm@linux-foundation.org> [2010-10-08 11:41:23]:
>
>> On Fri, 8 Oct 2010 23:19:58 +0530
>> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>
>> >
>> > memcg has lockdep warnings (sleep inside rcu lock)
>> >
>> > From: Balbir Singh <balbir@linux.vnet.ibm.com>
>> >
>> > Recent move to get_online_cpus() ends up calling get_online_cpus() fro=
m
>> > mem_cgroup_read_stat(). However mem_cgroup_read_stat() is called under=
 rcu
>> > lock. get_online_cpus() can sleep. The dirty limit patches expose
>> > this BUG more readily due to their usage of mem_cgroup_page_stat()
>> >
>> > This patch address this issue as identified by lockdep and moves the
>> > hotplug protection to a higher layer. This might increase the time
>> > required to hotplug, but not by much.
>> >
>> > Warning messages
>> >
>> > BUG: sleeping function called from invalid context at kernel/cpu.c:62
>> > in_atomic(): 0, irqs_disabled(): 0, pid: 6325, name: pagetest
>> > 2 locks held by pagetest/6325:
>> > #0: =A0(&mm->mmap_sem){......}, at: [<ffffffff815e9503>]
>> > do_page_fault+0x27d/0x4a0
>> > #1: =A0(rcu_read_lock){......}, at: [<ffffffff811124a1>]
>> > mem_cgroup_page_stat+0x0/0x23f
>> > Pid: 6325, comm: pagetest Not tainted 2.6.36-rc5-mm1+ #201
>> > Call Trace:
>> > [<ffffffff81041224>] __might_sleep+0x12d/0x131
>> > [<ffffffff8104f4af>] get_online_cpus+0x1c/0x51
>> > [<ffffffff8110eedb>] mem_cgroup_read_stat+0x27/0xa3
>> > [<ffffffff811125d2>] mem_cgroup_page_stat+0x131/0x23f
>> > [<ffffffff811124a1>] ? mem_cgroup_page_stat+0x0/0x23f
>> > [<ffffffff810d57c3>] global_dirty_limits+0x42/0xf8
>> > [<ffffffff810d58b3>] throttle_vm_writeout+0x3a/0xb4
>> > [<ffffffff810dc2f8>] shrink_zone+0x3e6/0x3f8
>> > [<ffffffff81074a35>] ? ktime_get_ts+0xb2/0xbf
>> > [<ffffffff810dd1aa>] do_try_to_free_pages+0x106/0x478
>> > [<ffffffff810dd601>] try_to_free_mem_cgroup_pages+0xe5/0x14c
>> > [<ffffffff8110f947>] mem_cgroup_hierarchical_reclaim+0x314/0x3a2
>> > [<ffffffff81111b31>] __mem_cgroup_try_charge+0x29b/0x593
>> > [<ffffffff8111194a>] ? __mem_cgroup_try_charge+0xb4/0x593
>> > [<ffffffff81071258>] ? local_clock+0x40/0x59
>> > [<ffffffff81009015>] ? sched_clock+0x9/0xd
>> > [<ffffffff810710d5>] ? sched_clock_local+0x1c/0x82
>> > [<ffffffff8111398a>] mem_cgroup_charge_common+0x4b/0x76
>> > [<ffffffff81141469>] ? bio_add_page+0x36/0x38
>> > [<ffffffff81113ba9>] mem_cgroup_cache_charge+0x1f4/0x214
>> > [<ffffffff810cd195>] add_to_page_cache_locked+0x4a/0x148
>> > ....
>> >
>> >
>> > Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
>> > ---
>> >
>> > =A0mm/memcontrol.c | =A0 =A04 ++--
>> > =A01 files changed, 2 insertions(+), 2 deletions(-)
>> >
>> >
>> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> > index 116fecd..f4c5665 100644
>> > --- a/mm/memcontrol.c
>> > +++ b/mm/memcontrol.c
>> > @@ -578,7 +578,6 @@ static s64 mem_cgroup_read_stat(struct mem_cgroup =
*mem,
>> > =A0 =A0 int cpu;
>> > =A0 =A0 s64 val =3D 0;
>> >
>> > - =A0 get_online_cpus();
>> > =A0 =A0 for_each_online_cpu(cpu)
>> > =A0 =A0 =A0 =A0 =A0 =A0 val +=3D per_cpu(mem->stat->count[idx], cpu);
>> > =A0#ifdef CONFIG_HOTPLUG_CPU
>> > @@ -586,7 +585,6 @@ static s64 mem_cgroup_read_stat(struct mem_cgroup =
*mem,
>> > =A0 =A0 val +=3D mem->nocpu_base.count[idx];
>> > =A0 =A0 spin_unlock(&mem->pcp_counter_lock);
>> > =A0#endif
>> > - =A0 put_online_cpus();
>> > =A0 =A0 return val;
>> > =A0}
>> >
>> > @@ -1284,6 +1282,7 @@ s64 mem_cgroup_page_stat(enum mem_cgroup_read_pa=
ge_stat_item item)
>> > =A0 =A0 struct mem_cgroup *iter;
>> > =A0 =A0 s64 value;
>> >
>> > + =A0 get_online_cpus();
>> > =A0 =A0 rcu_read_lock();
>> > =A0 =A0 mem =3D mem_cgroup_from_task(current);
>> > =A0 =A0 if (mem && !mem_cgroup_is_root(mem)) {
>> > @@ -1305,6 +1304,7 @@ s64 mem_cgroup_page_stat(enum mem_cgroup_read_pa=
ge_stat_item item)
>> > =A0 =A0 } else
>> > =A0 =A0 =A0 =A0 =A0 =A0 value =3D -EINVAL;
>> > =A0 =A0 rcu_read_unlock();
>> > + =A0 put_online_cpus();
>> >
>> > =A0 =A0 return value;
>> > =A0}
>>
>> Confused again. =A0There's no mem_cgroup_page_stat() in mainline,
>> linux-next or in any patches in -mm.
>>
>
> Oops, sorry for the confusion. This patch applies on top of the dirty
> limit patches posted by Greg. I should have posted this in response to
> Greg's posting.

I plan to include Balbir's fix (above) in forthcoming memcg dirty
limits series V2.  I'm running V2 through tests right now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
