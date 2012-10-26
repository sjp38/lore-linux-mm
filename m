Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 5C02C6B0072
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 13:02:39 -0400 (EDT)
Message-ID: <1351270990.16639.92.camel@maggy.simpson.net>
Subject: Re: process hangs on do_exit when oom happens
From: Mike Galbraith <efault@gmx.de>
Date: Fri, 26 Oct 2012 10:03:10 -0700
In-Reply-To: <CAKWKT+ZRTUwer8qhjWGjkra63e10R67UQzezdaCaStz+rvGjxw@mail.gmail.com>
References: <op.wmbi5kbrn27o5l@gaoqiang-d1.corp.qihoo.net>
	 <20121019160425.GA10175@dhcp22.suse.cz>
	 <CAKWKT+ZRMHzgCLJ1quGnw-_T1b9OboYKnQdRc2_Z=rdU_PFVtw@mail.gmail.com>
	 <CAKTCnzkMQQXRdx=ikydsD9Pm3LuRgf45_=m7ozuFmSZyxazXyA@mail.gmail.com>
	 <CAKWKT+bYOf0cEDuiibf6eV2raMxe481y-D+nrBgPWR3R+53zvg@mail.gmail.com>
	 <20121023095028.GD15397@dhcp22.suse.cz>
	 <CAKWKT+b2s4E7Nne5d0UJwfLGiCXqAUgrCzuuZi6ZPdjszVSmWg@mail.gmail.com>
	 <20121023101500.GE15397@dhcp22.suse.cz>
	 <CAKTCnzkiabWK8tAORkhg6oW11VvXS-YqBwDzED_3=J1buhaQnQ@mail.gmail.com>
	 <CAKWKT+ZahFTnPRJ4FCebxfcrcYEBf+PL9Wa_Foygep_gFst4_g@mail.gmail.com>
	 <20121025095719.GA11105@dhcp22.suse.cz>
	 <CAKWKT+ZRTUwer8qhjWGjkra63e10R67UQzezdaCaStz+rvGjxw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiang Gao <gaoqiangscut@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, linux-mm@kvack.org

On Fri, 2012-10-26 at 10:42 +0800, Qiang Gao wrote: 
> On Thu, Oct 25, 2012 at 5:57 PM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Wed 24-10-12 11:44:17, Qiang Gao wrote:
> >> On Wed, Oct 24, 2012 at 1:43 AM, Balbir Singh <bsingharora@gmail.com> wrote:
> >> > On Tue, Oct 23, 2012 at 3:45 PM, Michal Hocko <mhocko@suse.cz> wrote:
> >> >> On Tue 23-10-12 18:10:33, Qiang Gao wrote:
> >> >>> On Tue, Oct 23, 2012 at 5:50 PM, Michal Hocko <mhocko@suse.cz> wrote:
> >> >>> > On Tue 23-10-12 15:18:48, Qiang Gao wrote:
> >> >>> >> This process was moved to RT-priority queue when global oom-killer
> >> >>> >> happened to boost the recovery of the system..
> >> >>> >
> >> >>> > Who did that? oom killer doesn't boost the priority (scheduling class)
> >> >>> > AFAIK.
> >> >>> >
> >> >>> >> but it wasn't get properily dealt with. I still have no idea why where
> >> >>> >> the problem is ..
> >> >>> >
> >> >>> > Well your configuration says that there is no runtime reserved for the
> >> >>> > group.
> >> >>> > Please refer to Documentation/scheduler/sched-rt-group.txt for more
> >> >>> > information.
> >> >>> >
> >> >> [...]
> >> >>> maybe this is not a upstream-kernel bug. the centos/redhat kernel
> >> >>> would boost the process to RT prio when the process was selected
> >> >>> by oom-killer.
> >> >>
> >> >> This still looks like your cpu controller is misconfigured. Even if the
> >> >> task is promoted to be realtime.
> >> >
> >> >
> >> > Precisely! You need to have rt bandwidth enabled for RT tasks to run,
> >> > as a workaround please give the groups some RT bandwidth and then work
> >> > out the migration to RT and what should be the defaults on the distro.
> >> >
> >> > Balbir
> >>
> >>
> >> see https://patchwork.kernel.org/patch/719411/
> >
> > The patch surely "fixes" your problem but the primary fault here is the
> > mis-configured cpu cgroup. If the value for the bandwidth is zero by
> > default then all realtime processes in the group a screwed. The value
> > should be set to something more reasonable.
> > I am not familiar with the cpu controller but it seems that
> > alloc_rt_sched_group needs some treat. Care to look into it and send a
> > patch to the cpu controller and cgroup maintainers, please?
> >
> > --
> > Michal Hocko
> > SUSE Labs
> 
> I'm trying to fix the problem. but no substantive progress yet.

The throttle tracks a finite resource for an arbitrary number of groups,
so there's no sane rt_runtime default other than zero.

Most folks only want the top level throttle warm fuzzy, so a complete
runtime RT_GROUP_SCHED on/off switch with default to off, ie rt tasks
cannot be moved until switched on would fix some annoying "Oopsie, I
forgot" allocation troubles.  If you turn it on, shame on you if you
fail to allocate, you asked for it, you're not just stuck with it
because your distro enabled it in their config.

Or, perhaps just make zero rt_runtime always mean traverse up to first
non-zero rt_runtime, ie zero allocation children may consume parental
runtime as they see fit on first come first served basis, when it's
gone, tough, parent/children all wait for refill.

Or whatever, as long as you don't bust distribution/tracking for those
crazy people who intentionally use RT_GROUP_SCHED ;-)

The bug is in the patch that used sched_setscheduler_nocheck().  Plain
sched_setscheduler() would have replied -EGOAWAY.

-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
