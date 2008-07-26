Date: Sat, 26 Jul 2008 15:35:25 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: MMU notifiers review and some proposals
Message-ID: <20080726133525.GC9598@duo.random>
References: <20080724143949.GB12897@wotan.suse.de> <20080725214552.GB21150@duo.random> <20080726030810.GA18896@wotan.suse.de> <20080726113813.GD21150@duo.random> <20080726122826.GA17958@wotan.suse.de> <20080726130202.GA9598@duo.random> <20080726131015.GB21820@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080726131015.GB21820@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org, steiner@sgi.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Sat, Jul 26, 2008 at 03:10:15PM +0200, Nick Piggin wrote:
> I am talking about a number of threads starving another thread of the
> same process, but that isn't shooting themselves in the foot because
> they might be doing simple normal operations that don't expect the
> kernel to cause starvation.

I thought you worried about security issues sorry.

Note that each user is free to implement the locks as it wants. Given
what you describe is a feature and not a bug for KVM, we use readonly
locks and that can't lead to security issues either as you agreed
above.

But nothing prevents you to use a spinlock or rwlock and take the read
side of it from the page fault and the write side of it from the
range_start/end. Careful with the rwlock though because that is a
read-starved lock so it won't buy you anything, it was just to make an
example ;). Surely you can build a fair rwlock if that is what your
app requires. For KVM we want to go unfair and purely readonly in the
kvm page fault because we know the address space is almost never
mangled and that makes it a perfect fit as it'll never starve for all
remotely useful cases, and it can't be exploited either.

So you're actually commenting on the kvm implementation of the
lowlevel methods, but we're not forcing that implementation to all
users. You surely can use the mmu notifiers in -mm, to have the
secondary mmu page fault block and takeover from the range_start/end
and take range_start/end out of the game.

So really this isn't a valid complaint... infact the same issue exists
for invalidate_page or your invalidate_range. It's up to each user to
decide if to make the page fault slower but 100% fair and higher
priority than the munmap flood coming from the other threads of the
same mm.

> What's the problem with patching asm-*/tlb.h? They're just other files,
> but they all form part os the same tlb flushing design.

Nothing fundamental, but at least for the last half an year apparently
moving mmu notifier invalidate calls into arch pte/tlb flushing code
was considered a negative in layering terms (I did that initially with
ptep_clear_flush).

I suggest you make another patch that actually works so we've a better
picture of how the changes to tlb-gather looks like. I think the idea
of calling invalidate_page before every tlb_remove_page should be
rejected.

Hope also this shows how those discussions are endless and pointless
if there's nothing we can deploy to the KVM users in the first place.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
