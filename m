Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3CF376B00B6
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 14:01:11 -0500 (EST)
Received: by yw-out-1718.google.com with SMTP id 9so938585ywk.26
        for <linux-mm@kvack.org>; Mon, 16 Feb 2009 11:01:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090216153351.GB27520@cmpxchg.org>
References: <20090216142926.440561506@cmpxchg.org>
	 <20090216144725.976425091@cmpxchg.org>
	 <84144f020902160713y7341b2b4g8aa10919405ab82d@mail.gmail.com>
	 <20090216153351.GB27520@cmpxchg.org>
Date: Mon, 16 Feb 2009 13:01:09 -0600
Message-ID: <524f69650902161101u3e709155i14963483ba96302@mail.gmail.com>
Subject: Re: [patch 6/8] cifs: use kzfree()
From: Steve French <smfrench@gmail.com>
Content-Type: multipart/alternative; boundary=00c09f986e063841ed04630dcff6
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Steve French <sfrench@samba.org>
List-ID: <linux-mm.kvack.org>

--00c09f986e063841ed04630dcff6
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Looks fine to me:

Acked-by: Steve French <sfrench@us.ibm.com>

On Mon, Feb 16, 2009 at 9:33 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Mon, Feb 16, 2009 at 05:13:30PM +0200, Pekka Enberg wrote:
> > Hi Johannes,
> >
> > On Mon, Feb 16, 2009 at 4:29 PM, Johannes Weiner <hannes@cmpxchg.org>
> wrote:
> > > @@ -2433,11 +2433,8 @@ mount_fail_check:
> > >  out:
> > >        /* zero out password before freeing */
> > >        if (volume_info) {
> > > -               if (volume_info->password != NULL) {
> > > -                       memset(volume_info->password, 0,
> > > -                               strlen(volume_info->password));
> > > -                       kfree(volume_info->password);
> > > -               }
> > > +               if (volume_info->password != NULL)
> > > +                       kzfree(volume_info->password);
> >
> > The NULL check here is unnecessary.
> >
> > >                kfree(volume_info->UNC);
> > >                kfree(volume_info->prepath);
> > >                kfree(volume_info);
> > > --- a/fs/cifs/misc.c
> > > +++ b/fs/cifs/misc.c
> > > @@ -97,10 +97,8 @@ sesInfoFree(struct cifsSesInfo *buf_to_f
> > >        kfree(buf_to_free->serverOS);
> > >        kfree(buf_to_free->serverDomain);
> > >        kfree(buf_to_free->serverNOS);
> > > -       if (buf_to_free->password) {
> > > -               memset(buf_to_free->password, 0,
> strlen(buf_to_free->password));
> > > -               kfree(buf_to_free->password);
> > > -       }
> > > +       if (buf_to_free->password)
> > > +               kzfree(buf_to_free->password);
> >
> > And here.
>
> Thanks, Pekka!
>
> Here is the delta to fold into the above:
>
> [ btw, do these require an extra SOB?  If so:
>  Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
>
>  And for http://lkml.org/lkml/2009/2/16/184:
>  Signed-off-by: Johannes Weiner <hannes@cmpxchg.org> ]
>
> --- a/fs/cifs/connect.c
> +++ b/fs/cifs/connect.c
> @@ -2433,8 +2433,7 @@ mount_fail_check:
>  out:
>        /* zero out password before freeing */
>        if (volume_info) {
> -               if (volume_info->password != NULL)
> -                       kzfree(volume_info->password);
> +               kzfree(volume_info->password);
>                 kfree(volume_info->UNC);
>                kfree(volume_info->prepath);
>                kfree(volume_info);
> --- a/fs/cifs/misc.c
> +++ b/fs/cifs/misc.c
> @@ -97,8 +97,7 @@ sesInfoFree(struct cifsSesInfo *buf_to_f
>         kfree(buf_to_free->serverOS);
>        kfree(buf_to_free->serverDomain);
>        kfree(buf_to_free->serverNOS);
> -       if (buf_to_free->password)
> -               kzfree(buf_to_free->password);
> +       kzfree(buf_to_free->password);
>         kfree(buf_to_free->domainName);
>        kfree(buf_to_free);
>  }
> @@ -130,8 +129,7 @@ tconInfoFree(struct cifsTconInfo *buf_to
>         }
>        atomic_dec(&tconInfoAllocCount);
>        kfree(buf_to_free->nativeFileSystem);
> -       if (buf_to_free->password)
> -               kzfree(buf_to_free->password);
> +       kzfree(buf_to_free->password);
>        kfree(buf_to_free);
>  }
>
>


-- 
Thanks,

Steve

--00c09f986e063841ed04630dcff6
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Looks fine to me:<br><br>Acked-by: Steve French &lt;<a href=3D"mailto:sfren=
ch@us.ibm.com">sfrench@us.ibm.com</a>&gt;<br><br><div class=3D"gmail_quote"=
>On Mon, Feb 16, 2009 at 9:33 AM, Johannes Weiner <span dir=3D"ltr">&lt;<a =
href=3D"mailto:hannes@cmpxchg.org">hannes@cmpxchg.org</a>&gt;</span> wrote:=
<br>
<blockquote class=3D"gmail_quote" style=3D"border-left: 1px solid rgb(204, =
204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;"><div><div></div><=
div class=3D"Wj3C7c">On Mon, Feb 16, 2009 at 05:13:30PM +0200, Pekka Enberg=
 wrote:<br>

&gt; Hi Johannes,<br>
&gt;<br>
&gt; On Mon, Feb 16, 2009 at 4:29 PM, Johannes Weiner &lt;<a href=3D"mailto=
:hannes@cmpxchg.org">hannes@cmpxchg.org</a>&gt; wrote:<br>
&gt; &gt; @@ -2433,11 +2433,8 @@ mount_fail_check:<br>
&gt; &gt; &nbsp;out:<br>
&gt; &gt; &nbsp; &nbsp; &nbsp; &nbsp;/* zero out password before freeing */=
<br>
&gt; &gt; &nbsp; &nbsp; &nbsp; &nbsp;if (volume_info) {<br>
&gt; &gt; - &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; if (volume_inf=
o-&gt;password !=3D NULL) {<br>
&gt; &gt; - &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp; &nbsp; memset(volume_info-&gt;password, 0,<br>
&gt; &gt; - &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; strlen(volume_info-&gt;password))=
;<br>
&gt; &gt; - &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp; &nbsp; kfree(volume_info-&gt;password);<br>
&gt; &gt; - &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; }<br>
&gt; &gt; + &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; if (volume_inf=
o-&gt;password !=3D NULL)<br>
&gt; &gt; + &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp; &nbsp; kzfree(volume_info-&gt;password);<br>
&gt;<br>
&gt; The NULL check here is unnecessary.<br>
&gt;<br>
&gt; &gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;kfree(volu=
me_info-&gt;UNC);<br>
&gt; &gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;kfree(volu=
me_info-&gt;prepath);<br>
&gt; &gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;kfree(volu=
me_info);<br>
&gt; &gt; --- a/fs/cifs/misc.c<br>
&gt; &gt; +++ b/fs/cifs/misc.c<br>
&gt; &gt; @@ -97,10 +97,8 @@ sesInfoFree(struct cifsSesInfo *buf_to_f<br>
&gt; &gt; &nbsp; &nbsp; &nbsp; &nbsp;kfree(buf_to_free-&gt;serverOS);<br>
&gt; &gt; &nbsp; &nbsp; &nbsp; &nbsp;kfree(buf_to_free-&gt;serverDomain);<b=
r>
&gt; &gt; &nbsp; &nbsp; &nbsp; &nbsp;kfree(buf_to_free-&gt;serverNOS);<br>
&gt; &gt; - &nbsp; &nbsp; &nbsp; if (buf_to_free-&gt;password) {<br>
&gt; &gt; - &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; memset(buf_to_=
free-&gt;password, 0, strlen(buf_to_free-&gt;password));<br>
&gt; &gt; - &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; kfree(buf_to_f=
ree-&gt;password);<br>
&gt; &gt; - &nbsp; &nbsp; &nbsp; }<br>
&gt; &gt; + &nbsp; &nbsp; &nbsp; if (buf_to_free-&gt;password)<br>
&gt; &gt; + &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; kzfree(buf_to_=
free-&gt;password);<br>
&gt;<br>
&gt; And here.<br>
<br>
</div></div>Thanks, Pekka!<br>
<br>
Here is the delta to fold into the above:<br>
<br>
[ btw, do these require an extra SOB? &nbsp;If so:<br>
 &nbsp;Signed-off-by: Johannes Weiner &lt;<a href=3D"mailto:hannes@cmpxchg.=
org">hannes@cmpxchg.org</a>&gt;<br>
<br>
 &nbsp;And for <a href=3D"http://lkml.org/lkml/2009/2/16/184" target=3D"_bl=
ank">http://lkml.org/lkml/2009/2/16/184</a>:<br>
 &nbsp;Signed-off-by: Johannes Weiner &lt;<a href=3D"mailto:hannes@cmpxchg.=
org">hannes@cmpxchg.org</a>&gt; ]<br>
<div class=3D"Ih2E3d"><br>
--- a/fs/cifs/connect.c<br>
+++ b/fs/cifs/connect.c<br>
</div>@@ -2433,8 +2433,7 @@ mount_fail_check:<br>
<div class=3D"Ih2E3d">&nbsp;out:<br>
 &nbsp; &nbsp; &nbsp; &nbsp;/* zero out password before freeing */<br>
 &nbsp; &nbsp; &nbsp; &nbsp;if (volume_info) {<br>
- &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; if (volume_info-&gt;pass=
word !=3D NULL)<br>
</div>- &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbs=
p; &nbsp; kzfree(volume_info-&gt;password);<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; kzfree(volume_info-&gt;p=
assword);<br>
<div class=3D"Ih2E3d"> &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nb=
sp;kfree(volume_info-&gt;UNC);<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;kfree(volume_info-&=
gt;prepath);<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;kfree(volume_info);=
<br>
--- a/fs/cifs/misc.c<br>
+++ b/fs/cifs/misc.c<br>
</div>@@ -97,8 +97,7 @@ sesInfoFree(struct cifsSesInfo *buf_to_f<br>
<div class=3D"Ih2E3d"> &nbsp; &nbsp; &nbsp; &nbsp;kfree(buf_to_free-&gt;ser=
verOS);<br>
 &nbsp; &nbsp; &nbsp; &nbsp;kfree(buf_to_free-&gt;serverDomain);<br>
 &nbsp; &nbsp; &nbsp; &nbsp;kfree(buf_to_free-&gt;serverNOS);<br>
- &nbsp; &nbsp; &nbsp; if (buf_to_free-&gt;password)<br>
</div>- &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; kzfree(buf_to_free=
-&gt;password);<br>
+ &nbsp; &nbsp; &nbsp; kzfree(buf_to_free-&gt;password);<br>
<div class=3D"Ih2E3d"> &nbsp; &nbsp; &nbsp; &nbsp;kfree(buf_to_free-&gt;dom=
ainName);<br>
 &nbsp; &nbsp; &nbsp; &nbsp;kfree(buf_to_free);<br>
&nbsp;}<br>
</div>@@ -130,8 +129,7 @@ tconInfoFree(struct cifsTconInfo *buf_to<br>
<div class=3D"Ih2E3d"> &nbsp; &nbsp; &nbsp; &nbsp;}<br>
 &nbsp; &nbsp; &nbsp; &nbsp;atomic_dec(&amp;tconInfoAllocCount);<br>
 &nbsp; &nbsp; &nbsp; &nbsp;kfree(buf_to_free-&gt;nativeFileSystem);<br>
- &nbsp; &nbsp; &nbsp; if (buf_to_free-&gt;password)<br>
</div>- &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; kzfree(buf_to_free=
-&gt;password);<br>
+ &nbsp; &nbsp; &nbsp; kzfree(buf_to_free-&gt;password);<br>
 &nbsp; &nbsp; &nbsp; &nbsp;kfree(buf_to_free);<br>
&nbsp;}<br>
<br>
</blockquote></div><br><br clear=3D"all"><br>-- <br>Thanks,<br><br>Steve<br=
>

--00c09f986e063841ed04630dcff6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
