Date: Sun, 15 Oct 2006 16:19:53 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: SPAM: Re: [patch 6/6] mm: fix pagecache write deadlocks
Message-ID: <20061015141953.GC25243@wotan.suse.de>
References: <20061013143516.15438.8802.sendpatchset@linux.site> <20061013143616.15438.77140.sendpatchset@linux.site> <1160912230.5230.23.camel@lappy> <20061015115656.GA25243@wotan.suse.de> <1160920269.5230.29.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1160920269.5230.29.camel@lappy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linux Memory Management <linux-mm@kvack.org>, Neil Brown <neilb@suse.de>, Anton Altaparmakov <aia21@cam.ac.uk>, Chris Mason <chris.mason@oracle.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Sun, Oct 15, 2006 at 03:51:09PM +0200, Peter Zijlstra wrote:
> 
> > > 
> > > Why use raw {inc,dec}_preempt_count() and not
> > > preempt_{disable,enable}()? Is the compiler barrier not needed here? And
> > > do we really want to avoid the preempt_check_resched()?
> > 
> > Counter to intuition, we actually don't mind being preempted here,
> > but we do mind entering the (core) pagefault handler. Incrementing
> > the preempt count causes the arch specific handler to bail out early
> > before it takes any locks.
> > 
> > Clear as mud? Wrapping it in a better name might be an improvement?
> > Or wrapping it into the copy*user_atomic functions themselves (which
> > is AFAIK the only place we use it).
> 
> Right, but since you do inc the preempt_count you do disable preemption,
> might as well check TIF_NEED_RESCHED when enabling preemption again.

Yeah, you are right about that. Unfortunately there isn't a good
way to do this at the moment... well we could disable preempt
around the section, but that would be silly for a PREEMPT kernel.

And we should really decouple it from preempt entirely, in case we
ever want to check for it some other way in the pagefault handler.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
