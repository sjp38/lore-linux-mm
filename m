Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id B25D86B0069
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 04:11:01 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id p9so15664855pgc.6
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 01:11:01 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a14si12915047pgv.479.2017.11.22.01.11.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Nov 2017 01:11:00 -0800 (PST)
Date: Wed, 22 Nov 2017 10:10:56 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: show total hugetlb memory consumption in
 /proc/meminfo
Message-ID: <20171122091056.axzpd7tb3mxif4sg@dhcp22.suse.cz>
References: <20171115231409.12131-1-guro@fb.com>
 <20171120165110.587918bf75ffecb8144da66c@linux-foundation.org>
 <20171121151545.GA23974@castle>
 <20171121111907.6952d50adcbe435b1b6b4576@linux-foundation.org>
 <20171121195947.GA12709@castle>
 <bafb4396-858a-bbbc-743d-43c7312da868@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bafb4396-858a-bbbc-743d-43c7312da868@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, David Rientjes <rientjes@google.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Tue 21-11-17 16:27:38, Mike Kravetz wrote:
> On 11/21/2017 11:59 AM, Roman Gushchin wrote:
[...]
> > What we can do, is to rename "count" into "nr_huge_pages", like:
> > 
> > 	for_each_hstate(h) {
> > 		unsigned long nr_huge_pages = h->nr_huge_pages;
> > 
> > 		total += (PAGE_SIZE << huge_page_order(h)) * nr_huge_pages;
> > 
> > 		if (h == &default_hstate)
> > 			seq_printf(m,
> > 				   "HugePages_Total:   %5lu\n"
> > 				   "HugePages_Free:    %5lu\n"
> > 				   "HugePages_Rsvd:    %5lu\n"
> > 				   "HugePages_Surp:    %5lu\n"
> > 				   "Hugepagesize:   %8lu kB\n",
> > 				   nr_huge_pages,
> > 				   h->free_huge_pages,
> > 				   h->resv_huge_pages,
> > 				   h->surplus_huge_pages,
> > 				   (PAGE_SIZE << huge_page_order(h)) / 1024);
> > 	}
> > 
> > 	seq_printf(m, "Hugetlb:        %8lu kB\n", total / 1024);
> > 
> > But maybe taking a lock is not a bad idea, because it will also
> > guarantee consistency between other numbers (like HugePages_Free) as well,
> > which is not true right now.
> 
> You are correct in that there is no consistency guarantee for the numbers
> with the default huge page size today.  However, I am not really a fan of
> taking the lock for that guarantee.  IMO, the above code is fine.

I agree

> This discussion reminds me that ideally there should be a per-hstate lock.
> My guess is that the global lock is a carry over from the days when only
> a single huge page size was supported.  In practice, I don't think this is
> much of an issue as people typically only use a single huge page size.  But,
> if anyone thinks is/may be an issue I am happy to make the changes.

Well, it kind of makes sense but I am not sure it is worth bothering.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
