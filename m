Date: Sun, 1 Jun 2003 13:00:56 -0700
From: "Paul E. McKenney" <paulmck@us.ibm.com>
Subject: Re: Always passing mm and vma down (was: [RFC][PATCH] Convert do_no_page() to a hook to avoid DFS race)
Message-ID: <20030601200056.GA1471@us.ibm.com>
Reply-To: paulmck@us.ibm.com
References: <20030530164150.A26766@us.ibm.com> <20030531104617.J672@nightmaster.csn.tu-chemnitz.de> <20030531234816.GB1408@us.ibm.com> <20030601122200.GB1455@x30.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030601122200.GB1455@x30.local>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@digeo.com
List-ID: <linux-mm.kvack.org>

On Sun, Jun 01, 2003 at 02:22:00PM +0200, Andrea Arcangeli wrote:
> Hi Paul,

Hello, Andrea!

> On Sat, May 31, 2003 at 04:48:16PM -0700, Paul E. McKenney wrote:
[ . . . ]
> > Interesting point.  The original do_no_page() API does this
> > as well:
> > 
> > 	static int
> > 	do_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
> > 		   unsigned long address, int write_access, pte_t *page_table, pmd_t *pmd)
> > 
> > As does do_anonymous_page().  I assumed that there were corner
> > cases where this one-to-one correspondence did not exist, but
> > must confess that I did not go looking for them.
> > 
> > Or is this a performance issue, avoiding a dereference and
> > possible cache miss?
> 
> it's a performance microoptimization issue (the stack memory overhead is
> not significant), each new parameter to those calls will slowdown the
> kernel, especially with the x86 calling convetions it will hurt more
> than with other archs.  Jeff did something similar for UML (dunno if he
> also can use vma->vm_mm, anyways I #ifdeffed it out enterely for non UML
> compiles for exact this reason that I can't slowdown the whole
> production host kernel just for the uml compile) then there's also the
> additional extern call. So basically the patch would hurt until there
> are active users.
> 
> But the real question here I guess is: why should a distributed
> filesystem need to install the pte by itself?

The immediate motivation is to avoid the race with zap_page_range()
when another node writes to the corresponding portion of the file,
similar to the situation with vmtruncate().  The thought was to
leverage locking within the distributed filesystem, but if the
race is solved locally, then, as you say, perhaps this is not 
necessary.

> The memory coherency with distributed shared memory (i.e. MAP_SHARED
> against truncate with MAP_SHARED and truncate running on different boxes
> on a DFS) is a generic problem (most of the time using the same
> algorithm too), as such  I believe the infrastructure and logics to keep
> it coherent could make sense to be a common code functionalty.

This sounds good to me, though am checking with some DFS people.

> And w/o proper high level locking, the non distributed filesystems will
> corrupt the VM too with truncate against nopage. I already fixed this in
> my tree. (see the attachment) So I wonder if the fixes could be shared.
> I mean, you definitely need my fixes even when using the DFS on a
> isolated box, and if you don't need them while using the fs locally, it
> means we're duplicating effort somehow.

True -- my patches simply provided hooks to allow DFSs and local
filesystems to fix the problem.  

So, the idea is for the DFS to hold a fr_write_lock on the
truncate_lock across the invalidate_mmap_range() call, thus
preventing the PTEs from any racing pagefaults from being
installed?  This seems plausible at first glance, but need
to stare at it some more.  This might permit the current
do_no_page(), do_anonymous_page(), and ->nopage APIs to
be used, but again, need to stare at it some more.

(If I am not too confused, fr_write_lock() became
write_seqlock() in the 2.5 tree...)

> Since I don't see the users of the new hook, it's a bit hard to judje if
> the duplication is legitimate or not. So overall I'd agree with Andrew
> that to judje the patch it'd make sense to see (or know more) about the
> users of the hook too.

A simple change that takes care of all the cases certainly does
seem better than a more complex change that only takes care of
distributed filesystems!

> as for the anon memory, yes, it's probably more efficient and cleaner to
> have it be a nopage callback too, the double branch is probably more
> costly than the duplicated unlock anyways. However it has nothing to do
> with these issues, so I recommend to keep it separated from the DFS
> patches (for readibility). (it can't have anything to do with DFS since
> that memory is anon local to the box [if not using openmosix but that's
> a different issue ;) ])

Well, we do seem to have a number of ways of attacking the problem,
so I have hope that one of them will do the trick.  ;-)

						Thanx, Paul
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
