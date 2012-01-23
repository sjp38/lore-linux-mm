Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 816BA6B004D
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 07:34:04 -0500 (EST)
Date: Mon, 23 Jan 2012 13:33:39 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [LSF/MM TOPIC] [ATTEND] Future writeback topics
Message-ID: <20120123123339.GC1707@cmpxchg.org>
References: <4F1C141C.2050704@panasas.com>
 <1327246034.2834.7.camel@dabdike.int.hansenpartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1327246034.2834.7.camel@dabdike.int.hansenpartnership.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>, lsf-pc@lists.linux-foundation.org, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org

On Sun, Jan 22, 2012 at 09:27:14AM -0600, James Bottomley wrote:
> Since a lot of these are mm related; added linux-mm to cc list
> 
> On Sun, 2012-01-22 at 15:50 +0200, Boaz Harrosh wrote:
> > [Targeted writeback (IO-less page-reclaim)]
> >   Sometimes we would need to write a certain page or group of pages. It could be
> >   nice to prioritize/start the writeback on these pages, through the regular writeback
> >   mechanism instead of doing direct IO like today.
> > 
> >   This is actually related to above where we can have a "write_now" time constant that
> >   makes the priority of that inode to be written first. Then we also need the page-info
> >   that we want to write as part of that inode's IO. Usually today we start at the lowest
> >   indexed page of the inode, right? In targeted writeback we should make sure the writeout
> >   is the longest contiguous (aligned) dirty region containing the targeted page.
> > 
> >   With this in place we can also move to an IO-less page-reclaim. that is done entirely by
> >   the BDI thread writeback. (Need I say more)
>
> All of the above are complex.  The only reason for adding complexity in
> our writeback path should be because we can demonstrate that it's
> actually needed.  In order to demonstrate this, you'd need performance
> measurements ... is there a plan to get these before the summit?

The situations that required writeback for reclaim to make progress
have shrunk a lot with this merge window because of respecting page
reserves in the dirty limits, and per-zone dirty limits.

What's left to evaluate are certain NUMA configurations where the
dirty pages are concentrated on a few nodes.  Currently, we kick the
flushers from direct reclaim, completely undirected, just "clean some
pages, please".  That works for systems up to a certain size,
depending on the size of the node in relationship to the system as a
whole (likelihood of pages cleaned being from the target node) and how
fast the backing storage is (impact of cleaning 'wrong' pages).

So while the original problem is still standing, the urgency of it
might have been reduced quite a bit or the problem itself might have
been pushed into a corner where workarounds (spread dirty data more
evenly e.g.) might be more economical than trying to make writeback
node-aware and deal with all the implications (still have to guarantee
dirty cache expiration times for integrity; can fail spectacularly
when there is little or no relationship between disk placement and
memory placement, imagine round-robin allocation of disk-contiguous
dirty cache over a few nodes).

I agree with James: find scenarios where workarounds are not feasible
but that are important enough that the complexity would be justified.
Otherwise, talking about how to fix them is moot.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
