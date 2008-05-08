Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m48KGUG1010021
	for <linux-mm@kvack.org>; Thu, 8 May 2008 16:16:30 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m48KGUR5186046
	for <linux-mm@kvack.org>; Thu, 8 May 2008 14:16:30 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m48KGTf0021274
	for <linux-mm@kvack.org>; Thu, 8 May 2008 14:16:30 -0600
Subject: Re: [PATCH] x86: fix PAE pmd_bad bootup warning
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20080508200239.GJ12654@escobedo.amd.com>
References: <1210106579.4747.51.camel@nimitz.home.sr71.net>
	 <20080508143453.GE12654@escobedo.amd.com>
	 <1210258350.7905.45.camel@nimitz.home.sr71.net>
	 <20080508151145.GG12654@escobedo.amd.com>
	 <1210261882.7905.49.camel@nimitz.home.sr71.net>
	 <20080508161925  <20080508200239.GJ12654@escobedo.amd.com>
Content-Type: text/plain
Date: Thu, 08 May 2008 13:16:27 -0700
Message-Id: <1210277787.7905.81.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hans Rosenfeld <hans.rosenfeld@amd.com>
Cc: Hugh Dickins <hugh@veritas.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Jeff Chua <jeff.chua.linux@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Gabriel C <nix.or.die@googlemail.com>, Arjan van de Ven <arjan@linux.intel.com>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2008-05-08 at 22:02 +0200, Hans Rosenfeld wrote:
> > A pmd_huge(*pmd) test is tempting, but it only ever says "yes" on x86:
> > we've carefully left it undefined what happens to the pgd/pud/pmd/pte
> > hierarchy in the general arch case, once you're amongst hugepages.
> 
> AFAIK the reason for this is that pmd_huge() and pud_huge() are
> completely x86-specific. When I looked at the huge page support for
> other archs in Linux the last time, all of them marked hugepages with
> some page size bits in the PTE, using several PTEs for a single huge
> page. So for anything but x86, the pgd/pud/pmd/pte hierarchy should work
> for hugepages, too.

powerpc kinda puts them in pmds, although Adam calls them ptes in his
diagram.  See Adam's very nice pictures here:

	http://linux-mm.org/PageTableStructure

In the arch code, they have a concept of "slices" for each mm that you
can look up the page size for.  That's what they use when the mm/vmas
aren't around.  Their pmd_ts really are just pointers.  I don't think
they have any flags in them at all like _PAGE_PSE.

They just do a special pagetable walk instead of looking *at* the
pagetables.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
