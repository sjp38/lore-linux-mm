Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1FED1900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 13:43:39 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id p3EHhZnP012069
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 10:43:35 -0700
Received: from gyf1 (gyf1.prod.google.com [10.243.50.65])
	by hpaq12.eem.corp.google.com with ESMTP id p3EHfdTV019822
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 10:43:34 -0700
Received: by gyf1 with SMTP id 1so592667gyf.6
        for <linux-mm@kvack.org>; Thu, 14 Apr 2011 10:43:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTimR+Tn+AccUt3dxqXhSVA8tUp_xDg@mail.gmail.com>
References: <1302678187-24154-1-git-send-email-yinghan@google.com>
	<1302678187-24154-3-git-send-email-yinghan@google.com>
	<BANLkTimR+Tn+AccUt3dxqXhSVA8tUp_xDg@mail.gmail.com>
Date: Thu, 14 Apr 2011 10:43:33 -0700
Message-ID: <BANLkTimmBpbRvs-7oyhQoP32kTJz4Pe6Lg@mail.gmail.com>
Subject: Re: [PATCH V3 2/7] Add per memcg reclaim watermarks
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0cd67698d27b0404a0e47639
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org

--000e0cd67698d27b0404a0e47639
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Apr 14, 2011 at 1:24 AM, Zhu Yanhai <zhu.yanhai@gmail.com> wrote:

> Hi Ying,
>
> 2011/4/13 Ying Han <yinghan@google.com>:
> > +static void setup_per_memcg_wmarks(struct mem_cgroup *mem)
> > +{
> > +       u64 limit;
> > +       unsigned long wmark_ratio;
> > +
> > +       wmark_ratio = get_wmark_ratio(mem);
> > +       limit = mem_cgroup_get_limit(mem);
>
> mem_cgroup_get_limit doesn't return the correct limit for you,
> actually it's only for OOM killer.
> You should use
> limit = res_counter_read_u64(&mem->res, RES_LIMIT) directly.
> Otherwise in the box which has swapon, you will get a huge
> number here.
> e.g.
>  [root@zyh-fedora a]# echo 500m > memory.limit_in_bytes
> [root@zyh-fedora a]# cat memory.limit_in_bytes
> 524288000
> [root@zyh-fedora a]# cat memory.reclaim_wmarks
> low_wmark 9114218496
> high_wmark 9114218496
>

thank you~ will fix it next post.

--Ying

>
> Regards,
> Zhu Yanhai
>
>
> > +       if (wmark_ratio == 0) {
> > +               res_counter_set_low_wmark_limit(&mem->res, limit);
> > +               res_counter_set_high_wmark_limit(&mem->res, limit);
> > +       } else {
> > +               unsigned long low_wmark, high_wmark;
> > +               unsigned long long tmp = (wmark_ratio * limit) / 100;
> > +
> > +               low_wmark = tmp;
> > +               high_wmark = tmp - (tmp >> 8);
> > +               res_counter_set_low_wmark_limit(&mem->res, low_wmark);
> > +               res_counter_set_high_wmark_limit(&mem->res, high_wmark);
> > +       }
> > +}
> > +
> >  /*
> >  * Following LRU functions are allowed to be used without PCG_LOCK.
> >  * Operations are called by routine of global LRU independently from
> memcg.
> > @@ -1195,6 +1219,16 @@ static unsigned int get_swappiness(struct
> mem_cgroup *memcg)
> >        return memcg->swappiness;
> >  }
> >
> > +static unsigned long get_wmark_ratio(struct mem_cgroup *memcg)
> > +{
> > +       struct cgroup *cgrp = memcg->css.cgroup;
> > +
> > +       VM_BUG_ON(!cgrp);
> > +       VM_BUG_ON(!cgrp->parent);
> > +
> > +       return memcg->wmark_ratio;
> > +}
> > +
> >  static void mem_cgroup_start_move(struct mem_cgroup *mem)
> >  {
> >        int cpu;
> > @@ -3205,6 +3239,7 @@ static int mem_cgroup_resize_limit(struct
> mem_cgroup *memcg,
> >                        else
> >                                memcg->memsw_is_minimum = false;
> >                }
> > +               setup_per_memcg_wmarks(memcg);
> >                mutex_unlock(&set_limit_mutex);
> >
> >                if (!ret)
> > @@ -3264,6 +3299,7 @@ static int mem_cgroup_resize_memsw_limit(struct
> mem_cgroup *memcg,
> >                        else
> >                                memcg->memsw_is_minimum = false;
> >                }
> > +               setup_per_memcg_wmarks(memcg);
> >                mutex_unlock(&set_limit_mutex);
> >
> >                if (!ret)
> > @@ -4521,6 +4557,22 @@ static void __init enable_swap_cgroup(void)
> >  }
> >  #endif
> >
> > +int mem_cgroup_watermark_ok(struct mem_cgroup *mem,
> > +                               int charge_flags)
> > +{
> > +       long ret = 0;
> > +       int flags = CHARGE_WMARK_LOW | CHARGE_WMARK_HIGH;
> > +
> > +       VM_BUG_ON((charge_flags & flags) == flags);
> > +
> > +       if (charge_flags & CHARGE_WMARK_LOW)
> > +               ret = res_counter_check_under_low_wmark_limit(&mem->res);
> > +       if (charge_flags & CHARGE_WMARK_HIGH)
> > +               ret =
> res_counter_check_under_high_wmark_limit(&mem->res);
> > +
> > +       return ret;
> > +}
> > +
> >  static int mem_cgroup_soft_limit_tree_init(void)
> >  {
> >        struct mem_cgroup_tree_per_node *rtpn;
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

--000e0cd67698d27b0404a0e47639
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, Apr 14, 2011 at 1:24 AM, Zhu Yan=
hai <span dir=3D"ltr">&lt;<a href=3D"mailto:zhu.yanhai@gmail.com">zhu.yanha=
i@gmail.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" styl=
e=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
Hi Ying,<br>
<br>
2011/4/13 Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google=
.com</a>&gt;:<br>
<div class=3D"im">&gt; +static void setup_per_memcg_wmarks(struct mem_cgrou=
p *mem)<br>
&gt; +{<br>
&gt; + =A0 =A0 =A0 u64 limit;<br>
&gt; + =A0 =A0 =A0 unsigned long wmark_ratio;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 wmark_ratio =3D get_wmark_ratio(mem);<br>
&gt; + =A0 =A0 =A0 limit =3D mem_cgroup_get_limit(mem);<br>
<br>
</div>mem_cgroup_get_limit doesn&#39;t return the correct limit for you,<br=
>
actually it&#39;s only for OOM killer.<br>
You should use<br>
limit =3D res_counter_read_u64(&amp;mem-&gt;res, RES_LIMIT) directly.<br>
Otherwise in the box which has swapon, you will get a huge<br>
number here.<br>
e.g.<br>
=A0[root@zyh-fedora a]# echo 500m &gt; memory.limit_in_bytes<br>
[root@zyh-fedora a]# cat memory.limit_in_bytes<br>
524288000<br>
[root@zyh-fedora a]# cat memory.reclaim_wmarks<br>
low_wmark 9114218496<br>
high_wmark 9114218496<br></blockquote><div><br></div><div>thank you~ will f=
ix it next post.</div><div><br></div><div>--Ying=A0</div><blockquote class=
=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padd=
ing-left:1ex;">

<br>
Regards,<br>
Zhu Yanhai<br>
<br>
<br>
&gt; + =A0 =A0 =A0 if (wmark_ratio =3D=3D 0) {<br>
<div><div></div><div class=3D"h5">&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_co=
unter_set_low_wmark_limit(&amp;mem-&gt;res, limit);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_counter_set_high_wmark_limit(&amp;me=
m-&gt;res, limit);<br>
&gt; + =A0 =A0 =A0 } else {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long low_wmark, high_wmark;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long long tmp =3D (wmark_ratio =
* limit) / 100;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 low_wmark =3D tmp;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 high_wmark =3D tmp - (tmp &gt;&gt; 8);<b=
r>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_counter_set_low_wmark_limit(&amp;mem=
-&gt;res, low_wmark);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_counter_set_high_wmark_limit(&amp;me=
m-&gt;res, high_wmark);<br>
&gt; + =A0 =A0 =A0 }<br>
&gt; +}<br>
&gt; +<br>
&gt; =A0/*<br>
&gt; =A0* Following LRU functions are allowed to be used without PCG_LOCK.<=
br>
&gt; =A0* Operations are called by routine of global LRU independently from=
 memcg.<br>
&gt; @@ -1195,6 +1219,16 @@ static unsigned int get_swappiness(struct mem_c=
group *memcg)<br>
&gt; =A0 =A0 =A0 =A0return memcg-&gt;swappiness;<br>
&gt; =A0}<br>
&gt;<br>
&gt; +static unsigned long get_wmark_ratio(struct mem_cgroup *memcg)<br>
&gt; +{<br>
&gt; + =A0 =A0 =A0 struct cgroup *cgrp =3D memcg-&gt;css.cgroup;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 VM_BUG_ON(!cgrp);<br>
&gt; + =A0 =A0 =A0 VM_BUG_ON(!cgrp-&gt;parent);<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 return memcg-&gt;wmark_ratio;<br>
&gt; +}<br>
&gt; +<br>
&gt; =A0static void mem_cgroup_start_move(struct mem_cgroup *mem)<br>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 =A0int cpu;<br>
&gt; @@ -3205,6 +3239,7 @@ static int mem_cgroup_resize_limit(struct mem_cg=
roup *memcg,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memcg-&=
gt;memsw_is_minimum =3D false;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 setup_per_memcg_wmarks(memcg);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mutex_unlock(&amp;set_limit_mutex);<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!ret)<br>
&gt; @@ -3264,6 +3299,7 @@ static int mem_cgroup_resize_memsw_limit(struct =
mem_cgroup *memcg,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memcg-&=
gt;memsw_is_minimum =3D false;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 setup_per_memcg_wmarks(memcg);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mutex_unlock(&amp;set_limit_mutex);<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!ret)<br>
&gt; @@ -4521,6 +4557,22 @@ static void __init enable_swap_cgroup(void)<br>
&gt; =A0}<br>
&gt; =A0#endif<br>
&gt;<br>
&gt; +int mem_cgroup_watermark_ok(struct mem_cgroup *mem,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int char=
ge_flags)<br>
&gt; +{<br>
&gt; + =A0 =A0 =A0 long ret =3D 0;<br>
&gt; + =A0 =A0 =A0 int flags =3D CHARGE_WMARK_LOW | CHARGE_WMARK_HIGH;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 VM_BUG_ON((charge_flags &amp; flags) =3D=3D flags);<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 if (charge_flags &amp; CHARGE_WMARK_LOW)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D res_counter_check_under_low_wmar=
k_limit(&amp;mem-&gt;res);<br>
&gt; + =A0 =A0 =A0 if (charge_flags &amp; CHARGE_WMARK_HIGH)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D res_counter_check_under_high_wma=
rk_limit(&amp;mem-&gt;res);<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 return ret;<br>
&gt; +}<br>
&gt; +<br>
&gt; =A0static int mem_cgroup_soft_limit_tree_init(void)<br>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 =A0struct mem_cgroup_tree_per_node *rtpn;<br>
&gt; --<br>
&gt; 1.7.3.1<br>
&gt;<br>
</div></div>&gt; --<br>
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
</blockquote></div><br>

--000e0cd67698d27b0404a0e47639--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
