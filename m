Date: Mon, 6 Aug 2007 09:47:18 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070806094718.73a4539c@think.oraclecorp.com>
In-Reply-To: <20070805150029.GB28263@thunk.org>
References: <20070803123712.987126000@chello.nl>
	<alpine.LFD.0.999.0708031518440.8184@woody.linux-foundation.org>
	<20070804063217.GA25069@elte.hu>
	<20070804070737.GA940@elte.hu>
	<20070804103347.GA1956@elte.hu>
	<alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org>
	<20070804163733.GA31001@elte.hu>
	<p73hcnen7w2.fsf@bingen.suse.de>
	<20070805150029.GB28263@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Theodore Tso <tytso@mit.edu>
Cc: Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk
List-ID: <linux-mm.kvack.org>

On Sun, 5 Aug 2007 11:00:29 -0400
Theodore Tso <tytso@mit.edu> wrote:

> On Sun, Aug 05, 2007 at 02:26:53AM +0200, Andi Kleen wrote:
> > I always thought the right solution would be to just sync atime only
> > very very lazily. This means if a inode is only dirty because of an
> > atime update put it on a "only write out when there is nothing to do
> > or the memory is really needed" list.
> 
> As I've mentioend earlier, the memory balancing issues that arise when
> we add an "atime dirty" bit scare me a little.  It can be addressed,
> obviously, but at the cost of more code complexity.

ext3 and reiser both use a dirty_inode method to make sure that we
don't actually have dirty inodes.  This way, kswapd doesn't get stuck
on the log and is able to do real work.

It would be interesting to see a comparison of relatime with a kinoded
that is willing to get stuck on the log.  The FS would need a few
tweaks so that write_inode() could know if it really needed to log or
not, but for testing you could just drop ext3_dirty_inode and have
ext3_write_inode do real work.

Then just change kswapd to kick a new kinoded and benchmark away.  A
real patch would have to look for places where mark_inode_dirty was
used and expected the dirty_inode callback to log things right away,
but for testing its good enough.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
