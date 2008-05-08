Date: Thu, 8 May 2008 19:48:51 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] x86: fix PAE pmd_bad bootup warning
In-Reply-To: <20080508171657.GO23990@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0805081914210.16611@blonde.site>
References: <Pine.LNX.4.64.0805062043580.11647@blonde.site>
 <20080506202201.GB12654@escobedo.amd.com> <1210106579.4747.51.camel@nimitz.home.sr71.net>
 <20080508143453.GE12654@escobedo.amd.com> <1210258350.7905.45.camel@nimitz.home.sr71.net>
 <20080508151145.GG12654@escobedo.amd.com> <1210261882.7905.49.camel@nimitz.home.sr71.net>
 <20080508161925.GH12654@escobedo.amd.com> <20080508163352.GN23990@us.ibm.com>
 <20080508165111.GI12654@escobedo.amd.com> <20080508171657.GO23990@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Hans Rosenfeld <hans.rosenfeld@amd.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, Jeff Chua <jeff.chua.linux@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Gabriel C <nix.or.die@googlemail.com>, Arjan van de Ven <arjan@linux.intel.com>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 8 May 2008, Nishanth Aravamudan wrote:
> 
> So, is there any way to either add a is_vm_hugetlb_page(vma) check into
> pagemap_read()? Or can we modify walk_page_range to take the a vma and
> skip the walking if is_vm_hugetlb_page(vma) is set [to avoid
> complications down the road until hugepage walking is fixed]. I guess
> the latter isn't possible for pagemap_read(), since we are just looking
> at arbitrary addresses in the process space?
> 
> Dunno, seems quite clear that the bug is in pagemap_read(), not any
> hugepage code, and that the simplest fix is to make pagemap_read() do
> what the other walker-callers do, and skip hugepage regions.

Yes, I'm afraid it needs an is_vm_hugetlb_page(vma) in there somehow:
as you observe, that's what everything else uses to avoid huge issues.

A pmd_huge(*pmd) test is tempting, but it only ever says "yes" on x86:
we've carefully left it undefined what happens to the pgd/pud/pmd/pte
hierarchy in the general arch case, once you're amongst hugepages.

Might follow_huge_addr() be helpful, to avoid the need for a vma?
Perhaps, but my reading is that actually we've never really been
testing that path's success case (because get_user_pages already
skipped is_vm_hugetlb_page), so it might hold further surprises
on one architecture or another.

Many thanks to Hans for persisting, and pointing us to pagemap
to explain this hugepage leak: yes, the pmd_none_or_clear_bad
will be losing it - and corrupting target user address space.

Cc'ed Matt: he may have a view on what he wants his pagewalker
to do with hugepages: I fear it would differ from one usage to
another.  Skip over them has to be safest, though not ideal.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
