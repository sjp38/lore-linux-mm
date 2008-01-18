Date: Fri, 18 Jan 2008 16:01:07 +1100
From: David Chinner <dgc@sgi.com>
Subject: Re: [patch] Converting writeback linked lists to a tree based data structure
Message-ID: <20080118050107.GS155259@sgi.com>
References: <20080115080921.70E3810653@localhost> <400562938.07583@ustc.edu.cn> <532480950801171307q4b540ewa3acb6bfbea5dbc8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <532480950801171307q4b540ewa3acb6bfbea5dbc8@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Michael Rubin <mrubin@google.com>
Cc: Fengguang Wu <wfg@mail.ustc.edu.cn>, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 17, 2008 at 01:07:05PM -0800, Michael Rubin wrote:
> > Michael, could you sort out and document the new starvation prevention schemes?
> 
> The basic idea behind the writeback algorithm to handle starvation.
> The over arching idea is that we want to preserve order of writeback
> based on when an inode was dirtied and also preserve the dirtied_when
> contents until the inode has been written back (partially or fully)
> 
> Every sync_sb_inodes we find the least recent inodes dirtied. To deal
> with large or small starvation we have a s_flush_gen for each
> iteration of sync_sb_inodes every time we issue a writeback we mark
> that the inode cannot be processed until the next s_flush_gen. This
> way we don't process one get to the rest since we keep pushing them
> into subsequent s_fush_gen's.

This seems suboptimal for large files. If you keep feeding in
new least recently dirtied files, the large files will never
get an unimpeded go at the disk and hence we'll struggle to
get decent bandwidth under anything but pure large file
write loads.

Fairness is a tradeoff between seeks and bandwidth.  Ideally, we
want to spend 50% of the *disk* time servicing sequential writes and
50% of the time servicing seeky writes - that way neither get
penalised unfairly by the other type of workload.

Switching inodes during writeback implies a seek to the new write
location, while continuing to write the same inode has no seek
penalty because the writeback is sequential.  It follows from this
that allowing larges file a disproportionate amount of data
writeback is desirable.

Also, cycling rapidly through all the large files to write 4MB to each is
going to cause us to spend time seeking rather than writing compared
to cycling slower and writing 40MB from each large file at a time.

i.e. servicing one large file for 100ms is going to result in higher
writeback throughput than servicing 10 large files for 10ms each
because there's going to be less seeking and more writing done by
the disks.

That is, think of large file writes like process scheduler batch
jobs - bulk throughput is what matters, so the larger the time slice
you give them the higher the throughput.

IMO, the sort of result we should be looking at is a
writeback design that results in cycling somewhat like:

	slice 1: iterate over small files
	slice 2: flush large file 1
	slice 3: iterate over small files
	slice 4: flush large file 2
	......
	slice n-1: flush large file N
	slice n: iterate over small files
	slice n+1: flush large file N+1

So that we keep the disk busy with a relatively fair mix of
small and large I/Os while both are necessary.

Furthermore, as disk bandwidth goes up, the relationship
between large file and small file writes changes if we want
to maintain writeback at a significant percentage of the
maximum bandwidth of the drive (which is extremely desirable).
So if we take a 4k page machine and a 1024page writeback slice,
for different disks, we get a bandwidth slice in terms of disk
seeks like:

slow disk: 20MB/s, 10ms seek (say a laptop drive)
	- 4MB write takes 200ms, or equivalent of 10 seeks

normal disk: 60MB/s, 8ms seek (desktop)
	- 4MB write takes 66ms, or equivalent of 8 seeks

fast disk: 120MB/s, 5ms seek (15krpm SAS)
	- 4MB write takes 33ms,  or equivalent of 6 seeks

small RAID5 lun: 200MB/s, 4ms seek
	- 4MB write takes 20ms, or equivalent of 5 seeks

Large RAID5 lun: 1GB/s, 2ms seek
	- 4MB write takes 4ms, or equivalent of 2 seeks

Put simply:

	The higher the bandwidth of the device, the more frequently
	we need to be servicing the inodes with large amounts of
	dirty data to be written to maintain write throughput at a
	significant percentage of the device capability.

The writeback algorithm needs to take this into account for it
to be able to scale effectively for high throughput devices.

BTW, it needs to be recognised that if we are under memory pressure
we can clean much more memory in a short period of time by writing
out all the large files first. This would clearly benefit the system
as a whole as we'd get the most pages available for reclaim as
possible in a short a time as possible. The writeback algorithm
should really have a mode that allows this sort of flush ordering to
occur....

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
