Date: Thu, 29 Jul 2004 16:21:47 -0500
From: Brent Casavant <bcasavan@sgi.com>
Reply-To: Brent Casavant <bcasavan@sgi.com>
Subject: Re: Scaling problem with shmem_sb_info->stat_lock
In-Reply-To: <Pine.LNX.4.44.0407292006290.1096-100000@localhost.localdomain>
Message-ID: <Pine.SGI.4.58.0407291614150.35081@kzerza.americas.sgi.com>
References: <Pine.LNX.4.44.0407292006290.1096-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 29 Jul 2004, Hugh Dickins wrote:

> Jack Steiner's question was, why is this an issue on 2.6 when it
> wasn't on 2.4?  Perhaps better parallelism elsewhere in 2.6 has
> shifted contention to here?  Or was it an issue in 2.4 after all?

It was, but for some reason it didn't show up with this particular
test code.

> Why are all these threads allocating to the inode at the same time?
>
> Are they all trying to lock down the same pages?  Or is each trying
> to fault in a different page (as your "parallel" above suggests)?

They're all trying to fault in a different page.

> Why doesn't the creator of the shm segment or /dev/zero mapping just
> fault in all the pages before handing over to the other threads?

Performance.  The mapping could well range into the tens or hundreds
of gigabytes, and faulting these pages in parallel would certainly
be advantageous.

> But I may well have entirely the wrong model of what's going on.
> Could you provide a small .c testcase to show what it's actually
> trying to do when the problem manifests?  I don't have many cpus
> to reproduce it on, but it should help to provoke a solution.

Sure.  I'll forward it seperately.  I'll actually send you the
very program I've been using to test this work.  Jack Steiner
wrote it, so there shouldn't be any issue sharing it.

> (Once we've shifted the contention from info->lock to mapping->tree_lock,
> it'll be interesting but not conclusive to hear how 2.6.8 compares with
> 2.6.8-mm: since mm is currently using read/write_lock_irq on tree_lock.)

Therein lies the rub, right?  We solve one contention problem, only to
move it elsewhere. :)

Brent

-- 
Brent Casavant             bcasavan@sgi.com        Forget bright-eyed and
Operating System Engineer  http://www.sgi.com/     bushy-tailed; I'm red-
Silicon Graphics, Inc.     44.8562N 93.1355W 860F  eyed and bushy-haired.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
