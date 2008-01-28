Date: Mon, 28 Jan 2008 18:25:21 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch 0/4] [RFC] MMU Notifiers V1
Message-ID: <20080128172521.GC7233@v2.random>
References: <20080125055606.102986685@sgi.com> <20080125114229.GA7454@v2.random> <479DFE7F.9030305@qumranet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <479DFE7F.9030305@qumranet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Izik Eidus <izike@qumranet.com>
Cc: Christoph Lameter <clameter@sgi.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 28, 2008 at 06:10:39PM +0200, Izik Eidus wrote:
> i dont understand how is that better than notification on tlb flush?

I certainly agree. The quoted call wasn't actually the one that could
be moved in a single place in the .h file though. But the 4/4 patch
could be reduced to a few liner patch and it would not require any
change to ksm and mm/*.c internals that way etc...

If Christoph prefers to expand the two bits I added in the .h file,
all over the .c files that's ok with us. There is no good excuse for
that IMHO because a __ptep_clear_flush could be added to optimize away
the notifiers if it's followed by the invalidate_range (not the common
case), and if we want to just mark a spte readonly instead of
invalidating it we could implement new ptep_ function that would
invoke a new mmu notifier method. So there's full room for
optimizations without requiring the expansion.

In the end it's only a coding style issue but one that will become
visible in the VM (i.e. ksm has to be modified to add a mmu_notifier
call after ptep_clear_flush, it won't work automatically without
changes anymore).

So I'd like to know what can we do to help to merge the 4 patches from
Christoph in mainline, I'd appreciate comments on them so we can help
to address any outstanding issue!

It's very important to have this code in 2.6.25 final. KVM requires
mmu notifiers for reliable swapping, madvise/ballooning, ksm etc... so
it's high priority to get something merged to provide this
functionality regardless of its coding style ;).

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
