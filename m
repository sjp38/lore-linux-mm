Return-Path: <SRS0=ErOr=VZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9ECBDC433FF
	for <linux-mm@archiver.kernel.org>; Sun, 28 Jul 2019 18:06:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C3292075C
	for <linux-mm@archiver.kernel.org>; Sun, 28 Jul 2019 18:06:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="wm99k6CR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C3292075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=invisiblethingslab.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE6A08E0003; Sun, 28 Jul 2019 14:06:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D96B28E0002; Sun, 28 Jul 2019 14:06:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C85E08E0003; Sun, 28 Jul 2019 14:06:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id A7C038E0002
	for <linux-mm@kvack.org>; Sun, 28 Jul 2019 14:06:18 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id x1so50050206qkn.6
        for <linux-mm@kvack.org>; Sun, 28 Jul 2019 11:06:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Wuh+r/apknyXeChjuNouckyB6vMRP+244QZYYcOsnlc=;
        b=GkN43paFiQ5ZTQgHs8B35gN1s9naG/1d6tNX8yDTpxVAurhheg76pbSWCoerxW03v3
         t8aULEkoWEX+O9vXdW3GlqXGaANpqyulgRldAsPQBwKHBQOPytKlO5nx8j7nr/aT8mkD
         4LsQe0D8rkSy9fpS3tAvpqKp3RO97ROkD3N8DvlCPug5NgJXkP8SMjIMPDQdpxSvuzL0
         1aCfmpfjfzmgGiamJzoBnSqGXBu/RH7z//TJMYWy2IlHNMOSZtBxYkOcB6RaalswTMdc
         4XzlldcO9dqhE3esJ/WmxWecKiMvT9zkXJ6kt/IxNudoTGwKzzKsv2jd2IWeH0bqB3X/
         HhSg==
X-Gm-Message-State: APjAAAWTseb9cS3YaxtCdShBhjRh3dsV6uWpQ9E1DkRCGfw10HXbzJp4
	Sm7lhqHXQIXgvCWj7RwaR1HbQ7rH2ryrBTkj9ElcSfOcf0ILyMiHOmnBksXb/77FPdxQxuWuCdr
	cwsGMblAiSxjx/TIIA64SgMsPDVzSsjLUjxAZonNuSJK1nuekelq0QxwdTeLp6P0=
X-Received: by 2002:a37:be86:: with SMTP id o128mr72419088qkf.40.1564337178398;
        Sun, 28 Jul 2019 11:06:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxpVUS37S3z1dNHGEyS/cfetIJAOBqUf/5bS/Fs/Ux5QZ0eDT1bfDp3/hx7CZQkvglfdxBK
X-Received: by 2002:a37:be86:: with SMTP id o128mr72419046qkf.40.1564337177672;
        Sun, 28 Jul 2019 11:06:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564337177; cv=none;
        d=google.com; s=arc-20160816;
        b=z7cg9ieXTLK0mHpMnywoMpujPTmyoTerpSqkWB2nYW8Q93j4e4pSXSU5gFeTyAA7XD
         KngBjYlRKwRS5TfD+vVQ4R0OTZKwvRzym+uI+CiA/lBbz7CzVYM3yLyEO2xeHq9XvJIS
         GJkaQRTQJK6mN31cri7bFrX5QoiC5M+oDWOQ7EqSYnTNJAySx2VrxW+AG+GFLVEBQw9+
         9RcLyafMPHjs2ZCV4bUoLvjLLX7OFmLsYiiubQCzte08CcQrA5gOYRrovpdhDagQR1HK
         PM8rbiSRfhD/n2E/gTfk/uFnmalJfsLZqzDKUsejN9DvUMVIS252X93jbKHD+xdbJXlh
         qvnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Wuh+r/apknyXeChjuNouckyB6vMRP+244QZYYcOsnlc=;
        b=F6pyxB0Ux5GNpihmGmAijp5JGeBWS++wS7XFygGI0nSVxg65gU22bOHnSuhA7g5aa2
         jSie2Xmxbb0bMiMX4te3e0vnBRyaEuoEGYQYGyI9k4UKi2ZIOpww+0bhYbG35E1ZLJFq
         D339/WEESWkXLcBG0QMzYNYzmSySYzA5OZcpPsoUVIkcHjjpLVQIouTQN6MSJ7FM1CW+
         fByJWrdvKkP2JfIc8vgInbqlf48c9cjq6URoSu24DKpszPwCTWc3gy2UbaWPeAsE5fFL
         Rplkkpcd/Q2CNxxAPSlX3DkJj4uXik6H97gIkvsD7YN4peTBgDmRvjas9YmFr28Ulkeq
         Ch4g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm3 header.b=wm99k6CR;
       spf=neutral (google.com: 66.111.4.230 is neither permitted nor denied by best guess record for domain of marmarek@invisiblethingslab.com) smtp.mailfrom=marmarek@invisiblethingslab.com
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id o37si14706109qtb.397.2019.07.28.11.06.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Jul 2019 11:06:17 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.230 is neither permitted nor denied by best guess record for domain of marmarek@invisiblethingslab.com) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm3 header.b=wm99k6CR;
       spf=neutral (google.com: 66.111.4.230 is neither permitted nor denied by best guess record for domain of marmarek@invisiblethingslab.com) smtp.mailfrom=marmarek@invisiblethingslab.com
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
	by mailnew.nyi.internal (Postfix) with ESMTP id 4C10C1DBD;
	Sun, 28 Jul 2019 14:06:17 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute7.internal (MEProxy); Sun, 28 Jul 2019 14:06:17 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; bh=Wuh+r/
	apknyXeChjuNouckyB6vMRP+244QZYYcOsnlc=; b=wm99k6CR/Q7pt9kdCvdLey
	W/Zd5DFzUtxNhd3HX++suyBzz7TK2G0RL0mJVxzqWORxcoNWAl+nkwRp2ZPrggdC
	efeLioNTIdDu0vkrqnJTdRczhzg2bZRl7b/ZElpgAEGSwzK98cYlgyoXOXDyCzpq
	Op2JcVA1skR2DjpkAsEaXT3UXHsHNTriy7bXq0i5+HPhBD2mnynXOZuFM3JqktPy
	Uxl+pCEZ+f96B307DWmYV7hireznWPHSPS0tchWNI2UB5dnpgwLxaWr0++dWv14c
	DFXD7Ov6bd7XJphdbktpQc3ieyZm8MjGQjgSq3tcvZ1O1qHkip/AXSXrxmxj1PBQ
	==
X-ME-Sender: <xms:GOQ9XYg31LapBor6tf4MObxmE89H-o2CUI8W0pgKiFx0KigB4lGJKg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduvddrkeelgdduvddvucetufdoteggodetrfdotf
    fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
    uceurghilhhouhhtmecufedttdenucenucfjughrpeffhffvuffkfhggtggujggfsehgtd
    erredtreejnecuhfhrohhmpeforghrvghkucforghrtgiihihkohifshhkihdqifpkrhgv
    tghkihcuoehmrghrmhgrrhgvkhesihhnvhhishhisghlvghthhhinhhgshhlrggsrdgtoh
    hmqeenucfkphepledurdeihedrfeegrdeffeenucfrrghrrghmpehmrghilhhfrhhomhep
    mhgrrhhmrghrvghksehinhhvihhsihgslhgvthhhihhnghhslhgrsgdrtghomhenucevlh
    hushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:GOQ9XSrcaLktICNydOWNWTRHHdUDgu7W2dZsDXFXaB0e6pw72zCe7A>
    <xmx:GOQ9XUJf7fCHDk0tnWornb7vSjPyJubEEiD74GEL-P75HnWZRvpTYg>
    <xmx:GOQ9XfuBkKs-3neqKbzaoBAgUYJndeiknA6EDwPHU_S6rQj0NyDlAA>
    <xmx:GeQ9XV5IMTOtxrd0_fuHDmmOYrrYsTGaD0IqCuSbnFGHMABzlWugFA>
Received: from mail-itl (ip5b412221.dynamic.kabel-deutschland.de [91.65.34.33])
	by mail.messagingengine.com (Postfix) with ESMTPA id D197D80059;
	Sun, 28 Jul 2019 14:06:14 -0400 (EDT)
Date: Sun, 28 Jul 2019 20:06:11 +0200
From: Marek =?utf-8?Q?Marczykowski-G=C3=B3recki?= <marmarek@invisiblethingslab.com>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	boris.ostrovsky@oracle.com, jgross@suse.com, linux@armlinux.org.uk,
	robin.murphy@arm.com, xen-devel@lists.xenproject.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [Xen-devel] [PATCH v4 8/9] xen/gntdev.c: Convert to use
 vm_map_pages()
Message-ID: <20190728180611.GA20589@mail-itl>
References: <20190215024830.GA26477@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="MGYHOYXEY6WxJCY8"
Content-Disposition: inline
In-Reply-To: <20190215024830.GA26477@jordon-HP-15-Notebook-PC>
User-Agent: Mutt/1.12+29 (a621eaed) (2019-06-14)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Feb 15, 2019 at 08:18:31AM +0530, Souptick Joarder wrote:
> Convert to use vm_map_pages() to map range of kernel
> memory to user vma.
>=20
> map->count is passed to vm_map_pages() and internal API
> verify map->count against count ( count =3D vma_pages(vma))
> for page array boundary overrun condition.

This commit breaks gntdev driver. If vma->vm_pgoff > 0, vm_map_pages
will:
 - use map->pages starting at vma->vm_pgoff instead of 0
 - verify map->count against vma_pages()+vma->vm_pgoff instead of just
   vma_pages().

In practice, this breaks using a single gntdev FD for mapping multiple
grants.

It looks like vm_map_pages() is not a good fit for this code and IMO it
should be reverted.

> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> ---
>  drivers/xen/gntdev.c | 11 ++++-------
>  1 file changed, 4 insertions(+), 7 deletions(-)
>=20
> diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
> index 5efc5ee..5d64262 100644
> --- a/drivers/xen/gntdev.c
> +++ b/drivers/xen/gntdev.c
> @@ -1084,7 +1084,7 @@ static int gntdev_mmap(struct file *flip, struct vm=
_area_struct *vma)
>  	int index =3D vma->vm_pgoff;
>  	int count =3D vma_pages(vma);
>  	struct gntdev_grant_map *map;
> -	int i, err =3D -EINVAL;
> +	int err =3D -EINVAL;
> =20
>  	if ((vma->vm_flags & VM_WRITE) && !(vma->vm_flags & VM_SHARED))
>  		return -EINVAL;
> @@ -1145,12 +1145,9 @@ static int gntdev_mmap(struct file *flip, struct v=
m_area_struct *vma)
>  		goto out_put_map;
> =20
>  	if (!use_ptemod) {
> -		for (i =3D 0; i < count; i++) {
> -			err =3D vm_insert_page(vma, vma->vm_start + i*PAGE_SIZE,
> -				map->pages[i]);
> -			if (err)
> -				goto out_put_map;
> -		}
> +		err =3D vm_map_pages(vma, map->pages, map->count);
> +		if (err)
> +			goto out_put_map;
>  	} else {
>  #ifdef CONFIG_X86
>  		/*

--=20
Best Regards,
Marek Marczykowski-G=C3=B3recki
Invisible Things Lab
A: Because it messes up the order in which people normally read text.
Q: Why is top-posting such a bad thing?

--MGYHOYXEY6WxJCY8
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEEhrpukzGPukRmQqkK24/THMrX1ywFAl095BIACgkQ24/THMrX
1yziIAf/exzcYKVSO+KS0CX9O2QdFSocXv52LbbEaeXP7AvIDXtfXcdbvxrkBwyA
dM4LYJgnMPbjYusQKNqWNDwi16zSJJgNfM0F4g+B4Ch2wkPXqCsobfHILsV8/x96
uYVr05q30FJ5goCzeMvQMNdPwDHv6+xGalM5Zhl56Xj+BGUQNmKo5sw2dAvarOM2
vdJUiQvbaZSBYSLZnufgbaEoZsXKQpDJftX7uM2gt6qmW3OwcEyhhGVI9loMCyJ5
jCWaVsXNj3EW/pZpwSX2nJgygQEp0C0x6xIZrG9rPNt/mZClap556QsmZzUkZDN7
92r6MMVJJLYyM0f880I5KEOKsIGNaQ==
=PmYG
-----END PGP SIGNATURE-----

--MGYHOYXEY6WxJCY8--

