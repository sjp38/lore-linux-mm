Date: Fri, 6 Jul 2007 09:52:14 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: vm/fs meetup details
Message-ID: <20070706095214.1ac9da94@think.oraclecorp.com>
In-Reply-To: <20070706134201.GL31489@sgi.com>
References: <20070705040138.GG32240@wotan.suse.de>
	<468D303E.4040902@redhat.com>
	<137D15F6-EABE-4EC1-A3AF-DAB0A22CF4E3@oracle.com>
	<20070705212757.GB12413810@sgi.com>
	<468D6569.6050606@redhat.com>
	<20070706022651.GG14215@wotan.suse.de>
	<20070706100110.GD12413810@sgi.com>
	<20070706102623.GA846@lazybastard.org>
	<20070706134201.GL31489@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: =?UTF-8?B?SsODwrZybg==?= Engel <joern@logfs.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Zach Brown <zach.brown@oracle.com>, Anton Altaparmakov <aia21@cam.ac.uk>, Suparna Bhattacharya <suparna@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hugh@veritas.com>, Jared Hulbert <jaredeh@gmail.com>, "Martin J. Bligh" <mbligh@mbligh.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Neil Brown <neilb@suse.de>, Miklos Szeredi <miklos@szeredi.hu>, Mingming Cao <cmm@us.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, Steven Whitehouse <steve@chygwyn.com>, Dave McCracken <dave.mccracken@oracle.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Fri, 6 Jul 2007 23:42:01 +1000
David Chinner <dgc@sgi.com> wrote:

> On Fri, Jul 06, 2007 at 12:26:23PM +0200, JA?A?rn Engel wrote:
> > On Fri, 6 July 2007 20:01:10 +1000, David Chinner wrote:
> > > On Fri, Jul 06, 2007 at 04:26:51AM +0200, Nick Piggin wrote:
> > > 
> > > But, surprisingly enough, the above work is relevent to this
> > > forum because of two things:
> > > 
> > > 	- we've had to move to direct I/O and user space caching
> > > to work around deficiencies in kernel block device caching under
> > > memory pressure....
> > > 
> > > 	- we've exploited techniques that XFS supports but the VM
> > > does not. i.e. priority tagging of cached metadata so that less
> > > important metadata is tossed first (e.g. toss tree leaves before
> > > nodes and nodes before roots) when under memory pressure.
> > 
> > And the latter is exactly what logfs needs as well.  You certainly
> > have me interested.
> > 
> > I believe it applies to btrfs and any other cow-fs as well.  The
> > point is that higher levels get dirtied by writing lower layers.
> > So perfect behaviour for sync is to write leaves first, then nodes,
> > then the root.  Any other order will either cause sync not to sync
> > or cause unnecessary writes and cost performance.
> 
> Hmmm - I guess you could use it for writeback ordering. I hadn't
> really thought about that. Doesn't seem a particularly efficient way
> of doing it, though. Why not just use multiple address spaces for
> this? i.e. one per level and flush in ascending order.
> 

At least in the case of btrfs, the perfect order for sync is disk
order ;)  COW happens when blocks are changed for the first time in a
transaction, not when they are written out to disk.  If logfs is
writing things out some form of tree order, you're going to have to
group disk allocations such that tree order reflects disk order somehow.

But, the part where we toss leaves first is definitely useful.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
