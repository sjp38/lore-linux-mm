Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 7C6336B0062
	for <linux-mm@kvack.org>; Sun,  2 Sep 2012 20:40:01 -0400 (EDT)
Date: Mon, 3 Sep 2012 10:39:51 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/3] HWPOISON: prevent inode cache removal to keep
 AS_HWPOISON sticky
Message-ID: <20120903003951.GL15292@dastard>
References: <20120826222607.GD19235@dastard>
 <1346105106-26033-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20120829025941.GD13691@dastard>
 <503DA954.80009@ce.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <503DA954.80009@ce.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 29, 2012 at 02:32:04PM +0900, Jun'ichi Nomura wrote:
> On 08/29/12 11:59, Dave Chinner wrote:
> > On Mon, Aug 27, 2012 at 06:05:06PM -0400, Naoya Horiguchi wrote:
> >> And yes, I understand it's ideal, but many applications choose not to
> >> do that for performance reason.
> >> So I think it's helpful if we can surely report to such applications.
> 
> I suspect "performance vs. integrity" is not a correct
> description of the problem.

Right, to be  more precise, it's a "eat my data" vs "integrity"
problem. And in almost all cases I've seen over the years, "eat my
data" is done for performance reasons...

> > If performance is chosen over data integrity, we are under no
> > obligation to keep the error around indefinitely.  Fundamentally,
> > ensuring a write completes successfully is the reponsibility of the
> > application, not the kernel. There are so many different filesytem
> > and storage errors that can be lost right now because data is not
> > fsync()d, adding another one to them really doesn't change anything.
> > IOWs, a memory error is no different to a disk failing or the system
> > crashing when it comes to data integrity. If you care, you use
> > fsync().
> 
> I agree that applications should fsync() or O_SYNC
> when it wants to make sure the written data in on disk.
> 
> AFAIU, what Naoya is going to address is the case where
> fsync() is not necessarily needed.
> 
> For example, if someone do:
>   $ patch -p1 < ../a.patch
>   $ tar cf . > ../a.tar
> 
> and disk failure occurred between "patch" and "tar",
> "tar" will either see uptodate data or I/O error.

No, it won't. The only place AS_EIO is tested is in
filemap_fdatawait_range(), which is only called in the fsync() path.
The only way to report async write IO errors is to use fsync() -
subsequent reads of the file do *not* see the write error.

IOWs, tar will be oblivious of any IO error that preceeded it
reading the files it is copying.

> OTOH, if the failure was detected on dirty pagecache, the current memory
> failure handler invalidates the dirty page and the "tar" command will
> re-read old contents from disk without error.

After an IO error, the dirty page is no longer uptodate - that gets
cleared - so when the page is read the data will be re-read from
disk just like if a memory error occurred. So tar will behave the
same regardless of whether it is a memory error or an IO error (i.e.
reread old data from disk)

> (Well, the failures above are permanent failures.

Write IO errors can also be transient or permanent. Transient, for
example, when a path failure occurs and multipathing then detects
this and fails over to a good path. A subsequent write will then
succeed. Permanent, for example, when someone unplugs a USB drive.

> IOW, the current
>  memory failure handler turns permanent failure into transient error,
>  which is often more difficult to handle, I think.)

The patch I commented on is turning a transient error (error in a
page that is then poisoned and never used again) into a permanent
error (error on an address space that is reported on every future
operation that tries to insert a page into the page cache).

> Naoya's patch will keep the failure information and allows the reader
> to get I/O error when it reads from broken pagecache.

It only adds a hwposion check in add_to_page_cache_locked(). If the
page is already in the cache, then no error will be sent to the
reader because it never gets to add_to_page_cache_locked().

So there's no guarantee that the reader is even going to see the
error, or that they see the error on the page that actually caused
it - access to any missing page in the page cache will trigger it.
And as memory reclaim clears pages off the inode, more and more of
the range of the inode's data will return an error, even though
there is nothing wrong with the data in most of the file.

Indeed, what happens if the application calls fsync, gets the error
and tries to rewrite the page? i.e. it does everything correctly to
handle the write error? With this patch set, the application
cannot insert a replacement page into the page cache, so all
subsequent writes fail! IOWs, it makes it impossible for
applications to recover from a detected and handled memory failure.

I have no issue with reporting the problem to userspace - that needs
t am I saying that the current IO reporting is wonderful and can't
be improved. What I am saying, though, is that I really don't think
this patch set has been well thought through from either an IO path
or userspace error handling point of view.  The problems with this
patch set are quite significant:
	- permanent, unclearable error except by complete removal of
	  all data on the file. (forcing the removal of all
	  good data to recover from a transient error on a small
	  amount of data).
	- while the error is present, bad data cannot be overwritten
	  (applications cannot recover even if they catch the
	  error).
	- while the error is present, no new data can be written
	  (applications can't continue even if they don't care
	  about the error).
	- while the error is present, no valid data can be read from
	  the file (applications can't access good data they
	  need to run even after the error has been handled).
	- memory reclaim will slowly remove uptodate cached pages
	  and so re-reading good cached pages can suddenly return
	  errors even though no new error has been encountered.
	  (error gets worse over time until all good data is removed
	  or the system is rebooted).

The first thing that you need to do is make sure applications can
recover from a detected (via fsync) hwpoisoning event on a dirty
page in the page cache. Once you have that working, then handle the
case of errors on clean pages (e.g. hwpoison a libc dso page and see
if the machine continues to operate). Once you have a system
resilient to clean page errors and dirty page errors for
applications that care about data integrity, then you can start
thinking about making stuff better for applications that don't care
about data integrity....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
