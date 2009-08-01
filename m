Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id DD12B6B004D
	for <linux-mm@kvack.org>; Sat,  1 Aug 2009 00:01:58 -0400 (EDT)
Date: Sat, 1 Aug 2009 12:02:24 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Bug in kernel 2.6.31, Slow wb_kupdate writeout
Message-ID: <20090801040224.GA13291@localhost>
References: <1786ab030907281211x6e432ba6ha6afe9de73f24e0c@mail.gmail.com> <20090730213956.GH12579@kernel.dk> <33307c790907301501v4c605ea8oe57762b21d414445@mail.gmail.com> <20090730221727.GI12579@kernel.dk> <33307c790907301534v64c08f59o66fbdfbd3174ff5f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <33307c790907301534v64c08f59o66fbdfbd3174ff5f@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Martin Bligh <mbligh@google.com>
Cc: Jens Axboe <jens.axboe@oracle.com>, Chad Talbott <ctalbott@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Rubin <mrubin@google.com>, Andrew Morton <akpm@google.com>, sandeen@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, Jul 30, 2009 at 03:34:12PM -0700, Martin Bligh wrote:
> > The test case above on a 4G machine is only generating 1G of dirty data.
> > I ran the same test case on the 16G, resulting in only background
> > writeout. The relevant bit here being that the background writeout
> > finished quickly, writing at disk speed.
> >
> > I re-ran the same test, but using 300 100MB files instead. While the
> > dd's are running, we are going at ~80MB/sec (this is disk speed, it's an
> > x25-m). When the dd's are done, it continues doing 80MB/sec for 10
> > seconds or so. Then the remainder (about 2G) is written in bursts at
> > disk speeds, but with some time in between.
> 
> OK, I think the test case is sensitive to how many files you have - if
> we punt them to the back of the list, and yet we still have 299 other
> ones, it may well be able to keep the disk spinning despite the bug
> I outlined.Try using 30 1GB files?
> 
> Though it doesn't seem to happen with just one dd streamer, and
> I don't see why the bug doesn't trigger in that case either.

I guess the bug is not related to number dd streamers, but whether
there is a stream of newly dirtied inodes (atime dirtiness would be
enough). Because wb_kupdate() itself won't give up on congestion, but
redirty_tail() would refresh the inode dirty time if there are newly
dirtied inodes in front. And we cannot claim it to be a bug of the
list based redirty_tail(), since we call it with the belief that the
inode is somehow blocked. In this manner redirty_tail() can refresh
the inode dirty time (and therefore delay its writeback for up to 30s)
at will.

> I believe the bugfix is correct independent of any bdi changes?

Agreed.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
