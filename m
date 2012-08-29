Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 83EE36B0068
	for <linux-mm@kvack.org>; Tue, 28 Aug 2012 23:00:07 -0400 (EDT)
Date: Wed, 29 Aug 2012 12:59:41 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/3] HWPOISON: prevent inode cache removal to keep
 AS_HWPOISON sticky
Message-ID: <20120829025941.GD13691@dastard>
References: <20120826222607.GD19235@dastard>
 <1346105106-26033-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1346105106-26033-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Rik van Riel <riel@redhat.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 27, 2012 at 06:05:06PM -0400, Naoya Horiguchi wrote:
> On Mon, Aug 27, 2012 at 08:26:07AM +1000, Dave Chinner wrote:
> > On Fri, Aug 24, 2012 at 01:24:16PM -0400, Naoya Horiguchi wrote:
> > > Let me explain more to clarify my whole scenario. If a memory error
> > > hits on a dirty pagecache, kernel works like below:
> > > 
> > >   1. handles a MCE interrupt (logging MCE events,)
> > >   2. calls memory error handler (doing 3 to 6,)
> > >   3. sets PageHWPoison flag on the error page,
> > >   4. unmaps all mappings to processes' virtual addresses,
> > 
> > So nothing in userspace sees the bad page after this.
> > 
> > >   5. sets AS_HWPOISON on mappings to which the error page belongs
> > >   6. invalidates the error page (unlinks it from LRU list and removes
> > >      it from pagecache,)
> > >   (memory error handler finished)
> > 
> > Ok, so the moment a memory error is handled, the page has been
> > removed from the inode's mapping, and it will never be seen by
> > aplications again. It's a transient error....
> > 
> > >   7. later accesses to the file returns -EIO,
> > >   8. AS_HWPOISON is cleared when the file is removed or completely
> > >      truncated.
> > 
> > .... so why do we have to keep an EIO on the inode forever?
> > 
> > If the page is not dirty, then just tossing it from the cache (as
> > is already done) and rereading it from disk next time it is accessed
> > removes the need for any error to be reported at all. It's
> > effectively a transient error at this point, and as such no errors
> > should be visible from userspace.
> > 
> > If the page is dirty, then it needs to be treated just like any
> > other failed page write - the page is invalidated and the address
> > space is marked with AS_EIO, and that is reported to the next
> > operation that waits on IO on that file (i.e. fsync)
> > 
> > If you have a second application that reads the files that depends
> > on a guarantee of good data, then the first step in that process is
> > that application that writes it needs to use fsync to check the data
> > was written correctly. That ensures that you only have clean pages
> > in the cache before the writer closes the file, and any h/w error
> > then devolves to the above transient clean page invalidation case.
> 
> Thank you for detailed explanations.
> And yes, I understand it's ideal, but many applications choose not to
> do that for performance reason.

You choose: data integrity or performance.

> So I think it's helpful if we can surely report to such applications.

If performance is chosen over data integrity, we are under no
obligation to keep the error around indefinitely.  Fundamentally,
ensuring a write completes successfully is the reponsibility of the
application, not the kernel. There are so many different filesytem
and storage errors that can be lost right now because data is not
fsync()d, adding another one to them really doesn't change anything.
IOWs, a memory error is no different to a disk failing or the system
crashing when it comes to data integrity. If you care, you use
fsync().

> > Hence I fail to see why this type of IO error needs to be sticky.
> > The error on the mapping is transient - it is gone as soon as the
> > page is removed from the mapping. Hence the error can be dropped as
> > soon as it is reported to userspace because the mapping is now error
> > free.
> 
> It's error free only for the applications which do fsync check in
> each write, but not for the applications which don't do.
> I think the penalty for the latters (ignore dirty data lost and get
> wrong results) is too big to consider it as a reasonable trade-off.

I'm guessing that you don't deal with data integrity issues very
often. What you are suggesting is not a reasonable tradeoff - either
applications are coded correctly for data integrity, or they give
up any expectation that errors will be detected and reported
reliably.  Hoping that we might be able to report an error somewhere
to someone who didn't care to avoid or collect in the first place
does not improve the situation for anyone....

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
