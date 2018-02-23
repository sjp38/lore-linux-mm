Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0BCD16B0024
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 21:24:21 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id e186so6379279iof.9
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 18:24:21 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q133sor867298ioe.69.2018.02.22.18.24.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Feb 2018 18:24:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAKOZuesZPy8rgo_pPy=cUtGcGhLzCq4X46ns7h7ta7ihrJSPWA@mail.gmail.com>
References: <20180222020633.GC27147@rodete-desktop-imager.corp.google.com>
 <20180222024620.47691-1-dancol@google.com> <20180223020130.GA115990@rodete-desktop-imager.corp.google.com>
 <CAKOZuesZPy8rgo_pPy=cUtGcGhLzCq4X46ns7h7ta7ihrJSPWA@mail.gmail.com>
From: Daniel Colascione <dancol@google.com>
Date: Thu, 22 Feb 2018 18:24:18 -0800
Message-ID: <CAKOZues=wHgMu9vH7ixc-vzL7b7T7OK2jYecUKvnR45Fx=HDBw@mail.gmail.com>
Subject: Re: [PATCH] Synchronize task mm counters on demand
Content-Type: multipart/alternative; boundary="089e0826eb208f45710565d7dbea"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>

--089e0826eb208f45710565d7dbea
Content-Type: text/plain; charset="UTF-8"

On Thu, Feb 22, 2018 at 6:09 PM, Daniel Colascione <dancol@google.com>
wrote:

> Thanks for taking a look.
>
> On Feb 22, 2018 6:01 PM, "Minchan Kim" <minchan@kernel.org> wrote:
>
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index ad06d42adb1a..f8129afebbdd 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -1507,14 +1507,28 @@ extern int mprotect_fixup(struct vm_area_struct
> *vma,
> >   */
> >  int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
> >                         struct page **pages);
> > +
> > +#ifdef SPLIT_RSS_COUNTING
> > +/* Flush all task-buffered MM counters to the mm */
> > +void sync_mm_rss_all_users(struct mm_struct *mm);
>
> Really heavy functioin iterates all of processes and threads.
>
>
> Just all processes and the threads of each process attached to the mm.
> Maybe that's not much better.
>


Another option would be to maintain a list (with the list_head in the mm)
of all the tasks with unflushed counters. This way, we at least wouldn't
have to scan the world.

--089e0826eb208f45710565d7dbea
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><div class=3D"gmail_quote">On T=
hu, Feb 22, 2018 at 6:09 PM, Daniel Colascione <span dir=3D"ltr">&lt;<a hre=
f=3D"mailto:dancol@google.com" target=3D"_blank">dancol@google.com</a>&gt;<=
/span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8=
ex;border-left:1px #ccc solid;padding-left:1ex"><div dir=3D"auto"><div><div=
 class=3D"gmail_extra"><div class=3D"gmail_quote" dir=3D"auto">Thanks for t=
aking a look.</div><div><div class=3D"h5"><div class=3D"gmail_quote" dir=3D=
"auto"><br></div><div class=3D"gmail_quote">On Feb 22, 2018 6:01 PM, &quot;=
Minchan Kim&quot; &lt;<a href=3D"mailto:minchan@kernel.org" target=3D"_blan=
k">minchan@kernel.org</a>&gt; wrote:<br type=3D"attribution"></div></div></=
div></div></div><span class=3D""><div dir=3D"auto"><div class=3D"gmail_extr=
a"><div class=3D"gmail_quote"><blockquote class=3D"m_-7744850135525327735qu=
ote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex=
"><div class=3D"m_-7744850135525327735quoted-text">&gt; diff --git a/includ=
e/linux/mm.h b/include/linux/mm.h<br>
&gt; index ad06d42adb1a..f8129afebbdd 100644<br>
&gt; --- a/include/linux/mm.h<br>
&gt; +++ b/include/linux/mm.h<br>
&gt; @@ -1507,14 +1507,28 @@ extern int mprotect_fixup(struct vm_area_struc=
t *vma,<br>
&gt;=C2=A0 =C2=A0*/<br>
&gt;=C2=A0 int __get_user_pages_fast(unsigned long start, int nr_pages, int=
 write,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0struct page **pages);<br>
&gt; +<br>
&gt; +#ifdef SPLIT_RSS_COUNTING<br>
&gt; +/* Flush all task-buffered MM counters to the mm */<br>
&gt; +void sync_mm_rss_all_users(struct mm_struct *mm);<br>
<br>
</div>Really heavy functioin iterates all of processes and threads.<br></bl=
ockquote></div></div></div><div dir=3D"auto"><br></div></span><div dir=3D"a=
uto">Just all processes and the threads of each process attached to the mm.=
 Maybe that&#39;s not much better.</div></div></blockquote><div><br></div><=
div><br></div><div>Another option would be to maintain a list (with the lis=
t_head in the mm) of all the tasks with unflushed counters. This way, we at=
 least wouldn&#39;t have to scan the world.</div></div></div></div>

--089e0826eb208f45710565d7dbea--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
