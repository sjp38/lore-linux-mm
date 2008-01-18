Date: Fri, 18 Jan 2008 19:54:07 +1100
From: David Chinner <dgc@sgi.com>
Subject: Re: [patch] Converting writeback linked lists to a tree based data structure
Message-ID: <20080118085407.GV155259@sgi.com>
References: <20080115080921.70E3810653@localhost> <400562938.07583@ustc.edu.cn> <532480950801171307q4b540ewa3acb6bfbea5dbc8@mail.gmail.com> <20080118050107.GS155259@sgi.com> <532480950801172138x44e06780w2b15464845b626fc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <532480950801172138x44e06780w2b15464845b626fc@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Michael Rubin <mrubin@google.com>
Cc: David Chinner <dgc@sgi.com>, Fengguang Wu <wfg@mail.ustc.edu.cn>, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 17, 2008 at 09:38:24PM -0800, Michael Rubin wrote:
> On Jan 17, 2008 9:01 PM, David Chinner <dgc@sgi.com> wrote:
> 
> First off thank you for the very detailed reply. This rocks and gives
> me much to think about.
> 
> > On Thu, Jan 17, 2008 at 01:07:05PM -0800, Michael Rubin wrote:
> > This seems suboptimal for large files. If you keep feeding in
> > new least recently dirtied files, the large files will never
> > get an unimpeded go at the disk and hence we'll struggle to
> > get decent bandwidth under anything but pure large file
> > write loads.
> 
> You're right. I understand now. I just  changed a dial on my tests,
> ran it and found pdflush not keeping up like it should. I need to
> address this.
> 
> > Switching inodes during writeback implies a seek to the new write
> > location, while continuing to write the same inode has no seek
> > penalty because the writeback is sequential.  It follows from this
> > that allowing larges file a disproportionate amount of data
> > writeback is desirable.
> >
> > Also, cycling rapidly through all the large files to write 4MB to each is
> > going to cause us to spend time seeking rather than writing compared
> > to cycling slower and writing 40MB from each large file at a time.
> >
> > i.e. servicing one large file for 100ms is going to result in higher
> > writeback throughput than servicing 10 large files for 10ms each
> > because there's going to be less seeking and more writing done by
> > the disks.
> >
> > That is, think of large file writes like process scheduler batch
> > jobs - bulk throughput is what matters, so the larger the time slice
> > you give them the higher the throughput.
> >
> > IMO, the sort of result we should be looking at is a
> > writeback design that results in cycling somewhat like:
> >
> >         slice 1: iterate over small files
> >         slice 2: flush large file 1
> >         slice 3: iterate over small files
> >         slice 4: flush large file 2
> >         ......
> >         slice n-1: flush large file N
> >         slice n: iterate over small files
> >         slice n+1: flush large file N+1
> >
> > So that we keep the disk busy with a relatively fair mix of
> > small and large I/Os while both are necessary.
> 
> I am getting where you are coming from. But if we are going to make
> changes to optimize for seeks maybe we need to be more aggressive in
> write back in how we organize both time and location. Right now AFAIK
> there is no attention to location in the writeback path.

True. But IMO, locality ordering really only impacts the small file
data writes and the inodes themselves because there is typically
lots of seeks in doing that.

For large sequential writes to a file, writing a significant
chunk of data gives that bit of writeback it's own locality
because it does not cause seeks. Hence simply writing large
enough chunks avoids any need to order the writeback by locality.

Hence I writeback ordering by locality more a function of 
optimising the "iterate over small files" aspect of the writeback.

> >         The higher the bandwidth of the device, the more frequently
> >         we need to be servicing the inodes with large amounts of
> >         dirty data to be written to maintain write throughput at a
> >         significant percentage of the device capability.
> >
> 
> Could you expand that to say it's not the inodes of large files but
> the ones with data that we can exploit locality?

Not sure I understand what you mean. Can you rephrase that?

> Often large files are fragmented.

Then the filesystem is not doing it's job. Fragmentation does
not happen very frequently in XFS for large files - that is one
of the reasons it is extremely good for large files and high
throughput applications...

> Would it make more sense to pursue cracking the inodes and
> grouping their blocks's locations? Or is this all overkill and should
> be handled at a lower level like the elevator?

For large files it is overkill. For filesystems that do delayed
allocation, it is often impossible (no block mapping until
the writeback is executed unless it's an overwrite).

At this point, I'd say it is best to leave it to the filesystem and
the elevator to do their jobs properly.

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
