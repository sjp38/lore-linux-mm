Subject: Re: Break 2.4 VM in five easy steps
Message-ID: <OF75B67BC7.4C70DAF5-ON85256A64.004C4AD1@pok.ibm.com>
From: "Bulent Abali" <abali@us.ibm.com>
Date: Thu, 7 Jun 2001 10:22:50 -0400
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <mikeg@wen-online.de>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Derek Glidden <dglidden@illusionary.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


>> O.k.  I think I'm ready to nominate the dead swap pages for the big
>> 2.4.x VM bug award.  So we are burning cpu cycles in sys_swapoff
>> instead of being IO bound?  Just wanting to understand this the cheap
way :)
>
>There's no IO being done whatsoever (that I can see with only a blinky).
>I can fire up ktrace and find out exactly what's going on if that would
>be helpful.  Eating the dead swap pages from the active page list prior
>to swapoff cures all but a short freeze.  Eating the rest (few of those)
>might cure the rest, but I doubt it.
>
>    -Mike

1)  I second Mike's observation.  swapoff either from command line or
during
shutdown, just hangs there.  No disk I/O is being done as I could see
from the blinkers.  This is not a I/O boundness issue.  It is more like
a deadlock.

I happened to saw this one with debugger attached serial port.
The system was alive.  I think I was watching the free page count and
it was decreasing very slowly may be couple pages per second.  Bigger
the swap usage longer it takes to do swapoff.  For example, if I had
1GB in the swap space then it would take may be an half hour to shutdown...


2)  Now why I would have 1 GB in the swap space, that is another problem.
Here is what I observe and it doesn't make much sense to me.
Let's say I have 1GB of memory and plenty of swap.  And let's
say there is process with little less than 1GB size.  Suppose the system
starts swapping because it is short few megabytes of memory.
Within *seconds* of swapping, I see that the swap disk usage balloons to
nearly 1GB. Nearly entire memory moves in to the page cache.  If you
run xosview you will know what I mean.  Memory usage suddenly turns from
green to red :-).   And I know for a fact that my disk cannot do 1GB per
second :-). The SHARE column of the big process in "top" goes up by
hundreds
of megabytes.
So it appears to me that MM is marking the whole process memory to be
swapped out and probably reserving nearly 1 GB in the swap space and
furthermore moves entire process pages to apparently to the page cache.
You would think that if you are short by few MB of memory MM would put
few MB worth of pages in the swap. But it wants to move entire processes
in to swap.

When the 1GB process exits, the swap usage doesn't change (dead swap
pages?).
And shutdown or swapoff will take forever due to #1 above.

Bulent




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
