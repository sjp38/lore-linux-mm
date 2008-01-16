Message-ID: <400452490.28636@ustc.edu.cn>
Date: Wed, 16 Jan 2008 11:01:08 +0800
From: Fengguang Wu <wfg@mail.ustc.edu.cn>
Subject: Re: [patch] Converting writeback linked lists to a tree based data structure
References: <20080115080921.70E3810653@localhost> <1200386774.15103.20.camel@twins> <532480950801150953g5a25f041ge1ad4eeb1b9bc04b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <532480950801150953g5a25f041ge1ad4eeb1b9bc04b@mail.gmail.com>
Message-Id: <E1JEyWa-0001Ys-F9@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Michael Rubin <mrubin@google.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 15, 2008 at 09:53:42AM -0800, Michael Rubin wrote:
> On Jan 15, 2008 12:46 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > Just a quick question, how does this interact/depend-uppon etc.. with
> > Fengguangs patches I still have in my mailbox? (Those from Dec 28th)
> 
> They don't. They apply to a 2.6.24rc7 tree. This is a candidte for 2.6.25.
> 
> This work was done before Fengguang's patches. I am trying to test
> Fengguang's for comparison but am having problems with getting mm1 to
> boot on my systems.

Yeah, they are independent ones. The initial motivation is to fix the
bug "sluggish writeback on small+large files". Michael introduced
a new rbtree, and me introduced a new list(s_more_io_wait).

Basically I think rbtree is an overkill to do time based ordering.
Sorry, Michael. But s_dirty would be enough for that. Plus, s_more_io
provides fair queuing between small/large files, and s_more_io_wait
provides waiting mechanism for blocked inodes.

The time ordered rbtree may delay io for a blocked inode simply by
modifying its dirtied_when and reinsert it. But it would no longer be
that easy if it is to be ordered by location.

If we are going to do location based ordering in the future, the lists
will continue to be useful. It would simply be a matter of switching
from the s_dirty(order by time) to some rbtree or radix tree(order by
location).

We can even provide both ordering at the same time to different
fs/inodes which is configurable by the user. Because the s_dirty
and/or rbtree would provide _only_ ordering(not faireness or waiting)
and hence is interchangeable.

This patchset could be a good reference. It does location based
ordering with radix tree:

[RFC][PATCH] clustered writeback <http://lkml.org/lkml/2007/8/27/45>

Thank you,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
