Date: Mon, 12 Jul 2004 16:11:29 -0500
From: Brent Casavant <bcasavan@sgi.com>
Reply-To: Brent Casavant <bcasavan@sgi.com>
Subject: Scaling problem with shmem_sb_info->stat_lock
Message-ID: <Pine.SGI.4.58.0407121546460.111008@kzerza.americas.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: hugh@veritas.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh,

Christoph Hellwig recommended I email you about this issue.

In the Linux kernel, in both 2.4 and 2.6, in the mm/shmem.c code, there
is a stat_lock in the shmem_sb_info structure which protects (among other
things) the free_blocks field and (under 2.6) the inode i_blocks field.

At SGI we've found that on larger systems (>32P) undergoing parallel
/dev/zero page faulting, as often happens during parallel application
startup, this locking does not scale very well due to the lock cacheline
bouncing between CPUs.

Back in 2.4 Jack Steiner hacked on this code to avoid taking the lock
when free_blocks was equal to ULONG_MAX, as it makes little sense to
perform bookkeeping operations when there were no practical limits
being requested.  This (along with scaling fixes in other parts of the
VM system) provided for very good scaling of /dev/zero page faulting.
However, this could lead to problems in the shmem_set_size() function
during a remount operation; but as that operation is apparently fairly
rare on running systems, it solved the scaling problem in practice.

I've hacked up the 2.6 shmem.c code to not require the stat_lock to
be taken while accessing these two fields (free_blocks and i_blocks),
but unfortunately this does nothing more than change which cacheline
is bouncing around the system (the fields themselves, instead of
the lock).  This of course was not unexpected.

Looking at this code, I don't see any straightforward way to alleviate
this problem.  So, I was wondering if you might have any ideas how one
might approach this.  I'm hoping for something that will give us good
scaling all the way up to 512P.

Thanks,
Brent Casavant

-- 
Brent Casavant             bcasavan@sgi.com        Forget bright-eyed and
Operating System Engineer  http://www.sgi.com/     bushy-tailed; I'm red-
Silicon Graphics, Inc.     44.8562N 93.1355W 860F  eyed and bushy-haired.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
