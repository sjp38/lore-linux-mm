Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6FA4E6B0082
	for <linux-mm@kvack.org>; Sun, 30 Aug 2009 14:17:29 -0400 (EDT)
Date: Sun, 30 Aug 2009 14:17:31 -0400
From: Theodore Tso <tytso@mit.edu>
Subject: Re: [PATCH, RFC] vm: Add an tuning knob for vm.max_writeback_pages
Message-ID: <20090830181731.GA20822@mit.edu>
References: <1251600858-21294-1-git-send-email-tytso@mit.edu> <20090830165229.GA5189@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090830165229.GA5189@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-mm@kvack.org, Ext4 Developers List <linux-ext4@vger.kernel.org>, linux-fsdevel@vger.kernel.org, chris.mason@oracle.com, jens.axboe@oracle.com
List-ID: <linux-mm.kvack.org>

On Sun, Aug 30, 2009 at 12:52:29PM -0400, Christoph Hellwig wrote:
> On Sat, Aug 29, 2009 at 10:54:18PM -0400, Theodore Ts'o wrote:
> > MAX_WRITEBACK_PAGES was hard-coded to 1024 because of a concern of not
> > holding I_SYNC for too long.  But this shouldn't be a concern since
> > I_LOCK and I_SYNC have been separated.  So make it be a tunable and
> > change the default to be 32768.
> > 
> > This change is helpful for ext4 since it means we write out large file
> > in bigger chunks than just 4 megabytes at a time, so that when we have
> > multiple large files in the page cache waiting for writeback, the
> > files don't end up getting interleaved.  There shouldn't be any downside.
> > 
> > http://bugzilla.kernel.org/show_bug.cgi?id=13930
> 
> The current writeback sizes are defintively too small, we shoved in
> a hack into XFS to bump up nr_to_write to four times the value the
> VM sends us to be able to saturate medium sized RAID arrays in XFS.

Hmm, should we make it be a per-superblock tunable so that it can
either be tuned on a per-block device basis or the filesystem code can
adjust it to their liking?  I thought about it, but decided maybe it
was better to keeping it simple.

> Turns out this was not enough and at least for Chris Masons array
> we only started seaturating at * 16.  I suspect you patch will give
> a similar effect.

So you think 16384 would be a better default?  The reason why I picked
32768 was because that was the size of the ext4 block group, but it
was otherwise it was totally arbitrary.  I haven't done any
benchmarking yet, which is one of the reasons why I thought about
making it a tunable.

> And btw, I think referring to the historic code in the comment is not
> a good idea, it's just going to ocnfuse the heck out of everyone looking
> at it in the future.  The information above makes sense for the commit
> message.

Yeah, good point.

> And the other big question is how this interacts with Jens' new per-bdi
> flushing code that we still hope to merge in 2.6.32.

Jens?  What do you think?  Fixing MAX_WRITEBACK_PAGES was something I
really wanted to merge in 2.6.32 since it makes a huge difference for
the block allocation layout for a "rsync -avH /old-fs /new-fs" when we
are copying bunch of large files (say, 800 meg iso images) and so the
fact that the writeback routine is writing out 4 megs at a time, means
that our files get horribly interleaved and thus get fragmented.

I initially thought about adding some massive workarounds in the
filesystem layer (which is I guess what XFS did), but I ultimately
decided this was begging to be solved in the page writeback code,
especially since it's *such* an easy fix.

> Maybe we'll actually get some sane writeback code for the first time.

To quote from "Fiddler on the Roof", from your lips to God's ears....

:-)

   	      	       	      	     	  - Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
