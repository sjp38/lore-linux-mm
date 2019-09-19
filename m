Return-Path: <SRS0=3rjY=XO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC36EC49ED7
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 06:47:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DD7F21848
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 06:47:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="W4Gzy1TY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DD7F21848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CEF956B033B; Thu, 19 Sep 2019 02:47:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C9FA66B033D; Thu, 19 Sep 2019 02:47:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB5426B033E; Thu, 19 Sep 2019 02:47:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0012.hostedemail.com [216.40.44.12])
	by kanga.kvack.org (Postfix) with ESMTP id 99F376B033B
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 02:47:45 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 1044983E5
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 06:47:45 +0000 (UTC)
X-FDA: 75950739690.29.shake83_60a73907efa20
X-HE-Tag: shake83_60a73907efa20
X-Filterd-Recvd-Size: 14086
Received: from mail-lf1-f67.google.com (mail-lf1-f67.google.com [209.85.167.67])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 06:47:44 +0000 (UTC)
Received: by mail-lf1-f67.google.com with SMTP id u28so1491937lfc.5
        for <linux-mm@kvack.org>; Wed, 18 Sep 2019 23:47:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=qxUMZyUmNUkIdMHlYRe+Ie5w/3o+hNg6qylThKDX2aA=;
        b=W4Gzy1TYc91ENMLyQhaESayEMBx1CSVvEniI4lSmRqN+u8aOjhpPboZJktbKXLyRi/
         /HgcV08mScX4mZYzxsIFLo4+fExMc23pv8E3a3qDH8TLg2ABAzpD6tn0DJADRmfwsiIY
         wqgIfhvXHreW6pMWPxEh2U5EOCqZ9yT7f+BDM2QRyoRlwRe0RLKefxxyo3rTbOLfTh+B
         L6ikX4gde0TcVJa2Rgd8/rbkbRtfjn3LeJdGW3n7RKpFJfo49xDDCzv6CqGSIGOLp0r8
         vlBj8if4iehZ+6vm7KXybj+sy8sgFmQV+j7WEX5pnUr/4WNDvou+fBjxo7EoUa02Z4oy
         9BjQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=qxUMZyUmNUkIdMHlYRe+Ie5w/3o+hNg6qylThKDX2aA=;
        b=npg6JDR6b1BjIOMUjKLgkeXB8ka9p6q2wphgQI8BqS5gMHkLo09Vb/bItzGrkfVC2E
         47OpyAKWeOBKcJCAdwCO6KJhZZm1wHoe/ZjDhHbtlQnLEWJSqmAIoaU6GubbmEd4clAS
         vz4f/mIwO8Mu3LzuCSi6Z4/KNErYJOCyWqk8kREon3a0+U8mOMULgyzksg+wztWyQSjC
         EuBgNTDP+hb7QwUcvZG36HySsOv3j7ej0E6zTAvHj155rwKQ0cTSpN7hZTcMDk3zJzLe
         d3sW6DHtVS9XZ8ZT2CPaKPOp4DowKVCo4da3ZGRYked7rKyOHZIYV8f2+BX78XK/AFNs
         uzAg==
X-Gm-Message-State: APjAAAW1PmoRo7YI39avysFWJhduMDQojH5T+DM77rq0y8ttUOqXxH8G
	1C/OWOBL9IY+Ct67P6q2Jp2nRzWv3vtWPgLfrLs=
X-Google-Smtp-Source: APXvYqyl5gS6YzDXS+9E+iVK6yzK6t5AfDFy77FtEa10DNtihT6fk5aN1j2ErBzykvAVnQ0zb36apdKj97lkG0eS+Jc=
X-Received: by 2002:ac2:4d04:: with SMTP id r4mr4026927lfi.57.1568875662261;
 Wed, 18 Sep 2019 23:47:42 -0700 (PDT)
MIME-Version: 1.0
References: <20190917185352.44cf285d3ebd9e64548de5de@gmail.com> <d6214fbd-e757-43a9-ab12-4b61fde434db@suse.cz>
In-Reply-To: <d6214fbd-e757-43a9-ab12-4b61fde434db@suse.cz>
From: Markus Linnala <markus.linnala@gmail.com>
Date: Thu, 19 Sep 2019 09:47:30 +0300
Message-ID: <CAH6yVy1=P79_CCT0_3_97iyZdvy0NhRUbsrtydAi+UUSRYZi4w@mail.gmail.com>
Subject: Re: [PATCH] z3fold: fix memory leak in kmem cache
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Vitaly Wool <vitalywool@gmail.com>, Linux-MM <linux-mm@kvack.org>, 
	Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, 
	Dan Streetman <ddstreet@ieee.org>
Content-Type: multipart/alternative; boundary="0000000000008bc1240592e25407"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--0000000000008bc1240592e25407
Content-Type: text/plain; charset="UTF-8"

ke 18. syysk. 2019 klo 10.35 Vlastimil Babka (vbabka@suse.cz) kirjoitti:

> On 9/17/19 5:53 PM, Vitaly Wool wrote:
> > Currently there is a leak in init_z3fold_page() -- it allocates
> > handles from kmem cache even for headless pages, but then they are
> > never used and never freed, so eventually kmem cache may get
> > exhausted. This patch provides a fix for that.
> >
> > Reported-by: Markus Linnala <markus.linnala@gmail.com>
> > Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
>
> Can a Fixes: commit be pinpointed, and CC stable added?
>
> > ---
> >  mm/z3fold.c | 15 +++++++++------
> >  1 file changed, 9 insertions(+), 6 deletions(-)
> >
> > diff --git a/mm/z3fold.c b/mm/z3fold.c
> > index 6397725b5ec6..7dffef2599c3 100644
> > --- a/mm/z3fold.c
> > +++ b/mm/z3fold.c
> > @@ -301,14 +301,11 @@ static void z3fold_unregister_migration(struct
> z3fold_pool *pool)
> >   }
> >
> >  /* Initializes the z3fold header of a newly allocated z3fold page */
> > -static struct z3fold_header *init_z3fold_page(struct page *page,
> > +static struct z3fold_header *init_z3fold_page(struct page *page, bool
> headless,
> >                                       struct z3fold_pool *pool, gfp_t
> gfp)
> >  {
> >       struct z3fold_header *zhdr = page_address(page);
> > -     struct z3fold_buddy_slots *slots = alloc_slots(pool, gfp);
> > -
> > -     if (!slots)
> > -             return NULL;
> > +     struct z3fold_buddy_slots *slots;
> >
> >       INIT_LIST_HEAD(&page->lru);
> >       clear_bit(PAGE_HEADLESS, &page->private);
> > @@ -316,6 +313,12 @@ static struct z3fold_header
> *init_z3fold_page(struct page *page,
> >       clear_bit(NEEDS_COMPACTING, &page->private);
> >       clear_bit(PAGE_STALE, &page->private);
> >       clear_bit(PAGE_CLAIMED, &page->private);
> > +     if (headless)
> > +             return zhdr;
> > +
> > +     slots = alloc_slots(pool, gfp);
> > +     if (!slots)
> > +             return NULL;
> >
> >       spin_lock_init(&zhdr->page_lock);
> >       kref_init(&zhdr->refcount);
> > @@ -962,7 +965,7 @@ static int z3fold_alloc(struct z3fold_pool *pool,
> size_t size, gfp_t gfp,
> >       if (!page)
> >               return -ENOMEM;
> >
> > -     zhdr = init_z3fold_page(page, pool, gfp);
> > +     zhdr = init_z3fold_page(page, bud == HEADLESS, pool, gfp);
> >       if (!zhdr) {
> >               __free_page(page);
> >               return -ENOMEM;
> >
>
>
I have somwhat extensive test suite for this issue. Effectively:

for tmout in 10 10 10 10 10 10 10 10 10 10 10 10 20 20 20 20 20 20 30 30 30
30 900; do
stress --vm $(($(nproc)+2)) --vm-bytes $(($(awk '"'"'/MemAvail/{print
$2}'"'"' /proc/meminfo)*1024/$(nproc))) --timeout '"$tmout"
done

and then in another session run:

while true; do
bash -c '
declare -A arr;
b=();
for a in $(seq 7000);do
    b+=($a);
    arr["$a"]="${b[@]}";
done;
sleep 60;
'
sleep 20
done

This should make testing machine to have near constant memory pressure from
stress and then swapping and releasing swap from other script. And then
there is tons of stuff to manage virtual machine when it is stuck, update
kernels, collect logs and analyze logs.

I run tests in virtual machine (Fedora 30) with 4 vCPU 1 GiB memory.

There was still some issues with this patch. I ran my test suite about 72
hours and got 5 issues.

Vitaly send me patch with additional lines about page_claimed bit. After
running my test suite so far about 65 hours there has not been any issues.

When I first saw issues with zswap, I did git bisect run from v5.1 (good)
to v5.3-rc4 (bad) and got this:

commit 7c2b8baa61fe578af905342938ad12f8dbaeae79
Author: Vitaly Wool <...>
Date:   Mon May 13 17:22:49 2019 -0700

    mm/z3fold.c: add structure for buddy handles

    For z3fold to be able to move its pages per request of the memory
    subsystem, it should not use direct object addresses in handles.
Instead,
    it will create abstract handles (3 per page) which will contain pointers
    to z3fold objects.  Thus, it will be possible to change these pointers
    when z3fold page is moved.

--0000000000008bc1240592e25407
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><div><div><div>ke 18. syysk. 2019 klo 10.=
35 Vlastimil Babka (<a href=3D"mailto:vbabka@suse.cz" target=3D"_blank">vba=
bka@suse.cz</a>) kirjoitti:<br></div></div></div></div><div class=3D"gmail_=
quote"><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;=
border-left:1px solid rgb(204,204,204);padding-left:1ex">On 9/17/19 5:53 PM=
, Vitaly Wool wrote:<br>
&gt; Currently there is a leak in init_z3fold_page() -- it allocates<br>
&gt; handles from kmem cache even for headless pages, but then they are<br>
&gt; never used and never freed, so eventually kmem cache may get<br>
&gt; exhausted. This patch provides a fix for that.<br>
&gt; <br>
&gt; Reported-by: Markus Linnala &lt;<a href=3D"mailto:markus.linnala@gmail=
.com" target=3D"_blank">markus.linnala@gmail.com</a>&gt;<br>
&gt; Signed-off-by: Vitaly Wool &lt;<a href=3D"mailto:vitalywool@gmail.com"=
 target=3D"_blank">vitalywool@gmail.com</a>&gt;<br>
<br>
Can a Fixes: commit be pinpointed, and CC stable added?<br>
<br>
&gt; ---<br>
&gt;=C2=A0 mm/z3fold.c | 15 +++++++++------<br>
&gt;=C2=A0 1 file changed, 9 insertions(+), 6 deletions(-)<br>
&gt; <br>
&gt; diff --git a/mm/z3fold.c b/mm/z3fold.c<br>
&gt; index 6397725b5ec6..7dffef2599c3 100644<br>
&gt; --- a/mm/z3fold.c<br>
&gt; +++ b/mm/z3fold.c<br>
&gt; @@ -301,14 +301,11 @@ static void z3fold_unregister_migration(struct z=
3fold_pool *pool)<br>
&gt;=C2=A0 =C2=A0}<br>
&gt;=C2=A0 <br>
&gt;=C2=A0 /* Initializes the z3fold header of a newly allocated z3fold pag=
e */<br>
&gt; -static struct z3fold_header *init_z3fold_page(struct page *page,<br>
&gt; +static struct z3fold_header *init_z3fold_page(struct page *page, bool=
 headless,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct=
 z3fold_pool *pool, gfp_t gfp)<br>
&gt;=C2=A0 {<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0struct z3fold_header *zhdr =3D page_address(=
page);<br>
&gt; -=C2=A0 =C2=A0 =C2=A0struct z3fold_buddy_slots *slots =3D alloc_slots(=
pool, gfp);<br>
&gt; -<br>
&gt; -=C2=A0 =C2=A0 =C2=A0if (!slots)<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return NULL;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0struct z3fold_buddy_slots *slots;<br>
&gt;=C2=A0 <br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0INIT_LIST_HEAD(&amp;page-&gt;lru);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0clear_bit(PAGE_HEADLESS, &amp;page-&gt;priva=
te);<br>
&gt; @@ -316,6 +313,12 @@ static struct z3fold_header *init_z3fold_page(str=
uct page *page,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0clear_bit(NEEDS_COMPACTING, &amp;page-&gt;pr=
ivate);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0clear_bit(PAGE_STALE, &amp;page-&gt;private)=
;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0clear_bit(PAGE_CLAIMED, &amp;page-&gt;privat=
e);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0if (headless)<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return zhdr;<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0slots =3D alloc_slots(pool, gfp);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0if (!slots)<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return NULL;<br>
&gt;=C2=A0 <br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_init(&amp;zhdr-&gt;page_lock);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0kref_init(&amp;zhdr-&gt;refcount);<br>
&gt; @@ -962,7 +965,7 @@ static int z3fold_alloc(struct z3fold_pool *pool, =
size_t size, gfp_t gfp,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0if (!page)<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -ENOMEM;<=
br>
&gt;=C2=A0 <br>
&gt; -=C2=A0 =C2=A0 =C2=A0zhdr =3D init_z3fold_page(page, pool, gfp);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0zhdr =3D init_z3fold_page(page, bud =3D=3D HEADLE=
SS, pool, gfp);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0if (!zhdr) {<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__free_page(page=
);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -ENOMEM;<=
br>
&gt; <br>
<br></blockquote><div><br></div>I have somwhat extensive test suite for thi=
s issue. Effectively:</div><div class=3D"gmail_quote"><br></div><div class=
=3D"gmail_quote">for tmout in 10 10 10 10 10 10 10 10 10 10 10 10 20 20 20 =
20 20 20 30 30 30 30 900; do<br></div><div class=3D"gmail_quote">stress --v=
m $(($(nproc)+2)) --vm-bytes $(($(awk &#39;&quot;&#39;&quot;&#39;/MemAvail/=
{print $2}&#39;&quot;&#39;&quot;&#39; /proc/meminfo)*1024/$(nproc))) --time=
out &#39;&quot;$tmout&quot;<br></div><div class=3D"gmail_quote">done</div><=
div class=3D"gmail_quote"><br></div><div class=3D"gmail_quote">and then in =
another session run:</div><div class=3D"gmail_quote"><br></div><div class=
=3D"gmail_quote">while true; do</div><div class=3D"gmail_quote">bash -c &#3=
9;</div><div class=3D"gmail_quote">declare -A arr;<br>b=3D();<br>for a in $=
(seq 7000);do<br>=C2=A0 =C2=A0 b+=3D($a);<br>=C2=A0 =C2=A0 arr[&quot;$a&quo=
t;]=3D&quot;${b[@]}&quot;;<br>done;<br>sleep 60;<br></div><div class=3D"gma=
il_quote">&#39;</div><div class=3D"gmail_quote">sleep 20</div><div class=3D=
"gmail_quote">done</div><div class=3D"gmail_quote"><br></div><div class=3D"=
gmail_quote">This should make testing machine to have near constant memory =
pressure from stress and then swapping and releasing swap from other script=
. And then there is tons of stuff to manage virtual machine when it is stuc=
k, update kernels, collect logs and analyze logs.</div><div class=3D"gmail_=
quote"><br></div><div class=3D"gmail_quote">I run tests in virtual machine =
(Fedora 30) with 4 vCPU 1 GiB memory.</div><div class=3D"gmail_quote"><br><=
/div><div class=3D"gmail_quote">There was still some issues with this patch=
. I ran my test suite about 72 hours and got 5 issues.=C2=A0</div><div clas=
s=3D"gmail_quote"><br></div><div class=3D"gmail_quote">Vitaly send me patch=
 with additional lines about page_claimed bit. After running my test suite =
so far about 65 hours there has not been any issues.</div><div class=3D"gma=
il_quote"><br></div><div class=3D"gmail_quote">When I first saw issues with=
 zswap, I did git bisect run from v5.1 (good) to v5.3-rc4 (bad) and got thi=
s:<br></div><div class=3D"gmail_quote"><div><br></div><div>commit 7c2b8baa6=
1fe578af905342938ad12f8dbaeae79<br>Author: Vitaly Wool &lt;...&gt;<br>Date:=
 =C2=A0 Mon May 13 17:22:49 2019 -0700<br><br>=C2=A0 =C2=A0 mm/z3fold.c: ad=
d structure for buddy handles<br>=C2=A0 =C2=A0 <br>=C2=A0 =C2=A0 For z3fold=
 to be able to move its pages per request of the memory<br>=C2=A0 =C2=A0 su=
bsystem, it should not use direct object addresses in handles.=C2=A0 Instea=
d,<br>=C2=A0 =C2=A0 it will create abstract handles (3 per page) which will=
 contain pointers<br>=C2=A0 =C2=A0 to z3fold objects.=C2=A0 Thus, it will b=
e possible to change these pointers<br>=C2=A0 =C2=A0 when z3fold page is mo=
ved.<br></div><div><br></div></div>
</div>

--0000000000008bc1240592e25407--

