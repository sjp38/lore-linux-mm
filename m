Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8BE1F6B02A4
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 13:38:36 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <c979fa45-8878-4e40-9060-c3e929eebbab@default>
Date: Fri, 23 Jul 2010 10:37:51 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V3 0/8] Cleancache: overview
References: <20100621231809.GA11111@ca-server1.us.oracle.com4C49468B.40307@vflare.org>
 <840b32ff-a303-468e-9d4e-30fc92f629f8@default
 20100723140440.GA12423@infradead.org
 364c83bd-ccb2-48cc-920d-ffcf9ca7df19@default>
In-Reply-To: <364c83bd-ccb2-48cc-920d-ffcf9ca7df19@default>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>, ngupta@vflare.org
Cc: akpm@linux-foundation.org, Chris Mason <chris.mason@oracle.com>, viro@zeniv.linux.org.uk, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, Joel Becker <joel.becker@oracle.com>, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, jeremy@goop.org, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@suse.de, Dave Mccracken <dave.mccracken@oracle.com>, riel@redhat.com, avi@redhat.com, Konrad Wilk <konrad.wilk@oracle.com>
List-ID: <linux-mm.kvack.org>

> From: Dan Magenheimer
> Subject: RE: [PATCH V3 0/8] Cleancache: overview
>=20
> > From: Christoph Hellwig [mailto:hch@infradead.org]
> > Subject: Re: [PATCH V3 0/8] Cleancache: overview
> >
> > On Fri, Jul 23, 2010 at 06:58:03AM -0700, Dan Magenheimer wrote:
> > > CHRISTOPH AND ANDREW, if you disagree and your concerns have
> > > not been resolved, please speak up.
>=20
> Hi Christoph --
>=20
> Thanks very much for the quick (instantaneous?) reply!
>=20
> > Anything that need modification of a normal non-shared fs is utterly
> > broken and you'll get a clear NAK, so the propsal before is a good
> > one.
>=20
> Unless/until all filesystems are 100% built on top of VFS,
> I have to disagree.  Abstractions (e.g. VFS) are never perfect.

After thinking about this some more, I can see a way
to enforce "opt-in" in the cleancache backend without
any changes to non-generic fs code.   I think it's a horrible
hack and we can try it, but I expect fs maintainers
would prefer the explicit one-line-patch opt-in.

1) Cleancache backend maintains a list of "known working"
   filesystems (those that have been tested).

2) Nitin's proposed changes pass the *sb as a parameter.
  The string name of the filesystem type is available via
  sb->s_type->name.  This can be compared against
  the "known working" list.

Using the sb pointer as a "handle" requires an extra
table search on every cleancache get/put/flush,
and fs/super.c changes are required for fs unmount
notification anyway (e.g. to call cleancache_flush_fs)
so I'd prefer to keep the cleancache_poolid addition
to the sb.  I'll assume this is OK since this is in generic
fs code.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
