Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3F22A6B008A
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 17:21:09 -0500 (EST)
Date: Mon, 13 Dec 2010 14:20:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: kernel BUG at mm/truncate.c:475!
Message-Id: <20101213142059.643f8080.akpm@linux-foundation.org>
In-Reply-To: <E1PRQDn-0007jZ-5S@pomaz-ex.szeredi.hu>
References: <20101130194945.58962c44@xenia.leun.net>
	<alpine.LSU.2.00.1011301453090.12516@tigran.mtv.corp.google.com>
	<E1PNjsI-0005Bk-NB@pomaz-ex.szeredi.hu>
	<20101201124528.6809c539@xenia.leun.net>
	<E1PNqO1-0005px-9h@pomaz-ex.szeredi.hu>
	<20101202084159.6bff7355@xenia.leun.net>
	<20101202091552.4a63f717@xenia.leun.net>
	<E1PO5gh-00079U-Ma@pomaz-ex.szeredi.hu>
	<20101202115722.1c00afd5@xenia.leun.net>
	<20101203085350.55f94057@xenia.leun.net>
	<E1PPaIw-0004pW-Mk@pomaz-ex.szeredi.hu>
	<20101206204303.1de6277b@xenia.leun.net>
	<E1PRQDn-0007jZ-5S@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Michael Leun <lkml20101129@newton.leun.net>, hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 11 Dec 2010 15:14:47 +0100
Miklos Szeredi <miklos@szeredi.hu> wrote:

> On Mon, 6 Dec 2010, Michael Leun wrote:
> > At the moment I'm trying to create an easy to reproduce scenario.
> > 
> 
> I've managed to reproduce the BUG.  First I thought it has to do with
> fork() racing with invalidate_inode_pages2_range() but it turns out,
> just two parallel invocation of invalidate_inode_pages2_range() with
> some page faults going on can trigger it.
> 
> The problem is: unmap_mapping_range() is not prepared for more than
> one concurrent invocation per inode.  For example:
> 
>   thread1: going through a big range, stops in the middle of a vma and
>      stores the restart address in vm_truncate_count.
> 
>   thread2: comes in with a small (e.g. single page) unmap request on
>      the same vma, somewhere before restart_address, finds that the

"restart_addr", please.

>      vma was already unmapped up to the restart address and happily
>      returns without doing anything.
> 
> Another scenario would be two big unmap requests, both having to
> restart the unmapping and each one setting vm_truncate_count to its
> own value.  This could go on forever without any of them being able to
> finish.
> 
> Truncate and hole punching already serialize with i_mutex.  Other
> callers of unmap_mapping_range() do not, however, and I see difficulty
> with doing it in the callers.  I think the proper solution is to add
> serialization to unmap_mapping_range() itself.
> 
> Attached patch attempts to do this without adding more fields to
> struct address_space.  It fixes the bug in my testing.
> 

That's a pretty old bug, isn't it?  5+ years.

> 
> 
> ---
>  include/linux/pagemap.h |    1 +
>  mm/memory.c             |   14 ++++++++++++++
>  2 files changed, 15 insertions(+)
> 
> Index: linux.git/include/linux/pagemap.h
> ===================================================================
> --- linux.git.orig/include/linux/pagemap.h	2010-11-26 10:52:17.000000000 +0100
> +++ linux.git/include/linux/pagemap.h	2010-12-11 13:39:32.000000000 +0100
> @@ -24,6 +24,7 @@ enum mapping_flags {
>  	AS_ENOSPC	= __GFP_BITS_SHIFT + 1,	/* ENOSPC on async write */
>  	AS_MM_ALL_LOCKS	= __GFP_BITS_SHIFT + 2,	/* under mm_take_all_locks() */
>  	AS_UNEVICTABLE	= __GFP_BITS_SHIFT + 3,	/* e.g., ramdisk, SHM_LOCK */
> +	AS_UNMAPPING	= __GFP_BITS_SHIFT + 4, /* for unmap_mapping_range() */
>  };
>  
>  static inline void mapping_set_error(struct address_space *mapping, int error)
> Index: linux.git/mm/memory.c
> ===================================================================
> --- linux.git.orig/mm/memory.c	2010-12-11 13:07:28.000000000 +0100
> +++ linux.git/mm/memory.c	2010-12-11 14:09:42.000000000 +0100
> @@ -2535,6 +2535,12 @@ static inline void unmap_mapping_range_l
>  	}
>  }
>  
> +static int mapping_sleep(void *x)
> +{
> +	schedule();
> +	return 0;
> +}
> +
>  /**
>   * unmap_mapping_range - unmap the portion of all mmaps in the specified address_space corresponding to the specified page range in the underlying file.
>   * @mapping: the address space containing mmaps to be unmapped.
> @@ -2572,6 +2578,9 @@ void unmap_mapping_range(struct address_
>  		details.last_index = ULONG_MAX;
>  	details.i_mmap_lock = &mapping->i_mmap_lock;
>  
> +	wait_on_bit_lock(&mapping->flags, AS_UNMAPPING, mapping_sleep,
> +			 TASK_UNINTERRUPTIBLE);
> +
>  	spin_lock(&mapping->i_mmap_lock);
>  
>  	/* Protect against endless unmapping loops */
> @@ -2588,6 +2597,11 @@ void unmap_mapping_range(struct address_
>  	if (unlikely(!list_empty(&mapping->i_mmap_nonlinear)))
>  		unmap_mapping_range_list(&mapping->i_mmap_nonlinear, &details);
>  	spin_unlock(&mapping->i_mmap_lock);
> +
> +	clear_bit_unlock(AS_UNMAPPING, &mapping->flags);
> +	smp_mb__after_clear_bit();
> +	wake_up_bit(&mapping->flags, AS_UNMAPPING);
> +

I do think this was premature optimisation.  The open-coded lock is
hidden from lockdep so we won't find out if this introduces potential
deadlocks.  It would be better to add a new mutex at least temporarily,
then look at replacing it with a MiklosLock later on, when the code is
bedded in.

At which time, replacing mutexes with MiklosLocks becomes part of a
general "shrink the address_space" exercise in which there's no reason
to exclusively concentrate on that new mutex!


How hard is it to avoid adding a new lock and using an existing one,
presumablt i_mutex?  Because if we can get i_mutex coverage over
unmap_mapping_range() then I suspect all the
vm_truncate_count/restart_addr stuff can go away?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
