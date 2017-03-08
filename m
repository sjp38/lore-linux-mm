Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 628D76B039A
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 01:41:51 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id v190so42666321pfb.5
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 22:41:51 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id k2si2309914pga.293.2017.03.07.22.41.49
        for <linux-mm@kvack.org>;
        Tue, 07 Mar 2017 22:41:50 -0800 (PST)
Date: Wed, 8 Mar 2017 15:41:47 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 05/11] mm: make the try_to_munlock void function
Message-ID: <20170308064147.GG11206@bbox>
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
 <1488436765-32350-6-git-send-email-minchan@kernel.org>
 <20170307151747.GA2940@node.shutemov.name>
MIME-Version: 1.0
In-Reply-To: <20170307151747.GA2940@node.shutemov.name>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Mar 07, 2017 at 06:17:47PM +0300, Kirill A. Shutemov wrote:
> On Thu, Mar 02, 2017 at 03:39:19PM +0900, Minchan Kim wrote:
> > try_to_munlock returns SWAP_MLOCK if the one of VMAs mapped
> > the page has VM_LOCKED flag. In that time, VM set PG_mlocked to
> > the page if the page is not pte-mapped THP which cannot be
> > mlocked, either.
> > 
> > With that, __munlock_isolated_page can use PageMlocked to check
> > whether try_to_munlock is successful or not without relying on
> > try_to_munlock's retval. It helps to make ttu/ttuo simple with
> > upcoming patches.
> 
> I *think* you're correct, but it took time to wrap my head around.
> We basically rely on try_to_munlock() never caller for PTE-mapped THP.
> And we don't at the moment.
> 
> It worth adding something like
> 
> 	VM_BUG_ON_PAGE(PageCompound(page) && PageDoubleMap(page), page);
> 
> into try_to_munlock().

Agree.

> 
> Otherwise looks good to me.
> 
> Will free adding my Acked-by once this nit is addressed.

Thanks for the review this part, Kirill!

> 
> -- 
>  Kirill A. Shutemov
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
