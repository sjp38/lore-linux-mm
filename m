Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 348156B024D
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 10:45:10 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <364c83bd-ccb2-48cc-920d-ffcf9ca7df19@default>
Date: Fri, 23 Jul 2010 07:44:11 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V3 0/8] Cleancache: overview
References: <20100621231809.GA11111@ca-server1.us.oracle.com4C49468B.40307@vflare.org>
 <840b32ff-a303-468e-9d4e-30fc92f629f8@default
 20100723140440.GA12423@infradead.org>
In-Reply-To: <20100723140440.GA12423@infradead.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: ngupta@vflare.org, akpm@linux-foundation.org, Chris Mason <chris.mason@oracle.com>, viro@zeniv.linux.org.uk, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, Joel Becker <joel.becker@oracle.com>, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, jeremy@goop.org, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@suse.de, Dave Mccracken <dave.mccracken@oracle.com>, riel@redhat.com, avi@redhat.com, Konrad Wilk <konrad.wilk@oracle.com>
List-ID: <linux-mm.kvack.org>

> From: Christoph Hellwig [mailto:hch@infradead.org]
> Subject: Re: [PATCH V3 0/8] Cleancache: overview
>=20
> On Fri, Jul 23, 2010 at 06:58:03AM -0700, Dan Magenheimer wrote:
> > CHRISTOPH AND ANDREW, if you disagree and your concerns have
> > not been resolved, please speak up.

Hi Christoph --

Thanks very much for the quick (instantaneous?) reply!

> Anything that need modification of a normal non-shared fs is utterly
> broken and you'll get a clear NAK, so the propsal before is a good
> one.

Unless/until all filesystems are 100% built on top of VFS,
I have to disagree.  Abstractions (e.g. VFS) are never perfect.
And the relevant filesystem maintainers have acked, so I'm
wondering who you are NAK'ing for?

Nitin's proposal attempts to move the VFS hooks around to fix
usage for one fs (btrfs) that, for whatever reason, has
chosen to not layer itself completely on top of VFS; this
sounds to me like a recipe for disaster.
I think Minchan's reply quickly pointed out one issue...
what other filesystems that haven't been changed might
encounter a rare data corruption issue because cleancache is
transparently enabled for its page cache pages?

It also drops requires support to be dropped entirely for
another fs (ocfs2) which one user (zcache) can't use, but
the other (tmem) makes very good use of.

No, the per-fs opt-in is very sensible; and its design is
very minimal.

Could you please explain your objection further?

> There's a couple more issues like the still weird prototypes,
> e.g. and i_ino might not be enoug to uniquely identify an inode
> on serveral filesystems that use 64-bit inode inode numbers on 32-bit
> systems.

This reinforces my per-fs opt-in point.  Such filesystems
should not enable cleancache (or enable them only on the
appropriate systems).

> Also making the ops vector global is just a bad idea.
> There is nothing making this sort of caching inherently global.

I'm not sure I understand your point, but two very different
users of cleancache have been provided, and more will be
discussed at the MM summit next month.

Do you have a suggestion on how to avoid a global ops
vector while still serving the needs of both existing
users?

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
