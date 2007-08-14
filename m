Subject: Re: [RFC 4/9] Atomic reclaim: Save irq flags in vmscan.c
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0708141209270.29498@schroedinger.engr.sgi.com>
References: <20070814153021.446917377@sgi.com>
	 <20070814153501.766137366@sgi.com> <p73vebhnauo.fsf@bingen.suse.de>
	 <Pine.LNX.4.64.0708141209270.29498@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 14 Aug 2007 22:05:51 +0200
Message-Id: <1187121951.5337.4.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-08-14 at 12:12 -0700, Christoph Lameter wrote:
> On Tue, 14 Aug 2007, Andi Kleen wrote:
> 
> > Christoph Lameter <clameter@sgi.com> writes:
> > 
> > > Reclaim can be called with interrupts disabled in atomic reclaim.
> > > vmscan.c is currently using spinlock_irq(). Switch to spin_lock_irqsave().
> > 
> > I like the idea in principle. If this fully works out we could
> > potentially keep less memory free by default which would be a good
> > thing in general: free memory is bad memory.
> 
> Right.
>  
> > But would be interesting to measure what the lock
> > changes do to interrupt latency. Probably nothing good.
> 
> Yup.
>  
> > A more benign alternative might be to just set a per CPU flag during
> > these critical sections and then only do atomic reclaim on a local
> > interrupt when the flag is not set.  That would make it a little less
> > reliable, but much less intrusive and with some luck still give many
> > of the benefits.
> 
> There are other lock interactions that may cause problems. If we do not 
> switch to the saving of irq flags then all involved spinlocks must become 
> trylocks because the interrupt could have happened while the spinlock is 
> held. So interrupts must be disabled on locks acquired during an 
> interrupt.

A much simpler approach to this seems to use threaded interrupts like
-rt does.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
