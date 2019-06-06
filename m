Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48393C28EB4
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 19:53:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 09374206BB
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 19:53:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="BjNv3BPo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 09374206BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85BD06B0281; Thu,  6 Jun 2019 15:53:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 80AEA6B0282; Thu,  6 Jun 2019 15:53:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FA636B0285; Thu,  6 Jun 2019 15:53:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 391666B0281
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 15:53:54 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id y7so2562499pfy.9
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 12:53:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version;
        bh=UHAEe52WTylPEzWcunVQrncUjHHUAGZSuxAqUybT63Y=;
        b=AW17pVhmVzBNP6fU6JUnwFzGX5sz4sn8/caVVlS69vUlquQSW82v3Hclh7Nabz0gSn
         AWEFnnY3DLWbtQZvnUp4olkAwT1SUG5+X4jkd4v00ADWDzqCNxs8xoNDoWK7zdH9UsTL
         dorJUDCSoKiUFke8Lr+8H6oGXXvxl4eU5CfA67nUq6qc1e7Pv/45LFZVIsXLM0l5Sk1X
         L+DKPCTLByNKVe4Ncsj792nhBGEewD+n/NzPNa4QURqyot1R5Nr4d5VS7H/LqZlCBeO6
         N9BBsXd92lFHUJojhLvZU82ZhuzbRwpiW1PMk7d2ppS/5Q3dLBx/74lhBM8R9JHVXKyz
         V7LQ==
X-Gm-Message-State: APjAAAWLLL2yVe+8M4LaJEdbOkc+D9eP4gRZ5I9+tO1v9e8LbmCqwCNk
	4U+w6QQsv4rBVWMEL77Nxp3oxpMO1ltJ9Ly2FpxHmNj7IDV7L7nQXY+H6387Plhc1UdFTWlL4Ih
	w4Fkk5Dn7G+i0YPlRU81WuO19fgVZE0GXwsxC7vmvI0G+g+/J9S2ZqhpXkxPmkgx77Q==
X-Received: by 2002:a17:90a:bc0c:: with SMTP id w12mr1446744pjr.111.1559850833786;
        Thu, 06 Jun 2019 12:53:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxGRWP6r/JgxICARwQ54q4s0CHuF5iReFE2hfllsZINFDgg7/GDrvGLbLD+6+MMVSMEsz6s
X-Received: by 2002:a17:90a:bc0c:: with SMTP id w12mr1446685pjr.111.1559850832737;
        Thu, 06 Jun 2019 12:53:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559850832; cv=none;
        d=google.com; s=arc-20160816;
        b=DQUtSOh6j3xo6fUHDADY4948clMzitlCcrGTDcN+SUptCvgfFT9Ta3cYp7P5TnvIlI
         pWi4JQIO1yTVNbEPxsRPqJrjFMKDN9mayHFz+uWGjGXDBmrR5X5sYsomh9RRGksCjNw9
         JoARxX8SzR2JnkHOTwDVaOpAfOZ78FOiki8s51+65qR40UErReDPMS5969A/ZU+M44Vm
         PTcDYOLeGR+3iFLv/cRScYRlliaUbiQAh8QrNZ/ZqqFQo6WJB5l09N2flHapGfVYVGvE
         bioLeU3twSSjrr+nmIOo7PWlvQEmYmr5//sxbTWqXeXJhFgfUrIo9edMsIaWEs2oIX7j
         fOuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=UHAEe52WTylPEzWcunVQrncUjHHUAGZSuxAqUybT63Y=;
        b=MbMtSTsEB4A4t+7oOYq0Yf+gVr9ez5MFwOWenMUYMiKo2ZR0vqtTHI0/MwHWHK2x7h
         XdmK/l5vfzh5tHAYWqovwQPA9FzSKLLdXuCKAG5ySSWByppsb3BmMH8U7yYuA2VMrA3m
         t+A4rELjz+oFs0Iwc3nMESYOWNpUQ+h4nHarlELlw3ft9vqf09QXT3SC7lgLu+dIxi3u
         5RhGXpPyBQNlZD+9xRFAL6Jw2RM/FDuL4V4++IvJ/wgmvGOLCx1NsRcJVHuJ2s11ij5j
         KUaEoD7Jdlla6rhf7mnI1qsZ0SoIg7QAdkHRpRujxjf9SDc3oF7oI75BalHRvQpS4Vo6
         BHZg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=BjNv3BPo;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from ozlabs.org (bilbo.ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id p65si2608730pfp.168.2019.06.06.12.53.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Jun 2019 12:53:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=BjNv3BPo;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 45KbvF48Xvz9sDX;
	Fri,  7 Jun 2019 05:53:45 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201702; t=1559850827;
	bh=d6SJxU0/ScjlRTFzNoaL9FcILbaOOHmHAty3CZ/Vh/M=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=BjNv3BPoFFPjmA7YQV4rHasyQ0759LKCjrVwNHart/HO5uj6qphC7gz5KmZdB56+B
	 +HwcAvXphavYyjktKp2nK/jcsCuzQMXr5tqUTMfnT+ev0DFZx39i29fZZF8dgmZc/X
	 +9wCz+J4sHwuFLYcUDhILzckHTzdJn0r+exASPB5apFMQMHzlQXGO7rv4vH9K294gK
	 DO22P0PGbGBiNs9bXbMEll8eNKCkiScDLyAPZh+OSYddhH9pzQnsx+RyjoatvzPYzs
	 e6q3RHbjuSYXsBnUkV4GqSVVxHyycbvDTvvdYsR/a32WxXzAqT9enp//v76sEKQZFE
	 jQf8GDy1+/pRA==
Date: Fri, 7 Jun 2019 05:53:34 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig
 <hch@infradead.org>, Dave Airlie <airlied@redhat.com>, Linus Torvalds
 <torvalds@linux-foundation.org>, Daniel Vetter <daniel.vetter@ffwll.ch>,
 Jerome Glisse <jglisse@redhat.com>, "linux-kernel@vger.kernel.org"
 <linux-kernel@vger.kernel.org>, "linux-rdma@vger.kernel.org"
 <linux-rdma@vger.kernel.org>, Leon Romanovsky <leonro@mellanox.com>, Doug
 Ledford <dledford@redhat.com>, Artemy Kovalyov <artemyko@mellanox.com>,
 Moni Shoua <monis@mellanox.com>, Mike Marciniszyn
 <mike.marciniszyn@intel.com>, Kaike Wan <kaike.wan@intel.com>, Dennis
 Dalessandro <dennis.dalessandro@intel.com>, "linux-mm@kvack.org"
 <linux-mm@kvack.org>, dri-devel <dri-devel@lists.freedesktop.org>
Subject: Re: RFC: Run a dedicated hmm.git for 5.3
Message-ID: <20190607055334.2bdea125@canb.auug.org.au>
In-Reply-To: <20190606152543.GE17392@mellanox.com>
References: <20190523155207.GC5104@redhat.com>
	<20190523163429.GC12159@ziepe.ca>
	<20190523173302.GD5104@redhat.com>
	<20190523175546.GE12159@ziepe.ca>
	<20190523182458.GA3571@redhat.com>
	<20190523191038.GG12159@ziepe.ca>
	<20190524064051.GA28855@infradead.org>
	<20190524124455.GB16845@ziepe.ca>
	<20190525155210.8a9a66385ac8169d0e144225@linux-foundation.org>
	<20190527191247.GA12540@ziepe.ca>
	<20190606152543.GE17392@mellanox.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/l+KwJlP++eQB4BpW/9k.220"; protocol="application/pgp-signature"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--Sig_/l+KwJlP++eQB4BpW/9k.220
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Jason,

On Thu, 6 Jun 2019 15:25:49 +0000 Jason Gunthorpe <jgg@mellanox.com> wrote:
>
> On Mon, May 27, 2019 at 04:12:47PM -0300, Jason Gunthorpe wrote:
> > On Sat, May 25, 2019 at 03:52:10PM -0700, Andrew Morton wrote: =20
> > > On Fri, 24 May 2019 09:44:55 -0300 Jason Gunthorpe <jgg@ziepe.ca> wro=
te:
> > >  =20
> > > > Now that -mm merged the basic hmm API skeleton I think running like
> > > > this would get us quickly to the place we all want: comprehensive i=
n tree
> > > > users of hmm.
> > > >=20
> > > > Andrew, would this be acceptable to you? =20
> > >=20
> > > Sure.  Please take care not to permit this to reduce the amount of
> > > exposure and review which the core HMM pieces get. =20
> >=20
> > Certainly, thanks all
> >=20
> > Jerome: I started a HMM branch on v5.2-rc2 in the rdma.git here:
> >=20
> > git://git.kernel.org/pub/scm/linux/kernel/git/rdma/rdma.git
> > https://git.kernel.org/pub/scm/linux/kernel/git/rdma/rdma.git/log/?h=3D=
hmm =20
>=20
> I did a first round of collecting patches for hmm.git
>=20
> Andrew, I'm checking linux-next and to stay co-ordinated, I see the
> patches below are in your tree and now also in hmm.git. Can you please
> drop them from your tree?=20
>=20
> 5b693741de2ace mm/hmm.c: suppress compilation warnings when CONFIG_HUGETL=
B_PAGE is not set
> b2870fb882599a mm/hmm.c: only set FAULT_FLAG_ALLOW_RETRY for non-blocking
> dff7babf8ae9f1 mm/hmm.c: support automatic NUMA balancing
>=20
> I checked that the other two patches in -next also touching hmm.c are
> best suited to go through your tree:
>=20
> a76b9b318a7180 mm/devm_memremap_pages: fix final page put race
> fc64c058d01b98 mm/memremap: rename and consolidate SECTION_SIZE
>=20
> StephenR: Can you pick up the hmm branch from rdma.git for linux-next for
> this cycle? As above we are moving the patches from -mm to hmm.git, so
> there will be a conflict in -next until Andrew adjusts his tree,
> thanks!

I have added the hmm branch from today with currently just you as the
contact.  I also removed the three commits above from Andrew's tree.

Thanks for adding your subsystem tree as a participant of linux-next.  As
you may know, this is not a judgement of your code.  The purpose of
linux-next is for integration testing and to lower the impact of
conflicts between subsystems in the next merge window.=20

You will need to ensure that the patches/commits in your tree/series have
been:
     * submitted under GPL v2 (or later) and include the Contributor's
        Signed-off-by,
     * posted to the relevant mailing list,
     * reviewed by you (or another maintainer of your subsystem tree),
     * successfully unit tested, and=20
     * destined for the current or next Linux merge window.

Basically, this should be just what you would send to Linus (or ask him
to fetch).  It is allowed to be rebased if you deem it necessary.

--=20
Cheers,
Stephen Rothwell=20
sfr@canb.auug.org.au

--Sig_/l+KwJlP++eQB4BpW/9k.220
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAlz5bz4ACgkQAVBC80lX
0Gz42ggAjd2XdELh29gxYaa3AGGZx68tH5E3qcBVYvxP3IEAfi0bUSvxNXFhstk6
YaxWX9oxbApTS2Uj3++jezF4Xjj2Y73HGUjGLQ3Otw3Mnqcf6jXCMx8Z++gM7yyC
VCZzpR+3xAuAY21M7Ov9ZplyOO2h0UgAm8zaMi5hxEyGVAKjncUBDg4Y0qrh0UAl
AnZKxV4zQyp4/PvVuYFQa+g8igqB+cGfBLY36wP0k2p3f7btC0m1JSgADRiqg0lA
reZ+53oVo8c90IhdJp2lysklnxwDvfGMcl5S93eBGYfT0TdJ0XWriIgIy+uwt6mx
VsgPHJUvyidpJbGyRC/m2LJnhvk19w==
=dJb7
-----END PGP SIGNATURE-----

--Sig_/l+KwJlP++eQB4BpW/9k.220--

