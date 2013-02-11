Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 5B9476B0002
	for <linux-mm@kvack.org>; Mon, 11 Feb 2013 07:58:32 -0500 (EST)
Date: Mon, 11 Feb 2013 13:58:29 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/6] lib: Implement range locks
Message-ID: <20130211125829.GD5318@quack.suse.cz>
References: <1359668994-13433-1-git-send-email-jack@suse.cz>
 <1359668994-13433-2-git-send-email-jack@suse.cz>
 <CANN689ExHJjXvAdYM=eYP_hZFT78SHZb1AbJv6743Q=KjohBVQ@mail.gmail.com>
 <20130211102730.GA5318@quack.suse.cz>
 <CANN689G8f2QuROecapFcbcNUggGWv9bTuHSV+k4KBLj=_E7uFg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANN689G8f2QuROecapFcbcNUggGWv9bTuHSV+k4KBLj=_E7uFg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Mon 11-02-13 03:03:30, Michel Lespinasse wrote:
> On Mon, Feb 11, 2013 at 2:27 AM, Jan Kara <jack@suse.cz> wrote:
> > On Sun 10-02-13 21:42:32, Michel Lespinasse wrote:
> >> On Thu, Jan 31, 2013 at 1:49 PM, Jan Kara <jack@suse.cz> wrote:
> >> > +void range_lock_init(struct range_lock *lock, unsigned long start,
> >> > +                    unsigned long end);
> >> > +void range_lock(struct range_lock_tree *tree, struct range_lock *lock);
> >> > +void range_unlock(struct range_lock_tree *tree, struct range_lock *lock);
> >>
> >> Is there a point to separating the init and lock stages ? maybe the API could be
> >> void range_lock(struct range_lock_tree *tree, struct range_lock *lock,
> >> unsigned long start, unsigned long last);
> >> void range_unlock(struct range_lock_tree *tree, struct range_lock *lock);
> >   I was thinking about this as well. Currently I don't have a place which
> > would make it beneficial to separate _init and _lock but I can imagine such
> > uses (where you don't want to pass the interval information down the stack
> > and it's easier to pass the whole lock structure). Also it looks a bit
> > confusing to pass (tree, lock, start, last) to the locking functon. So I
> > left it there.
> >
> > OTOH I had to somewhat change the API so that the locking phase is now
> > separated in "lock_prep" phase which inserts the node into the tree and
> > counts blocking ranges and "wait" phase which waits for the blocking ranges
> > to unlock. The reason for this split is that while "lock_prep" needs to
> > happen under some lock synchronizing operations on the tree, "wait" phase
> > can be easily lockless. So this allows me to remove the knowledge of how
> > operations on the tree are synchronized from range locking code itself.
> > That further allowed me to use mapping->tree_lock for synchronization and
> > basically reduce the cost of mapping range locking close to 0 for buffered
> > IO (just a single tree lookup in the tree in the fast path).
> 
> Ah yes, being able to externalize the lock is good.
> 
> I think in this case, it makes the most sense for lock_prep phase to
> also initialize the lock node, though.
  I guess so.

> >> Reviewed-by: Michel Lespinasse <walken@google.com>
> >   I actually didn't add this because there are some differences in the
> > current version...
> 
> Did I miss another posting of yours, or is that coming up ?
  That will come. But as Dave Chinner pointed out for buffered writes we
should rather lock the whole range specified in the syscall (to avoid
strange results of racing truncate / write when i_mutex isn't used) and
that requires us to put the range lock above mmap_sem which isn't currently
easily possible due to page fault handling... So if the whole patch set
should go anywhere I need to solve that somehow.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
