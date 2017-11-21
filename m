Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E57FB6B0038
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 15:00:20 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id t76so6125445pfk.7
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 12:00:20 -0800 (PST)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id h185si11428922pgc.164.2017.11.21.12.00.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Nov 2017 12:00:19 -0800 (PST)
Date: Tue, 21 Nov 2017 19:59:54 +0000
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v2] mm: show total hugetlb memory consumption in
 /proc/meminfo
Message-ID: <20171121195947.GA12709@castle>
References: <20171115231409.12131-1-guro@fb.com>
 <20171120165110.587918bf75ffecb8144da66c@linux-foundation.org>
 <20171121151545.GA23974@castle>
 <20171121111907.6952d50adcbe435b1b6b4576@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20171121111907.6952d50adcbe435b1b6b4576@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar
 K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, David Rientjes <rientjes@google.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Tue, Nov 21, 2017 at 11:19:07AM -0800, Andrew Morton wrote:
> On Tue, 21 Nov 2017 15:15:55 +0000 Roman Gushchin <guro@fb.com> wrote:
> 
> > > > +
> > > > +	for_each_hstate(h) {
> > > > +		unsigned long count = h->nr_huge_pages;
> > > > +
> > > > +		total += (PAGE_SIZE << huge_page_order(h)) * count;
> > > > +
> > > > +		if (h == &default_hstate)
> > > 
> > > I'm not understanding this test.  Are we assuming that default_hstate
> > > always refers to the highest-index hstate?  If so why, and is that
> > > valid?
> > 
> > As Mike and Michal pointed, default_hstate is defined as
> >   #define default_hstate (hstates[default_hstate_idx]),
> > where default_hstate_idx can be altered by a boot argument.
> > 
> > We're iterating over all states to calculate total and also
> > print some additional info for the default size. Having a single
> > loop guarantees consistency of these numbers.
> > 
> 
> OK, I misread the handling of `count' -> HugePages_Total.
> 
> It seems unnecessarily obscure?
> 
> 	for_each_hstate(h) {
> 		unsigned long count = h->nr_huge_pages;
> 
> 		total += (PAGE_SIZE << huge_page_order(h)) * count;
> 
> 		if (h == &default_hstate)
> 			seq_printf(m,
> 				   "HugePages_Total:   %5lu\n"
> 				   "HugePages_Free:    %5lu\n"
> 				   "HugePages_Rsvd:    %5lu\n"
> 				   "HugePages_Surp:    %5lu\n"
> 				   "Hugepagesize:   %8lu kB\n",
> 				   count,
> 				   h->free_huge_pages,
> 				   h->resv_huge_pages,
> 				   h->surplus_huge_pages,
> 				   (PAGE_SIZE << huge_page_order(h)) / 1024);
> 	}
> 
> 	seq_printf(m, "Hugetlb:        %8lu kB\n", total / 1024);
> 
> 
> Why not
> 
> 	seq_printf(m,
> 			"HugePages_Total:   %5lu\n"
> 			"HugePages_Free:    %5lu\n"
> 			"HugePages_Rsvd:    %5lu\n"
> 			"HugePages_Surp:    %5lu\n"
> 			"Hugepagesize:   %8lu kB\n",
> 			h->nr_huge_pages,
> 			h->free_huge_pages,
> 			h->resv_huge_pages,
> 			h->surplus_huge_pages,
> 			1UL << (huge_page_order(h) + PAGE_SHIFT - 10));
> 
> 	for_each_hstate(h)
> 		total += (PAGE_SIZE << huge_page_order(h)) * h->nr_huge_pages;
> 	seq_printf(m, "Hugetlb:        %8lu kB\n", total / 1024);
> 	
> ?

The idea was that the local variable guarantees the consistency
between Hugetlb and HugePages_Total numbers. Otherwise we have
to take hugetlb_lock.

What we can do, is to rename "count" into "nr_huge_pages", like:

	for_each_hstate(h) {
		unsigned long nr_huge_pages = h->nr_huge_pages;

		total += (PAGE_SIZE << huge_page_order(h)) * nr_huge_pages;

		if (h == &default_hstate)
			seq_printf(m,
				   "HugePages_Total:   %5lu\n"
				   "HugePages_Free:    %5lu\n"
				   "HugePages_Rsvd:    %5lu\n"
				   "HugePages_Surp:    %5lu\n"
				   "Hugepagesize:   %8lu kB\n",
				   nr_huge_pages,
				   h->free_huge_pages,
				   h->resv_huge_pages,
				   h->surplus_huge_pages,
				   (PAGE_SIZE << huge_page_order(h)) / 1024);
	}

	seq_printf(m, "Hugetlb:        %8lu kB\n", total / 1024);

But maybe taking a lock is not a bad idea, because it will also
guarantee consistency between other numbers (like HugePages_Free) as well,
which is not true right now.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
