Date: Fri, 6 Jul 2007 17:57:49 +0200
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: vm/fs meetup details
Message-ID: <20070706155748.GC846@lazybastard.org>
References: <20070705040138.GG32240@wotan.suse.de> <468D303E.4040902@redhat.com> <137D15F6-EABE-4EC1-A3AF-DAB0A22CF4E3@oracle.com> <20070705212757.GB12413810@sgi.com> <468D6569.6050606@redhat.com> <20070706022651.GG14215@wotan.suse.de> <20070706100110.GD12413810@sgi.com> <20070706102623.GA846@lazybastard.org> <20070706134201.GL31489@sgi.com> <20070706095214.1ac9da94@think.oraclecorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20070706095214.1ac9da94@think.oraclecorp.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <chris.mason@oracle.com>
Cc: David Chinner <dgc@sgi.com>, =?utf-8?B?SsODwrZybg==?= Engel <joern@logfs.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Zach Brown <zach.brown@oracle.com>, Anton Altaparmakov <aia21@cam.ac.uk>, Suparna Bhattacharya <suparna@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hugh@veritas.com>, Jared Hulbert <jaredeh@gmail.com>, "Martin J. Bligh" <mbligh@mbligh.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Neil Brown <neilb@suse.de>, Miklos Szeredi <miklos@szeredi.hu>, Mingming Cao <cmm@us.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, Steven Whitehouse <steve@chygwyn.com>, Dave McCracken <dave.mccracken@oracle.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Fri, 6 July 2007 09:52:14 -0400, Chris Mason wrote:
> On Fri, 6 Jul 2007 23:42:01 +1000 David Chinner <dgc@sgi.com> wrote:
> 
> > Hmmm - I guess you could use it for writeback ordering. I hadn't
> > really thought about that. Doesn't seem a particularly efficient way
> > of doing it, though. Why not just use multiple address spaces for
> > this? i.e. one per level and flush in ascending order.

Interesting idea.  Is it possible to attach several address spaces to an
inode?  That would cure some headaches.

> At least in the case of btrfs, the perfect order for sync is disk
> order ;)  COW happens when blocks are changed for the first time in a
> transaction, not when they are written out to disk.  If logfs is
> writing things out some form of tree order, you're going to have to
> group disk allocations such that tree order reflects disk order somehow.

I don't understand half of what you're writing.  Maybe we should do
another design session on irc?

At any rate, logfs simply writes out blocks.  When it is handed a page
to write, the corresponding block is written.  Allocation happens at
writeout time, not earlier.  Each written block causes a higher-level
block to get changed, so that is written immediatly as well, until the
next higher level is the inode.

I would like to instead just dirty the higher-level block, so that
multiple changes can accumulate before indirect blocks are written.  And
I have no idea how transactions relate to all this.

> But, the part where we toss leaves first is definitely useful.

Shouldn't LRU ordering already do that.  I can even imagine cases when
leaves should be tossed last and LRU ordering would dtrt.

JA?rn

-- 
The competent programmer is fully aware of the strictly limited size of
his own skull; therefore he approaches the programming task in full
humility, and among other things he avoids clever tricks like the plague.
-- Edsger W. Dijkstra

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
