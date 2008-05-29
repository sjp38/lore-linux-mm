Date: Thu, 29 May 2008 05:07:45 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] hugetlb: fix lockdep error
Message-ID: <20080529030745.GG3258@wotan.suse.de>
References: <20080529015956.GC3258@wotan.suse.de> <20080528191657.ba5f283c.akpm@linux-foundation.org> <20080529022919.GD3258@wotan.suse.de> <20080528193808.6e053dac.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080528193808.6e053dac.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: agl@us.ibm.com, nacc@us.ibm.com, Linux Memory Management List <linux-mm@kvack.org>, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Wed, May 28, 2008 at 07:38:08PM -0700, Andrew Morton wrote:
> On Thu, 29 May 2008 04:29:19 +0200 Nick Piggin <npiggin@suse.de> wrote:
> 
> > Hi Andrew,
> > 
> > Can you merge this up please? It is helpful in testing to avoid lockdep
> > tripping over. I have it at the start of the multiple hugepage size
> > patchset, but it doesn't strictly belong there...
> > 
> > --
> > hugetlb: fix lockdep error
> > 
> > Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Acked-by: Adam Litke <agl@us.ibm.com>
> > Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>
> > Signed-off-by: Nick Piggin <npiggin@suse.de>
> 
> Please prefer to quote the warning/error message/trace/etc when fixing it.

OK.

Steps to reproduce: compile kernel with lockdep; run libhugetlbfs
regression test suite.

Reult:
=============================================
[ INFO: possible recursive locking detected ]
2.6.26-rc4 #30
---------------------------------------------
heap-overflow/2250 is trying to acquire lock:
 (&mm->page_table_lock){--..}, at: [<c0000000000cf2e8>] .copy_hugetlb_page_range+0x108/0x280

but task is already holding lock:
 (&mm->page_table_lock){--..}, at: [<c0000000000cf2dc>] .copy_hugetlb_page_range+0xfc/0x280

other info that might help us debug this:
3 locks held by heap-overflow/2250:
 #0:  (&mm->mmap_sem){----}, at: [<c000000000050e44>] .dup_mm+0x134/0x410
 #1:  (&mm->mmap_sem/1){--..}, at: [<c000000000050e54>] .dup_mm+0x144/0x410
 #2:  (&mm->page_table_lock){--..}, at: [<c0000000000cf2dc>] .copy_hugetlb_page_range+0xfc/0x280

stack backtrace:
Call Trace:
[c00000003b2774e0] [c000000000010ce4] .show_stack+0x74/0x1f0 (unreliable)
[c00000003b2775a0] [c0000000003f10e0] .dump_stack+0x20/0x34
[c00000003b277620] [c0000000000889bc] .__lock_acquire+0xaac/0x1080
[c00000003b277740] [c000000000089000] .lock_acquire+0x70/0xb0
[c00000003b2777d0] [c0000000003ee15c] ._spin_lock+0x4c/0x80
[c00000003b277870] [c0000000000cf2e8] .copy_hugetlb_page_range+0x108/0x280
[c00000003b277950] [c0000000000bcaa8] .copy_page_range+0x558/0x790
[c00000003b277ac0] [c000000000050fe0] .dup_mm+0x2d0/0x410
[c00000003b277ba0] [c000000000051d24] .copy_process+0xb94/0x1020
[c00000003b277ca0] [c000000000052244] .do_fork+0x94/0x310
[c00000003b277db0] [c000000000011240] .sys_clone+0x60/0x80
[c00000003b277e30] [c0000000000078c4] .ppc_clone+0x8/0xc

Fix is the same way that mm/memory.c copy_page_range does the
lockdep annotation.

 
> >  mm/hugetlb.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > Index: linux-2.6/mm/hugetlb.c
> > ===================================================================
> > --- linux-2.6.orig/mm/hugetlb.c
> > +++ linux-2.6/mm/hugetlb.c
> > @@ -785,7 +785,7 @@ int copy_hugetlb_page_range(struct mm_st
> >  			continue;
> >  
> >  		spin_lock(&dst->page_table_lock);
> > -		spin_lock(&src->page_table_lock);
> > +		spin_lock_nested(&src->page_table_lock, SINGLE_DEPTH_NESTING);
> >  		if (!huge_pte_none(huge_ptep_get(src_pte))) {
> >  			if (cow)
> >  				huge_ptep_set_wrprotect(src, addr, src_pte);
> 
> Confused.  This code has been there since October 2005.  Why are we
> only seeing lockdep warnings now?

Can't say. Haven't looked at hugetlb code or tested it much until now.
I am using a recent libhugetlbfs test suite, FWIW.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
