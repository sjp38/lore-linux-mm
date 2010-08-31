Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3B5076B01F0
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 20:49:24 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <37115137-2233-4b7f-b4d7-6d8ee07210e0@default>
Date: Mon, 30 Aug 2010 17:48:17 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V4 4/8] Cleancache: VFS hooks for cleancache
References: <20100830223203.GA1296@ca-server1.us.oracle.com
 4C7C35F5.6040508@goop.org>
In-Reply-To: <4C7C35F5.6040508@goop.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Chris Mason <chris.mason@oracle.com>, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, Joel Becker <joel.becker@oracle.com>, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, Dave Mccracken <dave.mccracken@oracle.com>, riel@redhat.com, avi@redhat.com, Konrad Wilk <konrad.wilk@oracle.com>, mel@csn.ul.ie, yinghan@google.com, gthelen@google.com
List-ID: <linux-mm.kvack.org>

> > +=09=09if (s->cleancache_poolid >=3D 0) {
> > +=09=09=09int cleancache_poolid =3D s->cleancache_poolid;
>=20
> That's a lot of characters for a local in a 3-line scope.

:-) OK.
=20
> > +=09=09=09s->cleancache_poolid =3D -1; /* avoid races */
>=20
> Races with what?  Something else sneaking something into the pool after
> the flush?  Is the filesystem dead at this stage or not?

If there are any inodes in the page cache that point to
this superblock, a cleancache_put_page may happen asynchronously
that grabs from page->...->i_sb->cleancache_poolid.
If the cleancache_flush_fs races with it and another
cleancache_init_fs happens after the cleancache_put_page
gets the poolid, the poolid could be stale.

Highly unlikely, but I thought it best to be safe.

> > +=09/* 99% of the time, we don't need to flush the cleancache on the
> bdev.
> > +=09 * But, for the strange corners, lets be cautious
> > +=09 */
>=20
> This comment-style is... unconventional for the kernel.

Yeah, I decided to defer to Chris Mason's wisdom and left it. :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
