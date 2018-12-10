Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 87EF18E0018
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 10:06:38 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id y85so4698865wmc.7
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 07:06:38 -0800 (PST)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id b12si7693685wrv.58.2018.12.10.07.06.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 07:06:36 -0800 (PST)
Date: Mon, 10 Dec 2018 15:05:51 +0000
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH] mm/zsmalloc.c: Fix zsmalloc 32-bit PAE support
Message-ID: <20181210150551.GE30658@n2100.armlinux.org.uk>
References: <20181210142105.6750-1-rafael.tinoco@linaro.org>
 <4da655ec-a1ac-c524-1eb4-5cbd18b265ef@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4da655ec-a1ac-c524-1eb4-5cbd18b265ef@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: Rafael David Tinoco <rafael.tinoco@linaro.org>, Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-sh@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Ram Pai <linuxram@us.ibm.com>, linux-mips@vger.kernel.org, linux-mm@kvack.org, Khalid Aziz <khalid.aziz@oracle.com>, Paul Mackerras <paulus@samba.org>, "H . Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, linux-s390@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Ingo Molnar <mingo@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, James Hogan <jhogan@kernel.org>, Anthony Yznaga <anthony.yznaga@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Fenghua Yu <fenghua.yu@intel.com>, Joerg Roedel <jroedel@suse.de>, Juergen Gross <jgross@suse.com>, Vasily Gorbik <gor@linux.ibm.com>, Will Deacon <will.deacon@arm.com>, Nicholas Piggin <npiggin@gmail.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org, Christophe Leroy <christophe.leroy@c-s.fr>, Tony Luck <tony.luck@intel.com>, Jiri Kosina <jkosina@suse.cz>, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, Minchan Kim <minchan@kernel.org>, Paul Burton <paul.burton@mips.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linuxppc-dev@lists.ozlabs.org, "David S . Miller" <davem@davemloft.net>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, Dec 10, 2018 at 02:35:55PM +0000, Robin Murphy wrote:
> On 10/12/2018 14:21, Rafael David Tinoco wrote:
> >On 32-bit systems, zsmalloc uses HIGHMEM and, when PAE is enabled, the
> >physical frame number might be so big that zsmalloc obj encoding (to
> >location) will break, causing:
> >
> >BUG: KASAN: null-ptr-deref in zs_map_object+0xa4/0x2bc
> >Read of size 4 at addr 00000000 by task mkfs.ext4/623
> >CPU: 2 PID: 623 Comm: mkfs.ext4 Not tainted 4.19.0-rc8-00017-g8239bc6d3307-dirty #15
> >Hardware name: Generic DT based system
> >[<c0418f7c>] (unwind_backtrace) from [<c0410ca4>] (show_stack+0x20/0x24)
> >[<c0410ca4>] (show_stack) from [<c16bd540>] (dump_stack+0xbc/0xe8)
> >[<c16bd540>] (dump_stack) from [<c06cab74>] (kasan_report+0x248/0x390)
> >[<c06cab74>] (kasan_report) from [<c06c94e8>] (__asan_load4+0x78/0xb4)
> >[<c06c94e8>] (__asan_load4) from [<c06ddc24>] (zs_map_object+0xa4/0x2bc)
> >[<c06ddc24>] (zs_map_object) from [<bf0bbbd8>] (zram_bvec_rw.constprop.2+0x324/0x8e4 [zram])
> >[<bf0bbbd8>] (zram_bvec_rw.constprop.2 [zram]) from [<bf0bc3cc>] (zram_make_request+0x234/0x46c [zram])
> >[<bf0bc3cc>] (zram_make_request [zram]) from [<c09aff9c>] (generic_make_request+0x304/0x63c)
> >[<c09aff9c>] (generic_make_request) from [<c09b0320>] (submit_bio+0x4c/0x1c8)
> >[<c09b0320>] (submit_bio) from [<c0743570>] (submit_bh_wbc.constprop.15+0x238/0x26c)
> >[<c0743570>] (submit_bh_wbc.constprop.15) from [<c0746cf8>] (__block_write_full_page+0x524/0x76c)
> >[<c0746cf8>] (__block_write_full_page) from [<c07472c4>] (block_write_full_page+0x1bc/0x1d4)
> >[<c07472c4>] (block_write_full_page) from [<c0748eb4>] (blkdev_writepage+0x24/0x28)
> >[<c0748eb4>] (blkdev_writepage) from [<c064a780>] (__writepage+0x44/0x78)
> >[<c064a780>] (__writepage) from [<c064b50c>] (write_cache_pages+0x3b8/0x800)
> >[<c064b50c>] (write_cache_pages) from [<c064dd78>] (generic_writepages+0x74/0xa0)
> >[<c064dd78>] (generic_writepages) from [<c0748e64>] (blkdev_writepages+0x18/0x1c)
> >[<c0748e64>] (blkdev_writepages) from [<c064e890>] (do_writepages+0x68/0x134)
> >[<c064e890>] (do_writepages) from [<c06368a4>] (__filemap_fdatawrite_range+0xb0/0xf4)
> >[<c06368a4>] (__filemap_fdatawrite_range) from [<c0636b68>] (file_write_and_wait_range+0x64/0xd0)
> >[<c0636b68>] (file_write_and_wait_range) from [<c0747af8>] (blkdev_fsync+0x54/0x84)
> >[<c0747af8>] (blkdev_fsync) from [<c0739dac>] (vfs_fsync_range+0x70/0xd4)
> >[<c0739dac>] (vfs_fsync_range) from [<c0739e98>] (do_fsync+0x4c/0x80)
> >[<c0739e98>] (do_fsync) from [<c073a26c>] (sys_fsync+0x1c/0x20)
> >[<c073a26c>] (sys_fsync) from [<c0401000>] (ret_fast_syscall+0x0/0x2c)
> >
> >when trying to decode (the pfn) and map the object.
> >
> >That happens because one architecture might not re-define
> >MAX_PHYSMEM_BITS, like in this ARM 32-bit w/ LPAE enabled example. For
> >32-bit systems, if not re-defined, MAX_POSSIBLE_PHYSMEM_BITS will
> >default to BITS_PER_LONG (32) in most cases, and, with PAE enabled,
> >_PFN_BITS might be wrong: which may cause obj variable to overflow if
> >frame number is in HIGHMEM and referencing a page above the 4GB
> >watermark.
> >
> >commit 6e00ec00b1a7 ("staging: zsmalloc: calculate MAX_PHYSMEM_BITS if
> >not defined") realized MAX_PHYSMEM_BITS depended on SPARSEMEM headers
> >and "fixed" it by calculating it using BITS_PER_LONG if SPARSEMEM wasn't
> >used, like in the example given above.
> >
> >Systems with potential for PAE exist for a long time and assuming
> >BITS_PER_LONG seems inadequate. Defining MAX_PHYSMEM_BITS looks better,
> >however it is NOT a constant anymore for x86.
> >
> >SO, instead, MAX_POSSIBLE_PHYSMEM_BITS should be defined by every
> >architecture using zsmalloc, together with a sanity check for
> >MAX_POSSIBLE_PHYSMEM_BITS being too big on 32-bit systems.
> >
> >Link: https://bugs.linaro.org/show_bug.cgi?id=3765#c17
> >Signed-off-by: Rafael David Tinoco <rafael.tinoco@linaro.org>
> >---
> >  arch/arm/include/asm/pgtable-2level-types.h |  2 ++
> >  arch/arm/include/asm/pgtable-3level-types.h |  2 ++
> >  arch/arm64/include/asm/pgtable-types.h      |  2 ++
> >  arch/ia64/include/asm/page.h                |  2 ++
> >  arch/mips/include/asm/page.h                |  2 ++
> >  arch/powerpc/include/asm/mmu.h              |  2 ++
> >  arch/s390/include/asm/page.h                |  2 ++
> >  arch/sh/include/asm/page.h                  |  2 ++
> >  arch/sparc/include/asm/page_32.h            |  2 ++
> >  arch/sparc/include/asm/page_64.h            |  2 ++
> >  arch/x86/include/asm/pgtable-2level_types.h |  2 ++
> >  arch/x86/include/asm/pgtable-3level_types.h |  3 +-
> >  arch/x86/include/asm/pgtable_64_types.h     |  4 +--
> >  mm/zsmalloc.c                               | 35 +++++++++++----------
> >  14 files changed, 45 insertions(+), 19 deletions(-)
> >
> >diff --git a/arch/arm/include/asm/pgtable-2level-types.h b/arch/arm/include/asm/pgtable-2level-types.h
> >index 66cb5b0e89c5..552dba411324 100644
> >--- a/arch/arm/include/asm/pgtable-2level-types.h
> >+++ b/arch/arm/include/asm/pgtable-2level-types.h
> >@@ -64,4 +64,6 @@ typedef pteval_t pgprot_t;
> >  #endif /* STRICT_MM_TYPECHECKS */
> >+#define MAX_POSSIBLE_PHYSMEM_BITS 32
> >+
> >  #endif	/* _ASM_PGTABLE_2LEVEL_TYPES_H */
> >diff --git a/arch/arm/include/asm/pgtable-3level-types.h b/arch/arm/include/asm/pgtable-3level-types.h
> >index 921aa30259c4..664c39e6517c 100644
> >--- a/arch/arm/include/asm/pgtable-3level-types.h
> >+++ b/arch/arm/include/asm/pgtable-3level-types.h
> >@@ -67,4 +67,6 @@ typedef pteval_t pgprot_t;
> >  #endif	/* STRICT_MM_TYPECHECKS */
> >+#define MAX_POSSIBLE_PHYSMEM_BITS 36
> 
> Nit: with LPAE, physical addresses go up to 40 bits, not just 36.

Right, with that set at 40, we get:

#define _PFN_BITS               (MAX_POSSIBLE_PHYSMEM_BITS - PAGE_SHIFT)

== 28

#define OBJ_TAG_BITS 1
#define OBJ_INDEX_BITS  (BITS_PER_LONG - _PFN_BITS - OBJ_TAG_BITS)

== 3

#define ZS_MAX_ZSPAGE_ORDER 2
#define ZS_MAX_PAGES_PER_ZSPAGE (_AC(1, UL) << ZS_MAX_ZSPAGE_ORDER)

== 4

#define ZS_MIN_ALLOC_SIZE \
        MAX(32, (ZS_MAX_PAGES_PER_ZSPAGE << PAGE_SHIFT >> OBJ_INDEX_BITS))

== 4 << 12 >> 3 = 2048

or half-page allocations.

Given this in Documentation/vm/zsmalloc.rst:

On the other hand, if we just use single
(0-order) pages, it would suffer from very high fragmentation --
any object of size PAGE_SIZE/2 or larger would occupy an entire page.
This was one of the major issues with its predecessor (xvmalloc).

It seems that would not be acceptable, so I have to ask whether
using an unsigned long to store PFN + object ID is really acceptable.
Maybe the real solution to this problem is to stop using an
unsigned long to contain both the PFN and object ID?

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
According to speedtest.net: 11.9Mbps down 500kbps up
