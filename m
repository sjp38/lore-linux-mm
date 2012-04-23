Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 8E5F16B0044
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 17:15:55 -0400 (EDT)
Received: by dadq36 with SMTP id q36so18138760dad.8
        for <linux-mm@kvack.org>; Mon, 23 Apr 2012 14:15:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1204231334200.11602@chino.kir.corp.google.com>
References: <1335208126-25919-1-git-send-email-sasikanth.v19@gmail.com>
	<alpine.DEB.2.00.1204231334200.11602@chino.kir.corp.google.com>
Date: Tue, 24 Apr 2012 02:45:54 +0530
Message-ID: <CAOJFanXaX__QZmbs15e04g6D-0478cAjm70WZK-BWebJCuQCQw@mail.gmail.com>
Subject: Re: [PATCH] mm:vmstat - Removed debug fs entries on failure of file
 creation and made extfrag_debug_root dentry local
From: Sasikanth babu <sasikanth.v19@gmail.com>
Content-Type: multipart/alternative; boundary=047d7b15fafdc0f36804be5f2412
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--047d7b15fafdc0f36804be5f2412
Content-Type: text/plain; charset=ISO-8859-1

On Tue, Apr 24, 2012 at 2:05 AM, David Rientjes <rientjes@google.com> wrote:

> On Tue, 24 Apr 2012, Sasikantha babu wrote:
>
> > diff --git a/mm/vmstat.c b/mm/vmstat.c
> > index f600557..ddae476 100644
> > --- a/mm/vmstat.c
> > +++ b/mm/vmstat.c
> > @@ -1220,7 +1220,6 @@ module_init(setup_vmstat)
> >  #if defined(CONFIG_DEBUG_FS) && defined(CONFIG_COMPACTION)
> >  #include <linux/debugfs.h>
> >
> > -static struct dentry *extfrag_debug_root;
> >
> >  /*
> >   * Return an index indicating how much of the available free memory is
> > @@ -1358,17 +1357,23 @@ static const struct file_operations
> extfrag_file_ops = {
> >
> >  static int __init extfrag_debug_init(void)
> >  {
> > +     struct dentry *extfrag_debug_root;
> > +
> >       extfrag_debug_root = debugfs_create_dir("extfrag", NULL);
> >       if (!extfrag_debug_root)
> >               return -ENOMEM;
> >
> >       if (!debugfs_create_file("unusable_index", 0444,
> > -                     extfrag_debug_root, NULL, &unusable_file_ops))
> > +                     extfrag_debug_root, NULL, &unusable_file_ops)) {
> > +             debugfs_remove (extfrag_debug_root);
> >               return -ENOMEM;
> > +     }
> >
> >       if (!debugfs_create_file("extfrag_index", 0444,
> > -                     extfrag_debug_root, NULL, &extfrag_file_ops))
> > +                     extfrag_debug_root, NULL, &extfrag_file_ops)) {
> > +             debugfs_remove_recursive (extfrag_debug_root);
> >               return -ENOMEM;
> > +     }
> >
> >       return 0;
> >  }
>
> Probably easier to do something like "goto fail" and then have a
>
>                return 0;
>
>        fail:
>                debugfs_remove_recursive(extfrag_debug_root);
>                return -ENOMEM;
>
>     Thanks, i will do the modification and resend the patch

> at the end of the function.
>
> Please run scripts/checkpatch.pl on your patch before proposing it.
>

  Didnt notice extra space after fucntion. From now onwards will run
checkpatch Thanks

--047d7b15fafdc0f36804be5f2412
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><br><br><div class=3D"gmail_quo=
te">On Tue, Apr 24, 2012 at 2:05 AM, David Rientjes <span dir=3D"ltr">&lt;<=
a href=3D"mailto:rientjes@google.com" target=3D"_blank">rientjes@google.com=
</a>&gt;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><div class=3D"HOEnZb"><div class=3D"h5">On T=
ue, 24 Apr 2012, Sasikantha babu wrote:<br>
<br>
&gt; diff --git a/mm/vmstat.c b/mm/vmstat.c<br>
&gt; index f600557..ddae476 100644<br>
&gt; --- a/mm/vmstat.c<br>
&gt; +++ b/mm/vmstat.c<br>
&gt; @@ -1220,7 +1220,6 @@ module_init(setup_vmstat)<br>
&gt; =A0#if defined(CONFIG_DEBUG_FS) &amp;&amp; defined(CONFIG_COMPACTION)<=
br>
&gt; =A0#include &lt;linux/debugfs.h&gt;<br>
&gt;<br>
&gt; -static struct dentry *extfrag_debug_root;<br>
&gt;<br>
&gt; =A0/*<br>
&gt; =A0 * Return an index indicating how much of the available free memory=
 is<br>
&gt; @@ -1358,17 +1357,23 @@ static const struct file_operations extfrag_fi=
le_ops =3D {<br>
&gt;<br>
&gt; =A0static int __init extfrag_debug_init(void)<br>
&gt; =A0{<br>
&gt; + =A0 =A0 struct dentry *extfrag_debug_root;<br>
&gt; +<br>
&gt; =A0 =A0 =A0 extfrag_debug_root =3D debugfs_create_dir(&quot;extfrag&qu=
ot;, NULL);<br>
&gt; =A0 =A0 =A0 if (!extfrag_debug_root)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;<br>
&gt;<br>
&gt; =A0 =A0 =A0 if (!debugfs_create_file(&quot;unusable_index&quot;, 0444,=
<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 extfrag_debug_root, NULL, &a=
mp;unusable_file_ops))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 extfrag_debug_root, NULL, &a=
mp;unusable_file_ops)) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 debugfs_remove (extfrag_debug_root);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;<br>
&gt; + =A0 =A0 }<br>
&gt;<br>
&gt; =A0 =A0 =A0 if (!debugfs_create_file(&quot;extfrag_index&quot;, 0444,<=
br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 extfrag_debug_root, NULL, &a=
mp;extfrag_file_ops))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 extfrag_debug_root, NULL, &a=
mp;extfrag_file_ops)) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 debugfs_remove_recursive (extfrag_debug_root=
);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;<br>
&gt; + =A0 =A0 }<br>
&gt;<br>
&gt; =A0 =A0 =A0 return 0;<br>
&gt; =A0}<br>
<br>
</div></div>Probably easier to do something like &quot;goto fail&quot; and =
then have a<br>
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;<br>
<br>
 =A0 =A0 =A0 =A0fail:<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0debugfs_remove_recursive(extfrag_debug_root=
);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;<br>
<br></blockquote><div>=A0 =A0 Thanks, i will do the modification and resend=
 the patch<br></div><blockquote class=3D"gmail_quote" style=3D"margin:0pt 0=
pt 0pt 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex">
at the end of the function.<br>
<br>
Please run scripts/<a href=3D"http://checkpatch.pl" target=3D"_blank">check=
patch.pl</a> on your patch before proposing it.<br>
</blockquote></div>=A0=A0 <br>=A0 Didnt notice extra space after fucntion. =
>From now onwards will run checkpatch Thanks<br></div></div>

--047d7b15fafdc0f36804be5f2412--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
