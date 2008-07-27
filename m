Date: Sun, 27 Jul 2008 14:32:09 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: MMU notifiers review and some proposals
Message-ID: <20080727123209.GC5223@wotan.suse.de>
References: <20080724143949.GB12897@wotan.suse.de> <20080725214552.GB21150@duo.random> <20080726030810.GA18896@wotan.suse.de> <20080726113813.GD21150@duo.random> <20080726122826.GA17958@wotan.suse.de> <20080726130202.GA9598@duo.random> <20080726131450.GC21820@wotan.suse.de> <20080726134915.GD9598@duo.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080726134915.GD9598@duo.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org, steiner@sgi.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Sat, Jul 26, 2008 at 03:49:15PM +0200, Andrea Arcangeli wrote:
> On Sat, Jul 26, 2008 at 03:14:50PM +0200, Nick Piggin wrote:
> 
> But I also wear a VM (as in virtual memory not virtual machine ;) hat
> not just a KVM hat, so I surely wouldn't have submitted something that
> I think is bad for the VM. Infact I opposed certain patches made
> specifically for XPMEM that could hurt the VM a micro-bit (mostly
> thinking at UP cellphones). Still I offered to support XPMEM but with
> a lower priority and done right.

BTW. I don't like this approach especially for XPMEM the infinite
starvation will probably be a much bigger issue if tasks can go to
sleep there. Perhaps priority inversion problems too.

Also making the locks into sleeping locks I don't know if it is such
a good approach. We have gone the other way for some reasons in the
past, so they have to be addressed.

 
> I don't happen to dislike mm_take_all_locks, as it's totally localized
> and _can_never_run_ unless you load one of those kvm or gru
> modules. I'd rather prefer mmu notifiers to be invisible to the
> tlb-gather logic, surely it'd be orders of magnitude simpler to delete
> mm_take_all_locks than to undo the changes to the tlb-gather logic. So
> if something we should go with -mm first, and then evaluate if the
> tlb-gather changes are better/worse.

The thing about mm_take_all_locks that I don't think you quite appreciate
is that it isn't totally localized. It now adds a contract to the rest
of the VM to say it isn't allowed to invalidate anything while it is
being run.

If it literally was self contained and zero impact, of course I wouldn't
care about it from the core VM perspective, but I still think it might
be a bad idea for some of the GRU (and XPMEM) use cases.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
