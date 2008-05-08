Date: Thu, 8 May 2008 03:52:49 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 08 of 11] anon-vma-rwsem
Message-ID: <20080508015249.GT8276@duo.random>
References: <alpine.LFD.1.10.0805071429170.3024@woody.linux-foundation.org> <20080507222205.GC8276@duo.random> <20080507153103.237ea5b6.akpm@linux-foundation.org> <20080507224406.GI8276@duo.random> <20080507155914.d7790069.akpm@linux-foundation.org> <alpine.LFD.1.10.0805071610490.3024@woody.linux-foundation.org> <Pine.LNX.4.64.0805071637360.14337@schroedinger.engr.sgi.com> <alpine.LFD.1.10.0805071655100.3024@woody.linux-foundation.org> <Pine.LNX.4.64.0805071752490.14829@schroedinger.engr.sgi.com> <alpine.LFD.1.10.0805071833450.3024@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.10.0805071833450.3024@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, steiner@sgi.com, holt@sgi.com, npiggin@suse.de, a.p.zijlstra@chello.nl, kvm-devel@lists.sourceforge.net, kanojsarcar@yahoo.com, rdreier@cisco.com, swise@opengridcomputing.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, general@lists.openfabrics.org, hugh@veritas.com, rusty@rustcorp.com.au, aliguori@us.ibm.com, chrisw@redhat.com, marcelo@kvack.org, dada1@cosmosbay.com, paulmck@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, May 07, 2008 at 06:39:48PM -0700, Linus Torvalds wrote:
> 
> 
> On Wed, 7 May 2008, Christoph Lameter wrote:
> > 
> > > (That said, we're not running out of vm flags yet, and if we were, we 
> > > could just add another word. We're already wasting that space right now on 
> > > 64-bit by calling it "unsigned long").
> > 
> > We sure have enough flags.
> 
> Oh, btw, I was wrong - we wouldn't want to mark the vma's (they are 
> unique), we need to mark the address spaces/anonvma's. So the flag would 
> need to be in the "struct anon_vma" (and struct address_space), not in the 
> vma itself. My bad. So the flag wouldn't be one of the VM_xyzzy flags, and 
> would require adding a new field to "struct anon_vma()"
> 
> And related to that brain-fart of mine, that obviously also means that 
> yes, the locking has to be stronger than "mm->mmap_sem" held for writing, 
> so yeah, it would have be a separate global spinlock (or perhaps a 
> blocking lock if you have some reason to protect anything else with this 

So because the bitflag can't prevent taking the same lock twice on two
different vmas in the same mm, we still can't remove the sorting, and
the global lock won't buy much other than reducing the collisions. I
can add that though.

I think it's more interesting to put a cap on the number of vmas to
min(1024,max_map_count). The sort time on an 8k array runs in constant
time. kvm runs with 127 vmas allocated...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
