Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 898E66B0092
	for <linux-mm@kvack.org>; Sat, 28 Apr 2012 15:45:38 -0400 (EDT)
Received: by dadq36 with SMTP id q36so2515483dad.8
        for <linux-mm@kvack.org>; Sat, 28 Apr 2012 12:45:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120428120657.4982a248.akpm@linux-foundation.org>
References: <1335383992-19419-1-git-send-email-sasikanth.v19@gmail.com>
	<20120426162108.b654a920.akpm@linux-foundation.org>
	<CAOJFanUu_RD2UNgFg4gNuPte+jOA95ejMtq53UCo6vLaLohmQQ@mail.gmail.com>
	<20120428120657.4982a248.akpm@linux-foundation.org>
Date: Sun, 29 Apr 2012 01:15:37 +0530
Message-ID: <CAOJFanXUdy17kcRHnOuHv5fgv44b4LrwviPupCEx9BbY6QF=zg@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: memblock - Handled failure of debug fs entries creation
From: Sasikanth babu <sasikanth.v19@gmail.com>
Content-Type: multipart/alternative; boundary=e89a8ff24bab0fdae504bec27709
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, "H. Peter Anvin" <hpa@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--e89a8ff24bab0fdae504bec27709
Content-Type: text/plain; charset=ISO-8859-1

On Sun, Apr 29, 2012 at 12:36 AM, Andrew Morton
<akpm@linux-foundation.org>wrote:

> On Sun, 29 Apr 2012 00:32:26 +0530 Sasikanth babu <sasikanth.v19@gmail.com>
> wrote:
>
> > > Fact is, debugfs_create_dir() and debugfs_create_file() are stupid
> > > interfaces which don't provide the caller (and hence the user) with any
> > > information about why they failed.  Perhaps memblock_init_debugfs()
> > > should return -EWESUCK.
> > >
> >
> >    I'm working on a patch which address this issue. debugfs_create_XXX
> > calls
> >    will return proper error codes, and fixing the existing code not each
> > and every part  but the code
> >    which handles the values returned by debufs_create_XXX otherwise it
> will
> > break the existing
> >    functionality .
>
> Excellent!
>
> > (any suggestions or opinions ?)
>
> Well, don't modify the existing interfaces: create new ones and we can
> migrate gradually.  But you're probably already doing that.
>

  Not going to change the existing interface.  Modified debugfs_create_XXX
  to return ERR_PTR(error) instead of NULL.

[sasikantha@localhost linux-2.6]$ git diff
diff --git a/fs/debugfs/inode.c b/fs/debugfs/inode.c
index b80bc84..f5a5783 100644
--- a/fs/debugfs/inode.c
+++ b/fs/debugfs/inode.c
@@ -378,7 +378,7 @@ struct dentry *debugfs_create_file(const char *name,
umode_t mode,
        error = debugfs_create_by_name(name, mode, parent, &dentry,
                                       data, fops);
        if (error) {
-               dentry = NULL;
+               dentry = ERR_PTR(error);
                simple_release_fs(&debugfs_mount, &debugfs_mount_count);
                goto exit;
        }

  And from the caller side modifying the code as shown below (Currently
started doing
  modification for each subsystem)

        dir = debugfs_create_dir("test", NULL);

        if (IS_ERR(dir)) {
            return PTR_ERR(dir);
       }

   I think as you had mentioned creating new interface and migrating
gradually is the right of
   way of doing it.

   Thanks
   Sasi

--e89a8ff24bab0fdae504bec27709
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_quote">On Sun, Apr 29, 2012 at 12:=
36 AM, Andrew Morton <span dir=3D"ltr">&lt;<a href=3D"mailto:akpm@linux-fou=
ndation.org" target=3D"_blank">akpm@linux-foundation.org</a>&gt;</span> wro=
te:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><div class=3D"im">On Sun, 29 Apr 2012 00:32:=
26 +0530 Sasikanth babu &lt;<a href=3D"mailto:sasikanth.v19@gmail.com">sasi=
kanth.v19@gmail.com</a>&gt; wrote:<br>

<br>
&gt; &gt; Fact is, debugfs_create_dir() and debugfs_create_file() are stupi=
d<br>
&gt; &gt; interfaces which don&#39;t provide the caller (and hence the user=
) with any<br>
&gt; &gt; information about why they failed. =A0Perhaps memblock_init_debug=
fs()<br>
&gt; &gt; should return -EWESUCK.<br>
&gt; &gt;<br>
&gt;<br>
&gt; =A0 =A0I&#39;m working on a patch which address this issue. debugfs_cr=
eate_XXX<br>
&gt; calls<br>
&gt; =A0 =A0will return proper error codes, and fixing the existing code no=
t each<br>
&gt; and every part =A0but the code<br>
&gt; =A0 =A0which handles the values returned by debufs_create_XXX otherwis=
e it will<br>
&gt; break the existing<br>
&gt; =A0 =A0functionality .<br>
<br>
</div>Excellent!<br>
<div class=3D"im"><br>
&gt; (any suggestions or opinions ?)<br>
<br>
</div>Well, don&#39;t modify the existing interfaces: create new ones and w=
e can<br>
migrate gradually. =A0But you&#39;re probably already doing that.<br>
</blockquote></div><br>=A0 Not going to change the existing interface.=A0 M=
odified debugfs_create_XXX <br>=A0 to return ERR_PTR(error) instead of NULL=
.<br>=A0 <br>[sasikantha@localhost linux-2.6]$ git diff<br>diff --git a/fs/=
debugfs/inode.c b/fs/debugfs/inode.c<br>
index b80bc84..f5a5783 100644<br>--- a/fs/debugfs/inode.c<br>+++ b/fs/debug=
fs/inode.c<br>@@ -378,7 +378,7 @@ struct dentry *debugfs_create_file(const =
char *name, umode_t mode,<br>
=A0=A0=A0=A0=A0=A0=A0 error =3D debugfs_create_by_name(name, mode, parent, =
&amp;dentry,<br>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 data, fops);<br>=
=A0=A0=A0=A0=A0=A0=A0 if (error) {<br>-=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0 dentry =3D NULL;<br>+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 dent=
ry =3D ERR_PTR(error);<br>

=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 simple_release_fs(&amp;debugf=
s_mount, &amp;debugfs_mount_count);<br>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0 goto exit;<br>=A0=A0=A0=A0=A0=A0=A0 }<br><br>=A0 And from the cal=
ler side modifying the code as shown below (Currently started doing<br>
=A0 modification for each subsystem)<br>=A0<br>=A0=A0=A0=A0=A0=A0=A0 dir =
=3D debugfs_create_dir(&quot;test&quot;, NULL);<br><br>=A0=A0=A0=A0=A0=A0=
=A0 if (IS_ERR(dir)) {<br>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 return PTR_ERR(=
dir);<br>=A0=A0=A0=A0=A0=A0 }<br><br>=A0=A0 I think as you had mentioned cr=
eating new interface and migrating gradually is the right of<br>
=A0=A0 way of doing it.<br>=A0=A0=A0 <br>=A0=A0 Thanks<br>=A0=A0 Sasi<br><b=
r></div>

--e89a8ff24bab0fdae504bec27709--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
