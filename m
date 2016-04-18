Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7DB226B025E
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 17:24:01 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u190so352124147pfb.0
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 14:24:01 -0700 (PDT)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id 136si9631038pfw.92.2016.04.18.14.24.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Apr 2016 14:24:00 -0700 (PDT)
Received: by mail-pf0-x235.google.com with SMTP id e128so84389421pfe.3
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 14:24:00 -0700 (PDT)
Date: Mon, 18 Apr 2016 14:23:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] mm, hugetlb_cgroup: round limit_in_bytes down to
 hugepage size
In-Reply-To: <20160415132451.GL32377@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1604181422220.23710@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1604051824320.32718@chino.kir.corp.google.com> <5704BA37.2080508@kyup.com> <5704BBBF.8040302@kyup.com> <alpine.DEB.2.10.1604061510040.10401@chino.kir.corp.google.com> <20160407125145.GD32755@dhcp22.suse.cz>
 <alpine.DEB.2.10.1604141321350.6593@chino.kir.corp.google.com> <20160415132451.GL32377@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nikolay Borisov <kernel@kyup.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 15 Apr 2016, Michal Hocko wrote:

> > > > +static void hugetlb_cgroup_init(struct hugetlb_cgroup *h_cgroup,
> > > > +				struct hugetlb_cgroup *parent_h_cgroup)
> > > > +{
> > > > +	int idx;
> > > > +
> > > > +	for (idx = 0; idx < HUGE_MAX_HSTATE; idx++) {
> > > > +		struct page_counter *counter = &h_cgroup->hugepage[idx];
> > > > +		struct page_counter *parent = NULL;
> > > > +		unsigned long limit;
> > > > +		int ret;
> > > > +
> > > > +		if (parent_h_cgroup)
> > > > +			parent = &parent_h_cgroup->hugepage[idx];
> > > > +		page_counter_init(counter, parent);
> > > > +
> > > > +		limit = round_down(PAGE_COUNTER_MAX,
> > > > +				   1 << huge_page_order(&hstates[idx]));
> > > > +		ret = page_counter_limit(counter, limit);
> > > > +		VM_BUG_ON(ret);
> > > > +	}
> > > > +}
> > > 
> > > I fail to see the point for this. Why would want to round down
> > > PAGE_COUNTER_MAX? It will never make a real difference. Or am I missing
> > > something?
> > 
> > Did you try the patch?
> > 
> > If we're rounding down the user value, it makes sense to be consistent 
> > with the upper bound default to specify intent.
> 
> The point I've tried to raise is why do we care and add a code if we can
> never reach that value? Does actually anybody checks for the alignment.

If the user modifies the value successfully, it can never be restored to 
the default since the write handler rounds down.  It's a matter of 
consistency for a long-term maintainable kernel and prevents bug reports.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
