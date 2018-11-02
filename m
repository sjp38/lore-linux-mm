Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8AED86B0006
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 21:43:38 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id c203-v6so428371ywh.8
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 18:43:38 -0700 (PDT)
Received: from esa7.fujitsucc.c3s2.iphmx.com (esa7.fujitsucc.c3s2.iphmx.com. [68.232.159.87])
        by mx.google.com with ESMTPS id j7-v6si9009339ywf.52.2018.11.01.18.43.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 18:43:37 -0700 (PDT)
From: "y-goto@fujitsu.com" <y-goto@fujitsu.com>
Subject: RE: Problems with VM_MIXEDMAP removal from /proc/<pid>/smaps
Date: Fri, 2 Nov 2018 01:43:27 +0000
Message-ID: 
 <TYAPR01MB32612BE7B72B099FBFB00DF190CF0@TYAPR01MB3261.jpnprd01.prod.outlook.com>
References: <20181002100531.GC4135@quack2.suse.cz>
 <20181002121039.GA3274@linux-x5ow.site>
 <20181002142959.GD9127@quack2.suse.cz>
 <x49h8hkfhk9.fsf@segfault.boston.devel.redhat.com>
 <20181018002510.GC6311@dastard> <20181018145555.GS23493@quack2.suse.cz>
 <20181019004303.GI6311@dastard>
 <CAPcyv4ixoAh7HEMfm+B4sRDx1Qwm6SHGjtQ+5r3EKsxreRydrA@mail.gmail.com>
 <20181030224904.GT19305@dastard>
 <TYAPR01MB32619CCA488DD0DA86EDB17E90CD0@TYAPR01MB3261.jpnprd01.prod.outlook.com>
 <20181101230012.GC19305@dastard>
In-Reply-To: <20181101230012.GC19305@dastard>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Dave Chinner' <david@fromorbit.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, jmoyer <jmoyer@redhat.com>, Johannes Thumshirn <jthumshirn@suse.de>, Dave Jiang <dave.jiang@intel.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>


> > > 	MAP_DIRECT is an access hint.
> > >
> > > 	MAP_SYNC provides a data integrity model guarantee.
> > >
> > > 	MAP_SYNC may imply MAP_DIRECT for specific implementations,
> > > 	but it does not require or guarantee MAP_DIRECT.
> > >
> > > Let's compare that with O_DIRECT:
> > >
> > > 	O_DIRECT in an access hint.
> > >
> > > 	O_DSYNC provides a data integrity model guarantee.
> > >
> > > 	O_DSYNC may imply O_DIRECT for specific implementations, but
> > > 	it does not require or guarantee O_DIRECT.
> > >
> > > Consistency in access and data integrity models is a good thing. DAX
> > > and pmem is not an exception. We need to use a model we know works
> > > and has proven itself over a long period of time.
> >
> > Hmmm, then, I would like to know all of the reasons of breakage of MAP_=
DIRECT.
> > (I'm not opposed to your opinion, but I need to know it.)
> >
> > In O_DIRECT case, in my understanding, the reason of breakage of O_DIRE=
CT is
> > "wrong alignment is specified by application", right?
>=20
> O_DIRECT has defined memory and offset alignment restrictions, and
> will return an error to userspace when they are violated. It does
> not fall back to buffered IO in this case. MAP_DIRECT has no
> equivalent restriction, so IO alignment of O_DIRECT is largely
> irrelevant here.
>=20
> What we are talking about here is that some filesystems can only do
> certain operations through buffered IO, such as block allocation or
> file extension, and so silently fall back to doing them via buffered
> IO even when O_DIRECT is specified. The old direct IO code used to
> be full of conditionals to allow this - I think DIO_SKIP_HOLES is
> only one remaining:
>=20
>                 /*
>                  * For writes that could fill holes inside i_size on a
>                  * DIO_SKIP_HOLES filesystem we forbid block creations: o=
nly
>                  * overwrites are permitted. We will return early to the =
caller
>                  * once we see an unmapped buffer head returned, and the =
caller
>                  * will fall back to buffered I/O.
>                  *
>                  * Otherwise the decision is left to the get_blocks metho=
d,
>                  * which may decide to handle it or also return an unmapp=
ed
>                  * buffer head.
>                  */
>                 create =3D dio->op =3D=3D REQ_OP_WRITE;
>                 if (dio->flags & DIO_SKIP_HOLES) {
>                         if (fs_startblk <=3D ((i_size_read(dio->inode) - =
1) >>
>                                                         i_blkbits))
>                                 create =3D 0;
>                 }
>=20
> Other cases like file extension cases are caught by the filesystems
> before calling into the DIO code itself, so there's multiple avenues
> for O_DIRECT transparently falling back to buffered IO.
>=20
> This means the applications don't fail just because the filesystem
> can't do a specific operation via O_DIRECT. The data writes still
> succeed because they fall back to buffered IO, and the application
> is blissfully unaware that the filesystem behaved that way.
>=20
> > When filesystem can not use O_DIRECT and it uses page cache instead,
> > then system uses more memory resource than user's expectation.
>=20
> That's far better than failing unexpectedly because the app
> unexpectedly came across a hole in the file (e.g. someone ran
> sparsify across the filesystem).
>=20
> > So, there is a side effect, and it may cause other trouble.
> > (memory pressure, expected performance can not be gained, and so on ..)
>=20
> Which is why people are supposed to test their systems before they
> put them into production.
>=20
> I've lost count of the number of times I've heard "but O_DIRECT is
> supposed to make things faster!" because people don't understand
> exactly what it does or means. Bypassing the page cache does not
> magically make applications go faster - it puts the responsibility
> for doing optimal IO on the application, not the kernel.
>=20
> MAP_DIRECT will be no different. It's no guarantee that it will make
> things faster, or that everything will just work as users expect
> them to. It specifically places the responsibility for performing IO
> in an optimal fashion on the application and the user for making
> sure that it is fit for their purposes. Like O_DIRECT, using
> MAP_DIRECT means "I, the application, know exactly what I'm doing,
> so get out of the way as much as possible because I'm taking
> responsibility for issuing IO in the most optimal manner now".
>=20
> > In such case its administrator (or technical support engineer) needs to=
 struggle to
> > investigate what is the reason.
>=20
> That's no different to performance problems that arise from
> inappropriate use of O_DIRECT. It requires a certain level of
> expertise to be able to understand and diagnose such issues.
>=20
> > So, I would like to know in MAP_DIRECT case, what is the reasons?
> > I think it will be helpful for users.
> > Only splice?
>=20
> The filesystem can ignore MAP_DIRECT for any reason it needs to. I'm
> certain that filesystem developers will try to maintain MAP_DIRECT
> semantics as much as possible, but it's not going to be possible in
> /all situations/ on XFS and ext4 because they simply haven't been
> designed with DAX in mind. Filesystems designed specifically for
> pmem and DAX might be able to provide MAP_DIRECT in all situations,
> but those filesystems don't really exist yet.
>=20
> This is no different to the early days of O_DIRECT. e.g.  ext3
> couldn't do O_DIRECT for all operations when it was first
> introduced, but over time the functionality improved as the
> underlying issues were solved. If O_DIRECT was a guarantee, then
> ext3 would have never supported O_DIRECT at all...

Hmm, Ok. I see.
Thank you very much for your detail explanation.

>=20
> > (Maybe such document will be necessary....)
>=20
> The semantics will need to be documented in the relevant man pages.

I agree.

Thanks, again.
----
Yasunori Goto
