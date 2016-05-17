Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6A0E16B0005
	for <linux-mm@kvack.org>; Tue, 17 May 2016 07:31:19 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id ne4so7292972lbc.1
        for <linux-mm@kvack.org>; Tue, 17 May 2016 04:31:19 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id n141si2097097lfb.227.2016.05.17.04.31.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 May 2016 04:31:17 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id j8so862235lfd.0
        for <linux-mm@kvack.org>; Tue, 17 May 2016 04:31:17 -0700 (PDT)
Date: Tue, 17 May 2016 14:31:14 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: + mm-thp-avoid-unnecessary-swapin-in-khugepaged.patch added to
 -mm tree
Message-ID: <20160517113114.GC9540@node.shutemov.name>
References: <57212c60.fUSE244UFwhXE+az%akpm@linux-foundation.org>
 <20160428151921.GL31489@dhcp22.suse.cz>
 <20160517075815.GC14453@dhcp22.suse.cz>
 <20160517090254.GE14453@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160517090254.GE14453@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, ebru.akagunduz@gmail.com, aarcange@redhat.com, aneesh.kumar@linux.vnet.ibm.com, boaz@plexistor.com, gorcunov@openvz.org, hannes@cmpxchg.org, hughd@google.com, iamjoonsoo.kim@lge.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, n-horiguchi@ah.jp.nec.com, riel@redhat.com, rientjes@google.com, vbabka@suse.cz, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Tue, May 17, 2016 at 11:02:54AM +0200, Michal Hocko wrote:
> On Tue 17-05-16 09:58:15, Michal Hocko wrote:
> > On Thu 28-04-16 17:19:21, Michal Hocko wrote:
> > > On Wed 27-04-16 14:17:20, Andrew Morton wrote:
> > > [...]
> > > > @@ -2484,7 +2485,14 @@ static void collapse_huge_page(struct mm
> > > >  		goto out;
> > > >  	}
> > > >  
> > > > -	__collapse_huge_page_swapin(mm, vma, address, pmd);
> > > > +	swap = get_mm_counter(mm, MM_SWAPENTS);
> > > > +	curr_allocstall = sum_vm_event(ALLOCSTALL);
> > > > +	/*
> > > > +	 * When system under pressure, don't swapin readahead.
> > > > +	 * So that avoid unnecessary resource consuming.
> > > > +	 */
> > > > +	if (allocstall == curr_allocstall && swap != 0)
> > > > +		__collapse_huge_page_swapin(mm, vma, address, pmd);
> > > >  
> > > >  	anon_vma_lock_write(vma->anon_vma);
> > > >  
> > > 
> > > I have mentioned that before already but this seems like a rather weak
> > > heuristic. Don't we really rather teach __collapse_huge_page_swapin
> > > (resp. do_swap_page) do to an optimistic GFP_NOWAIT allocations and
> > > back off under the memory pressure?
> > 
> > I gave it a try and it doesn't seem really bad. Untested and I might
> > have missed something really obvious but what do you think about this
> > approach rather than relying on ALLOCSTALL which is really weak
> > heuristic:
> 
> Ups forgot to add mm/internal.h to the git index
> ---
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 87f09dc986ab..1a4d4c807d92 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2389,7 +2389,8 @@ static void __collapse_huge_page_swapin(struct mm_struct *mm,
>  		swapped_in++;
>  		ret = do_swap_page(mm, vma, _address, pte, pmd,
>  				   FAULT_FLAG_ALLOW_RETRY|FAULT_FLAG_RETRY_NOWAIT,
> -				   pteval);
> +				   pteval,
> +				   GFP_HIGHUSER_MOVABLE | ~__GFP_DIRECT_RECLAIM);

Why only direct recliam? I'm not sure if triggering kswapd is justified
for swapin. Maybe ~__GFP_RECLAIM?

That said, I like the approach. ALLOCSTALL approach has locking issue[1].

[1] http://lkml.kernel.org/r/20160505013245.GB10429@yexl-desktop

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
