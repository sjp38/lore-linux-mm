Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4F40C6B037A
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 09:52:08 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id n189so62217186pga.4
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 06:52:08 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id e85si30982152pfj.218.2016.12.22.06.52.06
        for <linux-mm@kvack.org>;
        Thu, 22 Dec 2016 06:52:07 -0800 (PST)
Date: Thu, 22 Dec 2016 23:52:03 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: pmd dirty emulation in page fault handler
Message-ID: <20161222145203.GA18970@bbox>
References: <1482364101-16204-1-git-send-email-minchan@kernel.org>
 <20161222081713.GA32480@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161222081713.GA32480@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Jason Evans <je@fb.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, "[4.5+]" <stable@vger.kernel.org>, Andreas Schwab <schwab@suse.de>

Hello,

On Thu, Dec 22, 2016 at 11:17:13AM +0300, Kirill A. Shutemov wrote:

< snip >
> > diff --git a/mm/memory.c b/mm/memory.c
> > index 36c774f..7408ddc 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -3637,18 +3637,20 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
> >  			if (pmd_protnone(orig_pmd) && vma_is_accessible(vma))
> >  				return do_huge_pmd_numa_page(&vmf, orig_pmd);
> >  
> > -			if ((vmf.flags & FAULT_FLAG_WRITE) &&
> > -					!pmd_write(orig_pmd)) {
> > -				ret = wp_huge_pmd(&vmf, orig_pmd);
> > -				if (!(ret & VM_FAULT_FALLBACK))
> > +			if (vmf.flags & FAULT_FLAG_WRITE) {
> > +				if (!pmd_write(orig_pmd)) {
> > +					ret = wp_huge_pmd(&vmf, orig_pmd);
> > +					if (ret == VM_FAULT_FALLBACK)
> 
> In theory, more than one flag can be set and it would lead to
> false-negative. Bit check was the right thing.
> 
> And I don't understand why do you need to change code in
> __handle_mm_fault() at all.
> From what I see change to huge_pmd_set_accessed() should be enough.

Yeb. Thanks for the review. Here v2 goes.
