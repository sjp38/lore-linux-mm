Date: Sat, 4 Aug 2007 17:48:21 -0400
From: Theodore Tso <tytso@mit.edu>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070804214821.GC11150@thunk.org>
References: <20070804103347.GA1956@elte.hu> <alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org> <20070804163733.GA31001@elte.hu> <alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org> <46B4C0A8.1000902@garzik.org> <20070804191205.GA24723@lazybastard.org> <20070804192130.GA25346@elte.hu> <20070804192615.GA25600@lazybastard.org> <alpine.LFD.0.999.0708041246530.5037@woody.linux-foundation.org> <1186258399.2777.8.camel@laptopd505.fenrus.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1186258399.2777.8.camel@laptopd505.fenrus.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, =?iso-8859-1?Q?J=F6rn?= Engel <joern@logfs.org>, Ingo Molnar <mingo@elte.hu>, Jeff Garzik <jeff@garzik.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

On Sat, Aug 04, 2007 at 01:13:19PM -0700, Arjan van de Ven wrote:
> there is another trick possible (more involved though, Al will have to
> jump in on that one I suspect): Have 2 types of "dirty inode" states;
> one is the current dirty state (meaning the full range of ext3
> transactions etc) and "lighter" state of "atime-dirty"; which will not
> do the background syncs or journal transactions (so if your machine
> crashes, you lose the atime update) but it does keep atime for most
> normal cases and keeps it standard compliant "except after a crash".

That would make us standards compliant (POSIX explicitly says that
what happens after a unclean shutdown is Unspecified) and it would
make things a heck of a lot faster.  However, there is a potential
problem which is that it will keep a large number of inodes pinned in
memory, which is its own problem.  So there would have to be some way
to force the atime updates to be merged when under memory pressure,
and and perhaps on some much longer background interval (i.e., every
hour or so).

							- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
