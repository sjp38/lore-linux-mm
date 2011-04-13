Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 262CA900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 17:20:39 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id p3DLKNTC015667
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 14:20:23 -0700
Received: from qwc9 (qwc9.prod.google.com [10.241.193.137])
	by hpaq12.eem.corp.google.com with ESMTP id p3DLJnZj020026
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 14:20:22 -0700
Received: by qwc9 with SMTP id 9so1006966qwc.27
        for <linux-mm@kvack.org>; Wed, 13 Apr 2011 14:20:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110413180520.dc7ce1d4.kamezawa.hiroyu@jp.fujitsu.com>
References: <1302678187-24154-1-git-send-email-yinghan@google.com>
	<1302678187-24154-7-git-send-email-yinghan@google.com>
	<20110413180520.dc7ce1d4.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 13 Apr 2011 14:20:22 -0700
Message-ID: <BANLkTikdF+xjSBAk-5zptYH5mUpG2f=5Kw@mail.gmail.com>
Subject: Re: [PATCH V3 6/7] Enable per-memcg background reclaim.
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0cdfd0825d576a04a0d360c7
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Pavel Emelyanov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org

--000e0cdfd0825d576a04a0d360c7
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Apr 13, 2011 at 2:05 AM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 13 Apr 2011 00:03:06 -0700
> Ying Han <yinghan@google.com> wrote:
>
> > By default the per-memcg background reclaim is disabled when the
> limit_in_bytes
> > is set the maximum or the wmark_ratio is 0. The kswapd_run() is called
> when the
> > memcg is being resized, and kswapd_stop() is called when the memcg is
> being
> > deleted.
> >
> > The per-memcg kswapd is waked up based on the usage and low_wmark, which
> is
> > checked once per 1024 increments per cpu. The memcg's kswapd is waked up
> if the
> > usage is larger than the low_wmark.
> >
> > changelog v3..v2:
> > 1. some clean-ups
> >
> > changelog v2..v1:
> > 1. start/stop the per-cgroup kswapd at create/delete cgroup stage.
> > 2. remove checking the wmark from per-page charging. now it checks the
> wmark
> > periodically based on the event counter.
> >
> > Signed-off-by: Ying Han <yinghan@google.com>
>
> This event logic seems to make sense.
>
> > ---
> >  mm/memcontrol.c |   37 +++++++++++++++++++++++++++++++++++++
> >  1 files changed, 37 insertions(+), 0 deletions(-)
> >
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index efeade3..bfa8646 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -105,10 +105,12 @@ enum mem_cgroup_events_index {
> >  enum mem_cgroup_events_target {
> >       MEM_CGROUP_TARGET_THRESH,
> >       MEM_CGROUP_TARGET_SOFTLIMIT,
> > +     MEM_CGROUP_WMARK_EVENTS_THRESH,
> >       MEM_CGROUP_NTARGETS,
> >  };
> >  #define THRESHOLDS_EVENTS_TARGET (128)
> >  #define SOFTLIMIT_EVENTS_TARGET (1024)
> > +#define WMARK_EVENTS_TARGET (1024)
> >
> >  struct mem_cgroup_stat_cpu {
> >       long count[MEM_CGROUP_STAT_NSTATS];
> > @@ -366,6 +368,7 @@ static void mem_cgroup_put(struct mem_cgroup *mem);
> >  static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
> >  static void drain_all_stock_async(void);
> >  static unsigned long get_wmark_ratio(struct mem_cgroup *mem);
> > +static void wake_memcg_kswapd(struct mem_cgroup *mem);
> >
> >  static struct mem_cgroup_per_zone *
> >  mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
> > @@ -545,6 +548,12 @@ mem_cgroup_largest_soft_limit_node(struct
> mem_cgroup_tree_per_zone *mctz)
> >       return mz;
> >  }
> >
> > +static void mem_cgroup_check_wmark(struct mem_cgroup *mem)
> > +{
> > +     if (!mem_cgroup_watermark_ok(mem, CHARGE_WMARK_LOW))
> > +             wake_memcg_kswapd(mem);
> > +}
> > +
> >  /*
> >   * Implementation Note: reading percpu statistics for memcg.
> >   *
> > @@ -675,6 +684,9 @@ static void __mem_cgroup_target_update(struct
> mem_cgroup *mem, int target)
> >       case MEM_CGROUP_TARGET_SOFTLIMIT:
> >               next = val + SOFTLIMIT_EVENTS_TARGET;
> >               break;
> > +     case MEM_CGROUP_WMARK_EVENTS_THRESH:
> > +             next = val + WMARK_EVENTS_TARGET;
> > +             break;
> >       default:
> >               return;
> >       }
> > @@ -698,6 +710,10 @@ static void memcg_check_events(struct mem_cgroup
> *mem, struct page *page)
> >                       __mem_cgroup_target_update(mem,
> >                               MEM_CGROUP_TARGET_SOFTLIMIT);
> >               }
> > +             if (unlikely(__memcg_event_check(mem,
> > +                     MEM_CGROUP_WMARK_EVENTS_THRESH))){
> > +                     mem_cgroup_check_wmark(mem);
> > +             }
> >       }
> >  }
> >
> > @@ -3384,6 +3400,10 @@ static int mem_cgroup_resize_limit(struct
> mem_cgroup *memcg,
> >       if (!ret && enlarge)
> >               memcg_oom_recover(memcg);
> >
> > +     if (!mem_cgroup_is_root(memcg) && !memcg->kswapd_wait &&
> > +                     memcg->wmark_ratio)
> > +             kswapd_run(0, memcg);
> > +
>
> Isn't it enough to have trigger in charge() path ?
>

why? kswapd_run() is to create the kswapd thread for the memcg. If the
memcg's limit doesn't change from the initial value, we don't want to create
a kswapd thread for it. Only if the limit_in_byte is being changed. Adding
the hook in the charge path sounds too much overhead to the hotpath.

However, I might need to add checks here, where if the limit_in_byte is set
to RESOURCE_MAX.

>
> rather than here, I think we should check _move_task(). It changes res
> usage
> dramatically without updating events.
>

I see both the mem_cgroup_charge_statistics() and memcg_check_events()  are
being called in mem_cgroup_move_account(). Am i missing anything here?


Thanks
--Ying



>
> Thanks,
> -Kame
>
>
> >       return ret;
> >  }
> >
> > @@ -4680,6 +4700,7 @@ static void __mem_cgroup_free(struct mem_cgroup
> *mem)
> >  {
> >       int node;
> >
> > +     kswapd_stop(0, mem);
> >       mem_cgroup_remove_from_trees(mem);
> >       free_css_id(&mem_cgroup_subsys, &mem->css);
> >
>
> I think kswapd should stop at mem_cgroup_destroy(). No more tasks will use
> this memcg after _destroy().
>

I made the change.

>
> Thanks,
> -Kame
>
>
>
> > @@ -4786,6 +4807,22 @@ int mem_cgroup_last_scanned_node(struct mem_cgroup
> *mem)
> >       return mem->last_scanned_node;
> >  }
> >
> > +static inline
> > +void wake_memcg_kswapd(struct mem_cgroup *mem)
> > +{
> > +     wait_queue_head_t *wait;
> > +
> > +     if (!mem || !mem->wmark_ratio)
> > +             return;
> > +
> > +     wait = mem->kswapd_wait;
> > +
> > +     if (!wait || !waitqueue_active(wait))
> > +             return;
> > +
> > +     wake_up_interruptible(wait);
> > +}
> > +
> >  static int mem_cgroup_soft_limit_tree_init(void)
> >  {
> >       struct mem_cgroup_tree_per_node *rtpn;
> > --
> > 1.7.3.1
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Fight unfair telecom internet charges in Canada: sign
> http://stopthemeter.ca/
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >
>
>

--000e0cdfd0825d576a04a0d360c7
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Wed, Apr 13, 2011 at 2:05 AM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
<div class=3D"im">On Wed, 13 Apr 2011 00:03:06 -0700<br>
Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google.com</a>&g=
t; wrote:<br>
<br>
&gt; By default the per-memcg background reclaim is disabled when the limit=
_in_bytes<br>
&gt; is set the maximum or the wmark_ratio is 0. The kswapd_run() is called=
 when the<br>
&gt; memcg is being resized, and kswapd_stop() is called when the memcg is =
being<br>
&gt; deleted.<br>
&gt;<br>
&gt; The per-memcg kswapd is waked up based on the usage and low_wmark, whi=
ch is<br>
&gt; checked once per 1024 increments per cpu. The memcg&#39;s kswapd is wa=
ked up if the<br>
&gt; usage is larger than the low_wmark.<br>
&gt;<br>
&gt; changelog v3..v2:<br>
&gt; 1. some clean-ups<br>
&gt;<br>
&gt; changelog v2..v1:<br>
&gt; 1. start/stop the per-cgroup kswapd at create/delete cgroup stage.<br>
&gt; 2. remove checking the wmark from per-page charging. now it checks the=
 wmark<br>
&gt; periodically based on the event counter.<br>
&gt;<br>
&gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com">ying=
han@google.com</a>&gt;<br>
<br>
</div>This event logic seems to make sense.<br>
<div><div></div><div class=3D"h5"><br>
&gt; ---<br>
&gt; =A0mm/memcontrol.c | =A0 37 +++++++++++++++++++++++++++++++++++++<br>
&gt; =A01 files changed, 37 insertions(+), 0 deletions(-)<br>
&gt;<br>
&gt; diff --git a/mm/memcontrol.c b/mm/memcontrol.c<br>
&gt; index efeade3..bfa8646 100644<br>
&gt; --- a/mm/memcontrol.c<br>
&gt; +++ b/mm/memcontrol.c<br>
&gt; @@ -105,10 +105,12 @@ enum mem_cgroup_events_index {<br>
&gt; =A0enum mem_cgroup_events_target {<br>
&gt; =A0 =A0 =A0 MEM_CGROUP_TARGET_THRESH,<br>
&gt; =A0 =A0 =A0 MEM_CGROUP_TARGET_SOFTLIMIT,<br>
&gt; + =A0 =A0 MEM_CGROUP_WMARK_EVENTS_THRESH,<br>
&gt; =A0 =A0 =A0 MEM_CGROUP_NTARGETS,<br>
&gt; =A0};<br>
&gt; =A0#define THRESHOLDS_EVENTS_TARGET (128)<br>
&gt; =A0#define SOFTLIMIT_EVENTS_TARGET (1024)<br>
&gt; +#define WMARK_EVENTS_TARGET (1024)<br>
&gt;<br>
&gt; =A0struct mem_cgroup_stat_cpu {<br>
&gt; =A0 =A0 =A0 long count[MEM_CGROUP_STAT_NSTATS];<br>
&gt; @@ -366,6 +368,7 @@ static void mem_cgroup_put(struct mem_cgroup *mem)=
;<br>
&gt; =A0static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem)=
;<br>
&gt; =A0static void drain_all_stock_async(void);<br>
&gt; =A0static unsigned long get_wmark_ratio(struct mem_cgroup *mem);<br>
&gt; +static void wake_memcg_kswapd(struct mem_cgroup *mem);<br>
&gt;<br>
&gt; =A0static struct mem_cgroup_per_zone *<br>
&gt; =A0mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)<br>
&gt; @@ -545,6 +548,12 @@ mem_cgroup_largest_soft_limit_node(struct mem_cgr=
oup_tree_per_zone *mctz)<br>
&gt; =A0 =A0 =A0 return mz;<br>
&gt; =A0}<br>
&gt;<br>
&gt; +static void mem_cgroup_check_wmark(struct mem_cgroup *mem)<br>
&gt; +{<br>
&gt; + =A0 =A0 if (!mem_cgroup_watermark_ok(mem, CHARGE_WMARK_LOW))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 wake_memcg_kswapd(mem);<br>
&gt; +}<br>
&gt; +<br>
&gt; =A0/*<br>
&gt; =A0 * Implementation Note: reading percpu statistics for memcg.<br>
&gt; =A0 *<br>
&gt; @@ -675,6 +684,9 @@ static void __mem_cgroup_target_update(struct mem_=
cgroup *mem, int target)<br>
&gt; =A0 =A0 =A0 case MEM_CGROUP_TARGET_SOFTLIMIT:<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 next =3D val + SOFTLIMIT_EVENTS_TARGET;<br=
>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
&gt; + =A0 =A0 case MEM_CGROUP_WMARK_EVENTS_THRESH:<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 next =3D val + WMARK_EVENTS_TARGET;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
&gt; =A0 =A0 =A0 default:<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
&gt; =A0 =A0 =A0 }<br>
&gt; @@ -698,6 +710,10 @@ static void memcg_check_events(struct mem_cgroup =
*mem, struct page *page)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __mem_cgroup_target_update=
(mem,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MEM_CGROUP=
_TARGET_SOFTLIMIT);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(__memcg_event_check(mem,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MEM_CGROUP_WMARK_EVENTS_THRE=
SH))){<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_check_wmark(mem);=
<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; =A0 =A0 =A0 }<br>
&gt; =A0}<br>
&gt;<br>
&gt; @@ -3384,6 +3400,10 @@ static int mem_cgroup_resize_limit(struct mem_c=
group *memcg,<br>
&gt; =A0 =A0 =A0 if (!ret &amp;&amp; enlarge)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg_oom_recover(memcg);<br>
&gt;<br>
&gt; + =A0 =A0 if (!mem_cgroup_is_root(memcg) &amp;&amp; !memcg-&gt;kswapd_=
wait &amp;&amp;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg-&gt;wmark_ratio)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 kswapd_run(0, memcg);<br>
&gt; +<br>
<br>
</div></div>Isn&#39;t it enough to have trigger in charge() path ?<br></blo=
ckquote><div><br></div><div>why? kswapd_run() is to create the kswapd threa=
d for the memcg. If the memcg&#39;s limit doesn&#39;t change from the initi=
al value, we don&#39;t want to create a kswapd thread for it. Only if the l=
imit_in_byte is being changed. Adding the hook in the charge path sounds to=
o much overhead to the hotpath.</div>
<div><br></div><div>However, I might need to add checks here, where if the =
limit_in_byte is set to=A0RESOURCE_MAX.</div><blockquote class=3D"gmail_quo=
te" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;=
">

<br>
rather than here, I think we should check _move_task(). It changes res usag=
e<br>
dramatically without updating events.<br></blockquote><div><br></div><div>I=
 see both the mem_cgroup_charge_statistics() and=A0memcg_check_events() =A0=
are being called in mem_cgroup_move_account(). Am i missing anything here?<=
/div>
<div><br></div><div><br></div><div>Thanks</div><div>--Ying</div><div><br></=
div><div>=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .=
8ex;border-left:1px #ccc solid;padding-left:1ex;">
<br>
Thanks,<br>
-Kame<br>
<div class=3D"im"><br>
<br>
&gt; =A0 =A0 =A0 return ret;<br>
&gt; =A0}<br>
&gt;<br>
&gt; @@ -4680,6 +4700,7 @@ static void __mem_cgroup_free(struct mem_cgroup =
*mem)<br>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 int node;<br>
&gt;<br>
&gt; + =A0 =A0 kswapd_stop(0, mem);<br>
&gt; =A0 =A0 =A0 mem_cgroup_remove_from_trees(mem);<br>
&gt; =A0 =A0 =A0 free_css_id(&amp;mem_cgroup_subsys, &amp;mem-&gt;css);<br>
&gt;<br>
<br>
</div>I think kswapd should stop at mem_cgroup_destroy(). No more tasks wil=
l use<br>
this memcg after _destroy().<br></blockquote><div><br></div><div>I made the=
 change.=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8=
ex;border-left:1px #ccc solid;padding-left:1ex;">
<br>
Thanks,<br>
-Kame<br>
<div class=3D"im"><br>
<br>
<br>
&gt; @@ -4786,6 +4807,22 @@ int mem_cgroup_last_scanned_node(struct mem_cgr=
oup *mem)<br>
&gt; =A0 =A0 =A0 return mem-&gt;last_scanned_node;<br>
&gt; =A0}<br>
&gt;<br>
&gt; +static inline<br>
&gt; +void wake_memcg_kswapd(struct mem_cgroup *mem)<br>
&gt; +{<br>
&gt; + =A0 =A0 wait_queue_head_t *wait;<br>
&gt; +<br>
&gt; + =A0 =A0 if (!mem || !mem-&gt;wmark_ratio)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
&gt; +<br>
&gt; + =A0 =A0 wait =3D mem-&gt;kswapd_wait;<br>
&gt; +<br>
&gt; + =A0 =A0 if (!wait || !waitqueue_active(wait))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
&gt; +<br>
&gt; + =A0 =A0 wake_up_interruptible(wait);<br>
&gt; +}<br>
&gt; +<br>
&gt; =A0static int mem_cgroup_soft_limit_tree_init(void)<br>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 struct mem_cgroup_tree_per_node *rtpn;<br>
&gt; --<br>
&gt; 1.7.3.1<br>
&gt;<br>
</div>&gt; --<br>
&gt; To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<=
br>
&gt; the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org=
</a>. =A0For more info on Linux MM,<br>
&gt; see: <a href=3D"http://www.linux-mm.org/" target=3D"_blank">http://www=
.linux-mm.org/</a> .<br>
&gt; Fight unfair telecom internet charges in Canada: sign <a href=3D"http:=
//stopthemeter.ca/" target=3D"_blank">http://stopthemeter.ca/</a><br>
&gt; Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvac=
k.org">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">emai=
l@kvack.org</a> &lt;/a&gt;<br>
&gt;<br>
<br>
</blockquote></div><br>

--000e0cdfd0825d576a04a0d360c7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
