Received: from post.mail.demon.net (post-20.mail.demon.net [194.217.242.27])
	by kvack.org (8.8.7/8.8.7) with SMTP id RAA07734
	for <linux-mm@kvack.org>; Thu, 4 Dec 1997 17:27:12 -0500
Date: Thu, 4 Dec 1997 10:02:44 +0000 (GMT)
From: Mark Hemment <markhe@nextd.demon.co.uk>
Reply-To: Mark Hemment <markhe@nextd.demon.co.uk>
Subject: Re: 2.0.30: Lockups with huge proceses mallocing all VM
In-Reply-To: <vxkiut6fiku.fsf@pocari-sweat.jprc.com>
Message-ID: <Pine.LNX.3.95.971204092943.86B-100000@nextd.demon.co.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Karl Kleinpaste <karl@jprc.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 3 Dec 1997, Karl Kleinpaste wrote:
> We can reproduce this fairly reliably.  Before anyone had looked at
> the code at all closely, some folks were surmising that perhaps Linux
> was not guaranteeing the availability of backing store for freshly-
> allocated pages, and that perhaps eventually Linux was getting stuck
> looking for a free page when none were to be found.

  Yep, Linux uses lazy swap-page allocation (some OSes use eager
allocation).  This means it can run out of pages.
  If a page allocation fails during a page fault, then the faulting task
is killed.  If an allocation fails for a "management structure" (eg.
vm_area_struct), then the system-call should fail with EAGAIN.
  Unfortunately, not all allocation failures are handled cleanly - some
work may have been done before the failure, which is not completely undone
after the allocation failure.  An example of this is munmap(), which
may partially unmap the given address range before an allocation failure
(yep, munmap() can cause allocations).  Another example is mlock() and
mprotect() - either may partially succeed.  This can confuse an
allocation, which may end up seg-faulting.

> I'm wondering whether this sort of lockup is analogous to the
> fragmentation lockups recently mentioned by Bill Hawes and others.  If
> so, could someone direct me toward Mark Hemment or others doing work
> of this sort?

I was (am) working on reducing the free-page pool fragmentation when my
page-colouring is being used.  It places a lower bound on the
fragmentation.
BTW, are you using NFS?  This requries largish orders of contigious pages
from the page allocator, and I believe this can cause NFS to stall the
machine until it gets the requried allocations - but I might be wrong
here, and/or this 'feature' may only be in 2.1.xx....

> I'm perfectly willing to wade into the kernel mem.mgmt code to figure
> out what I can about this, though it sounds like others may be way out
> in front on the issue.  In the meantime, we're working around the
> problem as best we can by imposing datasize limits (via ulimit) since
> the problem only presents itself when the machine is out of aggregate
> VM anyway -- it doesn't matter if we make this lone process die as
> long as the machine as a whole survives.

I think the bug is not in the VM sub-system, but the lack of available
pages is causing some other sub-system to lock your box.
If you have a free test target, try using the latest 2.1.x to see if the
problem is still there.

  Regards,

     markhe
