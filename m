Date: Wed, 7 May 2008 23:58:40 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 01 of 11] mmu-notifier-core
Message-ID: <20080507215840.GB8276@duo.random>
References: <patchbomb.1210170950@duo.random> <e20917dcc8284b6a07cf.1210170951@duo.random> <20080507130528.adfd154c.akpm@linux-foundation.org> <alpine.LFD.1.10.0805071324570.3024@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.10.0805071324570.3024@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, clameter@sgi.com, steiner@sgi.com, holt@sgi.com, npiggin@suse.de, a.p.zijlstra@chello.nl, kvm-devel@lists.sourceforge.net, kanojsarcar@yahoo.com, rdreier@cisco.com, swise@opengridcomputing.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, general@lists.openfabrics.org, hugh@veritas.com, rusty@rustcorp.com.au, aliguori@us.ibm.com, chrisw@redhat.com, marcelo@kvack.org, dada1@cosmosbay.com, paulmck@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, May 07, 2008 at 01:30:39PM -0700, Linus Torvalds wrote:
> 
> 
> On Wed, 7 May 2008, Andrew Morton wrote:
> > 
> > The patch looks OK to me.
> 
> As far as I can tell, authorship has been destroyed by at least two of the 
> patches (ie Christoph seems to be the author, but Andrea seems to have 
> dropped that fact).

I can't follow this, please be more specific.

About the patches I merged from Christoph, I didn't touch them at all
(except for fixing a kernel crashing bug in them plus some reject
fix). Initially I didn't even add a signed-off-by: andrea, and I only
had the signed-off-by: christoph. But then he said I had to add my
signed-off-by too, while I thought at most an acked-by was
required. So if I got any attribution on Christoph work it's only
because he explicitly requested it as it was passing through my
maintenance line. In any case, all patches except mmu-notifier-core
are irrelevant in this context and I'm entirely fine to give Christoph
the whole attribution of the whole patchset including the whole
mmu-notifier-core where most of the code is mine.

We had many discussions with Christoph, Robin and Jack, but I can
assure you nobody had a single problem with regard to attribution.

About all patches except mmu-notifier-core: Christoph, Robin and
everyone (especially myself) agrees those patches can't yet be merged
in 2.6.26.

With regard to the post-2.6.26 material, I think adding a config
option to make the change at compile time, is ok. And there's no other
way to deal with it in a clean way, as vmtrunate has to teardown
pagetables, and if the i_mmap_lock is a spinlock there's no way to
notify secondary mmus about it, if the ->invalidate_range_start method
has to allocate an skb, send it through the network and wait for I/O
completion with schedule().

> Yeah, too late and no upside.

No upside to all people setting CONFIG_KVM=n true, but no downside
for them either, that's the important fact!

And for all the people setting CONFIG_KVM!=n, I should provide some
background here. KVM MM development is halted without this, that
includes: paging, ballooning, tlb flushing at large, pci-passthrough
removing page pin as a whole, etc...

Everyone on kvm-devel talks about mmu-notifiers, check the last VT-d
patch form Intel where Antony (IBM/qemu/kvm) wonders how to handle
things without mmu notifiers (mlock whatever).

Rusty agreed we had to get mmu notifiers in 2.6.26 so much that he has
gone as far as writing his own ultrasimple mmu notifier
implementation, unfortunately too simple as invalidate_range_start was
missing and we can't remove the page pinning and avoid doing
spte=invalid;tlbflush;unpin for every group of sptes released without
it. And without mm_lock invalidate_range_start can't be implemented in
a generic way (to work for GRU/XPMEM too).

> That "locking" code is also too ugly to live, at least without some 
> serious arguments for why it has to be done that way. Sorting the locks? 
> In a vmalloc'ed area?  And calling this something innocuous like 
> "mm_lock()"? Hell no. 

That's only invoked in mmu_notifier_register, mm_lock is explicitly
documented as heavyweight function. In the KVM case it's only called
when a VM is created, that's irrelevant cpu cost compared to the time
it takes to the OS to boot in the VM... (especially without real mode
emulation with direct NPT-like secondary-mmu paging).

mm_lock solved the fundamental race in the range_start/end
invalidation model (that will allow GRU to do a single tlb flush for
the whole range that is going to be freed by
zap_page_range/unmap_vmas/whatever). Christoph merged mm_lock in his
EMM versions of mmu notifiers, moments after I released it, I think he
wouldn't have done it if there was a better way.

> That code needs some serious re-thinking.

Even if you're totally right, with Nick's mmu notifiers, Rusty's mmu
notifiers, my original mmu notifiers, Christoph's first version of my
mmu notifiers, with my new mmu notifiers, with christoph EMM version
of my new mmu notifiers, with my latest mmu notifiers, and all people
making suggestions and testing the code and needing the code badly,
and further patches waiting inclusion during 2.6.27 in this area, it
must be obvious for everyone, that there's zero chance this code won't
evolve over time to perfection, but we can't wait it to be perfect
before start using it or we're screwed. Even if it's entirely broken
this will allow kvm development to continue and then we'll fix it (but
don't worry it works great at runtime and there are no race
conditions, Jack and Robin are also using it with zero problems with
GRU and XPMEM just in case the KVM testing going great isn't enough).

Furthermore the API is freezed for almost months, everyone agrees with
all fundamental blocks in mmu-notifier-core patch (to be complete
Christoph would like to replace invalidate_page with an
invalidate_range_start/end but that's a minor detail).

And most important we need something in now, regardless of which
API. We can handle a change of API totally fine later.

mm_lock() is not even part of the mmu notifier API, it's just an
internal implementation detail, so whatever problem it has, or
whatever better name we can find, isn't an high priority right now.

If you suggest a better name now I'll fix it up immediately. I hope
the mm_lock name and whatever signed-off-by error in patches after
mmu-notifier-core won't be really why this doesn't go in.

Thanks a lot for your time to review even if it wasn't as positive as
I hoped,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
