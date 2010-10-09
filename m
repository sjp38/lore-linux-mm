Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 4EA636B006A
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 23:16:22 -0400 (EDT)
Date: Sat, 9 Oct 2010 14:16:09 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Results of my VFS scaling evaluation.
Message-ID: <20101009031609.GK4681@dastard>
References: <1286580739.3153.57.camel@bobble.smo.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1286580739.3153.57.camel@bobble.smo.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: Frank Mayhar <fmayhar@google.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, mrubin@google.com
List-ID: <linux-mm.kvack.org>

On Fri, Oct 08, 2010 at 04:32:19PM -0700, Frank Mayhar wrote:
> Nick Piggin has been doing work on lock contention in VFS, in particular
> to remove the dcache and inode locks, and we are very interested in this
> work.  He has entirely eliminated two of the most contended locks,
> replacing them with a combination of more granular locking, seqlocks,
> RCU lists and other mechanisms that reduce locking and contention in
> general. He has published this work at
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/npiggin/linux-npiggin.git

While the code in that tree might be stable, it's not really in any
shape acceptible for mainline inclusion.

I've been reworking the inode_lock breakup code from this patch set,
and there is significant change in the locking order and structure
compared to the above tree to avoid the unmaintainable mess of
trylock operations that Nick's patchset ended up with.

Also, breaking the series down into smaller bunches also shows that
certain optimisations made later in the series (e.g. making
writeback lists per CPU, breaking up inode LRUs, etc) do not deal
with the primary causes of observable contention (e.g. unbound
writeback parallelism in balance_dirty_pages), so the parts of the
original patch set might not even end up in mainline for some time...

FWIW, it would be good if this sort of testing could be run on the tree
under review here:

git://git.kernel.org/pub/scm/linux/kernel/git/dgc/xfsdev.git inode-scale

This is what I'm trying to get reviewed in time for a .37 merge.  If
that gets in .37, then I'll probably follow the same process for the
dcache_lock in .38, and after that we can then consider all the RCU
changes for both the inode and dentry operations.

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
