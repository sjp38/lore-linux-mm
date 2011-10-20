Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 217266B002D
	for <linux-mm@kvack.org>; Thu, 20 Oct 2011 19:41:39 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p9KNfY9B020018
	for <linux-mm@kvack.org>; Thu, 20 Oct 2011 16:41:34 -0700
Received: from vws14 (vws14.prod.google.com [10.241.21.142])
	by wpaz5.hot.corp.google.com with ESMTP id p9KNc98Y032515
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Oct 2011 16:41:33 -0700
Received: by vws14 with SMTP id 14so4571145vws.3
        for <linux-mm@kvack.org>; Thu, 20 Oct 2011 16:41:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20111020013305.GD21703@tiehlicka.suse.cz>
References: <20111020013305.GD21703@tiehlicka.suse.cz>
Date: Thu, 20 Oct 2011 16:41:27 -0700
Message-ID: <CALWz4ixxeFveibvqYa4cQR1a4fEBrTrTUFwm2iajk9mV0MEiTw@mail.gmail.com>
Subject: Re: [RFD] Isolated memory cgroups again
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, Kir Kolyshkin <kir@parallels.com>, Pavel Emelianov <xemul@parallels.com>, GregThelen <gthelen@google.com>, "pjt@google.com" <pjt@google.com>, Tim Hockin <thockin@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Paul Menage <paul@paulmenage.org>, James Bottomley <James.Bottomley@hansenpartnership.com>

On Wed, Oct 19, 2011 at 6:33 PM, Michal Hocko <mhocko@suse.cz> wrote:
> Hi all,
> this is a request for discussion (I hope we can touch this during memcg
> meeting during the upcoming KS). I have brought this up earlier this
> year before LSF (http://thread.gmane.org/gmane.linux.kernel.mm/60464).
> The patch got much smaller since then due to excellent Johannes' memcg
> naturalization work (http://thread.gmane.org/gmane.linux.kernel.mm/68724)
> which this is based on.
> I realize that this will be controversial but I would like to hear
> whether this is strictly no-go or whether we can go that direction (the
> implementation might differ of course).
>
> The patch is still half baked but I guess it should be sufficient to
> show what I am trying to achieve.
> The basic idea is that memcgs would get a new attribute (isolated) which
> would control whether that group should be considered during global
> reclaim.
> This means that we could achieve a certain memory isolation for
> processes in the group from the rest of the system activity which has
> been traditionally done by mlocking the important parts of memory.
> This approach, however, has some advantages. First of all, it is a kind
> of all or nothing type of approach. Either the memory is important and
> mlocked or you have no guarantee that it keeps resident.
> Secondly it is much more prone to OOM situation.
> Let's consider a case where a memory is evictable in theory but you
> would pay quite much if you have to get it back resident (pre calculated
> data from database - e.g. reports). The memory wouldn't be used very
> often so it would be a number one candidate to evict after some time.
> We would want to have something like a clever mlock in such a case which
> would evict that memory only if the cgroup itself gets under memory
> pressure (e.g. peak workload). This is not hard to do if we are not
> over committing the memory but things get tricky otherwise.
> With the isolated memcgs we get exactly such a guarantee because we would
> reclaim such a memory only from the hard limit reclaim paths or if the
> soft limit reclaim if it is set up.
>
> Any thoughts comments?
>
> ---
> From: Michal Hocko <mhocko@suse.cz>
> Subject: Implement isolated cgroups
>
> This patch adds a new per-cgroup knob (isolated) which controls whether
> pages charged for the group should be considered for the global reclaim
> or they are reclaimed only during soft reclaim and under per-cgroup
> memory pressure.
>
> The value can be modified by GROUP/memory.isolated knob.
>
> The primary idea behind isolated cgroups is in a better isolation of a gr=
oup
> from the global system activity. At the moment, memory cgroups are mainly
> used to throttle processes in a group by placing a cap on their memory
> usage. However, mem. cgroups don't protect their (charged) memory from be=
ing
> evicted by the global reclaim as groups are considered during global
> reclaim.
>
> The feature will provide an easy way to setup a mission critical workload=
 in
> the memory isolated environment without necessity of mlock. Due to
> per-cgroup reclaim we can even handle memory usage spikes much more
> gracefully because a part of the working set can get reclaimed (unlike OO=
M
> killed as if mlock has been used). So we can look at the feature as an
> intelligent mlock (protect from external memory pressure and reclaim on
> internal pressure).
>
> The implementation ignores isolated group status for the soft reclaim whi=
ch
> means that every isolated group can configure how much memory it can
> sacrifice under global memory pressure. Soft unlimited groups are isolate=
d
> from the global memory pressure completely.
>
> Please note that the feature has to be used with caution because isolated
> groups will make a bigger reclaim pressure to non-isolated cgroups.
>
> Implementation is really simple because we just have to hook into shrink_=
zone
> and exclude isolated groups if we are doing the global reclaiming.
>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
>
> TODO
> - consider hierarchies - I am not sure whether we want to have
> =A0non-consistent isolated status in the hierarchy - probably not
> - handle root cgroup
> - Do we want some checks whether the current setting is safe?
> - is bool sufficient. Don't we rather want something like priority
> =A0instead?
>
>
> =A0include/linux/memcontrol.h | =A0 =A07 +++++++
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 44 ++++++++++++++++++++++=
++++++++++++++++++++++
> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A08 +++++++-
> =A03 files changed, 58 insertions(+), 1 deletion(-)
>
> Index: linux-3.1-rc4-next-20110831-mmotm-isolated-memcg/mm/memcontrol.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-3.1-rc4-next-20110831-mmotm-isolated-memcg.orig/mm/memcontrol.c
> +++ linux-3.1-rc4-next-20110831-mmotm-isolated-memcg/mm/memcontrol.c
> @@ -258,6 +258,9 @@ struct mem_cgroup {
> =A0 =A0 =A0 =A0/* set when res.limit =3D=3D memsw.limit */
> =A0 =A0 =A0 =A0bool =A0 =A0 =A0 =A0 =A0 =A0memsw_is_minimum;
>
> + =A0 =A0 =A0 /* is the group isolated from the global memory pressure? *=
/
> + =A0 =A0 =A0 bool =A0 =A0 =A0 =A0 =A0 =A0isolated;
> +
> =A0 =A0 =A0 =A0/* protect arrays of thresholds */
> =A0 =A0 =A0 =A0struct mutex thresholds_lock;
>
> @@ -287,6 +290,11 @@ struct mem_cgroup {
> =A0 =A0 =A0 =A0spinlock_t pcp_counter_lock;
> =A0};
>
> +bool mem_cgroup_isolated(struct mem_cgroup *mem)
> +{
> + =A0 =A0 =A0 return mem->isolated;
> +}
> +
> =A0/* Stuffs for move charges at task migration. */
> =A0/*
> =A0* Types of charges to be moved. "move_charge_at_immitgrate" is treated=
 as a
> @@ -4561,6 +4569,37 @@ static int mem_control_numa_stat_open(st
> =A0}
> =A0#endif /* CONFIG_NUMA */
>
> +static int mem_cgroup_isolated_write(struct cgroup *cgrp, struct cftype =
*cft,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 const char *buffer)
> +{
> + =A0 =A0 =A0 int ret =3D -EINVAL;
> + =A0 =A0 =A0 struct mem_cgroup *mem =3D mem_cgroup_from_cont(cgrp);
> +
> + =A0 =A0 =A0 if (mem_cgroup_is_root(mem))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> +
> + =A0 =A0 =A0 if (!strcasecmp(buffer, "true"))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem->isolated =3D true;
> + =A0 =A0 =A0 else if (!strcasecmp(buffer, "false"))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem->isolated =3D false;
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> +
> + =A0 =A0 =A0 ret =3D 0;
> +out:
> + =A0 =A0 =A0 return ret;
> +}
> +
> +static int mem_cgroup_isolated_read(struct cgroup *cgrp, struct cftype *=
cft,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct seq_file *seq)
> +{
> + =A0 =A0 =A0 struct mem_cgroup *mem =3D mem_cgroup_from_cont(cgrp);
> +
> + =A0 =A0 =A0 seq_puts(seq, (mem->isolated)?"true":"false");
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> =A0static struct cftype mem_cgroup_files[] =3D {
> =A0 =A0 =A0 =A0{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.name =3D "usage_in_bytes",
> @@ -4624,6 +4663,11 @@ static struct cftype mem_cgroup_files[]
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.unregister_event =3D mem_cgroup_oom_unreg=
ister_event,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.private =3D MEMFILE_PRIVATE(_OOM_TYPE, OO=
M_CONTROL),
> =A0 =A0 =A0 =A0},
> + =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D "isolated",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .write_string =3D mem_cgroup_isolated_write=
,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .read_seq_string =3D mem_cgroup_isolated_re=
ad,
> + =A0 =A0 =A0 },
> =A0#ifdef CONFIG_NUMA
> =A0 =A0 =A0 =A0{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.name =3D "numa_stat",
> Index: linux-3.1-rc4-next-20110831-mmotm-isolated-memcg/include/linux/mem=
control.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-3.1-rc4-next-20110831-mmotm-isolated-memcg.orig/include/linux/m=
emcontrol.h
> +++ linux-3.1-rc4-next-20110831-mmotm-isolated-memcg/include/linux/memcon=
trol.h
> @@ -165,6 +165,9 @@ void mem_cgroup_split_huge_fixup(struct
> =A0bool mem_cgroup_bad_page_check(struct page *page);
> =A0void mem_cgroup_print_bad_page(struct page *page);
> =A0#endif
> +
> +bool mem_cgroup_isolated(struct mem_cgroup *mem);
> +
> =A0#else /* CONFIG_CGROUP_MEM_RES_CTLR */
> =A0struct mem_cgroup;
>
> @@ -382,6 +385,10 @@ static inline
> =A0void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_ite=
m idx)
> =A0{
> =A0}
> +bool mem_cgroup_isolated(struct mem_cgroup *mem)
> +{
> + =A0 =A0 =A0 return false;
> +}
> =A0#endif /* CONFIG_CGROUP_MEM_CONT */
>
> =A0#if !defined(CONFIG_CGROUP_MEM_RES_CTLR) || !defined(CONFIG_DEBUG_VM)
> Index: linux-3.1-rc4-next-20110831-mmotm-isolated-memcg/mm/vmscan.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-3.1-rc4-next-20110831-mmotm-isolated-memcg.orig/mm/vmscan.c
> +++ linux-3.1-rc4-next-20110831-mmotm-isolated-memcg/mm/vmscan.c
> @@ -2109,7 +2109,13 @@ static void shrink_zone(int priority, st
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.zone =3D zone,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0};
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_mem_cgroup_zone(priority, &mz, sc);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Do not reclaim from an isolated group =
if we are in
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* the global reclaim.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!(mem_cgroup_isolated(mem) && global_re=
claim(sc)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_mem_cgroup_zone(prio=
rity, &mz, sc);
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Limit reclaim has historically picked o=
ne memcg and
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * scanned it with decreasing priority lev=
els until
> --
> Michal Hocko
> SUSE Labs
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9
> Czech Republic
>

Hi Michal:

I didn't read through the patch itself but only the description. If we
wanna protect a memcg being reclaimed from under global memory
pressure, I think we can approach it by making change on soft_limit
reclaim.

I have a soft_limit change built on top of Johannes's patchset, which
does basically soft_limit aware reclaim under global memory pressure.
The implementation is simple, and I am looking forward to discuss more
with you guys in the conference.

--Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
