Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5578F6B01BA
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 12:08:02 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <28f2e0a1-dfb5-4bcc-b0d7-238b5eea3e92@default>
Date: Wed, 2 Jun 2010 09:07:10 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V2 0/7] Cleancache (was Transcendent Memory): overview
References: <20100528173510.GA12166@ca-server1.us.oracle.com
 20100602132427.GA32110@infradead.org>
In-Reply-To: <20100602132427.GA32110@infradead.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com
List-ID: <linux-mm.kvack.org>

> From: Christoph Hellwig [mailto:hch@infradead.org]
> Subject: Re: [PATCH V2 0/7] Cleancache (was Transcendent Memory):
> overview

Hi Christophe --

Thanks for your feedback!

> >  fs/btrfs/super.c           |    2
> >  fs/buffer.c                |    5 +
> >  fs/ext3/super.c            |    2
> >  fs/ext4/super.c            |    2
> >  fs/mpage.c                 |    7 +
> >  fs/ocfs2/super.c           |    3
> >  fs/super.c                 |    8 +
>=20
> This is missing out a whole lot of filesystems.  Even more so why the
> hell do you need hooks into the filesystem?

Let me rephrase/regroup your question.  Let me know if
I missed anything...

1) Why is the VFS layer involved at all?

VFS hooks are necessary to avoid a disk read when a page
is already in cleancache and to maintain coherency (via
cleancache_flush operations) between cleancache, the
page cache, and disk.  This very small, very clean set
of hooks (placed by Chris Mason) all compile into
nothingness if cleancache is config'ed off, and turn
into "if (*p =3D=3D NULL)" if config'ed on but no "backend"
claims cleancache_ops or if an fs doesn't opt-in
(see below).

2) Why do the individual filesystems need to be modified?

Some filesystems are built entirely on top of VFS and
the hooks in VFS are sufficient, so don't require an
fs "cleancache_init" hook; the initial implementation
of cleancache didn't provide this hook.   But for some
fs (such as btrfs) the VFS hooks are incomplete and
one or more hooks in the fs-specific code is required.
For some other fs's (such as tmpfs), cleancache may even
be counterproductive.

So it seemed prudent to require an fs to "opt in" to
use cleancache, which requires at least one hook in
any fs.

3) Why are filesystems missing?
=20
Only because they haven't been tested.  The existence
proof of four fs's (ext3/ext4/ocfs2/btfrs) should be
sufficient to validate the concept, the opt-in approach
means that untested filesystems are not affected, and
the hooks in the four fs's should serve as examples to
show that it should be very easy to add more fs's in the
future.

> Please give your patches some semi-resonable subject line.

Not sure what you mean... are the subject lines too short?
Or should I leave off the back-reference to Transcendent Memory?
Or please suggest something you think is more reasonable?

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
