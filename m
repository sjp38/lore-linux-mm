Date: Mon, 6 Aug 2007 10:24:13 +1000
From: David Chinner <dgc@sgi.com>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070806002413.GJ31489@sgi.com>
References: <20070803123712.987126000@chello.nl> <alpine.LFD.0.999.0708031518440.8184@woody.linux-foundation.org> <20070804063217.GA25069@elte.hu> <20070804070737.GA940@elte.hu> <20070804103347.GA1956@elte.hu> <alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org> <20070804094119.81d8e533.akpm@linux-foundation.org> <87wswbjejw.fsf@mid.deneb.enyo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87wswbjejw.fsf@mid.deneb.enyo.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Florian Weimer <fw@deneb.enyo.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk
List-ID: <linux-mm.kvack.org>

On Sat, Aug 04, 2007 at 09:16:35PM +0200, Florian Weimer wrote:
> * Andrew Morton:
> 
> > The easy preventive is to mount with data=writeback.  Maybe that should
> > have been the default.
> 
> The documentation I could find suggests that this may lead to a
> security weakness (old data in blocks of a file that was grown just
> before the crash leaks to a different user).  XFS overwrites that data
> with zeros upon reboot, which tends to irritate users when it happens.

XFS has never overwritten data on reboot. It leaves holes when the kernel has
failed to write out data. A hole == zeros so XFS does not expose stale data in
this situation. As it is, the underlying XFS problem (lack of synchronisation
between inode size update and data writes has been mostly fixed in 2.6.22 by
only updating the file size to be written to disk on data I/O completion.

FWIW, fsync() would prevent this from happening, but many application writers
seem strangely reluctant to put fsync() calls into code to ensure the data
they write is safely on disk.....

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
