Date: Sat, 26 Jul 2008 14:28:26 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: MMU notifiers review and some proposals
Message-ID: <20080726122826.GA17958@wotan.suse.de>
References: <20080724143949.GB12897@wotan.suse.de> <20080725214552.GB21150@duo.random> <20080726030810.GA18896@wotan.suse.de> <20080726113813.GD21150@duo.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080726113813.GD21150@duo.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org, steiner@sgi.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Sat, Jul 26, 2008 at 01:38:13PM +0200, Andrea Arcangeli wrote:
> On Sat, Jul 26, 2008 at 05:08:10AM +0200, Nick Piggin wrote:
> > Well I just was never completely satisfied with how that turned out.
> > There was an assertion that invalidate range begin/end were the right
> > way to go because performance would be too bad using the traditional
> > mmu gather / range flushing. Now that I actually had the GRU and KVM
> > code to look at, I must say I would be very surprised if performance
> > is too bad. Given that, I would have thought the logical way to go
> > would be to start with the "minimal" type of notifiers I proposed now,
> > and then get some numbers together to try to support the start/end
> > scheme.
> 
> You know back in Feb I started with the minimal type of notifiers
> you're suggesting but it was turned down.

Yes, but I don't think it was turned down for good reasons. It was
turned down solely because of performance AFAIKS, but there were
not even any numbers to back this up and I think it most situations
where KVM and GRU are used, it should not be measurable.

 
> The advantages of the current -mm approach are:
> 
> 1) absolute minimal intrusion into the kernel common code, and
>    absolute minimum number of branches added to the kernel fast
>    paths. Kernel is faster than your "minimal" type of notifiers when
>    they're disarmed. Nobody can care less about the performance of mmu
>    notifiers infact, both will work fast enough, but I want the
>    approach that bloats the main kernel less, and -mm reaches this
>    objective fine.

I claim opposite. There is no mm_take_all_locks in my approach, and
the TLB flushing design mirrors that which we use for CPU TLB flushing.
Both these points make the -mm design much more intrusive to kernel
common code.

As for notifiers disabled speed, I can't see how -mm would be faster.
Sometimes -mm will result in fewer notifier calls eg. due to huge
unmaps. Othertimes my design will be fewer because it only makes
a single range flush call rather than a start/end pair. How do you
think they are slower?


> 2) No need to rewrite the tlb-gather logic, which in any case would
>    not allow to schedule inside the mmu notifiers later if an user
>    requiring scheduling ever showup (more flexible approach), and it
>    would also need to become per-mm and not per-cpu.

I sent a patch in my first email. I don't see this as rewriting the
TLB gather logic at all. Or is there a hole in my design?

Hmm, I missed putting the notification in tlb_remove_page when the
gather fills up, but I don't think that classes as a redesign of
the tlb-gather logic to put a callback in there.


> 3) Maximal reduction of IPI flood during vma teardown. You can't
>    possibly hold off the CPU primary-mmu tlb miss handler, but we can

You definitely can on many architectures except x86. None has seemed
to require the need as yet.


>    hold off the secondary-mmu page-fautl/tlb-miss handler, and doing
>    so we can run a single IPI for an unlimited amount of address space
>    teardown.

That is true, but 1) most unmaps will be either fairly small or
whole-program. In both cases, minimal notifiers should be just as
good.

 
> Disavantages:
> 
> 1) mm_take_all_locks is required to register
> 
> No other disavantage.

2) new tlb flushing design

3) livelock/starvation problem with TLB holdoff

 
> There is no problem with holding off the secondary mmu page fault, a
> few threads may spin but signals are handled the whole time, the page
> fault doesn't loop it returns and it is being retried. So you can
> shoot yourself in the foot (with your own threads stepping on each
> other toes) and that's all, there's no risk of starvation or anything
> like that.

That's not shooting yourself in the foot if you are forced into the
design. Definitely there can be indefinite starvation because there
is no notion of queueing on the range_active count.

 
> > If there is some real performance numbers or something that I missed,
> > please let me know.
> 
> Producing performance numbers for KVM isn't really possible, because
> either one will work fine, kvm never mangles the address space with
> the exception of madvise with ballooning which is going to perform
> well either way. invalidate_page is run most of the time in KVM
> runtime, never invalidate_range_start/end so there would be no difference.

So then the important question is GRU. In which case the driver isn't
even finished, it is being run on a simulator, and probably very few
or no real users of the driver... so that's not a good platform to be
arguing for more complexity for the sake of performance IMO.

 
> > I think for the core VM, minimal notifiers are basically trivial, and
> 
> Your minimal notifiers are a whole lot more complex, as they require
> to rewrite the tlb-gather in all archs. Go ahead it won't be ready for
> 2.6.27 be sure...
> 
> Furthermore despite rewriting tlb-gather they still have all the
> disavantages mentioned above.
> 
> What is possible is to have a minimal notifier that adds a branch for
> every pte teardown, that's easy done that in Feb, that leaves the
> tlb-gather optimization for later, but I still think using tlb-gather
> when we can do better and we already do better is wrong.

I'm doing range flushing withing tlb-gathers in the patch I posted which
does not add a branch for every pte teardown. And I don't really
consider range_start/end as better, given my reasons.

 
> > Anyway, I just voice my opinion and let Andrew and Linus decide. To be
> > clear: I have not found any actual bugs in Andrea's -mm patchset, only
> > some dislikes of the approach.
> 
> Yes, like I said I think this is a matter of taste of what you like of
> the tradeoff. There are disadvantages and advantages in both and if we
> wait forever to please everyone taste, it'll never go in.
> 
> My feeling is that what is in -mm is better and it will stay for long,
> because it fully exploits the ability we have to hold off and reply
> the secondary mmu page fault (equivalent of the primary-mmu tlb miss)
> something we can't do with the primary mmu tlb miss and that forces us
> to implement something as complex (and IPI-flooding) as tlb-gather
> logic. And the result besides being theoretically faster in the fast
> path both when armed and disarmed, is also simpler than plugging mmu
> notifier invalidate_pages inside tlb-gather. So I think it's a better
> tradeoff.

If I had seen even a single number to show the more complex scheme
is better maybe I would be more receptive. I realise there might be
some theoretical advantages but I also believe they wouldn't be
measurable in real use cases.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
