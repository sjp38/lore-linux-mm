Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id BEED88D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 01:55:25 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id p3M5tN5t010325
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 22:55:23 -0700
Received: from qwf7 (qwf7.prod.google.com [10.241.194.71])
	by wpaz21.hot.corp.google.com with ESMTP id p3M5tM6g004593
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 22:55:22 -0700
Received: by qwf7 with SMTP id 7so186642qwf.38
        for <linux-mm@kvack.org>; Thu, 21 Apr 2011 22:55:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110422134804.FA5E.A69D9226@jp.fujitsu.com>
References: <1303446260-21333-1-git-send-email-yinghan@google.com>
	<1303446260-21333-2-git-send-email-yinghan@google.com>
	<20110422134804.FA5E.A69D9226@jp.fujitsu.com>
Date: Thu, 21 Apr 2011 22:55:21 -0700
Message-ID: <BANLkTikpGy9sQOixoXWnxeAzu-+-p9x-bQ@mail.gmail.com>
Subject: Re: [PATCH V7 1/9] Add kswapd descriptor
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016e65dc8ece0053104a17b80c6
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--0016e65dc8ece0053104a17b80c6
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Apr 21, 2011 at 9:47 PM, KOSAKI Motohiro <
kosaki.motohiro@jp.fujitsu.com> wrote:

> Hi,
>
> This seems to have no ugly parts.
>

Thank you for reviewing.

>
>
> nitpick:
>
> > -     const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
> > +     const struct cpumask *cpumask;
> >
> >       lockdep_set_current_reclaim_state(GFP_KERNEL);
> >
> > +     cpumask = cpumask_of_node(pgdat->node_id);
>
> no effect change?
>

yes, will change .

>
>
> >       if (!cpumask_empty(cpumask))
> >               set_cpus_allowed_ptr(tsk, cpumask);
> >       current->reclaim_state = &reclaim_state;
> > @@ -2679,7 +2684,7 @@ static int kswapd(void *p)
> >                       order = new_order;
> >                       classzone_idx = new_classzone_idx;
> >               } else {
> > -                     kswapd_try_to_sleep(pgdat, order, classzone_idx);
> > +                     kswapd_try_to_sleep(kswapd_p, order,
> classzone_idx);
> >                       order = pgdat->kswapd_max_order;
> >                       classzone_idx = pgdat->classzone_idx;
> >                       pgdat->kswapd_max_order = 0;
> > @@ -2817,12 +2822,20 @@ static int __devinit cpu_callback(struct
> notifier_block *nfb,
> >               for_each_node_state(nid, N_HIGH_MEMORY) {
> >                       pg_data_t *pgdat = NODE_DATA(nid);
> >                       const struct cpumask *mask;
> > +                     struct kswapd *kswapd_p;
> > +                     struct task_struct *kswapd_tsk;
> > +                     wait_queue_head_t *wait;
> >
> >                       mask = cpumask_of_node(pgdat->node_id);
> >
> > +                     wait = &pgdat->kswapd_wait;
>
> In kswapd_try_to_sleep(), this waitqueue is called wait_h. Can you
> please keep naming consistency?
>
> Ok.

>
> > +                     kswapd_p = pgdat->kswapd;
> > +                     kswapd_tsk = kswapd_p->kswapd_task;
> > +
> >                       if (cpumask_any_and(cpu_online_mask, mask) <
> nr_cpu_ids)
> >                               /* One of our CPUs online: restore mask */
> > -                             set_cpus_allowed_ptr(pgdat->kswapd, mask);
> > +                             if (kswapd_tsk)
> > +                                     set_cpus_allowed_ptr(kswapd_tsk,
> mask);
>
> Need adding commnets. What mean kswapd_tsk==NULL and When it occur.
> I'm apologize if it done at later patch.
>

I don't think i have comments on later patch. will add.

--Ying

--0016e65dc8ece0053104a17b80c6
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, Apr 21, 2011 at 9:47 PM, KOSAKI =
Motohiro <span dir=3D"ltr">&lt;<a href=3D"mailto:kosaki.motohiro@jp.fujitsu=
.com">kosaki.motohiro@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote c=
lass=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;=
padding-left:1ex;">
Hi,<br>
<br>
This seems to have no ugly parts.<br></blockquote><div><br></div><div>Thank=
 you for reviewing.=A0</div><blockquote class=3D"gmail_quote" style=3D"marg=
in:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<br>
<br>
nitpick:<br>
<div class=3D"im"><br>
&gt; - =A0 =A0 const struct cpumask *cpumask =3D cpumask_of_node(pgdat-&gt;=
node_id);<br>
&gt; + =A0 =A0 const struct cpumask *cpumask;<br>
&gt;<br>
&gt; =A0 =A0 =A0 lockdep_set_current_reclaim_state(GFP_KERNEL);<br>
&gt;<br>
&gt; + =A0 =A0 cpumask =3D cpumask_of_node(pgdat-&gt;node_id);<br>
<br>
</div>no effect change?<br></blockquote><div><br></div><div>yes, will chang=
e .</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;borde=
r-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im"><br>
<br>
&gt; =A0 =A0 =A0 if (!cpumask_empty(cpumask))<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_cpus_allowed_ptr(tsk, cpumask);<br>
&gt; =A0 =A0 =A0 current-&gt;reclaim_state =3D &amp;reclaim_state;<br>
&gt; @@ -2679,7 +2684,7 @@ static int kswapd(void *p)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order =3D new_order;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 classzone_idx =3D new_clas=
szone_idx;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_try_to_sleep(pgdat, o=
rder, classzone_idx);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_try_to_sleep(kswapd_p=
, order, classzone_idx);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order =3D pgdat-&gt;kswapd=
_max_order;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 classzone_idx =3D pgdat-&g=
t;classzone_idx;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat-&gt;kswapd_max_order=
 =3D 0;<br>
&gt; @@ -2817,12 +2822,20 @@ static int __devinit cpu_callback(struct notif=
ier_block *nfb,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 for_each_node_state(nid, N_HIGH_MEMORY) {<=
br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pg_data_t *pgdat =3D NODE_=
DATA(nid);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const struct cpumask *mask=
;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct kswapd *kswapd_p;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task_struct *kswapd_t=
sk;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wait_queue_head_t *wait;<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mask =3D cpumask_of_node(p=
gdat-&gt;node_id);<br>
&gt;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wait =3D &amp;pgdat-&gt;kswa=
pd_wait;<br>
<br>
</div>In kswapd_try_to_sleep(), this waitqueue is called wait_h. Can you<br=
>
please keep naming consistency?<br>
<div class=3D"im"><br></div></blockquote><div>Ok.=A0</div><blockquote class=
=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padd=
ing-left:1ex;"><div class=3D"im">
<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_p =3D pgdat-&gt;kswap=
d;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_tsk =3D kswapd_p-&gt;=
kswapd_task;<br>
&gt; +<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cpumask_any_and(cpu_on=
line_mask, mask) &lt; nr_cpu_ids)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* One of =
our CPUs online: restore mask */<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_cpus_all=
owed_ptr(pgdat-&gt;kswapd, mask);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (kswapd_t=
sk)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 set_cpus_allowed_ptr(kswapd_tsk, mask);<br>
<br>
</div>Need adding commnets. What mean kswapd_tsk=3D=3DNULL and When it occu=
r.<br>
I&#39;m apologize if it done at later patch.<br></blockquote><div><br></div=
><div>I don&#39;t think i have comments on later patch. will add.</div><div=
><br></div><div>--Ying=A0</div></div><br>

--0016e65dc8ece0053104a17b80c6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
