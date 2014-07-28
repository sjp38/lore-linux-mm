Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 9FB036B0035
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 06:53:28 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id b13so7065148wgh.18
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 03:53:25 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.232])
        by mx.google.com with ESMTP id ei7si12910261wid.32.2014.07.28.03.53.19
        for <linux-mm@kvack.org>;
        Mon, 28 Jul 2014 03:53:19 -0700 (PDT)
Date: Mon, 28 Jul 2014 13:52:32 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: don't allow fault_around_bytes to be 0
Message-ID: <20140728105232.GA32057@node.dhcp.inet.fi>
References: <53D07E96.5000006@oracle.com>
 <1406533400-6361-1-git-send-email-a.ryabinin@samsung.com>
 <20140728093611.GA3975@node.dhcp.inet.fi>
 <53D62599.6000605@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53D62599.6000605@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ning Qu <quning@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Dave Jones <davej@redhat.com>, stable@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Hugh Dickins <hughd@google.com>

On Mon, Jul 28, 2014 at 02:27:37PM +0400, Andrey Ryabinin wrote:
> On 07/28/14 13:36, Kirill A. Shutemov wrote:
> > On Mon, Jul 28, 2014 at 11:43:20AM +0400, Andrey Ryabinin wrote:
> >> Sasha Levin triggered use-after-free when fuzzing using trinity and the KASAN
> >> patchset:
> >>
> >> 	AddressSanitizer: use after free in do_read_fault.isra.40+0x3c2/0x510 at addr ffff88048a733110
> >> 	page:ffffea001229ccc0 count:0 mapcount:0 mapping:          (null) index:0x0
> >> 	page flags: 0xafffff80008000(tail)
> >> 	page dumped because: kasan error
> >> 	CPU: 6 PID: 9262 Comm: trinity-c104 Not tainted 3.16.0-rc6-next-20140723-sasha-00047-g289342b-dirty #929
> >> 	 00000000000000fb 0000000000000000 ffffea001229ccc0 ffff88038ac0fb78
> >> 	 ffffffffa5e40903 ffff88038ac0fc48 ffff88038ac0fc38 ffffffffa142acfc
> >> 	 0000000000000001 ffff880509ff5aa8 ffff88038ac10038 ffff88038ac0fbb0
> >> 	Call Trace:
> >> 	dump_stack (lib/dump_stack.c:52)
> >> 	kasan_report_error (mm/kasan/report.c:98 mm/kasan/report.c:166)
> >> 	? debug_smp_processor_id (lib/smp_processor_id.c:57)
> >> 	? preempt_count_sub (kernel/sched/core.c:2606)
> >> 	? put_lock_stats.isra.13 (./arch/x86/include/asm/preempt.h:98 kernel/locking/lockdep.c:254)
> >> 	? do_read_fault.isra.40 (mm/memory.c:2784 mm/memory.c:2849 mm/memory.c:2898)
> >> 	__asan_load8 (mm/kasan/kasan.c:364)
> >> 	? do_read_fault.isra.40 (mm/memory.c:2864 mm/memory.c:2898)
> >> 	do_read_fault.isra.40 (mm/memory.c:2864 mm/memory.c:2898)
> >> 	? _raw_spin_unlock (./arch/x86/include/asm/preempt.h:98 include/linux/spinlock_api_smp.h:152 kernel/locking/spinlock.c:183)
> >> 	? __pte_alloc (mm/memory.c:598)
> >> 	handle_mm_fault (mm/memory.c:3092 mm/memory.c:3225 mm/memory.c:3345 mm/memory.c:3374)
> >> 	? pud_huge (./arch/x86/include/asm/paravirt.h:611 arch/x86/mm/hugetlbpage.c:76)
> >> 	__get_user_pages (mm/gup.c:286 mm/gup.c:478)
> >> 	__mlock_vma_pages_range (mm/mlock.c:262)
> >> 	__mm_populate (mm/mlock.c:710)
> >> 	SyS_remap_file_pages (mm/mmap.c:2653 mm/mmap.c:2593)
> >> 	tracesys (arch/x86/kernel/entry_64.S:541)
> >> 	Read of size 8 by thread T9262:
> >> 	Memory state around the buggy address:
> >> 	 ffff88048a732e80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> >> 	 ffff88048a732f00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> >> 	 ffff88048a732f80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> >> 	 ffff88048a733000: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> >> 	 ffff88048a733080: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> >> 	>ffff88048a733100: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> >> 	                         ^
> >> 	 ffff88048a733180: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> >> 	 ffff88048a733200: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> >> 	 ffff88048a733280: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> >> 	 ffff88048a733300: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> >> 	 ffff88048a733380: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> >>
> >>
> >> It looks like that pte pointer is invalid in do_fault_around().
> >> This could happen if fault_around_bytes is set to 0.
> >> fault_around_pages() and fault_around_mask() calls rounddown_pow_of_to(fault_around_bytes)
> >> The result of rounddown_pow_of_to is undefined if parameter == 0
> >> (in my environment it returns 0x8000000000000000).
> > 
> > Ouch. Good catch!
> > 
> > Although, I'm not convinced that it caused the issue. Sasha, did you touch the
> > debugfs handle?
> > 
> 
> I suppose trinity could change it, no? I've got the very same spew after setting fault_around_bytes to 0.
> 
> >> One way to fix this would be to return 0 from fault_around_pages() if fault_around_bytes == 0,
> >> however this would add extra code on fault path.
> >>
> >> So let's just forbid to set fault_around_bytes to zero.
> >> Fault around is not used if fault_around_pages() <= 1, so if anyone doesn't want to use
> >> it, fault_around_bytes could be set to any value in range [1, 2*PAGE_SIZE - 1]
> >> instead of 0.
> > 
> >>From user point of view, 0 is perfectly fine. What about untested patch
> > below?
> > 
> 
> In case if we are not going to get rid of debugfs interface I would better keep
> faul_around_bytes always roundded down, like in following patch:
> 
> 
> From f41b7777b29f06dc62f80526e5617cae82a38709 Mon Sep 17 00:00:00 2001
> From: Andrey Ryabinin <a.ryabinin@samsung.com>
> Date: Mon, 28 Jul 2014 13:46:10 +0400
> Subject: [PATCH] mm: debugfs: move rounddown_pow_of_two() out from do_fault
>  path
> 
> do_fault_around expects fault_around_bytes rounded down to nearest
> page order. Instead of calling rounddown_pow_of_two every time
> in fault_around_pages()/fault_around_mask() we could do round down
> when user changes fault_around_bytes via debugfs interface.
> 
> This also fixes bug when user set fault_around_bytes to 0.
> Result of rounddown_pow_of_two(0) is not defined, therefore
> fault_around_bytes == 0 doesn't work without this patch.
> 
> Let's set fault_around_bytes to PAGE_SIZE if user sets to something
> less than PAGE_SIZE
> 
> Fixes: a9b0f861("mm: nominate faultaround area in bytes rather than page order")
> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
> Cc: <stable@vger.kernel.org> # 3.15.x
> ---
>  mm/memory.c | 19 +++++++++++--------
>  1 file changed, 11 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 7e8d820..e0c6fd6 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2758,20 +2758,16 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
>  	update_mmu_cache(vma, address, pte);
>  }
> 
> -static unsigned long fault_around_bytes = 65536;
> +static unsigned long fault_around_bytes = rounddown_pow_of_two(65536);

This looks weird, but okay...

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
