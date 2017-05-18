Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 03133831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 17:30:06 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id t12so43693413pgo.7
        for <linux-mm@kvack.org>; Thu, 18 May 2017 14:30:05 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id h34si6272662pld.85.2017.05.18.14.30.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 May 2017 14:30:04 -0700 (PDT)
Date: Thu, 18 May 2017 15:29:39 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 2/2] dax: Fix race between colliding PMD & PTE entries
Message-ID: <20170518212939.GA28029@linux.intel.com>
References: <20170517171639.14501-1-ross.zwisler@linux.intel.com>
 <20170517171639.14501-2-ross.zwisler@linux.intel.com>
 <20170518075037.GA9084@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170518075037.GA9084@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Pawel Lebioda <pawel.lebioda@intel.com>, Dave Jiang <dave.jiang@intel.com>, Xiong Zhou <xzhou@redhat.com>, Eryu Guan <eguan@redhat.com>, stable@vger.kernel.org

On Thu, May 18, 2017 at 09:50:37AM +0200, Jan Kara wrote:
> On Wed 17-05-17 11:16:39, Ross Zwisler wrote:
> > We currently have two related PMD vs PTE races in the DAX code.  These can
> > both be easily triggered by having two threads reading and writing
> > simultaneously to the same private mapping, with the key being that private
> > mapping reads can be handled with PMDs but private mapping writes are
> > always handled with PTEs so that we can COW.
> > 
> > Here is the first race:
> > 
> > CPU 0					CPU 1
> > 
> > (private mapping write)
> > __handle_mm_fault()
> >   create_huge_pmd() - FALLBACK
> >   handle_pte_fault()
> >     passes check for pmd_devmap()
> > 
> > 					(private mapping read)
> > 					__handle_mm_fault()
> > 					  create_huge_pmd()
> > 					    dax_iomap_pmd_fault() inserts PMD
> > 
> >     dax_iomap_pte_fault() does a PTE fault, but we already have a DAX PMD
> >     			  installed in our page tables at this spot.
> >
> > 
> > Here's the second race:
> > 
> > CPU 0					CPU 1
> > 
> > (private mapping write)
> > __handle_mm_fault()
> >   create_huge_pmd() - FALLBACK
> > 					(private mapping read)
> > 					__handle_mm_fault()
> > 					  passes check for pmd_none()
> > 					  create_huge_pmd()
> > 
> >   handle_pte_fault()
> >     dax_iomap_pte_fault() inserts PTE
> > 					    dax_iomap_pmd_fault() inserts PMD,
> > 					       but we already have a PTE at
> > 					       this spot.
> 
> So I don't see how this second scenario can happen. dax_iomap_pmd_fault()
> will call grab_mapping_entry(). That will either find PTE entry in the
> radix tree -> EEXIST and we retry the fault. Or we will not find PTE entry
> -> try to insert PMD entry which collides with the PTE entry -> EEXIST and
> we retry the fault. Am I missing something?

Yep, sorry, I guess I needed a few extra steps in my flow (the initial private
mapping read by CPU 0):


CPU 0					CPU 1

(private mapping read)
__handle_mm_fault()
  passes check for pmd_none()
  create_huge_pmd()
    dax_iomap_pmd_fault() inserts PMD

(private mapping write)
__handle_mm_fault()
  create_huge_pmd() - FALLBACK
					(private mapping read)
					__handle_mm_fault()
					  passes check for pmd_none()
					  create_huge_pmd()

  handle_pte_fault()
    dax_iomap_pte_fault() inserts PTE
					    dax_iomap_pmd_fault() inserts PMD,
					       but we already have a PTE at
					       this spot.

So what happens is that CPU 0 inserts a DAX PMD into the radix tree that has
real storage backing, and all PTE and PMD faults just use that same PMD radix
tree entry for locking and dirty tracking.

> The first scenario seems to be possible. dax_iomap_pmd_fault() will create
> PMD entry in the radix tree. Then dax_iomap_pte_fault() will come, do
> grab_mapping_entry(), there it sees entry is PMD but we are doing PTE fault
> so I'd think that pmd_downgrade = true... But actually the condition there
> doesn't trigger in this case. And that's a catch that although we asked
> grab_mapping_entry() for PTE, we've got PMD back and that screws us later.

Yep, it was a concious decision when implementing the PMD support to allow one
thread to use PMDs and another to use PTEs in the same range, as long as the
thread faulting in PMDs is the first to insert into the radix tree.  A PMD
radix tree entry will be inserted and used for locking and dirty tracking, and
each thread or process can fault in either PTEs or PMDs into its own address
space as needed.

We can revisit this, if you think it is incorrect.  The option you outline
below would basically mean that if any thread were to fault in a PTE in a
range, all threads and processes would be forced to use PTEs because we would
use PTEs in the radix tree.

This is cleaner...I'm not sure if the use case of having two threads accessing
the same area, one with PTEs and one with PMDs, is actually prevalent.  It's
also maybe a bit weird that the current behavior varies based on which thread
faulted first - if the PTE thread faults first, it'll insert a PTE into the
radix tree and everyone will just use PTEs.

> Actually I'm not convinced your patch quite fixes this because
> dax_load_hole() or dax_insert_mapping_entry() will modify the passed entry
> with the assumption that it's PTE entry and so they will likely corrupt the
> entry in the radix tree.

I don't think we can ever call dax_load_hole() if we have a DAX PMD entry in
the radix tree, because we have a block mapping from the filesystem.

For dax_insert_mapping_entry(), we do the right thing.  From the comments
above the function:

 * If we happen to be trying to insert a PTE and there is a PMD
 * already in the tree, we will skip the insertion and just dirty the PMD as
 * appropriate.  If we happen to be trying to insert a PTE and there is a PMD
 * already in the tree, we will skip the insertion and just dirty the PMD as
 * appropriate.

> So I think to fix the first case we should rather modify
> grab_mapping_entry() to properly go through the pmd_downgrade path once we
> find PMD entry and we do PTE fault.
> 
> What do you think?

That could also work, though I do think the fix as submitted is correct.
I think it comes down to whether we want to keep the behavior where a thread
faulting in a PTEs will use an existing PMD entry in the radix tree, instead
of making all other threads fall back to PTEs.

I think either way solves this issue for the DAX case...but do you understand
how this is solved for other fault handlers?  They don't have any isolation
between faults either in the mm/memory.c code, and are susceptible to the same
races.  How do they deal with the fact that by the time they get to their PTE
fault handler, a racing PMD fault handler in another thread could have
inserted a PMD into their page tables, and vice versa?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
