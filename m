Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id B6A686B0005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 07:46:28 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id v5so969749uae.10
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 04:46:28 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i12sor376962uaj.206.2018.04.18.04.46.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Apr 2018 04:46:27 -0700 (PDT)
MIME-Version: 1.0
References: <20180417110615.16043-1-liwang@redhat.com> <20180417130300.GF17484@dhcp22.suse.cz>
 <20180417141442.GG17484@dhcp22.suse.cz> <CAEemH2dQ+yQ-P-=5J3Y-n+0V0XV-vJkQ81uD=Q3Bh+rHZ4sb-Q@mail.gmail.com>
 <20180417190044.GK17484@dhcp22.suse.cz> <7674C632-FE3E-42D2-B19D-32F531617043@cs.rutgers.edu>
 <20180418090722.GV17484@dhcp22.suse.cz> <20180418091943.GW17484@dhcp22.suse.cz>
 <CAEemH2evD8Gk6y_q41ygBZVwu--U9oKvnPh8xsrb5R27oLCBDA@mail.gmail.com> <20180418112916.GX17484@dhcp22.suse.cz>
In-Reply-To: <20180418112916.GX17484@dhcp22.suse.cz>
From: Li Wang <liwang@redhat.com>
Date: Wed, 18 Apr 2018 11:46:17 +0000
Message-ID: <CAEemH2eENKctW3xTJcQOLNTosz0-vai+EkGQdf5hhkDbPBk73Q@mail.gmail.com>
Subject: Re: [RFC PATCH] mm: correct status code which move_pages() returns
 for zero page
Content-Type: multipart/alternative; boundary="089e08240fd057ed1d056a1e01bc"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, linux-mm@kvack.org, ltp@lists.linux.it, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

--089e08240fd057ed1d056a1e01bc
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 18, 2018, 19:29 Michal Hocko <mhocko@suse.com> wrote:

> On Wed 18-04-18 18:39:19, Li Wang wrote:
> > On Wed, Apr 18, 2018 at 5:19 PM, Michal Hocko <mhocko@suse.com> wrote:
> >
> > > On Wed 18-04-18 11:07:22, Michal Hocko wrote:
> > > > On Tue 17-04-18 16:09:33, Zi Yan wrote:
> > > [...]
> > > > > diff --git a/mm/migrate.c b/mm/migrate.c
> > > > > index f65dd69e1fd1..32afa4723e7f 100644
> > > > > --- a/mm/migrate.c
> > > > > +++ b/mm/migrate.c
> > > > > @@ -1619,6 +1619,8 @@ static int do_pages_move(struct mm_struct
> *mm,
> > > nodemask_t task_nodes,
> > > > >                         if (err)
> > > > >                                 goto out;
> > > > >                 }
> > > > > +               /* Move to next page (i+1), after we have saved
> page
> > > status (until i) */
> > > > > +               start =3D i + 1;
> > > > >                 current_node =3D NUMA_NO_NODE;
> > > > >         }
> > > > >  out_flush:
> > > > >
> > > > > Feel free to check it by yourselves.
> > > >
> > > > Yes, you are right. I never update start if the last page in the
> range
> > > > fails and so we overwrite the whole [start, i] range. I wish the co=
de
> > > > wasn't that ugly and subtle but considering how we can fail in
> different
> > > > ways and that we want to batch as much as possible I do not see an
> easy
> > > > way.
> > > >
> > > > Care to send the patch? I would just drop the comment.
> > >
> > > Hmm, thinking about it some more. An alternative would be to check fo=
r
> > > list_empty on the page list. It is a bit larger diff but maybe that
> > > would be tiny bit cleaner because there is simply no point to call
> > > do_move_pages_to_node on an empty list in the first place.
> > >
> >
> > =E2=80=8BHi Michal, Zi
> >
> > I tried your patch separately, both of them works fine to me.
>
> Thanks for retesting! Do you plan to post a patch with the changelog or
> should I do it?
>

You better.

Li Wang

--089e08240fd057ed1d056a1e01bc
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><div><br><br><div class=3D"gmail_quote"><div dir=3D"ltr">=
On Wed, Apr 18, 2018, 19:29 Michal Hocko &lt;<a href=3D"mailto:mhocko@suse.=
com" target=3D"_blank" rel=3D"noreferrer">mhocko@suse.com</a>&gt; wrote:<br=
></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-=
left:1px #ccc solid;padding-left:1ex">On Wed 18-04-18 18:39:19, Li Wang wro=
te:<br>
&gt; On Wed, Apr 18, 2018 at 5:19 PM, Michal Hocko &lt;<a href=3D"mailto:mh=
ocko@suse.com" rel=3D"noreferrer noreferrer" target=3D"_blank">mhocko@suse.=
com</a>&gt; wrote:<br>
&gt; <br>
&gt; &gt; On Wed 18-04-18 11:07:22, Michal Hocko wrote:<br>
&gt; &gt; &gt; On Tue 17-04-18 16:09:33, Zi Yan wrote:<br>
&gt; &gt; [...]<br>
&gt; &gt; &gt; &gt; diff --git a/mm/migrate.c b/mm/migrate.c<br>
&gt; &gt; &gt; &gt; index f65dd69e1fd1..32afa4723e7f 100644<br>
&gt; &gt; &gt; &gt; --- a/mm/migrate.c<br>
&gt; &gt; &gt; &gt; +++ b/mm/migrate.c<br>
&gt; &gt; &gt; &gt; @@ -1619,6 +1619,8 @@ static int do_pages_move(struct m=
m_struct *mm,<br>
&gt; &gt; nodemask_t task_nodes,<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (err)<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto out;<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0}<br>
&gt; &gt; &gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0/* Move to next page (i+1), after we have saved page<br>
&gt; &gt; status (until i) */<br>
&gt; &gt; &gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0start =3D i + 1;<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0current_node =3D NUMA_NO_NODE;<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; &gt; &gt; &gt;=C2=A0 out_flush:<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; Feel free to check it by yourselves.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Yes, you are right. I never update start if the last page in=
 the range<br>
&gt; &gt; &gt; fails and so we overwrite the whole [start, i] range. I wish=
 the code<br>
&gt; &gt; &gt; wasn&#39;t that ugly and subtle but considering how we can f=
ail in different<br>
&gt; &gt; &gt; ways and that we want to batch as much as possible I do not =
see an easy<br>
&gt; &gt; &gt; way.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Care to send the patch? I would just drop the comment.<br>
&gt; &gt;<br>
&gt; &gt; Hmm, thinking about it some more. An alternative would be to chec=
k for<br>
&gt; &gt; list_empty on the page list. It is a bit larger diff but maybe th=
at<br>
&gt; &gt; would be tiny bit cleaner because there is simply no point to cal=
l<br>
&gt; &gt; do_move_pages_to_node on an empty list in the first place.<br>
&gt; &gt;<br>
&gt; <br>
&gt; =E2=80=8BHi Michal, Zi<br>
&gt; <br>
&gt; I tried your patch separately, both of them works fine to me.<br>
<br>
Thanks for retesting! Do you plan to post a patch with the changelog or<br>
should I do it?<br></blockquote></div></div><div dir=3D"auto"><br></div><di=
v dir=3D"auto">You better.</div><div dir=3D"auto"><br></div><div dir=3D"aut=
o">Li Wang</div></div>

--089e08240fd057ed1d056a1e01bc--
