Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E36026B0253
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 03:18:21 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id x66so7498252pfe.21
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 00:18:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k185si12517587pge.131.2017.11.15.00.18.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Nov 2017 00:18:20 -0800 (PST)
Date: Wed, 15 Nov 2017 09:18:18 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: show total hugetlb memory consumption in
 /proc/meminfo
Message-ID: <20171115081818.ucnp26tho4qffdwx@dhcp22.suse.cz>
References: <20171114125026.7055-1-guro@fb.com>
 <20171114131736.v2m6alrt5gelmh5c@dhcp22.suse.cz>
 <alpine.DEB.2.10.1711141425220.112995@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1711141425220.112995@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Tue 14-11-17 14:28:11, David Rientjes wrote:
[...]
> > /proc/meminfo is paved with mistakes throughout the history. It pretends
> > to give a good picture of the memory usage, yet we have many pointless
> > entries while large consumers are not reflected at all in many case.
> > 
> > Hugetlb data with that great details shouldn't have been exported in the
> > first place when they reflect only one specific hugepage size. I would
> > argue that if somebody went down to configure non-default hugetlb page
> > sizes then checking for the sysfs stats would be an immediate place to
> > look at. Anyway I can see that the cumulative information might be
> > helpful for those who do not own the machine but merely debug an issue
> > which is the primary usacase for the file.
> > 
> 
> I agree in principle, but I think it's inevitable on projects that span 
> decades and accumulate features that evolve over time.

Yes, this is acceptable in earlier stages but I believe we have reached
a mature state where we shouldn't repeat those mistakes.
[...]
> > >  	if (!hugepages_supported())
> > >  		return;
> > >  	seq_printf(m,
> > > @@ -2987,6 +2989,11 @@ void hugetlb_report_meminfo(struct seq_file *m)
> > >  			h->resv_huge_pages,
> > >  			h->surplus_huge_pages,
> > >  			1UL << (huge_page_order(h) + PAGE_SHIFT - 10));
> > > +
> > > +	for_each_hstate(h)
> > > +		total += (PAGE_SIZE << huge_page_order(h)) * h->nr_huge_pages;
> > 
> > Please keep the total calculation consistent with what we have there
> > already.
> > 
> 
> Yeah, and I'm not sure if your comment eludes to this being racy, but it 
> would be better to store the default size for default_hstate during the 
> iteration to total the size for all hstates.

I just meant to have the code consistent. I do not prefer one or other
option.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
