Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 970B8C76190
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:02:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4BE6022BE8
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:02:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IEDw3NPr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4BE6022BE8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED25E6B0003; Thu, 25 Jul 2019 14:02:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E5BB08E0003; Thu, 25 Jul 2019 14:02:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D4B4B8E0002; Thu, 25 Jul 2019 14:02:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id B36A86B0003
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 14:02:16 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id r27so55731070iob.14
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 11:02:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=KPzR1wWvIkg0tL1aSqNSu1pGs1ThRkzvtOtRs/z9zmY=;
        b=V3lRfe+fWRRxgnUCkp4pKvFXq/diipxFbnA03igAaFjVMbVConstlmpkN71OmGmwXn
         fXHh8stfvPnuB0a94ty+3R4fHlsEIvVcRkwhpvF2178KF2D+uXv1Zr4xiLMbfj0+xhfw
         DvOzEaGLpM+HQwBXAN9Lp34vAHAIvqpBEYnJI+0kvzxFLqzgSnCHaXmR8vBNq+WRPYB2
         u0Ed4FsYuprWLkPjk/CzyAa8yTUKUWEQHbn8KGjveZ7H6AJXDl79ELJWDjjXULH+Ok/6
         jT/AjdFAFcadDwwiBjDytKb9T6P5fm4RVxiP88RB2QSY5MBNpgrU3ulolkOlYZZ/FOG5
         qu4Q==
X-Gm-Message-State: APjAAAXIHEwLUtACfTi6d2w4lNvVXGd7aCtfbUZT5lhOeYEJMh0ZahcE
	5tut261y0gc2LTWffMRWrZU49XKJ2AeOQ0bq8zxc27bmteqDoZe5BOqP5LRc2dGgXoJ8NLA/kJ/
	ukZgIfENdWJDQPePoxy87kxdBSE5sgwk1BVwETkeC/+hJRIOl6jfkcDX6160zpJBQzg==
X-Received: by 2002:a02:5b05:: with SMTP id g5mr89581959jab.114.1564077736504;
        Thu, 25 Jul 2019 11:02:16 -0700 (PDT)
X-Received: by 2002:a02:5b05:: with SMTP id g5mr89581906jab.114.1564077735900;
        Thu, 25 Jul 2019 11:02:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564077735; cv=none;
        d=google.com; s=arc-20160816;
        b=e5aSGR+wrObd9yhg6rXugDDYU8G+OVQtH12jAKctGXbSaXR3unlh8+AhooDsDmvl2T
         6+jNEfcmm9TwPf9yiJi2FGgaS3c2qmeedrzDQr2olnb1nS4DgpSEdVc4vNkIPpk/l17B
         PEjBs2vTbR0JlkORwcC/+4Y5ONqQJfTGldc7IaH+7h8O+qj2x7DqgcpIvhnONWXEsmxY
         l0Z2SrJIyxsLhcw9Ynfx8u/LrIgTdughWlknOF7K2idhTvAWI1ZKw5bT03wQD4HroNJ4
         ueo7npMaF67G/uMBBjBuEkKcgLaEPvaVAOcovJ6KXpz0YmcxuyzgHZMysfK4Jbm+TvsL
         k11Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=KPzR1wWvIkg0tL1aSqNSu1pGs1ThRkzvtOtRs/z9zmY=;
        b=t5TQOvadKD+vu+XsMUh9yBCZlSsCDl1RKG37naGnPJ/LSh3I5G2EBPegW77SwQdNkU
         d/FH7w9leevbAe8QsZwHYEMNFIf8aiBl0ALUrqzABkTHGxNPNqtG/lZl32VHxSdEaJyt
         Ja4KeorPZn94UhJx+jWm7acr+WPJ6fxv9PUTTUlO1Tzm60RCVhlOOgc5vOYv5l4PmUNP
         46ZLRLIJc6wUrWPozhVWkgao5ytzRHxu/2tHSQndgto0ICq3PeURk2mbs0gU5zYDinIX
         JkX3rxJVTAbnl4QwCSmg5MpqLQZRG7/rWHmUG97x/Jp1agjtypWFC6weC5PPcHhFRN8S
         +wGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=IEDw3NPr;
       spf=pass (google.com: domain of navid.emamdoost@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=navid.emamdoost@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v17sor34252931iol.33.2019.07.25.11.02.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 11:02:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of navid.emamdoost@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=IEDw3NPr;
       spf=pass (google.com: domain of navid.emamdoost@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=navid.emamdoost@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=KPzR1wWvIkg0tL1aSqNSu1pGs1ThRkzvtOtRs/z9zmY=;
        b=IEDw3NPrZNAajuXeWjw6fQ4JejUSEC7f2ZMPYYM9HETSYh+I/1BqJ18+JUT6fcMAro
         y20ZrN4LJ2hBIAW212ufeCDzyzsH0ol49rcwDF3uKSBNa2pA5Gl3SOOJ/sBPewztkvDp
         ZWZJ+UbloBgFXMZn14CkNS6naaU9Aqh+MNyNK6zF4HpUVksFuFVYo2lw3WPaxFyNg8To
         nRe3t19kkN8iaSRHgSN2bz7hjH7ERI+Mp/Sg6b1+2RTZlZuEb9TqMhEG6tiaM+ubHNwR
         CjCYJ/wA4moxVlv7ZxvFqZnXlb0PcQ9CY/QCHpsfbv+VLI9HR5TFm1zcv+uJ/kgPDfpY
         iIQQ==
X-Google-Smtp-Source: APXvYqwbpf+TMNiWknA7K8A9ZVDSzMImtnJCu9YAGn/z8n97vnrDcHN3DRiBalM9qMj+OL4XWbjcQ0kmbS70QfhqcfQ=
X-Received: by 2002:a5d:9acf:: with SMTP id x15mr55498109ion.190.1564077735425;
 Thu, 25 Jul 2019 11:02:15 -0700 (PDT)
MIME-Version: 1.0
References: <20190725013944.20661-1-navid.emamdoost@gmail.com> <44c005c2-2b4f-d1da-0437-fe4c90f883ae@oracle.com>
In-Reply-To: <44c005c2-2b4f-d1da-0437-fe4c90f883ae@oracle.com>
From: Navid Emamdoost <navid.emamdoost@gmail.com>
Date: Thu, 25 Jul 2019 13:02:03 -0500
Message-ID: <CAEkB2EQzwFGWF91+3PXrXScYywQLX89Vcik6NqtxAvDJyer-nw@mail.gmail.com>
Subject: Re: [PATCH] mm/hugetlb.c: check the failure case for find_vma
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Navid Emamdoost <emamd001@umn.edu>, kjlu@umn.edu, Stephen McCamant <smccaman@umn.edu>, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org
Content-Type: multipart/alternative; boundary="000000000000d239e4058e85392c"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--000000000000d239e4058e85392c
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Mike,

Thanks for your detailed explanation. I see that for huge_pte_alloc the
address is checked to be within vma.

Best regards,

On Thu, Jul 25, 2019 at 12:53 PM Mike Kravetz <mike.kravetz@oracle.com>
wrote:

> On 7/24/19 6:39 PM, Navid Emamdoost wrote:
> > find_vma may fail and return NULL. The null check is added.
> >
> > Signed-off-by: Navid Emamdoost <navid.emamdoost@gmail.com>
> > ---
> >  mm/hugetlb.c | 3 +++
> >  1 file changed, 3 insertions(+)
> >
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index ede7e7f5d1ab..9c5e8b7a6476 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -4743,6 +4743,9 @@ void adjust_range_if_pmd_sharing_possible(struct
> vm_area_struct *vma,
> >  pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t
> *pud)
> >  {
> >       struct vm_area_struct *vma =3D find_vma(mm, addr);
> > +     if (!vma)
> > +             return (pte_t *)pmd_alloc(mm, pud, addr);
> > +
>
> Hello Navid,
>
> You should not mix declarations and code like this.  I am surprised that
> your
> compiler did not issue a warning such as:
>
> mm/hugetlb.c: In function =E2=80=98huge_pmd_share=E2=80=99:
> mm/hugetlb.c:4815:2: warning: ISO C90 forbids mixed declarations and code
> [-Wdeclaration-after-statement]
>   struct address_space *mapping =3D vma->vm_file->f_mapping;
>   ^~~~~~
>
> While it is true that the routine find_vma can return NULL.  I do not
> believe it is possible here within the context of huge_pmd_share.  Why?
>
> huge_pmd_share is called from huge_pte_alloc to allocate a page table
> entry for a huge page.  So, the calling code is attempting to populate
> page tables.  There are three callers of huge_pte_alloc: hugetlb_fault,
> copy_hugetlb_page_range and __mcopy_atomic_hugetlb.  In each of these
> routines (or their callers) it has been verified that address is within
> a vma.  In addition, mmap_sem is held so that vmas can not change.
> Therefore, there should be no way for find_vma to return NULL here.
>
> Please let me know if there is something I have overlooked.  Otherwise,
> there is no need for such a modification.
> --
> Mike Kravetz
>
> >       struct address_space *mapping =3D vma->vm_file->f_mapping;
> >       pgoff_t idx =3D ((addr - vma->vm_start) >> PAGE_SHIFT) +
> >                       vma->vm_pgoff;
> >
>


--=20
Navid.

--000000000000d239e4058e85392c
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi Mike,<div><br></div><div>Thanks for your detailed expla=
nation. I see that for huge_pte_alloc the address is checked to be within v=
ma.</div><div><br></div><div>Best=C2=A0regards,</div></div><br><div class=
=3D"gmail_quote"><div dir=3D"ltr" class=3D"gmail_attr">On Thu, Jul 25, 2019=
 at 12:53 PM Mike Kravetz &lt;<a href=3D"mailto:mike.kravetz@oracle.com">mi=
ke.kravetz@oracle.com</a>&gt; wrote:<br></div><blockquote class=3D"gmail_qu=
ote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,20=
4);padding-left:1ex">On 7/24/19 6:39 PM, Navid Emamdoost wrote:<br>
&gt; find_vma may fail and return NULL. The null check is added.<br>
&gt; <br>
&gt; Signed-off-by: Navid Emamdoost &lt;<a href=3D"mailto:navid.emamdoost@g=
mail.com" target=3D"_blank">navid.emamdoost@gmail.com</a>&gt;<br>
&gt; ---<br>
&gt;=C2=A0 mm/hugetlb.c | 3 +++<br>
&gt;=C2=A0 1 file changed, 3 insertions(+)<br>
&gt; <br>
&gt; diff --git a/mm/hugetlb.c b/mm/hugetlb.c<br>
&gt; index ede7e7f5d1ab..9c5e8b7a6476 100644<br>
&gt; --- a/mm/hugetlb.c<br>
&gt; +++ b/mm/hugetlb.c<br>
&gt; @@ -4743,6 +4743,9 @@ void adjust_range_if_pmd_sharing_possible(struct=
 vm_area_struct *vma,<br>
&gt;=C2=A0 pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, =
pud_t *pud)<br>
&gt;=C2=A0 {<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0struct vm_area_struct *vma =3D find_vma(mm, =
addr);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0if (!vma)<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return (pte_t *)pmd_a=
lloc(mm, pud, addr);<br>
&gt; +<br>
<br>
Hello Navid,<br>
<br>
You should not mix declarations and code like this.=C2=A0 I am surprised th=
at your<br>
compiler did not issue a warning such as:<br>
<br>
mm/hugetlb.c: In function =E2=80=98huge_pmd_share=E2=80=99:<br>
mm/hugetlb.c:4815:2: warning: ISO C90 forbids mixed declarations and code [=
-Wdeclaration-after-statement]<br>
=C2=A0 struct address_space *mapping =3D vma-&gt;vm_file-&gt;f_mapping;<br>
=C2=A0 ^~~~~~<br>
<br>
While it is true that the routine find_vma can return NULL.=C2=A0 I do not<=
br>
believe it is possible here within the context of huge_pmd_share.=C2=A0 Why=
?<br>
<br>
huge_pmd_share is called from huge_pte_alloc to allocate a page table<br>
entry for a huge page.=C2=A0 So, the calling code is attempting to populate=
<br>
page tables.=C2=A0 There are three callers of huge_pte_alloc: hugetlb_fault=
,<br>
copy_hugetlb_page_range and __mcopy_atomic_hugetlb.=C2=A0 In each of these<=
br>
routines (or their callers) it has been verified that address is within<br>
a vma.=C2=A0 In addition, mmap_sem is held so that vmas can not change.<br>
Therefore, there should be no way for find_vma to return NULL here.<br>
<br>
Please let me know if there is something I have overlooked.=C2=A0 Otherwise=
,<br>
there is no need for such a modification.<br>
-- <br>
Mike Kravetz<br>
<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0struct address_space *mapping =3D vma-&gt;vm=
_file-&gt;f_mapping;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0pgoff_t idx =3D ((addr - vma-&gt;vm_start) &=
gt;&gt; PAGE_SHIFT) +<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0vma-&gt;vm_pgoff;<br>
&gt; <br>
</blockquote></div><br clear=3D"all"><div><br></div>-- <br><div dir=3D"ltr"=
 class=3D"gmail_signature"><div dir=3D"ltr"><div><div dir=3D"ltr"><font col=
or=3D"#666666">Navid.</font></div></div></div></div>

--000000000000d239e4058e85392c--

