Date: Thu, 17 Apr 2008 12:25:56 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 1 of 9] Lock the entire mm to prevent any mmu related
	operation to happen
Message-ID: <20080417172556.GF11364@sgi.com>
References: <patchbomb.1207669443@duo.random> <ec6d8f91b299cf26cce5.1207669444@duo.random> <20080416163337.GJ22493@sgi.com> <Pine.LNX.4.64.0804161134360.12296@schroedinger.engr.sgi.com> <20080417155157.GC17187@duo.random> <20080417163642.GE11364@sgi.com> <20080417171443.GM17187@duo.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080417171443.GM17187@duo.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 17, 2008 at 07:14:43PM +0200, Andrea Arcangeli wrote:
> On Thu, Apr 17, 2008 at 11:36:42AM -0500, Robin Holt wrote:
> > In this case, we are not making the call to unregister, we are waiting
> > for the _release callout which has already removed it from the list.
> > 
> > In the event that the user has removed all the grants, we use unregister.
> > That typically does not occur.  We merely wait for exit processing to
> > clean up the structures.
> 
> Then it's very strange. LIST_POISON1 is set in n->next. If it was a
> second hlist_del triggering the bug in theory list_poison2 should
> trigger first, so perhaps it's really a notifier running despite a
> mm_lock is taken? Could you post a full stack trace so I can see who's
> running into LIST_POISON1? If it's really a notifier running outside
> of some mm_lock that will be _immediately_ visible from the stack
> trace that triggered the LIST_POISON1!
> 
> Also note, EMM isn't using the clean hlist_del, it's implementing list
> by hand (with zero runtime gain) so all the debugging may not be
> existent in EMM, so if it's really a mm_lock race, and it only
> triggers with mmu notifiers and not with EMM, it doesn't necessarily
> mean EMM is bug free. If you've a full stack trace it would greatly
> help to verify what is mangling over the list when the oops triggers.

The stack trace is below.  I did not do this level of testing on emm so
I can not compare the two in this area.

This is for a different, but equivalent failure.  I just reproduce the
LIST_POISON1 failure without trying to reproduce the exact same failure
as I had documented earlier (lost that stack trace, sorry).

Thanks,
Robin


<1>Unable to handle kernel paging request at virtual address 0000000000100100
<4>mpi006.f.x[23403]: Oops 11012296146944 [1]
<4>Modules linked in: nfs lockd sunrpc binfmt_misc thermal processor fan button loop md_mod dm_mod xpmem xp mspec sg
<4>
<4>Pid: 23403, CPU 114, comm:           mpi006.f.x
<4>psr : 0000121008526010 ifs : 800000000000038b ip  : [<a00000010015d6a1>]    Not tainted (2.6.25-rc8)
<4>ip is at __mmu_notifier_invalidate_range_start+0x81/0x120
<4>unat: 0000000000000000 pfs : 000000000000038b rsc : 0000000000000003
<4>rnat: a000000100149a00 bsps: a000000000010740 pr  : 66555666a9599aa9
<4>ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c0270033f
<4>csd : 0000000000000000 ssd : 0000000000000000
<4>b0  : a00000010015d670 b6  : a0000002101ddb40 b7  : a00000010000eb50
<4>f6  : 1003e2222222222222222 f7  : 000000000000000000000
<4>f8  : 000000000000000000000 f9  : 000000000000000000000
<4>f10 : 000000000000000000000 f11 : 000000000000000000000
<4>r1  : a000000100ef1190 r2  : e0000e6080cc1940 r3  : a0000002101edd10
<4>r8  : e0000e6080cc1970 r9  : 0000000000000000 r10 : e0000e6080cc19c8
<4>r11 : 20000003a6480000 r12 : e0000c60d31efb90 r13 : e0000c60d31e0000
<4>r14 : 000000000000004d r15 : e0000e6080cc1914 r16 : e0000e6080cc1970
<4>r17 : 20000003a6480000 r18 : 20000007bf900000 r19 : 0000000000040000
<4>r20 : e0000c60d31e0000 r21 : 0000000000000010 r22 : e0000e6080cc19a8
<4>r23 : e0000c60c55f1120 r24 : e0000c60d31efda0 r25 : e0000c60d31efd98
<4>r26 : e0000e60812166d0 r27 : e0000c60d31efdc0 r28 : e0000c60d31efdb8
<4>r29 : e0000c60d31e0b60 r30 : 0000000000000000 r31 : 0000000000000081
<4>
<4>Call Trace:
<4> [<a000000100014a20>] show_stack+0x40/0xa0
<4>                                sp=e0000c60d31ef760 bsp=e0000c60d31e11f0
<4> [<a000000100015330>] show_regs+0x850/0x8a0
<4>                                sp=e0000c60d31ef930 bsp=e0000c60d31e1198
<4> [<a000000100035ed0>] die+0x1b0/0x2e0
<4>                                sp=e0000c60d31ef930 bsp=e0000c60d31e1150
<4> [<a000000100060e90>] ia64_do_page_fault+0x8d0/0xa40
<4>                                sp=e0000c60d31ef930 bsp=e0000c60d31e1100
<4> [<a00000010000ab00>] ia64_leave_kernel+0x0/0x270
<4>                                sp=e0000c60d31ef9c0 bsp=e0000c60d31e1100
<4> [<a00000010015d6a0>] __mmu_notifier_invalidate_range_start+0x80/0x120
<4>                                sp=e0000c60d31efb90 bsp=e0000c60d31e10a8
<4> [<a00000010011b1d0>] unmap_vmas+0x70/0x14c0
<4>                                sp=e0000c60d31efb90 bsp=e0000c60d31e0fa8
<4> [<a00000010011c660>] zap_page_range+0x40/0x60
<4>                                sp=e0000c60d31efda0 bsp=e0000c60d31e0f70
<4> [<a0000002101d62d0>] xpmem_clear_PTEs+0x350/0x560 [xpmem]
<4>                                sp=e0000c60d31efdb0 bsp=e0000c60d31e0ef0
<4> [<a0000002101d1e30>] xpmem_remove_seg+0x3f0/0x700 [xpmem]
<4>                                sp=e0000c60d31efde0 bsp=e0000c60d31e0ea8
<4> [<a0000002101d2500>] xpmem_remove_segs_of_tg+0x80/0x140 [xpmem]
<4>                                sp=e0000c60d31efe10 bsp=e0000c60d31e0e78
<4> [<a0000002101dda40>] xpmem_mmu_notifier_release+0x40/0x80 [xpmem]
<4>                                sp=e0000c60d31efe10 bsp=e0000c60d31e0e58
<4> [<a00000010015d7f0>] __mmu_notifier_release+0xb0/0x100
<4>                                sp=e0000c60d31efe10 bsp=e0000c60d31e0e38
<4> [<a000000100124430>] exit_mmap+0x50/0x180
<4>                                sp=e0000c60d31efe10 bsp=e0000c60d31e0e10
<4> [<a00000010008fb30>] mmput+0x70/0x180
<4>                                sp=e0000c60d31efe20 bsp=e0000c60d31e0dd8
<4> [<a000000100098df0>] exit_mm+0x1f0/0x220
<4>                                sp=e0000c60d31efe20 bsp=e0000c60d31e0da0
<4> [<a00000010009ca60>] do_exit+0x4e0/0xf40
<4>                                sp=e0000c60d31efe20 bsp=e0000c60d31e0d58
<4> [<a00000010009d640>] do_group_exit+0x180/0x1c0
<4>                                sp=e0000c60d31efe30 bsp=e0000c60d31e0d20
<4> [<a00000010009d6a0>] sys_exit_group+0x20/0x40
<4>                                sp=e0000c60d31efe30 bsp=e0000c60d31e0cc8
<4> [<a00000010000a960>] ia64_ret_from_syscall+0x0/0x20
<4>                                sp=e0000c60d31efe30 bsp=e0000c60d31e0cc8
<4> [<a000000000010720>] __kernel_syscall_via_break+0x0/0x20
<4>                                sp=e0000c60d31f0000 bsp=e0000c60d31e0cc8

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
