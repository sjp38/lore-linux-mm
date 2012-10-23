Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 0BA086B0069
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 06:10:34 -0400 (EDT)
Received: by mail-vb0-f41.google.com with SMTP id v13so4795948vbk.14
        for <linux-mm@kvack.org>; Tue, 23 Oct 2012 03:10:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121023095028.GD15397@dhcp22.suse.cz>
References: <op.wmbi5kbrn27o5l@gaoqiang-d1.corp.qihoo.net>
	<20121019160425.GA10175@dhcp22.suse.cz>
	<CAKWKT+ZRMHzgCLJ1quGnw-_T1b9OboYKnQdRc2_Z=rdU_PFVtw@mail.gmail.com>
	<CAKTCnzkMQQXRdx=ikydsD9Pm3LuRgf45_=m7ozuFmSZyxazXyA@mail.gmail.com>
	<CAKWKT+bYOf0cEDuiibf6eV2raMxe481y-D+nrBgPWR3R+53zvg@mail.gmail.com>
	<20121023095028.GD15397@dhcp22.suse.cz>
Date: Tue, 23 Oct 2012 18:10:33 +0800
Message-ID: <CAKWKT+b2s4E7Nne5d0UJwfLGiCXqAUgrCzuuZi6ZPdjszVSmWg@mail.gmail.com>
Subject: Re: process hangs on do_exit when oom happens
From: Qiang Gao <gaoqiangscut@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Balbir Singh <bsingharora@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, linux-mm@kvack.org

On Tue, Oct 23, 2012 at 5:50 PM, Michal Hocko <mhocko@suse.cz> wrote:
> On Tue 23-10-12 15:18:48, Qiang Gao wrote:
>> This process was moved to RT-priority queue when global oom-killer
>> happened to boost the recovery of the system..
>
> Who did that? oom killer doesn't boost the priority (scheduling class)
> AFAIK.
>
>> but it wasn't get properily dealt with. I still have no idea why where
>> the problem is ..
>
> Well your configuration says that there is no runtime reserved for the
> group.
> Please refer to Documentation/scheduler/sched-rt-group.txt for more
> information.
>
>> On Tue, Oct 23, 2012 at 12:40 PM, Balbir Singh <bsingharora@gmail.com> wrote:
>> > On Tue, Oct 23, 2012 at 9:05 AM, Qiang Gao <gaoqiangscut@gmail.com> wrote:
>> >> information about the system is in the attach file "information.txt"
>> >>
>> >> I can not reproduce it in the upstream 3.6.0 kernel..
>> >>
>> >> On Sat, Oct 20, 2012 at 12:04 AM, Michal Hocko <mhocko@suse.cz> wrote:
>> >>> On Wed 17-10-12 18:23:34, gaoqiang wrote:
>> >>>> I looked up nothing useful with google,so I'm here for help..
>> >>>>
>> >>>> when this happens:  I use memcg to limit the memory use of a
>> >>>> process,and when the memcg cgroup was out of memory,
>> >>>> the process was oom-killed   however,it cannot really complete the
>> >>>> exiting. here is the some information
>> >>>
>> >>> How many tasks are in the group and what kind of memory do they use?
>> >>> Is it possible that you were hit by the same issue as described in
>> >>> 79dfdacc memcg: make oom_lock 0 and 1 based rather than counter.
>> >>>
>> >>>> OS version:  centos6.2    2.6.32.220.7.1
>> >>>
>> >>> Your kernel is quite old and you should be probably asking your
>> >>> distribution to help you out. There were many fixes since 2.6.32.
>> >>> Are you able to reproduce the same issue with the current vanila kernel?
>> >>>
>> >>>> /proc/pid/stack
>> >>>> ---------------------------------------------------------------
>> >>>>
>> >>>> [<ffffffff810597ca>] __cond_resched+0x2a/0x40
>> >>>> [<ffffffff81121569>] unmap_vmas+0xb49/0xb70
>> >>>> [<ffffffff8112822e>] exit_mmap+0x7e/0x140
>> >>>> [<ffffffff8105b078>] mmput+0x58/0x110
>> >>>> [<ffffffff81061aad>] exit_mm+0x11d/0x160
>> >>>> [<ffffffff81061c9d>] do_exit+0x1ad/0x860
>> >>>> [<ffffffff81062391>] do_group_exit+0x41/0xb0
>> >>>> [<ffffffff81077cd8>] get_signal_to_deliver+0x1e8/0x430
>> >>>> [<ffffffff8100a4c4>] do_notify_resume+0xf4/0x8b0
>> >>>> [<ffffffff8100b281>] int_signal+0x12/0x17
>> >>>> [<ffffffffffffffff>] 0xffffffffffffffff
>> >>>
>> >>> This looks strange because this is just an exit part which shouldn't
>> >>> deadlock or anything. Is this stack stable? Have you tried to take check
>> >>> it more times?
>> >
>> > Looking at information.txt, I found something interesting
>> >
>> > rt_rq[0]:/1314
>> >   .rt_nr_running                 : 1
>> >   .rt_throttled                  : 1
>> >   .rt_time                       : 0.856656
>> >   .rt_runtime                    : 0.000000
>> >
>> >
>> > cfs_rq[0]:/1314
>> >   .exec_clock                    : 8738.133429
>> >   .MIN_vruntime                  : 0.000001
>> >   .min_vruntime                  : 8739.371271
>> >   .max_vruntime                  : 0.000001
>> >   .spread                        : 0.000000
>> >   .spread0                       : -9792.255554
>> >   .nr_spread_over                : 1
>> >   .nr_running                    : 0
>> >   .load                          : 0
>> >   .load_avg                      : 7376.722880
>> >   .load_period                   : 7.203830
>> >   .load_contrib                  : 1023
>> >   .load_tg                       : 1023
>> >   .se->exec_start                : 282004.715064
>> >   .se->vruntime                  : 18435.664560
>> >   .se->sum_exec_runtime          : 8738.133429
>> >   .se->wait_start                : 0.000000
>> >   .se->sleep_start               : 0.000000
>> >   .se->block_start               : 0.000000
>> >   .se->sleep_max                 : 0.000000
>> >   .se->block_max                 : 0.000000
>> >   .se->exec_max                  : 77.977054
>> >   .se->slice_max                 : 0.000000
>> >   .se->wait_max                  : 2.664779
>> >   .se->wait_sum                  : 29.970575
>> >   .se->wait_count                : 102
>> >   .se->load.weight               : 2
>> >
>> > So 1314 is a real time process and
>> >
>> > cpu.rt_period_us:
>> > 1000000
>> > ----------------------
>> > cpu.rt_runtime_us:
>> > 0
>> >
>> > When did tt move to being a Real Time process (hint: see nr_running
>> > and nr_throttled)?
>> >
>> > Balbir
>> --
>> To unsubscribe from this list: send the line "unsubscribe cgroups" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> --
> Michal Hocko
> SUSE Labs
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


maybe this is not a upstream-kernel bug. the centos/redhat kernel
would boost the process to RT prio when the process was selected
by oom-killer.

I think I should report this to redhat/centos.thanks for your attention

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
