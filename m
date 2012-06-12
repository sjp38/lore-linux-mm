Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 976BF6B004D
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 04:56:45 -0400 (EDT)
Date: Tue, 12 Jun 2012 10:56:39 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: Hole punching and mmap races
Message-ID: <20120612085639.GA6021@quack.suse.cz>
References: <20120524123538.GA5632@quack.suse.cz>
 <20120605055150.GF4347@dastard>
 <20120605231530.GB4402@quack.suse.cz>
 <20120606000636.GG22848@dastard>
 <20120606095827.GA6304@quack.suse.cz>
 <20120606133616.GL22848@dastard>
 <20120607215835.GB393@quack.suse.cz>
 <20120608005700.GW4347@dastard>
 <20120608213629.GA1365@quack.suse.cz>
 <20120608230616.GA25389@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120608230616.GA25389@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

On Sat 09-06-12 09:06:16, Dave Chinner wrote:
> On Fri, Jun 08, 2012 at 11:36:29PM +0200, Jan Kara wrote:
> > On Fri 08-06-12 10:57:00, Dave Chinner wrote:
> > > On Thu, Jun 07, 2012 at 11:58:35PM +0200, Jan Kara wrote:
> > > > On Wed 06-06-12 23:36:16, Dave Chinner wrote:
> > > > Also we could implement the common case of locking a range
> > > > containing single page by just taking page lock so we save modification of
> > > > interval tree in the common case and generally make the tree smaller (of
> > > > course, at the cost of somewhat slowing down cases where we want to lock
> > > > larger ranges).
> > > 
> > > That seems like premature optimistion to me, and all the cases I
> > > think we need to care about are locking large ranges of the tree.
> > > Let's measure what the overhead of tracking everything in a single
> > > tree is first so we can then see what needs optimising...
> >   Umm, I agree that initially we probably want just to have the mapping
> > range lock ability, stick it somewhere to IO path and make things work.
> > Then we can look into making it faster / merging with page lock.
> > 
> > However I disagree we care most about locking large ranges. For all
> > buffered IO and all page faults we need to lock a range containing just a
> > single page. We cannot lock more due to locking constraints with mmap_sem.
> 
> Not sure I understand what that constraint is - I hav ebeen thinking
> that the buffered IO range lok would be across the entire IO, not
> individual pages.
> 
> As it is, if we want to do multipage writes (and we do), we have to
> be able to lock a range of the mapping in the buffered IO path at a
> time...
  The problem is that buffered IO path does (e.g. in
generic_perform_write()):
  iov_iter_fault_in_readable() - that faults in one page worth of buffers,
    takes mmap_sem
  ->write_begin()
  copy data - iov_iter_copy_from_user_atomic()
  ->write_end()

  So we take mmap_sem before writing every page. We could fault in more,
but that increases risk of iov_iter_copy_from_user_atomic() failing because
the page got reclaimed before we got to it. So the amount we fault in would
have to adapt to current memory pressure. That's certainly possible but not
related to the problem we are trying to solve now so I'd prefer to handle
it separately.

> > So the places that will lock larger ranges are: direct IO, truncate, punch
> > hole. Writeback actually doesn't seem to need any additional protection at
> > least as I've sketched out things so far.
> 
> AFAICT, writeback needs protection against punching holes, just like
> mmap does, because they use the same "avoid truncated pages"
> mechanism.
  If punching hole does:
lock_mapping_range()
evict all pages in a range
punch blocks
unlock_mapping_range()

  Then we shouldn't race against writeback because there are no pages in
the mapping range we punch and they cannot be created there because we
hold the lock. I agree this might be unnecessary optimization, but the nice
result is that we can clean dirty pages regardless of what others do with
the mapping. So in case there would be problems with taking mapping lock from
writeback, we could avoid that.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
