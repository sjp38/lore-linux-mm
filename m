Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id 180B8828FD
	for <linux-mm@kvack.org>; Thu,  5 Feb 2015 15:56:36 -0500 (EST)
Received: by mail-qa0-f42.google.com with SMTP id dc16so7745230qab.1
        for <linux-mm@kvack.org>; Thu, 05 Feb 2015 12:56:35 -0800 (PST)
Received: from g5t1625.atlanta.hp.com (g5t1625.atlanta.hp.com. [15.192.137.8])
        by mx.google.com with ESMTPS id v68si378871qge.29.2015.02.05.12.56.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Feb 2015 12:56:35 -0800 (PST)
Message-ID: <1423169785.6226.97.camel@misato.fc.hp.com>
Subject: Re: [RFC PATCH 2/7] lib: Add huge I/O map capability interfaces
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 05 Feb 2015 13:56:25 -0700
In-Reply-To: <1422320515.2493.53.camel@misato.fc.hp.com>
References: <1422314009-31667-1-git-send-email-toshi.kani@hp.com>
	 <1422314009-31667-3-git-send-email-toshi.kani@hp.com>
	 <20150126155456.a40df49e42b1b7f8077421f4@linux-foundation.org>
	 <1422320515.2493.53.camel@misato.fc.hp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Elliott@hp.com

On Mon, 2015-01-26 at 18:01 -0700, Toshi Kani wrote:
> On Mon, 2015-01-26 at 15:54 -0800, Andrew Morton wrote:
> > On Mon, 26 Jan 2015 16:13:24 -0700 Toshi Kani <toshi.kani@hp.com> wrote:
> > 
> > > Add ioremap_pud_enabled() and ioremap_pmd_enabled(), which
> > > return 1 when I/O mappings of pud/pmd are enabled on the kernel.
> > > 
> > > ioremap_huge_init() calls arch_ioremap_pud_supported() and
> > > arch_ioremap_pmd_supported() to initialize the capabilities.
> > > 
> > > A new kernel option "nohgiomap" is also added, so that user can
> > > disable the huge I/O map capabilities if necessary.
> > 
> > Why?  What's the problem with leaving it enabled?
> 
> No, there should not be any problem with leaving it enabled.  This
> option is added as a way to workaround a problem when someone hit an
> issue unexpectedly.

Intel SDM states "large page size considerations" as quoted in the
bottom of this email (Thanks Robert Elliott for this info).  There are
two cases mentioned:

 1) When large page is mapped to a region where MTRRs have multiple
different memory types, processor can behave in an undefined manner.
 2) When large page is mapped to the first 1MB which conflicts with the
fixed MTRRs, processor maps the range with multiple 4KB pages.

Case 2) is not an issue here since ioremap() does not remap the ISA
space in the first 1MB, and it's just a processor's "special" support.

For case 1), MTRR is a legacy feature and a driver calling ioremap() for
a large range covered by multiple MTRRs with two different types sounds
very unlikely to me, but it is theoretically possible.  (Note, /dev/mem
uses remap_pfn_range(), not ioremap().)

Here are three options I can think of for case 1).

 A) ioremap() to change a requested type to UC in case of 1)
 B) ioremap() to force 4KB mappings in case of 1)
 C) ioremap() to have no special handling for case 1)

In option A), pat_x_mtrr_type(), called from reserve_memtype(), already
has a special handling to convert WB request to UC-.  This handling
needs to be changed to convert all request types to UC (not UC-) in case
of 1).  reserve_memtype() is shared by other interfaces, so it needs to
have an additional argument to see if the caller supports large page
mapping since this conversion is only needed for large pages.

In option B), reserve_memtype() tells the caller that 4KB mappings need
to be used in case of 1) by returning 1.  All callers need to handle
this new return value properly.  ioremap_page_range() is then extended
to have additional flag that forces to use 4KB mappings.

In option C), we only document this potential issue, and do not make any
special handling for case 1), at least until we know this case really
exists in the real world.

Case 1) is better handled in the order of B), A), C) with additional
complexity & risk of the changes.  I am willing to make necessary
changes (A or B), but I am also thinking that we may be better off with
C) since MTRRs are legacy.

Do you think we need to protect the ioremap callers from case 1)?  Any
thoughts/suggestions will be very appreciated.

Thanks,
-Toshi  

=====
11.11.9 Large Page Size Considerations

The MTRRs provide memory typing for a limited number of regions that
have a 4 KByte granularity (the same gran-ularity as 4-KByte pages). The
memory type for a given page is cached in the processora??s TLBs. When
using large pages (2 MBytes, 4 MBytes, or 1 GBytes), a single page-table
entry covers multiple 4-KByte granules, each with a single memory type.
Because the memory type for a large page is cached in the TLB, the
processor can behave in an undefined manner if a large page is mapped to
a region of memory that MTRRs have mapped with multiple memory types. 

Undefined behavior can be avoided by insuring that all MTRR memory-type
ranges within a large page are of the same type. If a large page maps to
a region of memory containing different MTRR-defined memory types, the
PCD and PWT flags in the page-table entry should be set for the most
conservative memory type for that range. For example, a large page used
for memory mapped I/O and regular memory is mapped as UC memory.
Alternatively, the operating system can map the region using multiple
4-KByte pages each with its own memory type. 

The requirement that all 4-KByte ranges in a large page are of the same
memory type implies that large pages with different memory types may
suffer a performance penalty, since they must be marked with the lowest
common denominator memory type. The same consideration apply to 1 GByte
pages, each of which may consist of multiple 2-Mbyte ranges. 

The Pentium 4, Intel Xeon, and P6 family processors provide special
support for the physical memory range from 0 to 4 MBytes, which is
potentially mapped by both the fixed and variable MTRRs. This support is
invoked when a Pentium 4, Intel Xeon, or P6 family processor detects a
large page overlapping the first 1 MByte of this memory range with a
memory type that conflicts with the fixed MTRRs. Here, the processor
maps the memory range as multiple 4-KByte pages within the TLB. This
operation insures correct behavior at the cost of performance. To avoid 
this performance penalty, operating-system software should reserve the
large page option for regions of memory at addresses greater than or
equal to 4 MBytes.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
