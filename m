Date: Wed, 2 Jul 2003 19:47:00 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: What to expect with the 2.6 VM
Message-ID: <20030702174700.GJ23578@dualathlon.random>
References: <Pine.LNX.4.53.0307010238210.22576@skynet> <20030701022516.GL3040@dualathlon.random> <Pine.LNX.4.53.0307021641560.11264@skynet> <20030702171159.GG23578@dualathlon.random> <461030000.1057165809@flay>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <461030000.1057165809@flay>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 02, 2003 at 10:10:09AM -0700, Martin J. Bligh wrote:
> Maybe I'm just taking this out of context, and it's twisting my brain,
> but as far as I know, the nonlinear vma's *are* backed by pte_chains.
> That was the whole problem with objrmap having to do conversions, etc.
> 
> Am I just confused for some reason? I was pretty sure that was right ...

you're right:

int install_page(struct mm_struct *mm, struct vm_area_struct *vma,
		unsigned long addr, struct page *page, pgprot_t prot)
[..]
	flush_icache_page(vma, page);
	set_pte(pte, mk_pte(page, prot));
	pte_chain = page_add_rmap(page, pte, pte_chain);
	pte_unmap(pte);
[..]

(this make me understand better some of the arguments in the previous
emails too ;)

So ether we declare 32bit archs obsolete in production with 2.6, or we
drop rmap behind remap_file_pages.

actually other more invasive ways could be to move rmap into highmem.
Also the page clustering could also hide part of the mem overhead by
assuming the pagetables to be contiguos, but page clustering isn't part
of mainline yet either.

Something has to change since IMHO in the current 2.5.73 remap_file_pages
is nearly useless.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
