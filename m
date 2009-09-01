Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A9B646B004F
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 14:01:11 -0400 (EDT)
Date: Tue, 1 Sep 2009 14:00:52 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [PATCH, RFC] vm: Add an tuning knob for vm.max_writeback_pages
Message-ID: <20090901180052.GA7885@think>
References: <1251600858-21294-1-git-send-email-tytso@mit.edu>
 <20090830165229.GA5189@infradead.org>
 <20090830181731.GA20822@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090830181731.GA20822@mit.edu>
Sender: owner-linux-mm@kvack.org
To: Theodore Tso <tytso@mit.edu>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Ext4 Developers List <linux-ext4@vger.kernel.org>, linux-fsdevel@vger.kernel.org, jens.axboe@oracle.com
List-ID: <linux-mm.kvack.org>

On Sun, Aug 30, 2009 at 02:17:31PM -0400, Theodore Tso wrote:
[ ... ]

> Jens?  What do you think?  Fixing MAX_WRITEBACK_PAGES was something I
> really wanted to merge in 2.6.32 since it makes a huge difference for
> the block allocation layout for a "rsync -avH /old-fs /new-fs" when we
> are copying bunch of large files (say, 800 meg iso images) and so the
> fact that the writeback routine is writing out 4 megs at a time, means
> that our files get horribly interleaved and thus get fragmented.

I did some runs comparing mainline with Jens' current writeback queue.
This is just btrfs, but its a good example of how things are improving.

These graphs show us the 'compile' phase of compilebench, where it is
writing all the .o files into the 30 kernel trees.  Basically we have
one thread, creating a bunch of files based on the sizes of all the .o
files in a compiled kernel.  They are created in random order, similar
to the files produced from a make -j.

I haven't yet tried this without the max_writeback_pages patch, but the
graphs clearly show a speed improvement, and that the mainline code is
smearing writes across the drive while Jens' work is writing
sequentially.

Jens' writeback branch:
http://oss.oracle.com/~mason/seekwatcher/compilebench-writes-axboe.png

Mainline
http://oss.oracle.com/~mason/seekwatcher/compilebench-writes-pdflush.png

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
