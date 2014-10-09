Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id EDABC6B0038
	for <linux-mm@kvack.org>; Thu,  9 Oct 2014 16:40:54 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id v10so371998pde.20
        for <linux-mm@kvack.org>; Thu, 09 Oct 2014 13:40:54 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id yn9si1739842pac.118.2014.10.09.13.40.53
        for <linux-mm@kvack.org>;
        Thu, 09 Oct 2014 13:40:53 -0700 (PDT)
Date: Thu, 9 Oct 2014 16:40:26 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v1 2/7] mm: Prepare for DAX huge pages
Message-ID: <20141009204026.GP5098@wil.cx>
References: <1412774729-23956-1-git-send-email-matthew.r.wilcox@intel.com>
 <1412774729-23956-3-git-send-email-matthew.r.wilcox@intel.com>
 <20141008152124.GA7288@node.dhcp.inet.fi>
 <20141008155758.GK5098@wil.cx>
 <20141008194335.GA9232@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141008194335.GA9232@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Matthew Wilcox <willy@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Oct 08, 2014 at 10:43:35PM +0300, Kirill A. Shutemov wrote:
> On Wed, Oct 08, 2014 at 11:57:58AM -0400, Matthew Wilcox wrote:
> > On Wed, Oct 08, 2014 at 06:21:24PM +0300, Kirill A. Shutemov wrote:
> > > On Wed, Oct 08, 2014 at 09:25:24AM -0400, Matthew Wilcox wrote:
> > > > From: Matthew Wilcox <willy@linux.intel.com>
> > > > 
> > > > DAX wants to use the 'special' bit to mark PMD entries that are not backed
> > > > by struct page, just as for PTEs. 
> > > 
> > > Hm. I don't see where you use PMD without special set.
> > 
> > Right ... I don't currently insert PMDs that point to huge pages of DRAM,
> > only to huge pages of PMEM.
> 
> Looks like you don't need pmd_{mk,}special() then. It seems you have all
> inforamtion you need -- vma -- to find out what's going on. Right?

That would prevent us from putting huge pages of DRAM into a VM_MIXEDMAP |
VM_HUGEPAGE vma.  Is that acceptable to the wider peanut gallery?

> > > No private THP pages with THP? Why?
> > > It should be trivial: we already have a code path for !page case for zero
> > > page and it shouldn't be too hard to modify do_dax_pmd_fault() to support
> > > COW.
> > > 
> > > I remeber I've mentioned that you don't think it's reasonable to allocate
> > > 2M page on COW, but that's what we do for anon memory...
> > 
> > I agree that it shouldn't be too hard, but I have no evidence that it'll
> > be a performance win to COW 2MB pages for MAP_PRIVATE.  I'd rather be
> > cautious for now and we can explore COWing 2MB chunks in a future patch.
> 
> I would rather make it other way around: use the same apporoach as for
> anon memory until data shows it's doesn't make any good. Then consider
> switching COW for *both* anon and file THP to fallback path.
> This way we will get consistent behaviour for both types of mappings.

I'm not sure that we want consistent behaviour for both types of mappings.
My understanding is that they're used for different purposes, and having
different bahaviour is acceptable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
