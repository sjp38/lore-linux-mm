Subject: Re: [PATCH/RFC 2/14] Reclaim Scalability:  convert inode
	i_mmap_lock to reader/writer lock
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070920012441.GQ4608@v2.random>
References: <20070914205359.6536.98017.sendpatchset@localhost>
	 <20070914205412.6536.34898.sendpatchset@localhost>
	 <20070920012441.GQ4608@v2.random>
Content-Type: text/plain
Date: Thu, 20 Sep 2007 10:10:48 -0400
Message-Id: <1190297448.5326.8.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, riel@redhat.com, balbir@linux.vnet.ibm.com, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Thu, 2007-09-20 at 03:24 +0200, Andrea Arcangeli wrote:
> On Fri, Sep 14, 2007 at 04:54:12PM -0400, Lee Schermerhorn wrote:
> > Note:  This patch is meant to address a situation I've seen
> > running large Oracle OLTP workload--1000s of users--on an
> > large HP ia64 NUMA platform.  The system hung, spitting out
> > "soft lockup" messages on the console.  Stack traces showed
> > that all cpus were in page_referenced(), as mentioned above.
> > I let the system run overnight in this state--it never
> > recovered before I decided to reboot.
> 
> Just to understand better, was that an oom condition? Can you press
> SYSRQ+M to check the RAM and swap levels? If it's an oom condition the
> problem may be quite different.

Actually, the system never went OOM.  Didn't get that far.  I was trying
to create an Oracle workload that would put me at the brink of reclaim,
and then by running some app that would eat page cache, push it over the
edge.  But, I apparently went too far--too many Oracle users for this
system--and it went into reclaim, got hung up with all cpus spinning on
the i_mmap_lock in page_referenced_file().

I just got this system back for testing.  Soon as I build a 23-rc6-mm1
kernel for it, I'll retest that with the same workload to demonstrate
the problem.  Then I'll try it with the rw_lock patch to see if that
helps.

> 
> Still making those spinlocks rw sounds good to me.

Well, except for the concern about the extra overhead of rw_locks.  I'm
more worried about this for the i_mmap_lock than the anon_vma lock.  The
only time we need to take the anon_vma lock for write is when adding a
new vma to the list, or removing one [vma_link(), et al].  But, the
i_mmap_lock is also used to protect the truncate_count, and must be
taken for write there.  I expected that a kernel build might show
something with all the forks for parallel make, mapping of libc, cc
executable, ...  but nothing.  

Thanks,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
