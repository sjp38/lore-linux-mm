From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906071926.MAA83891@google.engr.sgi.com>
Subject: Questions on cache flushing in do_wp_page
Date: Mon, 7 Jun 1999 12:26:27 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
Cc: ralf@uni-koblenz.de, davem@redhat.com
List-ID: <linux-mm.kvack.org>

I am trying to understand what the primitives flush_page_to_ram and
flush_cache_page do. I am vaguely aware of the issues of non coherent
io and virtual aliasing/virtual coherency error. Specially, I am
trying to guess at what these primitives might be doing in the
do_wp_page() routine. The only processors which I have worked with
are MIPS and Intel processors. In Intel, these two primitives are
null since the caches are fully coherent. For MIPS, I can't find
a good reason why either function would be neccesary in
do_wp_page(). I am CCing David Miller and Ralf Baechle whose
names appear in the copyright messages in arch/mips/mm/r4xx0.c.
Anyone else with m68k/ppc/sparc etc expertise please feel free to
comment.

I am looking at the piece of code in do_wp_page that reads:

        copy_cow_page(old_page,new_page);
        flush_page_to_ram(old_page);
        flush_page_to_ram(new_page);
        flush_cache_page(vma, address);
        set_pte(page_table, pte_mkwrite(pte_mkdirty(mk_pte(new_page, vma->vm_page_prot))));
        free_page(old_page);
        flush_tlb_page(vma, address);

I can see that the flush_cache_page() is needed for a processor that
has virtually indexed, virtually tagged L1, but is there any such
processor that Linux supports (sparc?)? Does this processor also
need virtual alias avoidance support from the os because the processor
can not detect such aliasing?

For MIPS R4000PC, with a virtually indexed physically tagged L1, I
think it might be enough to just have a flush_page_to_ram(new_page);
to avoid aliasing issues ...

In any case, I can't see a reason for flush_page_to_ram(old_page);
Can anyone tell me why that might be needed (on whichever processor)?

Another place that I can't explain why a flush_cache_page might be
needed is in:

        case 1:
                /* We can release the kernel lock now.. */
                unlock_kernel();

                flush_cache_page(vma, address);
                set_pte(page_table, pte_mkdirty(pte_mkwrite(pte)));
                flush_tlb_page(vma, address);
end_wp_page:
                if (new_page)
                        free_page(new_page);
                return 1;

Thanks.

Kanoj
kanoj@engr.sgi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
