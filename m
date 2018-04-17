Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id C2BDD6B0005
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:28:34 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id z78so284518vkd.14
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 07:28:34 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 3sor3065813uah.141.2018.04.17.07.28.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Apr 2018 07:28:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180417141442.GG17484@dhcp22.suse.cz>
References: <20180417110615.16043-1-liwang@redhat.com> <20180417130300.GF17484@dhcp22.suse.cz>
 <20180417141442.GG17484@dhcp22.suse.cz>
From: Li Wang <liwang@redhat.com>
Date: Tue, 17 Apr 2018 22:28:33 +0800
Message-ID: <CAEemH2dQ+yQ-P-=5J3Y-n+0V0XV-vJkQ81uD=Q3Bh+rHZ4sb-Q@mail.gmail.com>
Subject: Re: [RFC PATCH] mm: correct status code which move_pages() returns
 for zero page
Content-Type: multipart/alternative; boundary="089e08240fd0390290056a0c273b"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org, ltp@lists.linux.it, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Zi Yan <zi.yan@cs.rutgers.edu>

--089e08240fd0390290056a0c273b
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, Apr 17, 2018 at 10:14 PM, Michal Hocko <mhocko@suse.com> wrote:

> On Tue 17-04-18 15:03:00, Michal Hocko wrote:
> > On Tue 17-04-18 19:06:15, Li Wang wrote:
> > [...]
> > > diff --git a/mm/migrate.c b/mm/migrate.c
> > > index f65dd69..2b315fc 100644
> > > --- a/mm/migrate.c
> > > +++ b/mm/migrate.c
> > > @@ -1608,7 +1608,7 @@ static int do_pages_move(struct mm_struct *mm,
> nodemask_t task_nodes,
> > >                     continue;
> > >
> > >             err =3D store_status(status, i, err, 1);
> > > -           if (err)
> > > +           if (!err)
> > >                     goto out_flush;
> >
> > This change just doesn't make any sense to me. Why should we bail out i=
f
> > the store_status is successul? I am trying to wrap my head around the
> > test case. 6b9d757ecafc ("mm, numa: rework do_pages_move") tried to
> > explain that move_pages has some semantic issues and the new
> > implementation might be not 100% replacement. Anyway I am studying the
> > test case to come up with a proper fix.
>
> OK, I get what the test cases does. I've failed to see the subtle
> difference between alloc_pages_on_node and numa_alloc_onnode. The later
> doesn't faul in anything.
>
> Why are we getting EPERM is quite not yet clear to me.
> add_page_for_migration uses FOLL_DUMP which should return EFAULT on
> zero pages (no_page_table()).
>
>         err =3D PTR_ERR(page);
>         if (IS_ERR(page))
>                 goto out;
>
> therefore bails out from add_page_for_migration and store_status should
> store that value. There shouldn't be any EPERM on the way.
>

Yes, I print the the return value and confirmed the
add_page_for_migration()=E2=80=8B
do right things for zero page. and after store_status(...) the status saves
-EFAULT.
So I did the change above.



>
> Let me try to reproduce and see what is going on. Btw. which kernel do
> you try this on?
>

=E2=80=8BThe latest mainline kernel-4.17-rc1.



--=20
Li Wang
liwang@redhat.com

--089e08240fd0390290056a0c273b
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_default" style=3D"font-family:arial,he=
lvetica,sans-serif"><br></div><div class=3D"gmail_extra"><br><div class=3D"=
gmail_quote">On Tue, Apr 17, 2018 at 10:14 PM, Michal Hocko <span dir=3D"lt=
r">&lt;<a href=3D"mailto:mhocko@suse.com" target=3D"_blank">mhocko@suse.com=
</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin=
:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><span class=3D"">O=
n Tue 17-04-18 15:03:00, Michal Hocko wrote:<br>
&gt; On Tue 17-04-18 19:06:15, Li Wang wrote:<br>
&gt; [...]<br>
&gt; &gt; diff --git a/mm/migrate.c b/mm/migrate.c<br>
&gt; &gt; index f65dd69..2b315fc 100644<br>
&gt; &gt; --- a/mm/migrate.c<br>
&gt; &gt; +++ b/mm/migrate.c<br>
&gt; &gt; @@ -1608,7 +1608,7 @@ static int do_pages_move(struct mm_struct *=
mm, nodemask_t task_nodes,<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0continue;<br>
&gt; &gt;=C2=A0 <br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0err =3D store_stat=
us(status, i, err, 1);<br>
&gt; &gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (err)<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!err)<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0goto out_flush;<br>
&gt; <br>
&gt; This change just doesn&#39;t make any sense to me. Why should we bail =
out if<br>
&gt; the store_status is successul? I am trying to wrap my head around the<=
br>
&gt; test case. 6b9d757ecafc (&quot;mm, numa: rework do_pages_move&quot;) t=
ried to<br>
&gt; explain that move_pages has some semantic issues and the new<br>
&gt; implementation might be not 100% replacement. Anyway I am studying the=
<br>
&gt; test case to come up with a proper fix.<br>
<br>
</span>OK, I get what the test cases does. I&#39;ve failed to see the subtl=
e<br>
difference between alloc_pages_on_node and numa_alloc_onnode. The later<br>
doesn&#39;t faul in anything.<br>
<br>
Why are we getting EPERM is quite not yet clear to me.<br>
add_page_for_migration uses FOLL_DUMP which should return EFAULT on<br>
zero pages (no_page_table()).<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 err =3D PTR_ERR(page);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (IS_ERR(page))<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;<br>
<br>
therefore bails out from add_page_for_migration and store_status should<br>
store that value. There shouldn&#39;t be any EPERM on the way.<br></blockqu=
ote><div><br></div><div><div style=3D"font-family:arial,helvetica,sans-seri=
f" class=3D"gmail_default">Yes, I print the the return value and confirmed =
the add_page_for_migration()=E2=80=8B</div><div style=3D"font-family:arial,=
helvetica,sans-serif" class=3D"gmail_default">do right things for zero page=
. and after store_status(...) the status saves -EFAULT.</div><div style=3D"=
font-family:arial,helvetica,sans-serif" class=3D"gmail_default">So I did th=
e change above.</div><div style=3D"font-family:arial,helvetica,sans-serif" =
class=3D"gmail_default"><br></div></div><div>=C2=A0</div><blockquote class=
=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padd=
ing-left:1ex">
<br>
Let me try to reproduce and see what is going on. Btw. which kernel do<br>
you try this on?<br>
<div class=3D"HOEnZb"><div class=3D"h5"></div></div></blockquote><div><br><=
/div><div style=3D"font-family:arial,helvetica,sans-serif" class=3D"gmail_d=
efault">=E2=80=8BThe latest mainline kernel-4.17-rc1.</div></div><br><br cl=
ear=3D"all"><br>-- <br><div class=3D"gmail_signature" data-smartmail=3D"gma=
il_signature">Li Wang<br><a href=3D"mailto:liwang@redhat.com" target=3D"_bl=
ank">liwang@redhat.com</a></div>
</div></div>

--089e08240fd0390290056a0c273b--
