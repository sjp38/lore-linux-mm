Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 773716B0002
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 11:19:55 -0400 (EDT)
Date: Fri, 12 Apr 2013 11:19:52 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: Excessive stall times on ext4 in 3.9-rc2
Message-ID: <20130412151952.GA4944@thunk.org>
References: <20130402142717.GH32241@suse.de>
 <20130402150651.GB31577@thunk.org>
 <20130410105608.GC1910@suse.de>
 <20130410131245.GC4862@thunk.org>
 <20130411170402.GB11656@suse.de>
 <20130411183512.GA12298@thunk.org>
 <20130411213335.GE9379@quack.suse.cz>
 <20130412025708.GB7445@thunk.org>
 <20130412045042.GA30622@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130412045042.GA30622@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>

On Fri, Apr 12, 2013 at 02:50:42PM +1000, Dave Chinner wrote:
> > If that is the case, one possible solution that comes to mind would be
> > to mark buffer_heads that contain metadata with a flag, so that the
> > flusher thread can write them back at the same priority as reads.
> 
> Ext4 is already using REQ_META for this purpose.

We're using REQ_META | REQ_PRIO for reads, not writes.

> I'm surprised that no-one has suggested "change the IO elevator"
> yet.....

Well, testing to see if the stalls go away with the noop schedule is a
good thing to try just to validate the theory.

The thing is, we do want to make ext4 work well with cfq, and
prioritizing non-readahead read requests ahead of data writeback does
make sense.  The issue is with is that metadata writes going through
the block device could in some cases effectively cause a priority
inversion when what had previously been an asynchronous writeback
starts blocking a foreground, user-visible process.

At least, that's the theory; we should confirm that this is indeed
what is causing the data stalls which Mel is reporting on HDD's before
we start figuring out how to fix this problem.

   	 	      	     	 - Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
