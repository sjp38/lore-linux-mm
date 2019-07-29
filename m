Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0343CC7618B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 13:39:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B6E3206DD
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 13:39:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="n3j6ChF5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B6E3206DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=invisiblethingslab.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E6F5B8E0003; Mon, 29 Jul 2019 09:39:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E1FCD8E0002; Mon, 29 Jul 2019 09:39:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D0F568E0003; Mon, 29 Jul 2019 09:39:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 847608E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 09:39:02 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id f9so30104181wrq.14
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 06:39:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=RyaC16PSTOvq/k1p7u852FYetjzj++iB3xERHs/E83U=;
        b=J0MQTS2R/ts96hZXkHzJCsUk8Y5ydPtI92lNZS76RSIKPS10w2riXLVMknmc4n1YBO
         pxdPQhHefh+I0gxt6rfw7Ucdg+Y+WaswNtsPqyhtqiWzVaROC2wwH10NymlyehAZf6zV
         ElAh684v9OFN7Avnddr4mYmZi5z8XFyALvIMSHKU9vfM56C/8cga08nkXIkNo6OiGmWa
         e4txqc4q+KSzA2qVOpvcaYeHPC6gfhSNjhNzzY4sv8gOFPDRF1MyPsd93qwW4bk6gePp
         PMCByMCrl4EkB817QTmjspk9tZ4mKwAnzvolHp9ihgMk13Ha51rq3okq3lKGU7rgmVOP
         TGzQ==
X-Gm-Message-State: APjAAAVtqh1OPkncTHzMSEcVk6RT0I8X1EyJ4nlwnrHlyuYkXPDqh87v
	7gjY2GM8y8IwjeH6ycqzlSXqylvMBgMVR44k+mTiRNSCF29VnRIqd+va1uPZUc8N7oMeuysGdM7
	BG47jPDLhLMRmfBJDFlqlVODNiyWIoU7RiEXcqKw4PWhgF86Steka4S1Sm1vKqos=
X-Received: by 2002:a5d:5450:: with SMTP id w16mr72882686wrv.128.1564407541954;
        Mon, 29 Jul 2019 06:39:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5TbTdmnMfFmDCtleplBCmM3uf8BY69Yfhy0gV3PmBr9yWjINNddPgkA9fvwQA4riJKcFD
X-Received: by 2002:a5d:5450:: with SMTP id w16mr72882614wrv.128.1564407540854;
        Mon, 29 Jul 2019 06:39:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564407540; cv=none;
        d=google.com; s=arc-20160816;
        b=aRpchVktcGQSiVKwvtfVFnpc+J8vzS7dlt6fjwrnmE1e1auh78iSlqd6oT6CE77db9
         +CtGj1hSCbYEWDrgeRVox2wTMOBlvQQFBZANhJ95dJ6Ih6AB37vASTygc8bQd8A4UX7l
         iJoK0YcGDt54JPcQaat8wy6dgH9f/uGcfiUFQP2TlM4ORo98lF0bTwGaw/MpvaBpJO2C
         1HrD8S7tkfiav0FAMmrwd6EW8JYf/qgnJiMCtdQ8ZG42DABlajXqkY6AbuNJ+lK7tvSb
         OPk9LpKewj1U2CEaYWN/3wdttaCQoW/e3mzrJblaBLCopVf5yAQriAtIxXrpwH3AE76J
         REgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=RyaC16PSTOvq/k1p7u852FYetjzj++iB3xERHs/E83U=;
        b=C4YCMBCVOU09HdUjOQ4yqXNQUUCR4cpPn4mjmeb239oKQY6AR+L+EtvGxM42LaEN+S
         l4u2UFFRUazgasOkagclwNBtT918TEIyGvg0Yjs1wvLBuYoT4yFoUNeTfQn4SXy0ycEn
         ydLJEwU+JlX4zFlqLLLaM7/LfqG5Am4vxDA4TOpS3Rg/Fqs9JW+gnmaJn4r10CLfDHoC
         mGbqF4kBfJ70/+MHwflxgWQkKIuEAD+WJ+BWdAi1km/tgzmgAazszHC7PCqLvwQpfAkJ
         GdKxo4s1QUaMaPU0RjEB3+AEVnSZynnkW3PWzKhOMlYSGPgwchFdMsjDSIS4dP7mTVk3
         3Irg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm3 header.b=n3j6ChF5;
       spf=neutral (google.com: 66.111.4.229 is neither permitted nor denied by best guess record for domain of marmarek@invisiblethingslab.com) smtp.mailfrom=marmarek@invisiblethingslab.com
Received: from new3-smtp.messagingengine.com (new3-smtp.messagingengine.com. [66.111.4.229])
        by mx.google.com with ESMTPS id r187si47464112wma.34.2019.07.29.06.39.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 06:39:00 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.229 is neither permitted nor denied by best guess record for domain of marmarek@invisiblethingslab.com) client-ip=66.111.4.229;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm3 header.b=n3j6ChF5;
       spf=neutral (google.com: 66.111.4.229 is neither permitted nor denied by best guess record for domain of marmarek@invisiblethingslab.com) smtp.mailfrom=marmarek@invisiblethingslab.com
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
	by mailnew.nyi.internal (Postfix) with ESMTP id 954BE25C7;
	Mon, 29 Jul 2019 09:36:49 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute7.internal (MEProxy); Mon, 29 Jul 2019 09:36:49 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; bh=RyaC16
	PSTOvq/k1p7u852FYetjzj++iB3xERHs/E83U=; b=n3j6ChF5mFB5vfXvL0hSko
	nPB4CTDOB9OdwGdBCP4FFTmO0cMekFHcA8p/MRZebqIYuvpmUgZkV/pk/jTEUSZL
	glzDJO3zNlpQ3lrrbSKvk1yFntvkfhx7DCHNOLKGtWRrYxwM3i/pvJP6ReTAHwLG
	izN6+aTE5GVADVz3OyEQWznY0+f12C2Ajg+FyVZrn38tR9g7u2YwkVsbIzKaL6zB
	SAY25nROjsdDjX4uAs8LuyF0f9PAwv3LmAugfXT9mpsDgOIdA9La/wPFBFGkQ2+8
	/XnuXzNRWWq1nZ5hcFq00019QOL2xybRw3/tzmnR0+HUw8WzdTmgEsYfPMM4owSg
	==
X-ME-Sender: <xms:cPY-XQTpzd_4FH8IQQnDIH5_UnLjHGiZYrFc-o8_DhJ2D8uGYgMbww>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduvddrledugdeiiecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpeffhffvuffkfhggtggujggfsehgtderredtreejnecuhfhrohhmpeforghrvghk
    ucforghrtgiihihkohifshhkihdqifpkrhgvtghkihcuoehmrghrmhgrrhgvkhesihhnvh
    hishhisghlvghthhhinhhgshhlrggsrdgtohhmqeenucffohhmrghinhepghhithhhuhgs
    rdgtohhmpdhgrhgrnhhtshdrhhhofienucfkphepledurdeihedrfeegrdeffeenucfrrg
    hrrghmpehmrghilhhfrhhomhepmhgrrhhmrghrvghksehinhhvihhsihgslhgvthhhihhn
    ghhslhgrsgdrtghomhenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:cPY-XYjf4ekNALU5d0xR9sr4N-cZt07Q1tYws3mrRSUuK8w9pJtFow>
    <xmx:cPY-XcssA5KSWNFrorGh0KSoRqS_YuHPGilEryLCzUDJqQCsptJiPg>
    <xmx:cPY-XazNBPefQNewECx2hzSoCeGN6tj0uV13FS35c56kBRp0pSC25A>
    <xmx:cfY-XYKf06DFSlRIxrqZvsjkOYRfjFvB7PLHXtA5x1chHcq6AHViIA>
Received: from mail-itl (ip5b412221.dynamic.kabel-deutschland.de [91.65.34.33])
	by mail.messagingengine.com (Postfix) with ESMTPA id 301DB80061;
	Mon, 29 Jul 2019 09:36:47 -0400 (EDT)
Date: Mon, 29 Jul 2019 15:36:42 +0200
From: Marek =?utf-8?Q?Marczykowski-G=C3=B3recki?= <marmarek@invisiblethingslab.com>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@suse.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Juergen Gross <jgross@suse.com>,
	Russell King - ARM Linux <linux@armlinux.org.uk>,
	robin.murphy@arm.com, xen-devel@lists.xenproject.org,
	linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>
Subject: Re: [Xen-devel] [PATCH v4 8/9] xen/gntdev.c: Convert to use
 vm_map_pages()
Message-ID: <20190729133642.GQ1250@mail-itl>
References: <20190215024830.GA26477@jordon-HP-15-Notebook-PC>
 <20190728180611.GA20589@mail-itl>
 <CAFqt6zaMDnpB-RuapQAyYAub1t7oSdHH_pTD=f5k-s327ZvqMA@mail.gmail.com>
 <CAFqt6zY+07JBxAVfMqb+X78mXwFOj2VBh0nbR2tGnQOP9RrNkQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="9ZRxqsK4bBEmgNeO"
Content-Disposition: inline
In-Reply-To: <CAFqt6zY+07JBxAVfMqb+X78mXwFOj2VBh0nbR2tGnQOP9RrNkQ@mail.gmail.com>
User-Agent: Mutt/1.12+29 (a621eaed) (2019-06-14)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--9ZRxqsK4bBEmgNeO
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jul 29, 2019 at 02:02:54PM +0530, Souptick Joarder wrote:
> On Mon, Jul 29, 2019 at 1:35 PM Souptick Joarder <jrdr.linux@gmail.com> w=
rote:
> >
> > On Sun, Jul 28, 2019 at 11:36 PM Marek Marczykowski-G=C3=B3recki
> > <marmarek@invisiblethingslab.com> wrote:
> > >
> > > On Fri, Feb 15, 2019 at 08:18:31AM +0530, Souptick Joarder wrote:
> > > > Convert to use vm_map_pages() to map range of kernel
> > > > memory to user vma.
> > > >
> > > > map->count is passed to vm_map_pages() and internal API
> > > > verify map->count against count ( count =3D vma_pages(vma))
> > > > for page array boundary overrun condition.
> > >
> > > This commit breaks gntdev driver. If vma->vm_pgoff > 0, vm_map_pages
> > > will:
> > >  - use map->pages starting at vma->vm_pgoff instead of 0
> >
> > The actual code ignores vma->vm_pgoff > 0 scenario and mapped
> > the entire map->pages[i]. Why the entire map->pages[i] needs to be mapp=
ed
> > if vma->vm_pgoff > 0 (in original code) ?

vma->vm_pgoff is used as index passed to gntdev_find_map_index. It's
basically (ab)using this parameter for "which grant reference to map".

> > are you referring to set vma->vm_pgoff =3D 0 irrespective of value pass=
ed
> > from user space ? If yes, using vm_map_pages_zero() is an alternate
> > option.

Yes, that should work.

> > >  - verify map->count against vma_pages()+vma->vm_pgoff instead of just
> > >    vma_pages().
> >
> > In original code ->
> >
> > diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
> > index 559d4b7f807d..469dfbd6cf90 100644
> > --- a/drivers/xen/gntdev.c
> > +++ b/drivers/xen/gntdev.c
> > @@ -1084,7 +1084,7 @@ static int gntdev_mmap(struct file *flip, struct
> > vm_area_struct *vma)
> > int index =3D vma->vm_pgoff;
> > int count =3D vma_pages(vma);
> >
> > Count is user passed value.
> >
> > struct gntdev_grant_map *map;
> > - int i, err =3D -EINVAL;
> > + int err =3D -EINVAL;
> > if ((vma->vm_flags & VM_WRITE) && !(vma->vm_flags & VM_SHARED))
> > return -EINVAL;
> > @@ -1145,12 +1145,9 @@ static int gntdev_mmap(struct file *flip,
> > struct vm_area_struct *vma)
> > goto out_put_map;
> > if (!use_ptemod) {
> > - for (i =3D 0; i < count; i++) {
> > - err =3D vm_insert_page(vma, vma->vm_start + i*PAGE_SIZE,
> > - map->pages[i]);
> >
> > and when count > i , we end up with trying to map memory outside
> > boundary of map->pages[i], which was not correct.
>=20
> typo.
> s/count > i / count > map->count

gntdev_find_map_index verifies it. Specifically, it looks for a map matching
both index and count.

> >
> > - if (err)
> > - goto out_put_map;
> > - }
> > + err =3D vm_map_pages(vma, map->pages, map->count);
> > + if (err)
> > + goto out_put_map;
> >
> > With this commit, inside __vm_map_pages(), we have addressed this scena=
rio.
> >
> > +static int __vm_map_pages(struct vm_area_struct *vma, struct page **pa=
ges,
> > + unsigned long num, unsigned long offset)
> > +{
> > + unsigned long count =3D vma_pages(vma);
> > + unsigned long uaddr =3D vma->vm_start;
> > + int ret, i;
> > +
> > + /* Fail if the user requested offset is beyond the end of the object =
*/
> > + if (offset > num)
> > + return -ENXIO;
> > +
> > + /* Fail if the user requested size exceeds available object size */
> > + if (count > num - offset)
> > + return -ENXIO;
> >
> > By checking count > num -offset. (considering vma->vm_pgoff !=3D 0 as w=
ell).
> > So we will never cross the boundary of map->pages[i].
> >
> >
> > >
> > > In practice, this breaks using a single gntdev FD for mapping multiple
> > > grants.
> >
> > How ?

gntdev uses vma->vm_pgoff to select which grant entry should be mapped.
map struct returned by gntdev_find_map_index() describes just the pages
to be mapped. Specifically map->pages[0] should be mapped at
vma->vm_start, not vma->vm_start+vma->vm_pgoff*PAGE_SIZE.

When trying to map grant with index (aka vma->vm_pgoff) > 1,
__vm_map_pages() will refuse to map it because it will expect map->count
to be at least vma_pages(vma)+vma->vm_pgoff, while it is exactly
vma_pages(vma).

> > > It looks like vm_map_pages() is not a good fit for this code and IMO =
it
> > > should be reverted.
> >
> > Did you hit any issue around this code in real time ?

Yes, relevant strace output:
[pid   857] ioctl(7, IOCTL_GNTDEV_MAP_GRANT_REF, 0x7ffd3407b6d0) =3D 0
[pid   857] mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_SHARED, 7, 0) =3D 0x=
777f1211b000
[pid   857] ioctl(7, IOCTL_GNTDEV_SET_UNMAP_NOTIFY, 0x7ffd3407b710) =3D 0
[pid   857] ioctl(7, IOCTL_GNTDEV_MAP_GRANT_REF, 0x7ffd3407b6d0) =3D 0
[pid   857] mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_SHARED, 7, 0x1000) =
=3D -1 ENXIO (No such device or address)

details here:
https://github.com/QubesOS/qubes-issues/issues/5199


> >
> >
> > >
> > > > Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> > > > Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> > > > ---
> > > >  drivers/xen/gntdev.c | 11 ++++-------
> > > >  1 file changed, 4 insertions(+), 7 deletions(-)
> > > >
> > > > diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
> > > > index 5efc5ee..5d64262 100644
> > > > --- a/drivers/xen/gntdev.c
> > > > +++ b/drivers/xen/gntdev.c
> > > > @@ -1084,7 +1084,7 @@ static int gntdev_mmap(struct file *flip, str=
uct vm_area_struct *vma)
> > > >       int index =3D vma->vm_pgoff;
> > > >       int count =3D vma_pages(vma);
> > > >       struct gntdev_grant_map *map;
> > > > -     int i, err =3D -EINVAL;
> > > > +     int err =3D -EINVAL;
> > > >
> > > >       if ((vma->vm_flags & VM_WRITE) && !(vma->vm_flags & VM_SHARED=
))
> > > >               return -EINVAL;
> > > > @@ -1145,12 +1145,9 @@ static int gntdev_mmap(struct file *flip, st=
ruct vm_area_struct *vma)
> > > >               goto out_put_map;
> > > >
> > > >       if (!use_ptemod) {
> > > > -             for (i =3D 0; i < count; i++) {
> > > > -                     err =3D vm_insert_page(vma, vma->vm_start + i=
*PAGE_SIZE,
> > > > -                             map->pages[i]);
> > > > -                     if (err)
> > > > -                             goto out_put_map;
> > > > -             }
> > > > +             err =3D vm_map_pages(vma, map->pages, map->count);
> > > > +             if (err)
> > > > +                     goto out_put_map;
> > > >       } else {
> > > >  #ifdef CONFIG_X86
> > > >               /*
> > >
> > > --
> > > Best Regards,
> > > Marek Marczykowski-G=C3=B3recki
> > > Invisible Things Lab
> > > A: Because it messes up the order in which people normally read text.
> > > Q: Why is top-posting such a bad thing?

--=20
Best Regards,
Marek Marczykowski-G=C3=B3recki
Invisible Things Lab
A: Because it messes up the order in which people normally read text.
Q: Why is top-posting such a bad thing?

--9ZRxqsK4bBEmgNeO
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEEhrpukzGPukRmQqkK24/THMrX1ywFAl0+9mwACgkQ24/THMrX
1yyp+Qf7BgjpKR5VnF94lyc3cB60I75O5vek4tH7R8v3YrusLm18zU20w/OBv6Dv
ZScjcJEpqQ9rorNTxSleltLG+zX/qPpv5Aqhh5hWqPKNCml8NqEI8KVQrVORk15x
c8YZDOGG4lMgONdcQyxwb83jySoRjfy0P9bj4N4impyB0/d4vgPZGsXbyn+EufdO
Nmfc6DrN7bu2ebW7c2y4DJlBiFj7g/PIdkooFaIpz1yh6XuWTkOotXOI/gt13qvy
9TWXPOTcRhGZfxTRsyDTcW/7qzp7hQWM8aLFXEEoZu6wdWfMh6i8AXJzpEgfTxeb
Wgqm5ngGbeXCUyKXVpMv+PYRSoCp6A==
=9+m6
-----END PGP SIGNATURE-----

--9ZRxqsK4bBEmgNeO--

