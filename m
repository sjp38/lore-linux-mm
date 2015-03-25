Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 1AF3A6B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 11:14:05 -0400 (EDT)
Received: by wibgn9 with SMTP id gn9so43743121wib.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 08:14:04 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id hy2si4799552wjb.163.2015.03.25.08.14.03
        for <linux-mm@kvack.org>;
        Wed, 25 Mar 2015 08:14:03 -0700 (PDT)
Date: Wed, 25 Mar 2015 17:13:54 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/3] mm: New pfn_mkwrite same as page_mkwrite for
 VM_PFNMAP
Message-ID: <20150325151354.GA12387@node.dhcp.inet.fi>
References: <5512B961.8070409@plexistor.com>
 <5512BA5D.8070609@plexistor.com>
 <5512CF68.5040509@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5512CF68.5040509@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Boaz Harrosh <boaz@plexistor.com>, Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>

On Wed, Mar 25, 2015 at 08:08:24AM -0700, Dave Hansen wrote:
> On 03/25/2015 06:38 AM, Boaz Harrosh wrote:
> >  /*
> >   * This routine handles present pages, when users try to write
> >   * to a shared page. It is done by copying the page to a new address
> > @@ -2025,8 +2042,17 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
> >  		 * accounting on raw pfn maps.
> >  		 */
> >  		if ((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
> > -				     (VM_WRITE|VM_SHARED))
> > +				     (VM_WRITE|VM_SHARED)) {
> > +			pte_unmap_unlock(page_table, ptl);
> > +			ret = do_pfn_mkwrite(vma, address);
> > +			if (ret & VM_FAULT_ERROR)
> > +				return ret;
> > +			page_table = pte_offset_map_lock(mm, pmd, address,
> > +							 &ptl);
> > +			if (!pte_same(*page_table, orig_pte))
> > +				goto unlock;
> >  			goto reuse;
> > +		}
> >  		goto gotten;
> >  	}
> 
> This adds a lock release/reacquire in a place where the lock was
> previously just held.  Could you explain a bit why this is safe?

It's common practice in page fault codepath. See code around
->page_mkwrite for example.
> 
> Also, that pte_same() check looks a bit fragile.  It seems like it would
> fail if the hardware, for instance, set the accessed bit in here
> somewhere.  Is that what we want?

In this case we will cancel this fault handling and fault again. No
problems here.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
