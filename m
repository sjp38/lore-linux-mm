Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0FA116B1FCC
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 09:17:07 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id b88-v6so1653028pfj.4
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 06:17:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p22sor26203750pfi.50.2018.11.20.06.17.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Nov 2018 06:17:05 -0800 (PST)
Date: Tue, 20 Nov 2018 17:17:00 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC PATCH 3/3] mm, fault_around: do not take a reference to a
 locked page
Message-ID: <20181120141700.pwoaxatx3v5xnwos@kshutemo-mobl1>
References: <20181120134323.13007-1-mhocko@kernel.org>
 <20181120134323.13007-4-mhocko@kernel.org>
 <20181120140715.mouc7okin3ht5krr@kshutemo-mobl1>
 <20181120141207.GK22247@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181120141207.GK22247@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Hildenbrand <david@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, Nov 20, 2018 at 03:12:07PM +0100, Michal Hocko wrote:
> On Tue 20-11-18 17:07:15, Kirill A. Shutemov wrote:
> > On Tue, Nov 20, 2018 at 02:43:23PM +0100, Michal Hocko wrote:
> > > From: Michal Hocko <mhocko@suse.com>
> > > 
> > > filemap_map_pages takes a speculative reference to each page in the
> > > range before it tries to lock that page. While this is correct it
> > > also can influence page migration which will bail out when seeing
> > > an elevated reference count. The faultaround code would bail on
> > > seeing a locked page so we can pro-actively check the PageLocked
> > > bit before page_cache_get_speculative and prevent from pointless
> > > reference count churn.
> > 
> > Looks fine to me.
> 
> Thanks for the review.
> 
> > But please drop a line of comment in the code. As is it might be confusing
> > for a reader.
> 
> This?

Yep.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index c76d6a251770..7c4e439a2e85 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2554,6 +2554,10 @@ void filemap_map_pages(struct vm_fault *vmf,
>  
>  		head = compound_head(page);
>  
> +		/*
> +		 * Check the locked pages before taking a reference to not
> +		 * go in the way of migration.
> +		 */
>  		if (PageLocked(head))
>  			goto next;
>  		if (!page_cache_get_speculative(head))
> -- 
> Michal Hocko
> SUSE Labs

-- 
 Kirill A. Shutemov
