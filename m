Date: Wed, 30 Jul 2008 16:54:36 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: MMU notifiers review and some proposals
Message-ID: <20080730145436.GJ11494@duo.random>
References: <20080724143949.GB12897@wotan.suse.de> <20080725214552.GB21150@duo.random> <20080726030810.GA18896@wotan.suse.de> <20080726113813.GD21150@duo.random> <20080726122826.GA17958@wotan.suse.de> <20080726130202.GA9598@duo.random> <20080726131450.GC21820@wotan.suse.de> <48907880.3020105@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48907880.3020105@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

On Wed, Jul 30, 2008 at 09:19:44AM -0500, Christoph Lameter wrote:
> Yes we have had so much talk about this that I am a bit tired of
> talking about it. I vaguely remember bringing up the same point a
> couple of months ago. If you can make it work then great.

I think the current implementation is fine for the long run, it can
provide the fastest performance when armed, and each invalidate either
requires IPIs or it may may need to access the southbridge, so when
freeing large areas of memory it's good being able to do a single
invalidate.

If I can add another comment, I think if a new user of
mm_take_all_locks showup, that will further confirm that such method
is useful and should stay. Of course it needs to be a legitimate usage
that allows to improve performance to the fast paths like in the
mmu-notifier usage. And if Nick's right that mm_take_all_locks will
ever become a limitation, removing it is trivial, much much simpler
than undoing mmu-notifier changes to tlb-gather. So until Nick will go
ahead and remove the anon_vma->lock (and I don't think it's feasible
without screwing other paths much more troublesome than
mm_take_all_locks) I think this is fine to stay. If you'll have
troubles removing anon_vma->lock it won't be because of
mm_take_all_locks be sure ;). If you ever get there we'll add
invalidate_page before tlb_remove_page and be done with it for the
benefit of the VM, no problem at all.

If we'll ever need to add scheduling capability to mmu notifiers (like
for XPMEM or perhaps in the future infiniband) that's nearly trivially
feasible too in the future without having to alter the API at all
(something not feasible with other implementations).

Nevertheless I'm ok if we want to alter the implementation in the
future for whatever good/wrong reasaon: the only important thing to me
is that from now on all kernels will have this functionality one way
or another because KVM already depends on it and it swaps much better
now!

The current implementation is bugfree, well tested, looks great to me
and there's no urgency to alter it. It's surely what all the
mmu-notifier users prefer, and I want to thank everyone for the help
in getting here and all the good/bad feedback provided that helped
improving the code so much.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
