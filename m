Subject: Re: [Experimental][PATCH] putback_lru_page rework
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080619092242.79648592.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org>
	 <20080617163501.7cf411ee.nishimura@mxp.nes.nec.co.jp>
	 <20080617164709.de4db070.nishimura@mxp.nes.nec.co.jp>
	 <20080618184000.a855dfe0.kamezawa.hiroyu@jp.fujitsu.com>
	 <1213813266.6497.14.camel@lts-notebook>
	 <20080619092242.79648592.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Thu, 19 Jun 2008 10:45:22 -0400
Message-Id: <1213886722.6398.29.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2008-06-19 at 09:22 +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 18 Jun 2008 14:21:06 -0400
> Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> 
> > On Wed, 2008-06-18 at 18:40 +0900, KAMEZAWA Hiroyuki wrote:
> > > Lee-san, how about this ?
> > > Tested on x86-64 and tried Nisimura-san's test at el. works good now.
> > 
> > I have been testing with my work load on both ia64 and x86_64 and it
> > seems to be working well.  I'll let them run for a day or so.
> > 
> thank you.
> <snip>

Update:

On x86_64 [32GB, 4xdual-core Opteron], my work load has run for ~20:40
hours.  Still running.

On ia64 [32G, 16cpu, 4 node], the system started going into softlockup
after ~7 hours.  Stack trace [below] indicates zone-lru lock in
__page_cache_release() called from put_page().  Either heavy contention
or failure to unlock.  Note that previous run, with patches to
putback_lru_page() and unmap_and_move(), the same load ran for ~18 hours
before I shut it down to try these patches.

I'm going to try again with the collected patches posted by Kosaki-san
[for which, Thanks!].  If it occurs again, I'll deconfig the unevictable
lru feature and see if I can reproduce it there.  It may be unrelated to
the unevictable lru patches.

> 
> > > @@ -240,6 +232,9 @@ static int __munlock_pte_handler(pte_t *
> > >  	struct page *page;
> > >  	pte_t pte;
> > >  
> > > +	/*
> > > +	 * page is never be unmapped by page-reclaim. we lock this page now.
> > > +	 */
> > 
> > I don't understand what you're trying to say here.  That is, what the
> > point of this comment is...
> > 
> We access the page-table without taking pte_lock. But this vm is MLOCKED
> and migration-race is handled. So we don't need to be too nervous to access
> the pte. I'll consider more meaningful words.

OK, so you just want to note that we're accessing the pte w/o locking
and that this is safe because the vma has been VM_LOCKED and all pages
should be mlocked?  

I'll note that the vma is NOT VM_LOCKED during the pte walk.
munlock_vma_pages_range() resets it so that try_to_unlock(), called from
munlock_vma_page(), won't try to re-mlock the page.  However, we hold
the mmap sem for write, so faults are held off--no need to worry about a
COW fault occurring between when the VM_LOCKED was cleared and before
the page is munlocked.  If that could occur, it could open a window
where a non-mlocked page is mapped in this vma, and page reclaim could
potentially unmap the page.  Shouldn't be an issue as long as we never
downgrade the semaphore to read during munlock.

Lee

----------
softlockup stack trace for "usex" workload on ia64:

BUG: soft lockup - CPU#13 stuck for 61s! [usex:124359]
Modules linked in: ipv6 sunrpc dm_mirror dm_log dm_multipath scsi_dh dm_mod pci_slot fan dock thermal sg sr_mod processor button container ehci_hcd ohci_hcd uhci_hcd usbcore

Pid: 124359, CPU 13, comm:                 usex
psr : 00001010085a6010 ifs : 8000000000000000 ip  : [<a00000010000a1a0>]    Tainted: G      D   (2.6.26-rc5-mm3-kame-rework+mcl_inherit)
ip is at ia64_spinlock_contention+0x20/0x60
unat: 0000000000000000 pfs : 0000000000000081 rsc : 0000000000000003
rnat: 0000000000000000 bsps: 0000000000000000 pr  : a65955959a96e969
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a0000001001264a0 b6  : a0000001006f0350 b7  : a00000010000b940
f6  : 0ffff8000000000000000 f7  : 1003ecf3cf3cf3cf3cf3d
f8  : 1003e0000000000000001 f9  : 1003e0000000000000015
f10 : 1003e000003a82aaab1fb f11 : 1003e0000000000000000
r1  : a000000100c03650 r2  : 000000000000038a r3  : 0000000000000001
r8  : 00000010085a6010 r9  : 0000000000080028 r10 : 000000000000000b
r11 : 0000000000000a80 r12 : e0000741aaac7d50 r13 : e0000741aaac0000
r14 : 0000000000000000 r15 : a000400741329148 r16 : e000074000060100
r17 : e000076000078e98 r18 : 0000000000000015 r19 : 0000000000000018
r20 : 0000000000000003 r21 : 0000000000000002 r22 : e000076000078e88
r23 : e000076000078e80 r24 : 0000000000000001 r25 : 0240000000080028
r26 : ffffffffffff04d8 r27 : 00000010085a6010 r28 : 7fe3382473f8b380
r29 : 9c00000000000000 r30 : 0000000000000001 r31 : e000074000061400

Call Trace:
 [<a000000100015e00>] show_stack+0x80/0xa0
                                sp=e0000741aaac79b0 bsp=e0000741aaac1528
 [<a000000100016700>] show_regs+0x880/0x8c0
                                sp=e0000741aaac7b80 bsp=e0000741aaac14d0
 [<a0000001000fbbe0>] softlockup_tick+0x2e0/0x340
                                sp=e0000741aaac7b80 bsp=e0000741aaac1480
 [<a0000001000a9400>] run_local_timers+0x40/0x60
                                sp=e0000741aaac7b80 bsp=e0000741aaac1468
 [<a0000001000a9460>] update_process_times+0x40/0xc0
                                sp=e0000741aaac7b80 bsp=e0000741aaac1438
 [<a00000010003ded0>] timer_interrupt+0x1b0/0x4a0
                                sp=e0000741aaac7b80 bsp=e0000741aaac13d0
 [<a0000001000fc480>] handle_IRQ_event+0x80/0x120
                                sp=e0000741aaac7b80 bsp=e0000741aaac1398
 [<a0000001000fc660>] __do_IRQ+0x140/0x440
                                sp=e0000741aaac7b80 bsp=e0000741aaac1338
 [<a0000001000136d0>] ia64_handle_irq+0x3f0/0x420
                                sp=e0000741aaac7b80 bsp=e0000741aaac12c0
 [<a00000010000c120>] ia64_native_leave_kernel+0x0/0x270
                                sp=e0000741aaac7b80 bsp=e0000741aaac12c0
 [<a00000010000a1a0>] ia64_spinlock_contention+0x20/0x60
                                sp=e0000741aaac7d50 bsp=e0000741aaac12c0
 [<a0000001006f0350>] _spin_lock_irqsave+0x50/0x60
                                sp=e0000741aaac7d50 bsp=e0000741aaac12b8

Probably zone lru_lock in __page_cache_release().

 [<a0000001001264a0>] put_page+0x100/0x300
                                sp=e0000741aaac7d50 bsp=e0000741aaac1280
 [<a000000100157170>] free_page_and_swap_cache+0x70/0xe0
                                sp=e0000741aaac7d50 bsp=e0000741aaac1260
 [<a000000100145a10>] exit_mmap+0x3b0/0x580
                                sp=e0000741aaac7d50 bsp=e0000741aaac1210
 [<a00000010008b420>] mmput+0x80/0x1c0
                                sp=e0000741aaac7e10 bsp=e0000741aaac11d8

NOTE:  all cpus show similar stack traces above here.  Some, however, get
here from do_exit()/exit_mm(), rather than via execve().

 [<a00000010019c2c0>] flush_old_exec+0x5a0/0x1520
                                sp=e0000741aaac7e10 bsp=e0000741aaac10f0
 [<a000000100213080>] load_elf_binary+0x7e0/0x2600
                                sp=e0000741aaac7e20 bsp=e0000741aaac0fb8
 [<a00000010019b7a0>] search_binary_handler+0x1a0/0x520
                                sp=e0000741aaac7e20 bsp=e0000741aaac0f30
 [<a00000010019e4e0>] do_execve+0x320/0x3e0
                                sp=e0000741aaac7e20 bsp=e0000741aaac0ed0
 [<a000000100014d00>] sys_execve+0x60/0xc0
                                sp=e0000741aaac7e30 bsp=e0000741aaac0e98
 [<a00000010000b690>] ia64_execve+0x30/0x140
                                sp=e0000741aaac7e30 bsp=e0000741aaac0e48
 [<a00000010000bfa0>] ia64_ret_from_syscall+0x0/0x20
                                sp=e0000741aaac7e30 bsp=e0000741aaac0e48
 [<a000000000010720>] __start_ivt_text+0xffffffff00010720/0x400
                                sp=e0000741aaac8000 bsp=e0000741aaac0e48



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
