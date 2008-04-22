Date: Tue, 22 Apr 2008 15:21:43 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 0 of 9] mmu notifier #v12
Message-ID: <20080422132143.GS12709@duo.random>
References: <patchbomb.1207669443@duo.random> <20080409131709.GR11364@sgi.com> <20080409144401.GT10133@duo.random> <20080409185500.GT11364@sgi.com> <20080422072026.GM12709@duo.random> <20080422120056.GR12709@duo.random> <20080422130120.GR22493@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080422130120.GR22493@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 22, 2008 at 08:01:20AM -0500, Robin Holt wrote:
> On Tue, Apr 22, 2008 at 02:00:56PM +0200, Andrea Arcangeli wrote:
> > On Tue, Apr 22, 2008 at 09:20:26AM +0200, Andrea Arcangeli wrote:
> > >     invalidate_range_start {
> > > 	spin_lock(&kvm->mmu_lock);
> > > 
> > > 	kvm->invalidate_range_count++;
> > > 	rmap-invalidate of sptes in range
> > > 
> > 
> > 	write_seqlock; write_sequnlock;
> 
> I don't think you need it here since invalidate_range_count is already
> elevated which will accomplish the same effect.

Agreed, seqlock only in range_end should be enough. BTW, the fact
seqlock is needed regardless of invalidate_page existing or not,
really makes invalidate_page a no brainer not just from the core VM
point of view, but from the driver point of view too. The
kvm_page_fault logic would be the same even if I remove
invalidate_page from the mmu notifier patch but it'd run slower both
when armed and disarmed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
