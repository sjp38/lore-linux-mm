Subject: Re: [PATCH/RFC 1/8] Mem Policy: Write lock mmap_sem while changing
	task mempolicy
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <200712062224.58812.ak@suse.de>
References: <20071206212047.6279.10881.sendpatchset@localhost>
	 <20071206212053.6279.27183.sendpatchset@localhost>
	 <200712062224.58812.ak@suse.de>
Content-Type: text/plain
Date: Thu, 06 Dec 2007 16:34:28 -0500
Message-Id: <1196976868.5293.56.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mel@skynet.ie, eric.whitney@hp.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 2007-12-06 at 22:24 +0100, Andi Kleen wrote:
> On Thursday 06 December 2007 22:20:53 Lee Schermerhorn wrote:
> > PATCH/RFC 01/08 Mem Policy: Write lock mmap_sem while changing task mempolicy
> > 
> > Against:  2.6.24-rc2-mm1
> > 
> > A read of /proc/<pid>/numa_maps holds the target task's mmap_sem
> > for read while examining each vma's mempolicy.  A vma's mempolicy
> > can fall back to the task's policy.  However, the task could be
> > changing it's task policy and free the one that the show_numa_maps()
> > is examining.
> 
> But do_set_mempolicy doesn't actually modify the mempolicy. It just
> replaces it using essentially Copy-on-write. 
> 
> If the numa_maps holds a proper reference count (I haven't 
> checked if it does) it can keep the old unmodified one as long as it wants.
> 
> I don't think a write lock is needed.

Hi, Andi.

You are correct.  But Christoph wants to avoid as many cases for having
to increment the reference count as possible and to simplify/eliminate
the tests of whether the increment/decrement is required.  numa_maps
isn't a performance path, but it uses get_vma_policy()--same as used by
page allocation.  If you look at patch 5, you'll see that I've
eliminated all extra references in this path, except the one taken by
shared policy lookup.  The new 'mpol_cond_free()' [and
mpol_need_cond_unref() helper--used in alloc_page_vma() "slow path"]
only trigger for shared policy now.  This is a single test of the
mempolicy mode [formerly policy] member that should be cache hot, if not
actually in a register.

This was what Christoph was trying to achieve, I think.

Lee


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
