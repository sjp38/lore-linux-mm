Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 158B46B025E
	for <linux-mm@kvack.org>; Tue, 17 May 2016 08:25:24 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e201so9916338wme.1
        for <linux-mm@kvack.org>; Tue, 17 May 2016 05:25:24 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id v198si3906738wmv.34.2016.05.17.05.25.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 May 2016 05:25:22 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id e201so4360439wme.2
        for <linux-mm@kvack.org>; Tue, 17 May 2016 05:25:22 -0700 (PDT)
Date: Tue, 17 May 2016 14:25:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: + mm-thp-avoid-unnecessary-swapin-in-khugepaged.patch added to
 -mm tree
Message-ID: <20160517122520.GH14453@dhcp22.suse.cz>
References: <57212c60.fUSE244UFwhXE+az%akpm@linux-foundation.org>
 <20160428151921.GL31489@dhcp22.suse.cz>
 <20160517075815.GC14453@dhcp22.suse.cz>
 <20160517090254.GE14453@dhcp22.suse.cz>
 <20160517113114.GC9540@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160517113114.GC9540@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: akpm@linux-foundation.org, ebru.akagunduz@gmail.com, aarcange@redhat.com, aneesh.kumar@linux.vnet.ibm.com, boaz@plexistor.com, gorcunov@openvz.org, hannes@cmpxchg.org, hughd@google.com, iamjoonsoo.kim@lge.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, n-horiguchi@ah.jp.nec.com, riel@redhat.com, rientjes@google.com, vbabka@suse.cz, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Tue 17-05-16 14:31:14, Kirill A. Shutemov wrote:
> On Tue, May 17, 2016 at 11:02:54AM +0200, Michal Hocko wrote:
[...]
> > ---
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index 87f09dc986ab..1a4d4c807d92 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -2389,7 +2389,8 @@ static void __collapse_huge_page_swapin(struct mm_struct *mm,
> >  		swapped_in++;
> >  		ret = do_swap_page(mm, vma, _address, pte, pmd,
> >  				   FAULT_FLAG_ALLOW_RETRY|FAULT_FLAG_RETRY_NOWAIT,
> > -				   pteval);
> > +				   pteval,
> > +				   GFP_HIGHUSER_MOVABLE | ~__GFP_DIRECT_RECLAIM);
> 
> Why only direct recliam? I'm not sure if triggering kswapd is justified
> for swapin. Maybe ~__GFP_RECLAIM?

Dunno, skipping kswapd sounds like we might consume a lot of memory
and the next request might hit the direct reclaim too early. But this is
only a speculation. This has to be measured properly and evaluated
against real usecases.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
