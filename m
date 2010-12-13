Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AD05D6B008A
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 15:54:26 -0500 (EST)
Subject: Re: [PATCH 30/35] nfs: heuristics to avoid commit
From: Trond Myklebust <Trond.Myklebust@netapp.com>
In-Reply-To: <20101213150329.953837345@intel.com>
References: <20101213144646.341970461@intel.com>
	 <20101213150329.953837345@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 13 Dec 2010 15:53:46 -0500
Message-ID: <1292273626.8795.19.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-12-13 at 22:47 +0800, Wu Fengguang wrote:
> plain text document attachment (writeback-nfs-should-commit.patch)
> The heuristics introduced by commit 420e3646 ("NFS: Reduce the number of
> unnecessary COMMIT calls") do not work well for large inodes being
> actively written to.
>=20
> Refine the criterion to
> - it has gone quiet (all data transfered to server)
> - has accumulated >=3D 4MB data to commit (so it will be large IO)
> - too few active commits (hence active IO) in the server

Where does the number 4MB come from? If I'm writing a 4GB file, I
certainly do not want to commit every 4MB; that would make for a total
of 1000 commit requests in addition to the writes. On a 64-bit client
+server both having loads of memory and connected by a decently a fast
network, that can be a significant slowdown...

Most of the time, we really want the server to be managing its dirty
cache entirely independently of the client. The latter should only be
sending the commit when it really needs to free up those pages.

Cheers
  Trond


--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
