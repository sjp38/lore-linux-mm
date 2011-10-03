Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 41CDF9000C6
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 09:30:42 -0400 (EDT)
Received: by vcbfo14 with SMTP id fo14so3803957vcb.14
        for <linux-mm@kvack.org>; Mon, 03 Oct 2011 06:30:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20111003192458.14d198a3.kamezawa.hiroyu@jp.fujitsu.com>
References: <CADLM8XNiaxLFRZXs4NKJmoORvED-DV0bNxPF6eHsfnLqtxw09w@mail.gmail.com>
	<20111003192458.14d198a3.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 3 Oct 2011 21:30:06 +0800
Message-ID: <CADLM8XOaWOd9EaOg-xaepc2JsLgwxuo0BTZg6gfHpCEfwKhTng@mail.gmail.com>
Subject: Re: One comment on the __release_region in kernel/resource.c
From: Wei Yang <weiyang.kernel@gmail.com>
Content-Type: multipart/alternative; boundary=bcaec519638f1b424704ae64f944
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

--bcaec519638f1b424704ae64f944
Content-Type: text/plain; charset=ISO-8859-1

2011/10/3 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> On Sun, 2 Oct 2011 21:57:07 +0800
> Wei Yang <weiyang.kernel@gmail.com> wrote:
>
> > Dear experts,
> >
> > I am viewing the source code of __release_region() in kernel/resource.c.
> > And I have one comment for the performance issue.
> >
> > For example, we have a resource tree like this.
> > 10-89
> >    20-79
> >        30-49
> >        55-59
> >        60-64
> >        65-69
> >    80-89
> > 100-279
> >
> > If the caller wants to release a region of [50,59], the original code
> will
> > execute four times in the for loop in the subtree of 20-79.
> >
> > After changing the code below, it will execute two times instead.
> >
> > By using the "git annotate", I see this code is committed by Linus as the
> > initial version. So don't get more information about why this code is
> > written
> > in this way.
> >
> > Maybe the case I thought will not happen in the real world?
> >
> > Your comment is warmly welcome. :)
> >
> > diff --git a/kernel/resource.c b/kernel/resource.c
> > index 8461aea..81525b4 100644
> > --- a/kernel/resource.c
> > +++ b/kernel/resource.c
> > @@ -931,7 +931,7 @@ void __release_region(struct resource *parent,
> > resource_size_t start,
> >        for (;;) {
> >                struct resource *res = *p;
> >
> > -               if (!res)
> > +               if (!res || res->start > start)
>
> Hmm ?
>        res->start > end ?
>
>  I think res->start > start is fine.
__release_region will release the exact the region, no overlap.
So if res->start > start, this means there is no exact region to release.
The required to release region doesn't exist.


> Thanks,
> -Kame
>
>


-- 
Wei Yang
Help You, Help Me

--bcaec519638f1b424704ae64f944
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">2011/10/3 KAMEZAWA Hiroyuki <span dir=3D=
"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com" target=3D"_blan=
k">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span><br><blockquote class=3D"gm=
ail_quote" style=3D"margin: 0pt 0pt 0pt 0.8ex; border-left: 1px solid rgb(2=
04, 204, 204); padding-left: 1ex;">

<div><div></div><div>On Sun, 2 Oct 2011 21:57:07 +0800<br>
Wei Yang &lt;<a href=3D"mailto:weiyang.kernel@gmail.com" target=3D"_blank">=
weiyang.kernel@gmail.com</a>&gt; wrote:<br>
<br>
&gt; Dear experts,<br>
&gt;<br>
&gt; I am viewing the source code of __release_region() in kernel/resource.=
c.<br>
&gt; And I have one comment for the performance issue.<br>
&gt;<br>
&gt; For example, we have a resource tree like this.<br>
&gt; 10-89<br>
&gt; =A0 =A020-79<br>
&gt; =A0 =A0 =A0 =A030-49<br>
&gt; =A0 =A0 =A0 =A055-59<br>
&gt; =A0 =A0 =A0 =A060-64<br>
&gt; =A0 =A0 =A0 =A065-69<br>
&gt; =A0 =A080-89<br>
&gt; 100-279<br>
&gt;<br>
&gt; If the caller wants to release a region of [50,59], the original code =
will<br>
&gt; execute four times in the for loop in the subtree of 20-79.<br>
&gt;<br>
&gt; After changing the code below, it will execute two times instead.<br>
&gt;<br>
&gt; By using the &quot;git annotate&quot;, I see this code is committed by=
 Linus as the<br>
&gt; initial version. So don&#39;t get more information about why this code=
 is<br>
&gt; written<br>
&gt; in this way.<br>
&gt;<br>
&gt; Maybe the case I thought will not happen in the real world?<br>
&gt;<br>
&gt; Your comment is warmly welcome. :)<br>
&gt;<br>
&gt; diff --git a/kernel/resource.c b/kernel/resource.c<br>
&gt; index 8461aea..81525b4 100644<br>
&gt; --- a/kernel/resource.c<br>
&gt; +++ b/kernel/resource.c<br>
&gt; @@ -931,7 +931,7 @@ void __release_region(struct resource *parent,<br>
&gt; resource_size_t start,<br>
&gt; =A0 =A0 =A0 =A0for (;;) {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct resource *res =3D *p;<br>
&gt;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!res)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!res || res-&gt;start &gt; start)<br=
>
<br>
</div></div>Hmm ?<br>
 =A0 =A0 =A0 =A0res-&gt;start &gt; end ?<br>
<br></blockquote><div>=A0I think res-&gt;start &gt; start is fine. <br>__re=
lease_region will release the exact the region, no overlap.<br>So if res-&g=
t;start &gt; start, this means there is no exact region to release.<br>The =
required to release region doesn&#39;t exist.<br>
<br></div><blockquote class=3D"gmail_quote" style=3D"margin: 0pt 0pt 0pt 0.=
8ex; border-left: 1px solid rgb(204, 204, 204); padding-left: 1ex;">
<br>
Thanks,<br>
-Kame<br>
<br>
</blockquote></div><br><br clear=3D"all"><br>-- <br>Wei Yang<br>Help You, H=
elp Me<br><br>

--bcaec519638f1b424704ae64f944--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
