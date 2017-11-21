Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id DA0136B0069
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 14:19:11 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id y41so8488884wrc.22
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 11:19:11 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u21si11298218wrc.235.2017.11.21.11.19.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Nov 2017 11:19:10 -0800 (PST)
Date: Tue, 21 Nov 2017 11:19:07 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: show total hugetlb memory consumption in
 /proc/meminfo
Message-Id: <20171121111907.6952d50adcbe435b1b6b4576@linux-foundation.org>
In-Reply-To: <20171121151545.GA23974@castle>
References: <20171115231409.12131-1-guro@fb.com>
	<20171120165110.587918bf75ffecb8144da66c@linux-foundation.org>
	<20171121151545.GA23974@castle>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, David Rientjes <rientjes@google.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Tue, 21 Nov 2017 15:15:55 +0000 Roman Gushchin <guro@fb.com> wrote:

> > > +
> > > +	for_each_hstate(h) {
> > > +		unsigned long count = h->nr_huge_pages;
> > > +
> > > +		total += (PAGE_SIZE << huge_page_order(h)) * count;
> > > +
> > > +		if (h == &default_hstate)
> > 
> > I'm not understanding this test.  Are we assuming that default_hstate
> > always refers to the highest-index hstate?  If so why, and is that
> > valid?
> 
> As Mike and Michal pointed, default_hstate is defined as
>   #define default_hstate (hstates[default_hstate_idx]),
> where default_hstate_idx can be altered by a boot argument.
> 
> We're iterating over all states to calculate total and also
> print some additional info for the default size. Having a single
> loop guarantees consistency of these numbers.
> 

OK, I misread the handling of `count' -> HugePages_Total.

It seems unnecessarily obscure?

	for_each_hstate(h) {
		unsigned long count = h->nr_huge_pages;

		total += (PAGE_SIZE << huge_page_order(h)) * count;

		if (h == &default_hstate)
			seq_printf(m,
				   "HugePages_Total:   %5lu\n"
				   "HugePages_Free:    %5lu\n"
				   "HugePages_Rsvd:    %5lu\n"
				   "HugePages_Surp:    %5lu\n"
				   "Hugepagesize:   %8lu kB\n",
				   count,
				   h->free_huge_pages,
				   h->resv_huge_pages,
				   h->surplus_huge_pages,
				   (PAGE_SIZE << huge_page_order(h)) / 1024);
	}

	seq_printf(m, "Hugetlb:        %8lu kB\n", total / 1024);


Why not

	seq_printf(m,
			"HugePages_Total:   %5lu\n"
			"HugePages_Free:    %5lu\n"
			"HugePages_Rsvd:    %5lu\n"
			"HugePages_Surp:    %5lu\n"
			"Hugepagesize:   %8lu kB\n",
			h->nr_huge_pages,
			h->free_huge_pages,
			h->resv_huge_pages,
			h->surplus_huge_pages,
			1UL << (huge_page_order(h) + PAGE_SHIFT - 10));

	for_each_hstate(h)
		total += (PAGE_SIZE << huge_page_order(h)) * h->nr_huge_pages;
	seq_printf(m, "Hugetlb:        %8lu kB\n", total / 1024);
	
?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
