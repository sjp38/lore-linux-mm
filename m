Date: Thu, 10 Jan 2008 01:20:21 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 1/4] include: add callbacks to toggle reference counting for VM_MIXEDMAP pages
Message-ID: <20080110002021.GC19997@wotan.suse.de>
References: <476A73F0.4070704@de.ibm.com> <476A7D21.7070607@de.ibm.com> <20071221004556.GB31040@wotan.suse.de> <476B9000.2090707@de.ibm.com> <20071221102052.GB28484@wotan.suse.de> <476B96D6.2010302@de.ibm.com> <20071221104701.GE28484@wotan.suse.de> <1199784954.25114.27.camel@cotte.boeblingen.de.ibm.com> <1199891032.28689.9.camel@cotte.boeblingen.de.ibm.com> <1199891645.28689.22.camel@cotte.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1199891645.28689.22.camel@cotte.boeblingen.de.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Carsten Otte <cotte@de.ibm.com>
Cc: carsteno@de.ibm.com, Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 09, 2008 at 04:14:05PM +0100, Carsten Otte wrote:
> From: Carsten Otte <cotte@de.ibm.com>
> 
> include: add callbacks to toggle reference counting for VM_MIXEDMAP pages
> 
> This patch introduces two arch callbacks, which may optionally be implemented
> in case the architecutre does define __HAVE_ARCH_PTEP_NOREFCOUNT.
> 
> The first callback, pte_set_norefcount(__pte) is called by core-vm to indicate
> that subject page table entry is going to be inserted into a VM_MIXEDMAP vma.
> default implementation: 	noop
> s390 implementation:		set sw defined bit in pte
> proposed arm implementation:	noop
> 
> The second callback, mixedmap_refcount_pte(__pte) is called by core-vm to
> figure out whether or not subject pte requires reference counting in the
> corresponding struct page entry. A non-zero result indicates reference counting
> is required.
> default implementation:		(1)
> s390 implementation:		query sw defined bit in pte
> proposed arm implementation:	convert pte_t to pfn, use pfn_valid()
> 
> Signed-off-by: Carsten Otte <cotte@de.ibm.com>


Hmm, I had it in my mind that this would be entirely hidden in the s390's
mixedmap_refcount_pfn, but of course you actually need to set the pte too....

In that case, I would rather prefer to go along the lines of my pte_special
patch, which would replace all of vm_normal_page (on a per-arch basis), and
you wouldn't need this mixedmap_refcount_* stuff (it can stay pfn_valid for
those architectures that don't implement pte_special).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
