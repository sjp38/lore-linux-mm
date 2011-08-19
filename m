Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id A547F6B0170
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 20:00:58 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p7J00pPL014822
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 17:00:54 -0700
Received: from qwb7 (qwb7.prod.google.com [10.241.193.71])
	by wpaz9.hot.corp.google.com with ESMTP id p7J00l0W011989
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 17:00:50 -0700
Received: by qwb7 with SMTP id 7so2180027qwb.40
        for <linux-mm@kvack.org>; Thu, 18 Aug 2011 17:00:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110818144025.8e122a67.akpm@linux-foundation.org>
References: <1313650253-21794-1-git-send-email-gthelen@google.com> <20110818144025.8e122a67.akpm@linux-foundation.org>
From: Greg Thelen <gthelen@google.com>
Date: Thu, 18 Aug 2011 17:00:30 -0700
Message-ID: <CAHH2K0b_jNHfAnSpDqBMKh4NbZCu8JrEcfjb+rputWKXgv5FLA@mail.gmail.com>
Subject: Re: [PATCH] memcg: remove unneeded preempt_disable
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-arch@vger.kernel.org, Valdis.Kletnieks@vt.edu, jweiner@redhat.com

On Thu, Aug 18, 2011 at 2:40 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> (cc linux-arch)
>
> On Wed, 17 Aug 2011 23:50:53 -0700
> Greg Thelen <gthelen@google.com> wrote:
>
>> Both mem_cgroup_charge_statistics() and mem_cgroup_move_account() were
>> unnecessarily disabling preemption when adjusting per-cpu counters:
>> =A0 =A0 preempt_disable()
>> =A0 =A0 __this_cpu_xxx()
>> =A0 =A0 __this_cpu_yyy()
>> =A0 =A0 preempt_enable()
>>
>> This change does not disable preemption and thus CPU switch is possible
>> within these routines. =A0This does not cause a problem because the tota=
l
>> of all cpu counters is summed when reporting stats. =A0Now both
>> mem_cgroup_charge_statistics() and mem_cgroup_move_account() look like:
>> =A0 =A0 this_cpu_xxx()
>> =A0 =A0 this_cpu_yyy()
>>
>> ...
>>
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -664,24 +664,20 @@ static unsigned long mem_cgroup_read_events(struct=
 mem_cgroup *mem,
>> =A0static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0bool file, int nr_pages)
>> =A0{
>> - =A0 =A0 preempt_disable();
>> -
>> =A0 =A0 =A0 if (file)
>> - =A0 =A0 =A0 =A0 =A0 =A0 __this_cpu_add(mem->stat->count[MEM_CGROUP_STA=
T_CACHE], nr_pages);
>> + =A0 =A0 =A0 =A0 =A0 =A0 this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_=
CACHE], nr_pages);
>> =A0 =A0 =A0 else
>> - =A0 =A0 =A0 =A0 =A0 =A0 __this_cpu_add(mem->stat->count[MEM_CGROUP_STA=
T_RSS], nr_pages);
>> + =A0 =A0 =A0 =A0 =A0 =A0 this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_=
RSS], nr_pages);
>>
>> =A0 =A0 =A0 /* pagein of a big page is an event. So, ignore page size */
>> =A0 =A0 =A0 if (nr_pages > 0)
>> - =A0 =A0 =A0 =A0 =A0 =A0 __this_cpu_inc(mem->stat->events[MEM_CGROUP_EV=
ENTS_PGPGIN]);
>> + =A0 =A0 =A0 =A0 =A0 =A0 this_cpu_inc(mem->stat->events[MEM_CGROUP_EVEN=
TS_PGPGIN]);
>> =A0 =A0 =A0 else {
>> - =A0 =A0 =A0 =A0 =A0 =A0 __this_cpu_inc(mem->stat->events[MEM_CGROUP_EV=
ENTS_PGPGOUT]);
>> + =A0 =A0 =A0 =A0 =A0 =A0 this_cpu_inc(mem->stat->events[MEM_CGROUP_EVEN=
TS_PGPGOUT]);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_pages =3D -nr_pages; /* for event */
>> =A0 =A0 =A0 }
>>
>> - =A0 =A0 __this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_COUNT], nr_=
pages);
>> -
>> - =A0 =A0 preempt_enable();
>> + =A0 =A0 this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_COUNT], nr_pa=
ges);
>> =A0}
>
> On non-x86 architectures this_cpu_add() internally does
> preempt_disable() and preempt_enable(). =A0So the patch is a small
> optimisation for x86 and a larger deoptimisation for non-x86.
>
> I think I'll apply it, as the call frequency is low (correct?) and the
> problem will correct itself as other architectures implement their
> atomic this_cpu_foo() operations.

mem_cgroup_charge_statistics() is a common operation, which is called
on each memcg page charge and uncharge.

The per arch/config effects of this patch:
* non-preemptible kernels: there's no difference before/after this patch.
* preemptible x86: this patch helps by removing an unnecessary
preempt_disable/enable.
* preemptible non-x86: this patch hurts by adding implicit
preempt_disable/enable around each operation.

So I am uncomfortable this patch's unmeasured impact on archs that do
not have atomic this_cpu_foo() operations.  Please drop the patch from
mmotm.  Sorry for the noise.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
