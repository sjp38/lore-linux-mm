Message-ID: <20040204183334.60551.qmail@web9701.mail.yahoo.com>
Date: Wed, 4 Feb 2004 10:33:34 -0800 (PST)
From: Alok Mooley <rangdi@yahoo.com>
Subject: Re: Active Memory Defragmentation: Our implementation & problems
In-Reply-To: <1075874074.14153.159.camel@nighthawk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: mbligh@aracnet.com, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--- Dave Hansen <haveblue@us.ibm.com> wrote:
> On Tue, 2004-02-03 at 21:09, Alok Mooley wrote:

> Instead of a daemon
> > kicking in on a threshold  violation (as proposed
> by Mr. Daniel
> > Phillips), we intend to capture idle cpu cycles by
> inserting a new
> > process just above the idle process.  

> 
> I think I'd agree with Dan on that one.  When kswapd
> is going, it's
> pretty much too late.  The daemon approach would be
> more flexible, allow
> you to start earlier, and more easily have various
> levels of
> aggressiveness.
>

The flexibility & the various levels of aggressiveness
are fine, but won't the daemon be running when some
other process could well have been?
In this case, won't a process just above the idle
process be a better proposition, since we know that
the cpu is now truly idle? This may be at the cost of
not having control over when this process is
scheduled,if ever.

> > Now, when we are scheduled, we are sure that the
> cpu is idle, & this
> > is when we check for threshold violation &
> defragment.  One problem
> > with this would be when to reschedule ourselves
> (allow our
> > preemption)?  We do not want the memory state to
> change beneath us,
> > so right now we are not allowing our preemption.
> 
> It's a real luxury if the state doesn't change
> underneath you.  It's
> usually worthwhile to try and do it without locking
> too many things
> down.  Take the page cache, for instance.  It does a
> lot of its work
> without locks, and has all of the error handling
> necessary when thing
> collide during a duplicate addition or go away from
> underneath you. 
> It's a good example of some really capable code that
> doesn't require a
> static state to work properly.

If we do allow our preemption (before our work is well
& truly finished), even a simple page-fault will wreak
havoc, since it may change the memory state & we have
to do the same work (gathering the new memory state)
all over again. This becomes all the more significant
considering that 2.6.0 is a preemptible kernel.
Considering this, should we allow our preemption? If
not, won't this hog the cpu? Is there any way out?

-Alok 


__________________________________
Do you Yahoo!?
Yahoo! SiteBuilder - Free web site building tool. Try it!
http://webhosting.yahoo.com/ps/sb/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
