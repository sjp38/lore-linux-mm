Subject: Re: [PATCH 00/23] per device dirty throttling -v8
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <20070804214821.GC11150@thunk.org>
References: <20070804103347.GA1956@elte.hu>
	 <alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org>
	 <20070804163733.GA31001@elte.hu>
	 <alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org>
	 <46B4C0A8.1000902@garzik.org> <20070804191205.GA24723@lazybastard.org>
	 <20070804192130.GA25346@elte.hu> <20070804192615.GA25600@lazybastard.org>
	 <alpine.LFD.0.999.0708041246530.5037@woody.linux-foundation.org>
	 <1186258399.2777.8.camel@laptopd505.fenrus.org>
	 <20070804214821.GC11150@thunk.org>
Content-Type: text/plain
Date: Sun, 05 Aug 2007 11:01:18 -0700
Message-Id: <1186336878.2777.15.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Theodore Tso <tytso@mit.edu>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, =?ISO-8859-1?Q?J=F6rn?= Engel <joern@logfs.org>, Ingo Molnar <mingo@elte.hu>, Jeff Garzik <jeff@garzik.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

On Sat, 2007-08-04 at 17:48 -0400, Theodore Tso wrote:
> On Sat, Aug 04, 2007 at 01:13:19PM -0700, Arjan van de Ven wrote:
> > there is another trick possible (more involved though, Al will have to
> > jump in on that one I suspect): Have 2 types of "dirty inode" states;
> > one is the current dirty state (meaning the full range of ext3
> > transactions etc) and "lighter" state of "atime-dirty"; which will not
> > do the background syncs or journal transactions (so if your machine
> > crashes, you lose the atime update) but it does keep atime for most
> > normal cases and keeps it standard compliant "except after a crash".
> 
> That would make us standards compliant (POSIX explicitly says that
> what happens after a unclean shutdown is Unspecified) and it would
> make things a heck of a lot faster.  However, there is a potential
> problem which is that it will keep a large number of inodes pinned in
> memory, which is its own problem.  So there would have to be some way
> to force the atime updates to be merged when under memory pressure,
> and and perhaps on some much longer background interval (i.e., every
> hour or so).

on the journalling side this would be one transaction (not 5 milion)
and... since inodes are grouped on disk, you can even get some better
coalescing this way... 

Wonder if we could do inode-grouping smartly; eg if we HAVE to write
inode X, also write out the atime-dirty inodes in range X-Y to X+Y
(where Y is some tunable) in the same IO..


-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com
Test the interaction between Linux and your BIOS via http://www.linuxfirmwarekit.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
