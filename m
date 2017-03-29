Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id DA8586B0390
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 12:57:28 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id p52so4355605wrc.8
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 09:57:28 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id u95si9219520wrc.221.2017.03.29.09.57.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Mar 2017 09:57:27 -0700 (PDT)
Date: Wed, 29 Mar 2017 12:57:22 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm -v7 2/9] mm, memcg: Support to charge/uncharge
 multiple swap entries
Message-ID: <20170329165722.GB31821@cmpxchg.org>
References: <20170328053209.25876-1-ying.huang@intel.com>
 <20170328053209.25876-3-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170328053209.25876-3-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org

On Tue, Mar 28, 2017 at 01:32:02PM +0800, Huang, Ying wrote:
> @@ -5908,16 +5907,19 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
>  		css_put(&memcg->css);
>  }
>  
> -/*
> - * mem_cgroup_try_charge_swap - try charging a swap entry
> +/**
> + * mem_cgroup_try_charge_swap - try charging a set of swap entries
>   * @page: page being added to swap
> - * @entry: swap entry to charge
> + * @entry: the first swap entry to charge
> + * @nr_entries: the number of swap entries to charge
>   *
> - * Try to charge @entry to the memcg that @page belongs to.
> + * Try to charge @nr_entries swap entries starting from @entry to the
> + * memcg that @page belongs to.
>   *
>   * Returns 0 on success, -ENOMEM on failure.
>   */
> -int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry)
> +int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry,
> +			       unsigned int nr_entries)

I've pointed this out before, but there doesn't seem to be a reason to
pass @nr_entries when we have the struct page. Why can't this function
just check PageTransHuge() by itself?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
