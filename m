Date: Thu, 8 May 2008 03:26:56 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 08 of 11] anon-vma-rwsem
Message-ID: <20080508012656.GQ8276@duo.random>
References: <6b384bb988786aa78ef0.1210170958@duo.random> <alpine.LFD.1.10.0805071349200.3024@woody.linux-foundation.org> <20080507212650.GA8276@duo.random> <alpine.LFD.1.10.0805071429170.3024@woody.linux-foundation.org> <20080507222205.GC8276@duo.random> <20080507153103.237ea5b6.akpm@linux-foundation.org> <20080507224406.GI8276@duo.random> <20080507155914.d7790069.akpm@linux-foundation.org> <20080507233953.GM8276@duo.random> <alpine.LFD.1.10.0805071757520.3024@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.10.0805071757520.3024@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, clameter@sgi.com, steiner@sgi.com, holt@sgi.com, npiggin@suse.de, a.p.zijlstra@chello.nl, kvm-devel@lists.sourceforge.net, kanojsarcar@yahoo.com, rdreier@cisco.com, swise@opengridcomputing.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, general@lists.openfabrics.org, hugh@veritas.com, rusty@rustcorp.com.au, aliguori@us.ibm.com, chrisw@redhat.com, marcelo@kvack.org, dada1@cosmosbay.com, paulmck@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, May 07, 2008 at 06:02:49PM -0700, Linus Torvalds wrote:
> You replace mm_lock() with the sequence that Andrew gave you (and I 
> described):
> 
> 	spin_lock(&global_lock)
> 	.. get all locks UNORDERED ..
> 	spin_unlock(&global_lock)
> 
> and you're now done. You have your "mm_lock()" (which still needs to be 
> renamed - it should be a "mmu_notifier_lock()" or something like that), 
> but you don't need the insane sorting. At most you apparently need a way 
> to recognize duplicates (so that you don't deadlock on yourself), which 
> looks like a simple bit-per-vma.
> 
> The global lock doesn't protect any data structures itself - it just 
> protects two of these mm_lock() functions from ABBA'ing on each other!

I thought the thing to remove was the "get all locks". I didn't
realize the major problem was only the sorting of the array.

I'll add the global lock, it's worth it as it drops the worst case
number of steps by log(65536) times. Furthermore surely two concurrent
mm_notifier_lock will run faster as it'll decrease the cacheline
collisions. Since you ask to call it mmu_notifier_lock I'll also move
it to mmu_notifier.[ch] as consequence.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
