Date: Tue, 15 Jan 2008 13:44:50 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH] mmu notifiers #v2
Message-ID: <20080115124449.GK30812@v2.random>
References: <20080113162418.GE8736@v2.random> <Pine.LNX.4.64.0801141154240.8300@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801141154240.8300@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm-devel@lists.sourceforge.net, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, daniel.blueman@quadrics.com, holt@sgi.com, steiner@sgi.com, Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <npiggin@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 14, 2008 at 12:02:42PM -0800, Christoph Lameter wrote:
> Hmmm... In most of the callsites we hold a writelock on mmap_sem right?

Not in all, like Marcelo pointed out in kvm-devel, so the lowlevel
locking can't relay on the VM locks.

About your request to schedule in the mmu notifier methods this is not
feasible right now, the notifier is often called with the pte
spinlocks held. I wonder if you can simply post/queue an event like a
softirq/pdflush.

> Passing mm is fine as long as mmap_sem is held.

mmap_sem is not held, but don't worry "mm" can't go away under the mmu
notifier, so it's ok. It's just that the KVM methods never uses "mm"
at all (containerof translates the struct mmu_notifier to a struct
kvm, and there is the mm in kvm->mm too). Perhaps others don't save
the "mm" in their container where the mmu_notifier is embedded into,
so I left mm as parameter to the methods.

> Hmmm... this is ptep_clear_flush? What about the other uses of 
> flush_tlb_page in asm-generic/pgtable.h and related uses in arch code?

This is not necessarily a 1:1 relationship with the tlb
flushes. Otherwise they'd be the tlb-notifiers not the mmu-notifiers.

The other methods in the pgtable.h are not dropping an user page from
the "mm". That's the invalidate case right now. Other methods will not
call into invalidate_page, but you're welcome to add other methods and
call them from other ptep_* functions if you're interested about being
notified about more than just the invalidates of the "mm".

Is invalidate_page/range a clear enough method name to explain when
the ptes and tlb entries have been dropped for such page/range mapped
in userland in that address/range?

> (would help if your patches would mention the function name in the diff 
> headers)

my patches uses git diff defaults I guess, and they mention the
function name in all other places, it's just git isn't smart enough
there to catch the function name in that single place, it's ok.

> > +#define mmu_notifier(function, mm, args...)				\
> > +	do {								\
> > +		struct mmu_notifier *__mn;				\
> > +		struct hlist_node *__n;					\
> > +									\
> > +		hlist_for_each_entry(__mn, __n, &(mm)->mmu_notifier, hlist) \
> > +			if (__mn->ops->function)			\
> > +				__mn->ops->function(__mn, mm, args);	\
> > +	} while (0)
> 
> Does this have to be inline? ptep_clear_flush will become quite big

Inline makes the patch smaller and it avoids a call in the common case
that the mmu_notifier list is empty. Perhaps I could add a:

     if (unlikely(!list_empty(&(mm)->mmu_notifier)) {
     	...
     }

so gcc could offload the internal block in a cold-icache region of .text.

I think at least an unlikely(!list_empty(&(mm)->mmu_notifier)) check
has to be inline. Currently there isn't such check because I'm unsure
if it really makes sense. The idea is that if you really care to
optimize this you'll use self-modifying code to turn a nop into a call
when a certain method is armed. That's an extreme optimization though,
current code shouldn't be measurable already when disarmed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
