From: Con Kolivas <kernel@kolivas.org>
Subject: Re: 2.6.0-test1-mm1
Date: Wed, 16 Jul 2003 19:15:29 +1000
References: <20030715225608.0d3bff77.akpm@osdl.org> <6uwueidhdd.fsf@zork.zork.net>
In-Reply-To: <6uwueidhdd.fsf@zork.zork.net>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200307161915.29497.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Sean Neakums <sneakums@zork.net>, Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Wed, 16 Jul 2003 18:07, Sean Neakums wrote:
> Andrew Morton <akpm@osdl.org> writes:
> > . Another interactivity patch from Con.  Feedback is needed on this
> >   please - we cannot make much progress on this fairly subjective work
> >   without lots of people telling us how it is working for them.
>
> This patch seems to mostly cure an oddity I've been seeing since
> 2.5.7x, or maybe very late 2.5.6x (I forget exactly when) where
> running 'ps aux' or 'ls -l' in an xterm (and only xterm it seems; I've
> tried rxvt and aterm) would more often than not result in a wallclock
> run time of up to two seconds, instead of the usual tenth of a second
> or so, with system and user time remaining constant.  If I keep
> running 'ps aux' its output does start to become slow again, snapping
> back to full speed after a few more runs.  Kind of an odd one.

In fact I've seen a number of apps display this problem. Basically how I 
understood it was the child was spawned with a lower dynamic priority (50% of 
the bonus of the parent with the child penalty at 50%). The parent then was 
spinning madly waiting for the child but in the process it was continually 
preempting the child. Eventually the parent was seen as a cpu hog, it's 
dynamic priority dropped and the child finally got to run along side it. The 
next time you ran the same parent/child combination the problem had gone 
because the parent was at a lower dynamic priority. Changing child penalty 
back up to 95% cures this problem (but can bring other problems with it 
unless workarounds are added). While this seems more an anomaly in the coding 
of the application brought out by the scheduler, it seems to be very common.

Con

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
