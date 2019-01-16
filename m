Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 236F88E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 12:29:44 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id y74so958648wmc.0
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 09:29:44 -0800 (PST)
Received: from EUR04-VI1-obe.outbound.protection.outlook.com (mail-eopbgr80041.outbound.protection.outlook.com. [40.107.8.41])
        by mx.google.com with ESMTPS id m6si34519478wrp.29.2019.01.16.09.29.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 16 Jan 2019 09:29:42 -0800 (PST)
From: Jason Gunthorpe <jgg@mellanox.com>
Subject: Re: [PATCH 6/6] drivers/IB,core: reduce scope of mmap_sem
Date: Wed, 16 Jan 2019 17:29:40 +0000
Message-ID: <20190116172933.GI3758@mellanox.com>
References: <20190115181300.27547-1-dave@stgolabs.net>
 <20190115181300.27547-7-dave@stgolabs.net>
 <20190115205311.GD22031@mellanox.com>
 <20190115211207.GD6310@bombadil.infradead.org>
 <20190115211722.GA3758@mellanox.com>
 <20190116160026.iyg7pwmzy5o35h5l@linux-r8p5>
 <20190116170252.GG3758@mellanox.com>
 <20190116170612.GK6310@bombadil.infradead.org>
In-Reply-To: <20190116170612.GK6310@bombadil.infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <249B23343316074B83215D657D982139@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "dledford@redhat.com" <dledford@redhat.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Davidlohr Bueso <dbueso@suse.de>

On Wed, Jan 16, 2019 at 09:06:12AM -0800, Matthew Wilcox wrote:
> On Wed, Jan 16, 2019 at 05:02:59PM +0000, Jason Gunthorpe wrote:
> > On Wed, Jan 16, 2019 at 08:00:26AM -0800, Davidlohr Bueso wrote:
> > > On Tue, 15 Jan 2019, Jason Gunthorpe wrote:
> > >=20
> > > > On Tue, Jan 15, 2019 at 01:12:07PM -0800, Matthew Wilcox wrote:
> > > > > On Tue, Jan 15, 2019 at 08:53:16PM +0000, Jason Gunthorpe wrote:
> > > > > > > -	new_pinned =3D atomic_long_read(&mm->pinned_vm) + npages;
> > > > > > > +	new_pinned =3D atomic_long_add_return(npages, &mm->pinned_v=
m);
> > > > > > >  	if (new_pinned > lock_limit && !capable(CAP_IPC_LOCK)) {
> > > > > >
> > > > > > I thought a patch had been made for this to use check_overflow.=
..
> > > > >=20
> > > > > That got removed again by patch 1 ...
> > > >=20
> > > > Well, that sure needs a lot more explanation. :(
> > >=20
> > > What if we just make the counter atomic64?
> >=20
> > That could work.
>=20
> atomic_long, perhaps?  No need to use 64-bits on 32-bit architectures.

Well, there is, the point is to protect from user triggered overflow..

Say I'm on 32 bit and try to mlock 2G from 100 threads in parallel, I
can't allow the atomic_inc to wrap.

A 64 bit value works OK because I can't create enough threads to push
a 64 bit value into wrapping with at most a 32 bit add.

If you want to use a 32 bit, then I think the algo needs to use a compare
and swap loop with the check_overflow.

Jason
