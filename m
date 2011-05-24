Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id CE45E6B0011
	for <linux-mm@kvack.org>; Tue, 24 May 2011 12:54:54 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p4OGslmo014238
	for <linux-mm@kvack.org>; Tue, 24 May 2011 09:54:47 -0700
Received: from qwb8 (qwb8.prod.google.com [10.241.193.72])
	by hpaq14.eem.corp.google.com with ESMTP id p4OGrFvC028459
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 24 May 2011 09:54:46 -0700
Received: by qwb8 with SMTP id 8so4825237qwb.11
        for <linux-mm@kvack.org>; Tue, 24 May 2011 09:54:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110524154644.GA3440@balbir.in.ibm.com>
References: <1305928918-15207-1-git-send-email-yinghan@google.com>
	<20110524154644.GA3440@balbir.in.ibm.com>
Date: Tue, 24 May 2011 09:54:43 -0700
Message-ID: <BANLkTim+evwxEAYtQQ339N_tqV5jyWVH2w@mail.gmail.com>
Subject: Re: [PATCH V5] memcg: add memory.numastat api for numa statistics
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=002354470aa8d6acf304a40871fc
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--002354470aa8d6acf304a40871fc
Content-Type: text/plain; charset=ISO-8859-1

On Tue, May 24, 2011 at 8:46 AM, Balbir Singh <balbir@linux.vnet.ibm.com>wrote:

> * Ying Han <yinghan@google.com> [2011-05-20 15:01:58]:
>
> > The new API exports numa_maps per-memcg basis. This is a piece of useful
> > information where it exports per-memcg page distribution across real numa
> > nodes.
> >
> > One of the usecase is evaluating application performance by combining
> this
> > information w/ the cpu allocation to the application.
> >
> > The output of the memory.numastat tries to follow w/ simiar format of
> numa_maps
> > like:
> >
> > total=<total pages> N0=<node 0 pages> N1=<node 1 pages> ...
> > file=<total file pages> N0=<node 0 pages> N1=<node 1 pages> ...
> > anon=<total anon pages> N0=<node 0 pages> N1=<node 1 pages> ...
> > unevictable=<total anon pages> N0=<node 0 pages> N1=<node 1 pages> ...
> >
> > And we have per-node:
> > total = file + anon + unevictable
> >
> > $ cat /dev/cgroup/memory/memory.numa_stat
> > total=250020 N0=87620 N1=52367 N2=45298 N3=64735
> > file=225232 N0=83402 N1=46160 N2=40522 N3=55148
> > anon=21053 N0=3424 N1=6207 N2=4776 N3=6646
> > unevictable=3735 N0=794 N1=0 N2=0 N3=2941
> >
> > This patch is based on mmotm-2011-05-06-16-39
> >
> > change v5..v4:
> > 1. disable the API non-NUMA kernel.
> >
> > change v4..v3:
> > 1. add per-node "unevictable" value.
> > 2. change the functions to be static.
> >
> > change v3..v2:
> > 1. calculate the "total" based on the per-memcg lru size instead of
> rss+cache.
> > this makes the "total" value to be consistant w/ the per-node values
> follows
> > after.
> >
> > change v2..v1:
> > 1. add also the file and anon pages on per-node distribution.
> >
> > Signed-off-by: Ying Han <yinghan@google.com>
> > Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > ---
> >  mm/memcontrol.c |  155
> +++++++++++++++++++++++++++++++++++++++++++++++++++++++
> >  1 files changed, 155 insertions(+), 0 deletions(-)
> >
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index e14677c..ced414b 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1162,6 +1162,93 @@ unsigned long mem_cgroup_zone_nr_lru_pages(struct
> mem_cgroup *memcg,
> >       return MEM_CGROUP_ZSTAT(mz, lru);
> >  }
> >
> > +#ifdef CONFIG_NUMA
> > +static unsigned long mem_cgroup_node_nr_file_lru_pages(struct mem_cgroup
> *memcg,
> > +                                                     int nid)
> > +{
> > +     unsigned long ret;
> > +
> > +     ret = mem_cgroup_get_zonestat_node(memcg, nid, LRU_INACTIVE_FILE) +
> > +             mem_cgroup_get_zonestat_node(memcg, nid, LRU_ACTIVE_FILE);
> > +
> > +     return ret;
> > +}
> > +
> > +static unsigned long mem_cgroup_nr_file_lru_pages(struct mem_cgroup
> *memcg)
> > +{
> > +     u64 total = 0;
> > +     int nid;
> > +
> > +     for_each_node_state(nid, N_HIGH_MEMORY)
> > +             total += mem_cgroup_node_nr_file_lru_pages(memcg, nid);
> > +
> > +     return total;
> > +}
> > +
> > +static unsigned long mem_cgroup_node_nr_anon_lru_pages(struct mem_cgroup
> *memcg,
> > +                                                     int nid)
> > +{
> > +     unsigned long ret;
> > +
> > +     ret = mem_cgroup_get_zonestat_node(memcg, nid, LRU_INACTIVE_ANON) +
> > +             mem_cgroup_get_zonestat_node(memcg, nid, LRU_ACTIVE_ANON);
> > +
> > +     return ret;
> > +}
> > +
> > +static unsigned long mem_cgroup_nr_anon_lru_pages(struct mem_cgroup
> *memcg)
> > +{
> > +     u64 total = 0;
> > +     int nid;
> > +
> > +     for_each_node_state(nid, N_HIGH_MEMORY)
> > +             total += mem_cgroup_node_nr_anon_lru_pages(memcg, nid);
> > +
> > +     return total;
> > +}
> > +
> > +static unsigned long
> > +mem_cgroup_node_nr_unevictable_lru_pages(struct mem_cgroup *memcg, int
> nid)
> > +{
> > +     return mem_cgroup_get_zonestat_node(memcg, nid, LRU_UNEVICTABLE);
> > +}
> > +
> > +static unsigned long
> > +mem_cgroup_nr_unevictable_lru_pages(struct mem_cgroup *memcg)
> > +{
> > +     u64 total = 0;
> > +     int nid;
> > +
> > +     for_each_node_state(nid, N_HIGH_MEMORY)
> > +             total += mem_cgroup_node_nr_unevictable_lru_pages(memcg,
> nid);
> > +
> > +     return total;
> > +}
> > +
> > +static unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup
> *memcg,
> > +                                                     int nid)
> > +{
> > +     enum lru_list l;
> > +     u64 total = 0;
> > +
> > +     for_each_lru(l)
> > +             total += mem_cgroup_get_zonestat_node(memcg, nid, l);
> > +
> > +     return total;
> > +}
> > +
> > +static unsigned long mem_cgroup_nr_lru_pages(struct mem_cgroup *memcg)
> > +{
> > +     u64 total = 0;
> > +     int nid;
> > +
> > +     for_each_node_state(nid, N_HIGH_MEMORY)
> > +             total += mem_cgroup_node_nr_lru_pages(memcg, nid);
> > +
> > +     return total;
> > +}
> > +#endif /* CONFIG_NUMA */
> > +
> >  struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup
> *memcg,
> >                                                     struct zone *zone)
> >  {
> > @@ -4048,6 +4135,51 @@ mem_cgroup_get_total_stat(struct mem_cgroup *mem,
> struct mcs_total_stat *s)
> >               mem_cgroup_get_local_stat(iter, s);
> >  }
> >
> > +#ifdef CONFIG_NUMA
> > +static int mem_control_numa_stat_show(struct seq_file *m, void *arg)
> > +{
> > +     int nid;
> > +     unsigned long total_nr, file_nr, anon_nr, unevictable_nr;
> > +     unsigned long node_nr;
> > +     struct cgroup *cont = m->private;
> > +     struct mem_cgroup *mem_cont = mem_cgroup_from_cont(cont);
> > +
> > +     total_nr = mem_cgroup_nr_lru_pages(mem_cont);
> > +     seq_printf(m, "total=%lu", total_nr);
> > +     for_each_node_state(nid, N_HIGH_MEMORY) {
> > +             node_nr = mem_cgroup_node_nr_lru_pages(mem_cont, nid);
> > +             seq_printf(m, " N%d=%lu", nid, node_nr);
> > +     }
> > +     seq_putc(m, '\n');
> > +
> > +     file_nr = mem_cgroup_nr_file_lru_pages(mem_cont);
> > +     seq_printf(m, "file=%lu", file_nr);
> > +     for_each_node_state(nid, N_HIGH_MEMORY) {
> > +             node_nr = mem_cgroup_node_nr_file_lru_pages(mem_cont, nid);
> > +             seq_printf(m, " N%d=%lu", nid, node_nr);
> > +     }
> > +     seq_putc(m, '\n');
> > +
> > +     anon_nr = mem_cgroup_nr_anon_lru_pages(mem_cont);
> > +     seq_printf(m, "anon=%lu", anon_nr);
> > +     for_each_node_state(nid, N_HIGH_MEMORY) {
> > +             node_nr = mem_cgroup_node_nr_anon_lru_pages(mem_cont, nid);
> > +             seq_printf(m, " N%d=%lu", nid, node_nr);
> > +     }
> > +     seq_putc(m, '\n');
> > +
> > +     unevictable_nr = mem_cgroup_nr_unevictable_lru_pages(mem_cont);
> > +     seq_printf(m, "unevictable=%lu", unevictable_nr);
> > +     for_each_node_state(nid, N_HIGH_MEMORY) {
> > +             node_nr =
> mem_cgroup_node_nr_unevictable_lru_pages(mem_cont,
> > +
> nid);
> > +             seq_printf(m, " N%d=%lu", nid, node_nr);
> > +     }
> > +     seq_putc(m, '\n');
> > +     return 0;
> > +}
> > +#endif /* CONFIG_NUMA */
> > +
> >  static int mem_control_stat_show(struct cgroup *cont, struct cftype
> *cft,
> >                                struct cgroup_map_cb *cb)
> >  {
> > @@ -4058,6 +4190,7 @@ static int mem_control_stat_show(struct cgroup
> *cont, struct cftype *cft,
> >       memset(&mystat, 0, sizeof(mystat));
> >       mem_cgroup_get_local_stat(mem_cont, &mystat);
> >
> > +
> >       for (i = 0; i < NR_MCS_STAT; i++) {
> >               if (i == MCS_SWAP && !do_swap_account)
> >                       continue;
> > @@ -4481,6 +4614,22 @@ static int mem_cgroup_oom_control_write(struct
> cgroup *cgrp,
> >       return 0;
> >  }
> >
> > +#ifdef CONFIG_NUMA
> > +static const struct file_operations
> mem_control_numa_stat_file_operations = {
> > +     .read = seq_read,
> > +     .llseek = seq_lseek,
> > +     .release = single_release,
> > +};
> > +
>
> Do we need this?
>
>
> > +static int mem_control_numa_stat_open(struct inode *unused, struct file
> *file)
> > +{
> > +     struct cgroup *cont = file->f_dentry->d_parent->d_fsdata;
> > +
> > +     file->f_op = &mem_control_numa_stat_file_operations;
> > +     return single_open(file, mem_control_numa_stat_show, cont);
> > +}
> > +#endif /* CONFIG_NUMA */
> > +
> >  static struct cftype mem_cgroup_files[] = {
> >       {
> >               .name = "usage_in_bytes",
> > @@ -4544,6 +4693,12 @@ static struct cftype mem_cgroup_files[] = {
> >               .unregister_event = mem_cgroup_oom_unregister_event,
> >               .private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
> >       },
> > +#ifdef CONFIG_NUMA
> > +     {
> > +             .name = "numa_stat",
> > +             .open = mem_control_numa_stat_open,
> > +     },
> > +#endif
>
> Can't we do this the way we do the stats file? Please see
> mem_control_stat_show().
>

I looked that earlier but can not get the formating working as well as the
seq_*. Is there a particular reason we prefer one than the other?

Thanks
--Ying


>
> >  };
> >
> >  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> > --
> > 1.7.3.1
> >
>
> --
>        Three Cheers,
>         Balbir
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign
> http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--002354470aa8d6acf304a40871fc
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Tue, May 24, 2011 at 8:46 AM, Balbir =
Singh <span dir=3D"ltr">&lt;<a href=3D"mailto:balbir@linux.vnet.ibm.com">ba=
lbir@linux.vnet.ibm.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail=
_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:=
1ex;">
* Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google.com</a>=
&gt; [2011-05-20 15:01:58]:<br>
<div><div></div><div class=3D"h5"><br>
&gt; The new API exports numa_maps per-memcg basis. This is a piece of usef=
ul<br>
&gt; information where it exports per-memcg page distribution across real n=
uma<br>
&gt; nodes.<br>
&gt;<br>
&gt; One of the usecase is evaluating application performance by combining =
this<br>
&gt; information w/ the cpu allocation to the application.<br>
&gt;<br>
&gt; The output of the memory.numastat tries to follow w/ simiar format of =
numa_maps<br>
&gt; like:<br>
&gt;<br>
&gt; total=3D&lt;total pages&gt; N0=3D&lt;node 0 pages&gt; N1=3D&lt;node 1 =
pages&gt; ...<br>
&gt; file=3D&lt;total file pages&gt; N0=3D&lt;node 0 pages&gt; N1=3D&lt;nod=
e 1 pages&gt; ...<br>
&gt; anon=3D&lt;total anon pages&gt; N0=3D&lt;node 0 pages&gt; N1=3D&lt;nod=
e 1 pages&gt; ...<br>
&gt; unevictable=3D&lt;total anon pages&gt; N0=3D&lt;node 0 pages&gt; N1=3D=
&lt;node 1 pages&gt; ...<br>
&gt;<br>
&gt; And we have per-node:<br>
&gt; total =3D file + anon + unevictable<br>
&gt;<br>
&gt; $ cat /dev/cgroup/memory/memory.numa_stat<br>
&gt; total=3D250020 N0=3D87620 N1=3D52367 N2=3D45298 N3=3D64735<br>
&gt; file=3D225232 N0=3D83402 N1=3D46160 N2=3D40522 N3=3D55148<br>
&gt; anon=3D21053 N0=3D3424 N1=3D6207 N2=3D4776 N3=3D6646<br>
&gt; unevictable=3D3735 N0=3D794 N1=3D0 N2=3D0 N3=3D2941<br>
&gt;<br>
&gt; This patch is based on mmotm-2011-05-06-16-39<br>
&gt;<br>
&gt; change v5..v4:<br>
&gt; 1. disable the API non-NUMA kernel.<br>
&gt;<br>
&gt; change v4..v3:<br>
&gt; 1. add per-node &quot;unevictable&quot; value.<br>
&gt; 2. change the functions to be static.<br>
&gt;<br>
&gt; change v3..v2:<br>
&gt; 1. calculate the &quot;total&quot; based on the per-memcg lru size ins=
tead of rss+cache.<br>
&gt; this makes the &quot;total&quot; value to be consistant w/ the per-nod=
e values follows<br>
&gt; after.<br>
&gt;<br>
&gt; change v2..v1:<br>
&gt; 1. add also the file and anon pages on per-node distribution.<br>
&gt;<br>
&gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com">ying=
han@google.com</a>&gt;<br>
&gt; Acked-by: KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu@jp.f=
ujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;<br>
&gt; Acked-by: Daisuke Nishimura &lt;<a href=3D"mailto:nishimura@mxp.nes.ne=
c.co.jp">nishimura@mxp.nes.nec.co.jp</a>&gt;<br>
&gt; ---<br>
&gt; =A0mm/memcontrol.c | =A0155 ++++++++++++++++++++++++++++++++++++++++++=
+++++++++++++<br>
&gt; =A01 files changed, 155 insertions(+), 0 deletions(-)<br>
&gt;<br>
&gt; diff --git a/mm/memcontrol.c b/mm/memcontrol.c<br>
&gt; index e14677c..ced414b 100644<br>
&gt; --- a/mm/memcontrol.c<br>
&gt; +++ b/mm/memcontrol.c<br>
&gt; @@ -1162,6 +1162,93 @@ unsigned long mem_cgroup_zone_nr_lru_pages(stru=
ct mem_cgroup *memcg,<br>
&gt; =A0 =A0 =A0 return MEM_CGROUP_ZSTAT(mz, lru);<br>
&gt; =A0}<br>
&gt;<br>
&gt; +#ifdef CONFIG_NUMA<br>
&gt; +static unsigned long mem_cgroup_node_nr_file_lru_pages(struct mem_cgr=
oup *memcg,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int nid)<br>
&gt; +{<br>
&gt; + =A0 =A0 unsigned long ret;<br>
&gt; +<br>
&gt; + =A0 =A0 ret =3D mem_cgroup_get_zonestat_node(memcg, nid, LRU_INACTIV=
E_FILE) +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_get_zonestat_node(memcg, nid, LRU=
_ACTIVE_FILE);<br>
&gt; +<br>
&gt; + =A0 =A0 return ret;<br>
&gt; +}<br>
&gt; +<br>
&gt; +static unsigned long mem_cgroup_nr_file_lru_pages(struct mem_cgroup *=
memcg)<br>
&gt; +{<br>
&gt; + =A0 =A0 u64 total =3D 0;<br>
&gt; + =A0 =A0 int nid;<br>
&gt; +<br>
&gt; + =A0 =A0 for_each_node_state(nid, N_HIGH_MEMORY)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 total +=3D mem_cgroup_node_nr_file_lru_pages=
(memcg, nid);<br>
&gt; +<br>
&gt; + =A0 =A0 return total;<br>
&gt; +}<br>
&gt; +<br>
&gt; +static unsigned long mem_cgroup_node_nr_anon_lru_pages(struct mem_cgr=
oup *memcg,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int nid)<br>
&gt; +{<br>
&gt; + =A0 =A0 unsigned long ret;<br>
&gt; +<br>
&gt; + =A0 =A0 ret =3D mem_cgroup_get_zonestat_node(memcg, nid, LRU_INACTIV=
E_ANON) +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_get_zonestat_node(memcg, nid, LRU=
_ACTIVE_ANON);<br>
&gt; +<br>
&gt; + =A0 =A0 return ret;<br>
&gt; +}<br>
&gt; +<br>
&gt; +static unsigned long mem_cgroup_nr_anon_lru_pages(struct mem_cgroup *=
memcg)<br>
&gt; +{<br>
&gt; + =A0 =A0 u64 total =3D 0;<br>
&gt; + =A0 =A0 int nid;<br>
&gt; +<br>
&gt; + =A0 =A0 for_each_node_state(nid, N_HIGH_MEMORY)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 total +=3D mem_cgroup_node_nr_anon_lru_pages=
(memcg, nid);<br>
&gt; +<br>
&gt; + =A0 =A0 return total;<br>
&gt; +}<br>
&gt; +<br>
&gt; +static unsigned long<br>
&gt; +mem_cgroup_node_nr_unevictable_lru_pages(struct mem_cgroup *memcg, in=
t nid)<br>
&gt; +{<br>
&gt; + =A0 =A0 return mem_cgroup_get_zonestat_node(memcg, nid, LRU_UNEVICTA=
BLE);<br>
&gt; +}<br>
&gt; +<br>
&gt; +static unsigned long<br>
&gt; +mem_cgroup_nr_unevictable_lru_pages(struct mem_cgroup *memcg)<br>
&gt; +{<br>
&gt; + =A0 =A0 u64 total =3D 0;<br>
&gt; + =A0 =A0 int nid;<br>
&gt; +<br>
&gt; + =A0 =A0 for_each_node_state(nid, N_HIGH_MEMORY)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 total +=3D mem_cgroup_node_nr_unevictable_lr=
u_pages(memcg, nid);<br>
&gt; +<br>
&gt; + =A0 =A0 return total;<br>
&gt; +}<br>
&gt; +<br>
&gt; +static unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *=
memcg,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int nid)<br>
&gt; +{<br>
&gt; + =A0 =A0 enum lru_list l;<br>
&gt; + =A0 =A0 u64 total =3D 0;<br>
&gt; +<br>
&gt; + =A0 =A0 for_each_lru(l)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 total +=3D mem_cgroup_get_zonestat_node(memc=
g, nid, l);<br>
&gt; +<br>
&gt; + =A0 =A0 return total;<br>
&gt; +}<br>
&gt; +<br>
&gt; +static unsigned long mem_cgroup_nr_lru_pages(struct mem_cgroup *memcg=
)<br>
&gt; +{<br>
&gt; + =A0 =A0 u64 total =3D 0;<br>
&gt; + =A0 =A0 int nid;<br>
&gt; +<br>
&gt; + =A0 =A0 for_each_node_state(nid, N_HIGH_MEMORY)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 total +=3D mem_cgroup_node_nr_lru_pages(memc=
g, nid);<br>
&gt; +<br>
&gt; + =A0 =A0 return total;<br>
&gt; +}<br>
&gt; +#endif /* CONFIG_NUMA */<br>
&gt; +<br>
&gt; =A0struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cg=
roup *memcg,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone)<br>
&gt; =A0{<br>
&gt; @@ -4048,6 +4135,51 @@ mem_cgroup_get_total_stat(struct mem_cgroup *me=
m, struct mcs_total_stat *s)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_get_local_stat(iter, s);<br>
&gt; =A0}<br>
&gt;<br>
&gt; +#ifdef CONFIG_NUMA<br>
&gt; +static int mem_control_numa_stat_show(struct seq_file *m, void *arg)<=
br>
&gt; +{<br>
&gt; + =A0 =A0 int nid;<br>
&gt; + =A0 =A0 unsigned long total_nr, file_nr, anon_nr, unevictable_nr;<br=
>
&gt; + =A0 =A0 unsigned long node_nr;<br>
&gt; + =A0 =A0 struct cgroup *cont =3D m-&gt;private;<br>
&gt; + =A0 =A0 struct mem_cgroup *mem_cont =3D mem_cgroup_from_cont(cont);<=
br>
&gt; +<br>
&gt; + =A0 =A0 total_nr =3D mem_cgroup_nr_lru_pages(mem_cont);<br>
&gt; + =A0 =A0 seq_printf(m, &quot;total=3D%lu&quot;, total_nr);<br>
&gt; + =A0 =A0 for_each_node_state(nid, N_HIGH_MEMORY) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 node_nr =3D mem_cgroup_node_nr_lru_pages(mem=
_cont, nid);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 seq_printf(m, &quot; N%d=3D%lu&quot;, nid, n=
ode_nr);<br>
&gt; + =A0 =A0 }<br>
&gt; + =A0 =A0 seq_putc(m, &#39;\n&#39;);<br>
&gt; +<br>
&gt; + =A0 =A0 file_nr =3D mem_cgroup_nr_file_lru_pages(mem_cont);<br>
&gt; + =A0 =A0 seq_printf(m, &quot;file=3D%lu&quot;, file_nr);<br>
&gt; + =A0 =A0 for_each_node_state(nid, N_HIGH_MEMORY) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 node_nr =3D mem_cgroup_node_nr_file_lru_page=
s(mem_cont, nid);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 seq_printf(m, &quot; N%d=3D%lu&quot;, nid, n=
ode_nr);<br>
&gt; + =A0 =A0 }<br>
&gt; + =A0 =A0 seq_putc(m, &#39;\n&#39;);<br>
&gt; +<br>
&gt; + =A0 =A0 anon_nr =3D mem_cgroup_nr_anon_lru_pages(mem_cont);<br>
&gt; + =A0 =A0 seq_printf(m, &quot;anon=3D%lu&quot;, anon_nr);<br>
&gt; + =A0 =A0 for_each_node_state(nid, N_HIGH_MEMORY) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 node_nr =3D mem_cgroup_node_nr_anon_lru_page=
s(mem_cont, nid);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 seq_printf(m, &quot; N%d=3D%lu&quot;, nid, n=
ode_nr);<br>
&gt; + =A0 =A0 }<br>
&gt; + =A0 =A0 seq_putc(m, &#39;\n&#39;);<br>
&gt; +<br>
&gt; + =A0 =A0 unevictable_nr =3D mem_cgroup_nr_unevictable_lru_pages(mem_c=
ont);<br>
&gt; + =A0 =A0 seq_printf(m, &quot;unevictable=3D%lu&quot;, unevictable_nr)=
;<br>
&gt; + =A0 =A0 for_each_node_state(nid, N_HIGH_MEMORY) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 node_nr =3D mem_cgroup_node_nr_unevictable_l=
ru_pages(mem_cont,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nid);<b=
r>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 seq_printf(m, &quot; N%d=3D%lu&quot;, nid, n=
ode_nr);<br>
&gt; + =A0 =A0 }<br>
&gt; + =A0 =A0 seq_putc(m, &#39;\n&#39;);<br>
&gt; + =A0 =A0 return 0;<br>
&gt; +}<br>
&gt; +#endif /* CONFIG_NUMA */<br>
&gt; +<br>
&gt; =A0static int mem_control_stat_show(struct cgroup *cont, struct cftype=
 *cft,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct =
cgroup_map_cb *cb)<br>
&gt; =A0{<br>
&gt; @@ -4058,6 +4190,7 @@ static int mem_control_stat_show(struct cgroup *=
cont, struct cftype *cft,<br>
&gt; =A0 =A0 =A0 memset(&amp;mystat, 0, sizeof(mystat));<br>
&gt; =A0 =A0 =A0 mem_cgroup_get_local_stat(mem_cont, &amp;mystat);<br>
&gt;<br>
&gt; +<br>
&gt; =A0 =A0 =A0 for (i =3D 0; i &lt; NR_MCS_STAT; i++) {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (i =3D=3D MCS_SWAP &amp;&amp; !do_swap_=
account)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;<br>
&gt; @@ -4481,6 +4614,22 @@ static int mem_cgroup_oom_control_write(struct =
cgroup *cgrp,<br>
&gt; =A0 =A0 =A0 return 0;<br>
&gt; =A0}<br>
&gt;<br>
&gt; +#ifdef CONFIG_NUMA<br>
&gt; +static const struct file_operations mem_control_numa_stat_file_operat=
ions =3D {<br>
&gt; + =A0 =A0 .read =3D seq_read,<br>
&gt; + =A0 =A0 .llseek =3D seq_lseek,<br>
&gt; + =A0 =A0 .release =3D single_release,<br>
&gt; +};<br>
&gt; +<br>
<br>
</div></div>Do we need this?<br>
<div class=3D"im"><br>
<br>
&gt; +static int mem_control_numa_stat_open(struct inode *unused, struct fi=
le *file)<br>
&gt; +{<br>
&gt; + =A0 =A0 struct cgroup *cont =3D file-&gt;f_dentry-&gt;d_parent-&gt;d=
_fsdata;<br>
&gt; +<br>
&gt; + =A0 =A0 file-&gt;f_op =3D &amp;mem_control_numa_stat_file_operations=
;<br>
&gt; + =A0 =A0 return single_open(file, mem_control_numa_stat_show, cont);<=
br>
&gt; +}<br>
&gt; +#endif /* CONFIG_NUMA */<br>
&gt; +<br>
&gt; =A0static struct cftype mem_cgroup_files[] =3D {<br>
&gt; =A0 =A0 =A0 {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D &quot;usage_in_bytes&quot;,<br>
&gt; @@ -4544,6 +4693,12 @@ static struct cftype mem_cgroup_files[] =3D {<b=
r>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 .unregister_event =3D mem_cgroup_oom_unreg=
ister_event,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 .private =3D MEMFILE_PRIVATE(_OOM_TYPE, OO=
M_CONTROL),<br>
&gt; =A0 =A0 =A0 },<br>
&gt; +#ifdef CONFIG_NUMA<br>
&gt; + =A0 =A0 {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .name =3D &quot;numa_stat&quot;,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .open =3D mem_control_numa_stat_open,<br>
&gt; + =A0 =A0 },<br>
&gt; +#endif<br>
<br>
</div>Can&#39;t we do this the way we do the stats file? Please see<br>
mem_control_stat_show().<br></blockquote><div><br></div><div>I looked that =
earlier but can not get the formating working as well as the seq_*. Is ther=
e a particular reason we prefer one than the other?</div><div><br></div>
<div>Thanks=A0</div><div>--Ying</div><div>=A0</div><blockquote class=3D"gma=
il_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-lef=
t:1ex;">
<div class=3D"im"><br>
&gt; =A0};<br>
&gt;<br>
&gt; =A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP<br>
&gt; --<br>
&gt; 1.7.3.1<br>
&gt;<br>
<br>
</div>--<br>
 =A0 =A0 =A0 =A0Three Cheers,<br>
<font color=3D"#888888"> =A0 =A0 =A0 =A0Balbir<br>
</font><div><div></div><div class=3D"h5"><br>
--<br>
To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<br>
the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org</a>.=
 =A0For more info on Linux MM,<br>
see: <a href=3D"http://www.linux-mm.org/" target=3D"_blank">http://www.linu=
x-mm.org/</a> .<br>
Fight unfair telecom internet charges in Canada: sign <a href=3D"http://sto=
pthemeter.ca/" target=3D"_blank">http://stopthemeter.ca/</a><br>
Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvack.org=
">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">email@kva=
ck.org</a> &lt;/a&gt;<br>
</div></div></blockquote></div><br>

--002354470aa8d6acf304a40871fc--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
