Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id EF5E56B04FC
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 02:46:05 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id l3so37592254wrc.12
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 23:46:05 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u65si2998586wmg.82.2017.07.27.23.46.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Jul 2017 23:46:04 -0700 (PDT)
Date: Fri, 28 Jul 2017 08:46:02 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/1] mm/hugetlb mm/oom_kill:  Add support for
 reclaiming hugepages on OOM events.
Message-ID: <20170728064602.GC2274@dhcp22.suse.cz>
References: <20170727180236.6175-1-Liam.Howlett@Oracle.com>
 <20170727180236.6175-2-Liam.Howlett@Oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170727180236.6175-2-Liam.Howlett@Oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liam R. Howlett" <Liam.Howlett@Oracle.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, mike.kravetz@Oracle.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, punit.agrawal@arm.com, arnd@arndb.de, gerald.schaefer@de.ibm.com, aarcange@redhat.com, oleg@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, mingo@kernel.org, kirill.shutemov@linux.intel.com, vdavydov.dev@gmail.com, willy@infradead.org

On Thu 27-07-17 14:02:36, Liam R. Howlett wrote:
> When a system runs out of memory it may be desirable to reclaim
> unreserved hugepages.  This situation arises when a correctly configured
> system has a memory failure and takes corrective action of rebooting and
> removing the memory from the memory pool results in a system failing to
> boot.  With this change, the out of memory handler is able to reclaim
> any pages that are free and not reserved.

I am sorry but I have to Nack this. You are breaking the basic contract
of hugetlb user API. Administrator configures the pool to suit a
workload. It is a deliberate and privileged action. We allow to
overcommit that pool should there be a immediate need for more hugetlb
pages and we do remove those when they are freed. If we don't then this
should be fixed.
Other than that hugetlb pages are not reclaimable by design and users
do rely on that. Otherwise they could consider using THP instead.

If somebody configures the initial pool too high it is a configuration
bug. Just think about it, we do not want to reset lowmem reserves
configured by admin just because we are hitting the oom killer and yes
insanely large lowmem reserves might lead to early OOM as well.

Nacked-by: Michal Hocko <mhocko@suse.com>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
