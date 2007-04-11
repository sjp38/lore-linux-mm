Date: Tue, 10 Apr 2007 21:04:47 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [QUICKLIST 1/4] Quicklists for page table pages V5
In-Reply-To: <1176180337.8061.21.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0704102058420.18321@schroedinger.engr.sgi.com>
References: <20070409182509.8559.33823.sendpatchset@schroedinger.engr.sgi.com>
 <1176180337.8061.21.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ak@suse.de, Paul Mackerras <paulus@samba.org>
List-ID: <linux-mm.kvack.org>

On Tue, 10 Apr 2007, Benjamin Herrenschmidt wrote:

> On Mon, 2007-04-09 at 11:25 -0700, Christoph Lameter wrote:
> 
> > Quicklists for page table pages V5
> 
> Looks interesting, but unfortunately not very useful at this point for
> powerpc unless you remove the assumption that quicklists contain
> pages...

Then quicklists wont be as simple anymore.

> On powerpc, we currently use kmem cache slabs (though that isn't
> terribly node friendly) whose sizes depend on the page size.
> 
> For a 4K page size kernel, we have 4 level page tables and use 2 caches,
> PTE and PGD pages are 4K (thus are PAGE_SIZE'd), and PMD & PUD are 1K.

PTE and PGD could be run via quicklists? With PTEs you cover the most 
common case. Quicklists using PGDs will allow to optimize using 
preconstructed pages.

Its probably best to keep the slabs for the 1K pages.
 
> For a 64K page size kernel, we have 3 level page tables and we use 3
> caches: a PGD pages are 128 bytes (yeah, not big heh...), our pmd
> pages are 32K (half a page) and PTE pages are PAGE_SIZE (64K).

Ok so use quicklists for the PTEs and slab for the rest? A PGD of only 128 
bytes? Stuff one at the end of the mm_struct or the task struct? That way 
you can avoid allocation overhead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
