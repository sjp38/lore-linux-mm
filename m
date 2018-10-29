Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DACC96B0364
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 05:00:37 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id x1-v6so7244674eds.16
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 02:00:37 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 8-v6si5828188edx.32.2018.10.29.02.00.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Oct 2018 02:00:36 -0700 (PDT)
Date: Mon, 29 Oct 2018 10:00:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: thp:  relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
Message-ID: <20181029090035.GE32673@dhcp22.suse.cz>
References: <20180925120326.24392-1-mhocko@kernel.org>
 <20180925120326.24392-2-mhocko@kernel.org>
 <20181029051752.GB16399@350D>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181029051752.GB16399@350D>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Stable tree <stable@vger.kernel.org>

On Mon 29-10-18 16:17:52, Balbir Singh wrote:
[...]
> I wonder if alloc_pool_huge_page() should also trim out it's logic
> of __GFP_THISNODE for the same reasons as mentioned here. I like
> that we round robin to alloc the pool pages, but __GFP_THISNODE
> might be an overkill for that case as well.

alloc_pool_huge_page uses __GFP_THISNODE for a different reason than
THP. We really do want to allocated for a per-node pool. THP can
fallback or use a different node.

These hugetlb allocations might be disruptive and that is an expected
behavior because this is an explicit requirement from an admin to
pre-allocate large pages for the future use. __GFP_RETRY_MAYFAIL just
underlines that requirement.

Maybe the compaction logic could be improved and that might be a shared
goal with future changes though.
-- 
Michal Hocko
SUSE Labs
