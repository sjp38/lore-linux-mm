Date: Fri, 04 Jul 2008 14:40:29 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [-mm] BUG: sleeping function called from invalid context at include/linux/pagemap.h:290
In-Reply-To: <Pine.LNX.4.64.0807031747470.14783@blonde.site>
References: <486C9FBD.9000800@cn.fujitsu.com> <Pine.LNX.4.64.0807031747470.14783@blonde.site>
Message-Id: <20080704091349.BAA2.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, npiggin@suse.de, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik Van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> > > Could you explain detail of reproduce way?
> > 
> > Nothing special. I booted the system up, and entered KDE, and opened xterm,
> > and typed "dmesg".
> > 
> > .config attached.
> 
> The reason you're seeing it and others not is because your
> CONFIG_HIGHPTE=y
> is making the issue visible.
> 
> __munlock_pte_handler is trying to lock_page (or migration_entry_wait)
> while using the per-cpu kmap_atomic from walk_pte_range's pte_offset_map.
> Sleeping functions called from atomic context.
> 
> There's quite a lot to worry about there.

Wow, this is obiously bug ;-)
IMHO, CONFIG_UNEVICTABLE was developed aiming at 64bit. (had depend on 64BIT ago)
So, noboy tested it long time on 32bit.

Yes, it is definitly bad.
I'll fix soon (hopefully).


> That page table walker was originally written to gather some info
> for /proc display, not to act upon the page table contents in any
> serious way.  So it's just doing pte_offset_map when every(?) other
> page table walk would be required to pte_offset_map_lock.  If it
> were doing pte_offset_map_lock, then lots more people would have
> seen the problem sooner.
> 
> Does this usage need to pte_offset_map_lock?  I think to the extent
> that it needs to lock_page, it needs to pte_offset_map_lock: both
> are because file truncation (or more commonly reclaim, but without
> looking into it too carefully, I dare say reclaim isn't a problem
> in this context) could interfere with page->mapping and pte at any
> instant.
> 
> Conveniently, we have not one but two attempts at a generic page
> walker (sigh!): the other one, apply_to_page_range in mm/memory.c,
> does do the lock; it also allocates a page table if it's not there,
> I guess that aspect wouldn't be a problem on an mlocked area.  Maybe
> using apply_to_page_range would be better here, and sidestep the
> issue of not having CONFIG_PAGE_WALKER.
> 
> But if it does pte_offset_map_lock, look, migration_entry_wait does
> so too; well, never mind the lock, it'll kunmap_atomic 
> Obviously that part cries out for refactoring.
> 
> And how do you manage the lock_page?  Offhand, I don't know, I'm
> just reporting on the obvious.  Would trylocking be good enough?
> 
> (I do dislike "generic page walkers" because they encourage this
> kind of oversight; and I hate to think of the latency problems
> they might be introducing - no sign of a cond_resched in either.)

Thank you great explain.
but we can't use trylock because munlock should turn off PAGE_MLOCK at that time.

__munlock_pte_handler introduced for avoid PROT_NONE problem.
(get_user_pages() can't get PROT_NONE page, old implementation can't munlock PROT_NONE page)

So, We had 2 choice
  1. enhance get_use_pages()
  2. use pagewalk

current implementation select 2.
Unfortunately this is problematic choice.
Now, We have problem on CONFIG_HIGHPTE and !CONFIG_MMU environment.

So, I am gradually charmed by choice 1.
my fix plan is below

1. CONFIG_UNEVICTABLE depend on 64BIT (just temporary hotfix)
2. add vm_flags ignoring option to get_user_pages()
3. rewrite __munlock_vma_pages_range by new get_user_pages()
4. revert 1
5. revert pagewalker's Kconfig change (someone dislike "select" expression)


and Step1 patch is attached below.
this patch solve this problem temporary.

Li-san, Could you try to below patch on your environment?


----------------------
pagewalk use pte_offset_map().
pte_offset_map() use kmap_atomic().
__munlock_pte_handler() use lock_page().

So, in CONFIG_HIGHPTE=y, following error happend.


BUG: sleeping function called from invalid context at include/linux/pagemap.h:290
in_atomic():1, irqs_disabled():0
no locks held by gpg-agent/2134.
Pid: 2134, comm: gpg-agent Not tainted 2.6.26-rc8-mm1 #11
 [<c0421d38>] __might_sleep+0xbe/0xc5
 [<c04770a2>] __munlock_pte_handler+0x3c/0x9e
 [<c047c11f>] walk_page_range+0x15b/0x1b4
 [<c0477048>] __munlock_vma_pages_range+0x4e/0x5b
 [<c0476f0c>] ? __munlock_pmd_handler+0x0/0x10
 [<c0477066>] ? __munlock_pte_handler+0x0/0x9e
 [<c0477064>] munlock_vma_pages_range+0xf/0x11
 [<c0477dcb>] exit_mmap+0x32/0xf2
 [<c042ac12>] ? exit_mm+0xc7/0xda
 [<c042732a>] mmput+0x3a/0x8b
 [<c042ac20>] exit_mm+0xd5/0xda
 [<c042bf6a>] do_exit+0x1fb/0x5d5
 [<c045c4df>] ? audit_syscall_exit+0x2aa/0x2c5
 [<c042c3a3>] do_group_exit+0x5f/0x88
 [<c042c3db>] sys_exit_group+0xf/0x11
 [<c0403956>] syscall_call+0x7/0xb

then, this feature should be disabled on 32BIT until fixed above problem.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 mm/Kconfig |    1 +
 1 file changed, 1 insertion(+)

Index: b/mm/Kconfig
===================================================================
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -216,6 +216,7 @@ config PAGE_WALKER
 config UNEVICTABLE_LRU
 	bool "Add LRU list to track non-evictable pages"
 	default y
+	depends on 64BIT
 	select PAGE_WALKER
 	help
 	  Keeps unevictable pages off of the active and inactive pageout


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
