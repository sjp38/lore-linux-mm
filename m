Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id A2ACE6B0003
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 08:58:32 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id bb5-v6so5386761plb.22
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 05:58:32 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b12si5079862pge.24.2018.03.16.05.58.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Mar 2018 05:58:31 -0700 (PDT)
Date: Fri, 16 Mar 2018 13:58:27 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/shmem: Do not wait for lock_page() in
 shmem_unused_huge_shrink()
Message-ID: <20180316125827.GC11461@dhcp22.suse.cz>
References: <20180316105908.62516-1-kirill.shutemov@linux.intel.com>
 <20180316121303.GI23100@dhcp22.suse.cz>
 <20180316122508.fv4edpx34hdqybwx@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180316122508.fv4edpx34hdqybwx@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Eric Wheeler <linux-mm@lists.ewheeler.net>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

On Fri 16-03-18 15:25:08, Kirill A. Shutemov wrote:
> On Fri, Mar 16, 2018 at 01:13:03PM +0100, Michal Hocko wrote:
> > On Fri 16-03-18 13:59:08, Kirill A. Shutemov wrote:
> > [..]
> > > @@ -498,31 +498,42 @@ static unsigned long shmem_unused_huge_shrink(struct shmem_sb_info *sbinfo,
> > >  			continue;
> > >  		}
> > >  
> > > -		page = find_lock_page(inode->i_mapping,
> > > +		page = find_get_page(inode->i_mapping,
> > >  				(inode->i_size & HPAGE_PMD_MASK) >> PAGE_SHIFT);
> > >  		if (!page)
> > >  			goto drop;
> > >  
> > > +		/* No huge page at the end of the file: nothing to split */
> > >  		if (!PageTransHuge(page)) {
> > > -			unlock_page(page);
> > >  			put_page(page);
> > >  			goto drop;
> > >  		}
> > >  
> > > +		/*
> > > +		 * Leave the inode on the list if we failed to lock
> > > +		 * the page at this time.
> > > +		 *
> > > +		 * Waiting for the lock may lead to deadlock in the
> > > +		 * reclaim path.
> > > +		 */
> > > +		if (!trylock_page(page)) {
> > > +			put_page(page);
> > > +			goto leave;
> > > +		}
> > 
> > Can somebody split the huge page after the PageTransHuge check and
> > before we lock it?
> 
> Nope. Pin on the page is enough to prevent split.

Good, I thought so but wasn't really 100% sure. Thanks for the
clarification and feel free to add
Acked-by: Michal Hocko <mhocko@suse.com>

Maybe you should stick
Reported-by: Eric Wheeler <linux-mm@lists.ewheeler.net>
and point to http://lkml.kernel.org/r/alpine.LRH.2.11.1801242349220.30642@mail.ewheeler.net
because that smells like a bug that this patch would be fixing.
-- 
Michal Hocko
SUSE Labs
