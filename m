Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E2FC96B0003
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 08:25:34 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id m79so766512wma.7
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 05:25:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g27sor3494396edf.34.2018.03.16.05.25.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Mar 2018 05:25:33 -0700 (PDT)
Date: Fri, 16 Mar 2018 15:25:08 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm/shmem: Do not wait for lock_page() in
 shmem_unused_huge_shrink()
Message-ID: <20180316122508.fv4edpx34hdqybwx@node.shutemov.name>
References: <20180316105908.62516-1-kirill.shutemov@linux.intel.com>
 <20180316121303.GI23100@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180316121303.GI23100@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Fri, Mar 16, 2018 at 01:13:03PM +0100, Michal Hocko wrote:
> On Fri 16-03-18 13:59:08, Kirill A. Shutemov wrote:
> [..]
> > @@ -498,31 +498,42 @@ static unsigned long shmem_unused_huge_shrink(struct shmem_sb_info *sbinfo,
> >  			continue;
> >  		}
> >  
> > -		page = find_lock_page(inode->i_mapping,
> > +		page = find_get_page(inode->i_mapping,
> >  				(inode->i_size & HPAGE_PMD_MASK) >> PAGE_SHIFT);
> >  		if (!page)
> >  			goto drop;
> >  
> > +		/* No huge page at the end of the file: nothing to split */
> >  		if (!PageTransHuge(page)) {
> > -			unlock_page(page);
> >  			put_page(page);
> >  			goto drop;
> >  		}
> >  
> > +		/*
> > +		 * Leave the inode on the list if we failed to lock
> > +		 * the page at this time.
> > +		 *
> > +		 * Waiting for the lock may lead to deadlock in the
> > +		 * reclaim path.
> > +		 */
> > +		if (!trylock_page(page)) {
> > +			put_page(page);
> > +			goto leave;
> > +		}
> 
> Can somebody split the huge page after the PageTransHuge check and
> before we lock it?

Nope. Pin on the page is enough to prevent split.

-- 
 Kirill A. Shutemov
