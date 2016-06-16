Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id DCF8D6B0253
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 11:43:26 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id jf8so29391576lbc.3
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 08:43:26 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id uq9si6063537wjb.114.2016.06.16.08.43.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 08:43:25 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id m124so12373280wme.3
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 08:43:25 -0700 (PDT)
Date: Thu, 16 Jun 2016 17:43:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: fix account pmd page to the process
Message-ID: <20160616154324.GN6836@dhcp22.suse.cz>
References: <1466076971-24609-1-git-send-email-zhongjiang@huawei.com>
 <20160616154214.GA12284@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160616154214.GA12284@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

[It seems that this patch has been sent several times and this
particular copy didn't add Kirill who has added this code CC him now]

On Thu 16-06-16 17:42:14, Michal Hocko wrote:
> On Thu 16-06-16 19:36:11, zhongjiang wrote:
> > From: zhong jiang <zhongjiang@huawei.com>
> > 
> > when a process acquire a pmd table shared by other process, we
> > increase the account to current process. otherwise, a race result
> > in other tasks have set the pud entry. so it no need to increase it.
> > 
> > Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> > ---
> >  mm/hugetlb.c | 5 ++---
> >  1 file changed, 2 insertions(+), 3 deletions(-)
> > 
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index 19d0d08..3b025c5 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -4189,10 +4189,9 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
> >  	if (pud_none(*pud)) {
> >  		pud_populate(mm, pud,
> >  				(pmd_t *)((unsigned long)spte & PAGE_MASK));
> > -	} else {
> > +	} else 
> >  		put_page(virt_to_page(spte));
> > -		mm_inc_nr_pmds(mm);
> > -	}
> 
> The code is quite puzzling but is this correct? Shouldn't we rather do
> mm_dec_nr_pmds(mm) in that path to undo the previous inc?
> 
> > +
> >  	spin_unlock(ptl);
> >  out:
> >  	pte = (pte_t *)pmd_alloc(mm, pud, addr);
> > -- 
> > 1.8.3.1
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
