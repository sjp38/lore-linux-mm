Date: Thu, 20 Sep 2007 16:16:16 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH/RFC 2/14] Reclaim Scalability:  convert inode
	i_mmap_lock to reader/writer lock
Message-ID: <20070920141616.GV4608@v2.random>
References: <20070914205359.6536.98017.sendpatchset@localhost> <20070914205412.6536.34898.sendpatchset@localhost> <20070920012441.GQ4608@v2.random> <1190297448.5326.8.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1190297448.5326.8.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, riel@redhat.com, balbir@linux.vnet.ibm.com, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Thu, Sep 20, 2007 at 10:10:48AM -0400, Lee Schermerhorn wrote:
> Actually, the system never went OOM.  Didn't get that far.  I was trying
> to create an Oracle workload that would put me at the brink of reclaim,
> and then by running some app that would eat page cache, push it over the
> edge.  But, I apparently went too far--too many Oracle users for this
> system--and it went into reclaim, got hung up with all cpus spinning on
> the i_mmap_lock in page_referenced_file().
> 
> I just got this system back for testing.  Soon as I build a 23-rc6-mm1
> kernel for it, I'll retest that with the same workload to demonstrate
> the problem.  Then I'll try it with the rw_lock patch to see if that
> helps.

Ok, I guess it's a numa scalability issue. All pages belongs to that
file... and they all trash on the same spinlock. So I doubt the
rw_lock will help much, the trashing where most time is probably spent
should be the same. the rw_lock still looks a good idea, for smaller
systems with faster interconnects like dualcore ;)

> Well, except for the concern about the extra overhead of rw_locks.  I'm
> more worried about this for the i_mmap_lock than the anon_vma lock.  The
> only time we need to take the anon_vma lock for write is when adding a
> new vma to the list, or removing one [vma_link(), et al].  But, the
> i_mmap_lock is also used to protect the truncate_count, and must be
> taken for write there.  I expected that a kernel build might show
> something with all the forks for parallel make, mapping of libc, cc
> executable, ...  but nothing.  

You mean it's not actually slower? Well I doubt a few instructions
more counts these days, the major hit is the cacheline miss and
that'll be the same for rwlock or spinlock... (which is why it
probably won't help much on systems with tons of cpus and where
cacheline bouncing trashes so badly). Ironically I think it's more an
optimization for small smp with lots of ram, than big smp/numa.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
