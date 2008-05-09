Subject: Re: [PATCH 08 of 11] anon-vma-rwsem
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <alpine.LFD.1.10.0805080907420.3024@woody.linux-foundation.org>
References: <20080507153103.237ea5b6.akpm@linux-foundation.org>
	 <20080507224406.GI8276@duo.random>
	 <20080507155914.d7790069.akpm@linux-foundation.org>
	 <20080507233953.GM8276@duo.random>
	 <alpine.LFD.1.10.0805071757520.3024@woody.linux-foundation.org>
	 <Pine.LNX.4.64.0805071809170.14935@schroedinger.engr.sgi.com>
	 <20080508025652.GW8276@duo.random>
	 <Pine.LNX.4.64.0805072009230.15543@schroedinger.engr.sgi.com>
	 <20080508034133.GY8276@duo.random>
	 <alpine.LFD.1.10.0805072109430.3024@woody.linux-foundation.org>
	 <20080508052019.GA8276@duo.random>
	 <alpine.LFD.1.10.0805080759430.3024@woody.linux-foundation.org>
	 <alpine.LFD.1.10.0805080907420.3024@woody.linux-foundation.org>
Content-Type: text/plain
Date: Fri, 09 May 2008 20:37:29 +0200
Message-Id: <1210358249.13978.275.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, steiner@sgi.com, holt@sgi.com, npiggin@suse.de, kvm-devel@lists.sourceforge.net, kanojsarcar@yahoo.com, rdreier@cisco.com, swise@opengridcomputing.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, general@lists.openfabrics.org, hugh@veritas.com, rusty@rustcorp.com.au, aliguori@us.ibm.com, chrisw@redhat.com, marcelo@kvack.org, dada1@cosmosbay.com, paulmck@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Thu, 2008-05-08 at 09:11 -0700, Linus Torvalds wrote:
> 
> On Thu, 8 May 2008, Linus Torvalds wrote:
> > 
> > Also, we'd need to make it 
> > 
> > 	unsigned short flag:1;
> > 
> > _and_ change spinlock_types.h to make the spinlock size actually match the 
> > required size (right now we make it an "unsigned int slock" even when we 
> > actually only use 16 bits).
> 
> Btw, this is an issue only on 32-bit x86, because on 64-bit one we already 
> have the padding due to the alignment of the 64-bit pointers in the 
> list_head (so there's already empty space there).
> 
> On 32-bit, the alignment of list-head is obviously just 32 bits, so right 
> now the structure is "perfectly packed" and doesn't have any empty space. 
> But that's just because the spinlock is unnecessarily big.
> 
> (Of course, if anybody really uses NR_CPUS >= 256 on 32-bit x86, then the 
> structure really will grow. That's a very odd configuration, though, and 
> not one I feel we really need to care about).

Another possibility, would something like this work?

 
 /*
  * null out the begin function, no new begin calls can be made
  */
 rcu_assing_pointer(my_notifier.invalidate_start_begin, NULL); 

 /*
  * lock/unlock all rmap locks in any order - this ensures that any
  * pending start() will have its end() function called.
  */
 mm_barrier(mm);

 /*
  * now that no new start() call can be made and all start()/end() pairs
  * are complete we can remove the notifier.
  */
 mmu_notifier_remove(mm, my_notifier);


This requires a mmu_notifier instance per attached mm and that
__mmu_notifier_invalidate_range_start() uses rcu_dereference() to obtain
the function.

But I think its enough to ensure that:

  for each start an end will be called

It can however happen that end is called without start - but we could
handle that I think.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
