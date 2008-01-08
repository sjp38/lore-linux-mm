Date: Tue, 8 Jan 2008 08:31:34 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Subject: Re: [PATCH 11 of 11] not-wait-memdie
Message-ID: <20080108073134.GB22800@v2.random>
References: <504e981185254a12282d.1199326157@v2.random> <Pine.LNX.4.64.0801071141130.23617@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801071141130.23617@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 07, 2008 at 11:43:07AM -0800, Christoph Lameter wrote:
> On Thu, 3 Jan 2008, Andrea Arcangeli wrote:
> 
> > +		if (unlikely(test_tsk_thread_flag(p, TIF_MEMDIE))) {
> > +			/*
> > +			 * Hopefully we already waited long enough,
> > +			 * or exit_mm already run, but we must try to kill
> > +			 * another task to avoid deadlocking.
> > +			 */
> > +			continue;
> > +		}
> 
> If all tasks are marked TIF_MEMDIE then we just scan through them return 
> NULL and
> 
> 
> >  		/* Found nothing?!?! Either we hang forever, or we panic. */
> > -		if (!p) {
> > +		if (unlikely(!p)) {
> >  			read_unlock(&tasklist_lock);
> >  			panic("Out of memory and no killable processes...\n");
> 
> panic.
> 
> Should we not wait awhile before panicing? The processes may need some 
> time to terminate.

I've a new patchset that would wait 60 sec for every new set
TIF_MEMDIE before paniking. that will fix this. Thanks.

Problem is with the new patchset with the memdie_jiffies, I run into
new deadlock with my testcase so I was trying to fix those new issues
before submission. For whatever reason I could never reproduce any
problem with the patchset I sent to linux-mm before introducing the
memdie_iffies. However this week I've other urgent work to do too not
in the oom area... so we'll see what I can do. If I can't fix the new
deadlocks within a few days I'll submit a new patchset anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
