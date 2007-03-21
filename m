Date: Wed, 21 Mar 2007 03:46:49 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH 1/7] Introduce the pagetable_operations and associated helper macros.
Message-ID: <20070321104649.GG2986@holomorphy.com>
References: <20070319200502.17168.17175.stgit@localhost.localdomain> <20070319200513.17168.52238.stgit@localhost.localdomain> <4600B216.3010505@yahoo.com.au> <20070321045214.GE2986@holomorphy.com> <4600BD9F.8030609@yahoo.com.au> <20070321054102.GF2986@holomorphy.com> <4600D5EB.90507@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4600D5EB.90507@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Adam Litke <agl@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, Christoph Hellwig <hch@infradead.org>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
>> I'm tied up elsewhere so I won't get to it in a timely fashion. Maybe
>> in a few weeks I can start up on the first two of the bunch.

On Wed, Mar 21, 2007 at 05:51:23PM +1100, Nick Piggin wrote:
> Care to give us a hint? :)

The first is something DISM-like. I've not made up my mind on the
second, but the shopping catalogue of feature requests I've done
nothing about for some time that want this is long.


William Lee Irwin III wrote:
>> Not much of a VM translation; it's just a lookup through the
>> software mocked-up structures on everything save i386, x86_64, and
>> some m68k where they're the same thing only with hardware walkers
>> (ISTR ia64's being firmware a la Alpha despite the "HPW" name,
>> though I could be wrong)

On Wed, Mar 21, 2007 at 05:51:23PM +1100, Nick Piggin wrote:
> Well the vma+pagetables *are* our VM translation data structure. It is
> a good data structure. The Gelato/UNSW guys experimenting with changing
> this have basically said they haven't yet got anything that beats it.
> I would be opposed to anything that bypasses that unless a) it is not
> applicable to the VM as a whole, and b) it is really worth it
> (hugepages was a reasonable exception).

Maybe anticipating the conventional Linux approach to this wasn't as
difficult as I supposed. ;)


William Lee Irwin III wrote:
>> reliant on them. The drivers/etc. could just as easily use helper
>> functions to carry out the lookup, thereby accomplishing the
>> unification. There's nothing particularly fundamental about a pte
>> lookup.

On Wed, Mar 21, 2007 at 05:51:23PM +1100, Nick Piggin wrote:
> Yeah you could, but it looks back to front to me.
> The VM tells the filesystem that the machine took a fault at virtual
> address X, then the filesystem asks the VM what pgoff that is, then
> tells the VM to install the corresponding page to vaddr X.
> With my ->fault, the VM asks the filesystem to give the page that
> corresponds to vaddr X, then installs it into that vaddr.

I'm aware of what is now done and the minor modification accomplished
by your ->fault(). Maybe I've even written something like this before
that I never posted. It's obvious what I'm on about and that my
thoughts here are too divergent to fly. Others should chime in with
more Linux-native ideas about what's to be done here.


William Lee Irwin III wrote:
>> Normal arches that do software TLB refill could just as easily
>> consult the radix trees dangled off struct address_space or any old
>> data structure floating around the kernel with enough information to
>> translate user virtual addresses to the physical addresses they need to
>> fill the TLB with, and there are other kernels that literally do things
>> like that.

On Wed, Mar 21, 2007 at 05:51:23PM +1100, Nick Piggin wrote:
> Sure it *could* be done, but it may not be very nice, given Linux's
> design. And you definitely need _something_ other than just the
> pagecache radix-tree, because the VM needs to know who maps the page.
> So if, for your backing store, you use a small hash table and evict old
> entries like powerpc, you'll constantly be faulting in and out pages
> from the VM's high level view of the address space. That isn't a really
> cheap operation. It takes at least:
[long list of locking operations snipped]
> Compared to our current page table walk which is just a single locked
> op + barrier for the spinlock + radix tree walk.
> If you had a very large hash table (ia64 long mode, maybe?), then you
> may have slightly fewer high level faults, but range based operations
> are going to take a whole lot of cache misses, aren't they? Especially
> for small processes.
> Not that I wouldn't be happy to be proven wrong, but I don't think it
> should be something that sneaks in under these pagetable operations.
> IMO.

I'll presume that was not for my benefit; if so, it was superfluous.

The example I gave was to show how far things could diverge from Linux'
conventions. Every single locking operation cited for Linux didn't
apply to the kernel I was thinking of due to its lockless pagecache
analogue, its lack of a direct equivalent of struct page, and its use
of different lifetime-bounding protocols from reference counting.
Things like page replacement didn't rely on things that would disturb
all that. It all worked out quite well for that kernel. So not only
can it be done other ways, but those ways are indeed efficient.

It should be clear from the above that retrofitting Linux to do similar
is effectively impossible. (Well, if you think you can pull off removing
struct page in favor of no direct equivalent and bounding the lifetimes
of page-sized chunks of memory by shooting down all references using
knowledge of who could possibly be hanging onto them in Linux, feel
free to attempt such a retrofit, and I'll send you a case of Scotch
whisky if you can get it to boot and run a major database benchmark
without crashing regardless of whether it's merged.)

In any event, let's not talk too much at cross-purposes. I'm deferring
to others on this, as I said. Someone else will doubtless come at this
from a direction that gibes better with Linux-native conventions.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
