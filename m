Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 58C896B0253
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 02:55:15 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id gc3so53920563obb.3
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 23:55:15 -0800 (PST)
Received: from mail-ob0-x22a.google.com (mail-ob0-x22a.google.com. [2607:f8b0:4003:c01::22a])
        by mx.google.com with ESMTPS id d5si7530886oic.38.2016.02.17.23.55.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 23:55:14 -0800 (PST)
Received: by mail-ob0-x22a.google.com with SMTP id wb13so55089392obb.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 23:55:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1602161629560.19997@chino.kir.corp.google.com>
References: <56C2EDC1.2090509@huawei.com>
	<20160216173849.GA10487@kroah.com>
	<alpine.DEB.2.10.1602161629560.19997@chino.kir.corp.google.com>
Date: Thu, 18 Feb 2016 15:55:14 +0800
Message-ID: <CAF7GXvqr2dmc7CUcs_OmfYnEA9jE_Db4kGGG1HJyYYLhC6Bgew@mail.gmail.com>
Subject: Re: [PATCH] mm: add MM_SWAPENTS and page table when calculate
 tasksize in lowmem_scan()
From: "Figo.zhang" <figo1802@gmail.com>
Content-Type: multipart/alternative; boundary=001a11c2a5f6cf41c4052c06af1d
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Xishi Qiu <qiuxishi@huawei.com>, arve@android.com, riandrews@android.com, devel@driverdev.osuosl.org, zhong jiang <zhongjiang@huawei.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

--001a11c2a5f6cf41c4052c06af1d
Content-Type: text/plain; charset=UTF-8

2016-02-17 8:35 GMT+08:00 David Rientjes <rientjes@google.com>:

> On Tue, 16 Feb 2016, Greg Kroah-Hartman wrote:
>
> > On Tue, Feb 16, 2016 at 05:37:05PM +0800, Xishi Qiu wrote:
> > > Currently tasksize in lowmem_scan() only calculate rss, and not
> include swap.
> > > But usually smart phones enable zram, so swap space actually use ram.
> >
> > Yes, but does that matter for this type of calculation?  I need an ack
> > from the android team before I could ever take such a core change to
> > this code...
> >
>
> The calculation proposed in this patch is the same as the generic oom
> killer, it's an estimate of the amount of memory that will be freed if it
> is killed and can exit.  This is better than simply get_mm_rss().
>
> However, I think we seriously need to re-consider the implementation of
> the lowmem killer entirely.  It currently abuses the use of TIF_MEMDIE,
> which should ideally only be set for one thread on the system since it
> allows unbounded access to global memory reserves.
>


i don't understand why it need wait 1 second:

if (test_tsk_thread_flag(p, TIF_MEMDIE) &&
   time_before_eq(jiffies, lowmem_deathpending_timeout)) {
task_unlock(p);
rcu_read_unlock();
return 0;                             <= why return rather than continue?
}

and it will retry and wait many CPU times if one task holding the TIF_MEMDI.
   shrink_slab_node()
       while()
           shrinker->scan_objects();
                     lowmem_scan()
                                 if (test_tsk_thread_flag(p, TIF_MEMDIE) &&
                                       time_before_eq(jiffies,
lowmem_deathpending_timeout))



>
> It also abuses the user-visible /proc/self/oom_score_adj tunable: this
> tunable is used by the generic oom killer to bias or discount a proportion
> of memory from a process's usage.  This is the only supported semantic of
> the tunable.  The lowmem killer uses it as a strict prioritization, so any
> process with oom_score_adj higher than another process is preferred for
> kill, REGARDLESS of memory usage.  This leads to priority inversion, the
> user is unable to always define the same process to be killed by the
> generic oom killer and the lowmem killer.  This is what happens when a
> tunable with a very clear and defined purpose is used for other reasons.
>
> I'd seriously consider not accepting any additional hacks on top of this
> code until the implementation is rewritten.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--001a11c2a5f6cf41c4052c06af1d
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">2016-02-17 8:35 GMT+08:00 David Rientjes <span dir=3D"ltr">&lt;<a href=
=3D"mailto:rientjes@google.com" target=3D"_blank">rientjes@google.com</a>&g=
t;</span>:<br><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px=
 0.8ex;border-left-width:1px;border-left-color:rgb(204,204,204);border-left=
-style:solid;padding-left:1ex"><span class=3D"">On Tue, 16 Feb 2016, Greg K=
roah-Hartman wrote:<br>
<br>
&gt; On Tue, Feb 16, 2016 at 05:37:05PM +0800, Xishi Qiu wrote:<br>
&gt; &gt; Currently tasksize in lowmem_scan() only calculate rss, and not i=
nclude swap.<br>
&gt; &gt; But usually smart phones enable zram, so swap space actually use =
ram.<br>
&gt;<br>
&gt; Yes, but does that matter for this type of calculation?=C2=A0 I need a=
n ack<br>
&gt; from the android team before I could ever take such a core change to<b=
r>
&gt; this code...<br>
&gt;<br>
<br>
</span>The calculation proposed in this patch is the same as the generic oo=
m<br>
killer, it&#39;s an estimate of the amount of memory that will be freed if =
it<br>
is killed and can exit.=C2=A0 This is better than simply get_mm_rss().<br>
<br>
However, I think we seriously need to re-consider the implementation of<br>
the lowmem killer entirely.=C2=A0 It currently abuses the use of TIF_MEMDIE=
,<br>
which should ideally only be set for one thread on the system since it<br>
allows unbounded access to global memory reserves.<br></blockquote><div><br=
></div><div><br></div><div>i don&#39;t understand why it need wait 1 second=
:</div><div><br></div><div><div><span class=3D"" style=3D"white-space:pre">=
		</span>if (test_tsk_thread_flag(p, TIF_MEMDIE) &amp;&amp;</div><div><span=
 class=3D"" style=3D"white-space:pre">		</span> =C2=A0 =C2=A0time_before_eq=
(jiffies, lowmem_deathpending_timeout)) {</div><div><span class=3D"" style=
=3D"white-space:pre">			</span>task_unlock(p);</div><div><span class=3D"" s=
tyle=3D"white-space:pre">			</span>rcu_read_unlock();</div><div><span class=
=3D"" style=3D"white-space:pre">			</span>return 0; =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 &lt;=3D why return rather than continue?</div><div><span class=3D"" sty=
le=3D"white-space:pre">		</span>}</div></div><div><br></div><div>and it wil=
l retry and wait many CPU times if one task holding the TIF_MEMDI.</div><di=
v>=C2=A0 =C2=A0shrink_slab_node() =C2=A0=C2=A0</div><div>=C2=A0 =C2=A0 =C2=
=A0 =C2=A0while()</div><div>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0shrink=
er-&gt;scan_objects();<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0lowmem_scan()</div><div>=C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0if (test_tsk_thread_flag(p, TIF_MEMDIE) &amp;&amp;</div=
><div><span class=3D"" style=3D"white-space:pre">		</span>=C2=A0=C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 time_before_eq(jiffies, lo=
wmem_deathpending_timeout))=C2=A0</div><div><br></div><div>=C2=A0</div><blo=
ckquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left=
-width:1px;border-left-color:rgb(204,204,204);border-left-style:solid;paddi=
ng-left:1ex">
<br>
It also abuses the user-visible /proc/self/oom_score_adj tunable: this<br>
tunable is used by the generic oom killer to bias or discount a proportion<=
br>
of memory from a process&#39;s usage.=C2=A0 This is the only supported sema=
ntic of<br>
the tunable.=C2=A0 The lowmem killer uses it as a strict prioritization, so=
 any<br>
process with oom_score_adj higher than another process is preferred for<br>
kill, REGARDLESS of memory usage.=C2=A0 This leads to priority inversion, t=
he<br>
user is unable to always define the same process to be killed by the<br>
generic oom killer and the lowmem killer.=C2=A0 This is what happens when a=
<br>
tunable with a very clear and defined purpose is used for other reasons.<br=
>
<br>
I&#39;d seriously consider not accepting any additional hacks on top of thi=
s<br>
code until the implementation is rewritten.<br>
<div class=3D""><div class=3D"h5"><br>
--<br>
To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<br>
the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org</a>.=
=C2=A0 For more info on Linux MM,<br>
see: <a href=3D"http://www.linux-mm.org/" rel=3D"noreferrer" target=3D"_bla=
nk">http://www.linux-mm.org/</a> .<br>
Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvack.org=
">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">email@kva=
ck.org</a> &lt;/a&gt;<br>
</div></div></blockquote></div><br></div></div>

--001a11c2a5f6cf41c4052c06af1d--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
