Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42B39C7618B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 08:33:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC8BC206E0
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 08:33:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Yj2x/YP+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC8BC206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8EE698E0006; Mon, 29 Jul 2019 04:33:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 89FC78E0002; Mon, 29 Jul 2019 04:33:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B63B8E0006; Mon, 29 Jul 2019 04:33:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 160E08E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 04:33:08 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id m2so13177770ljj.0
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 01:33:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=fzjgi5IYwtgWKCD94QQKl1WKdW6R14NVG7cIaq5hNd0=;
        b=jeVi6Ww37OMF6tqarBtA+YvrLrv1TXHinDQdRIP7I8APZIvSAstvVGoYAgxuN0YerS
         v9yQxKHEzQbLjYiO4TH/R+7WIVvAFoAoEoyUEUZw1V1wFKwFiWZVIysPqda0VO0XdmPc
         M9cr7tuBKhIIC2zRAPnfwJCmeL2/f/XfuU+V7ND1Z+gCpEyQVv4jfrVBik0WhM3RW9lK
         vNertnOVznzHM7U3ZnnOpb8AVLLJQvAuiI+hsLtgITIOUK4+h1Udj7cCw+2RTHF0B01s
         vFSYVJlWWvI5cgMmZEatPScOCEHVh1G7WVeiUGVVlzeGBr3j9WRhzNZ3tZDNN97+Ej9i
         1s7A==
X-Gm-Message-State: APjAAAXEquYJJbPrQwD22GaeTWPkBcdBqH3IBj+8V1Bj1F7Pp/1pt/fz
	BFcyLHckL+i185Kn7fxS9wFNHN3hSa2AiA5qQo9cK1ZK7Qa25JfytJP1Iiz3hOkriAHhDxszVvn
	vhJwPklsi2tlm5ZRIn/HE+wGyFjCh8EeA5ctcifaJsIP0T1fQIpnJ7IW9auojPf0rew==
X-Received: by 2002:a2e:96d0:: with SMTP id d16mr43788506ljj.14.1564389187492;
        Mon, 29 Jul 2019 01:33:07 -0700 (PDT)
X-Received: by 2002:a2e:96d0:: with SMTP id d16mr43788467ljj.14.1564389186659;
        Mon, 29 Jul 2019 01:33:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564389186; cv=none;
        d=google.com; s=arc-20160816;
        b=Ek64xVYwLvdCu44i4Qqt11v5sidNVc7YC/5Bq41y+PrJ3ggMWQvObbfHTuX1+dQ8qX
         Pzfkrg7SoUsTnqBxNevPGqWqO1CtqUfLWaH9EXu5mxVJDnSFbe23QeHXBh+awI4+JtxX
         ERgQtvaDaapMvS8C1yUYPpNJf3fHT9CzlxBdGAvgq6mGJuKIqkCq+R69PH2KIUVKj/xM
         96q5IDTiHR27ePvVntJnkV7xN0BKR5dTusGOVocwzK6B1lm1DgaPtWO4xj4EKl7YPrbY
         ceP1ifhhPy11A1fXiizG/GybETVXIoiTd2Lnnqf5OM7Uu/fyMC7/gHzKZ9haDsEdZ9xJ
         BorQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=fzjgi5IYwtgWKCD94QQKl1WKdW6R14NVG7cIaq5hNd0=;
        b=IlYwU5gYE6L5XuLmuPZn+ycyAdLmHOdjxYBh74ACDr4vavikeaD4HZt0+hUhQPFBzM
         +550LNwgoYefEGxwYRMgXO6BpoS+vqjONCqhApuYo1TsY4nTzGz0K/GkHqde6uLrx7KH
         oQ6aygEnhohz05e3ZGWQxIFw3YwD/xML0GpEunu9nsfMchGZYGHJwwbHjQ076zMnkY1j
         B+DxVb/8ZSrT43wDalqefnWftqjuenBVLBMLDg/q5/jBwfo5POrn8aVphCSf8noFC7Ur
         LQ6Q0+Dbo15OyKveJIE1A6PlXSapvv7YwOoajf5bZY8N09CQsNLyqiciSzVSeTRL57+W
         +n5g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="Yj2x/YP+";
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n5sor15358853lfi.73.2019.07.29.01.33.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jul 2019 01:33:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="Yj2x/YP+";
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=fzjgi5IYwtgWKCD94QQKl1WKdW6R14NVG7cIaq5hNd0=;
        b=Yj2x/YP+GQx3u0ETLl95DFn76V+nUeZ0HgcyvoUS0J23BQZRtMVjzIjCk80uAnKs7Q
         HQlRZ1Ixt54mk2Xl0CPAS4hhA/sUUWDDv5/rRB2v+KHQ4C83QqlXf3PwcGVgrK44gXGK
         T8QwJf/xyMFHhs2/N13YRy+O5ZrAaWHzCrT+9uVBY8T0e9XoY4vKw0aMc3l5RNtlaUye
         2VNkfpFLe1kIUERcSgFAVPZYdYW3WF1u+Y7yXdwTmDoI1JjojonOcWFQNJEu9zZ2L+Ms
         iR7gq/NDAQVjh7NAv7l7QBoZvm7uLNemt8yUQrhf5sdM60rK76dfCnEyAtS40qTLkvPy
         d9ag==
X-Google-Smtp-Source: APXvYqxOB3hlBmp/ELmfdAvewRmPGBGlLy908aDcnO5gzCSlHvcgEUZGOZj5/xu4Z+SD47jako1Nt3Hob11dDINtGdM=
X-Received: by 2002:a19:5e10:: with SMTP id s16mr49683043lfb.13.1564389186319;
 Mon, 29 Jul 2019 01:33:06 -0700 (PDT)
MIME-Version: 1.0
References: <20190215024830.GA26477@jordon-HP-15-Notebook-PC>
 <20190728180611.GA20589@mail-itl> <CAFqt6zaMDnpB-RuapQAyYAub1t7oSdHH_pTD=f5k-s327ZvqMA@mail.gmail.com>
In-Reply-To: <CAFqt6zaMDnpB-RuapQAyYAub1t7oSdHH_pTD=f5k-s327ZvqMA@mail.gmail.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Mon, 29 Jul 2019 14:02:54 +0530
Message-ID: <CAFqt6zY+07JBxAVfMqb+X78mXwFOj2VBh0nbR2tGnQOP9RrNkQ@mail.gmail.com>
Subject: Re: [Xen-devel] [PATCH v4 8/9] xen/gntdev.c: Convert to use vm_map_pages()
To: =?UTF-8?Q?Marek_Marczykowski=2DG=C3=B3recki?= <marmarek@invisiblethingslab.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, 
	Michal Hocko <mhocko@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, 
	Juergen Gross <jgross@suse.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com, 
	xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org, 
	Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 1:35 PM Souptick Joarder <jrdr.linux@gmail.com> wro=
te:
>
> On Sun, Jul 28, 2019 at 11:36 PM Marek Marczykowski-G=C3=B3recki
> <marmarek@invisiblethingslab.com> wrote:
> >
> > On Fri, Feb 15, 2019 at 08:18:31AM +0530, Souptick Joarder wrote:
> > > Convert to use vm_map_pages() to map range of kernel
> > > memory to user vma.
> > >
> > > map->count is passed to vm_map_pages() and internal API
> > > verify map->count against count ( count =3D vma_pages(vma))
> > > for page array boundary overrun condition.
> >
> > This commit breaks gntdev driver. If vma->vm_pgoff > 0, vm_map_pages
> > will:
> >  - use map->pages starting at vma->vm_pgoff instead of 0
>
> The actual code ignores vma->vm_pgoff > 0 scenario and mapped
> the entire map->pages[i]. Why the entire map->pages[i] needs to be mapped
> if vma->vm_pgoff > 0 (in original code) ?
>
> are you referring to set vma->vm_pgoff =3D 0 irrespective of value passed
> from user space ? If yes, using vm_map_pages_zero() is an alternate
> option.
>
>
> >  - verify map->count against vma_pages()+vma->vm_pgoff instead of just
> >    vma_pages().
>
> In original code ->
>
> diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
> index 559d4b7f807d..469dfbd6cf90 100644
> --- a/drivers/xen/gntdev.c
> +++ b/drivers/xen/gntdev.c
> @@ -1084,7 +1084,7 @@ static int gntdev_mmap(struct file *flip, struct
> vm_area_struct *vma)
> int index =3D vma->vm_pgoff;
> int count =3D vma_pages(vma);
>
> Count is user passed value.
>
> struct gntdev_grant_map *map;
> - int i, err =3D -EINVAL;
> + int err =3D -EINVAL;
> if ((vma->vm_flags & VM_WRITE) && !(vma->vm_flags & VM_SHARED))
> return -EINVAL;
> @@ -1145,12 +1145,9 @@ static int gntdev_mmap(struct file *flip,
> struct vm_area_struct *vma)
> goto out_put_map;
> if (!use_ptemod) {
> - for (i =3D 0; i < count; i++) {
> - err =3D vm_insert_page(vma, vma->vm_start + i*PAGE_SIZE,
> - map->pages[i]);
>
> and when count > i , we end up with trying to map memory outside
> boundary of map->pages[i], which was not correct.

typo.
s/count > i / count > map->count
>
> - if (err)
> - goto out_put_map;
> - }
> + err =3D vm_map_pages(vma, map->pages, map->count);
> + if (err)
> + goto out_put_map;
>
> With this commit, inside __vm_map_pages(), we have addressed this scenari=
o.
>
> +static int __vm_map_pages(struct vm_area_struct *vma, struct page **page=
s,
> + unsigned long num, unsigned long offset)
> +{
> + unsigned long count =3D vma_pages(vma);
> + unsigned long uaddr =3D vma->vm_start;
> + int ret, i;
> +
> + /* Fail if the user requested offset is beyond the end of the object */
> + if (offset > num)
> + return -ENXIO;
> +
> + /* Fail if the user requested size exceeds available object size */
> + if (count > num - offset)
> + return -ENXIO;
>
> By checking count > num -offset. (considering vma->vm_pgoff !=3D 0 as wel=
l).
> So we will never cross the boundary of map->pages[i].
>
>
> >
> > In practice, this breaks using a single gntdev FD for mapping multiple
> > grants.
>
> How ?
>
> >
> > It looks like vm_map_pages() is not a good fit for this code and IMO it
> > should be reverted.
>
> Did you hit any issue around this code in real time ?
>
>
> >
> > > Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> > > Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> > > ---
> > >  drivers/xen/gntdev.c | 11 ++++-------
> > >  1 file changed, 4 insertions(+), 7 deletions(-)
> > >
> > > diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
> > > index 5efc5ee..5d64262 100644
> > > --- a/drivers/xen/gntdev.c
> > > +++ b/drivers/xen/gntdev.c
> > > @@ -1084,7 +1084,7 @@ static int gntdev_mmap(struct file *flip, struc=
t vm_area_struct *vma)
> > >       int index =3D vma->vm_pgoff;
> > >       int count =3D vma_pages(vma);
> > >       struct gntdev_grant_map *map;
> > > -     int i, err =3D -EINVAL;
> > > +     int err =3D -EINVAL;
> > >
> > >       if ((vma->vm_flags & VM_WRITE) && !(vma->vm_flags & VM_SHARED))
> > >               return -EINVAL;
> > > @@ -1145,12 +1145,9 @@ static int gntdev_mmap(struct file *flip, stru=
ct vm_area_struct *vma)
> > >               goto out_put_map;
> > >
> > >       if (!use_ptemod) {
> > > -             for (i =3D 0; i < count; i++) {
> > > -                     err =3D vm_insert_page(vma, vma->vm_start + i*P=
AGE_SIZE,
> > > -                             map->pages[i]);
> > > -                     if (err)
> > > -                             goto out_put_map;
> > > -             }
> > > +             err =3D vm_map_pages(vma, map->pages, map->count);
> > > +             if (err)
> > > +                     goto out_put_map;
> > >       } else {
> > >  #ifdef CONFIG_X86
> > >               /*
> >
> > --
> > Best Regards,
> > Marek Marczykowski-G=C3=B3recki
> > Invisible Things Lab
> > A: Because it messes up the order in which people normally read text.
> > Q: Why is top-posting such a bad thing?

