Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id B77556B00EE
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 14:04:49 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p86I4dqc010748
	for <linux-mm@kvack.org>; Tue, 6 Sep 2011 11:04:39 -0700
Received: from qyl16 (qyl16.prod.google.com [10.241.83.208])
	by hpaq14.eem.corp.google.com with ESMTP id p86I0FNT030444
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 6 Sep 2011 11:04:38 -0700
Received: by qyl16 with SMTP id 16so4081520qyl.0
        for <linux-mm@kvack.org>; Tue, 06 Sep 2011 11:04:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110906095852.GA25053@redhat.com>
References: <1313650253-21794-1-git-send-email-gthelen@google.com> <20110906095852.GA25053@redhat.com>
From: Greg Thelen <gthelen@google.com>
Date: Tue, 6 Sep 2011 11:04:16 -0700
Message-ID: <CAHH2K0ZpBMwqmPBQ6Eh_7drEN6dcqG+fvPdY7kyE1t5eBk+hrw@mail.gmail.com>
Subject: Re: [PATCH] memcg: remove unneeded preempt_disable
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

On Tue, Sep 6, 2011 at 2:58 AM, Johannes Weiner <jweiner@redhat.com> wrote:
> On Wed, Aug 17, 2011 at 11:50:53PM -0700, Greg Thelen wrote:
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
>> Reported-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> Signed-off-by: Greg Thelen <gthelen@google.com>
>
> I just noticed that both cases have preemption disabled anyway because
> of the page_cgroup bit spinlock.
>
> So removing the preempt_disable() is fine but we can even keep the
> non-atomic __this_cpu operations.
>
> Something like this instead?
>
> ---
> From: Johannes Weiner <jweiner@redhat.com>
> Subject: mm: memcg: remove needless recursive preemption disabling
>
> Callsites of mem_cgroup_charge_statistics() hold the page_cgroup bit
> spinlock, which implies disabled preemption.
>
> The same goes for the explicit preemption disabling to account mapped
> file pages in mem_cgroup_move_account().
>
> The explicit disabling of preemption in both cases is redundant.
>
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>

Looks good, thanks.

Reviewed-by: Greg Thelen <gthelen@google.com>

> ---
> =A0mm/memcontrol.c | =A0 =A06 ------
> =A01 file changed, 6 deletions(-)
>
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -618,8 +618,6 @@ static unsigned long mem_cgroup_read_eve
> =A0static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 bool file, int nr_pages)
> =A0{
> - =A0 =A0 =A0 preempt_disable();
> -
> =A0 =A0 =A0 =A0if (file)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__this_cpu_add(mem->stat->count[MEM_CGROUP=
_STAT_CACHE], nr_pages);
> =A0 =A0 =A0 =A0else
> @@ -634,8 +632,6 @@ static void mem_cgroup_charge_statistics
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0__this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_COUNT],=
 nr_pages);
> -
> - =A0 =A0 =A0 preempt_enable();
> =A0}
>
> =A0unsigned long
> @@ -2582,10 +2578,8 @@ static int mem_cgroup_move_account(struc
>
> =A0 =A0 =A0 =A0if (PageCgroupFileMapped(pc)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Update mapped_file data for mem_cgroup =
*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 preempt_disable();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__this_cpu_dec(from->stat->count[MEM_CGROU=
P_STAT_FILE_MAPPED]);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__this_cpu_inc(to->stat->count[MEM_CGROUP_=
STAT_FILE_MAPPED]);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 preempt_enable();
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0mem_cgroup_charge_statistics(from, PageCgroupCache(pc), -n=
r_pages);
> =A0 =A0 =A0 =A0if (uncharge)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
