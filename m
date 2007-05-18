Date: Fri, 18 May 2007 04:16:07 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [RFC] log out-of-virtual-memory events
Message-ID: <20070518091606.GA1010@lnx-holt.americas.sgi.com>
References: <464C81B5.8070101@users.sourceforge.net> <464C9D82.60105@redhat.com> <464D5AA4.8080900@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <464D5AA4.8080900@users.sourceforge.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Righi <righiandr@users.sourceforge.net>
Cc: Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 18, 2007 at 09:50:03AM +0200, Andrea Righi wrote:
> Rik van Riel wrote:
> > Andrea Righi wrote:
> >> I'm looking for a way to keep track of the processes that fail to
> >> allocate new
> >> virtual memory. What do you think about the following approach
> >> (untested)?
> >
> > Looks like an easy way for users to spam syslogd over and
> > over and over again.
> >
> > At the very least, shouldn't this be dependant on print_fatal_signals?
> >
> 
> Anyway, with print-fatal-signals enabled a user could spam syslogd too, simply
> with a (char *)0 = 0 program, but we could always identify the spam attempts
> logging the process uid...
> 
> In any case, I agree, it should depend on that patch...
> 
> What about adding a simple msleep_interruptible(SOME_MSECS) at the end of
> log_vm_enomem() or, at least, a might_sleep() to limit the potential spam/second
> rate?

An msleep will slow down this process, but do nothing about slowing
down the amount of logging.  Simply fork a few more processes and all
you are doing with msleep is polluting the pid space.

What about a throttling similar to what ia64 does for floating point
assist faults (handle_fpu_swa()).  There is a thread flag to not log
the events at all.  It is rate throttled globally, but uses per cpu
variables for early exits.  This algorithm scaled well to a thousand
cpus.

I think this may be a good fit.

Good Luck,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
