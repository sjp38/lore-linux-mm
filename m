Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 00AF46B01AC
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 19:04:48 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <489aa002-6d42-4dd5-bb66-81c665f8cdd1@default>
Date: Wed, 2 Jun 2010 16:02:40 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V2 0/7] Cleancache (was Transcendent Memory): overview
References: <20100528173510.GA12166@ca-server1.us.oracle.comAANLkTilV-4_QaNq5O0WSplDx1Oq7JvkgVrEiR1rgf1up@mail.gmail.com>
 <1d88619a-bb1e-493f-ad96-bf204b60938d@default
 20100602163827.GA5450@barrios-desktop>
In-Reply-To: <20100602163827.GA5450@barrios-desktop>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@Sun.COM, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com
List-ID: <linux-mm.kvack.org>

> From: Minchan Kim [mailto:minchan.kim@gmail.com]

> > I am also eagerly awaiting Nitin Gupta's cleancache backend
> > and implementation to do in-kernel page cache compression.
>=20
> Do Nitin say he will make backend of cleancache for
> page cache compression?
>=20
> It would be good feature.
> I have a interest, too. :)

That was Nitin's plan for his GSOC project when we last discussed
this.  Nitin is on the cc list and can comment if this has
changed.

> > By "move", do you mean changing the virtual mappings?  Yes,
> > this could be done as long as the source and destination are
> > both directly addressable (that is, true physical RAM), but
> > requires TLB manipulation and has some complicated corner
> > cases.  The copy semantics simplifies the implementation on
> > both the "frontend" and the "backend" and also allows the
> > backend to do fancy things on-the-fly like page compression
> > and page deduplication.
>=20
> Agree. But I don't mean it.
> If I use brd as backend, i want to do it follwing as.
>=20
> <snip>
>=20
> Of course, I know it's impossible without new metadata and
> modification of page cache handling and it makes front and
> backend's good layered design.
>=20
> What I want is to remove copy overhead when backend is ram
> and it's also part of main memory(ie, we have page descriptor).
>=20
> Do you have an idea?

Copy overhead on modern processors is very low now due to
very wide memory buses.  The additional metadata and code
to handle coherency and concurrency, plus existing overhead
for batching and asynchronous access to brd is likely much
higher than the cost to avoid copying.

But if you did implement this without copying, I think
you might need a different set of hooks in various places.
I don't know.

> > Or did you mean a cleancache_ops "backend"?  For tmem, there
> > is one file linux/drivers/xen/tmem.c and it interfaces between
> > the cleancache_ops calls and Xen hypercalls.  It should be in
> > a Xenlinux pv_ops tree soon, or I can email it sooner.
>=20
> I mean "backend". :)

I dropped the code used for a RHEL6beta Xen tmem driver here:
http://oss.oracle.com/projects/tmem/dist/files/RHEL6beta/tmem-backend.patch=
=20

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
