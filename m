Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id 00E876B0035
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 08:49:04 -0500 (EST)
Received: by mail-ee0-f42.google.com with SMTP id e53so697509eek.1
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 05:49:04 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e48si93414992eeh.8.2014.01.08.05.49.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 08 Jan 2014 05:49:04 -0800 (PST)
Date: Wed, 8 Jan 2014 14:49:03 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: could you clarify mm/mempolicy: fix !vma in new_vma_page()
Message-ID: <20140108134903.GI27937@dhcp22.suse.cz>
References: <CAA_GA1dNdrG9aQ3UKDA0O=BY721rvseORVkc2+RxUpzysp3rYw@mail.gmail.com>
 <20140106141827.GB27602@dhcp22.suse.cz>
 <CAA_GA1csMEhSYmeS7qgDj7h=Xh2WrsYvirkS55W4Jj3LTHy87A@mail.gmail.com>
 <20140107102212.GC8756@dhcp22.suse.cz>
 <20140107173034.GE8756@dhcp22.suse.cz>
 <CAA_GA1fN5p3-m40Mf3nqFzRrGcJ9ni9Cjs_q4fm1PCLnzW1cEw@mail.gmail.com>
 <20140108100859.GC27937@dhcp22.suse.cz>
 <CAA_GA1emcHt+9zOqAKHPoXLd-ofyfYyuQn9fcdLOox5k7BLgww@mail.gmail.com>
 <20140108124240.GH27937@dhcp22.suse.cz>
 <CAA_GA1dh3TtzGnK0HgAb_Sy6ww5JBaFqmf_YViPKpMCEpzFh4w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA_GA1dh3TtzGnK0HgAb_Sy6ww5JBaFqmf_YViPKpMCEpzFh4w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bob Liu <bob.liu@oracle.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 08-01-14 21:10:29, Bob Liu wrote:
[...]
> >> > From 2d61421f26a3b63b4670d71b7adc67e2191b6157 Mon Sep 17 00:00:00 2001
> >> > From: Michal Hocko <mhocko@suse.cz>
> >> > Date: Wed, 8 Jan 2014 10:57:41 +0100
> >> > Subject: [PATCH] mm: new_vma_page cannot see NULL vma for hugetlb pages
> >> >
> >> > 11c731e81bb0 (mm/mempolicy: fix !vma in new_vma_page()) has removed
> >> > BUG_ON(!vma) from new_vma_page which is partially correct because
> >> > page_address_in_vma will return EFAULT for non-linear mappings and at
> >> > least shared shmem might be mapped this way.
> >> >
> >> > The patch also tried to prevent NULL ptr for hugetlb pages which is not
> >> > correct AFAICS because hugetlb pages cannot be mapped as VM_NONLINEAR
> >> > and other conditions in page_address_in_vma seem to be legit and catch
> >> > real bugs.
> >> >
> >> > This patch restores BUG_ON for PageHuge to catch potential issues when
> >> > the to-be-migrated page is not setup properly.
> >> >
> >> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> Reviewed-by: Bob Liu <bob.liu@oracle.com>

Thanks!

> >> > ---
> >> >  mm/mempolicy.c | 6 ++----
> >> >  1 file changed, 2 insertions(+), 4 deletions(-)
> >> >
> >> > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> >> > index 9e8d2d86978a..f3f51464a23b 100644
> >> > --- a/mm/mempolicy.c
> >> > +++ b/mm/mempolicy.c
> >> > @@ -1199,10 +1199,8 @@ static struct page *new_vma_page(struct page *page, unsigned long private, int *
> >> >         }
> >> >
> >> >         if (PageHuge(page)) {
> >> > -               if (vma)
> >> > -                       return alloc_huge_page_noerr(vma, address, 1);
> >> > -               else
> >> > -                       return NULL;
> >> > +               BUG_ON(vma)

That was meant to say BUG_ON(!vma) of course ;) but I guess your
reviewed-by still applies so I will post it to Andrew.

> >> > +               return alloc_huge_page_noerr(vma, address, 1);
> >> >         }
> >> >         /*
> >> >          * if !vma, alloc_page_vma() will use task or system default policy
> >> > --
> >> > 1.8.5.2
> >> >
> 
> -- 
> Regards,
> --Bob

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
