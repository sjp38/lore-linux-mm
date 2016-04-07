Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8FCC36B0005
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 08:51:48 -0400 (EDT)
Received: by mail-wm0-f41.google.com with SMTP id n3so103405086wmn.0
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 05:51:48 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id 16si8840202wmx.75.2016.04.07.05.51.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Apr 2016 05:51:47 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id n3so21233514wmn.1
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 05:51:47 -0700 (PDT)
Date: Thu, 7 Apr 2016 14:51:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch v2] mm, hugetlb_cgroup: round limit_in_bytes down to
 hugepage size
Message-ID: <20160407125145.GD32755@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1604051824320.32718@chino.kir.corp.google.com>
 <5704BA37.2080508@kyup.com>
 <5704BBBF.8040302@kyup.com>
 <alpine.DEB.2.10.1604061510040.10401@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1604061510040.10401@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nikolay Borisov <kernel@kyup.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 06-04-16 15:10:23, David Rientjes wrote:
[...]
> +static void hugetlb_cgroup_init(struct hugetlb_cgroup *h_cgroup,
> +				struct hugetlb_cgroup *parent_h_cgroup)
> +{
> +	int idx;
> +
> +	for (idx = 0; idx < HUGE_MAX_HSTATE; idx++) {
> +		struct page_counter *counter = &h_cgroup->hugepage[idx];
> +		struct page_counter *parent = NULL;
> +		unsigned long limit;
> +		int ret;
> +
> +		if (parent_h_cgroup)
> +			parent = &parent_h_cgroup->hugepage[idx];
> +		page_counter_init(counter, parent);
> +
> +		limit = round_down(PAGE_COUNTER_MAX,
> +				   1 << huge_page_order(&hstates[idx]));
> +		ret = page_counter_limit(counter, limit);
> +		VM_BUG_ON(ret);
> +	}
> +}

I fail to see the point for this. Why would want to round down
PAGE_COUNTER_MAX? It will never make a real difference. Or am I missing
something?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
