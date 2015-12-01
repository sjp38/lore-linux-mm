Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id A6D276B0038
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 16:04:16 -0500 (EST)
Received: by padhx2 with SMTP id hx2so16643728pad.1
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 13:04:16 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id dx9si13133998pab.202.2015.12.01.13.04.15
        for <linux-mm@kvack.org>;
        Tue, 01 Dec 2015 13:04:15 -0800 (PST)
Date: Tue, 1 Dec 2015 23:04:11 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 3/9] mm: postpone page table allocation until do_set_pte()
Message-ID: <20151201210411.GB135984@black.fi.intel.com>
References: <1447889136-6928-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1447889136-6928-4-git-send-email-kirill.shutemov@linux.intel.com>
 <565E08C5.8090607@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <565E08C5.8090607@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Dec 01, 2015 at 12:53:25PM -0800, Dave Hansen wrote:
> On 11/18/2015 03:25 PM, Kirill A. Shutemov wrote:
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -2068,11 +2068,6 @@ void filemap_map_pages(struct fault_env *fe,
> ...
> >  		if (file->f_ra.mmap_miss > 0)
> >  			file->f_ra.mmap_miss--;
> > -		do_set_pte(fe, page);
> > +
> > +		fe->address += (iter.index - last_pgoff) << PAGE_SHIFT;
> > +		if (fe->pte)
> > +			fe->pte += iter.index - last_pgoff;
> > +		last_pgoff = iter.index;
> > +		if (do_set_pte(fe, NULL, page)) {
> > +			/* failed to setup page table: giving up */
> > +			if (!fe->pte)
> > +				break;
> > +			goto unlock;
> > +		}
> >  		unlock_page(page);
> >  		goto next;
> 
> Hey Kirill,
> 
> Is there a case here where do_set_pte() returns an error and _still_
> manages to populate fe->pte?

Yes. If the page is already mapped, we will get VM_FAULT_NOPAGE:

do_set_pte()
  pte_alloc_one_map()
    !pmd_none(*fe->pmd) => goto map_pte;
    fe->pte = pte_offset_map_lock()
  !pte_none(*fe->pte) => return VM_FAULT_NOPAGE;

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
