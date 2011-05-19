Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id BACCE6B0011
	for <linux-mm@kvack.org>; Thu, 19 May 2011 11:52:40 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id p4JFqOV7013269
	for <linux-mm@kvack.org>; Thu, 19 May 2011 08:52:24 -0700
Received: from qwe5 (qwe5.prod.google.com [10.241.194.5])
	by hpaq5.eem.corp.google.com with ESMTP id p4JFprrp005546
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 19 May 2011 08:52:23 -0700
Received: by qwe5 with SMTP id 5so1499510qwe.9
        for <linux-mm@kvack.org>; Thu, 19 May 2011 08:52:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110519152206.1dac20af.nishimura@mxp.nes.nec.co.jp>
References: <1305766511-11469-1-git-send-email-yinghan@google.com>
	<1305766511-11469-2-git-send-email-yinghan@google.com>
	<20110519152206.1dac20af.nishimura@mxp.nes.nec.co.jp>
Date: Thu, 19 May 2011 08:23:47 -0700
Message-ID: <BANLkTimMGu7b2Ke1+TQCfzCH6qu9CREsDg@mail.gmail.com>
Subject: Re: [PATCH V2 2/2] memcg: add memory.numastat api for numa statistics
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=20cf302efce277c12c04a3a297fe
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--20cf302efce277c12c04a3a297fe
Content-Type: text/plain; charset=ISO-8859-1

On Wed, May 18, 2011 at 11:22 PM, Daisuke Nishimura <
nishimura@mxp.nes.nec.co.jp> wrote:

> On Wed, 18 May 2011 17:55:11 -0700
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
> > total=317674 N0=101850 N1=72552 N2=30120 N3=113142
> > file=288219 N0=98046 N1=59220 N2=23578 N3=107375
> > anon=25699 N0=3804 N1=10124 N2=6540 N3=5231
> >
> > Note: I noticed <total pages> is not equal to the sum of the rest of
> counters.
> > I might need to change the way get that counter, comments are welcomed.
> >
> Isn't it just because <total pages>(mem_cgroup_local_usage()) includes
> pages
> which are not on any LRU, while other counters doesn't ?
>

Yes, i noticed that also and I am preparing for the next post :)

>
> > change v2..v1:
> > 1. add also the file and anon pages on per-node distribution.
> >
> > Signed-off-by: Ying Han <yinghan@google.com>
> > ---
> >  mm/memcontrol.c |  109
> +++++++++++++++++++++++++++++++++++++++++++++++++++++++
> >  1 files changed, 109 insertions(+), 0 deletions(-)
> >
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index da183dc..cffc3a6 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1162,6 +1162,62 @@ unsigned long mem_cgroup_zone_nr_lru_pages(struct
> mem_cgroup *memcg,
> >       return MEM_CGROUP_ZSTAT(mz, lru);
> >  }
> >
> > +unsigned long mem_cgroup_node_nr_file_pages(struct mem_cgroup *memcg,
> int nid)
> > +{
> > +     unsigned long ret;
> > +
> > +     ret = mem_cgroup_get_zonestat_node(memcg, nid, LRU_INACTIVE_FILE) +
> > +             mem_cgroup_get_zonestat_node(memcg, nid, LRU_ACTIVE_FILE);
> > +
> > +     return ret;
> > +}
> > +
> > +unsigned long mem_cgroup_node_nr_anon_pages(struct mem_cgroup *memcg,
> int nid)
> > +{
> > +     unsigned long ret;
> > +
> > +     ret = mem_cgroup_get_zonestat_node(memcg, nid, LRU_INACTIVE_ANON) +
> > +             mem_cgroup_get_zonestat_node(memcg, nid, LRU_ACTIVE_ANON);
> > +
> > +     return ret;
> > +}
> > +
> > +unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
> > +                                             int nid, bool file)
> > +{
> > +     if (file)
> > +             return mem_cgroup_node_nr_file_pages(memcg, nid);
> > +     else
> > +             return mem_cgroup_node_nr_anon_pages(memcg, nid);
> > +}
> > +
> > +unsigned long mem_cgroup_nr_lru_pages(struct mem_cgroup *memcg, bool
> file)
> > +{
> > +     u64 total = 0;
> > +     int nid;
> > +
> > +     for_each_node_state(nid, N_HIGH_MEMORY)
> > +             total += mem_cgroup_node_nr_lru_pages(memcg, nid, file);
> > +
> > +     return total;
> > +}
> > +
> Can these functions defined as "static" ?
>



>
> > +unsigned long mem_cgroup_node_nr_pages(struct mem_cgroup *memcg, int
> nid)
> > +{
> > +     int zid;
> > +     struct mem_cgroup_per_zone *mz;
> > +     enum lru_list l;
> > +     u64 total = 0;
> > +
> > +     for (zid = 0; zid < MAX_NR_ZONES; zid++) {
> > +             mz = mem_cgroup_zoneinfo(memcg, nid, zid);
> > +             for_each_lru(l)
> > +                     total += MEM_CGROUP_ZSTAT(mz, l);
> > +     }
> > +
> > +     return total;
> > +}
> > +
> ditto.
> And I think this function can be implemented by using
> mem_cgroup_get_zonestat_node().
>
>        for_each_lru(l)
>                total += mem_cgroup_get_zonestat_node(memcg, nid, l);
>
> As KAMEZAWA-san posted a fix already, mem_cgroup_get_zonestat_node() must
> be fixed first.
>
>
> Yes, I can include that in the patchset.

Thanks

--Ying


> Thanks,
> Daisuke Nishimura.
>
> >  struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup
> *memcg,
> >                                                     struct zone *zone)
> >  {
> > @@ -4048,6 +4104,41 @@ mem_cgroup_get_total_stat(struct mem_cgroup *mem,
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
> > +     total_nr = mem_cgroup_local_usage(mem_cont);
> > +     seq_printf(m, "total=%lu", total_nr);
> > +     for_each_node_state(nid, N_HIGH_MEMORY) {
> > +             node_nr = mem_cgroup_node_nr_pages(mem_cont, nid);
> > +             seq_printf(m, " N%d=%lu", nid, node_nr);
> > +     }
> > +     seq_putc(m, '\n');
> > +
> > +     file_nr = mem_cgroup_nr_lru_pages(mem_cont, 1);
> > +     seq_printf(m, "file=%lu", file_nr);
> > +     for_each_node_state(nid, N_HIGH_MEMORY) {
> > +             node_nr = mem_cgroup_node_nr_lru_pages(mem_cont, nid, 1);
> > +             seq_printf(m, " N%d=%lu", nid, node_nr);
> > +     }
> > +     seq_putc(m, '\n');
> > +
> > +     anon_nr = mem_cgroup_nr_lru_pages(mem_cont, 0);
> > +     seq_printf(m, "anon=%lu", anon_nr);
> > +     for_each_node_state(nid, N_HIGH_MEMORY) {
> > +             node_nr = mem_cgroup_node_nr_lru_pages(mem_cont, nid, 0);
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
> > @@ -4481,6 +4572,20 @@ static int mem_cgroup_oom_control_write(struct
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
> > @@ -4544,6 +4649,10 @@ static struct cftype mem_cgroup_files[] = {
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
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign
> http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--20cf302efce277c12c04a3a297fe
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Wed, May 18, 2011 at 11:22 PM, Daisuk=
e Nishimura <span dir=3D"ltr">&lt;<a href=3D"mailto:nishimura@mxp.nes.nec.c=
o.jp">nishimura@mxp.nes.nec.co.jp</a>&gt;</span> wrote:<br><blockquote clas=
s=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;pad=
ding-left:1ex;">
<div class=3D"im">On Wed, 18 May 2011 17:55:11 -0700<br>
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
&gt; total=3D317674 N0=3D101850 N1=3D72552 N2=3D30120 N3=3D113142<br>
&gt; file=3D288219 N0=3D98046 N1=3D59220 N2=3D23578 N3=3D107375<br>
&gt; anon=3D25699 N0=3D3804 N1=3D10124 N2=3D6540 N3=3D5231<br>
&gt;<br>
&gt; Note: I noticed &lt;total pages&gt; is not equal to the sum of the res=
t of counters.<br>
&gt; I might need to change the way get that counter, comments are welcomed=
.<br>
&gt;<br>
</div>Isn&#39;t it just because &lt;total pages&gt;(mem_cgroup_local_usage(=
)) includes pages<br>
which are not on any LRU, while other counters doesn&#39;t ?<br></blockquot=
e><div><br></div><div>Yes, i noticed that also and I am preparing for the n=
ext post :)=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0=
 .8ex;border-left:1px #ccc solid;padding-left:1ex;">

<div><div></div><div class=3D"h5"><br>
&gt; change v2..v1:<br>
&gt; 1. add also the file and anon pages on per-node distribution.<br>
&gt;<br>
&gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com">ying=
han@google.com</a>&gt;<br>
&gt; ---<br>
&gt; =A0mm/memcontrol.c | =A0109 ++++++++++++++++++++++++++++++++++++++++++=
+++++++++++++<br>
&gt; =A01 files changed, 109 insertions(+), 0 deletions(-)<br>
&gt;<br>
&gt; diff --git a/mm/memcontrol.c b/mm/memcontrol.c<br>
&gt; index da183dc..cffc3a6 100644<br>
&gt; --- a/mm/memcontrol.c<br>
&gt; +++ b/mm/memcontrol.c<br>
&gt; @@ -1162,6 +1162,62 @@ unsigned long mem_cgroup_zone_nr_lru_pages(stru=
ct mem_cgroup *memcg,<br>
&gt; =A0 =A0 =A0 return MEM_CGROUP_ZSTAT(mz, lru);<br>
&gt; =A0}<br>
&gt;<br>
&gt; +unsigned long mem_cgroup_node_nr_file_pages(struct mem_cgroup *memcg,=
 int nid)<br>
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
&gt; +unsigned long mem_cgroup_node_nr_anon_pages(struct mem_cgroup *memcg,=
 int nid)<br>
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
&gt; +unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,<=
br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 int nid, bool file)<br>
&gt; +{<br>
&gt; + =A0 =A0 if (file)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return mem_cgroup_node_nr_file_pages(memcg, =
nid);<br>
&gt; + =A0 =A0 else<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return mem_cgroup_node_nr_anon_pages(memcg, =
nid);<br>
&gt; +}<br>
&gt; +<br>
&gt; +unsigned long mem_cgroup_nr_lru_pages(struct mem_cgroup *memcg, bool =
file)<br>
&gt; +{<br>
&gt; + =A0 =A0 u64 total =3D 0;<br>
&gt; + =A0 =A0 int nid;<br>
&gt; +<br>
&gt; + =A0 =A0 for_each_node_state(nid, N_HIGH_MEMORY)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 total +=3D mem_cgroup_node_nr_lru_pages(memc=
g, nid, file);<br>
&gt; +<br>
&gt; + =A0 =A0 return total;<br>
&gt; +}<br>
&gt; +<br>
</div></div>Can these functions defined as &quot;static&quot; ?<br></blockq=
uote><div><br></div><div>=A0</div><blockquote class=3D"gmail_quote" style=
=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im"><br>
&gt; +unsigned long mem_cgroup_node_nr_pages(struct mem_cgroup *memcg, int =
nid)<br>
&gt; +{<br>
&gt; + =A0 =A0 int zid;<br>
&gt; + =A0 =A0 struct mem_cgroup_per_zone *mz;<br>
&gt; + =A0 =A0 enum lru_list l;<br>
&gt; + =A0 =A0 u64 total =3D 0;<br>
&gt; +<br>
&gt; + =A0 =A0 for (zid =3D 0; zid &lt; MAX_NR_ZONES; zid++) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 mz =3D mem_cgroup_zoneinfo(memcg, nid, zid);=
<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 for_each_lru(l)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total +=3D MEM_CGROUP_ZSTAT(=
mz, l);<br>
&gt; + =A0 =A0 }<br>
&gt; +<br>
&gt; + =A0 =A0 return total;<br>
&gt; +}<br>
&gt; +<br>
</div>ditto.<br>
And I think this function can be implemented by using mem_cgroup_get_zonest=
at_node().<br>
<br>
 =A0 =A0 =A0 =A0for_each_lru(l)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0total +=3D mem_cgroup_get_zonestat_node(mem=
cg, nid, l);<br>
<br>
As KAMEZAWA-san posted a fix already, mem_cgroup_get_zonestat_node() must b=
e fixed first.<br>
<br>
<br></blockquote><div>Yes, I can include that in the patchset.</div><div><b=
r></div><div>Thanks</div><div><br></div><div>--Ying</div><div>=A0</div><blo=
ckquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #c=
cc solid;padding-left:1ex;">

Thanks,<br>
Daisuke Nishimura.<br>
<div><div></div><div class=3D"h5"><br>
&gt; =A0struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cg=
roup *memcg,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone)<br>
&gt; =A0{<br>
&gt; @@ -4048,6 +4104,41 @@ mem_cgroup_get_total_stat(struct mem_cgroup *me=
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
&gt; + =A0 =A0 total_nr =3D mem_cgroup_local_usage(mem_cont);<br>
&gt; + =A0 =A0 seq_printf(m, &quot;total=3D%lu&quot;, total_nr);<br>
&gt; + =A0 =A0 for_each_node_state(nid, N_HIGH_MEMORY) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 node_nr =3D mem_cgroup_node_nr_pages(mem_con=
t, nid);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 seq_printf(m, &quot; N%d=3D%lu&quot;, nid, n=
ode_nr);<br>
&gt; + =A0 =A0 }<br>
&gt; + =A0 =A0 seq_putc(m, &#39;\n&#39;);<br>
&gt; +<br>
&gt; + =A0 =A0 file_nr =3D mem_cgroup_nr_lru_pages(mem_cont, 1);<br>
&gt; + =A0 =A0 seq_printf(m, &quot;file=3D%lu&quot;, file_nr);<br>
&gt; + =A0 =A0 for_each_node_state(nid, N_HIGH_MEMORY) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 node_nr =3D mem_cgroup_node_nr_lru_pages(mem=
_cont, nid, 1);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 seq_printf(m, &quot; N%d=3D%lu&quot;, nid, n=
ode_nr);<br>
&gt; + =A0 =A0 }<br>
&gt; + =A0 =A0 seq_putc(m, &#39;\n&#39;);<br>
&gt; +<br>
&gt; + =A0 =A0 anon_nr =3D mem_cgroup_nr_lru_pages(mem_cont, 0);<br>
&gt; + =A0 =A0 seq_printf(m, &quot;anon=3D%lu&quot;, anon_nr);<br>
&gt; + =A0 =A0 for_each_node_state(nid, N_HIGH_MEMORY) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 node_nr =3D mem_cgroup_node_nr_lru_pages(mem=
_cont, nid, 0);<br>
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
&gt; @@ -4481,6 +4572,20 @@ static int mem_cgroup_oom_control_write(struct =
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
&gt; @@ -4544,6 +4649,10 @@ static struct cftype mem_cgroup_files[] =3D {<b=
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
<br>
</div></div><font color=3D"#888888">--<br>
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
</font></blockquote></div><br>

--20cf302efce277c12c04a3a297fe--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
