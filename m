Subject: Re: [RFC/PATCH] Use mmu_gather for fork() instead of flush_tlb_mm()
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <46920A0C.3040400@yahoo.com.au>
References: <1183952874.3388.349.camel@localhost.localdomain>
	 <1183962981.5961.3.camel@localhost.localdomain>
	 <1183963544.5961.6.camel@localhost.localdomain>
	 <4691E64F.5070506@yahoo.com.au>
	 <1183972349.5961.25.camel@localhost.localdomain>
	 <4691FFDC.5020808@yahoo.com.au>
	 <1183974458.5961.42.camel@localhost.localdomain>
	 <46920A0C.3040400@yahoo.com.au>
Content-Type: text/plain
Date: Mon, 09 Jul 2007 22:32:06 +1000
Message-Id: <1183984326.5961.62.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org, Linux Kernel list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-07-09 at 20:12 +1000, Nick Piggin wrote:
> Benjamin Herrenschmidt wrote:
> > On Mon, 2007-07-09 at 19:29 +1000, Nick Piggin wrote:
> > 
> >>They could just #define one to the other though, there are only a
> >>small
> >>number of them. Is there a downside to not making them distinct? i386
> >>for example probably would just keep doing a tlb flush for fork and
> >>not
> >>want to worry about touching the tlb gather stuff.
> > 
> > 
> > But the tlb gather stuff just does ... a flush_tlb_mm() on x86 :-)
> 
> But it still does the get_cpu of the mmu gather data structure and
> has to look in there and touch the cacheline. You're also having to
> do more work when unlocking/relocking the ptl etc.

Hrm... true. I forgot about the cost of get_cpu. Do you think it will by
measurable at all in practice ? I doubt it but heh...

The place where I see a possible issue is indeed when dropping the lock,
in things like copy_pte_range, we would want to flush the batch in order
to be able to schedule.

That means we would end up probably doing flush_tlb_mm() once for every
lock drop instead of just once on x86, unless there's a smart way to
deal with that case... After all, when we do such lock dropping, we
don't actually need to dismiss the batch, the only reason we do so is to
re-enable preempt, because we may be migrated to another CPU.

But I wonder if it's worth bothering.... we drop the lock when have
need_resched() or there is contention on the lock. In both of these
cases, I doubt the added flush will matter noticeably...

If you think it will, then we could probably make the implementation a
bit more subtle, and allow to "put" a current batch (unblock
preemption), and only actually complete/flush it if a context switch
happens. It's not totally trivial to do with the current APIs though
mostly because of the passing of start/end when completing the batch.

Technically, on x86, I believe we don't even need to do anything but the
-last- flush in fact. So we could just add a pair of tlb_pause/resume
for the lock dropping :-)

But if we're going to do a spearate API, then what would you have it
look like ? It would have all of the same issues no ? 

I suppose best is to do a few tests to see if there's any measurable
performance regression with my patch on x86 (btw, it may not build with
hugetlbfs, I forgot a #include). Do you have some test gear around ? I
lack x86 hardware myself...

I'm also interested in the possible impact on ia64. I wonder if they can
benefit from more targetted flushing in fork()

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
