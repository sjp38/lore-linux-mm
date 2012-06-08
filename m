Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 53D1E6B006C
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 19:06:21 -0400 (EDT)
Date: Sat, 9 Jun 2012 09:06:16 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Hole punching and mmap races
Message-ID: <20120608230616.GA25389@dastard>
References: <20120519014024.GZ25351@dastard>
 <20120524123538.GA5632@quack.suse.cz>
 <20120605055150.GF4347@dastard>
 <20120605231530.GB4402@quack.suse.cz>
 <20120606000636.GG22848@dastard>
 <20120606095827.GA6304@quack.suse.cz>
 <20120606133616.GL22848@dastard>
 <20120607215835.GB393@quack.suse.cz>
 <20120608005700.GW4347@dastard>
 <20120608213629.GA1365@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120608213629.GA1365@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

On Fri, Jun 08, 2012 at 11:36:29PM +0200, Jan Kara wrote:
> On Fri 08-06-12 10:57:00, Dave Chinner wrote:
> > On Thu, Jun 07, 2012 at 11:58:35PM +0200, Jan Kara wrote:
> > > On Wed 06-06-12 23:36:16, Dave Chinner wrote:
> > > Also we could implement the common case of locking a range
> > > containing single page by just taking page lock so we save modification of
> > > interval tree in the common case and generally make the tree smaller (of
> > > course, at the cost of somewhat slowing down cases where we want to lock
> > > larger ranges).
> > 
> > That seems like premature optimistion to me, and all the cases I
> > think we need to care about are locking large ranges of the tree.
> > Let's measure what the overhead of tracking everything in a single
> > tree is first so we can then see what needs optimising...
>   Umm, I agree that initially we probably want just to have the mapping
> range lock ability, stick it somewhere to IO path and make things work.
> Then we can look into making it faster / merging with page lock.
> 
> However I disagree we care most about locking large ranges. For all
> buffered IO and all page faults we need to lock a range containing just a
> single page. We cannot lock more due to locking constraints with mmap_sem.

Not sure I understand what that constraint is - I hav ebeen thinking
that the buffered IO range lok would be across the entire IO, not
individual pages.

As it is, if we want to do multipage writes (and we do), we have to
be able to lock a range of the mapping in the buffered IO path at a
time...

> So the places that will lock larger ranges are: direct IO, truncate, punch
> hole. Writeback actually doesn't seem to need any additional protection at
> least as I've sketched out things so far.

AFAICT, writeback needs protection against punching holes, just like
mmap does, because they use the same "avoid truncated pages"
mechanism.

> So single-page ranges matter at least as much as longer ranges. That's why
> I came up with that page lock optimisation and merging...

I agree they are common, but lets measure the overhead first before
trying to optimise/special case certain behaviours....

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
