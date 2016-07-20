Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 16E4C6B0005
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 08:45:05 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id x83so32693278wma.2
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 05:45:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o6si824709wjt.125.2016.07.20.05.45.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Jul 2016 05:45:03 -0700 (PDT)
Date: Wed, 20 Jul 2016 14:45:02 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] mm/hugetlb: fix race when migrate pages
Message-ID: <20160720124501.GK11249@dhcp22.suse.cz>
References: <1468935958-21810-1-git-send-email-zhongjiang@huawei.com>
 <20160720073859.GE11249@dhcp22.suse.cz>
 <578F4C7C.6000706@huawei.com>
 <20160720121645.GJ11249@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160720121645.GJ11249@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: vbabka@suse.cz, qiuxishi@huawei.com, akpm@linux-foundation.org, linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>

On Wed 20-07-16 14:16:45, Michal Hocko wrote:
> On Wed 20-07-16 18:03:40, zhong jiang wrote:
> > On 2016/7/20 15:38, Michal Hocko wrote:
> > > [CC Mike and Naoya]
> > > On Tue 19-07-16 21:45:58, zhongjiang wrote:
> > >> From: zhong jiang <zhongjiang@huawei.com>
> > >>
> > >> I hit the following code in huge_pte_alloc when run the database and
> > >> online-offline memory in the system.
> > >>
> > >> BUG_ON(pte && !pte_none(*pte) && !pte_huge(*pte));
> > >>
> > >> when pmd share function enable, we may be obtain a shared pmd entry.
> > >> due to ongoing offline memory , the pmd entry points to the page will
> > >> turn into migrate condition. therefore, the bug will come up.
> > >>
> > >> The patch fix it by checking the pmd entry when we obtain the lock.
> > >> if the shared pmd entry points to page is under migration. we should
> > >> allocate a new pmd entry.
> > >
> > > I am still not 100% sure this is correct. Does huge_pte_lockptr work
> > > properly for the migration swapentry?
> 
> What about this part?
> 
> > > If yes and we populate the pud
> > > with a migration entry then is it really bad/harmful (other than hitting
> > > the BUG_ON which might be update to handle that case)? This might be a
> > > stupid question, sorry about that, but I have really problem to grasp
> > > the whole issue properly and the changelog didn't help me much. I would
> > > really appreciate some clarification here. The pmd sharing code is clear
> > > as mud and adding new tweaks there doesn't sound like it would make it
> > > more clear.
> >
> >     ok, Maybe the following explain will better.
> >     cpu0                                                                      cpu1
> >     try_to_unmap_one                                 huge_pmd_share                             
> >         page_check_address                                 huge_pte_lockptr
> >                       spin_lock                                                        
> >        (page entry can be set to migrate or
> >        Posion )      
> >  
> >          pte_unmap_unlock
> >                                                                             spin_lock
> >                                                                             (page entry have changed)
> 
> Well, but this is just one possible race. We can also race after
> pud_populate:
> 
> cpu0				cpu1
> try_to_unmap_on			huge_pmd_share
>   page_check_address		  huge_pte_lockptr
>   				    spin_lock
> 				    pud_populate
> 				    spin_unlock
>   spin_lock(ptl)
>   set_migration_entry
>   spun_unlock()
>   				  pmd_alloc # we will get migration entry
> 
> So unless I am missing something here we either have to be able to cope
> with migration entries somehow already or we need some additional care
> for shared pmd entries (aka shared pud page) for this to behave
> properly.

I was talking to Mel (CCed) and he has raised a good question. So if you
encounter a page under migration and fail to share the pmd with it how
can you have a proper content of the target page in the end? So not only
the patch doesn't catch the other race I believe it can lead to a
corruption (which is my fault because your previous version did retry
rather than fail). But anyway the primary question is whether seeing
migration entry here is really a problem and just the BUG_ON needs to be
fixed.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
