Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA01934
	for <linux-mm@kvack.org>; Wed, 3 Dec 1997 17:25:18 -0500
Date: Wed, 3 Dec 1997 23:05:44 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: H.H.vanRiel@fys.ruu.nl
Subject: Re: 2.0.30: Lockups with huge proceses mallocing all VM
In-Reply-To: <vxkiut6fiku.fsf@pocari-sweat.jprc.com>
Message-ID: <Pine.LNX.3.91.971203225838.738B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Karl Kleinpaste <karl@jprc.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 3 Dec 1997, Karl Kleinpaste wrote:

> The specific symptom is that the beast mallocs and mallocs like
> there's no tomorrow, as it analyzes documents, building word lists,
> collating similar documents, and doing some serious and arcane
> statistical work on the mess.  As it approaches occupation of the
> entire system's available VM, performance drops precipitously, though
> it remains responsive and usable with as little as 20Mbytes swap space
> remaining.  When it finally closes on that last 20 or 10 Mbytes, the
> system simply hangs.

When memory is finished and a program tries to allocate another
page, the system will swap out the program page from which the
other data page was allocated... Now you're out of memory and
the program can't be swapped in again :)
The ONLY fix for this is to allocate enough swap space for your
system (the swapd swap-on-demand daemon is an option).

Of course, we could make a kernel kludge that kills the largest
program (or some other program) so memory is freed, but killing
off your document-system to let it run won't be very effective :-)

> allocated pages, and that perhaps eventually Linux was getting stuck
> looking for a free page when none were to be found.

Yep.

> I'm wondering whether this sort of lockup is analogous to the
> fragmentation lockups recently mentioned by Bill Hawes and others.  If
> so, could someone direct me toward Mark Hemment or others doing work
> of this sort?

No, your system has just run out of memory... Maybe we should add
some code to the kernel that puts out a KERN_ALERT message saying
that free swap-space went below 10%

> I'm perfectly willing to wade into the kernel mem.mgmt code to figure
> out what I can about this, though it sounds like others may be way out
> in front on the issue.  In the meantime, we're working around the
> problem as best we can by imposing datasize limits (via ulimit) since
> the problem only presents itself when the machine is out of aggregate
> VM anyway -- it doesn't matter if we make this lone process die as
> long as the machine as a whole survives.

You mean that the program allocates memory without limit...
It just allocates, allocates, allocates and NEVER FREE()s
memory... This is just _wrong_ program design... 
OTOH, if the program really needs 1000Megs of memory, then
380 megs of ram and 400 megs of swap just aren't enough.

hope this helps,

Rik.

----------
Send Linux memory-management wishes to me: I'm currently looking
for something to hack...
