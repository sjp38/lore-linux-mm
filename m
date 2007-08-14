Date: Tue, 14 Aug 2007 04:08:30 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] 2.6.23-rc1 mm: NUMA replicated pagecache
Message-ID: <20070814020830.GB24542@wotan.suse.de>
References: <20070727084252.GA9347@wotan.suse.de> <1186604723.5055.47.camel@localhost> <1186780099.5246.6.camel@localhost> <20070813074351.GA15609@wotan.suse.de> <1187013901.5592.24.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1187013901.5592.24.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Joachim Deguara <joachim.deguara@amd.com>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 13, 2007 at 10:05:01AM -0400, Lee Schermerhorn wrote:
> On Mon, 2007-08-13 at 09:43 +0200, Nick Piggin wrote:
> > 
> > Replication may be putting more stress on some locks. It will cause more
> > tlb flushing that can not be batched well, which could cause the call_lock
> > to get hotter. Then i_mmap_lock is held over tlb flushing, so it will
> > inherit the latency from call_lock. (If this is the case, we could
> > potentially extend the tlb flushing API slightly to cope better with
> > unmapping of pages from multiple mm's, but that comes way down the track
> > when/if replication proves itself!).
> > 
> > tlb flushing AFAIKS should not do the IPI unless it is deadling with a
> > multithreaded mm... does usex use threads?
> 
> Yes.  Apparently, there are some tests, perhaps some of the /usr/bin
> apps that get run repeatedly, that are multi-threaded.  This job mix
> caught a number of races in my auto-migration patches when
> multi-threaded tasks race in the page fault paths.
> 
> More below...

Hmm, come to think of it: I'm a bit mistaken. The replica zaps will often
to be coming from _other_ CPUs, so they will require an IPI regardless of
whether they are threaded or not.

The generic ia64 tlb flushing code also does a really bad job at flushing one
'mm' from another: it uses the single-threaded smp_call_function and broadcasts
IPIs (and TLB invalidates) to ALL CPUs, regardless of the cpu_vm_mask of the
target process. So you have a multiplicative problem with call_lock.

I think this path could be significantly optimised... but it's a bit nasty
to be playing around with the TLB flushing code while trying to test
something else :P

Can we make a simple change to smp_flush_tlb_all to do
smp_flush_tlb_cpumask(cpu_online_map), rather than on_each_cpu()? At least
then it will use the direct IPI vector and avoid call_lock.


> > Ah, so it does eventually die? Any hints of why?
> 
> No, doesn't die--as in panic.  I was just commenting that I'd leave it
> running ...  However [:-(], it DID hang again.  The test window said
> that the tests ran for 62h:28m before the screen stopped updating.  In
> another window, I was running a script to snap the replication and #
> file pages vmstats, along with a timestamp, every 10 minutes.  That
> stopped reporting stats at about 7:30am on Saturday--about 14h:30m into
> the test.  It still wrote the timestamps [date command] until around 7am
> this morning [Monday]--or ~62 hours into test.
> 
> So, I do have ~14 hours of replication stats that I can send you or plot
> up...

If you think it could be useful, sure.

 
> Re: the hang:  again, console was scrolling soft lockups continuously.
> Checking the messages file, I see hangs in copy_process(),
> smp_call_function [as in prev test], vma_link [from mmap], ...

I don't suppose it should hang even if it is encountering 10s delays on
call_lock.... but I wonder how it would go with the tlb flush change.
With luck, it would add more concurrency and make it hang _faster_ ;)


> > Yeah I guess it can be a little misleading: as time approaches infinity,
> > zaps will probably approach replications. But that doesn't tell you how
> > long a replica stayed around and usefully fed CPUs with local memory...
> 
> May be able to capture that info with a more invasive patch -- e.g., add
> a timestamp to the page struct.  I'll think about it.

Yeah that actually could be a good approach. You could make a histogram
of lifetimes which would be a decent metric to start tuning with. Ideally
you'd also want to record some context of what caused the zap and the status
of the file, but it may be difficult to get a good S/N on those metrics.

 
> And, I'll keep you posted.  Not sure how much time I'll be able to
> dedicate to this patch stream.  Got a few others I need to get back
> to...

Thanks, I appreciate it. I'm pretty much in the same boat, just spending a
bit of time on it here and there.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
