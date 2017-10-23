Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 515146B0253
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 06:54:54 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 64so1137631wme.12
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 03:54:54 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c30sor3280082edf.16.2017.10.23.03.54.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Oct 2017 03:54:53 -0700 (PDT)
Date: Mon, 23 Oct 2017 13:54:50 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC PATCH] mm, thp: make deferred_split_shrinker memcg-aware
Message-ID: <20171023105450.jv4qerpzlrodfws6@node.shutemov.name>
References: <20171019200323.42491-1-nehaagarwal@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171019200323.42491-1-nehaagarwal@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Neha Agarwal <nehaagarwal@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Dan Williams <dan.j.williams@intel.com>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Kemi Wang <kemi.wang@intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Shaohua Li <shli@fb.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Thu, Oct 19, 2017 at 01:03:23PM -0700, Neha Agarwal wrote:
> deferred_split_shrinker is NUMA aware. Making it memcg-aware if
> CONFIG_MEMCG is enabled to prevent shrinking memory of memcg(s) that are
> not under memory pressure. This change isolates memory pressure across
> memcgs from deferred_split_shrinker perspective, by not prematurely
> splitting huge pages for the memcg that is not under memory pressure.
> 
> Note that a pte-mapped compound huge page charge is not moved to the dst
> memcg on task migration. Look mem_cgroup_move_charge_pte_range() for
> more information. Thus, mem_cgroup_move_account doesn't get called on
> pte-mapped compound huge pages, hence we do not need to transfer the
> page from source-memcg's split to destinations-memcg's split_queue.
> 
> Tested: Ran two copies of a microbenchmark with partially unmapped
> thp(s) in two separate memory cgroups. When first memory cgroup is put
> under memory pressure, it's own thp(s) split. Other memcg's thp(s)
> remain intact.
> 
> Current implementation is not NUMA aware if MEMCG is compiled. If it is
> important to have this shrinker both NUMA and MEMCG aware, I can work on
> that.  Some feedback on this front will be useful.

I thin, this should be done. That's strange compromise -- memcg vs NUMA.
And I think solving will help a lot with ifdefs.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
