Date: Thu, 8 May 2008 01:45:21 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 08 of 11] anon-vma-rwsem
Message-ID: <20080507234521.GN8276@duo.random>
References: <6b384bb988786aa78ef0.1210170958@duo.random> <alpine.LFD.1.10.0805071349200.3024@woody.linux-foundation.org> <20080507212650.GA8276@duo.random> <alpine.LFD.1.10.0805071429170.3024@woody.linux-foundation.org> <20080507222205.GC8276@duo.random> <20080507153103.237ea5b6.akpm@linux-foundation.org> <20080507224406.GI8276@duo.random> <1210202918.1421.20.camel@pasglop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1210202918.1421.20.camel@pasglop>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, clameter@sgi.com, steiner@sgi.com, holt@sgi.com, npiggin@suse.de, a.p.zijlstra@chello.nl, kvm-devel@lists.sourceforge.net, kanojsarcar@yahoo.com, rdreier@cisco.com, swise@opengridcomputing.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, general@lists.openfabrics.org, hugh@veritas.com, rusty@rustcorp.com.au, aliguori@us.ibm.com, chrisw@redhat.com, marcelo@kvack.org, dada1@cosmosbay.com, paulmck@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Thu, May 08, 2008 at 09:28:38AM +1000, Benjamin Herrenschmidt wrote:
> 
> On Thu, 2008-05-08 at 00:44 +0200, Andrea Arcangeli wrote:
> > 
> > Please note, we can't allow a thread to be in the middle of
> > zap_page_range while mmu_notifier_register runs.
> 
> You said yourself that mmu_notifier_register can be as slow as you
> want ... what about you use stop_machine for it ? I'm not even joking
> here :-)

We can put a cap of time + a cap of vmas. It's not important if it
fails, the only useful case we know it, and it won't be slow at
all. The failure can happen because the cap of time or the cap of vmas
or the cap vmas triggers or there's a vmalloc shortage. We handle the
failure in userland of course. There are zillon of allocations needed
anyway, any one of them can fail, so this isn't a new fail path, is
the same fail path that always existed before mmu_notifiers existed.

I can't possibly see how adding a new global wide lock that forces all
truncate to be serialized against each other, practically eliminating
the need of the i_mmap_lock, could be superior to an approach that
doesn't cause the overhead to the VM at all, and only require kvm to
pay for an additional cost when it startup.

Furthermore the only reason I had to implement mm_lock was to fix the
invalidate_range_start/end model, if we go with only invalidate_page
and invalidate_pages called inside the PT lock and we use the PT lock
to serialize, we don't need a mm_lock anymore and no new lock from the
VM either. I tried to push for that, but everyone else wanted
invalidate_range_start/end. I only did the only possible thing to do:
to make invalidate_range_start safe to make everyone happy without
slowing down the VM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
