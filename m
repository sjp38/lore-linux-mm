Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id BC3159000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 20:21:11 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id p3R0L33F021726
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 17:21:03 -0700
Received: from qyj19 (qyj19.prod.google.com [10.241.83.83])
	by kpbe19.cbf.corp.google.com with ESMTP id p3R0KZiE029633
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 17:21:01 -0700
Received: by qyj19 with SMTP id 19so1724194qyj.2
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 17:21:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110426101631.F34C.A69D9226@jp.fujitsu.com>
References: <1303752134-4856-1-git-send-email-yinghan@google.com>
	<1303752134-4856-3-git-send-email-yinghan@google.com>
	<20110426101631.F34C.A69D9226@jp.fujitsu.com>
Date: Tue, 26 Apr 2011 17:21:00 -0700
Message-ID: <BANLkTikteGwLXiG9GVDrMkrruUoTieADfQ@mail.gmail.com>
Subject: Re: [PATCH V2 2/2] change shrinker API by passing shrink_control struct
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016e64aefda4e32e904a1db6af2
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--0016e64aefda4e32e904a1db6af2
Content-Type: text/plain; charset=ISO-8859-1

On Mon, Apr 25, 2011 at 6:15 PM, KOSAKI Motohiro <
kosaki.motohiro@jp.fujitsu.com> wrote:

> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 7a2f657..abc13ea 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -1137,16 +1137,19 @@ static inline void sync_mm_rss(struct task_struct
> *task, struct mm_struct *mm)
> >  struct shrink_control {
> >       unsigned long nr_scanned;
> >       gfp_t gfp_mask;
> > +
> > +     /* How many slab objects shrinker() should reclaim */
> > +     unsigned long nr_slab_to_reclaim;
>
> Wrong name. The original shrinker API is
>        int (*shrink)(struct shrinker *, int nr_to_scan, gfp_t gfp_mask);
>
> ie, shrinker get scanning target. not reclaiming target.
> You should have think folloing diff hunk is strange.
>

Ok, changed to "nr_slab_to_shrink"

>
> >  {
> >       struct xfs_mount *mp;
> >       struct xfs_perag *pag;
> >       xfs_agnumber_t  ag;
> >       int             reclaimable;
> > +     int nr_to_scan = sc->nr_slab_to_reclaim;
> > +     gfp_t gfp_mask = sc->gfp_mask;
>
> And, this very near meaning field .nr_scanned and .nr_slab_to_reclaim
> poped up new question.
> Why don't we pass more clever slab shrinker target? Why do we need pass
> similar two argument?
>

I renamed the nr_slab_to_reclaim and nr_scanned in shrink struct.

--Ying

> >  /*
> >   * A callback you can register to apply pressure to ageable caches.
> >   *
> > - * 'shrink' is passed a count 'nr_to_scan' and a 'gfpmask'.  It should
> > - * look through the least-recently-used 'nr_to_scan' entries and
> > - * attempt to free them up.  It should return the number of objects
> > - * which remain in the cache.  If it returns -1, it means it cannot do
> > - * any scanning at this time (eg. there is a risk of deadlock).
> > + * 'sc' is passed shrink_control which includes a count
> 'nr_slab_to_reclaim'
> > + * and a 'gfpmask'.  It should look through the least-recently-us
>
>                                                                  us?
>
>
> > + * 'nr_slab_to_reclaim' entries and attempt to free them up.  It should
> return
> > + * the number of objects which remain in the cache.  If it returns -1,
> it means
> > + * it cannot do any scanning at this time (eg. there is a risk of
> deadlock).
> >   *
>
>
>
>
>

--0016e64aefda4e32e904a1db6af2
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Mon, Apr 25, 2011 at 6:15 PM, KOSAKI =
Motohiro <span dir=3D"ltr">&lt;<a href=3D"mailto:kosaki.motohiro@jp.fujitsu=
.com">kosaki.motohiro@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote c=
lass=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;=
padding-left:1ex;">
&gt; diff --git a/include/linux/mm.h b/include/linux/mm.h<br>
&gt; index 7a2f657..abc13ea 100644<br>
&gt; --- a/include/linux/mm.h<br>
&gt; +++ b/include/linux/mm.h<br>
&gt; @@ -1137,16 +1137,19 @@ static inline void sync_mm_rss(struct task_str=
uct *task, struct mm_struct *mm)<br>
&gt; =A0struct shrink_control {<br>
&gt; =A0 =A0 =A0 unsigned long nr_scanned;<br>
&gt; =A0 =A0 =A0 gfp_t gfp_mask;<br>
&gt; +<br>
&gt; + =A0 =A0 /* How many slab objects shrinker() should reclaim */<br>
&gt; + =A0 =A0 unsigned long nr_slab_to_reclaim;<br>
<br>
Wrong name. The original shrinker API is<br>
 =A0 =A0 =A0 =A0int (*shrink)(struct shrinker *, int nr_to_scan, gfp_t gfp_=
mask);<br>
<br>
ie, shrinker get scanning target. not reclaiming target.<br>
You should have think folloing diff hunk is strange.<br></blockquote><div><=
br></div><div>Ok, changed to &quot;nr_slab_to_shrink&quot;=A0</div><blockqu=
ote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc s=
olid;padding-left:1ex;">

<br>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 struct xfs_mount *mp;<br>
&gt; =A0 =A0 =A0 struct xfs_perag *pag;<br>
&gt; =A0 =A0 =A0 xfs_agnumber_t =A0ag;<br>
&gt; =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 reclaimable;<br>
&gt; + =A0 =A0 int nr_to_scan =3D sc-&gt;nr_slab_to_reclaim;<br>
&gt; + =A0 =A0 gfp_t gfp_mask =3D sc-&gt;gfp_mask;<br>
<br>
And, this very near meaning field .nr_scanned and .nr_slab_to_reclaim<br>
poped up new question.<br>
Why don&#39;t we pass more clever slab shrinker target? Why do we need pass=
<br>
similar two argument?<br></blockquote><div><br></div><div>I renamed the nr_=
slab_to_reclaim and nr_scanned in shrink struct. =A0</div><div><br></div><d=
iv>--Ying</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex=
;border-left:1px #ccc solid;padding-left:1ex;">

&gt; =A0/*<br>
&gt; =A0 * A callback you can register to apply pressure to ageable caches.=
<br>
&gt; =A0 *<br>
&gt; - * &#39;shrink&#39; is passed a count &#39;nr_to_scan&#39; and a &#39=
;gfpmask&#39;. =A0It should<br>
&gt; - * look through the least-recently-used &#39;nr_to_scan&#39; entries =
and<br>
&gt; - * attempt to free them up. =A0It should return the number of objects=
<br>
&gt; - * which remain in the cache. =A0If it returns -1, it means it cannot=
 do<br>
&gt; - * any scanning at this time (eg. there is a risk of deadlock).<br>
&gt; + * &#39;sc&#39; is passed shrink_control which includes a count &#39;=
nr_slab_to_reclaim&#39;<br>
&gt; + * and a &#39;gfpmask&#39;. =A0It should look through the least-recen=
tly-us<br>
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0us?<br>
<br>
<br>
&gt; + * &#39;nr_slab_to_reclaim&#39; entries and attempt to free them up. =
=A0It should return<br>
&gt; + * the number of objects which remain in the cache. =A0If it returns =
-1, it means<br>
&gt; + * it cannot do any scanning at this time (eg. there is a risk of dea=
dlock).<br>
&gt; =A0 *<br>
<br>
<br>
<br>
<br>
</blockquote></div><br>

--0016e64aefda4e32e904a1db6af2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
