Subject: Re: mlock: mlocked pages are unevictable
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20081021151301.GE4980@osiris.boeblingen.de.ibm.com>
References: <200810201659.m9KGxtFC016280@hera.kernel.org>
	 <20081021151301.GE4980@osiris.boeblingen.de.ibm.com>
Content-Type: text/plain
Date: Wed, 22 Oct 2008 11:28:47 -0400
Message-Id: <1224689328.6392.19.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2008-10-21 at 17:13 +0200, Heiko Carstens wrote:
> Hi Nick,
> 
> On Mon, Oct 20, 2008 at 04:59:55PM +0000, Linux Kernel Mailing List wrote:
> > Gitweb:     http://git.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=b291f000393f5a0b679012b39d79fbc85c018233
> > Commit:     b291f000393f5a0b679012b39d79fbc85c018233
> > Author:     Nick Piggin <npiggin@suse.de>
> > AuthorDate: Sat Oct 18 20:26:44 2008 -0700
> > Committer:  Linus Torvalds <torvalds@linux-foundation.org>
> > CommitDate: Mon Oct 20 08:52:30 2008 -0700
> > 
> >     mlock: mlocked pages are unevictable
> 
> [...]
> 
> I think the following part of your patch:
> 
> > diff --git a/mm/swap.c b/mm/swap.c
> > index fee6b97..bc58c13 100644
> > --- a/mm/swap.c
> > +++ b/mm/swap.c
> > @@ -278,7 +278,7 @@ void lru_add_drain(void)
> >  	put_cpu();
> >  }
> > 
> > -#ifdef CONFIG_NUMA
> > +#if defined(CONFIG_NUMA) || defined(CONFIG_UNEVICTABLE_LRU)
> >  static void lru_add_drain_per_cpu(struct work_struct *dummy)
> >  {
> >  	lru_add_drain();
> 
> causes this (allyesconfig on s390):
> 
> [17179587.988810] =======================================================
> [17179587.988819] [ INFO: possible circular locking dependency detected ]
> [17179587.988824] 2.6.27-06509-g2515ddc-dirty #190
> [17179587.988827] -------------------------------------------------------
> [17179587.988831] multipathd/3868 is trying to acquire lock:
> [17179587.988834]  (events){--..}, at: [<0000000000157f82>] flush_work+0x42/0x124
> [17179587.988850] 
> [17179587.988851] but task is already holding lock:
> [17179587.988854]  (&mm->mmap_sem){----}, at: [<00000000001c0be4>] sys_mlockall+0x5c/0xe0
> [17179587.988865] 
> [17179587.988866] which lock already depends on the new lock.
> [17179587.988867] 
<snip>
> [17179587.989148] other info that might help us debug this:
> [17179587.989149] 
> [17179587.989154] 1 lock held by multipathd/3868:
> [17179587.989156]  #0:  (&mm->mmap_sem){----}, at: [<00000000001c0be4>] sys_mlockall+0x5c/0xe0
> [17179587.989165] 
> [17179587.989166] stack backtrace:
> [17179587.989170] CPU: 0 Not tainted 2.6.27-06509-g2515ddc-dirty #190
> [17179587.989174] Process multipathd (pid: 3868, task: 000000003978a298, ksp: 0000000039b23eb8)
> [17179587.989178] 000000003978aa00 0000000039b238b8 0000000000000002 0000000000000000 
> [17179587.989184]        0000000039b23958 0000000039b238d0 0000000039b238d0 00000000001060ee 
> [17179587.989192]        0000000000000003 0000000000000000 0000000000000000 000000000000000b 
> [17179587.989199]        0000000000000060 0000000000000008 0000000039b238b8 0000000039b23928 
> [17179587.989207]        0000000000b30b50 00000000001060ee 0000000039b238b8 0000000039b23910 
> [17179587.989216] Call Trace:
> [17179587.989219] ([<0000000000106036>] show_trace+0xb2/0xd0)
> [17179587.989225]  [<000000000010610c>] show_stack+0xb8/0xc8
> [17179587.989230]  [<0000000000b27a96>] dump_stack+0xae/0xbc
> [17179587.989234]  [<000000000017019e>] print_circular_bug_tail+0xee/0x100
> [17179587.989240]  [<00000000001716ca>] __lock_acquire+0x10c6/0x17c4
> [17179587.989245]  [<0000000000171e5c>] lock_acquire+0x94/0xbc
> [17179587.989250]  [<0000000000157fb4>] flush_work+0x74/0x124
> [17179587.989256]  [<0000000000158620>] schedule_on_each_cpu+0xec/0x138
> [17179587.989261]  [<00000000001b0ab4>] lru_add_drain_all+0x2c/0x40
> [17179587.989266]  [<00000000001c05ac>] __mlock_vma_pages_range+0xcc/0x2e8
> [17179587.989271]  [<00000000001c0970>] mlock_fixup+0x1a8/0x280
> [17179587.989276]  [<00000000001c0aec>] do_mlockall+0xa4/0xd4
> [17179587.989281]  [<00000000001c0c36>] sys_mlockall+0xae/0xe0
> [17179587.989286]  [<0000000000114d30>] sysc_noemu+0x10/0x16
> [17179587.989290]  [<000002000025a466>] 0x2000025a466
> [17179587.989294] INFO: lockdep is turned off.


We could probably remove the lru_add_drain_all() called from
__mlock_vma_pages_range(), or replace it with a local lru_add_drain().
It's only there to push pages that might still be in the lru pagevecs
out to the lru lists so that we can isolate them and move them to the
the unevictable list.  The local lru_drain() should push any pages
faulted in by the immediately prior call to get_user_pages().  The only
pages we'd miss would be pages [recently?] faulted on another processor
and still in that pagevec.  So, we'll have a page marked as mlocked on a
normal lru list.  If/when vmscan sees it, it will immediately move it to
the unevictable lru list.

The call to lru_add_drain_all() from __clear_page_mlock() may be more
difficult.  Rik added that during testing because we found race
conditions--during COW in the fault path, IIRC--where we would strand an
mlocked page on the unevictable list.  It's an unlikely situation, I
think.  We were beating on COWing of mlocked pages--mlockall(); fork();
child attempts write to shared anon page, mlocked by parent;
munlockall()/exit() from parent--pretty heavily at the time.

Lee


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
