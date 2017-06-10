Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 296156B0292
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 23:03:49 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id q78so25994586pfj.9
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 20:03:49 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id h34si2283292pld.85.2017.06.09.20.03.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Jun 2017 20:03:48 -0700 (PDT)
Date: Fri, 9 Jun 2017 21:03:46 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 1/3] mm: add vm_insert_mixed_mkwrite()
Message-ID: <20170610030346.GA3575@linux.intel.com>
References: <20170607204859.13104-1-ross.zwisler@linux.intel.com>
 <CAA9_cmcPsyZCB7-pd9djL0+bLamfL49SJVgkyoJ22G6tgOxyww@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA9_cmcPsyZCB7-pd9djL0+bLamfL49SJVgkyoJ22G6tgOxyww@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-xfs@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Matthew Wilcox <mawilcox@microsoft.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Jonathan Corbet <corbet@lwn.net>, Steven Rostedt <rostedt@goodmis.org>, linux-doc@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@redhat.com>, Andreas Dilger <adilger.kernel@dilger.ca>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, ext4 hackers <linux-ext4@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

On Fri, Jun 09, 2017 at 02:23:51PM -0700, Dan Williams wrote:
> On Wed, Jun 7, 2017 at 1:48 PM, Ross Zwisler
> <ross.zwisler@linux.intel.com> wrote:
> > To be able to use the common 4k zero page in DAX we need to have our PTE
> > fault path look more like our PMD fault path where a PTE entry can be
> > marked as dirty and writeable as it is first inserted, rather than waiting
> > for a follow-up dax_pfn_mkwrite() => finish_mkwrite_fault() call.
> >
> > Right now we can rely on having a dax_pfn_mkwrite() call because we can
> > distinguish between these two cases in do_wp_page():
> >
> >         case 1: 4k zero page => writable DAX storage
> >         case 2: read-only DAX storage => writeable DAX storage
> >
> > This distinction is made by via vm_normal_page().  vm_normal_page() returns
> > false for the common 4k zero page, though, just as it does for DAX ptes.
> > Instead of special casing the DAX + 4k zero page case, we will simplify our
> > DAX PTE page fault sequence so that it matches our DAX PMD sequence, and
> > get rid of dax_pfn_mkwrite() completely.
> >
> > This means that insert_pfn() needs to follow the lead of insert_pfn_pmd()
> > and allow us to pass in a 'mkwrite' flag.  If 'mkwrite' is set insert_pfn()
> > will do the work that was previously done by wp_page_reuse() as part of the
> > dax_pfn_mkwrite() call path.
> >
> > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> > ---
> >  include/linux/mm.h |  9 +++++++--
> >  mm/memory.c        | 21 ++++++++++++++-------
> >  2 files changed, 21 insertions(+), 9 deletions(-)
> >
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index b892e95..11e323a 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -2294,10 +2294,15 @@ int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
> >                         unsigned long pfn);
> >  int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
> >                         unsigned long pfn, pgprot_t pgprot);
> > -int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
> > -                       pfn_t pfn);
> > +int vm_insert_mixed_mkwrite(struct vm_area_struct *vma, unsigned long addr,
> > +                       pfn_t pfn, bool mkwrite);
> 
> Are there any other planned public users of vm_insert_mixed_mkwrite()
> that would pass false? I think not.
> 
> >  int vm_iomap_memory(struct vm_area_struct *vma, phys_addr_t start, unsigned long len);
> >
> > +static inline int vm_insert_mixed(struct vm_area_struct *vma,
> > +               unsigned long addr, pfn_t pfn)
> > +{
> > +       return vm_insert_mixed_mkwrite(vma, addr, pfn, false);
> > +}
> 
> ...in other words instead of making the distinction of
> vm_insert_mixed_mkwrite() and vm_insert_mixed() with extra flag
> argument just move the distinction into mm/memory.c directly.
> 
> So, the prototype remains the same as vm_insert_mixed()
> 
> int vm_insert_mixed_mkwrite(struct vm_area_struct *vma, unsigned long
> addr, pfn_t pfn);
> 
> ...and only static insert_pfn(...) needs to change.

My usage of vm_insert_mixed_mkwrite() in fs/dax.c needs the mkwrite flag to be
there.  From dax_insert_mapping():

        return vm_insert_mixed_mkwrite(vma, vaddr, pfn,
	                        vmf->flags & FAULT_FLAG_WRITE);

So, yes, we could do what you suggest, but then that code becomes:

	if (vmf->flags & FAULT_FLAG_WRITE)
		vm_insert_mixed_mkwrite(vma, vaddr, pfn);
	else
		vm_insert_mixed(vma, vaddr, pfn);

And vm_insert_mixed_mkwrite() and vm_insert_mixed() are redundant with only
the insert_pfn() line differing?  This doesn't seem better...unless I'm
missing something?

The way it is, vm_insert_mixed_mkwrite() also closely matches
insert_pfn_pmd(), which we use in the PMD case and which also takes a 'write'
boolean which works the same as our newly added 'mkwrite'.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
