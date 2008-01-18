Message-ID: <400632190.14601@ustc.edu.cn>
Date: Fri, 18 Jan 2008 12:56:09 +0800
From: Fengguang Wu <wfg@mail.ustc.edu.cn>
Subject: Re: [patch] Converting writeback linked lists to a tree based data structure
References: <20080115080921.70E3810653@localhost> <400562938.07583@ustc.edu.cn> <532480950801171307q4b540ewa3acb6bfbea5dbc8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <532480950801171307q4b540ewa3acb6bfbea5dbc8@mail.gmail.com>
Message-Id: <E1JFjGz-0001eU-3O@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Michael Rubin <mrubin@google.com>
Cc: a.p.zijlstra@chello.nl, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 17, 2008 at 01:07:05PM -0800, Michael Rubin wrote:
> On Jan 17, 2008 1:41 AM, Fengguang Wu <wfg@mail.ustc.edu.cn> wrote:
> > On Tue, Jan 15, 2008 at 12:09:21AM -0800, Michael Rubin wrote:
> > The main benefit of rbtree is possibly better support of future policies.
> > Can you demonstrate an example?
> 
> These are ill-formed thoughts as of now on my end but the idea was
> that keeping one tree sorted via a scheme might be simpler than
> multiple list_heads.

Suppose we want to grant longer expiration window for temp files,
adding a new list named s_dirty_tmpfile would be a handy solution.

So the question is: should we need more than 3 QoS classes?

> > The most tricky writeback issues could be starvation prevention
> > between
> 
> 
> >         - small/large files
> >         - new/old files
> >         - superblocks
> 
> So I have written tests and believe I have covered these issues. If
> you are concerned in specific on any and have a test case please let
> me know.

OK.

> > Some kind of limit should be applied for each. They used to be:
> >         - requeue to s_more_io whenever MAX_WRITEBACK_PAGES is reached
> >           this preempts big files
> 
> The patch uses th same limit.
> 
> >         - refill s_io iif it is drained
> >           this prevents promotion of big/old files
> 
> Once a big file gets its first do_writepages it is moved behind the
> other smaller files via i_flushed_when. And the same in reverse for
> big vs old.

You mean i_flush_gen? No, sync_sb_inodes() will abort on every
MAX_WRITEBACK_PAGES, and s_flush_gen will be updated accordingly.
Hence the sync will restart from big/old files.

> 
> >         - return from sync_sb_inodes() after one go of s_io
> 
> I am not sure how this limit helps things out. Is this for superblock
> starvation? Can you elaborate?

We should have a way to go to next superblock even if new dirty inodes
or pages are emerging fast in this superblock. Fill and drain s_io
only once and then abort helps.

s_io is a stable and bounded working set in one go of superblock.

> > Michael, could you sort out and document the new starvation prevention schemes?
> 
> The basic idea behind the writeback algorithm to handle starvation.
> The over arching idea is that we want to preserve order of writeback
> based on when an inode was dirtied and also preserve the dirtied_when
> contents until the inode has been written back (partially or fully)
> 
> Every sync_sb_inodes we find the least recent inodes dirtied. To deal
> with large or small starvation we have a s_flush_gen for each
> iteration of sync_sb_inodes every time we issue a writeback we mark
> that the inode cannot be processed until the next s_flush_gen. This
> way we don't process one get to the rest since we keep pushing them
> into subsequent s_fush_gen's.
> 
> Let me know if you want more detail or structured responses.
> 
> > Introduce i_flush_gen to help restarting from the last inode?
> > Well, it's not as simple as list_heads.

Basically you make one list_head in each rbtree node.
That list_head is recycled cyclic, and is an analog to the old
fashioned s_dirty. We need to know 'where we are' and 'where it ends'.
So an extra indicator must be introduced - i_flush_gen. It's awkward.

We are simply repeating the aged list_heads' problem.

> > > 2) Added an inode flag to allow inodes to be marked so that they
> > >    are never written back to disk.
> > >
> > >    The motivation behind this change is several fold. The first is
> > >    to insure fairness in the writeback algorithm. The second is to
> >
> > What do you mean by fairness?
> 
> So originally this comment was written when I was trying to fix a bug
> in 2.6.23. The one where we were starving large files from being
> flushed. There was a fairness issue where small files were being
> flushed but the large ones were just ballooning in memory.

In fact the bug is turned-around rather than fixed - now the small
files could be starved.

> > Why cannot I_WRITEBACK_NEVER be in a decoupled standalone patch?
> 
> The WRITEBACK_NEVER could be in a previous patch to the rbtree. But
> not a subsequent patch to the rbtree. The rbtree depends on the
> WRITEBACK_NEVER patch otherwise we run in to problems in
> generic_delete_inode. Now that you point it out I think I can split
> this patch into two patches and make the WRITEBACK_NEVER in the first
> one.

OK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
