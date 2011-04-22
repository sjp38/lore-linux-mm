Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 174DA8D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 14:37:51 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p3MIbk7E007816
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 11:37:46 -0700
Received: from qyk7 (qyk7.prod.google.com [10.241.83.135])
	by hpaq1.eem.corp.google.com with ESMTP id p3MIbifV013478
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 11:37:44 -0700
Received: by qyk7 with SMTP id 7so439804qyk.19
        for <linux-mm@kvack.org>; Fri, 22 Apr 2011 11:37:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110422174554.71F2.A69D9226@jp.fujitsu.com>
References: <20110422150050.FA6E.A69D9226@jp.fujitsu.com>
	<BANLkTi=BewF6TtSAsqY+bYQB6UUR_yt9yQ@mail.gmail.com>
	<20110422174554.71F2.A69D9226@jp.fujitsu.com>
Date: Fri, 22 Apr 2011 11:37:43 -0700
Message-ID: <BANLkTinB5tGAH=DE55HnE5krGxx1uoXgLA@mail.gmail.com>
Subject: Re: [PATCH V7 7/9] Per-memcg background reclaim.
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0ce008bc48599604a18627cf
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--000e0ce008bc48599604a18627cf
Content-Type: text/plain; charset=ISO-8859-1

On Fri, Apr 22, 2011 at 1:44 AM, KOSAKI Motohiro <
kosaki.motohiro@jp.fujitsu.com> wrote:

> > > > @@ -111,6 +113,8 @@ struct scan_control {
> > > >        * are scanned.
> > > >        */
> > > >       nodemask_t      *nodemask;
> > > > +
> > > > +     int priority;
> > > >  };
> > >
> > > Bah!
> > > If you need sc.priority, you have to make cleanup patch at first. and
> > > all current reclaim path have to use sc.priority. Please don't increase
> > > unnecessary mess.
> > >
> > > hmm. so then I would change it by passing the priority
> > > as separate parameter.
>
> ok.
>
> > > > +             /*
> > > > +              * If we've done a decent amount of scanning and
> > > > +              * the reclaim ratio is low, start doing writepage
> > > > +              * even in laptop mode
> > > > +              */
> > > > +             if (total_scanned > SWAP_CLUSTER_MAX * 2 &&
> > > > +                 total_scanned > sc->nr_reclaimed + sc->nr_reclaimed
> /
> > > 2) {
> > > > +                     sc->may_writepage = 1;
> > >
> > > please make helper function for may_writepage. iow, don't cut-n-paste.
> > >
> > > hmm, can you help to clarify that?
>
> I meant completely cut-n-paste code and comments is here.
>
>
> > > > +     total_scanned = 0;
> > > > +
> > > > +     do_nodes = node_states[N_ONLINE];
> > >
> > > Why do we need care memoryless node? N_HIGH_MEMORY is wrong?
> > >
> > hmm, let me look into that.
>
>
> > > > +             sc.priority = priority;
> > > > +             /* The swap token gets in the way of swapout... */
> > > > +             if (!priority)
> > > > +                     disable_swap_token();
> > >
> > > Why?
> > >
> > > disable swap token mean "Please devest swap preventation privilege from
> > > owner task. Instead we endure swap storm and performance hit".
> > > However I doublt memcg memory shortage is good situation to make swap
> > > storm.
> > >
> >
> > I am not sure about that either way. we probably can leave as it is and
> make
> > corresponding change if real problem is observed?
>
> Why?
> This is not only memcg issue, but also can lead to global swap ping-pong.
>
> But I give up. I have no time to persuade you.
>
> Thank you for pointing that out. I didn't pay much attention on the
swap_token but just simply inherited
it from the global logic. Now after reading a bit more, i think you were
right about it.  It would be a bad
idea to have memcg kswapds affecting much the global swap token being set.

I will remove it from the next post.

>
> > > > +                     nid = mem_cgroup_select_victim_node(mem_cont,
> > > > +                                                     &do_nodes);
> > > > +
> > > > +                     pgdat = NODE_DATA(nid);
> > > > +                     shrink_memcg_node(pgdat, order, &sc);
> > > > +                     total_scanned += sc.nr_scanned;
> > > > +
> > > > +                     for (i = pgdat->nr_zones - 1; i >= 0; i--) {
> > > > +                             struct zone *zone = pgdat->node_zones +
> i;
> > > > +
> > > > +                             if (populated_zone(zone))
> > > > +                                     break;
> > > > +                     }
> > >
> > > memory less node check is here. but we can check it before.
> >
> > Not sure I understand this, can you help to clarify?
>
> Same with above N_HIGH_MEMORY comments.
>

Ok, agree on the HIGH_MEMORY and will change that.

--Ying

--000e0ce008bc48599604a18627cf
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Fri, Apr 22, 2011 at 1:44 AM, KOSAKI =
Motohiro <span dir=3D"ltr">&lt;<a href=3D"mailto:kosaki.motohiro@jp.fujitsu=
.com">kosaki.motohiro@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote c=
lass=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;=
padding-left:1ex;">
<div class=3D"im">&gt; &gt; &gt; @@ -111,6 +113,8 @@ struct scan_control {<=
br>
&gt; &gt; &gt; =A0 =A0 =A0 =A0* are scanned.<br>
&gt; &gt; &gt; =A0 =A0 =A0 =A0*/<br>
&gt; &gt; &gt; =A0 =A0 =A0 nodemask_t =A0 =A0 =A0*nodemask;<br>
&gt; &gt; &gt; +<br>
&gt; &gt; &gt; + =A0 =A0 int priority;<br>
&gt; &gt; &gt; =A0};<br>
&gt; &gt;<br>
&gt; &gt; Bah!<br>
&gt; &gt; If you need sc.priority, you have to make cleanup patch at first.=
 and<br>
&gt; &gt; all current reclaim path have to use sc.priority. Please don&#39;=
t increase<br>
&gt; &gt; unnecessary mess.<br>
&gt; &gt;<br>
&gt; &gt; hmm. so then I would change it by passing the priority<br>
&gt; &gt; as separate parameter.<br>
<br>
</div>ok.<br>
<div class=3D"im"><br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0* If we&#39;ve done a decent am=
ount of scanning and<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0* the reclaim ratio is low, sta=
rt doing writepage<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0* even in laptop mode<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (total_scanned &gt; SWAP_CLUSTE=
R_MAX * 2 &amp;&amp;<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned &gt; sc-&gt;=
nr_reclaimed + sc-&gt;nr_reclaimed /<br>
&gt; &gt; 2) {<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;may_writepa=
ge =3D 1;<br>
&gt; &gt;<br>
&gt; &gt; please make helper function for may_writepage. iow, don&#39;t cut=
-n-paste.<br>
&gt; &gt;<br>
&gt; &gt; hmm, can you help to clarify that?<br>
<br>
</div>I meant completely cut-n-paste code and comments is here.<br>
<div class=3D"im"><br>
<br>
&gt; &gt; &gt; + =A0 =A0 total_scanned =3D 0;<br>
&gt; &gt; &gt; +<br>
&gt; &gt; &gt; + =A0 =A0 do_nodes =3D node_states[N_ONLINE];<br>
&gt; &gt;<br>
&gt; &gt; Why do we need care memoryless node? N_HIGH_MEMORY is wrong?<br>
&gt; &gt;<br>
&gt; hmm, let me look into that.<br>
<br>
<br>
</div><div class=3D"im">&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 sc.priorit=
y =3D priority;<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 /* The swap token gets in the way =
of swapout... */<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (!priority)<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 disable_swap_token=
();<br>
&gt; &gt;<br>
&gt; &gt; Why?<br>
&gt; &gt;<br>
&gt; &gt; disable swap token mean &quot;Please devest swap preventation pri=
vilege from<br>
&gt; &gt; owner task. Instead we endure swap storm and performance hit&quot=
;.<br>
&gt; &gt; However I doublt memcg memory shortage is good situation to make =
swap<br>
&gt; &gt; storm.<br>
&gt; &gt;<br>
&gt;<br>
&gt; I am not sure about that either way. we probably can leave as it is an=
d make<br>
&gt; corresponding change if real problem is observed?<br>
<br>
</div>Why?<br>
This is not only memcg issue, but also can lead to global swap ping-pong.<b=
r>
<br>
But I give up. I have no time to persuade you.<br>
<div class=3D"im"><br></div></blockquote><div>Thank you for pointing that o=
ut. I didn&#39;t pay much attention on the swap_token but just simply=A0inh=
erited</div><div>it from the global logic. Now after reading a bit more, i =
think you were right about it. =A0It would be a bad</div>
<div>idea to have memcg kswapds affecting much the global swap token being =
set.=A0</div><div><br></div><div>I will remove it from the next post. =A0=
=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;borde=
r-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im">
<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nid =3D mem_cgroup=
_select_victim_node(mem_cont,<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &amp;do_nodes);<br>
&gt; &gt; &gt; +<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat =3D NODE_DAT=
A(nid);<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_memcg_node(=
pgdat, order, &amp;sc);<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned +=3D=
 sc.nr_scanned;<br>
&gt; &gt; &gt; +<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D pgdat-&=
gt;nr_zones - 1; i &gt;=3D 0; i--) {<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 st=
ruct zone *zone =3D pgdat-&gt;node_zones + i;<br>
&gt; &gt; &gt; +<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if=
 (populated_zone(zone))<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 break;<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; &gt;<br>
&gt; &gt; memory less node check is here. but we can check it before.<br>
&gt;<br>
&gt; Not sure I understand this, can you help to clarify?<br>
<br>
</div>Same with above N_HIGH_MEMORY comments.<br></blockquote><div><br></di=
v><div>Ok, agree on the HIGH_MEMORY and will change that.</div><div><br></d=
iv><div>--Ying=A0</div></div><br>

--000e0ce008bc48599604a18627cf--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
