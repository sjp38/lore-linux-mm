Date: Sun, 18 Apr 2004 12:23:44 +0100
From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: PTE aging, ptep_test_and_clear_young() and TLB
Message-ID: <20040418122344.A11293@flint.arm.linux.org.uk>
References: <20040418093949.GY743@holomorphy.com> <Pine.LNX.4.44.0404181142290.12120-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0404181142290.12120-100000@localhost.localdomain>; from hugh@veritas.com on Sun, Apr 18, 2004 at 11:58:21AM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Apr 18, 2004 at 11:58:21AM +0100, Hugh Dickins wrote:
> I'm not surprised Russell's found he just needs mm rather than vma,
> I did try briefly yesterday to understand just what it is that vma
> gives to flush TLB.  Needs thorough research through all the arches,
> the ARM case is not necessarily representative.

For flushing TLBs, my understanding is the vma gives you access to
vm_flags, specifically the VM_EXEC flag.  This can be used as an
optimisation by Harvard architectures to avoid touching the I-TLB
if the page is not executable.

If this is the only reason, and we need to spent cycles looking up
the VMA, it becomes questionable whether the optimisation is really
valid in every case.  If the VMA is already available for some other
purpose then it makes sense, but otherwise it doesn't.

> Russell may well be right that we're much too lazy about the
> referenced bit in 2.6, but that doesn't mean we now have to
> jump and get it exactly right all the time: the dirty bit is
> vital, the referenced bit never more than a hint.

The evidence from Marc appears to imply that it is far more than a
hint.  His case appears to show that if we flush the TLB (due to
a context switch) his problems vanish completely.  This will be
because the referenced bit will be updated shortly after each
switch.

However, consider the following case: a TLB with ASIDs and we only
flush the TLB when we have used up all ASIDs.  The only other way
entries are purged from the TLB is when they are recycled.

The lifetime of a TLB entry is now much longer - the context
switch boundary is now eliminated.  This means that unless the
TLB entry is flushed, we'll _never_ know if the page has been
referenced after the VM scan has aged the entry.

So, I think we definitely need the flush there.  The available data
so far from Marc appears to confirm this, and the theory surrounding
ASID-based MMUs (which are coming on ARM) also require it.

This leaves one major problem - implementation.  The kernel include
files are a mess which makes it hard to get to the information
required to implement this.  We certainly can't get at the mm_struct
in asm/pgtable.h because it hasn't been defined at the point pgtable.h
is included.

I'm going to be looking into what can be done to relieve the include
mess today, and then see about implementing the flush in the private
architecture code.  However, there is most certainly a dependency
between the two activities. ;(

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
