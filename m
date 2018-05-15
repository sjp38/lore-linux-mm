Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7784A6B027D
	for <linux-mm@kvack.org>; Tue, 15 May 2018 08:07:59 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id m10-v6so18847303otb.5
        for <linux-mm@kvack.org>; Tue, 15 May 2018 05:07:59 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p7-v6si3665891oig.358.2018.05.15.05.07.58
        for <linux-mm@kvack.org>;
        Tue, 15 May 2018 05:07:58 -0700 (PDT)
Date: Tue, 15 May 2018 13:07:51 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH] mm: Add new vma flag VM_LOCAL_CPU
Message-ID: <20180515120750.lro2qbskw5cptc5o@lakrids.cambridge.arm.com>
References: <0efb5547-9250-6b6c-fe8e-cf4f44aaa5eb@netapp.com>
 <20180514191551.GA27939@bombadil.infradead.org>
 <7ec6fa37-8529-183d-d467-df3642bcbfd2@netapp.com>
 <20180515004137.GA5168@bombadil.infradead.org>
 <f3a66d8b-b9dc-b110-08aa-a63f0c309fb2@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f3a66d8b-b9dc-b110-08aa-a63f0c309fb2@netapp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boazh@netapp.com>
Cc: Matthew Wilcox <willy@infradead.org>, Jeff Moyer <jmoyer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Amit Golander <Amit.Golander@netapp.com>

On Tue, May 15, 2018 at 01:43:23PM +0300, Boaz Harrosh wrote:
> On 15/05/18 03:41, Matthew Wilcox wrote:
> > On Mon, May 14, 2018 at 10:37:38PM +0300, Boaz Harrosh wrote:
> >> On 14/05/18 22:15, Matthew Wilcox wrote:
> >>> On Mon, May 14, 2018 at 08:28:01PM +0300, Boaz Harrosh wrote:
> >>>> On a call to mmap an mmap provider (like an FS) can put
> >>>> this flag on vma->vm_flags.
> >>>>
> >>>> The VM_LOCAL_CPU flag tells the Kernel that the vma will be used
> >>>> from a single-core only, and therefore invalidation (flush_tlb) of
> >>>> PTE(s) need not be a wide CPU scheduling.
> >>>
> >>> I still don't get this.  You're opening the kernel up to being exploited
> >>> by any application which can persuade it to set this flag on a VMA.
> >>>
> >>
> >> No No this is not an application accessible flag this can only be set
> >> by the mmap implementor at ->mmap() time (Say same as VM_VM_MIXEDMAP).
> >>
> >> Please see the zuf patches for usage (Again apologise for pushing before
> >> a user)
> >>
> >> The mmap provider has all the facilities to know that this can not be
> >> abused, not even by a trusted Server.
> > 
> > I don't think page tables work the way you think they work.
> > 
> > +               err = vm_insert_pfn_prot(zt->vma, zt_addr, pfn, prot);
> > 
> > That doesn't just insert it into the local CPU's page table.  Any CPU
> > which directly accesses or even prefetches that address will also get
> > the translation into its cache.
> > 
> 
> Yes I know, but that is exactly the point of this flag. I know that this
> address is only ever accessed from a single core. Because it is an mmap (vma)
> of an O_TMPFILE-exclusive file created in a core-pinned thread and I allow
> only that thread any kind of access to this vma. Both the filehandle and the
> mmaped pointer are kept on the thread stack and have no access from outside.

Even if (in the specific context of your application) software on other
cores might not explicitly access this area, that does not prevent
allocations into TLBs, and TLB maintenance *cannot* be elided.

Even assuming that software *never* explicitly accesses an address which
it has not mapped is insufficient.

For example, imagine you have two threads, each pinned to a CPU, and
some local_cpu_{mmap,munmap} which uses your new flag:

	CPU0				CPU1
	x = local_cpu_mmap(...);
	do_things_with(x);
					// speculatively allocates TLB
					// entries for X.

	// only invalidates local TLBs
	local_cpu_munmap(x);

					// TLB entries for X still live
	
					y = local_cpu_mmap(...);

					// if y == x, we can hit the
					// stale TLB entry, and access
					// the wrong page
					do_things_with(y);

Consider that after we free x, the kernel could reuse the page for any
purpose (e.g. kernel page tables), so this is a major risk.

This flag simply is not safe, unless the *entire* mm is only ever
accessed from a single CPU. In that case, we don't need the flag anyway,
as the mm already has a cpumask.

Thanks,
Mark.
