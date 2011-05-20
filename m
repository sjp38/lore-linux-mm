Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id CA22C6B0011
	for <linux-mm@kvack.org>; Thu, 19 May 2011 20:11:57 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id p4K0BqfB023108
	for <linux-mm@kvack.org>; Thu, 19 May 2011 17:11:53 -0700
Received: from qyk36 (qyk36.prod.google.com [10.241.83.164])
	by hpaq3.eem.corp.google.com with ESMTP id p4K0Bohw026850
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 19 May 2011 17:11:51 -0700
Received: by qyk36 with SMTP id 36so186qyk.4
        for <linux-mm@kvack.org>; Thu, 19 May 2011 17:11:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110520085152.e518ac71.kamezawa.hiroyu@jp.fujitsu.com>
References: <1305826360-2167-1-git-send-email-yinghan@google.com>
	<1305826360-2167-3-git-send-email-yinghan@google.com>
	<20110520085152.e518ac71.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 19 May 2011 17:11:49 -0700
Message-ID: <BANLkTincQttGR_o3Q6dxsq91+Ew12gYEOg@mail.gmail.com>
Subject: Re: [PATCH V3 3/3] memcg: add memory.numastat api for numa statistics
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=002354470aa8d8c18804a3a9f7f8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--002354470aa8d8c18804a3a9f7f8
Content-Type: text/plain; charset=ISO-8859-1

On Thu, May 19, 2011 at 4:51 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 19 May 2011 10:32:40 -0700
> Ying Han <yinghan@google.com> wrote:
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
> >
> > $ cat /dev/cgroup/memory/memory.numa_stat
> > total=246594 N0=18225 N1=72025 N2=26378 N3=129966
> > file=221728 N0=15030 N1=60804 N2=23238 N3=122656
> > anon=21120 N0=2937 N1=7733 N2=3140 N3=7310
> >
>
> Hmm ? this doesn't seem consistent....Isn't this log updated ?
>

Nope. This is the V3 i posted w/ updated testing result.

--Ying


>
> Thanks,
> -Kame
>
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
> > ---
> >  mm/memcontrol.c |  120
> +++++++++++++++++++++++++++++++++++++++++++++++++++++++
> >  1 files changed, 120 insertions(+), 0 deletions(-)
> >
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index e14677c..268d806 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1162,6 +1162,73 @@ unsigned long mem_cgroup_zone_nr_lru_pages(struct
> mem_cgroup *memcg,
> >       return MEM_CGROUP_ZSTAT(mz, lru);
> >  }
> >
> > +
> > +unsigned long mem_cgroup_node_nr_file_lru_pages(struct mem_cgroup
> *memcg,
> > +                                             int nid)
> > +{
> > +     unsigned long ret;
> > +
> > +     ret = mem_cgroup_get_zonestat_node(memcg, nid, LRU_INACTIVE_FILE) +
> > +             mem_cgroup_get_zonestat_node(memcg, nid, LRU_ACTIVE_FILE);
> > +
> > +     return ret;
> > +}
> > +
> > +unsigned long mem_cgroup_nr_file_lru_pages(struct mem_cgroup *memcg)
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
> > +unsigned long mem_cgroup_node_nr_anon_lru_pages(struct mem_cgroup
> *memcg,
> > +                                             int nid)
> > +{
> > +     unsigned long ret;
> > +
> > +     ret = mem_cgroup_get_zonestat_node(memcg, nid, LRU_INACTIVE_ANON) +
> > +             mem_cgroup_get_zonestat_node(memcg, nid, LRU_ACTIVE_ANON);
> > +
> > +     return ret;
> > +}
> > +
> > +unsigned long mem_cgroup_nr_anon_lru_pages(struct mem_cgroup *memcg)
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
> > +unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg, int
> nid)
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
> > +unsigned long mem_cgroup_nr_lru_pages(struct mem_cgroup *memcg)
> > +{
> > +     u64 total = 0;
> > +     int nid;
> > +
> > +     for_each_node_state(nid, N_HIGH_MEMORY)
> > +             total += mem_cgroup_node_nr_lru_pages(memcg, nid);
> > +
> > +     return total;
> > +}
> > +
> >  struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup
> *memcg,
> >                                                     struct zone *zone)
> >  {
> > @@ -4048,6 +4115,41 @@ mem_cgroup_get_total_stat(struct mem_cgroup *mem,
> struct mcs_total_stat *s)
> >               mem_cgroup_get_local_stat(iter, s);
> >  }
> >
> > +static int mem_control_numa_stat_show(struct seq_file *m, void *arg)
> > +{
> > +     int nid;
> > +     unsigned long total_nr, file_nr, anon_nr;
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
> > +     return 0;
> > +}
> > +
> >  static int mem_control_stat_show(struct cgroup *cont, struct cftype
> *cft,
> >                                struct cgroup_map_cb *cb)
> >  {
> > @@ -4481,6 +4583,20 @@ static int mem_cgroup_oom_control_write(struct
> cgroup *cgrp,
> >       return 0;
> >  }
> >
> > +static const struct file_operations
> mem_control_numa_stat_file_operations = {
> > +     .read = seq_read,
> > +     .llseek = seq_lseek,
> > +     .release = single_release,
> > +};
> > +
> > +static int mem_control_numa_stat_open(struct inode *unused, struct file
> *file)
> > +{
> > +     struct cgroup *cont = file->f_dentry->d_parent->d_fsdata;
> > +
> > +     file->f_op = &mem_control_numa_stat_file_operations;
> > +     return single_open(file, mem_control_numa_stat_show, cont);
> > +}
> > +
> >  static struct cftype mem_cgroup_files[] = {
> >       {
> >               .name = "usage_in_bytes",
> > @@ -4544,6 +4660,10 @@ static struct cftype mem_cgroup_files[] = {
> >               .unregister_event = mem_cgroup_oom_unregister_event,
> >               .private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
> >       },
> > +     {
> > +             .name = "numa_stat",
> > +             .open = mem_control_numa_stat_open,
> > +     },
> >  };
> >
> >  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> > --
> > 1.7.3.1
> >
> >
>
>

--002354470aa8d8c18804a3a9f7f8
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, May 19, 2011 at 4:51 PM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
<div class=3D"im">On Thu, 19 May 2011 10:32:40 -0700<br>
Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google.com</a>&g=
t; wrote:<br>
<br>
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
&gt;<br>
&gt; $ cat /dev/cgroup/memory/memory.numa_stat<br>
&gt; total=3D246594 N0=3D18225 N1=3D72025 N2=3D26378 N3=3D129966<br>
&gt; file=3D221728 N0=3D15030 N1=3D60804 N2=3D23238 N3=3D122656<br>
&gt; anon=3D21120 N0=3D2937 N1=3D7733 N2=3D3140 N3=3D7310<br>
&gt;<br>
<br>
</div>Hmm ? this doesn&#39;t seem consistent....Isn&#39;t this log updated =
?<br></blockquote><div><br></div><div>Nope. This is the V3 i posted w/ upda=
ted testing result.</div><div><br></div><div>--Ying</div><div>=A0</div><blo=
ckquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #c=
cc solid;padding-left:1ex;">

<br>
Thanks,<br>
-Kame<br>
<div><div></div><div class=3D"h5"><br>
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
&gt; ---<br>
&gt; =A0mm/memcontrol.c | =A0120 ++++++++++++++++++++++++++++++++++++++++++=
+++++++++++++<br>
&gt; =A01 files changed, 120 insertions(+), 0 deletions(-)<br>
&gt;<br>
&gt; diff --git a/mm/memcontrol.c b/mm/memcontrol.c<br>
&gt; index e14677c..268d806 100644<br>
&gt; --- a/mm/memcontrol.c<br>
&gt; +++ b/mm/memcontrol.c<br>
&gt; @@ -1162,6 +1162,73 @@ unsigned long mem_cgroup_zone_nr_lru_pages(stru=
ct mem_cgroup *memcg,<br>
&gt; =A0 =A0 =A0 return MEM_CGROUP_ZSTAT(mz, lru);<br>
&gt; =A0}<br>
&gt;<br>
&gt; +<br>
&gt; +unsigned long mem_cgroup_node_nr_file_lru_pages(struct mem_cgroup *me=
mcg,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 int nid)<br>
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
&gt; +unsigned long mem_cgroup_nr_file_lru_pages(struct mem_cgroup *memcg)<=
br>
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
&gt; +unsigned long mem_cgroup_node_nr_anon_lru_pages(struct mem_cgroup *me=
mcg,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 int nid)<br>
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
&gt; +unsigned long mem_cgroup_nr_anon_lru_pages(struct mem_cgroup *memcg)<=
br>
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
&gt; +unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg, =
int nid)<br>
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
&gt; +unsigned long mem_cgroup_nr_lru_pages(struct mem_cgroup *memcg)<br>
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
&gt; +<br>
&gt; =A0struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cg=
roup *memcg,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone)<br>
&gt; =A0{<br>
&gt; @@ -4048,6 +4115,41 @@ mem_cgroup_get_total_stat(struct mem_cgroup *me=
m, struct mcs_total_stat *s)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_get_local_stat(iter, s);<br>
&gt; =A0}<br>
&gt;<br>
&gt; +static int mem_control_numa_stat_show(struct seq_file *m, void *arg)<=
br>
&gt; +{<br>
&gt; + =A0 =A0 int nid;<br>
&gt; + =A0 =A0 unsigned long total_nr, file_nr, anon_nr;<br>
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
&gt; + =A0 =A0 return 0;<br>
&gt; +}<br>
&gt; +<br>
&gt; =A0static int mem_control_stat_show(struct cgroup *cont, struct cftype=
 *cft,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct =
cgroup_map_cb *cb)<br>
&gt; =A0{<br>
&gt; @@ -4481,6 +4583,20 @@ static int mem_cgroup_oom_control_write(struct =
cgroup *cgrp,<br>
&gt; =A0 =A0 =A0 return 0;<br>
&gt; =A0}<br>
&gt;<br>
&gt; +static const struct file_operations mem_control_numa_stat_file_operat=
ions =3D {<br>
&gt; + =A0 =A0 .read =3D seq_read,<br>
&gt; + =A0 =A0 .llseek =3D seq_lseek,<br>
&gt; + =A0 =A0 .release =3D single_release,<br>
&gt; +};<br>
&gt; +<br>
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
&gt; +<br>
&gt; =A0static struct cftype mem_cgroup_files[] =3D {<br>
&gt; =A0 =A0 =A0 {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D &quot;usage_in_bytes&quot;,<br>
&gt; @@ -4544,6 +4660,10 @@ static struct cftype mem_cgroup_files[] =3D {<b=
r>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 .unregister_event =3D mem_cgroup_oom_unreg=
ister_event,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 .private =3D MEMFILE_PRIVATE(_OOM_TYPE, OO=
M_CONTROL),<br>
&gt; =A0 =A0 =A0 },<br>
&gt; + =A0 =A0 {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .name =3D &quot;numa_stat&quot;,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .open =3D mem_control_numa_stat_open,<br>
&gt; + =A0 =A0 },<br>
&gt; =A0};<br>
&gt;<br>
&gt; =A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP<br>
&gt; --<br>
&gt; 1.7.3.1<br>
&gt;<br>
&gt;<br>
<br>
</div></div></blockquote></div><br>

--002354470aa8d8c18804a3a9f7f8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
