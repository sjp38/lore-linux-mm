Date: Sun, 18 Apr 2004 10:36:16 +0100
From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: PTE aging, ptep_test_and_clear_young() and TLB
Message-ID: <20040418103616.B5745@flint.arm.linux.org.uk>
References: <20040417211506.C21974@flint.arm.linux.org.uk> <20040417204302.GR743@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040417204302.GR743@holomorphy.com>; from wli@holomorphy.com on Sat, Apr 17, 2004 at 01:43:02PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Apr 17, 2004 at 01:43:02PM -0700, William Lee Irwin III wrote:
> On Sat, Apr 17, 2004 at 09:15:06PM +0100, Russell King wrote:
> > This in turn means that we need to replace ptep_test_and_clear_young()
> > with ptep_clear_flush_young(), which in turn means we need the VMA and
> > address.  However, this implies introducing more code into
> > page_referenced().
> > Comments?
> 
> The address and mm should already be recoverable via the pte page
> tagging technique. The vma is recoverable from that, albeit at some
> cost (mm->page_table_lock acquisition + find_vma() call). OTOH unless
> kswapd's going wild it should largely count as a slow path anyway.

Actually, we don't actually need the VMA - if you look at flush_tlb_page()
in include/asm-arm/tlbflush.h, we only really need the MM.  Therefore,
it's pointless digging up the VMA.  (I did think that we didn't flush
the I-TLB if VM_EXEC wasn't set, but I think that was a previous
incarnation.)

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
