Date: Wed, 7 May 2008 15:59:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 08 of 11] anon-vma-rwsem
Message-Id: <20080507155914.d7790069.akpm@linux-foundation.org>
In-Reply-To: <20080507224406.GI8276@duo.random>
References: <6b384bb988786aa78ef0.1210170958@duo.random>
	<alpine.LFD.1.10.0805071349200.3024@woody.linux-foundation.org>
	<20080507212650.GA8276@duo.random>
	<alpine.LFD.1.10.0805071429170.3024@woody.linux-foundation.org>
	<20080507222205.GC8276@duo.random>
	<20080507153103.237ea5b6.akpm@linux-foundation.org>
	<20080507224406.GI8276@duo.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: torvalds@linux-foundation.org, clameter@sgi.com, steiner@sgi.com, holt@sgi.com, npiggin@suse.de, a.p.zijlstra@chello.nl, kvm-devel@lists.sourceforge.net, kanojsarcar@yahoo.com, rdreier@cisco.com, swise@opengridcomputing.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, general@lists.openfabrics.org, hugh@veritas.com, rusty@rustcorp.com.au, aliguori@us.ibm.com, chrisw@redhat.com, marcelo@kvack.org, dada1@cosmosbay.com, paulmck@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Thu, 8 May 2008 00:44:06 +0200
Andrea Arcangeli <andrea@qumranet.com> wrote:

> On Wed, May 07, 2008 at 03:31:03PM -0700, Andrew Morton wrote:
> > Nope.  We only need to take the global lock before taking *two or more* of
> > the per-vma locks.
> > 
> > I really wish I'd thought of that.
> 
> I don't see how you can avoid taking the system-wide-global lock
> before every single anon_vma->lock/i_mmap_lock out there without
> mm_lock.
> 
> Please note, we can't allow a thread to be in the middle of
> zap_page_range while mmu_notifier_register runs.
> 
> vmtruncate takes 1 single lock, the i_mmap_lock of the inode. Not more
> than one lock and we've to still take the global-system-wide lock
> _before_ this single i_mmap_lock and no other lock at all.
> 
> Please elaborate, thanks!


umm...


	CPU0:			CPU1:

	spin_lock(a->lock);	spin_lock(b->lock);
	spin_lock(b->lock);	spin_lock(a->lock);

bad.

	CPU0:			CPU1:

	spin_lock(global_lock)	spin_lock(global_lock);
	spin_lock(a->lock);	spin_lock(b->lock);
	spin_lock(b->lock);	spin_lock(a->lock);

Is OK.


	CPU0:			CPU1:

	spin_lock(global_lock)	
	spin_lock(a->lock);	spin_lock(b->lock);
	spin_lock(b->lock);	spin_unlock(b->lock);
				spin_lock(a->lock);
				spin_unlock(a->lock);

also OK.

As long as all code paths which can take two-or-more locks are all covered
by the global lock there is no deadlock scenario.  If a thread takes just a
single instance of one of these locks without taking the global_lock then
there is also no deadlock.


Now, if we need to take both anon_vma->lock AND i_mmap_lock in the newly
added mm_lock() thing and we also take both those locks at the same time in
regular code, we're probably screwed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
