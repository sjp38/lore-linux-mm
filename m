Date: Sun, 18 Apr 2004 11:42:11 +0100
From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: PTE aging, ptep_test_and_clear_young() and TLB
Message-ID: <20040418114211.A9952@flint.arm.linux.org.uk>
References: <20040417211506.C21974@flint.arm.linux.org.uk> <20040417204302.GR743@holomorphy.com> <20040418103616.B5745@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040418103616.B5745@flint.arm.linux.org.uk>; from rmk@arm.linux.org.uk on Sun, Apr 18, 2004 at 10:36:16AM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Apr 18, 2004 at 10:36:16AM +0100, Russell King wrote:
> Actually, we don't actually need the VMA - if you look at flush_tlb_page()
> in include/asm-arm/tlbflush.h, we only really need the MM.  Therefore,
> it's pointless digging up the VMA.  (I did think that we didn't flush
> the I-TLB if VM_EXEC wasn't set, but I think that was a previous
> incarnation.)

Grumble - there's one big problem here - it's the kernel include
dependencies.

In file included from include/linux/mm.h:25,
                 from arch/arm/kernel/asm-offsets.c:14:
include/asm/pgtable.h: In function `ptep_test_and_clear_young':
include/asm/pgtable.h:404: warning: implicit declaration of function `flush_tlb_mm_page'
include/asm/pgtable.h:404: warning: implicit declaration of function `ptep_to_mm'
include/asm/pgtable.h:404: warning: implicit declaration of function `ptep_to_address'

Ok, so linux/mm.h includes asm/pgtable.h, which in turn includes
asm-generic/pgtable.h.  I need to get at the mm and address in my
implementation of ptep_test_and_clear_young() - and the functions
are defined in asm-generic/rmap.h.  This includes linux/mm.h, so
I can't include it in asm/pgtable.h. Moreover, mm_struct hasn't
been declared yet.

Converting ptep_test_and_clear_young() to be a macro doesn't look
sane either, not without creating some rather disgusting code.

So, how do I get at the mm_struct and address in asm/pgtable.h ?
Maybe we need to split out the pte manipulation into asm/pte.h rather
than overloading pgtable.h with it?

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
