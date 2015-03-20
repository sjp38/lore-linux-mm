Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id E0A346B006C
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 17:17:45 -0400 (EDT)
Received: by iedm5 with SMTP id m5so38671818ied.3
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 14:17:45 -0700 (PDT)
Received: from mail-ig0-x22d.google.com (mail-ig0-x22d.google.com. [2607:f8b0:4001:c05::22d])
        by mx.google.com with ESMTPS id o1si5654397icp.73.2015.03.20.14.17.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Mar 2015 14:17:45 -0700 (PDT)
Received: by igcqo1 with SMTP id qo1so2422534igc.0
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 14:17:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <550C37C9.2060200@oracle.com>
References: <550C37C9.2060200@oracle.com>
Date: Fri, 20 Mar 2015 14:17:43 -0700
Message-ID: <CA+55aFxoVPRuFJGuP_=0-NCiqx_NPeJBv+SAZqbAzeC9AhN+CA@mail.gmail.com>
Subject: Re: 4.0.0-rc4: panic in free_block
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Ahern <david.ahern@oracle.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Mar 20, 2015 at 8:07 AM, David Ahern <david.ahern@oracle.com> wrote:
> Instruction DUMP: 86230003  8730f00d  8728f006 <d658c007> 8600c007 8e0ac008 2ac1c002  c658e030  d458e028

Ok, so it's d658c007 that faults, which is that

        ldx  [ %g3 + %g7 ], %o3

instruction.

Looking at your objdump:

> free_block():
> /opt/dahern/linux.git/kbuild/../mm/slab.c:3265
>   55de64:       10 68 00 47     b  %xcc, 55df80 <free_block+0x158>
>   55de68:       85 30 b0 02     srlx  %g2, 2, %g2
> clear_obj_pfmemalloc():
> /opt/dahern/linux.git/kbuild/../mm/slab.c:224
>   55de6c:       98 0b 3f fe     and  %o4, -2, %o4
>   55de70:       d8 76 40 00     stx  %o4, [ %i1 ]
> virt_to_head_page():
> /opt/dahern/linux.git/kbuild/../include/linux/mm.h:554
>   55de74:       c6 5c 80 00     ldx  [ %l2 ], %g3
>   55de78:       ce 5c 40 00     ldx  [ %l1 ], %g7
>   55de7c:       86 23 00 03     sub  %o4, %g3, %g3
>   55de80:       87 30 f0 0d     srlx  %g3, 0xd, %g3
>   55de84:       87 28 f0 06     sllx  %g3, 6, %g3
> test_bit():
> /opt/dahern/linux.git/kbuild/../include/asm-generic/bitops/non-atomic.h:105
>   55de88:       d6 58 c0 07     ldx  [ %g3 + %g7 ], %o3
> virt_to_head_page():
> /opt/dahern/linux.git/kbuild/../include/linux/mm.h:554
>   55de8c:       86 00 c0 07     add  %g3, %g7, %g3

I think that's the load of "page->flags" which is almost certainly
part of that initial

                page = virt_to_head_page(objp);

at the top of the loop in free_block(). In fact, it's probably from
compound_head_fast() which does

        if (unlikely(PageTail(page)))
                if (likely(__get_page_tail(page)))
                        return;

so I think it's about to test the PG_tail bit.

So it's the virt_to_page(x) that has returned 0006100000000000. For
sparc64, that's

   #define virt_to_page(kaddr)    pfn_to_page(__pa(kaddr)>>PAGE_SHIFT)

Looking at the code generation, I think %g7 (0x0006000000000000) is
VMEMMAP_BASE, and %g3 is "pfn << 6", where the "<< 6" is because a
"struct page" is 64 bytes.

And looking at that

        sub  %o4, %g3, %g3

I think that's "__pa(x)", so I think %o4 is 'x'. That also matches the
"and  %o4, -2, %o4", which would be the clear_obj_pfmemalloc().

And %o4 is 0.

In other words, if I read that sparc asm right (and it is very likely
that I do *not*), then "objp" is NULL, and that's why you crash.

That's odd, because we know that objp cannot be NULL in
kmem_slab_free() (even if we allowed it, like with kfree(),
remove_vma() cannot possibly have a NULL vma, since ti dereferences it
multiple times).

So I must be misreading this completely. Somebody with better sparc
debugging mojo should double-check my logic. How would objp be NULL?

                        Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
