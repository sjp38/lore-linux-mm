Subject: What archs need flush_tlb_page() in handle_pte_fault() ?
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Content-Type: text/plain
Date: Thu, 02 Aug 2007 11:37:01 +1000
Message-Id: <1186018621.5495.558.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, Linux Arch list <linux-arch@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Heya !

In my page table accessor spring cleaning, one of my targets is
flush_tlb_page(). At this stage, it's only called by generic code in one
place (in addition to the asm-generic bits that use it to implement
missing accessors, but I'm taking care of those spearately) :

In handle_pte_fault(), when the PTE is present -and-
ptep_set_access_flags() returns false -and- it's a write fault, we do a
flush_tlb_page().

ptep_set_access_flags() returning false typically means we don't
actually need to call update_mmu_cache() and haven't updated the PTE.

Now, I would like to understand what archs actually need that. If we
have lazy _PAGE_DIRTY handling, then ptep_set_access_flags() would have
done the flush already. I can imagine people may want to avoid the SMP
IPI in that case and only lazily flush on that CPU but that doesn't seem
to be what i386 does today.

In any case, I believe that this flush could be moved to inside
ptep_set_access_flags() for archs that need it, thus totally removing
the else { ... } clause in handle_pte_fault(). Archs that want to be
smart can do a local flush inside ptep_set_access_flags() if !changed &&
dirty, it all gets under arch control, and that last flush_tlb_page()
can be removed from generic code.

Now, before I actually remove it, I need to understand what archs
actually -need- that flush, so I can move it to their respective
ptep_set_access_flags() implementations.

I don't see i386 needing it unless I missed something.

For now, I'll assume nobody needs it. So please tell me if your arch
does and I'll make sure my patch has it fixed up properly.

Thanks !
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
