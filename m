Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id DF8F86B008A
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 03:20:55 -0500 (EST)
Date: Tue, 14 Dec 2010 16:20:50 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 30/35] nfs: heuristics to avoid commit
Message-ID: <20101214082050.GC6940@localhost>
References: <20101213144646.341970461@intel.com>
 <20101213150329.953837345@intel.com>
 <1292273626.8795.19.camel@heimdal.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1292273626.8795.19.camel@heimdal.trondhjem.org>
Sender: owner-linux-mm@kvack.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, "Tang, Feng" <feng.tang@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 14, 2010 at 04:53:46AM +0800, Trond Myklebust wrote:
> On Mon, 2010-12-13 at 22:47 +0800, Wu Fengguang wrote:
> > plain text document attachment (writeback-nfs-should-commit.patch)
> > The heuristics introduced by commit 420e3646 ("NFS: Reduce the number of
> > unnecessary COMMIT calls") do not work well for large inodes being
> > actively written to.
> > 
> > Refine the criterion to
> > - it has gone quiet (all data transfered to server)
> > - has accumulated >= 4MB data to commit (so it will be large IO)
> > - too few active commits (hence active IO) in the server
> 
> Where does the number 4MB come from? If I'm writing a 4GB file, I
> certainly do not want to commit every 4MB; that would make for a total
> of 1000 commit requests in addition to the writes. On a 64-bit client
> +server both having loads of memory and connected by a decently a fast
> network, that can be a significant slowdown...

Sorry the description omits too much details..

Let me show you the behavior in real workload first.

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/nfs-1dd-1M-8p-2952M-2.6.37-rc5+-2010-12-09-03-04/writeback-inode.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/nfs-1dd-1M-8p-2952M-2.6.37-rc5+-2010-12-09-03-04/nfs-commit-300.png

On a 3GB client writing 50MB/s to the NFS server, the write chunk size
and commit size is mostly 32MB and 64MB.

The ->writepages() size and the later commit size actually scales up
to the available write bandwidth ("[PATCH 20/35] writeback: scale IO
chunk size up to device bandwidth").

So the "4MB" here is merely the minimal threshold. I chose it mainly
by the rule of thumb "it's not too bad IO size". And it's mainly used
for the cases:

1) low client=>server write bandwidth

In this case the VFS will call ->writepages() with small (but always
 >= 4MB, see patch 20/35) nr_to_write , and the 4MB threshold helps
accumulate to-be-commited pages over multiple ->write_inode() calls.
As you said it will help to further scale this 4MB threshold up to the
client's memory size. But complexity arises in the next case.

2) bandwidth/memory is high, but there are lots of concurrent dd's

When doing 10 dd's with mem=3G, it still achieves 20-30MB write/commit
size:
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/nfs-10dd-1M-8p-2952M-2.6.37-rc5+-2010-12-09-03-13/writeback-300.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/nfs-10dd-1M-8p-2952M-2.6.37-rc5+-2010-12-09-03-13/nfs-commit-300.png

However when there comes 100 dd's, you cannot wait each inode to
accumulate much more than 4MB pages to commit, because 4*100MB is
approaching the client's dirty limit. So you'll see around 4-5MB
commit sizes in this graph.
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/nfs-100dd-1M-8p-2952M-2.6.37-rc5+-2010-12-09-03-23/nfs-commit-300.png

Then you see the problem: how to decide one auto scaled threshold to
start commit for the current inode? It's easy for the 1-dd case.
However when there are N dd's (admittedly NFS clients rarely do large
N), we don't readily know the number N to scale down the threshold
that's suitable for 1-dd case..

So I give up the scale-to-memory commit threshold idea that could help
case (1) and just do it in a dumb but should good enough way. But I'm
open to better ideas :)

> Most of the time, we really want the server to be managing its dirty
> cache entirely independently of the client. The latter should only be
> sending the commit when it really needs to free up those pages.

Agreed. And it makes one major contrariety I'm fighting about: do large
commit size but not too much to make unacceptable fluctuations in the
data flow. It leads to the decision to include patch 20/35 into this
series. It magically reduces the frequency to ->writepages()/write_inode()
and results in semi-adaptive wrote pages in each ->writepages() (and
the later commit) to the number of concurrent dd's.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
