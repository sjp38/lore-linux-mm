Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 774D06B007E
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 16:22:33 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u190so148672968pfb.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 13:22:33 -0700 (PDT)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id gl9si12208993pac.111.2016.04.14.13.22.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Apr 2016 13:22:32 -0700 (PDT)
Received: by mail-pf0-x235.google.com with SMTP id n1so49209401pfn.2
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 13:22:32 -0700 (PDT)
Date: Thu, 14 Apr 2016 13:22:30 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] mm, hugetlb_cgroup: round limit_in_bytes down to
 hugepage size
In-Reply-To: <20160407125145.GD32755@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1604141321350.6593@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1604051824320.32718@chino.kir.corp.google.com> <5704BA37.2080508@kyup.com> <5704BBBF.8040302@kyup.com> <alpine.DEB.2.10.1604061510040.10401@chino.kir.corp.google.com> <20160407125145.GD32755@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nikolay Borisov <kernel@kyup.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 7 Apr 2016, Michal Hocko wrote:

> > +static void hugetlb_cgroup_init(struct hugetlb_cgroup *h_cgroup,
> > +				struct hugetlb_cgroup *parent_h_cgroup)
> > +{
> > +	int idx;
> > +
> > +	for (idx = 0; idx < HUGE_MAX_HSTATE; idx++) {
> > +		struct page_counter *counter = &h_cgroup->hugepage[idx];
> > +		struct page_counter *parent = NULL;
> > +		unsigned long limit;
> > +		int ret;
> > +
> > +		if (parent_h_cgroup)
> > +			parent = &parent_h_cgroup->hugepage[idx];
> > +		page_counter_init(counter, parent);
> > +
> > +		limit = round_down(PAGE_COUNTER_MAX,
> > +				   1 << huge_page_order(&hstates[idx]));
> > +		ret = page_counter_limit(counter, limit);
> > +		VM_BUG_ON(ret);
> > +	}
> > +}
> 
> I fail to see the point for this. Why would want to round down
> PAGE_COUNTER_MAX? It will never make a real difference. Or am I missing
> something?

Did you try the patch?

If we're rounding down the user value, it makes sense to be consistent 
with the upper bound default to specify intent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
