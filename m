Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 855316B000A
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 04:13:54 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id k9-v6so12026786ioj.18
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 01:13:54 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j79sor15074175jad.11.2018.11.13.01.13.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Nov 2018 01:13:53 -0800 (PST)
MIME-Version: 1.0
References: <CAJtqMcZVQFp8U0aFqrMDD2-UGuLkWYvg3rytcCswnOT_ZMSzjQ@mail.gmail.com>
 <20181113074641.GA7645@hori1.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20181113074641.GA7645@hori1.linux.bs1.fc.nec.co.jp>
From: Yongkai Wu <nic.wuyk@gmail.com>
Date: Tue, 13 Nov 2018 17:13:42 +0800
Message-ID: <CAJtqMcYwcKcEsZSRw4iN3Tn3yRNFSiy4xPibratVhhEhfjXhjg@mail.gmail.com>
Subject: Re: [PATCH] mm/hwpoison: fix incorrect call put_hwpoison_page() when
 isolate_huge_page() return false
Content-Type: multipart/alternative; boundary="000000000000857ecf057a883cc9"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: n-horiguchi@ah.jp.nec.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

--000000000000857ecf057a883cc9
Content-Type: text/plain; charset="UTF-8"

Dear Naoya,
Thank you for your kind reply.
You are right.The current code is ok and I am sorry for wasting your time.

Best Regards.


On Tue, Nov 13, 2018 at 3:47 PM Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
wrote:

> On Tue, Nov 13, 2018 at 03:00:09PM +0800, Yongkai Wu wrote:
> > when isolate_huge_page() return false,it won't takes a refcount of page,
> > if we call put_hwpoison_page() in that case,we may hit the
> VM_BUG_ON_PAGE!
> >
> > Signed-off-by: Yongkai Wu <nic_w@163.com>
> > ---
> >  mm/memory-failure.c | 13 +++++++------
> >  1 file changed, 7 insertions(+), 6 deletions(-)
> >
> > diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> > index 0cd3de3..ed09f56 100644
> > --- a/mm/memory-failure.c
> > +++ b/mm/memory-failure.c
> > @@ -1699,12 +1699,13 @@ static int soft_offline_huge_page(struct page
> *page,
> > int flags)
> >   unlock_page(hpage);
> >
> >   ret = isolate_huge_page(hpage, &pagelist);
> > - /*
> > - * get_any_page() and isolate_huge_page() takes a refcount each,
> > - * so need to drop one here.
> > - */
> > - put_hwpoison_page(hpage);
> > - if (!ret) {
> > + if (ret) {
> > +        /*
> > +          * get_any_page() and isolate_huge_page() takes a refcount
> each,
> > +          * so need to drop one here.
> > +        */
> > + put_hwpoison_page(hpage);
> > + } else {
>
> Hi Yongkai,
>
> Although the current code might look odd, it's OK. We have to release
> one refcount whether this isolate_huge_page() succeeds or not, because
> the put_hwpoison_page() is cancelling the refcount from get_any_page()
> which always succeeds when we enter soft_offline_huge_page().
>
> Let's consider that the isolate_huge_page() fails with your patch applied,
> then the refcount taken by get_any_page() is never released after returning
> from soft_offline_page(). That will lead to memory leak.
>
> I think that current code comment doesn't explaing it well, so if you
> like, you can fix the comment.  (If you do that, please check coding style.
> scripts/checkpatch.pl will help you.)
>
> Thanks,
> Naoya Horiguchi
>

--000000000000857ecf057a883cc9
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><div dir=3D"ltr">Dear Naoya,<div>Thank yo=
u for your kind reply.</div><div>You are right.The current code is ok and I=
 am sorry for wasting your time.</div><div><br></div><div>Best Regards.</di=
v><div>=C2=A0</div></div></div></div><br><div class=3D"gmail_quote"><div di=
r=3D"ltr">On Tue, Nov 13, 2018 at 3:47 PM Naoya Horiguchi &lt;<a href=3D"ma=
ilto:n-horiguchi@ah.jp.nec.com" target=3D"_blank">n-horiguchi@ah.jp.nec.com=
</a>&gt; wrote:<br></div><blockquote class=3D"gmail_quote" style=3D"margin:=
0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">On Tue, Nov 13, 201=
8 at 03:00:09PM +0800, Yongkai Wu wrote:<br>
&gt; when isolate_huge_page() return false,it won&#39;t takes a refcount of=
 page,<br>
&gt; if we call put_hwpoison_page() in that case,we may hit the VM_BUG_ON_P=
AGE!<br>
&gt; <br>
&gt; Signed-off-by: Yongkai Wu &lt;<a href=3D"mailto:nic_w@163.com" target=
=3D"_blank">nic_w@163.com</a>&gt;<br>
&gt; ---<br>
&gt;=C2=A0 mm/memory-failure.c | 13 +++++++------<br>
&gt;=C2=A0 1 file changed, 7 insertions(+), 6 deletions(-)<br>
&gt; <br>
&gt; diff --git a/mm/memory-failure.c b/mm/memory-failure.c<br>
&gt; index 0cd3de3..ed09f56 100644<br>
&gt; --- a/mm/memory-failure.c<br>
&gt; +++ b/mm/memory-failure.c<br>
&gt; @@ -1699,12 +1699,13 @@ static int soft_offline_huge_page(struct page =
*page,<br>
&gt; int flags)<br>
&gt;=C2=A0 =C2=A0unlock_page(hpage);<br>
&gt;=C2=A0 <br>
&gt;=C2=A0 =C2=A0ret =3D isolate_huge_page(hpage, &amp;pagelist);<br>
&gt; - /*<br>
&gt; - * get_any_page() and isolate_huge_page() takes a refcount each,<br>
&gt; - * so need to drop one here.<br>
&gt; - */<br>
&gt; - put_hwpoison_page(hpage);<br>
&gt; - if (!ret) {<br>
&gt; + if (ret) {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 /*<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * get_any_page() and isolate_huge_=
page() takes a refcount each,<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * so need to drop one here.<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 */<br>
&gt; + put_hwpoison_page(hpage);<br>
&gt; + } else {<br>
<br>
Hi Yongkai,<br>
<br>
Although the current code might look odd, it&#39;s OK. We have to release<b=
r>
one refcount whether this isolate_huge_page() succeeds or not, because<br>
the put_hwpoison_page() is cancelling the refcount from get_any_page()<br>
which always succeeds when we enter soft_offline_huge_page().<br>
<br>
Let&#39;s consider that the isolate_huge_page() fails with your patch appli=
ed,<br>
then the refcount taken by get_any_page() is never released after returning=
<br>
from soft_offline_page(). That will lead to memory leak.<br>
<br>
I think that current code comment doesn&#39;t explaing it well, so if you<b=
r>
like, you can fix the comment.=C2=A0 (If you do that, please check coding s=
tyle.<br>
scripts/<a href=3D"http://checkpatch.pl" rel=3D"noreferrer" target=3D"_blan=
k">checkpatch.pl</a> will help you.)<br>
<br>
Thanks,<br>
Naoya Horiguchi<br>
</blockquote></div>

--000000000000857ecf057a883cc9--
