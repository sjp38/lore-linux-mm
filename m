Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id F40DA6B0003
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 10:10:47 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id w193-v6so7028589wmf.8
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 07:10:47 -0700 (PDT)
Received: from www.kot-begemot.co.uk (ivanoab6.miniserver.com. [5.153.251.140])
        by mx.google.com with ESMTPS id j138-v6si1353255wmf.195.2018.10.12.07.10.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 12 Oct 2018 07:10:46 -0700 (PDT)
Subject: Re: [PATCH v2 2/2] mm: speed up mremap by 500x on large regions
References: <20181012013756.11285-1-joel@joelfernandes.org>
 <20181012013756.11285-2-joel@joelfernandes.org>
From: Anton Ivanov <anton.ivanov@kot-begemot.co.uk>
Message-ID: <9ed82f9e-88c4-8e4f-8c45-3ef153469603@kot-begemot.co.uk>
Date: Fri, 12 Oct 2018 15:09:49 +0100
MIME-Version: 1.0
In-Reply-To: <20181012013756.11285-2-joel@joelfernandes.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Joel Fernandes (Google)" <joel@joelfernandes.org>, linux-kernel@vger.kernel.org
Cc: linux-mips@linux-mips.org, Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, mhocko@kernel.org, linux-mm@kvack.org, lokeshgidra@google.com, linux-riscv@lists.infradead.org, elfring@users.sourceforge.net, Jonas Bonn <jonas@southpole.se>, linux-s390@vger.kernel.org, dancol@google.com, Yoshinori Sato <ysato@users.sourceforge.jp>, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-hexagon@vger.kernel.org, Helge Deller <deller@gmx.de>, "maintainer:X86 ARCHITECTURE 32-BIT AND 64-BIT" <x86@kernel.org>, hughd@google.com, "James E.J. Bottomley" <jejb@parisc-linux.org>, kasan-dev@googlegroups.com, kvmarm@lists.cs.columbia.edu, Ingo Molnar <mingo@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-snps-arc@lists.infradead.org, kernel-team@android.com, Sam Creasey <sammy@sammy.net>, Fenghua Yu <fenghua.yu@intel.com>, Jeff Dike <jdike@addtoit.com>, linux-um@lists.infradead.org, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Julia Lawall <Julia.Lawall@lip6.fr>, linux-m68k@lists.linux-m68k.org, openrisc@lists.librecores.org, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, nios2-dev@lists.rocketboards.org, kirill@shutemov.name, Stafford Horne <shorne@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, linux-arm-kernel@lists.infradead.org, Chris Zankel <chris@zankel.net>, Tony Luck <tony.luck@intel.com>, Richard Weinberger <richard@nod.at>, linux-parisc@vger.kernel.org, pantin@google.com, Max Filippov <jcmvbkbc@gmail.com>, minchan@kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-alpha@vger.kernel.org, Ley Foon Tan <lftan@altera.com>, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

On 10/12/18 2:37 AM, Joel Fernandes (Google) wrote:
> Android needs to mremap large regions of memory during memory management
> related operations. The mremap system call can be really slow if THP is
> not enabled. The bottleneck is move_page_tables, which is copying each
> pte at a time, and can be really slow across a large map. Turning on THP
> may not be a viable option, and is not for us. This patch speeds up the
> performance for non-THP system by copying at the PMD level when possible.
>
> The speed up is three orders of magnitude. On a 1GB mremap, the mremap
> completion times drops from 160-250 millesconds to 380-400 microseconds.
>
> Before:
> Total mremap time for 1GB data: 242321014 nanoseconds.
> Total mremap time for 1GB data: 196842467 nanoseconds.
> Total mremap time for 1GB data: 167051162 nanoseconds.
>
> After:
> Total mremap time for 1GB data: 385781 nanoseconds.
> Total mremap time for 1GB data: 388959 nanoseconds.
> Total mremap time for 1GB data: 402813 nanoseconds.
>
> Incase THP is enabled, the optimization is skipped. I also flush the
> tlb every time we do this optimization since I couldn't find a way to
> determine if the low-level PTEs are dirty. It is seen that the cost of
> doing so is not much compared the improvement, on both x86-64 and arm64.
>
> Cc: minchan@kernel.org
> Cc: pantin@google.com
> Cc: hughd@google.com
> Cc: lokeshgidra@google.com
> Cc: dancol@google.com
> Cc: mhocko@kernel.org
> Cc: kirill@shutemov.name
> Cc: akpm@linux-foundation.org
> Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
> ---
>   mm/mremap.c | 62 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>   1 file changed, 62 insertions(+)
>
> diff --git a/mm/mremap.c b/mm/mremap.c
> index 9e68a02a52b1..d82c485822ef 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -191,6 +191,54 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
>   		drop_rmap_locks(vma);
>   }
>   
> +static bool move_normal_pmd(struct vm_area_struct *vma, unsigned long old_addr,
> +		  unsigned long new_addr, unsigned long old_end,
> +		  pmd_t *old_pmd, pmd_t *new_pmd, bool *need_flush)
> +{
> +	spinlock_t *old_ptl, *new_ptl;
> +	struct mm_struct *mm = vma->vm_mm;
> +
> +	if ((old_addr & ~PMD_MASK) || (new_addr & ~PMD_MASK)
> +	    || old_end - old_addr < PMD_SIZE)
> +		return false;
> +
> +	/*
> +	 * The destination pmd shouldn't be established, free_pgtables()
> +	 * should have release it.
> +	 */
> +	if (WARN_ON(!pmd_none(*new_pmd)))
> +		return false;
> +
> +	/*
> +	 * We don't have to worry about the ordering of src and dst
> +	 * ptlocks because exclusive mmap_sem prevents deadlock.
> +	 */
> +	old_ptl = pmd_lock(vma->vm_mm, old_pmd);
> +	if (old_ptl) {
> +		pmd_t pmd;
> +
> +		new_ptl = pmd_lockptr(mm, new_pmd);
> +		if (new_ptl != old_ptl)
> +			spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
> +
> +		/* Clear the pmd */
> +		pmd = *old_pmd;
> +		pmd_clear(old_pmd);
> +
> +		VM_BUG_ON(!pmd_none(*new_pmd));
> +
> +		/* Set the new pmd */
> +		set_pmd_at(mm, new_addr, new_pmd, pmd);

UML does not have set_pmd_at at all

If I read the code right, MIPS completely ignores the address argument 
so set_pmd_at there may not have the effect which this patch is trying 
to achieve.

IMHO, this needs to be a per-architecture, not across full tree.

> +		if (new_ptl != old_ptl)
> +			spin_unlock(new_ptl);
> +		spin_unlock(old_ptl);
> +
> +		*need_flush = true;
> +		return true;
> +	}
> +	return false;
> +}
> +
>   unsigned long move_page_tables(struct vm_area_struct *vma,
>   		unsigned long old_addr, struct vm_area_struct *new_vma,
>   		unsigned long new_addr, unsigned long len,
> @@ -239,7 +287,21 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
>   			split_huge_pmd(vma, old_pmd, old_addr);
>   			if (pmd_trans_unstable(old_pmd))
>   				continue;
> +		} else if (extent == PMD_SIZE) {
> +			bool moved;
> +
> +			/* See comment in move_ptes() */
> +			if (need_rmap_locks)
> +				take_rmap_locks(vma);
> +			moved = move_normal_pmd(vma, old_addr, new_addr,
> +					old_end, old_pmd, new_pmd,
> +					&need_flush);
> +			if (need_rmap_locks)
> +				drop_rmap_locks(vma);
> +			if (moved)
> +				continue;
>   		}
> +
>   		if (pte_alloc(new_vma->vm_mm, new_pmd))
>   			break;
>   		next = (new_addr + PMD_SIZE) & PMD_MASK;


Brgds,


A.
