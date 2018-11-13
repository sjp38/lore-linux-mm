Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5878B6B0010
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 10:12:38 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id a14-v6so5779349ybk.23
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 07:12:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u78-v6sor8447299ybi.79.2018.11.13.07.12.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Nov 2018 07:12:36 -0800 (PST)
MIME-Version: 1.0
References: <CAJtqMcZp5AVva2yOM4gJET8Gd_j_BGJDLTkcqRdJynVCiRRFxQ@mail.gmail.com>
 <20181113130433.GB16182@dhcp22.suse.cz>
In-Reply-To: <20181113130433.GB16182@dhcp22.suse.cz>
From: Yongkai Wu <nic.wuyk@gmail.com>
Date: Tue, 13 Nov 2018 23:12:24 +0800
Message-ID: <CAJtqMcY98hARD-_FmGYt875Tr6qmMP+42O7OWXNny6rD8ag91A@mail.gmail.com>
Subject: Re: [PATCH] mm/hugetl.c: keep the page mapping info when
 free_huge_page() hit the VM_BUG_ON_PAGE
Content-Type: multipart/alternative; boundary="0000000000006e041d057a8d3fdc"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: mike.kravetz@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--0000000000006e041d057a8d3fdc
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Dear Maintainer,
Actually i met a VM_BUG_ON_PAGE issue in centos7.4 some days ago.When the
issue first happen,
i just can know that it happen in free_huge_page() when doing soft offline
huge page.
But because page->mapping is set to null,i can not get any further
information how the issue happen.

So i modified the code as the patch show,and apply the new code to our
produce line and wait some time,
then the issue come again.And this time i can know the whole file path
which trigger the issue by using
crash tool to get the inode=E3=80=81dentry and so on,that help me to find a=
 way to
reproduce the issue quite easily
and finally found the root cause and solve it.

I think if keep the page->mapping,we can even do the rmap to check more
detail info too by using the crash tool to analyse the coredump.
So i think preservning the page state would more or less help to debug.
But if it is not so meaningful,just let it go. ^_^

Thank you for your time.

Best Regards

On Tue, Nov 13, 2018 at 9:04 PM Michal Hocko <mhocko@kernel.org> wrote:

> On Tue 13-11-18 20:38:16, Yongkai Wu wrote:
> > It is better to keep page mapping info when free_huge_page() hit the
> > VM_BUG_ON_PAGE,
> > so we can get more infomation from the coredump for further analysis.
>
> The patch seems to be whitespace damaged. Put that aside, have you
> actually seen a case where preservning the page state would help to nail
> down any bug.
>
> I am not objecting to the patch, it actually makes some sense to me, I
> am just curious about a background motivation.
>
> > Signed-off-by: Yongkai Wu <nic_w@163.com>
> > ---
> >  mm/hugetlb.c | 5 +++--
> >  1 file changed, 3 insertions(+), 2 deletions(-)
> >
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index c007fb5..ba693bb 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -1248,10 +1248,11 @@ void free_huge_page(struct page *page)
> >   (struct hugepage_subpool *)page_private(page);
> >   bool restore_reserve;
> >
> > +        VM_BUG_ON_PAGE(page_count(page), page);
> > +        VM_BUG_ON_PAGE(page_mapcount(page), page);
> > +
> >   set_page_private(page, 0);
> >   page->mapping =3D NULL;
> > - VM_BUG_ON_PAGE(page_count(page), page);
> > - VM_BUG_ON_PAGE(page_mapcount(page), page);
> >   restore_reserve =3D PagePrivate(page);
> >   ClearPagePrivate(page);
> >
> > --
> > 1.8.3.1
>
> --
> Michal Hocko
> SUSE Labs
>

--0000000000006e041d057a8d3fdc
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><div>Dear Maintainer,</div><div>Actually =
i met a VM_BUG_ON_PAGE issue in centos7.4 some days ago.When the issue firs=
t happen,</div><div>i just can know that it happen in free_huge_page() when=
 doing soft offline huge page.</div><div>But because page-&gt;mapping is se=
t to null,i can not get any further information how the issue happen.</div>=
<div><br></div><div>So i modified the code as the patch show,and apply the =
new code to our produce line and wait some time,</div><div>then the issue c=
ome again.And this time i can know the whole file path which trigger the is=
sue by using=C2=A0</div><div>crash tool to get the inode=E3=80=81dentry and=
 so on,that help me to find a way to reproduce the issue quite easily</div>=
<div>and finally found the root cause and solve it.</div><div><br></div><di=
v>I think if keep the page-&gt;mapping,we can even do the rmap to check mor=
e detail info too by using the crash tool to analyse the coredump.</div><di=
v>So i think preservning the page state would more or less help to debug.</=
div><div>But if it is not so meaningful,just let it go. ^_^</div><div><br><=
/div><div>Thank you for your time.</div><div><br></div><div>Best Regards</d=
iv></div></div><br><div class=3D"gmail_quote"><div dir=3D"ltr">On Tue, Nov =
13, 2018 at 9:04 PM Michal Hocko &lt;<a href=3D"mailto:mhocko@kernel.org">m=
hocko@kernel.org</a>&gt; wrote:<br></div><blockquote class=3D"gmail_quote" =
style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">On =
Tue 13-11-18 20:38:16, Yongkai Wu wrote:<br>
&gt; It is better to keep page mapping info when free_huge_page() hit the<b=
r>
&gt; VM_BUG_ON_PAGE,<br>
&gt; so we can get more infomation from the coredump for further analysis.<=
br>
<br>
The patch seems to be whitespace damaged. Put that aside, have you<br>
actually seen a case where preservning the page state would help to nail<br=
>
down any bug.<br>
<br>
I am not objecting to the patch, it actually makes some sense to me, I<br>
am just curious about a background motivation.<br>
<br>
&gt; Signed-off-by: Yongkai Wu &lt;<a href=3D"mailto:nic_w@163.com" target=
=3D"_blank">nic_w@163.com</a>&gt;<br>
&gt; ---<br>
&gt;=C2=A0 mm/hugetlb.c | 5 +++--<br>
&gt;=C2=A0 1 file changed, 3 insertions(+), 2 deletions(-)<br>
&gt; <br>
&gt; diff --git a/mm/hugetlb.c b/mm/hugetlb.c<br>
&gt; index c007fb5..ba693bb 100644<br>
&gt; --- a/mm/hugetlb.c<br>
&gt; +++ b/mm/hugetlb.c<br>
&gt; @@ -1248,10 +1248,11 @@ void free_huge_page(struct page *page)<br>
&gt;=C2=A0 =C2=A0(struct hugepage_subpool *)page_private(page);<br>
&gt;=C2=A0 =C2=A0bool restore_reserve;<br>
&gt; <br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 VM_BUG_ON_PAGE(page_count(page), page);<b=
r>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 VM_BUG_ON_PAGE(page_mapcount(page), page)=
;<br>
&gt; +<br>
&gt;=C2=A0 =C2=A0set_page_private(page, 0);<br>
&gt;=C2=A0 =C2=A0page-&gt;mapping =3D NULL;<br>
&gt; - VM_BUG_ON_PAGE(page_count(page), page);<br>
&gt; - VM_BUG_ON_PAGE(page_mapcount(page), page);<br>
&gt;=C2=A0 =C2=A0restore_reserve =3D PagePrivate(page);<br>
&gt;=C2=A0 =C2=A0ClearPagePrivate(page);<br>
&gt; <br>
&gt; -- <br>
&gt; 1.8.3.1<br>
<br>
-- <br>
Michal Hocko<br>
SUSE Labs<br>
</blockquote></div>

--0000000000006e041d057a8d3fdc--
