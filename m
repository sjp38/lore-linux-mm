Date: Tue, 22 Apr 2008 14:00:56 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 0 of 9] mmu notifier #v12
Message-ID: <20080422120056.GR12709@duo.random>
References: <patchbomb.1207669443@duo.random> <20080409131709.GR11364@sgi.com> <20080409144401.GT10133@duo.random> <20080409185500.GT11364@sgi.com> <20080422072026.GM12709@duo.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080422072026.GM12709@duo.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 22, 2008 at 09:20:26AM +0200, Andrea Arcangeli wrote:
>     invalidate_range_start {
> 	spin_lock(&kvm->mmu_lock);
> 
> 	kvm->invalidate_range_count++;
> 	rmap-invalidate of sptes in range
> 

	write_seqlock; write_sequnlock;

> 	spin_unlock(&kvm->mmu_lock)
>     }
> 
>     invalidate_range_end {
> 	spin_lock(&kvm->mmu_lock);
> 
> 	kvm->invalidate_range_count--;


	write_seqlock; write_sequnlock;

> 
> 	spin_unlock(&kvm->mmu_lock)
>     }

Robin correctly pointed out by PM there should be a seqlock in
range_begin/end too like corrected above.

I guess it's better to use an explicit sequence counter so we avoid an
useless spinlock of the write_seqlock (mmu_lock is enough already in
all places) and so we can increase it with a single op with +=2 in the
range_begin/end. The above is a lower-perf version of the final
locking but simpler for reading purposes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
