Date: Thu, 8 May 2008 22:02:39 +0200
From: Hans Rosenfeld <hans.rosenfeld@amd.com>
Subject: Re: [PATCH] x86: fix PAE pmd_bad bootup warning
Message-ID: <20080508200239.GJ12654@escobedo.amd.com>
References: <1210106579.4747.51.camel@nimitz.home.sr71.net> <20080508143453.GE12654@escobedo.amd.com> <1210258350.7905.45.camel@nimitz.home.sr71.net> <20080508151145.GG12654@escobedo.amd.com> <1210261882.7905.49.camel@nimitz.home.sr71.net> <20080508161925
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0805081914210.16611@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, Jeff Chua <jeff.chua.linux@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Gabriel C <nix.or.die@googlemail.com>, Arjan van de Ven <arjan@linux.intel.com>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 08, 2008 at 07:48:51PM +0100, Hugh Dickins wrote:
> > Dunno, seems quite clear that the bug is in pagemap_read(), not any
> > hugepage code, and that the simplest fix is to make pagemap_read() do
> > what the other walker-callers do, and skip hugepage regions.
> 
> Yes, I'm afraid it needs an is_vm_hugetlb_page(vma) in there somehow:
> as you observe, that's what everything else uses to avoid huge issues.
> 
> A pmd_huge(*pmd) test is tempting, but it only ever says "yes" on x86:
> we've carefully left it undefined what happens to the pgd/pud/pmd/pte
> hierarchy in the general arch case, once you're amongst hugepages.

AFAIK the reason for this is that pmd_huge() and pud_huge() are
completely x86-specific. When I looked at the huge page support for
other archs in Linux the last time, all of them marked hugepages with
some page size bits in the PTE, using several PTEs for a single huge
page. So for anything but x86, the pgd/pud/pmd/pte hierarchy should work
for hugepages, too.

> Cc'ed Matt: he may have a view on what he wants his pagewalker
> to do with hugepages: I fear it would differ from one usage to
> another.  Skip over them has to be safest, though not ideal.

Proper hugepage support in /proc/pid/pagemap would be very helpful for
certain kinds of performance analysis, like TLB usage, where you need
page size information when you have a TLB for each supported page size.
That was the reason why I was working on supporting huge pages in
/proc/pid/pagemap in the first place.


-- 
%SYSTEM-F-ANARCHISM, The operating system has been overthrown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
