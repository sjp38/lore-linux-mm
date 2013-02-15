Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id A56666B0025
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 10:02:08 -0500 (EST)
Date: Fri, 15 Feb 2013 16:02:05 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: introduce __linear_page_index()
Message-ID: <20130215150205.GC31037@dhcp22.suse.cz>
References: <1360047819-6669-1-git-send-email-b32955@freescale.com>
 <20130205132741.1e1a4e04.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130205132741.1e1a4e04.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Huang Shijie <b32955@freescale.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 05-02-13 13:27:41, Andrew Morton wrote:
[...]
> > +static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
> > +					unsigned long address)
> > +{
> >  	if (unlikely(is_vm_hugetlb_page(vma)))
> >  		return linear_hugepage_index(vma, address);
> > -	pgoff = (address - vma->vm_start) >> PAGE_SHIFT;
> > -	pgoff += vma->vm_pgoff;
> > -	return pgoff >> (PAGE_CACHE_SHIFT - PAGE_SHIFT);
> > +	return __linear_page_index(vma, address) >>
> > +				(PAGE_CACHE_SHIFT - PAGE_SHIFT);
> >  }
> 
> I don't think we need bother creating both linear_page_index() and
> __linear_page_index().  Realistically, we won't be supporting
> PAGE_SHIFT!=PAGE_CACHE_SHIFT.  And most (or all?) of the sites which
> you changed should have been using PAGE_CACHE_SHIFT anyway!

Except for hugetlb (huge_pmd_share, unmap_ref_private) which uses
PAGE_SHIFT to get an index into mapping. History proves there was
some confusion about those in the past (36e4f20a fixing 0c176d52). So
__linear_page_index makes some sense here.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
